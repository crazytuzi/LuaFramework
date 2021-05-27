require("scripts/game/vip_boss/vip_boss_data")
require("scripts/game/vip_boss/vip_boss_view")

VipBossCtrl = VipBossCtrl or BaseClass(BaseController)

function VipBossCtrl:__init()
	if VipBossCtrl.Instance then
		ErrorLog("[VipBossCtrl]:Attempt to create singleton twice!")
	end
	VipBossCtrl.Instance = self
	self.view = VipBossView.New(ViewName.VipBoss)
	self.data = VipBossData.New()
	self:RegisterAllProtocols()
end

function VipBossCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	VipBossCtrl.Instance = nil
end

function VipBossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSVipBossFubenInfo,"OnVipBossFubenInfo")
end

function VipBossCtrl:SendOnVipBossFubenReq(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOnVipBossFubenReq)
	protocol.vip_lev = level
	protocol:EncodeAndSend() 
end

function VipBossCtrl:OnVipBossFubenInfo(protocol)
	self.data:SetVipBossFuben(protocol)
	self.view:Flush()
	RemindManager.Instance:DoRemind(RemindName.BossVip)
end