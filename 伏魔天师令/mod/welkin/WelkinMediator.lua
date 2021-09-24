local welkinMediator = classGc(mediator, function(self, _view)
    self.name = "welkinMediator"
    self.view = _view

    self:regSelf()
end)

welkinMediator.protocolsList={
	_G.Msg.ACK_STRIDE_ENJOY_BACK,
	_G.Msg.ACK_STRIDE_RANK_HAIG,
	_G.Msg.ACK_TXDY_SUPER_REPLY_FIRST,     -- 请求三清天尊
    _G.Msg.ACK_SYSTEM_ERROR,               
}

welkinMediator.commandsList={
}

function welkinMediator.ACK_STRIDE_ENJOY_BACK( self, _ackMsg )
	self : getView() : Net_ENJOY_BACK( _ackMsg.type )
end

function welkinMediator.ACK_STRIDE_RANK_HAIG( self, _ackMsg )
	self : getView() : Net_RANK_HAIG( _ackMsg )
end

function welkinMediator.ACK_TXDY_SUPER_REPLY_FIRST( self, _ackMsg )
    if _ackMsg ~= nil and _ackMsg.name ~= nil and _ackMsg.name ~= 0  then
        self : getView() : Net_REPLY_FIRST( _ackMsg.name )
    end
end

function welkinMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
    if _ackMsg.error_code == 11542 then
        self : getView() : Net_CloseWidow()
    elseif _ackMsg.error_code == 27200 then
        -- self : getView() : 
    elseif _ackMsg.error_code == 27220 then
        self : getView() : noInTime()
    end
end

return welkinMediator