local event = stitch 'lua.event'
local ut = {}

-- Dialog stuffs --
    local dialog = {}
    local read = {}
    local read_index = 1

    local dialog_chars = {}

    local sfx_dir = ''
    local function sound(str)
        SOUND:PlayOnce(sfx_dir .. str .. '.ogg')
    end

    local char_width = {
        detM24 = {
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,29,14,14,14,14,14,14,14,14,14,14,
            14,14,18,14,14,14,14,14,14,14,14,14,13,14,14,14,14,14,14,
            14,14,14,14,0,14,14,9,8,14,14,14,14,14,7,14,14,24,21,
            26,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
            14,14,14,14,14,14,14,14,14
        }
    }
    local char_states = {
        -- + Special Characters (1)
            [' '] = 0,
            ['space'] = 0,
            ['!'] = 1,
            ['&quot;'] = 2,
            ['"'] = 2,
            ['#'] = 3,
            ['$'] = 4,
            ['%'] = 5,
            ['&'] = 6,
            ['\''] = 7,
            ['('] = 8,
            [')'] = 9,
            ['*'] = 10,
            ['+'] = 11,
            [','] = 12,
            ['-'] = 13,
            ['.'] = 14,
            ['/'] = 15,
        -- + Special Characters (1)
    
        -- + Numbers
            ['0'] = 16,
            ['1'] = 17,
            ['2'] = 18,
            ['3'] = 19,
            ['4'] = 20,
            ['5'] = 21,
            ['6'] = 22,
            ['7'] = 23,
            ['8'] = 24,
            ['9'] = 25,
        -- + Numbers
    
        -- + Special Characters (2)
            [':'] = 26,
            [';'] = 27,
            ['<'] = 28,
            ['='] = 29,
            ['>'] = 30,
            ['?'] = 31,
            ['@'] = 32,
            -- + Special Characters (2)
    
            -- + Uppercase Letters
            ['A'] = 33,
            ['B'] = 34,
            ['C'] = 35,
            ['D'] = 36,
            ['E'] = 37,
            ['F'] = 38,
            ['G'] = 39,
            ['H'] = 40,
            ['I'] = 41,
            ['J'] = 42,
            ['K'] = 43,
            ['L'] = 44,
            ['M'] = 45,
            ['N'] = 46,
            ['O'] = 47,
            ['P'] = 48,
            ['Q'] = 49,
            ['R'] = 50,
            ['S'] = 51,
            ['T'] = 52,
            ['U'] = 53,
            ['V'] = 54,
            ['W'] = 55,
            ['X'] = 56,
            ['Y'] = 57,
            ['Z'] = 58,
        -- + Uppercase Letters
    
        -- + Special Characters (3)
            ['['] = 59,
            ['\\'] = 60,
            [']'] = 61,
            ['^'] = 62,
            ['_'] = 63,
            ['`'] = 64,
        -- + Special Characters (3)
    
        -- + Lowercase Letters
            ['a'] = 65,
            ['b'] = 66,
            ['c'] = 67,
            ['d'] = 68,
            ['e'] = 69,
            ['f'] = 70,
            ['g'] = 71,
            ['h'] = 72,
            ['i'] = 73,
            ['j'] = 74,
            ['k'] = 75,
            ['l'] = 76,
            ['m'] = 77,
            ['n'] = 78,
            ['o'] = 79,
            ['p'] = 80,
            ['q'] = 81,
            ['r'] = 82,
            ['s'] = 83,
            ['t'] = 84,
            ['u'] = 85,
            ['v'] = 86,
            ['w'] = 87,
            ['x'] = 88,
            ['y'] = 89,
            ['z'] = 90,
        -- + Lowercase Letters
    
        -- + Special Characters (4)
            ['{'] = 91,
            ['|'] = 92,
            ['}'] = 93,
            ['~'] = 94
        -- + Special Characters (4)
    }
--

