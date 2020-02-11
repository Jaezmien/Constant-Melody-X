local wbrb = {}

function wbrb:Setup()
    -- We're automatically setting up, actually.
end

function wbrb:Dead()
    self:queuecommand('StartFail')
end

return wbrb