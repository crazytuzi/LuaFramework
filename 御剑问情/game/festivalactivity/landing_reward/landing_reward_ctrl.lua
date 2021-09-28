require("game/festivalactivity/landing_reward/landing_reward_data")

LandingRewardCtrl = LandingRewardCtrl or BaseClass(BaseController)
function LandingRewardCtrl:__init()
	if nil ~= LandingRewardCtrl.Instance then
		return
	end

	LandingRewardCtrl.Instance = self
	self.data = LandingRewardData.New()
	self:RegisterAllProtocols()
end

function LandingRewardCtrl:__delete()
	LandingRewardCtrl.Instance = nil

    if self.data then
    	self.data:DeleteMe()
    end
end

function LandingRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALoginActiveGiftInfo, "OnSCRALoginActiveGiftInfo")
end

function LandingRewardCtrl:OnSCRALoginActiveGiftInfo(protocol)
	self.data:SetLandingRewardInfo(protocol)
	RemindManager.Instance:Fire(RemindName.LoginRewardRemind)
end