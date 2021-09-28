CompetitionTips = CompetitionTips or BaseClass(BaseView)

function CompetitionTips:__init()
	self.ui_config = {"uis/views/competitionactivityview_prefab","CompeteTips"}
	self.reward_item_list = {}
end

function CompetitionTips:__delete()

end

function CompetitionTips:ReleaseCallBack()
	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	self:CancelCountDown()
	self.time = nil
	self.can_reward = nil
	self.condition = nil

	RemindManager.Instance:UnBind(self.remind_change)
end

function CompetitionTips:LoadCallBack()
	for i = 1, 2 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self:FindObj("RewardItem"..i))
		self.reward_item_list[i] = cell
	end

	self.time = self:FindVariable("Time")
	self.can_reward = self:FindVariable("Can_Reward")
	self.condition = self:FindVariable("Condition")

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGetReward, self))
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))

	self.remind_change = function() self:Flush() end
	RemindManager.Instance:Bind(self.remind_change,  RemindName.BiPin)
end

function CompetitionTips:OpenCallBack()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[open_day] then
		return
	end
	
	local activity_type = bipin_cfg[open_day].activity_type
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end

function CompetitionTips:ShowIndexCallBack()
	self:Flush()
end

function CompetitionTips:OnFlush()
	local reward_item_list = CompetitionActivityData.Instance:GetBiPingReward()
	if nil == reward_item_list or nil == next(reward_item_list) then
		return
	end
	for k, v in pairs(self.reward_item_list) do
		v:SetActive(nil ~= reward_item_list[k])
		if reward_item_list[k] then
			v:SetData(reward_item_list[k])
		end
	end

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[open_day] then
		return
	end
	
	local activity_type = bipin_cfg[open_day].activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then
		return
	end
	local is_reward = KaifuActivityData.Instance:IsGetReward(cfg[#cfg].seq, activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(cfg[#cfg].seq, activity_type)
	self.can_reward:SetValue(is_complete and not is_reward)

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)

	local bundle, asset = ResPath.GetCompetitionActivity("word_act_" .. activity_type)
	self.condition:SetAsset(bundle, asset)
end

function CompetitionTips:CloseCallBack()

end

function CompetitionTips:OnClickGetReward()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[open_day] then
		return
	end
	
	local activity_type = bipin_cfg[open_day].activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then
		return
	end

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, #cfg or 0)
end

function CompetitionTips:CloseWindow()
	self:Close()
end

function CompetitionTips:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(total_time - elapse_time + 0.5)
			self.time:SetValue(TimeUtil.FormatSecond(left_time))
		end

		diff_time_func(0, diff_time)
		self:CancelCountDown()
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function CompetitionTips:CancelCountDown()
	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end