local BattleComparisonMediator = classGc(mediator,function(self, _view)
	self.name = "BattleComparisonMediator"
	self.view = _view
	self:regSelf() 
end)

BattleComparisonMediator.protocolsList={
	_G.Msg.ACK_ROLE_REPLY_COMPARE,   -- 1405
}

BattleComparisonMediator.commandsList = nil

function BattleComparisonMediator.ACK_ROLE_REPLY_COMPARE( self, _ackMsg )
	self : getView() : ACK_ROLE_REPLY_COMPARE( _ackMsg )
end

return BattleComparisonMediator