local Welkin_FirstMediator = classGc(mediator,function(self, _view)
	self.name = "Welkin_FirstMediator"
	self.view = _view
	self:regSelf() 
end)

Welkin_FirstMediator.protocolsList={
	_G.Msg.ACK_STRIDE_RANK_DATA,
	_G.Msg.ACK_STRIDE_AWARD_OK,
	_G.Msg.ACK_STRIDE_BUY_CG,
	_G.Msg.ACK_STRIDE_BUY_OK,
	_G.Msg.ACK_STRIDE_CAN_AWARD,
	_G.Msg.ACK_STRIDE_CAN_AWARD_SEC,
	_G.Msg.ACK_STRIDE_RANK_HAIG,
	_G.Msg.ACK_SYSTEM_ERROR,
	_G.Msg.ACK_STRIDE_YJ_GROUP,
	_G.Msg.ACK_STRIDE_POWER_BACK,
}

Welkin_FirstMediator.commandsList = nil

function Welkin_FirstMediator.ACK_STRIDE_RANK_DATA( self, _ackMsg )
	local msg = _ackMsg
	if msg.type == _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_5 or  
	   msg.type == _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_6 then
		self : getView() : Net_RANK_DATA( _ackMsg )
	end

end

function Welkin_FirstMediator.ACK_STRIDE_AWARD_OK( self, _ackMsg )
	self : getView() : Net_AWARD_OK( _ackMsg.cenci )
end

function Welkin_FirstMediator.ACK_STRIDE_BUY_CG( self )
	self : getView() : Net_BUY_CG()
end

function Welkin_FirstMediator.ACK_STRIDE_BUY_OK( self, _ackMsg )
	self : getView() : Net_BUY_OK( _ackMsg )
end

function Welkin_FirstMediator.ACK_STRIDE_CAN_AWARD( self, _ackMsg )
	self : getView() : Net_CAN_AWARD( _ackMsg )
end

function Welkin_FirstMediator.ACK_STRIDE_CAN_AWARD_SEC( self, _ackMsg )
	self : getView() : Net_CAN_AWARD_SEC( _ackMsg )
end

function Welkin_FirstMediator.ACK_STRIDE_RANK_HAIG( self, _ackMsg )
	self : getView() : Net_RANK_HAIG( _ackMsg )
end

function Welkin_FirstMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

function Welkin_FirstMediator.ACK_STRIDE_YJ_GROUP( self, _ackMsg )
	self : getView() : Net_YJ_GROUP( _ackMsg )
end

function Welkin_FirstMediator.ACK_STRIDE_POWER_BACK( self, _ackMsg )
	self : getView() : Net_POWER_BACK( _ackMsg.power )
end

return Welkin_FirstMediator