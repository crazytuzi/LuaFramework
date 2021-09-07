FuBenInfoExpView = FuBenInfoExpView or BaseClass(BaseView)

function FuBenInfoExpView:__init()
	self.ui_config = {"uis/views/fubenview", "ExpFBInFoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function FuBenInfoExpView:LoadCallBack()
	self.cur_wave = self:FindVariable("wave")
	self.kill_monster_text = self:FindVariable("kill_monster_text")
	self.exp_text = self:FindVariable("exp_text")
	self.all_wave = self:FindVariable("all_wave")
	self.show_panel = self:FindVariable("show_panel")
	self.total_monster_text = self:FindVariable("total_monster_text")
	self.monster_name = self:FindVariable("monster_name")
	self.remaining_time = self:FindVariable("remaining_time")
	-- self.wave_reward = self:FindVariable("wave_reward")

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))

	--刷新副本剩余时间
	self.FlushRemainingTime_timer_quest = GlobalTimerQuest:AddRunQuest(function() 
		self:UpdateRemainingTime()
	end, 1)

	self:Flush()
end

function FuBenInfoExpView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	if self.show_panel then
		self.show_panel:SetValue(state)
	end
end

function FuBenInfoExpView:ReleaseCallBack()
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	if self.FlushRemainingTime_timer_quest then
		GlobalTimerQuest:CancelQuest(self.FlushRemainingTime_timer_quest)
		self.FlushRemainingTime_timer_quest = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	-- 清理变量和对象
	self.cur_wave = nil
	self.monster_name = nil
	self.kill_monster_text = nil
	self.total_monster_text = nil
	-- self.wave_reward = nil
	self.exp_text = nil
	self.all_wave = nil
	self.show_panel = nil
	self.remaining_time = nil
	self.exit_fb_time = nil
end

function FuBenInfoExpView:OnFlush()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	if not exp_fb_info then return end
	local exp_fb_cfg = FuBenData.Instance:GetExpFBLevelCfg()														
	if not exp_fb_cfg then return end
	local exp_fb_cfg_info = exp_fb_cfg[exp_fb_info.param1]
	if not exp_fb_cfg_info then return end
	
	--通过波数获得当前波的怪物名字	
	local monster_cfg = BossData.Instance:GetMonsterInfo(exp_fb_cfg_info.monster_id)
	if monster_cfg then
		self.monster_name:SetValue(monster_cfg.name)
	end
	--通过波数获得当前波的经验奖励
	-- self.wave_reward:SetValue(exp_fb_cfg_info.reward_exp)
	--杀怪数目
	self.kill_monster_text:SetValue(exp_fb_info.kill_allmonster_num)
	--怪物总数
	if exp_fb_info.total_allmonster_num > 0 then
		self.total_monster_text:SetValue(exp_fb_info.total_allmonster_num)
	end 
	self.cur_wave:SetValue(exp_fb_info.param1)
	self.exp_text:SetValue(CommonDataManager.ConverMoney(exp_fb_info.exp))
	
	local data_list = {Language.FuBen.GainExperience, {item_id = ResPath.CurrencyToIconId.exp or 0, num = exp_fb_info.exp,is_bind = 0}}
	if exp_fb_info.is_finish == 1 then
		if self.upgrade_timer_quest == nil then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "expfinish", {data = data_list})
			end, 2)
		end
	end

	--通过副本超时时间戳计算出副本剩余时间并设置
	if exp_fb_info.time_out_stamp and self.remaining_time then
		self.exit_fb_time = exp_fb_info.time_out_stamp
		if exp_fb_info.is_pass == 1 and exp_fb_info.is_finish == 1 then
			self.exit_fb_time = TimeCtrl.Instance:GetServerTime() + 15
		end
	end
end

--刷新副本剩余时间,供计时器调用
function FuBenInfoExpView:UpdateRemainingTime()
	if self.exit_fb_time then
		local remainingSecond = self.exit_fb_time - TimeCtrl.Instance:GetServerTime() --副本剩余秒数
		local remainingDateTime  =  os.date("%M:%S",remainingSecond)
		self.remaining_time:SetValue(remainingDateTime)
	end 
end