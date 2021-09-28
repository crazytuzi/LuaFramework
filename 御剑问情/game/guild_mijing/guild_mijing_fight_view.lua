
GuildMijingFightView = GuildMijingFightView or BaseClass(BaseView)

function GuildMijingFightView:__init()
	self.ui_config = {"uis/views/guildmijing_prefab","GuildMijingFightView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function GuildMijingFightView:__delete()

end

function GuildMijingFightView:LoadCallBack()
	self.score_info = MijingScoreInfoView.New(self:FindObj("ScorePerson"))
	-- self.shrink_button_toggle = self:FindObj("ShrinkButton").toggle
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))

	self.show_time_tips = self:FindVariable("ShowNextTime")
	self.show_follow_icon = self:FindVariable("ShowFollowIcon")
	self.next_time_txt = self:FindVariable("NextTimeTips")
	self.show_panel = self:FindVariable("ShowPanel")
	self:ListenEvent("FollowGuard",
		BindTool.Bind(self.FollowGuard, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

end

function GuildMijingFightView:ReleaseCallBack()
	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function GuildMijingFightView:FollowGuard()
	GuildMijingCtrl.SendGetGuildFBGuardPos()
end

function GuildMijingFightView:OpenCallBack()
	MainUICtrl.Instance.view:SetViewState(false)
	self.show_time_tips:SetValue(false)
	self:Flush()
end

function GuildMijingFightView:CloseCallBack()
	MainUICtrl.Instance.view:SetViewState(true)
	GlobalTimerQuest:CancelQuest(self.next_countdown)
end

function GuildMijingFightView:MianUIOpenComlete()
	MainUICtrl.Instance.view:SetViewState(false)
	self:Flush()
end
function GuildMijingFightView:OnFlush(param_t)
	self.score_info:Flush()
	for k,v in pairs(param_t) do
		if k == "mijing_info" then
			for k1,v1 in pairs(v) do
				local mijing_info = v1
				if self.next_countdown then
					GlobalTimerQuest:CancelQuest(self.next_countdown)
				end
				if 1 == mijing_info.is_finish then
					self:LeaveCountDown()
					local seconds = mijing_info.kick_role_time - TimeCtrl.Instance:GetServerTime()
					self.show_time_tips:SetValue(seconds > 0)
					if seconds > 0 then
						self.next_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveCountDown, self), 1)
					end
					return
				elseif mijing_info.notify_reason == GuildFbNotifyReason.WAIT and mijing_info.next_wave_time > 0 then
					GlobalTimerQuest:CancelQuest(self.next_countdown)
					local seconds = mijing_info.next_wave_time - TimeCtrl.Instance:GetServerTime()
					self.show_time_tips:SetValue(seconds > 0)
					if seconds > 0 then
						self:OpenNextWaveCountDown()
						self.next_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OpenNextWaveCountDown, self), 1)
					end
				end
			end
		end

	end
end

function GuildMijingFightView:OpenNextWaveCountDown()
	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	local seconds = math.floor(mijing_info.next_wave_time - TimeCtrl.Instance:GetServerTime())
	if seconds <= 0 then
		GlobalTimerQuest:CancelQuest(self.next_countdown)
		self.show_time_tips:SetValue(false)
		return
	end
	self.next_time_txt:SetValue(string.format(Language.Guild.MijingTimeTip, seconds))
end

function GuildMijingFightView:LeaveCountDown()
	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	local seconds = math.floor(mijing_info.kick_role_time - TimeCtrl.Instance:GetServerTime())
	if seconds <= 0 then
		GlobalTimerQuest:CancelQuest(self.next_countdown)
		self.show_time_tips:SetValue(false)
		return
	end
	self.next_time_txt:SetValue(string.format(Language.Guild.MijingTimeTip2, seconds))
end

function GuildMijingFightView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
	-- if self.shrink_button_toggle and self:IsOpen() then
	-- 	self.shrink_button_toggle.isOn = not enable
	-- end
end

----------------------View----------------------
MijingScoreInfoView = MijingScoreInfoView or BaseClass(BaseRender)
function MijingScoreInfoView:__init()
	self.pass = self:FindVariable("Pass")
	self.monster_count = self:FindVariable("MonsterCount")
	self.guard_blood = self:FindVariable("GuardBlood")

	self:Flush()
end

function MijingScoreInfoView:__delete()

end

function MijingScoreInfoView:Flush()
	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	local max_wave = #ConfigManager.Instance:GetAutoConfig("guildfb_auto").wave_cfg
	local cur_wave = math.min((mijing_info.curr_wave + 1), max_wave)
	self.pass:SetValue(cur_wave .. "/" .. max_wave)
	self.monster_count:SetValue(mijing_info.wave_enemy_count)

	local rate = mijing_info.hp / mijing_info.max_hp
	if mijing_info.hp == 0 then
		rate = 0
	end
	local guard_blood = (rate - rate % 0.0001) * 100 .. "%"
	self.guard_blood:SetValue(guard_blood)
end
