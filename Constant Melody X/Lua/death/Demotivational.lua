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
    }
    local ind = math.random(1, table.getn(text))
    self:GetChild('Top'):settext( text[ind][1] )
    self:GetChild('Bottom'):settext( text[ind][2] )

    self:hidden(0)
    self:GetChild('Audio'):queuecommand('Play')
end

return demotiv