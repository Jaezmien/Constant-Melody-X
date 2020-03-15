local config = stitch 'config'
local event = stitch 'lua.event'
local self = self

self:x(0)
self:y(0)
self:zoom(1)
self:horizalign("left")
self:vertalign("top")

-- Uksrt tournament stuff
event.Persist("key char","uksrt", function(c)
    if string.find(c, "%w") then
        MESSAGEMAN:Broadcast("KeyPress"..c)
    end
end)

-- Widescreen centering hack
if FUCK_EXE then
    local function pref(name)
        return PREFSMAN:GetPreference(name)
    end
    if  pref("CenterImageTranslateX") ~= 0 or
        pref("CenterImageTranslateY") ~= 0 or
        pref("CenterImageAddWidth") ~= 0 or
        pref("CenterImageAddHeight") ~= 0 then
        event.Persist("update","afts sucks", function()
            DISPLAY:ChangeCentering(
                pref("CenterImageTranslateX"),
                pref("CenterImageTranslateY"),
                pref("CenterImageAddWidth"),
                pref("CenterImageAddHeight")
            )
        end)
    end
end

-- OpenITG EditorShowSongTitle emulation
if config.EditorShowSongTitle == nil then
    config.EditorShowSongTitle = true
end

-- wee hee
if not CONSTMELODY.MinimumVersion('V4') then
    local disp_width = PREFSMAN:GetPreference('DisplayWidth')
    local disp_height = PREFSMAN:GetPreference('DisplayHeight')
    --
    SCREEN_WIDTH = 480 * (disp_width / disp_height)
    SCREEN_CENTER_X = SCREEN_WIDTH / 2
end