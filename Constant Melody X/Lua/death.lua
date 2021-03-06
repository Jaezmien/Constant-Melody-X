local death = {}
local current = CONSTMELODY.Profile.Get().Options_FailOption or 1

local types = {
    {
        Name = "Off"
    },
    {
        Name = "Random"
    },
}

local players = 0

local isReady = false

--function death.Next()
--    if SCREENMAN:GetTopScreen():GetName() ~= 'ScreenGameplay' then return end -- Only apply this option when we're in ScreenGameplay... Though this seems like a bad idea, since there might be files that will utilize the Action buttons.
--    current = current%#types+1
--    if types[current].Prepare then
--        types[current].Prepare(types[current].Frame)
--    end
--    SCREENMAN:SystemMessage('FailOverlay '..types[current].Name)
--end

function death.Switch(n)
    current = n

    if types[current].Prepare then
        types[current].Prepare(types[current].Frame)
    end
end

function death.Trigger()
    if not CONSTMELODY.Profile.Get().Options_DefaultFail then return end -- If we're using default fail, don't call the script.
    local actual_current = current
    if current == 2 then
        actual_current = math.random(3, table.getn(types))
        if types[actual_current].Prepare then -- one time prepare
            types[actual_current].Prepare(types[current].Frame)
        end
    end
    if types[actual_current].Dead then
        types[actual_current].Dead(types[actual_current].Frame)
    end
end

function death:Ready()
    if isReady then return end
    isReady = true
    d_af = self
    if not FUCK_EXE or not CONSTMELODY.MinimumVersion('V3.1') then self:hidden(1); return end -- Disable this if we're on OpenITG or below v3.1
    if not CONSTMELODY.Profile.Get().Options_FailOption then CONSTMELODY.Profile.Get().Options_FailOption = 1; CONSTMELODY.Profile.Set(); end

    for i=1,self:GetNumChildren() do
        local actor = self:GetChildAt(i-1)
        local name = actor:GetName()
        local style = stitch("lua.death."..name)
        style.Name = style.Name or name
        style.Frame = actor
        if style.Setup then style.Setup(actor) end
        types[i+2] = style
        CONSTMELODY.ExtraOptions.FailOption_Choices[i+2] = style.Name
    end

    for i=1,2 do
        local pn = i
        self:addcommand("XFailP"..pn.."Message",function()
            players = players - 1
            if players == 0 then
                death.Trigger()
            end
        end)
    end

    --self:addcommand("StepP1Action5PressMessage", death.Next)
end

function death.Start()
    if not FUCK_EXE or not CONSTMELODY.MinimumVersion('V3.1') then return end -- Disable this if we're on OpenITG or v3.1 below
    players = GAMESTATE:GetNumPlayersEnabled()
    if types[current].Prepare then
        types[current].Prepare(types[current].Frame)
    end
end

function death.Test()
    death.Start()
    death.Trigger()
end

return death