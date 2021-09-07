require("game/boss/boss_team_view")

BossFamilyFightView = BossFamilyFightView or BaseClass(BaseView)

function BossFamilyFightView:__init()
	self.ui_config = {"uis/views/bossview","BossFamilyFightView"}
	self.active_close = false
	self.click_flag = false
	self.view_layer = UiLayer.MainUILow
	self.info_event = BindTool.Bind(self.Flush, self)
	self.last_remind_time = 0
	self.is_safe_area_adapter = true
end

function BossFamilyFightView:ReleaseCallBack()
	FunctionGuide.Instance:DelWaitGuideListByName("BoosKill")
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	if self.boss_panel then
		self.boss_panel:DeleteMe()
		self.boss_panel = nil
	end

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.BossFamilyInfoView)
	end

	-- 清理变量和对象
	self.boss_btn = nil
	self.track_info = nil
	self.show_panel = nil
	self.time_text = nil
	self.show_boss_tab_hl = nil
	self.show_team_tab_hl = nil
	self.boss_panel_obj = nil
end

function BossFamilyFightView:LoadCallBack()
	self.boss_panel_obj = self:FindObj("BossPanel")
	self.boss_panel = BossFamilybossView.New(self.boss_panel_obj)
	self.team_panel = BossFamilyTeamInfo.New(self:FindObj("TeamPanel"))
	self.boss_btn = self:FindObj("boss_btn")
	self.track_info = self:FindObj("track_info")
	self.show_panel = self:FindVariable("ShowPanel")
	self.time_text = self:FindVariable("time_text")
	self.show_boss_tab_hl = self:FindVariable("show_boss_tab_hl")
	self.show_team_tab_hl = self:FindVariable("show_team_tab_hl")

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:ListenEvent("click_info", BindTool.Bind(self.ClickInfo, self))
	self:ListenEvent("click_boss", BindTool.Bind(self.ClickBoss, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.BossFamilyInfoView, BindTool.Bind(self.GetUiCallBack, self))

	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("BoosKill")
	self:Flush()
end

function BossFamilyFightView:ClickInfo()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush("team_type")
		self:FlushTabHl(false)
	else
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
end

function BossFamilyFightView:ClickBoss()
	self.click_flag = false
	self.boss_panel:Flush()
	self:FlushTabHl(true)
end

function BossFamilyFightView:CloseCallBack()
	local boss_type = BossData.Instance:GetBossType()
	if BossData.Instance then
		local listener_str = BossData.FAMILY_BOSS
		if boss_type == BOSS_TYPE.MIKU_BOSS then
			listener_str = BossData.MIKU_BOSS
		elseif boss_type == BOSS_TYPE.NEUTRAL_BOSS then
			listener_str = BossData.NEUTRAL_BOSS
		elseif boss_type == BOSS_TYPE.BABY_BOSS then
			listener_str = BossData.BABY_BOSS
		end
		BossData.Instance:RemoveListener(listener_str, self.info_event)
	end

	if self.main_role_do_hit then
		GlobalEventSystem:UnBind(self.main_role_do_hit)
		self.main_role_do_hit = nil
	end

	if self.root_node.gameObject.activeSelf and self.track_info.gameObject.activeSelf then
		self.boss_btn.toggle.isOn = true
		self:FlushTabHl(true)
	end
	self.click_flag = false
end

function BossFamilyFightView:FlushTabHl(show_boss)
	self.show_boss_tab_hl:SetValue(show_boss)
	self.show_team_tab_hl:SetValue(not show_boss)
end

function BossFamilyFightView:OpenCallBack()
	local boss_data = BossData.Instance
	local boss_type = boss_data:GetBossType()
	self.main_role_do_hit = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_DO_HIT,
		BindTool.Bind(self.MainRoleDoHit, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self.boss_panel:Flush()
	local info = nil
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
	elseif boss_type == BOSS_TYPE.MIKU_BOSS then
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	elseif boss_type == BOSS_TYPE.NEUTRAL_BOSS then
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL)
	elseif boss_type == BOSS_TYPE.BABY_BOSS then
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.BOSS_ENTER_TYPE)
	end
	self:Flush("open_flush")
	if info and not FunctionGuide.Instance:GetIsGuide() then
		if boss_data:GetAutoComeFlag() then
			MoveCache.end_type = MoveEndType.Normal
			boss_data:SetAutoComeFlag(false)
		else
			MoveCache.end_type = MoveEndType.Auto
		end
		GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 10, 10, nil, nil, true)
		boss_data:SetCurInfo(0, 0)
	end
	self:Flush("team_type")
end

function BossFamilyFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function BossFamilyFightView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	self.show_panel:SetValue(state)
end

function BossFamilyFightView:OnFlush(param_t)
	local boss_type = BossData.Instance:GetBossType()
	self.boss_panel:SetCurIndex(0)
	for k,v in pairs(param_t) do
		if k == "boss_type" then
			local listener_str = BossData.FAMILY_BOSS
			if boss_type == BOSS_TYPE.MIKU_BOSS then
				listener_str = BossData.MIKU_BOSS
			elseif boss_type == BOSS_TYPE.NEUTRAL_BOSS then
				listener_str = BossData.NEUTRAL_BOSS
			elseif boss_type == BOSS_TYPE.BABY_BOSS then
				listener_str = BossData.BABY_BOSS
			end
			BossData.Instance:AddListener(listener_str, self.info_event)
			self.boss_panel:Flush()
		elseif k == "team_type" then
			self.team_panel:Flush()
		elseif k == "open_flush" then
			self.boss_btn.toggle.isOn = true
			self:FlushTabHl(true)
		else
			self.boss_panel:Flush()
		end
	end
