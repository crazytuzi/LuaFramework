require("game/activity_online/activity_online_login_reward/activity_panel_login_reward_data")
ActivityPanelLoginRewardCtrl = ActivityPanelLoginRewardCtrl or BaseClass(BaseController)

function ActivityPanelLoginRewardCtrl:__init()
	if nil ~= ActivityPanelLoginRewardCtrl.Instance then
		return
	end

	ActivityPanelLoginRewardCtrl.Instance = self
	self.data = ActivityPanelLoginRewardData.New()
	self:RegisterAllProtocols()
end

function ActivityPanelLoginRewardCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
	end
	self.data = nil
	KuanHuanActivityPanelDanBiChongZhiCtrl.Instance = nil
end

function ActivityPanelLoginRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALoginGiftInfo, "OnSCRALoginGiftInfo_0")
	self:RegisterProtocol(SCRALoginGiftInfo_1, "OnSCRALoginGiftInfo_1")
	self:RegisterProtocol(SCRALoginGiftInfo_2, "OnSCRALoginGiftInfo_2")
end

function ActivityPanelLoginRewardCtrl:OnSCRALoginGiftInfo_0(protocol)
	self.data:SetLoginRewardInfo_0(protocol)
	ActivityOnLineCtrl.Instance:FlushView("login_reward")
	RemindManager.Instance:Fire(RemindName.RewardGift0)
end

function ActivityPanelLoginRewardCtrl:OnSCRALoginGiftInfo_1(protocol)
	self.data:SetLoginRewardInfo_1(protocol)
	ActivityOnLineCtrl.Instance:FlushView("login_reward")
	RemindManager.Instance:Fire(RemindName.RewardGift1)
end

function ActivityPanelLoginRewardCtrl:OnSCRALoginGiftInfo_2(protocol)
	self.data:SetLoginRewardInfo_2(protocol)
	ActivityOnLineCtrl.Instance:FlushView("login_reward")
	RemindManager.Instance:Fire(RemindName.RewardGift2)
end

--领取奖励请求
function ActivityPanelLoginRewardCtrl:SendGetReward(rand_activity_type, opera_type, param_1, param_2)
	if IS_ON_CROSSSERVER then
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type or 0
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end
