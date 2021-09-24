local expeditMediator = classGc(mediator,function(self, _view)
	-- here??
	self.name = "expeditMediator"
	self.view = _view
	self:regSelf() 
end)

expeditMediator.protocolsList={
	_G.Msg.ACK_EXPEDIT_REPLY,
	_G.Msg.ACK_EXPEDIT_TIMES_SUCCESS,
	_G.Msg.ACK_EXPEDIT_PK,
	_G.Msg.ACK_EXPEDIT_FINISH_MSG,
	_G.Msg.ACK_SYSTEM_ERROR,
}

expeditMediator.commandsList = nil

function expeditMediator.ACK_EXPEDIT_REPLY( self, _ackMsg )
	self : getView() : Expedit_reply( _ackMsg )
end

function expeditMediator.ACK_EXPEDIT_TIMES_SUCCESS( self, _ackMsg )
	self : getView() : Times_success( _ackMsg )
end

function expeditMediator.ACK_EXPEDIT_PK( self, _ackMsg )
	self : getView() : Expedit_pk( _ackMsg )
end

function expeditMediator.ACK_EXPEDIT_FINISH_MSG( self, _ackMsg )
	self : getView() : Finish_Msg( _ackMsg )
end

function expeditMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

return expeditMediator