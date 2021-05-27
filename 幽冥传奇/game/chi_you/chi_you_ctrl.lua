require("scripts/game/chi_you/chi_you_data")
require("scripts/game/chi_you/chi_you_view")
ChiYouCtrl = ChiYouCtrl or BaseClass(BaseController)

function ChiYouCtrl:__init()
    if ChiYouCtrl.Instance then
        ErrorLog("[ChiYouCtrl]:Attempt to create singleton twice!")
    end
    ChiYouCtrl.Instance = self
    
    self.data = ChiYouData.New()
    self.view = ChiYouView.New(ViewDef.ChiyouView)
    self:RegisterAllProtocols()
end

function ChiYouCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    ChiYouCtrl.Instance = nil
end

function ChiYouCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCChiyouBossInfo, "OnChiyouBossInfo")

    GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanOnChiyouShi)
end

function ChiYouCtrl:RecvMainRoleInfo()
    ChiYouCtrl.SendChiYouReq(1)
end

function ChiYouCtrl.SendChiYouReq(index)
    local protocol = ProtocolPool.Instance:GetProtocol(CSChiyouInputReq)
    protocol.req_type = index
    protocol:EncodeAndSend()
end

function ChiYouCtrl:GetRemindNum(remind_name)
    if remind_name == RemindName.CanOnChiyouShi then
        return self.data:RemindChiyouNum()
    end
end

function ChiYouCtrl:OnChiyouBossInfo(protocol)
    self.data:GetChiyouBossNum(protocol)

    RemindManager.Instance:DoRemind(RemindName.CanOnChiyouShi)
end