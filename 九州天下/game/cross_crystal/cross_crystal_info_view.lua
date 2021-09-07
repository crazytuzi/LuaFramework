
CrossCrystalInfoView = CrossCrystalInfoView or BaseClass(BaseView)

function CrossCrystalInfoView:__init()
	self.ui_config = {"uis/views/crosscrystalview","CrossCrystalInfoView"}
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
end

function CrossCrystalInfoView:__delete()

end

function CrossCrystalInfoView:LoadCallBack()
	self.score_info = CrossCrystalScoreInfoView.New(self:FindObj("ScorePerson"))
	self.shrink_button_toggle = self:FindObj("ShrinkButton").toggle
	self.task_parent = self:FindObj("TaskParent")
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.CrossCrystalInfoView, BindTool.Bind(self.GetUiCallBack, self))

	if self.listen_role == nil then
		self.listen_role = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_APPERANCE_CHANGE, BindTool.Bind(self.RoleBuffShow, self))
	end
end

function CrossCrystalInfoView:RoleBuffShow()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ()
			local main_role = Scene.Instance:GetMainRole()
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role and role_vo then
				main_role:SetBuffList(bit:ll2b(role_vo.buff_mark_high, role_vo.buff_mark_low))
			end
	end, 2)
end

function CrossCrystalInfoView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.CrossCrystalInfoView)
	end

	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.listen_role ~= nil then
		GlobalEventSystem:UnBind(self.listen_role)
		self.listen_role = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	self.shrink_button_toggle = nil
	self.task_parent = nil

	self.cross_crystal_gather_btn = nil
end

function CrossCrystalInfoView:OpenCallBack()
	local info = CrossCrystalData.Instance:GetCrystalInfo()
	if info.next_time ~= 0 then
		FuBenCtrl.Instance:SetCountDownByTotalTime(info.next_time - TimeCtrl.Instance:GetServerTime())
	end
	MainUICtrl.Instance.view:SetViewState(false)
	CrossCrystalData.Instance:SetSelectGatherType(0)
	self:Flush()
end

function CrossCrystalInfoView:CloseCallBack()
	MainUICtrl.Instance.view:SetViewState(true)
end

function CrossCrystalInfoView:ActivityCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.SHUIJING then
		if status == ACTIVITY_STATUS.OPEN then
			FuBenCtrl.Instance:SetCountDownByTotalTime(next_time - TimeCtrl.Instance:GetServerTime())
		else
			FuBenCtrl.Instance:SetCountDownByTotalTime(0)
		end
	end
end

function CrossCrystalInfoView:MianUIOpenComlete()
	MainUICtrl.Instance.view:SetViewState(false)
	self:Flush()
end

function CrossCrystalInfoView:OnFlush(param_t)
	self.score_info:Flush()
end

function CrossCrystalInfoView:SwitchButtonState(enable)
	-- if self.shrink_button_toggle and self:IsOpen() then
	-- 	self.shrink_button_toggle.isOn = not enable
	-- end
	self.task_parent:SetActive(enable)
end

function CrossCrystalInfoView:ClearSelectGatherType()
	if self.score_info then
		self.score_info:ClearSelectGatherType()
	end
end

-- 得到引导用按钮
function CrossCrystalInfoView:GetGuideBtn()
	if self.score_info then
		local btn = self.score_info:GetGuideBtn()
		if btn then
			return btn
		end
	end
	return nil
end

-- 引导
function CrossCrystalInfoView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	else
		self.cross_crystal_gather_btn = self:GetGuideBtn()
	end
end

----------------------View----------------------
CrossCrystalScoreInfoView = CrossCrystalScoreInfoView or BaseClass(BaseRender)

local Gather_Type = {
	Small = 1,
	Middle = 2,
	Big = 3,
	Super = 4,
}

