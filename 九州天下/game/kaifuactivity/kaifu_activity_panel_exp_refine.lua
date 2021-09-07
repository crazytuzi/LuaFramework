KaiFuExpRefineView = KaiFuExpRefineView or BaseClass(BaseRender)

function KaiFuExpRefineView:__init()
	self.play_audio = true
	self.have_get_gold_num = 0
	self.old_get_gold_num = 0
	self.is_fly_ing = false
end

function KaiFuExpRefineView:__delete()
	-- 清理变量和对象
	self.label_refine_get_num = nil
	self.label_level_and_rebirth = nil
	self.obj_leiji = nil
	self.obj_get = nil
	self.obj_reward = nil
	self.obj_diamond_animator = nil
	self.act_time = nil
	self.day_num = nil
	self.gold = nil
	self.have_get_gold = nil
	self.left_value = nil
	self.right_value1 = nil
	self.right_value2 = nil
	self.level_up_day = nil
	self.refine_get_num = nil
	self.level_and_rebirth = nil
	self.btn_is_refine = nil
	self.show_label_image = nil

	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.is_fly_ing = false
end

function KaiFuExpRefineView:LoadCallBack()
	self.label_refine_get_num = self:FindObj("LabelRefineGetNum")
	self.label_level_and_rebirth = self:FindObj("LabelLevelAndRebirth")
	self.obj_leiji = self:FindObj("LeiJi")
	self.obj_get = self:FindObj("Get")
	self.obj_reward = self:FindObj("Reward")
	self.obj_diamond_animator = self:FindObj("DiamondAnim")

	self.act_time = self:FindVariable("ActTime")
	self.day_num = self:FindVariable("DayNum")
	self.gold = self:FindVariable("Gold")
	self.have_get_gold = self:FindVariable("HaveGotGold")

	self.left_value = self:FindVariable("LeftValue")
	self.right_value1 = self:FindVariable("RightValue1")
	self.right_value2 = self:FindVariable("RightValue2")
	self.level_up_day = self:FindVariable("LevelUpDay")
	self.refine_get_num = self:FindVariable("RefineGetNum")
	self.level_and_rebirth = self:FindVariable("LevelAndRebirth")
	self.btn_is_refine = self:FindVariable("IsRefine")
	self.show_label_image = self:FindVariable("ShowLabelImage")

	self:ListenEvent("OnClickRefine", BindTool.Bind(self.OnClickRefineHanlder, self))
	self:ListenEvent("ClickOpenReward", BindTool.Bind(self.OnClickOpenRewardHanlder, self))

	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	self.old_get_gold_num = exp_refine_info.refine_reward_gold

	self.have_get_gold_num = 0
	ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_GET_INFO)
	self:SetActivityInfo()
end

function KaiFuExpRefineView:SetCurTyoe()
	
end

function KaiFuExpRefineView:SetActivityInfo()
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

function KaiFuExpRefineView:CountDownTime(elapse_time, total_time)
	local time = total_time - elapse_time
	if time > 0 then
		self.act_time:SetValue(TimeUtil.FormatSecond2Str(time))
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

function KaiFuExpRefineView:OnFlush()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	local buy_num = exp_refine_info.refine_today_buy_time
	local max_buy_num = ExpRefineData.Instance:GetRAExpRefineCfgMaxNum()

	-- 砖石飞过去的动画
	if self.old_get_gold_num ~= exp_refine_info.refine_reward_gold then
		self.is_fly_ing = true
		self.old_get_gold_num = exp_refine_info.refine_reward_gold
	end

	if self.is_fly_ing and self.old_get_gold_num > 0 then
		self.is_fly_ing = false
		local animator = self.obj_diamond_animator:GetComponent(typeof(UnityEngine.Animator))
		if animator.isActiveAndEnabled then
			animator:SetTrigger("state")
		end
	end

	if exp_refine_info.refine_reward_gold > 0 then
		self.have_get_gold_num = exp_refine_info.refine_reward_gold
		self.have_get_gold:SetValue(self.have_get_gold_num)
	end
	self.gold:SetValue(exp_refine_info.refine_reward_gold)

	local result_buy_num = max_buy_num - buy_num
	result_buy_num = result_buy_num > 0 and result_buy_num or 0
	local str = ToColorStr(result_buy_num, "#00931F")
	if result_buy_num <= 0 then
		str = ToColorStr(result_buy_num, COLOR.RED)
	end
	self.right_value1:SetValue(str)
	self.right_value2:SetValue(max_buy_num)

	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_info.next_time or 0
		local time = next_time - TimeCtrl.Instance:GetServerTime()
		local time_tab = TimeUtil.Format2TableDHM(time)
		self.day_num:SetValue(time_tab.day + 1)
	else
		self.day_num:SetValue(1)
	end

	if buy_num < max_buy_num and act_info.status == ACTIVITY_STATUS.OPEN then
		local exp_refine_cfg = ExpRefineData.Instance:GetRAExpRefineCfgBySeq(buy_num)
		if exp_refine_cfg then
			-- 没配置写死7天
			self.level_up_day:SetValue(7)

			self.left_value:SetValue(exp_refine_cfg.consume_gold)
			self.refine_get_num:SetValue(exp_refine_cfg.reward_exp)

			local role_exp = GameVoManager.Instance:GetMainRoleVo().exp + exp_refine_cfg.reward_exp
			local level = PlayerData.Instance:GetRoleLevelByExp(role_exp)
			local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
			self.level_and_rebirth:SetValue(string.format(Language.ExpRefine.LevelString, sub_level, rebirth))
		end

		self.label_refine_get_num:SetActive(true)
		self.show_label_image:SetValue(true)
		self.label_level_and_rebirth:SetActive(true)
		self.btn_is_refine:SetValue(false)

		self.obj_leiji:SetActive(true)
		self.obj_get:SetActive(false)
		self.obj_reward:SetActive(false)
	else
		self.left_value:SetValue("--")
		self.label_refine_get_num:SetActive(false)
		self.show_label_image:SetValue(false)
		self.label_level_and_rebirth:SetActive(false)
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

function KaiFuExpRefineView:OnClickRefineHanlder()
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

function KaiFuExpRefineView:OnClickOpenRewardHanlder()
	local exp_refine_info = ExpRefineData.Instance:GetRAExpRefineInfo()
	if exp_refine_info.refine_reward_gold > 0 then
		ExpRefineCtrl.Instance:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD)
	end
end