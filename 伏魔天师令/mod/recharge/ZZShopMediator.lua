ZZShopMediator = classGc( mediator, function( self, _view )
          self.name = "ZZShopMediator"
          self.view = _view
          self : regSelf()
end)

ZZShopMediator.protocolsList={
    _G.Msg.ACK_SHOP_REQUEST_OK,     -- 请求店铺面板成功
    _G.Msg.ACK_SHOP_REQUEST_OK_NEW, -- 请求店铺面板成功
    _G.Msg.ACK_SHOP_BUY_SUCC,       -- 购买成功
}

ZZShopMediator.commandsList=nil

function ZZShopMediator.ACK_SHOP_REQUEST_OK( self, _ackMsg )
    print("ACK_SHOP_REQUEST_OK", _ackMsg.type,_ackMsg.type_bb,_ackMsg.count, _ackMsg.end_time)
    self : getView() : pushData(_ackMsg)
end

function ZZShopMediator.ACK_SHOP_REQUEST_OK_NEW( self, _ackMsg )
    print("ACK_SHOP_REQUEST_OK_NEW", _ackMsg.type,_ackMsg.type_bb,_ackMsg.count, _ackMsg.end_time,_ackMsg.goods_msg_no)
	self : getView() : pushData(_ackMsg)
end

function ZZShopMediator.ACK_SHOP_BUY_SUCC( self, _ackMsg)
    print("ACK_SHOP_BUY_SUCC")
    self : getView() : SHOP_BUY_SUCC()
end

return ZZShopMediator