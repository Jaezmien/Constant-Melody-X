local event = stitch 'lua.event'
local name = nil
local practice = {}

function practice:Setup()
    self:GetChildAt(1 - 1):halign(0)
    self:GetChildAt(2 - 1):halign(1)
    self:GetChildAt(1 - 1):xy(SCREEN_CENTER_X * -1, SCREEN_CENTER_Y)
    self:GetChildAt(2 - 1):xy(SCREEN_CENTER_X * 3, SCREEN_CENTER_Y)
    self:GetChildAt(1 - 1):hidden(1)
    self:GetChildAt(2 - 1):hidden(1)
end

function practice:Prepare() end

function practice:Dead()
        name = SCREENMAN():GetName()
    local sounds = {
        GAMESTATE:GetFileStructure('Themes/' .. THEME:GetCurThemeName() ..
                                       '/Screens/Overlay/Death/Practice/Sound Funnies/')
    }
    local choice = sounds[math.random(1, table.getn(sounds))]
    SOUND:PlayOnce('Themes/' .. THEME:GetCurThemeName() ..
                       '/Screens/Overlay/Death/Practice/Sound Funnies/' ..
                       choice)
    self:GetChildAt(1 - 1):hidden(0)
    self:GetChildAt(2 - 1):hidden(0)
    self:GetChildAt(1 - 1):zoomto(SCREEN_WIDTH / 2, SCREEN_HEIGHT)
    self:GetChildAt(2 - 1):zoomto(SCREEN_WIDTH / 2, SCREEN_HEIGHT)
    self:GetChildAt(1 - 1):linear(0.25)
    self:GetChildAt(2 - 1):linear(0.25)
    self:GetChildAt(1 - 1):x(SCREEN_CENTER_X * 0)
    self:GetChildAt(2 - 1):x(SCREEN_CENTER_X * 2)
    SCREENMAN:GetTopScreen():PauseGame(true)
    event.Timer(5, function()
        SCREENMAN:GetTopScreen():PauseGame(false);
        GAMESTATE:FinishSong()
    end)
    event.Add('update', 'prac_exit', function()
        if SCREENMAN():GetName() == name then return end
        self:GetChildAt(1 - 1):linear(2)
        self:GetChildAt(2 - 1):linear(2)
        self:GetChildAt(1 - 1):xy(SCREEN_CENTER_X * -1, SCREEN_CENTER_Y)
        self:GetChildAt(2 - 1):xy(SCREEN_CENTER_X * 3, SCREEN_CENTER_Y)
        event.Remove('update', 'prac_exit')
    end)
end

return practice
