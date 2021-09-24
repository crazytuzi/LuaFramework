zhuRechargeMediator = classGc( mediator, function( self, _view )
          self.name = "zhuRechargeMediator"
          self.view = _view
          self : regSelf()
end)

zhuRechargeMediator.protocolsList={
    _G.Msg.ACK_ROLE_LV_MY,    -- 请求VIP(自己) 
    _G.Msg.ACK_REWARD_LOGS_PAY,    -- 已经充值过的金额
    _G.Msg.ACK_REWARD_VIP_LV_RMB,   -- 更新数值
    _G.Msg.ACK_REWARD_VIP_MSG_CB,   --VIP奖励信息
    _G.Msg.ACK_REWARD_VIP_REPLY,   --领取VIP奖励成功
    _G.Msg.ACK_WEAGOD_RMB_REPLY,    --招财貔貅
    _G.Msg.ACK_WEAGOD_RMB_SUCCESS,  --成功购买招财貔貅
    _G.Msg.ACK_WEAGOD_RMB_GIFT_BACK, --貔貅礼包领取返回
    _G.Msg.ACK_WEAGOD_RMB_GUI_CONTROL, --貔貅界面控制
}

zhuRechargeMediator.commandsList={
	CFunctionOpenCommand.TYPE,
    CloseWindowCommand.TYPE,
    RechargeViewCommand.TYPE,
}

function zhuRechargeMediator.processCommand(self, _command)
    if _command:getType()==CFunctionOpenCommand.TYPE then
        if _command:getData()==CFunctionOpenCommand.TIMES_UPDATE then
            self.view:chuangIconNum(_command.sysId,_command.number)
        end
    elseif _command:getType() == RechargeViewCommand.TYPE then
        self : getView() : onRecharge()
    end
    local commamdData=_command:getData()
    if commamdData==_G.Const.CONST_FUNC_OPEN_RECHARGE then
        self : getView() : onCloseCallBack()
    end
    return false
end

function zhuRechargeMediator.ACK_ROLE_LV_MY( self, _ackMsg )
    print("zhuRechargeMediator.ACK_ROLE_LV_MY", _ackMsg.lv)
    self : getView() : pushData(_ackMsg.lv,_ackMsg.vip_up)
end

function zhuRechargeMediator.ACK_REWARD_LOGS_PAY( self, _ackMsg )
    print("zhuRechargeMediator.ACK_REWARD_LOGS_PAY-->",_ackMsg.count )
    self : getView() : rechargeData( _ackMsg.count, _ackMsg.msg_xxx )
end

function zhuRechargeMediator.ACK_REWARD_VIP_MSG_CB( self, _ackMsg )
    self : getView() : PrivilegeData(_ackMsg.msg)
end

function zhuRechargeMediator.ACK_REWARD_VIP_REPLY( self )
    self : getView() : SuccessVip()
end

function zhuRechargeMediator.ACK_WEAGOD_RMB_REPLY( self, _ackMsg )
    print("zhuRechargeMediator.ACK_WEAGOD_RMB_REPLY", _ackMsg)
    self : getView() : ZCPXpushdata(_ackMsg)
end
function zhuRechargeMediator.ACK_WEAGOD_RMB_SUCCESS( self, _ackMsg )
    print("zhuRechargeMediator.ACK_WEAGOD_RMB_SUCCESS")
    self : getView() : SuccessBuy()
end
function zhuRechargeMediator.ACK_WEAGOD_RMB_GIFT_BACK( self, _ackMsg )
    print("zhuRechargeMediator.ACK_WEAGOD_RMB_GIFT_BACK", _ackMsg.id)
    self : getView() : SuccessReward(_ackMsg.id)
end

function zhuRechargeMediator.ACK_WEAGOD_RMB_GUI_CONTROL( self, _ackMsg )
    print("zhuRechargeMediator.ACK_WEAGOD_RMB_GUI_CONTROL", _ackMsg.flag)
    self : getView() : ZCViewFlag(_ackMsg.flag)
end

return zhuRechargeMediator