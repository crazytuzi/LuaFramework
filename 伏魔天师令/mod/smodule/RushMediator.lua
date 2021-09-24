local RushMediator = classGc(mediator, function(self, _view)
    self.name = "RushMediator"
    self.view = _view

    self:regSelf()
end)

RushMediator.protocolsList={
	_G.Msg.ACK_SHOP_REQUEST_OK,     -- 请求店铺面板成功
}

RushMediator.commandsList=nil

function RushMediator.ACK_SHOP_REQUEST_OK( self, _ackMsg )
    print("ACK_SHOP_REQUEST_OK",_ackMsg.count, _ackMsg.end_time)
    self : getView() : pushData(_ackMsg)
end

return RushMediator