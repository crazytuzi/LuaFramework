local BagProxyMediator = classGc(mediator,function(self,_view)
    self.name="BagProxyMediator"
    self.view=_view
    self:regSelfLong()
end)

BagProxyMediator.protocolsList={
    _G.Msg.ACK_GOODS_REMOVE,  -- [2040]消失物品/装备 -- 物品/背包
    _G.Msg.ACK_GOODS_REVERSE,  -- [2020]请求返回数据 -- 物品/背包
    _G.Msg.ACK_GOODS_CHANGE,  -- [2050]物品/装备属性变化 -- 物品/背包
    _G.Msg.ACK_GOODS_SHOP_BACK,  -- [2310]商店数据返回 -- 物品/背包
}
BagProxyMediator.commandsList=nil

-- [2040]消失物品/装备 -- 物品/背包
function BagProxyMediator.ACK_GOODS_REMOVE( self, _ackMsg)
    if _ackMsg.type == _G.Const.CONST_GOODS_CONTAINER_BUY_BACK then
        self:getView():removeSellGoodsByIdx(_ackMsg.index)
    else
        if _ackMsg.type ~= 1 then
            return
        end

        self:getView():removeSomeGoodsByIdx(_ackMsg.index)
    end

end

-- [2020]请求返回数据 -- 物品/背包
function BagProxyMediator.ACK_GOODS_REVERSE( self, _ackMsg)

    print("BagProxyMediator.ACK_GOODS_REVERSE",_ackMsg.type,_ackMsg.maximum)
    if _ackMsg.type == _G.Const.CONST_GOODS_CONTAINER_BUY_BACK then
        self.view :setMaxCapacity( _ackMsg.maximum)
        self.view :setBagSellList( _ackMsg.goods_msg_no)
    else
        if _ackMsg.type ~= 1 then
            return
        end
        self.view :setMaxCapacity( _ackMsg.maximum)
        self.view :setBackpackList( _ackMsg.goods_msg_no)
    end
end

-- [2050]物品/装备属性变化 -- 物品/背包 
function BagProxyMediator.ACK_GOODS_CHANGE( self, _ackMsg)
    print("BagProxyMediator.ACK_GOODS_CHANGE",_ackMsg.type)

    if _ackMsg.type == _G.Const.CONST_GOODS_CONTAINER_BUY_BACK then
        self:getView():sellGoodsChuange(_ackMsg.goods_msg_no)
    else
        if _ackMsg.type ~= 1 then
            return
        end
        self:getView():someGoodsChuange(_ackMsg.goods_msg_no)
    end
end

-- [2310]商店数据返回 -- 物品/背包 
function BagProxyMediator.ACK_GOODS_SHOP_BACK( self, _ackMsg)
    local command = CProxyUpdataCommand()
    controller :sendCommand( command)
end

return BagProxyMediator
