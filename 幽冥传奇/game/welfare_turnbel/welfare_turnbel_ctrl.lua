require("scripts/game/welfare_turnbel/welfare_turnbel_data")
require("scripts/game/welfare_turnbel/welfare_turnbel_view")
WelfareTurnbelCtrl = WelfareTurnbelCtrl or BaseClass(BaseController)

function WelfareTurnbelCtrl:__init()
    if WelfareTurnbelCtrl.Instance then
        ErrorLog("[WelfareTurnbelCtrl]:Attempt to create singleton twice!")
    end
    WelfareTurnbelCtrl.Instance = self
    
    self.data = WelfareTurnbelData.New()
    self.view = WelfareTurnbelView.New(ViewDef.WelfareTurnbel)

    GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))
    GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, function ()
        self.data.start_time = Status.NowTime
        self.SendInfoReq()
    end)

    self:RegisterAllProtocols()
end

function WelfareTurnbelCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    WelfareTurnbelCtrl.Instance = nil
end

function WelfareTurnbelCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCWelfareTurnbelInfo, "OnWelfareTurnbelInfo")
    self:RegisterProtocol(SCWelfareTurnbelChangeInfo, "OnWelfareTurnbelChangeInfo")
    RemindManager.Instance:RegisterCheckRemind(function ()
        return self.data:GetRewardRemind()
    end, RemindName.WelfareTurnbel)
end

function WelfareTurnbelCtrl:PassDayCallBack()
end

function WelfareTurnbelCtrl:OnWelfareTurnbelInfo(protocol)
    self.data:SetData(protocol)
    RemindManager.Instance:DoRemindDelayTime(RemindName.WelfareTurnbel)
end

function WelfareTurnbelCtrl:OnWelfareTurnbelChangeInfo(protocol)
    self.data:SetData(protocol)
    RemindManager.Instance:DoRemindDelayTime(RemindName.WelfareTurnbel)
end

function WelfareTurnbelCtrl.SendInfoReq()
    WelfareTurnbelCtrl.SendWelfareTurnbelReq(4)
end

function WelfareTurnbelCtrl.SendDrawReq()
    WelfareTurnbelCtrl.SendWelfareTurnbelReq(1)
end

function WelfareTurnbelCtrl.SendGetBossAwardReq()
    WelfareTurnbelCtrl.SendWelfareTurnbelReq(2)
end

function WelfareTurnbelCtrl.SendGetOnlineAwardReq()
    WelfareTurnbelCtrl.SendWelfareTurnbelReq(3)
end

-- 1-抽奖  2-领取boss积分  3-领取在线积分  4-请求数据
function WelfareTurnbelCtrl.SendWelfareTurnbelReq(idx)
    local protocol = ProtocolPool.Instance:GetProtocol(CSWelfareTurnbelReq)
    protocol.idx = idx
    protocol:EncodeAndSend()
end