end

function BossFamilyFightView:SwitchButtonState(enable)
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end

function BossFamilyFightView:MainRoleDoHit(obj, damage)
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.MIKU_BOSS then
		if damage >= 0 then
			local miku_boss_weary = BossData.Instance:GetMikuBossWeary() or 0
			local weary_upper_limit = BossData.Instance:GetMikuBossMaxWeary() or 0
			if miku_boss_weary >= weary_upper_limit then
				if self.last_remind_time + 5 <= Status.NowTime then
					self.last_remind_time = Status.NowTime
					SysMsgCtrl.Instance:ErrorRemind(Language.Boss.MiKuWeary, 0.5)
				end
			end
		end
	end
end

function BossFamilyFightView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		else
			return NextGuideStepFlag
		end
	else
		if ui_name == GuideUIName.BoosKill then
			return self.boss_panel_obj
		end
	end
end
------------------------领主boss----------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
BossFamilybossView = BossFamilybossView or BaseClass(BaseRender)
function BossFamilybossView:__init()
	-- 获取控件
	self.list_view = self:FindObj("TaskList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self:Flush()
end

function BossFamilybossView:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function BossFamilybossView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function BossFamilybossView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BossFamilyBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function BossFamilybossView:GetDataList()
	local role_vo_camp = PlayerData.Instance:GetRoleVo().camp
	local scene_id = Scene.Instance:GetSceneId()
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		return BossData.Instance:GetBossFamilyList(scene_id)
	elseif boss_type == BOSS_TYPE.MIKU_BOSS then
		return BossData.Instance:GetMikuBossList(scene_id - (role_vo_camp * 4 - 4))
	elseif boss_type == BOSS_TYPE.BABY_BOSS then
		return BossData.Instance:GetBossBabyList(scene_id)
	else
		return BossData.Instance:GetNeutralBossList(scene_id)
	end
end

function BossFamilybossView:SetCurIndex(index)
	self.cur_index = index
end

function BossFamilybossView:GetCurIndex()
	return self.cur_index
end

function BossFamilybossView:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossFamilybossView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end
------------------------------------------------------------------------
------------------BossFamilyBossItem-------------------------------------
------------------------------------------------------------------------
BossFamilyBossItem = BossFamilyBossItem or BaseClass(BaseRender)

function BossFamilyBossItem:__init(instance, parent)
	self.parent = parent
	self.desc = self:FindVariable("Desc")
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.show_hl = self:FindVariable("show_hl")
	self.time_color = self:FindVariable("TimeColor")
	self.level_text = self:FindVariable("Level")
	self.index = 0
	self.next_refresh_time = 0
	self:ListenEvent("Click", BindTool.Bind(self.ClickKill, self))
end

function BossFamilyBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BossFamilyBossItem:ClickKill(is_click)
	if self.data == nil then return end
	local main_role = Scene.Instance:GetMainRole()
	if main_role ~= nil and main_role:IsMultiMountPartner() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.MultiNoMove)
		return
	end

	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 10, 10, nil, nil, true)
	self.parent:FlushAllHl()
	return
end

function BossFamilyBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function BossFamilyBossItem:GetBossData(boss_id)
	local boss_info = nil
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		boss_info = BossData.Instance:GetFamilyBossInfo(self.data.scene_id)
	elseif boss_type == BOSS_TYPE.MIKU_BOSS then
		boss_info = BossData.Instance:GetMikuBossInfoList(self.data.scene_id)
	elseif boss_type == BOSS_TYPE.BABY_BOSS then
		boss_info = BossData.Instance:GetBossBabyInfo(self.data.scene_id)
	else
		boss_info = BossData.Instance:GetNeutralBossScene(self.data.scene_id)
	end
	if boss_info == nil then
		return nil
	end
	for k,v in pairs(boss_info) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function BossFamilyBossItem:SetItemIndex(index)
	self.index = index
end

function BossFamilyBossItem:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID or self.data.boss_id or self.data.monster_id]
	if monster_cfg then
		self.name:SetValue(monster_cfg.name)
		self.level_text:SetValue(monster_cfg.level)
	end
	local boss_data = self:GetBossData(self.data.bossID or self.data.boss_id or self.data.monster_id)
	if boss_data then
		self.time_color:SetValue(boss_data.status == 1 and TEXT_COLOR.GREEN_3 or "#ff0000ff")
		self.next_refresh_time = boss_data.next_refresh_time
		if boss_data.status == 1 then
			if self.time_coundown then
				GlobalTimerQuest:CancelQuest(self.time_coundown)
				self.time_coundown = nil
				self.time:SetValue(Language.Dungeon.CanKill)
			end
			self.time:SetValue(Language.Dungeon.CanKill)
		else
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			end
			self:OnBossUpdate()
		end
	else
		self.time_color:SetValue(TEXT_COLOR.GREEN_3)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(Language.Dungeon.CanKill)
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	if scene_cfg then
		self.desc:SetValue(scene_cfg.name .. "(" .. self.data.born_x .. "," .. self.data.born_y .. ")")
	end

	self:FlushHl()
end

function BossFamilyBossItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function BossFamilyBossItem:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time:SetValue(ToColorStr(Language.Dungeon.CanKill, TEXT_COLOR.GREEN))
	else
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, time > 3600 and 3 or 2), TEXT_COLOR.RED))
	end
end