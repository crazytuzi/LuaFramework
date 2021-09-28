require("game/recharge_return_reward/recharge_return_reward_view")
require("game/recharge_return_reward/recharge_return_reward_data")

RechargeReturnRewardCtrl = RechargeReturnRewardCtrl or BaseClass(BaseController)

function RechargeReturnRewardCtrl:__init()
	if RechargeReturnRewardCtrl.Instance ~= nil then
		print("[RechargeReturnRewardCtrl]error:create a singleton twice")
	end
	RechargeReturnRewardCtrl.Instance = self

	self.view = RechargeReturnRewardView.New(ViewName.RechargeReturnReward)
	self.data = RechargeReturnRewardData.New()

	self:RegisterAllProtocols()
end

function RechargeReturnRewardCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	RechargeReturnRewardCtrl.Instance = nil
end

function RechargeReturnRewardCtrl:Open(index, param_t)
	local mijingtaobao_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
	if not mijingtaobao_isopen then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end
	self.view:Open(index)
end

function RechargeReturnRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRaCrazyRebateChongInfo , "OnSCRaCrazyRebateChongInfo")
end

function RechargeReturnRewardCtrl:OnSCRaCrazyRebateChongInfo(protocol)
	self.data:SetRechargeNum(protocol.chongzhi_count)

	if self.view:IsOpen() then
		self.view:Flush()
	end
end
