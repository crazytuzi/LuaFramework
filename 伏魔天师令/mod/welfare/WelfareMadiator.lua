WelfareMadiator = classGc( mediator, function( self, _view )
          self.name = "WelfareMadiator"
          self.view = _view
          self : regSelf()
end)

WelfareMadiator.protocolsList={
    _G.Msg.ACK_REWARD_DAILY_REP,        -- 每日领奖返回
    _G.Msg.ACK_ROLE_BUFF_REPLY,           -- 领取体力成功
    _G.Msg.ACK_REWARD_ONLINE_REP,       -- 在线奖励返回
    _G.Msg.ACK_CARD_SUCCEED,            -- 兑换奖励卡
    _G.Msg.ACK_REWARD_ICON_TIME,        -- 角标返回
}

WelfareMadiator.commandsList={
    CGuideNoticDel.TYPE
}

function WelfareMadiator.processCommand(self, _command)
    if _command:getType()==CGuideNoticDel.TYPE then
        self.view:guideDelete(_command.guideId)
    end
end

function WelfareMadiator.ACK_REWARD_DAILY_REP( self, _ackMsg )
    print("ACK_REWARD_DAILY_REP", _ackMsg.count)
    self : getView() : dailyData(_ackMsg)
end

-- function WelfareMadiator.ACK_ROLE_BUFF_REPLY( self, _ackMsg )
--     print("ACK_ROLE_BUFF_REPLY-->", _ackMsg.count)
--     self : getView() : lvData(_ackMsg)
-- end

function WelfareMadiator.ACK_REWARD_ONLINE_REP( self, _ackMsg )
    print("ACK_REWARD_ONLINE_REP-->",_ackMsg.timenext )
    self : getView() : onlineData( _ackMsg )
end

function WelfareMadiator.ACK_ROLE_BUFF_REPLY( self )
    print("ACK_ROLE_BUFF_REPLY-->" )
    self : getView() : Success()
end

function WelfareMadiator.ACK_CARD_SUCCEED( self, _ackMsg )
    print("ACK_CARD_SUCCEED-->",_ackMsg.goods_count )
    self : getView() : cardData( _ackMsg )
end

function WelfareMadiator.ACK_REWARD_ICON_TIME( self, _ackMsg )
    print("ACK_REWARD_ICON_TIME-->",_ackMsg.num1,_ackMsg.num2 )
    self : getView() : numData( _ackMsg )
end

return WelfareMadiator