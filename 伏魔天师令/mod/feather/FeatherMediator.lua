local FeatherMediator = classGc(mediator, function(self, _view)
    self.name = "FeatherMediator"
    self.view = _view

    self:regSelf()
end)

FeatherMediator.protocolsList={
    _G.Msg.ACK_FEATHER_DRESS_REPLY,
    _G.Msg.ACK_FEATHER_REPLY,
    _G.Msg.ACK_FEATHER_XXX_DATA,
    _G.Msg.ACK_FEATHER_EXP_ADD,
    _G.Msg.ACK_SYSTEM_ERROR,
}

FeatherMediator.commandsList={
	CProxyUpdataCommand.TYPE,
}

function FeatherMediator.processCommand(self, _command)
    if _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:bagGoodsUpdate()
    end
    return false
end

function FeatherMediator.ACK_FEATHER_DRESS_REPLY( self, _ackMsg )
	self : getView() : Net_RIDE_BACK( _ackMsg.id )
end

function FeatherMediator.ACK_FEATHER_REPLY( self, _ackMsg )
	self : getView() : Net_FEATHER_REPLY( _ackMsg )
end

function FeatherMediator.ACK_FEATHER_XXX_DATA( self, _ackMsg )
	self : getView() : Net_ACTIVATE_BACK( _ackMsg )
end

function FeatherMediator.ACK_FEATHER_EXP_ADD( self, _ackMsg )
    self : getView() : Net_EXP_ADD( _ackMsg.exp )
end

function FeatherMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

return FeatherMediator