RebateMediator = classGc( mediator, function( self, _view )
          self.name = "RebateMediator"
          self.view = _view
          self : regSelf()
end)

RebateMediator.protocolsList={
    _G.Msg.ACK_ART_CONSUME_REPLY,    -- 开放的活动
    _G.Msg.ACK_ART_SUCCESS_GET,    -- 充值领取返回
    _G.Msg.ACK_ART_RANK_TOP,   -- 更新数值
    _G.Msg.ACK_ART_ICON_CB,   -- 角标返回
    _G.Msg.ACK_ART_FZTX_CB,     -- 福泽万民数据
    _G.Msg.ACK_ART_GET_FZTX_CB, -- 福泽万民领取返回
    _G.Msg.ACK_SHOP_REQUEST_OK, -- 请求店铺面板成功
    _G.Msg.ACK_SHOP_REQUEST_OK_NEW, -- 请求店铺面板成功
    _G.Msg.ACK_SHOP_BUY_SUCC,       -- 兑换成功
    -- _G.Msg.ACK_ART_ZHUANPAN_UNLIMIT_CB, -- 放回转盘数据
    _G.Msg.ACK_ART_ZHUANPAN_UNLOTTERY_CB, -- 抽取一次
    _G.Msg.ACK_ART_ZHUANPAN_TEN_UNLIMIT,  -- 抽奖十次
    _G.Msg.ACK_ART_ZHUANPAN_LIMIT_CB,  -- 不放回转盘数据
    _G.Msg.ACK_ART_ZHUANPAN_LOTTERY_CB,  -- 不放回转盘抽奖
    _G.Msg.ACK_ART_REWARD_OK,  -- 封测领取奖励成功
}   

RebateMediator.commandsList={
    CloseWindowCommand.TYPE,
}

function RebateMediator.processCommand( self, _command )
    local commamdData=_command:getData()
    if commamdData==_G.Const.CONST_FUNC_OPEN_REBATE then
        self : getView() : CloseWindow()
    end
end

function RebateMediator.ACK_ART_CONSUME_REPLY( self, _ackMsg )
    print("ACK_ART_CONSUME_REPLY", _ackMsg.count,_ackMsg.msg)
    self : getView() : pushData(_ackMsg.count,_ackMsg.msg)
end

function RebateMediator.ACK_ART_FZTX_CB( self, _ackMsg )
    print("ACK_ART_FZTX_CB", _ackMsg.id,_ackMsg.count,_ackMsg.msg)
    self : getView() : ART_FZTX_CB(_ackMsg)
end

function RebateMediator.ACK_ART_SUCCESS_GET( self, _ackMsg )
    print("RebateMediator.ACK_ART_SUCCESS_GET-->",_ackMsg.count )
    self : getView() : fullData( _ackMsg.id, _ackMsg.id_sub,_ackMsg.state,_ackMsg.num )
end

function RebateMediator.ACK_ART_GET_FZTX_CB( self, _ackMsg )
    print("RebateMediator.ACK_ART_GET_FZTX_CB-->",_ackMsg.id,_ackMsg.idx,_ackMsg.times )
    self : getView() : ART_GET_FZTX_CB( _ackMsg )
end

function RebateMediator.ACK_ART_RANK_TOP( self, _ackMsg )
    print("RebateMediator.ACK_ART_RANK_TOP-->" )
    self : getView() : rankData(_ackMsg.msg)
end

function RebateMediator.ACK_ART_ICON_CB( self, _ackMsg )
    print("RebateMediator.ACK_ART_ICON_CB-->",_ackMsg.count )
    self : getView() : iconData(_ackMsg.count,_ackMsg.msg)
end

function RebateMediator.ACK_SHOP_REQUEST_OK_NEW( self, _ackMsg )
    print("ACK_SHOP_REQUEST_OK_NEW", _ackMsg.type,_ackMsg.type_bb,_ackMsg.count, _ackMsg.end_time,_ackMsg.goods_msg_no)
    self : getView() : GrabData(_ackMsg)
end

function RebateMediator.ACK_SHOP_BUY_SUCC( self, _ackMsg)
    print("ACK_SHOP_BUY_SUCC",_ackMsg.type)
    if _ackMsg.type==_G.Const.CONST_MALL_TYPE_ID_INTEGRAL then
        self : getView() : GrabShop()
    elseif _ackMsg.type==90 then
        self : getView() : TimeShopBuyReturn()
    end
end

function RebateMediator.ACK_SHOP_REQUEST_OK( self, _ackMsg )
    print("ACK_SHOP_REQUEST_OK", _ackMsg.type,_ackMsg.type_bb,_ackMsg.count, _ackMsg.end_time,_ackMsg.goods_msg_no)
    if _ackMsg.type~=90 then return end
    self : getView() : TimeShopData(_ackMsg)
end

-- function RebateMediator.ACK_ART_ZHUANPAN_UNLIMIT_CB( self, _ackMsg )
--     print("RebateMediator.ACK_ART_ZHUANPAN_UNLIMIT_CB-->" )
--     self : getView() : FHZPData(_ackMsg)
-- end

function RebateMediator.ACK_ART_ZHUANPAN_UNLOTTERY_CB( self, _ackMsg )
    print("RebateMediator.ACK_ART_ZHUANPAN_UNLOTTERY_CB-->" )
    self : getView() : ZPRewardData(_ackMsg)
end

function RebateMediator.ACK_ART_ZHUANPAN_TEN_UNLIMIT( self, _ackMsg )
    print("RebateMediator.ACK_ART_ZHUANPAN_TEN_UNLIMIT-->" )
    self : getView() : FHZPTenData(_ackMsg)
end

function RebateMediator.ACK_ART_ZHUANPAN_LIMIT_CB( self, _ackMsg )
    print("RebateMediator.ACK_ART_ZHUANPAN_LIMIT_CB-->" )
    self : getView() : NFZPData(_ackMsg)
end
function RebateMediator.ACK_ART_ZHUANPAN_LOTTERY_CB( self, _ackMsg )
    print("RebateMediator.ACK_ART_ZHUANPAN_LOTTERY_CB-->" )
    self : getView() : ZPRewardData(_ackMsg)
end

function RebateMediator.ACK_ART_REWARD_OK( self, _ackMsg )
    print("RebateMediator.ACK_ART_REWARD_OK-->",_ackMsg.type )
    self : getView() : FCRewardReturn(_ackMsg.type)
end

return RebateMediator