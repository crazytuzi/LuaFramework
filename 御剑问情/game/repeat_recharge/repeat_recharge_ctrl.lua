
require("game/repeat_recharge/repeat_recharge_data")
require("game/repeat_recharge/repeat_recharge_view")

RepeatRechargeCtrl = RepeatRechargeCtrl or BaseClass(BaseController)

function RepeatRechargeCtrl:__init()
	if nil ~= RepeatRechargeCtrl.Instance then
		print_error("[RepeatRechargeCtrl] attempt to create singleton twice!")
		return
	end
	RepeatRechargeCtrl.Instance = self
	self.data = RepeatRechargeData.New()
	self.view = RepeatRechargeView.New(ViewName.RepeatRechargeView)
	self:RegisterAllProtocols()
	self:RegisterAllHandlers()

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.RepeatRecharge)
end

function RepeatRechargeCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	RepeatRechargeCtrl.Instance = nil
end

function RepeatRechargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRACirculationChongzhiInfo, "OnSCRACirculationChongzhiInfo")
end

function RepeatRechargeCtrl:RegisterAllHandlers()

end

-- 打开主窗口
function RepeatRechargeCtrl:Open()
	self.view:Open()
end

-- 刷新面板
function RepeatRechargeCtrl:OnSCRACirculationChongzhiInfo(protocol)
	self.data:UpdateInfoData(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.RepeatRecharge)
end

function RepeatRechargeCtrl:SendAllInfoReq() 
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE, 
										RA_CIRCULATION_CHONGZHI_OPERA_TYPE.RA_CIRCULATION_CHONGZHI_OPERA_TYPE_QUERY_INFO)
end

function RepeatRechargeCtrl:SendGetReward()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE, 
										RA_CIRCULATION_CHONGZHI_OPERA_TYPE.RA_CIRCULATION_CHONGZHI_OPEAR_TYPE_FETCH_REWARD)
end

function RepeatRechargeCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE and status == ACTIVITY_STATUS.OPEN then
		self:SendAllInfoReq()
	end 
end

function RepeatRechargeCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.RepeatRecharge then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE, num > 0)
	end
end