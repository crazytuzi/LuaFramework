require("scripts/game/boss/secret_boss/secret_boss_data")

SecretBossCtrl = SecretBossCtrl or BaseClass(BaseController)

function SecretBossCtrl:__init()
	if	SecretBossCtrl.Instance then
		ErrorLog("[SecretBossCtrl]:Attempt to create singleton twice!")
	end
    SecretBossCtrl.Instance = self
    
	self.data = SecretBossData.New()
	self:RegisterAllProtocols()
end

function SecretBossCtrl:__delete()
    SecretBossCtrl.Instance = nil
end

function SecretBossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetSecretBossOwnInfo, "OnGetSecretBossOwnInfo")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function SecretBossCtrl:RecvMainRoleInfo()
	self.data:SetListenerEvent()
	SecretBossCtrl.Instance.GetSecretBossReq(1)
end

function SecretBossCtrl:OnGetSecretBossOwnInfo(protocol)
	self.data:GetSecretInfo(protocol)
end

function SecretBossCtrl.GetSecretBossReq(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSecretBossReq)
	protocol.type = type
	protocol:EncodeAndSend()
end