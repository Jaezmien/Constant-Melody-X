local demotiv = {}

function demotiv:Setup()
    self:hidden(1)
end

function demotiv:Prepare()
    self:GetChild('AFT Sprite'):SetTexture( self:GetChild('AFT'):GetTexture() )
    demotiv.Prepare = nil
end

function demotiv:Dead()
    self:GetChild('AFT'):queuecommand('Freeze')

    local text = {
        {'What','how you fail that'},
        {'Really','you just had to miss that arrow'},
        {'WHAT THE FUCK','what the hell why did you miss that\narrow are you stupid what the hell'},
        {'WHAT','HOW'},
        {'Bruh','bruh momento numero dos'},
        {'?','?'},
        {'How','How did you miss that arrow are you stupid'},
    }
    local ind = math.random(1, table.getn(text))
    self:GetChild('Top'):settext( text[ind][1] )
    self:GetChild('Bottom'):settext( text[ind][2] )

    self:hidden(0)
    self:GetChild('Audio'):queuecommand('Play')
end

return demotiv