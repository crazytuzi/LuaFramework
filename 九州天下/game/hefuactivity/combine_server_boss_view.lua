CombineServerBoss =  CombineServerBoss or BaseClass(BaseRender)

function CombineServerBoss:__init()
end

function CombineServerBoss:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
end

function CombineServerBoss:SetCurTyoe(cur_type)
end

function CombineServerBoss:OpenCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)
end

function CombineServerBoss:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function CombineServerBoss:LoadCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

	self.activity_time = self:FindVariable("ActivityTime")
	self.Kill_boss_des = self:FindVariable("KillBossDes")
	self.can_reward = self:FindVariable("CanReward")
	self.reward_count = self:FindVariable("RewardCount")

	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGo, self))
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("Item"))
end

function CombineServerBoss:OnFlush()
	local other_cfg = HefuActivityData.Instance:GetCombineServerOtherCfg()
	local role_info = HefuActivityData.Instance:GetCombineRoleInfo()
	if other_cfg and role_info then
		local kill_boss_reward_cost = other_cfg.kill_boss_reward_cost or 0
		local kill_boss_count = role_info.kill_boss_kill_count or 0
		local reward_max_count = other_cfg.kill_boss_fetch_reward_max_times or 0
		local reward_count = role_info.kill_boss_fetch_reward_times or 0
		local can_reward_count = reward_max_count - reward_count
		self.reward_item:SetData(other_cfg.kill_boss_reward or {})
		self.reward_count:SetValue(can_reward_count)
		local show_kill_boss_count = reward_count * kill_boss_reward_cost + kill_boss_count
		self.Kill_boss_des:SetValue(string.format(Language.HefuActivity.BossKillDes, show_kill_boss_count, can_reward_count))
		self.can_reward:SetValue(can_reward_count > 0 and kill_boss_count >= kill_boss_reward_cost)
	end
end

function CombineServerBoss:OnClickGo()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.neutral_boss)
end

function CombineServerBoss:OnClickReward()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS)
end

function CombineServerBoss:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	if self.activity_time then
		self.activity_time:SetValue(str)
	end
end