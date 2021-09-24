CouponShopMediator = classGc( mediator, function( self, _view )
          self.name = "CouponShopMediator"
          self.view = _view
          self : regSelf()
end)

CouponShopMediator.protocolsList={
    _G.Msg["ACK_SHOP_REQUEST_OK"],       --面板回复
    _G.Msg["ACK_SHOP_BUY_SUCC"],       -- 购买成功
}

CouponShopMediator.commandsList=nil
function CouponShopMediator.processCommand(self, _command)
end

function CouponShopMediator.ACK_SHOP_REQUEST_OK(self, _ackMsg)
    print("ACK_SHOP_REQUEST_OK", _ackMsg.type,_ackMsg.type_bb,_ackMsg.good_id,_ackMsg.count, _ackMsg.msg)
    self : getView() : pushData(_ackMsg)
end

function CouponShopMediator.ACK_SHOP_BUY_SUCC( self, _ackMsg)
    print("ACK_SHOP_BUY_SUCC",_ackMsg.idx,_ackMsg.state)
    self : getView() : SHOP_BUY_SUCC(_ackMsg)
end

return CouponShopMediator