function ut:Setup()
    sfx_dir = self:GetXMLDir() .. 'Undertale/'
    self:hidden(1)

    -- Setup dialog functions
        dialog.Hide = function()
            dialog_chars = {}
            self:GetChild('Dialog'):GetChild('Renderer'):finishtweening()
            self:GetChild('Dialog'):hidden(1)
        end
        dialog.Show = function()
            self:GetChild('Dialog'):hidden(0)
        end
        dialog.Clear = function() 
            self:GetChild('Dialog'):GetChild('Renderer'):finishtweening()
            dialog_chars = {}
        end

        dialog.Say = function(text)
            read = {}
            read_index = 1

            text = text

            local actor_index = 1
            local char_index = 1

            local text_position_x = 0
            local text_position_y = 0

            local current_pause = 0.08
            local current_color = {1,1,1}
            while char_index <= string.len(text) do
                local char = string.sub(text,char_index,char_index)
                if char == ' ' then
                    text_position_x = text_position_x + char_width.detM24[1]
                elseif char == '$' then
                    local special = string.sub(text,char_index+1,char_index+1)
                    char_index = char_index + 1
                    --
                    if special == 'n' then
                        text_position_x = 0
                        text_position_y = text_position_y + 30
                    elseif special == 'p' then
                        table.insert(read, {pause = 0.6})
                    elseif special == 's' then
                        current_pause = 0.18
                    elseif special == 'y' then
                        current_color = {1,1,0}
                    elseif special == 'c' then
                        current_pause = 0.05
                        current_color = {1,1,1}
                    end
                else
                    local char_state = char_states[ char ]
                    local char_width = char_width.detM24[ char_state + 1 ]
                    --
                    local actor = {
                        Position = {
                            (text_position_x + char_width / 2),
                            text_position_y
                        },
                        State = char_state,
                    }
                    text_position_x = text_position_x + char_width + 4
                    
                    table.insert( read , {actor = actor, pause = current_pause} )
                    --
                    actor_index = actor_index + 1
                end
                char_index = char_index + 1
            end

            self:GetChild('Dialog'):GetChild('Renderer'):queuecommand('Render')
        end

        -- Text update
        dialog.Render = function()

            if read_index <= #read then
                local current = read[ read_index ]
                if current.actor then
                    sound( 'talk_asgore' )
                    table.insert(dialog_chars, current.actor)
                end
                read_index = read_index + 1
                return true, current.pause
            end

            return false

        end

        -- Text render
        dialog.Update = function()
            local tex = self:GetChild('Dialog'):GetChild('Texture')
            for i,v in pairs(dialog_chars) do
                tex:hidden(0)

                tex:xy( v.Position[1], v.Position[2] )
                tex:setstate( v.State )

                tex:Draw()
                tex:hidden(1)
            end
        end
    --


    self:GetChild('Dialog'):GetChild('Pool'):SetDrawFunction(function()
        local res, err = pcall(dialog.Update)
        if not res then print(err) end
    end)
    self:GetChild('Dialog'):GetChild('Renderer'):addcommand('Render',function(_)
        local continue, delay = dialog.Render()
        if continue then
            _:sleep(delay)
            _:queuecommand('Render')
        end
    end)
end
function ut:Prepare()

end

local shards = {
    {},
    {}
}
function update_shards(self, plr)
    local p = plr
    event.Add('update','ut death shards',function(delta_time,time)
        local dt = delta_time*60
        for pn,pl in pairs(p) do
            local new_table = {}

            for i,v in pairs(shards[pn]) do
                if v and v.Position[2] <= SCREEN_HEIGHT + 8 then
                    v.Position[1] = v.Position[1] + v.Velocity[1] * dt
                    v.AirTime = v.AirTime + 0.2 * ( dt/ (DISPLAY:GetFPS()/60) )
                    v.Velocity[2] = v.Velocity[2] + 0.03 * v.AirTime
                    v.Position[2] = v.Position[2] + v.Velocity[2] * dt
                    pl:GetChild('Shard '..i):hidden(0)
                    pl:GetChild('Shard '..i):animate(1)
                    pl:GetChild('Shard '..i):xy( v.Position[1], v.Position[2] )
                    new_table[i] = v
                else
                    pl:GetChild('Shard '..i):hidden(1)
                end
            end
            
            shards[pn] = new_table
        end

        local finished = {
            (not p[1]) or table.getn(shards[1])==0,
            (not p[2]) or table.getn(shards[2])==0
        }
        if finished[1] and finished[2] then event.Remove('update','ut death shards') end
    
    end)
