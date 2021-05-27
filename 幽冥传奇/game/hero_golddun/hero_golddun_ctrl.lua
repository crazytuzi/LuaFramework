require("scripts/game/hero_golddun/hero_golddun_data")
require("scripts/game/hero_golddun/hero_golddun_view")

HeroGoldDunCtrl = HeroGoldDunCtrl or BaseClass(BaseController)

function HeroGoldDunCtrl:__init()
	if HeroGoldDunCtrl.Instance then
		ErrorLog("[HeroGoldDunCtrl] attempt to create singleton twice!")
		return
	end
	HeroGoldDunCtrl.Instance = self
	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function HeroGoldDunCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	HeroGoldDunCtrl.Instance = nil
end	

function HeroGoldDunCtrl:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	self:RegisterProtocol(SCHeroGoldDunInfo, "OnHeroGoldDunData")
end

function HeroGoldDunCtrl:OnHeroGoldDunData(protocol)
	self.data:setEquipGoldBossCfg(protocol)
end

function HeroGoldDunCtrl:OnRecvMainRoleInfo()
	self:HeroDunReq(1,0)
	-- self:SetHeroGoldReq()
end

function HeroGoldDunCtrl:CreateRelatedObjs()
	self.data = HeroGoldDunData.New()
	self.view = HeroGoldDunView.New(ViewName.HeroGoldDun)
end


function HeroGoldDunCtrl:HeroDunReq(temp_index,boss_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroGoldDunReq)
	protocol.temp_index = temp_index or 1
	protocol.boss_index = boss_index or 0
	protocol:EncodeAndSend()
end