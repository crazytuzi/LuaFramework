local LingeringMediator = classGc(mediator, function(self, _view)
	self.name = "LingeringMediator"
    self.view = _view

    self:regSelf()
end)

LingeringMediator.protocolsList={
    _G.Msg["ACK_MEIREN_LINGERING_CB"],	     --面板回复
    _G.Msg["ACK_MEIREN_GET_SUCCESS"],
    _G.Msg["ACK_MEIREN_LINGERING_SUC"],
    _G.Msg["ACK_MEIREN_FOLLOW_CB"],
    _G.Msg["ACK_MEIREN_HONEY_POWER"],
    _G.Msg["ACK_MEIREN_HONEY_SKID"],
}

LingeringMediator.commandsList=
{
}
function LingeringMediator.processCommand(self, _command)

end

function LingeringMediator.ACK_MEIREN_LINGERING_CB(self, _ackMsg)
    print( "-- ACK_MEIREN_LINGERING_CB")
    self.view : initView(_ackMsg)
end

function LingeringMediator.ACK_MEIREN_GET_SUCCESS(self, _ackMsg)
    print( "-- ACK_MEIREN_GET_SUCCESS")
    _G.Util:playAudioEffect("ui_task_get")
    self.view : updateState()
end

function LingeringMediator.ACK_MEIREN_LINGERING_SUC(self, _ackMsg)
    print( "-- ACK_MEIREN_LINGERING_SUC")
    self.view : updateData(_ackMsg)
end

function LingeringMediator.ACK_MEIREN_FOLLOW_CB(self, _ackMsg)
    print( "-- ACK_MEIREN_FOLLOW_CB")
    self.view : updateFollowState()
end

function LingeringMediator.ACK_MEIREN_HONEY_POWER(self, _ackMsg)
    print( "-- ACK_MEIREN_HONEY_POWER")
    self.view : updatePower(_ackMsg.power)
end

function LingeringMediator.ACK_MEIREN_HONEY_SKID(self, _ackMsg)
    print( "-- ACK_MEIREN_HONEY_SKID")
    self.view : updateAttr(_ackMsg)
end
return LingeringMediator