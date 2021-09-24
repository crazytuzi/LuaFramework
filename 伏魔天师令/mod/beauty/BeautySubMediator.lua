local BeautySubMediator = classGc(mediator, function(self, _view)
    self.name = "BeautySubMediator"
    self.view = _view

    self:regSelf()
end)

BeautySubMediator.protocolsList={
    _G.Msg["ACK_MEIREN_GET_SUCCESS"],	     --面板回复
}

BeautySubMediator.commandsList=
{
}

function BeautySubMediator.processCommand(self, _command)
end

function BeautySubMediator.ACK_MEIREN_GET_SUCCESS(self, _ackMsg)
	self.view:updateState()
end

return BeautySubMediator