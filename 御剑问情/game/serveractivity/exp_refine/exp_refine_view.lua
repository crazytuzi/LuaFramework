ExpRefineView = ExpRefineView or BaseClass(BaseView)

function ExpRefineView:__init()
	self.ui_config = {"uis/views/serveractivity/exprefine_prefab", "ExpRefineView"}
	self.play_audio = true

	self.have_get_gold_num = 0
	self.old_get_gold_num = 0
end

function ExpRefineView:__delete()

end

function ExpRefineView:ReleaseCallBack()
	-- 清理变量和对象
	self.label_refine_get_num = nil
	self.obj_leiji = nil
	self.obj_get = nil
	self.obj_reward = nil
	self.act_time = nil
	self.day_num = nil
	self.gold = nil
	self.have_get_gold = nil
	self.left_value = nil
	self.right_value1 = nil
	self.right_value2 = nil
	-- self.level_up_day = nil
	self.refine_get_num = nil
	self.btn_is_refine = nil
	self.show_label_image = nil
	self.vip_str = nil
end

function ExpRefineView:LoadCallBack()
	self.label_refine_get_num = self:FindObj("LabelRefineGetNum")
	self.obj_leiji = self:FindObj("LeiJi")
	self.obj_get = self:FindObj("Get")
	self.obj_reward = self:FindObj("Reward")


	self.act_time = self:FindVariable("ActTime")
	self.day_num = self:FindVariable("DayNum")
	self.gold = self:FindVariable("Gold")
	self.have_get_gold = self:FindVariable("HaveGotGold")

	self.left_value = self:FindVariable("LeftValue")
	self.right_value1 = self:FindVariable("RightValue1")
	self.right_value2 = self:FindVariable("RightValue2")
	-- self.level_up_day = self:FindVariable("LevelUpDay")
	self.refine_get_num = self:FindVariable("RefineGetNum")
	self.btn_is_refine = self:FindVariable("IsRefine")
	self.show_label_image = self:FindVariable("ShowLabelImage")
	self.vip_str = self:FindVariable("VIPStr")

	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickRefine", BindTool.Bind(self.OnClickRefineHanlder, self))
	self:ListenEvent("ClickOpenReward", BindTool.Bind(self.OnClickOpenRewardHanlder, self))
end

function ExpRefineView:OpenCallBack()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	self.old_get_gold_num = exp_refine_info.refine_reward_gold

	self.have_get_gold_num = 0
	ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_GET_INFO)
end

function ExpRefineView:ShowIndexCallBack(index)
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_info.next_time or 0
		if CountDown.Instance:HasCountDown(self.count_down) then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end

		local time = next_time - TimeCtrl.Instance:GetServerTime()
		if self.count_down == nil and time > 0 then
			self:CountDownTime(0, time)
			self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDownTime, self))
		end
	else
		self.act_time:SetValue(Language.Activity.YiJieShuDes)
	end
end

function ExpRefineView:CloseCallBack()
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ExpRefineView:CountDownTime(elapse_time, total_time)
	local time = total_time - elapse_time
	if time > 0 then
		if time > 60 * 60 * 24 then
			self.act_time:SetValue(TimeUtil.FormatSecond(time, 7))
		else
			self.act_time:SetValue(TimeUtil.FormatSecond2Str(time))
		end
	else
		if self.count_down then
			if CountDown.Instance:HasCountDown(self.count_down) then
				CountDown.Instance:RemoveCountDown(self.count_down)
			end
			self.count_down = nil
		end
		self.act_time:SetValue(Language.Activity.YiJieShuDes)
	end
end

