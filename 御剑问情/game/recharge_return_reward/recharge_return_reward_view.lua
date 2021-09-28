
RechargeReturnRewardView = RechargeReturnRewardView or BaseClass(BaseView)
function RechargeReturnRewardView:__init()
	self.ui_config = {"uis/views/randomact/rechargereturnreward_prefab","RechargeReturnReward"}
	self.play_audio = true
	self.reward_count = 4
end

function RechargeReturnRewardView:__delete()
end

function RechargeReturnRewardView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.act_time = nil
	self.text_today_recharge = nil
	self.reward_desc_list = {}
	self.reward_percent_list = {}
end

function RechargeReturnRewardView:LoadCallBack(index, loaded_times)
	self.act_time = self:FindVariable("ActTime")
	self.reward_desc_list = {}
	self.reward_percent_list = {}
	for i=1,self.reward_count do
		self.reward_desc_list[i] = self:FindVariable("text_recharge_num" .. i)
		self.reward_percent_list[i] = self:FindVariable("text_percent" .. i)
	end

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OpenRecharge", BindTool.Bind(self.OpenRecharge, self))

	self.text_today_recharge = self:FindVariable("text_today_recharge")
end

function RechargeReturnRewardView:OnClickRecharge()
end


function RechargeReturnRewardView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function RechargeReturnRewardView:OpenCallBack()
end

function RechargeReturnRewardView:CloseCallBack()
end

function RechargeReturnRewardView:OpenRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RechargeReturnRewardView:OnFlush(param_t, index)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	local config = RechargeReturnRewardData.Instance:GetActConfig()

	if config then
		local open_day = TimeCtrl.Instance:GetCurOpenServerDay() or 0
		local opengame_day = config[self.reward_count] and config[self.reward_count].opengame_day or 0

		for i = 1, self.reward_count do
			local index = i

			if opengame_day < open_day then
				index = index + self.reward_count
			end

			local cfg = config[index]

			if cfg then
				local desc = ""
				if cfg.gold_high_limit then
					desc = cfg.gold_low_limit .. "-" .. cfg.gold_high_limit
				else
					desc = cfg.gold_low_limit
				end

				self.reward_desc_list[i]:SetValue(desc)
				self.reward_percent_list[i]:SetValue(cfg.reward_precent .. "%")
			end
		end
	end
	
	local num = RechargeReturnRewardData.Instance:GetRechargeNum()
	self.text_today_recharge:SetValue(num or 0)
end

function RechargeReturnRewardView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end
	
	self.act_time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, time_type), TEXT_COLOR.GREEN))
end
