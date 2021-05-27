require("scripts/game/hero_goldbing/hero_goldbing_data")
require("scripts/game/hero_goldbing/hero_goldbing_view")

HeroGoldBingCtrl = HeroGoldBingCtrl or BaseClass(BaseController)

function HeroGoldBingCtrl:__init()
	if HeroGoldBingCtrl.Instance then
		ErrorLog("[HeroGoldBingCtrl] attempt to create singleton twice!")
		return
	end
	HeroGoldBingCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function HeroGoldBingCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	HeroGoldBingCtrl.Instance = nil
end	

function HeroGoldBingCtrl:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	self:RegisterProtocol(SCHeroGoldBingInfo, "OnHeroGoldBingData")
end

function HeroGoldBingCtrl:CreateRelatedObjs()
	self.data = HeroGoldBingData.New()
	self.view = HeroGoldBingView.New(ViewName.HeroGoldBing)
end

function HeroGoldBingCtrl:OnRecvMainRoleInfo()
	self:ReqMoneyReq(0)
end

function HeroGoldBingCtrl:OnHeroGoldBingData(protocol)
	self.data:setChargeInfo(protocol.charge_money,protocol.oper_cnt)
	GlobalEventSystem:Fire(HeroGoldEvent.HeroGoldBing,protocol)
	self.view:Flush()
end

function HeroGoldBingCtrl:ReqMoneyReq(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroGoldBingReq)
	protocol.req_type = req_type or 0
	protocol:EncodeAndSend()
end