require("scripts/game/boss/new_boss/new_boss_data")

NewBossCtrl = NewBossCtrl or BaseClass(BaseController)

function NewBossCtrl:__init()
	if	NewBossCtrl.Instance then
		ErrorLog("[NewBossCtrl]:Attempt to create singleton twice!")
	end
    NewBossCtrl.Instance = self
    
	self.data = NewBossData.New()
	self:RegisterAllProtocols()
end

function NewBossCtrl:__delete()
    NewBossCtrl.Instance = nil
end

function NewBossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBossRecord, "OnBossRecord")
	-- self:RegisterProtocol(SCBossTypeData, "OnBossTypeData")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function NewBossCtrl:RecvMainRoleInfo()
	-- self.data:SetListenerEvent()
end

function NewBossCtrl:SendBossKillInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossDropReq)
	protocol:EncodeAndSend()
end

-- function NewBossCtrl:SendBossTypeReq(type)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSBossTypeReq)
-- 	protocol.boss_type = type
-- 	protocol:EncodeAndSend()
-- end

function NewBossCtrl:OnBossRecord(protocol)
	self.data:GetBossInfo(protocol.drop_list)
end

-- function NewBossCtrl:OnBossTypeData(protocol)
-- 	self.data:GetBossTypeData(protocol)
-- end