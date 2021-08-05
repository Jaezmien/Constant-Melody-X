local smb = {}

function smb:Setup()
    self:hidden(1)
end

function smb:Prepare()
    self:GetChild('AFT Sprite'):SetTexture( self:GetChild('AFT'):GetTexture() )
    smb.Prepare = nil
end

function smb:Dead()
    self:GetChild('AFT'):queuecommand('Freeze')
    self:hidden(0)
    self:GetChild('Controller'):queuecommand('Start')
end

return smb