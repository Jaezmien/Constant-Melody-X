local youdied = {}

function youdied:Setup()
    self:GetChildAt(1-1):cmd("stretchto,0,0,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,1,0,0,0")
    self:GetChildAt(2-1):cmd("xy,SCREEN_CENTER_X,SCREEN_CENTER_Y;diffusealpha,0;")
end

function youdied:Dead()
    GAMESTATE:ApplyGameCommand('sound,srt_hit')
    self:GetChildAt(1-1):cmd("diffusealpha,.7;linear,.4;diffusealpha,0;")
    self:GetChildAt(2-1):cmd("diffusealpha,1;linear,1;diffusealpha,0;")
end

return youdied