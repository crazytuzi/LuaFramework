local DemonsMediator = classGc(mediator,function(self, _view)
	self.name = "DemonsMediator"
	self.view = _view
	self:regSelf() 
end)

DemonsMediator.protocolsList={
	_G.Msg.ACK_THOUSAND_REPLY, 
	_G.Msg.ACK_THOUSAND_REPLY_BUY,
	_G.Msg.ACK_THOUSAND_BUY_SUCCESS,
	_G.Msg.ACK_THOUSAND_WAR_REPLY,
	_G.Msg.ACK_THOUSAND_REPLY_RANK,
	_G.Msg.ACK_COPY_THROUGH,
}

DemonsMediator.commandsList = nil

function DemonsMediator.ACK_THOUSAND_REPLY( self, _ackMsg )
	self : getView() : Net_THOUSAND_REPLY( _ackMsg )
end

function DemonsMediator.ACK_THOUSAND_REPLY_BUY( self, _ackMsg )
	self : getView() : Net_REPLY_BUY( _ackMsg )
end

function DemonsMediator.ACK_THOUSAND_BUY_SUCCESS( self, _ackMsg )
	self : getView() : Net_BUY_SUCCESS( _ackMsg.times )
end

function DemonsMediator.ACK_THOUSAND_WAR_REPLY( self, _ackMsg )
	self : getView() : Net_WAR_REPLY( _ackMsg )
end

function DemonsMediator.ACK_THOUSAND_REPLY_RANK( self, _ackMsg )
	self : getView() : Net_REPLY_RANK( _ackMsg )
end

function DemonsMediator.ACK_COPY_THROUGH( self, _ackMsg )
	self : getView() : Net_COPY_THROUGH( _ackMsg.key )
end

return DemonsMediator