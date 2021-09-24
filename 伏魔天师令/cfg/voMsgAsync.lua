local voMsgAsync = classGc(function(self, _delay, _tabProtocol)
    self.m_delay     = _delay
    self.m_protocols = _tabProtocol
end)

function voMsgAsync.getDelayTime(self)
    return self.m_delay
end

function voMsgAsync.getProtocolList(self)
    return self.m_protocols
end

return voMsgAsync