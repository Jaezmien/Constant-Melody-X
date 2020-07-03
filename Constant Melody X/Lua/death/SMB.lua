local smb = {}

function smb:Setup()
    self:hidden(1)
end

function smb:Prepare()

end

function smb:Dead()
    self:hidden(0)
    self:GetChild('Controller'):queuecommand('Start')
end

return smb