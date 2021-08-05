local fnaf = {}


function fnaf:Setup()
    -- Init
    self:GetChild('bg_office'):xy( SCREEN_CENTER_X, SCREEN_CENTER_Y )
    local cur_height = 768
    local good_height = SCREEN_HEIGHT + 160
    self:GetChild('bg_office'):zoom( good_height / cur_height )
    self:GetChild('bg_office'):hidden(1)

    self:GetChild('fg_camera'):xy( SCREEN_CENTER_X, SCREEN_CENTER_Y )
    self:GetChild('fg_camera'):zoomto( SCREEN_WIDTH, SCREEN_HEIGHT )
    self:GetChild('fg_camera'):cmd('animate,0;setstate,0;hidden,1')

    self:GetChild('fg_camera_cleanup'):xy( SCREEN_CENTER_X, SCREEN_CENTER_Y )
    self:GetChild('fg_camera_cleanup'):zoomto( SCREEN_WIDTH, SCREEN_HEIGHT )
    self:GetChild('fg_camera_cleanup'):cmd('animate,0;setstate,0;hidden,1')

    self:GetChild('fg_scare'):xy( SCREEN_CENTER_X, SCREEN_CENTER_Y )
    self:GetChild('fg_scare'):playcommand('CleanAnimatronics')

    self:GetChild('ScareUpdate'):luaeffect('Update')
end

function fnaf:Prepare()
    
end

function fnaf:Dead()
    -- Trigger
    self:GetChild('bg_office'):hidden(1)
    self:GetChild('fg_camera'):cmd('animate,0;setstate,0;hidden,1')
    self:GetChild('fg_camera_cleanup'):cmd('animate,0;setstate,0;hidden,1')
    self:GetChild('fg_scare'):playcommand('CleanAnimatronics')
    self:GetChild('Controller'):queuecommand('Spook')
end


return fnaf