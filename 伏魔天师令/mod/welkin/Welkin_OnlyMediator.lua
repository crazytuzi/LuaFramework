local Welkin_OnlyMediator = classGc(mediator, function(self, _view)
    self.name = "Welkin_OnlyMediator"
    self.view = _view

    self:regSelf()
end)

Welkin_OnlyMediator.protocolsList={
	_G.Msg.ACK_TXDY_SUPER_REPLY_GUESS,  	-- 55070
	_G.Msg.ACK_TXDY_SUPER_REPLY, 			-- 55015
	_G.Msg.ACK_TXDY_SUPER_TIME, 			-- 55060
	_G.Msg.ACK_TXDY_SUPER_REPLY, 			-- 55015
	_G.Msg.ACK_TXDY_SUPER_GUESS_TOTAL,		-- 55095
	_G.Msg.ACK_TXDY_SUPER_REPLY_MY_GAME,	-- 55015
	_G.Msg.ACK_TXDY_SUPER_GUESS_BET_REPLY,	-- 55085
	_G.Msg.ACK_TXDY_SUPER_REPLY_KING, 		-- 55050
}

Welkin_OnlyMediator.commandsList = nil

function Welkin_OnlyMediator.ACK_TXDY_SUPER_REPLY_GUESS( self, _ackMsg )
	self : getView() : Net_SUPER_REPLY_GUESS( _ackMsg )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_REPLY( self, _ackMsg )
	self : getView() : Net_SUPER_REPLY( _ackMsg )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_TIME( self, _ackMsg )
	self : getView() : Net_SUPER_TIME( _ackMsg )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_REPLY( self, _ackMsg )
	self : getView() : Net_SUPER_REPLY( _ackMsg )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_GUESS_TOTAL( self, _ackMsg )
	self : getView() : Net_GUESS_TOTAL( _ackMsg.pebble )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_REPLY_MY_GAME( self, _ackMsg )
	self : getView() : Net_REPLY_MY_GAME( _ackMsg )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_GUESS_BET_REPLY( self, _ackMsg )
	self : getView() : Net_GUESS_BET_REPLY( _ackMsg )
end

function Welkin_OnlyMediator.ACK_TXDY_SUPER_REPLY_KING( self, _ackMsg )
	self : getView() : Net_REPLY_KING( _ackMsg )
end

return Welkin_OnlyMediator