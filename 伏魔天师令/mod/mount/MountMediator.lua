local MountMediator = classGc(mediator, function(self, _view)
    self.name = "MountMediator"
    self.view = _view

    self:regSelf()
end)

MountMediator.protocolsList={
    _G.Msg.ACK_MOUNT_RIDE_BACK,
    _G.Msg.ACK_MOUNT_MOUNT_REPLY,
    _G.Msg.ACK_MOUNT_CUL_RESULT,
    _G.Msg.ACK_MOUNT_ACTIVATE_BACK,
    _G.Msg.ACK_SYSTEM_ERROR,
}

MountMediator.commandsList={
	CProxyUpdataCommand.TYPE,
}

function MountMediator.processCommand(self, _command)
    if _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:bagGoodsUpdate()
    end
    return false
end

function MountMediator.ACK_MOUNT_RIDE_BACK( self, _ackMsg )
	self : getView() : Net_RIDE_BACK( _ackMsg.mount_id )
end

function MountMediator.ACK_MOUNT_MOUNT_REPLY( self, _ackMsg )
	self : getView() : Net_MOUNT_REPLY( _ackMsg )
    for _,v in pairs(_ackMsg.mount_data) do
        if  v.mid==_G.Cfg.mount[self.view.Table[self.view.currentTypeId]].mount_id then
            _G.GPropertyProxy:getMainPlay():setMountLv(v.grade)
        end
    end
end

function MountMediator.ACK_MOUNT_CUL_RESULT( self, _ackMsg )
	self : getView() : Net_CUL_RESULT( _ackMsg.result )
end

function MountMediator.ACK_MOUNT_ACTIVATE_BACK( self )
	self : getView() : Net_ACTIVATE_BACK( )
end

function MountMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

return MountMediator