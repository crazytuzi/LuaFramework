KillTaskView = KillTaskView or BaseClass(BaseView)

function KillTaskView:__init()
	self:SetMaskBg(true)
	self.ui_config = {"uis/views/taskview", "KillTaskView"}
	self.des = ""
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function KillTaskView:__delete()

end

function KillTaskView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))

	--self.exp = self:FindVariable("Exp")
	self.jungong = self:FindVariable("JunGong")
	self.yingyong = self:FindVariable("YingYong")
	self.jungong_exp = self:FindVariable("JunGongExp")
	self.killget = self:FindVariable("KillGet")
	self.vip7max = self:FindVariable("Vip7Max")
	self.vip8max = self:FindVariable("Vip8Max")
end

function KillTaskView:ReleaseCallBack()
	--self.exp = nil
	self.jungong = nil
	self.yingyong = nil
	self.jungong_exp = nil
	self.killget = nil
	self.vip7max = nil
	self.vip8max = nil
end

function KillTaskView:CloseWindow()
	self:Close()
end

function KillTaskView:OpenCallBack()
	self:Flush()
end

function KillTaskView:OnFlush()
	local level = PlayerData.Instance.role_vo.level
	local vip_level = PlayerData.Instance.role_vo.vip_level
	local task_info = TaskData.Instance:GetKillTaskInfo()
	local kill_level_cfg = TaskData.Instance:GetKillRoleLevelLimit(level) -- 杀人任务等级上线配置
	local fetch_Integration = TaskData.Instance:GetkillRoleFetchIntegration()[1] -- 杀人积分
	local integration_reward = TaskData.Instance:GetIntegrationReward(level) -- 杀人任务积分奖励配置

	if task_info and kill_level_cfg and fetch_Integration and integration_reward then
		--self.exp:SetValue(string.format(Language.Task.KillTaskExp, task_info.kill_role_reward_exp, kill_level_cfg.reward_jingyan_limit))
		local reward_jungong_limit = kill_level_cfg.reward_jungong_limit
		if vip_level >= 8 then
			reward_jungong_limit = kill_level_cfg.vip8_reward_jungong_limit
		elseif vip_level >= 4 then
			reward_jungong_limit = kill_level_cfg.vip4_reward_jungong_limit
		else
			reward_jungong_limit = kill_level_cfg.reward_jungong_limit
		end
		self.jungong:SetValue(string.format(Language.Task.KillTaskJunGong, task_info.kill_role_jungong, reward_jungong_limit))
		self.yingyong:SetValue(string.format(Language.Task.TaskYingyong, task_info.task_desc))
		self.jungong_exp:SetValue(string.format(Language.Task.TaskJungongExp, fetch_Integration.integration_get_jungong, integration_reward.reward_jingyan, integration_reward.reward_jungong))
		self.killget:SetValue(string.format(Language.Task.TaskKillget, fetch_Integration.kill_role_fetch_integration, fetch_Integration.teammate_kill_role_intergration, fetch_Integration.bekill_role_fetch_integration))
		self.vip7max:SetValue(string.format(Language.Task.Vip7Max, string.format("%0.2f", ((kill_level_cfg.vip4_reward_jungong_limit - kill_level_cfg.reward_jungong_limit) / kill_level_cfg.reward_jungong_limit)) * 100))
		self.vip8max:SetValue(string.format(Language.Task.Vip8Max, string.format("%0.2f", ((kill_level_cfg.vip8_reward_jungong_limit- kill_level_cfg.reward_jungong_limit) / kill_level_cfg.reward_jungong_limit)) * 100))

	end
end