FuBenInfoGuardView = FuBenInfoGuardView or BaseClass(BaseView)

function FuBenInfoGuardView:__init()
	self.ui_config = {"uis/views/fubenview", "TowerDefendFBInFoView"}

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.out_time = 0
	self.flag = false
	self.is_safe_area_adapter = true
end

function FuBenInfoGuardView:LoadCallBack()
	self.cur_count = self:FindVariable("CurCunt")
	self.kill_count = self:FindVariable("KillCount")
	self.next_time = self:FindVariable("NextTime")
	self.progess = self:FindVariable("Progress")
	self.pre_txt = self:FindVariable("ProTxt")
	self.auto_toggle = self:FindObj("AutoToggle")

	self.show_panel = self:FindVariable("ShowPanel")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:ListenEvent("OnClickRefresh",BindTool.Bind(self.OnClickRefresh, self))
	self:ListenEvent("OnToggleChange",BindTool.Bind(self.OnToggleChange, self))
end

function FuBenInfoGuardView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function FuBenInfoGuardView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self.cur_count = nil
	self.kill_count = nil
	self.next_time = nil
	self.progess = nil
	self.pre_txt = nil
	self.show_panel = nil
	self.auto_toggle = nil
	self.out_time = 0
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function FuBenInfoGuardView:OpenCallBack()
	self:Flush()
end

function FuBenInfoGuardView:CloseCallBack()

end

function FuBenInfoGuardView:OnClickRefresh()
	FuBenCtrl.Instance:SendTowerDefendNextWave()
end

function FuBenInfoGuardView:OnToggleChange(is_on)
	self.flag = is_on
end

function FuBenInfoGuardView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function FuBenInfoGuardView:OnFlush(param_t)
	local info = FuBenData.Instance:GetTowerDefendInfo()
	if nil == next(info) then return end
	local cur_level = FuBenData.Instance:GetCurTowerDefendLevel()
	local cfg = FuBenData.Instance:GetTowerWaveCfg(cur_level)
	self.cur_count:SetValue(info.curr_wave + 1 .. "/" .. #cfg)
	self.kill_count:SetValue(info.clear_wave_count .. "/" .. #cfg)
	local pro = info.life_tower_left_hp / info.life_tower_left_maxhp
	self.progess:SetValue(pro)
	local pro_txt = math.ceil(pro * 100) .. "%"
	self.pre_txt:SetValue(pro_txt)
	self.out_time = info.next_wave_refresh_time
	if nil == self.timer_quest then
		self:TimerCallback()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	end
	if self.auto_toggle.toggle.isOn and info.curr_wave + 1 == info.clear_wave_count and info.curr_wave + 1 < #cfg then
		FuBenCtrl.Instance:SendTowerDefendNextWave()
	end

	-- if info.curr_wave == info.clear_wave_count and self.flag then
	-- 	FuBenCtrl.Instance:SendTowerDefendNextWave()
	-- end
end

function FuBenInfoGuardView:TimerCallback()
	local time = math.max(self.out_time - TimeCtrl.Instance:GetServerTime(), 0)
	if time > 3600 then
		self.next_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.next_time:SetValue(TimeUtil.FormatSecond(time, 2))
	end
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end