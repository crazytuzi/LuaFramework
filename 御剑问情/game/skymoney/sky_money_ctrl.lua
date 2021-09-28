require("game/skymoney/sky_money_data")
-- require("game/skymoney/sky_money_view")
require("game/skymoney/sky_money_fb_info_view")
require("game/skymoney/sky_money_reward_view")

SkyMoneyCtrl = SkyMoneyCtrl or BaseClass(BaseController)

function SkyMoneyCtrl:__init()
	if SkyMoneyCtrl.Instance ~= nil then
		print_error("[SkyMoneyCtrl] Attemp to create a singleton twice !")
		return
	end
	SkyMoneyCtrl.Instance = self

	self.data = SkyMoneyData.New()
	-- self.view = SkyMoneyView.New(ViewName.SkyMoneyView)
	self.info = SkyMoneyFBInfoView.New(ViewName.SkyMoneyFBInfoView)
	-- self.reward_view = SkyMoneyRewardView.New(ViewName.SkyMoneyRewardView)

	self:RegisterAllProtocols()
end

function SkyMoneyCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.info then
		self.info:DeleteMe()
		self.info = nil
	end
	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	SkyMoneyCtrl.Instance = nil
end

function SkyMoneyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTianJiangCaiBaoUserInfo, "GetSkyMoneyInfoReq")
end

function SkyMoneyCtrl:GetSkyMoneyInfoReq(protocol)
	self.data:SetSkyMoneyInfo(protocol)
	self.info:Flush()
	self.data:SetSkyMoneyItemList()
	-- if protocol.is_finish == 1 then
	-- 	self.reward_view:Open()
	-- end
end