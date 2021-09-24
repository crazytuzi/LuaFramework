local KeJuMediator = classGc(mediator,function(self, _view)
	self.name = "KeJuMediator"
	self.view = _view
	self:regSelf() 
end)

KeJuMediator.protocolsList={
	_G.Msg.ACK_KEJU_ASK_REPLY,
	_G.Msg.ACK_KEJU_START_REPLY,
	_G.Msg.ACK_KEJU_ANSWER_REPLY,
	_G.Msg.ACK_KEJU_OUT_WRONG_REPLY,
	_G.Msg.ACK_KEJU_BRIBE_REPLY,
}

KeJuMediator.commandsList = nil

function KeJuMediator.ACK_KEJU_ASK_REPLY( self, _ackMsg )
	if _ackMsg.type == 1 then 
		self : getView() : Ask_reply_1( _ackMsg )
	elseif _ackMsg.type == 2 then
		self : getView() : Ask_reply_2( _ackMsg )
	end
end

function KeJuMediator.ACK_KEJU_START_REPLY( self, _ackMsg )
	self : getView() : Start_Reply( _ackMsg )
end

function KeJuMediator.ACK_KEJU_ANSWER_REPLY( self, _ackMsg )
	self : getView() : Answer_Reply( _ackMsg )
end

function KeJuMediator.ACK_KEJU_OUT_WRONG_REPLY( self, _ackMsg )
	self : getView() : Wrong_Reply( _ackMsg )
end

function KeJuMediator.ACK_KEJU_BRIBE_REPLY( self, _ackMsg )
	self : getView() : Bribe_Reply( _ackMsg )
end

return KeJuMediator

