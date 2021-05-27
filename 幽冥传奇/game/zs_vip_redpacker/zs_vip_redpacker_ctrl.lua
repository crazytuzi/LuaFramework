require("scripts/game/zs_vip_redpacker/zs_vip_redpacker_data")
require("scripts/game/zs_vip_redpacker/zs_vip_redpacker_view")
require("scripts/game/zs_vip_redpacker/zs_vip_redpacker_award_view")
ZsVipRedpackerCtrl = ZsVipRedpackerCtrl or BaseClass(BaseController)

function ZsVipRedpackerCtrl:__init()
    if ZsVipRedpackerCtrl.Instance then
        ErrorLog("[ZsVipRedpackerCtrl]:Attempt to create singleton twice!")
    end
    ZsVipRedpackerCtrl.Instance = self
    
    self.data = ZsVipRedpackerData.New()
    self.view = ZsVipRedpackerView.New(ViewDef.ZsVipRedpacker)
    self.alert_view = ZsVipRedpackerAwardView.New(ViewDef.ZsVipRedpackerAlertAwardView)
    self:RegisterAllProtocols()
end

function ZsVipRedpackerCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil

    self.alert_view:DeleteMe()
    self.alert_view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    ZsVipRedpackerCtrl.Instance = nil
    if self.pass_day then
        GlobalEventSystem:UnBind(self.pass_day)
         self.pass_day = nil 
    end
end

function ZsVipRedpackerCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCZsVipRedpackerInfo, "OnZsVipRedpackerInfo")
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ZsVipRedpacker)
    self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, function ()
        self.SendZsVipRedpackerReq()
    end)

    self.pass_day = GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, function ()
       ZsVipRedpackerCtrl.SendZsVipRedpackerReq()
    end)
end

function ZsVipRedpackerCtrl:OnZsVipRedpackerInfo(protocol)
    self.data:SetProData(protocol)
    RemindManager.Instance:DoRemind(RemindName.ZsVipRedpacker)
    if protocol.award_type ~= 0 then
        self.alert_view:SetData(protocol.award_type)
        self.alert_view:Open()
    end
end


function ZsVipRedpackerCtrl.SendZsVipRedpackerReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSZsVipRedpackerReq)
    protocol:EncodeAndSend()
end

function ZsVipRedpackerCtrl:GetRemindNum(remind_name)
    return self.data:GetRewardRemind()
end