function CrossCrystalScoreInfoView:__init()
	self.count = self:FindVariable("Count")
	self.buff_time = self:FindVariable("BuffTime")
	self.super_crystal = self:FindVariable("SuperCrystal")
	self.two_time = self:FindVariable("TwoTime")
	self.is_show_effect = self:FindVariable("ShowEffect")

	self.guide_button = self:FindObj("GuideButton")
	self.select_img = {}
	self.rest_count = {}
	self:ListenEvent("BuyBuff", BindTool.Bind(self.BuyBuff, self))
	for i = 1, 4 do
		self:ListenEvent("Gather" .. i, BindTool.Bind(self.ClickIconGather, self, i))
		self.select_img[i] = self:FindVariable("SelectImg"..i)
		self.rest_count[i] = self:FindVariable("RestCount"..i)
	end

	if self.move_by_click == nil then
		self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	end

	if self.guaji_type == nil then
		self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))
	end

	if self.role_revive == nil then
		self.role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind1(self.OnMainRoleRevive, self))
	end
end

function CrossCrystalScoreInfoView:__delete()
	self:ClearCountdown()

	if self.move_by_click then
		GlobalEventSystem:UnBind(self.move_by_click)
		self.move_by_click = nil
	end

	if self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end

	if self.role_revive then
		GlobalEventSystem:UnBind(self.role_revive)
		self.role_revive = nil
	end

	if self.delay_revive_gather then
		GlobalTimerQuest:CancelQuest(self.delay_revive_gather)
		self.delay_revive_gather = nil
	end
end

function CrossCrystalScoreInfoView:OnMainRoleRevive()
	if self.delay_revive_gather == nil then
		self.delay_revive_gather = GlobalTimerQuest:AddDelayTimer(function ()
			self:ReviveGoToGather()
		end, 3)
	end
end

function CrossCrystalScoreInfoView:ReviveGoToGather()
	local crystal_info = CrossCrystalData.Instance:GetCrystalInfo()
	if crystal_info and next(crystal_info) then
		local gather_time = crystal_info.cur_gather_times or 0
		local select_gather_type = CrossCrystalData.Instance:GetSelectGatherType()
		if gather_time > 0 and select_gather_type ~= 0 then
			local gather = CrossCrystalData.Instance:GetGatherPos(select_gather_type)
			if gather and next(gather) then
				self:GoToGather(gather)
			end
		end
	end
	if self.delay_revive_gather then
		GlobalTimerQuest:CancelQuest(self.delay_revive_gather)
		self.delay_revive_gather = nil
	end
end

function CrossCrystalScoreInfoView:OnMoveByClick()
	self:ClearSelectGatherType()
end

function CrossCrystalScoreInfoView:OnGuajiTypeChange(guaji_type)
	if guaji_type ~= GuajiType.None then
		self:ClearSelectGatherType()
	end
end

function CrossCrystalScoreInfoView:ClearSelectGatherType()
	if CrossCrystalData.Instance:GetSelectGatherType() ~= 0 then
		CrossCrystalData.Instance:SetSelectGatherType(0)
	end
end

function CrossCrystalScoreInfoView:BuyBuff()
	local crystal_info =  CrossCrystalData.Instance:GetCrystalInfo()
	if crystal_info.gather_buff_time > TimeCtrl.Instance:GetServerTime() then
		TipsCtrl.Instance:ShowSystemMsg(Language.CrossCrystal.RemindingBuyShiJian)
	else
		local func = function()
			CrossCrystalCtrl.Instance:OnShuijingBuyBuff()
		end
		local other_cfg = CrossCrystalData.Instance:GetOtherConfig()
		local time_tab = TimeUtil.Format2TableDHM(other_cfg.gather_buff_time)
		TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.CrossCrystal.BuyBuffTips, other_cfg.gather_buff_gold))
	end
end

function CrossCrystalScoreInfoView:ClickIconGather(gather_type)
	CrossCrystalData.Instance:SetSelectGatherType(gather_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	for i = 1, 4 do
		self.select_img[i]:SetValue(i == gather_type)
	end
	local gather = CrossCrystalData.Instance:GetGatherPos(gather_type)
	if not gather or not next(gather) then 
		if gather_type == Gather_Type.Super then
			if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.SHUIJING) then
				TipsCtrl.Instance:ShowSystemMsg(Language.CrossCrystal.NoSuperCrystalRemind)
				return
			end
		end
		TipsCtrl.Instance:ShowSystemMsg(Language.CrossCrystal.NoGatherRemind[gather_type])
		return 
	end
	self:GoToGather(gather)
