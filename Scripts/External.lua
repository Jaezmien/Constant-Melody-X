--[[

    jaezmien's external handler v2

    todo: find way to encode two letters into one number

]]

local handler = {}

handler.disabled = false

-- simple encode/decode
    local encode_guide = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 \n'\"~!@#$%^&*()<>/-=_+[]:;.,`{}"
    handler.encode = function(s)
        local t = {}
        for i=1,string.len(s) do
            local char = string.sub(s,i,i)
            for c=1,string.len(encode_guide) do
                if string.sub(encode_guide,c,c) == char then table.insert(t,c) break end
            end
        end
        return t
    end
    handler.decode = function(t)
        local s = ""
        for i,v in pairs(t) do
            s = s..(string.sub(encode_guide,v,v))
        end
        return s
    end
--

-- id = sender id
-- out = buffer
-- set = 0=full,1=partial,2=partial_end
handler.buffer = {}
handler.add_buffer = function(self,id,buffer)

    if type(id) ~= 'number' then
        Debug('[External] Sender id must be a number.')
    end
    if id < 1 then
        Debug('[External] Sender id must be greater than 0.')
    end
    local buff_length = 26
    if table.getn(buffer) > buff_length then
        local ind = 1
        while ind<=table.getn(buffer) do
            local _t = {}
            for i=ind,ind+(buff_length-1) do
                if i<=table.getn(buffer) then
                    table.insert(_t,buffer[i])
                end
            end
            table.insert( self.buffer , { id = id , out= _t , set=((ind+buff_length>table.getn(buffer)) and 2 or 1) } )
            ind=ind+buff_length
        end
    else
        table.insert( self.buffer , { id = id , out = buffer , set=0 } )
    end

end

handler.hooks = {}
handler.add_hook = function(self,id,ide,func)
    if type(id)~='number' then
        Debug('[External Handler] Hook id must be a number.')
        return
    end
    self.hooks[ id ] = self.hooks[ id ] or {}
    self.hooks[ id ][ ide ] = func -- Allows multiple hooks on one id.
end
handler.remove_hook = function(self,id,ide)
    if type(id)~='number' then
        Debug('[External Handler] Hook id must be a number.')
        return
    end
    if not self.hooks[ id ] then
        Debug('[External Handler] Hook id doesn\'t contain any hooks.')
        return
    end
    self.hooks[ id ][ ide ] = nil
end
handler.has_hook = function(self,id) return self.hooks[ id ] ~= nil end
handler.get_hooks = function(self,id)
    return self.hooks[ id ]
end

-- Updating
local read_buffer = {}
handler.tick = function(self)
    if self.disabled or not self.initialized then return end
    if not CONSTMELODY.MinimumVersion('V3') then
        Debug('[External] External only works for V3 onward. Disabling.')
        self.disabled = true
        return
    end
    --[[

        << JAEZMIEN'S EXTERNAL MAPPING >>
        0-25  - READ        (26)
        26    - READ LENGTH
        27    - IS READ A PART OF A SET (0=No,1=Yes,2=Yes and the end of set)
        28-53 - WRITE       (26)
        54    - WRITE LENGTH
        55    - IS WRITE A PART OF A SET (0=No,1=Yes,2=Yes and the end of set)
        56    - Reader Flag (0=Idle,1=Reserved/Writing,2=Read) [by external application]
        57    - Writer Flag (0=Idle,1=Avaiable)                [by this program]
        58    - Sender ID for Reader
        59    - Sender ID for Writer
        60    - Has NotITG initialized? (and not in loading state)
        61    - Empty
        62    - Empty
        63    - Empty

        i have no fucking idea if this is efficient or not but hey at least read/write is separate for  s p e e d

    ]]
    -- READ
    if GAMESTATE:GetExternal(56) == 2 then
        local r_bf = {}
        for i=1,GAMESTATE:GetExternal(26) do
            table.insert( r_bf , GAMESTATE:GetExternal(i-1) )
            GAMESTATE:SetExternal( i-1 , 0 )
        end
        GAMESTATE:SetExternal(26,0)
        local r_id = GAMESTATE:GetExternal(58)

        if GAMESTATE:GetExternal(27) == 0 then

            if self:has_hook(r_id) then
                for i,v in pairs( self:get_hooks(r_id) ) do
                    v( r_bf )
                end
            end

        else

            read_buffer[r_id] = read_buffer[r_id] or {}
            for i,v in pairs(r_bf) do
                table.insert( read_buffer[r_id] , v )
            end
            if GAMESTATE:GetExternal(27) == 2 then
                if self:has_hook(r_id) then
                    for i,v in pairs( self:get_hooks(r_id) ) do
                        v( read_buffer[r_id] )
                    end
                end
                read_buffer[r_id] = nil
            end

        end

        GAMESTATE:SetExternal(27, 0)
        GAMESTATE:SetExternal(56, 0)
        GAMESTATE:SetExternal(58, 0)
    end
    -- WRITE
    if GAMESTATE:GetExternal(57) == 0 and table.getn( self.buffer ) > 0 then
        local w_bf = self.buffer[1]
        for i,v in pairs(w_bf.out) do
            GAMESTATE:SetExternal( 27+i , v )
        end
        GAMESTATE:SetExternal( 54 , table.getn(w_bf.out) )
        GAMESTATE:SetExternal( 55 , w_bf.set )
        GAMESTATE:SetExternal( 59 , w_bf.id )
        GAMESTATE:SetExternal( 57 , 1 )

        table.remove(self.buffer,1)
        self.last_seen_write = w_bf
    end
    --
