local gambleMediator = classGc(mediator,function(self, _view)
	-- here??
	self.name = "gambleMediator"
	self.view = _view
	self:regSelf() 
end)

gambleMediator.protocolsList={
	_G.Msg.ACK_FLSH_TIMES_REPLY,
	_G.Msg.ACK_FLSH_PAI_REPLY,
	_G.Msg.ACK_FLSH_FLSH_REWARD_POS,
	_G.Msg.ACK_SYSTEM_ERROR,
}

gambleMediator.commandsList = nil

function gambleMediator.ACK_FLSH_TIMES_REPLY( self, _ackMsg )
	print( "次数返回：ACK_FLSH_TIMES_REPLY")
	self : getView() : Times_Reply( _ackMsg )
end

function gambleMediator.ACK_FLSH_PAI_REPLY( self, _ackMsg )
	print(  "牌返回：ACK_FLSH_PAI_REPLY" )
	self : getView() : Pai_Reply( _ackMsg )
end

function gambleMediator.ACK_FLSH_FLSH_REWARD_POS( self, _ackMsg )
	print(  "奖励返回：ACK_FLSH_FLSH_REWARD_POS" )
	_G.Util:playAudioEffect("ui_wealth_money")
	self : getView() : Reward_Pos( _ackMsg )
end

function gambleMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	print( "变筛错误：ACK_SYSTEM_ERROR" )
	self : getView() : Error_get( _ackMsg )
end

return gambleMediator