end

function ut:Dead()
    self:hidden(0)
    shards = { {}, {} }
    local function create_shard(pn, velocity)
        local shard = {
            Position = {
                0, 0
            },
            AirTime = 0,
        }
        shard.Velocity = velocity
        shard.Velocity[1] = shard.Velocity[1] + ( math.random() + math.random(-2,2) )
        shard.Velocity[2] = shard.Velocity[2] + ( math.random() + math.random(-2,2) )
        table.insert(shards[pn], shard)
    end

    local player_pos = {
        {SCREEN_CENTER_X*0.5, SCREEN_CENTER_Y},
        {SCREEN_CENTER_X*1.5, SCREEN_CENTER_Y},
    }
    local plr = {
        self:GetChild('Player 1'),
        self:GetChild('Player 2')
    }
    
    if SCREENMAN:GetTopScreen():GetName() == 'ScreenGameplay' then
        SCREENMAN:GetTopScreen():PauseGame(true)

        for i=1,2 do
            if GAMESTATE:IsPlayerEnabled( i-1 ) then
                local p = SCREENMAN:GetTopScreen():GetChild('PlayerP'..i)
                player_pos[i] = {
                    p:GetX(),
                    p:GetY()
                }

                create_shard(i, {-2,-4})
                create_shard(i, {1,-3.5})
                create_shard(i, {3,-2})
                create_shard(i, {-3,1})
                create_shard(i, {0.5,3})
                create_shard(i, {4,0.5})
            else
                plr[i] = nil
            end
        end
    end

    -- woo (Setup)
        sound('soul_damage')
        for i,v in pairs(plr) do
            v:hidden(0)
            v:GetChild('Heart Full'):hidden(0)
            v:xy( player_pos[i][1], player_pos[i][2] )
        end
    -- Heart
        local t_s = 80/60
        local t_l = 280/60
        event.Timer(t_s,function()
        
            for i,v in pairs(plr) do
                v:GetChild('Heart Full'):hidden(1)
                v:GetChild('Heart Break'):hidden(0)
                sound('soul_gameover_hit')
            end
            event.Timer(t_s, function()
               
                for i,v in pairs(plr) do
                    v:GetChild('Heart Break'):hidden(1)
                    sound('soul_gameover_hit_break')
                end
                update_shards(self, plr)
                event.Timer(t_s, function()
                    
                    self:GetChild('Game Over'):linear(2)
                    self:GetChild('Game Over'):diffusealpha(1)
                    self:GetChild('Game Over Audio'):start()
                    event.Timer(t_l, function()
                    
                        dialog.Show()
                        dialog.Say("You cannot give$nup just yet...")
                        event.Timer(t_l, function()
                    
                            dialog.Clear()
                            dialog.Say("Player!$p$p$nStay determined...")
                            event.Timer(300/60, function()
                    
                                dialog.Hide()
                                self:GetChild('Game Over'):linear(1)
                                self:GetChild('Game Over'):diffusealpha(1)
                                self:GetChild('Game Over'):linear(2)
                                self:GetChild('Game Over'):diffusealpha(0)
                                event.Timer(3,function()
                                    
                                    self:hidden(1)
                                    self:GetChild('Game Over Audio'):stop()
                                    if SCREENMAN:GetTopScreen():GetName() == 'ScreenGameplay' then
                                        SCREENMAN:GetTopScreen():PauseGame(false)
                                        GAMESTATE:FinishSong()
                                    end

                                end)
        
                            end)
    
                        end)

                    end)

                end)

            end)

        end)
    -- Fade in
    -- Dialog
    -- Fade out
end

return ut