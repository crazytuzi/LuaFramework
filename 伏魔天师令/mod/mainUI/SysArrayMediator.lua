local SysArrayMediator = classGc( mediator, function( self, _view )
	self.name = "SysArrayMediator"
	self.view = _view

    self:regSelf()
end)

SysArrayMediator.protocolsList={
	_G.Msg["ACK_ROLE_SYS_CHANGE"],
}

SysArrayMediator.commandsList={
	CGuideNoticDel.TYPE,
    CGuideNoticShow.TYPE,
    CGuideNoticHide.TYPE
}
function SysArrayMediator.processCommand( self, _command )
    local commandType = _command :getType()
	if commandType == CGuideNoticDel.TYPE then
		self.view:removeGuideNode()
    elseif commandType == CGuideNoticShow.TYPE then
    	self.view:showGuideNode()
    elseif commandType == CGuideNoticHide.TYPE then
    	self.view:hideGuideNode()
    end
end

function SysArrayMediator.ACK_ROLE_SYS_CHANGE( self, _ackMsg )
	self : getView() : Net_SYS_CHANGE( _ackMsg )
end

return SysArrayMediator