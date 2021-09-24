local DaemonMediator = classGc(mediator, function(self, _view)
    self.name = "DaemonMediator"
    self.view = _view

    self:regSelf()
end)

DaemonMediator.protocolsList={
    _G.Msg["ACK_INN_PARTNER_GET_TEN"],
}

DaemonMediator.commandsList={
}

function DaemonMediator.ACK_INN_PARTNER_GET_TEN(self, _ackMsg)
    self.view:showGet(_ackMsg.count,_ackMsg.data)
end

return DaemonMediator