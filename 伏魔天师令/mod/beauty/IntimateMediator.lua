local IntimateMediator = classGc(mediator, function(self, _view)
	self.name = "IntimateMediator"
    self.view = _view

    self:regSelf()
end)

IntimateMediator.protocolsList={
    _G.Msg["ACK_MEIREN_HONNEY_LIST"],	     --面板回复
    _G.Msg["ACK_MEIREN_HONEY_CB"],
    _G.Msg["ACK_MEIREN_ONE_HONEY_CB"],
}

IntimateMediator.commandsList=
{
}
function IntimateMediator.processCommand(self, _command)

end

function IntimateMediator.ACK_MEIREN_HONNEY_LIST(self, _ackMsg)
    self.view:initView(_ackMsg)
end

function IntimateMediator.ACK_MEIREN_HONEY_CB(self, _ackMsg)
    self.view:updateMsg(_ackMsg)
end

function IntimateMediator.ACK_MEIREN_ONE_HONEY_CB(self, _ackMsg)
    self.view:updateTips(_ackMsg)
end

return IntimateMediator