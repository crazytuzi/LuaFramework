TeamFuBenInfoView = TeamFuBenInfoView or BaseClass(BaseView)

function TeamFuBenInfoView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "TeamTowerFBInFoView"}

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.out_time = 0
end

function TeamFuBenInfoView:LoadCallBack()
	self.cur_count = self:FindVariable("CurCunt")
	self.kill_count = self:FindVariable("KillCount")
	self.next_time = self:FindVariable("NextTime")
	self.progess = self:FindVariable("Progress")
	self.pre_txt = self:FindVariable("ProTxt")
	self.auto_toggle = self:FindObj("AutoToggle")
	self.text_name = self:FindVariable("text_name")
	self.text_name:SetValue(Language.FuBen.TeamFbName[2])

	self.show_panel = self:FindVariable("ShowPanel")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:ListenEvent("OnClickRefresh",BindTool.Bind(self.OnClickRefresh, self))
	self:ListenEvent("OnToggleChange",BindTool.Bind(self.OnToggleChange, self))
end

function TeamFuBenInfoView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function TeamFuBenInfoView:ReleaseCallBack()
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
	self.text_name = nil
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TeamFuBenInfoView:OpenCallBack()
	self:Flush()
end

function TeamFuBenInfoView:CloseCallBack()

end

function TeamFuBenInfoView:OnClickRefresh()
	FuBenCtrl.SendTowerDefendNextWave()
end


function TeamFuBenInfoView:OnToggleChange(is_on)

end

function TeamFuBenInfoView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function TeamFuBenInfoView:OnFlush(param_t)
	local team_info = TeamFbData.Instance:GetTeamTowerInfo() or {}
	if nil == next(team_info) then return end
	local cur_level = FuBenData.Instance:GetCurTowerDefendLevel()
	local wave_num = FuBenData.Instance:GetTeamTowerWaveNum()
	self.cur_count:SetValue(team_info.curr_wave + 1 .. "/" .. wave_num)
	self.kill_count:SetValue(team_info.clear_wave .. "/" .. wave_num)
	local pro = team_info.life_tower_left_hp / team_info.life_tower_left_maxhp
	if team_info.life_tower_left_hp <= 0 then
		GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 2)
	end
	self.progess:SetValue(pro)
	local pro_txt = math.ceil(pro * 100) .. "%"
	self.pre_txt:SetValue(pro_txt)
	self.out_time = team_info.next_wave_refresh_time
	if nil == self.timer_quest then
		self:TimerCallback()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	end
	if self.auto_toggle.toggle.isOn and team_info.curr_wave + 1 == team_info.clear_wave and team_info.curr_wave + 1 < wave_num then
		FuBenCtrl.SendTowerDefendNextWave()
	end

end

function TeamFuBenInfoView:TimerCallback()
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