local SettingViewMediator = classGc(mediator,function(self, _view)
	-- here??
	self.name = "SettingViewMediator"
	self.view = _view
	self:regSelf() 
end)

SettingViewMediator.protocolsList={
    _G.Msg.ACK_SYS_SET_WX_BACK,    
    _G.Msg.ACK_SYS_SET_WX_PLY,
    _G.Msg.ACK_SYS_SET_TYPE_STATE,
}

SettingViewMediator.commandsList = nil

function SettingViewMediator.ACK_SYS_SET_WX_BACK( self, _askMsg )
	print("-----ACK_SYS_SET_WX_BACK = ",_askMsg.state)
	self : getView() : GoodsOK( _askMsg )
end

function SettingViewMediator.ACK_SYS_SET_WX_PLY( self )
	print( "－－－－－－－接受情况－－－－－－－－" )
	self : getView() : GoodsTakeOK()
end

function SettingViewMediator.ACK_SYS_SET_TYPE_STATE( self, _ackMsg )
	self : getView() : Type_state()
end

return SettingViewMediator