end
handler.clear_write = function(self)
    for i=28,53 do GAMESTATE:SetExternal(i,0) end
    GAMESTATE:SetExternal(57,0)
    GAMESTATE:SetExternal(59,0)
end
handler.check_write = function(self)

    local w_bf = {}
    w_bf.out = {}
    for i=1,GAMESTATE:GetExternal(54) do
        table.insert( w_bf.out , GAMESTATE:GetExternal(27+i) )
    end
    w_bf.set = GAMESTATE:GetExternal(55)
    w_bf.id = GAMESTATE:GetExternal(59)

    if table.getn(self.last_seen_write.out) ~= table.getn(w_bf.out) then return false end

    local changed = false
    for i,v in pairs(w_bf.out) do
        if self.last_seen_write.out[i] ~= v then
            changed = true
            break
        end
    end
    return not changed and (w_bf.id == self.last_seen_write.id) and (w_bf.set == self.last_seen_write.set)

end

--
handler.initialized = false
handler.initialize = function(self)
    for i=0,63 do
        GAMESTATE:SetExternal(i,0)
    end
    GAMESTATE:SetExternal(60,1)
    print('[External] Initialized!')
end

-- i was about to do this long if-else statement but i got lazy
local debug_help = {
    { {0,25}, 'Read Buffer' },
    { 26, 'Read Buffer Length' },
    { 27, 'Read Type (0 = Single, 1 = Part of Set, 2 = End of Set)' },
    { {28,53}, 'Write Buffer' },
    { 54, 'Write Buffer Length' },
    { 55, 'Write Type (0 = Single, 1 = Part of Set, 3 = End of Set)' },
    { 56, 'Read Flag by External (0 = Idle, 1 = Reserved/Writing, 2 = Allowing Read)'},
    { 57, 'Write Flag by NotITG (0 = Idle, 1 = Available)' },
    { 58, 'Reader ID' },
    { 59, 'Writer ID' },
    { 60, 'Initialized State (0 = No, 1 = Yes)' },
    { 61, 'Extra 1' },
    { 62, 'Extra 2' },
    { 63, 'Extra 3' },
}
local debug_help_parseable = {}
for i,v in pairs(debug_help) do
    if type(v[1]) == 'table' then
        for k=v[1][1], v[1][2] do
            debug_help_parseable[ k ] = v[2]
        end
    else
        debug_help_parseable[ v[1] ] = v[2]
    end
end
handler.dump = function()
    print('---')
    for i=0,63 do
        print( '', debug_help_parseable[i]  )
        print( '', '', i+1, GAMESTATE:GetExternal(i) )
    end
    print('---')
end

--
handler.last_seen_write = nil
handler.timer = nil

External = handler