local Welkin_BattleMediator = classGc(mediator, function(self, _view)
    self.name = "Welkin_BattleMediator"
    self.view = _view

    self:regSelf()
end)

Welkin_BattleMediator.protocolsList={
	_G.Msg.ACK_STRIDE_RANK_DATA, 	-- 43550
	_G.Msg.ACK_STRIDE_BUY_OK, 		-- 43660
	_G.Msg.ACK_STRIDE_RANK_HAIG, 	-- 43541
	_G.Msg.ACK_SYSTEM_ERROR,
}

Welkin_BattleMediator.commandsList={
}

function Welkin_BattleMediator.ACK_STRIDE_RANK_DATA( self, _ackMsg )
	local msg = _ackMsg
	if msg.type == _G.Const.CONST_OVER_SERVER_STRIDE_TYPE_4 then
		self : getView() : Net_RANK_DATA( _ackMsg )
	end
end

function Welkin_BattleMediator.ACK_STRIDE_BUY_OK( self, _ackMsg )
	self : getView() : Net_BUY_OK( _ackMsg )
end

function Welkin_BattleMediator.ACK_STRIDE_RANK_HAIG( self, _ackMsg )
	self : getView() : Net_RANK_HAIG( _ackMsg )
end

function Welkin_BattleMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

return Welkin_BattleMediator