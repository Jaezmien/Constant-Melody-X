local continued = {}

function continued:Setup()
    self:hidden(1)
end

function continued:Prepare()
    self:GetChild('AFT Sprite'):SetTexture( self:GetChild('AFT'):GetTexture() )
    continued.Prepare = nil
end

function continued:Dead()
    self:GetChild('AFT'):queuecommand('Freeze')
    self:GetChild('Arrow'):queuecommand('Spawn')

    self:hidden(0)
    self:GetChild('Audio'):queuecommand('Play')
end

return continued