function ExpRefineView:OnFlush()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	local buy_num = exp_refine_info.refine_today_buy_time
	local max_buy_num, next_vip, next_count = ExpRefineData.Instance:GetRAExpRefineCfgMaxNum()

	-- 砖石飞过去的动画
	if self.old_get_gold_num ~= exp_refine_info.refine_reward_gold then
		self.old_get_gold_num = exp_refine_info.refine_reward_gold
	end

	if exp_refine_info.refine_reward_gold > 0 then
		self.have_get_gold_num = exp_refine_info.refine_reward_gold
		self.have_get_gold:SetValue(self.have_get_gold_num)
	end
	self.gold:SetValue(exp_refine_info.refine_reward_gold)

	local result_buy_num = max_buy_num - buy_num
	result_buy_num = result_buy_num > 0 and result_buy_num or 0
	local str = ToColorStr(result_buy_num, "#0000f1ff")
	if result_buy_num <= 0 then
		str = ToColorStr(result_buy_num, COLOR.RED)
	end
	self.right_value1:SetValue(str)
	self.right_value2:SetValue(max_buy_num)
	if next_vip > -1 then
		self.vip_str:SetValue(string.format(Language.ExpRefine.VipLimit, next_vip, max_buy_num + next_count))
	else
		self.vip_str:SetValue("")
	end

	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_info.next_time or 0
		local time = next_time - TimeCtrl.Instance:GetServerTime()
		local time_tab = TimeUtil.Format2TableDHM(time)
		local day = nil

		if time_tab.day + 1 <= 10 then
			day = Language.Common.NumToChs[time_tab.day + 1]
		elseif time_tab.day + 1 > 10 and  time_tab.day + 1 < 20 then
			day = Language.Common.NumToChs[10] .. Language.Common.NumToChs[(time_tab.day + 1) % 10]
		elseif time_tab.day + 1 > 20 and  time_tab.day + 1 < 100 then
			day = Language.Common.NumToChs[math.floor((time_tab.day + 1)/10)] ..Language.Common.NumToChs[10] .. Language.Common.NumToChs[(time_tab.day + 1) % 10]
		elseif time_tab.day + 1 % 10 == 0 and time_tab.day + 1 > 10 then
			day = Language.Common.NumToChs[math.floor((time_tab.day + 1)/10)] .. Language.Common.NumToChs[10]
		end

		self.day_num:SetValue(day)
	else
		self.day_num:SetValue(CommonDataManager.DAXIE[1])
	end

	if buy_num < max_buy_num and act_info.status == ACTIVITY_STATUS.OPEN then
		local exp_refine_cfg = ExpRefineData.Instance:GetRAExpRefineCfgBySeq(buy_num)
		if exp_refine_cfg then
			-- 没配置写死7天
			-- self.level_up_day:SetValue(7)

			self.left_value:SetValue(exp_refine_cfg.consume_gold)
			self.refine_get_num:SetValue(exp_refine_cfg.reward_exp)

			local role_exp = GameVoManager.Instance:GetMainRoleVo().exp + exp_refine_cfg.reward_exp
			local level = PlayerData.Instance:GetRoleLevelByExp(role_exp)
			local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
		end

		self.label_refine_get_num:SetActive(true)
		self.show_label_image:SetValue(true)
		self.btn_is_refine:SetValue(false)

		self.obj_leiji:SetActive(true)
		self.obj_get:SetActive(false)
		self.obj_reward:SetActive(false)
	else
		self.left_value:SetValue("")
		self.label_refine_get_num:SetActive(false)
		self.show_label_image:SetValue(false)
		self.btn_is_refine:SetValue(true)

		if act_info.status == ACTIVITY_STATUS.OPEN then
			self.obj_leiji:SetActive(true)
			self.obj_get:SetActive(false)
			self.obj_reward:SetActive(false)
		else
			self.obj_leiji:SetActive(false)
			if exp_refine_info.refine_reward_gold > 0 then
				self.obj_get:SetActive(true)
				self.obj_reward:SetActive(false)
			else
				self.obj_get:SetActive(false)
				self.obj_reward:SetActive(true)
			end
		end
	end
end

function ExpRefineView:OnClickClose()
	self:Close()
end

function ExpRefineView:OnClickRefineHanlder()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
		local exp_refine_cfg = ExpRefineData.Instance:GetRAExpRefineCfgBySeq(exp_refine_info.refine_today_buy_time)
		if exp_refine_cfg then
			local des = string.format(Language.ExpRefine.AutoTips, exp_refine_cfg.consume_gold)
			local ok_callback = function()
				ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_BUY_EXP)
			end
			TipsCtrl.Instance:ShowCommonAutoView("auto_exp_refine", des, ok_callback)
		end
	end
end

function ExpRefineView:OnClickOpenRewardHanlder()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	if exp_refine_info.refine_reward_gold > 0 then
		ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD)
	end
end