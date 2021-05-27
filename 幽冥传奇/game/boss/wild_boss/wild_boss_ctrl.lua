require("scripts/game/boss/wild_boss/wild_boss_data")

WildBossCtrl = WildBossCtrl or BaseClass(BaseController)

function WildBossCtrl:__init()
	if	WildBossCtrl.Instance then
		ErrorLog("[WildBossCtrl]:Attempt to create singleton twice!")
	end
    WildBossCtrl.Instance = self
    
	self.data = WildBossData.New()
	self:RegisterAllProtocols()
end

function WildBossCtrl:__delete()
    WildBossCtrl.Instance = nil
end

function WildBossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetWildBossOwnInfo, "OnGetWildBossOwnInfo")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function WildBossCtrl:RecvMainRoleInfo()
	self.data:SetListenerEvent()
end
function WildBossCtrl:OnGetWildBossOwnInfo(protocol)
	self.data:SetWildBossOwnInfo(protocol)
end

function WildBossCtrl.GetWildBossOwnInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetWildBossOwnInfo)
	protocol:EncodeAndSend()
end