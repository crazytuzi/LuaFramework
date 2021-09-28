require("game/limited_feedback/limited_feedback_view")
require("game/limited_feedback/limited_feedback_data")

LimitedFeedbackCtrl = LimitedFeedbackCtrl or BaseClass(BaseController)

function LimitedFeedbackCtrl:__init()
	if LimitedFeedbackCtrl.Instance then
		print_error("[LimitedFeedbackCtrl] Attemp to create a singleton twice !")
	end
	LimitedFeedbackCtrl.Instance = self

	self.data = LimitedFeedbackData.New()
	self.view = LimitedFeedbackView.New(ViewName.LimitedFeedbackView)

	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.LimitedFeedbackRemind)
end

function LimitedFeedbackCtrl:__delete()

	LimitedFeedbackCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

end

function LimitedFeedbackCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALimitTimeRebateInfo , "OnSCRALimitTimeRebateInfo")
end

function LimitedFeedbackCtrl:OnSCRALimitTimeRebateInfo(protocol)
	self.data:SetSCRALimitTimeRebateInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LimitedFeedbackRemind)

end

function LimitedFeedbackCtrl:ActivityChange(activity_type, status, next_time, open_type)

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE,RA_LIMIT_TIME_REBATE_OPERA_TYPE.RA_LIMIT_TIME_REBATE_OPERA_TYPE_INFO,0,0)
		end
	end
end

function LimitedFeedbackCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.LimitedFeedbackRemind then
		self.data:FlushHallRedPoindRemind()
	end
end