end

function CrossCrystalScoreInfoView:GoToGather(gather)
	local new_gather_pos = CrossCrystalData.Instance:GetMinDistancePosList(gather)
	if new_gather_pos and next(new_gather_pos) then
		MoveCache.param1 = new_gather_pos[1].gather_id
		MoveCache.end_type = MoveEndType.GatherById
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), new_gather_pos[1].x, new_gather_pos[1].y, 4, 2)
	end
end

function CrossCrystalScoreInfoView:OnFlush()
	local crystal_info = CrossCrystalData.Instance:GetCrystalInfo()
	if crystal_info and next(crystal_info) then
		local gather_time = crystal_info.cur_gather_times or 0
		local des = ToColorStr(tostring(gather_time > 0 and gather_time or 0), gather_time > 0 and TEXT_COLOR.GREEN_5 or TEXT_COLOR.RED)
		self.count:SetValue(des)
		-- 超级采集物计时
		self:ClearCountdown()
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.SHUIJING) then
			self.two_time:SetValue(Language.Activity.KaiQiZhong)
			local seconds = crystal_info.next_big_shuijing_refresh_timestamp - TimeCtrl.Instance:GetServerTime()
			if seconds > 0 then
				self.crystal_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SuperCrystalCountDown, self, crystal_info), 0)
			else
				self.super_crystal:SetValue(Language.CrossCrystal.SuperCrystalCount)
			end
		else
			self.two_time:SetValue(Language.Activity.YiJieShu)
			self.super_crystal:SetValue("")
		end
		-- buff计时
		local seconds = crystal_info.gather_buff_time - TimeCtrl.Instance:GetServerTime()
		if seconds > 0 then
			self.buff_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.BuffTimeCountDown, self, crystal_info), 0)
		else
			self.buff_time:SetValue("")
		end
		self.is_show_effect:SetValue(seconds <= 0)

		-- 采集物信息
		local count_list = CrossCrystalData.Instance:GetCrystalCountList()
		for i = 1, 4 do
			self.rest_count[i]:SetValue(count_list[i])
		end

		local select_gather_type = CrossCrystalData.Instance:GetSelectGatherType()
		if gather_time > 0 and select_gather_type ~= 0 then
			local gather = CrossCrystalData.Instance:GetGatherPos(select_gather_type)
			if gather and next(gather) then
				self:GoToGather(gather)
			end
		end
	end
end

function CrossCrystalScoreInfoView:ClearCountdown()
	if self.crystal_countdown then
		GlobalTimerQuest:CancelQuest(self.crystal_countdown)
		self.crystal_countdown = nil
	end

	if self.buff_countdown then
		GlobalTimerQuest:CancelQuest(self.buff_countdown)
		self.buff_countdown = nil
	end
end

function CrossCrystalScoreInfoView:BuffTimeCountDown(crystal_info)
	local seconds = crystal_info.gather_buff_time - TimeCtrl.Instance:GetServerTime()
	if seconds < 0 then
		GlobalTimerQuest:CancelQuest(self.buff_countdown)
		self.buff_countdown = nil
		self:Flush()
		return
	end
	self.buff_time:SetValue(TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2))
end

function CrossCrystalScoreInfoView:SuperCrystalCountDown(crystal_info)
	local seconds = crystal_info.next_big_shuijing_refresh_timestamp - TimeCtrl.Instance:GetServerTime()
	if seconds < 0 then
		GlobalTimerQuest:CancelQuest(self.crystal_countdown)
		self.crystal_countdown = nil
		self:Flush()
		return
	end
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.SHUIJING) then
		self:Flush()
		return
	end
	local time = TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2)
	self.super_crystal:SetValue(string.format(Language.CrossCrystal.SuperCrystalReflush, time))
end

-- 得到引导用按钮
function CrossCrystalScoreInfoView:GetGuideBtn()
	if self.guide_button then
		return self.guide_button
	end
	return nil
end