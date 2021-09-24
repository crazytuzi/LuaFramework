local QiLingMediator = classGc(mediator,function(self, _view)
	self.name = "QiLingMediator"
	self.view = _view
	self:regSelf() 
end)

QiLingMediator.protocolsList={
	_G.Msg.ACK_WUQI_REPLY,
}

QiLingMediator.commandsList = nil

function QiLingMediator.ACK_WUQI_REPLY( self, _ackMsg )
	print("ACK_WUQI_REPLY-->",_ackMsg.lv,_ackMsg.time)
	self : getView() : updateMsg( _ackMsg.lv,_ackMsg.pro,_ackMsg.time )
end


return QiLingMediator

