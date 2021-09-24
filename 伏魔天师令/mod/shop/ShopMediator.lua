ShopMediator = classGc( mediator, function( self, _view )
          self.name = "ShopMediator"
          self.view = _view
          self : regSelf()
end)

ShopMediator.protocolsList={
    _G.Msg.ACK_SHOP_REQUEST_OK,     -- 请求店铺面板成功
    -- _G.Msg.ACK_SHOP_REQUEST_OK_NEW, -- 请求店铺面板成功
    _G.Msg.ACK_SHOP_XXX1,           -- 店铺物品信息块
    _G.Msg.ACK_SHOP_INFO_NEW,       -- 店铺物品信息块
    _G.Msg.ACK_SHOP_BUY_SUCC,       -- 购买成功
    _G.Msg.ACK_LINGYAO_YUANHUN,     -- 妖灵数值
}

ShopMediator.commandsList={
    CPropertyCommand.TYPE,
}

function ShopMediator.processCommand( self, _command )
    if _command:getType()==CPropertyCommand.TYPE then
        if _command:getData()==CPropertyCommand.MONEY then
            self.view:updateMoneyTab()
        end
    end
end

function ShopMediator.ACK_SHOP_REQUEST_OK( self, _ackMsg )
    print("ACK_SHOP_REQUEST_OK", _ackMsg.type,_ackMsg.type_bb,_ackMsg.good_id,_ackMsg.count, _ackMsg.msg)
    self : getView() : pushData(_ackMsg)
end

function ShopMediator.ACK_SHOP_BUY_SUCC( self, _ackMsg)
    print("ACK_SHOP_BUY_SUCC",_ackMsg.idx,_ackMsg.state)
    self : getView() : SHOP_BUY_SUCC(_ackMsg)
end

function ShopMediator.ACK_LINGYAO_YUANHUN( self, _ackMsg)
    print("ACK_LINGYAO_YUANHUN",_ackMsg.yuanhun)
    self : getView() : updateYaoling(_ackMsg.yuanhun)
end

return ShopMediator