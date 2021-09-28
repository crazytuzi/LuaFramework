BossFamilyFightView = BossFamilyFightView or BaseClass(BaseView)

function BossFamilyFightView:__init()
	self.ui_config = {"uis/views/bossview_prefab","BossFamilyFightView"}
	self.active_close = false
	self.click_flag = false
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.info_event = BindTool.Bind(self.Flush, self)
	self.last_remind_time = 0
end

function BossFamilyFightView:ReleaseCallBack()
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

	-- 清理变量和对象
	self.boss_btn = nil
	self.track_info = nil
	self.show_panel = nil
	self.time_text = nil
	self.show_boss_tab_hl = nil
	self.show_team_tab_hl = nil
end

function BossFamilyFightView:LoadCallBack()
	self.boss_panel = BossFamilybossView.New(self:FindObj("BossPanel"))
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
		BossData.Instance:RemoveListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
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
	local boss_type = BossData.Instance:GetBossType()
	self.main_role_do_hit = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_DO_HIT,
		BindTool.Bind(self.MainRoleDoHit, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self.boss_panel:Flush()
	local info = nil
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
	else
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	end
	self:Flush("open_flush")
	if info then
		if boss_data:GetAutoComeFlag() then
			MoveCache.end_type = MoveEndType.Normal
			boss_data:SetAutoComeFlag(false)
		else
			MoveCache.end_type = MoveEndType.Auto
		end
		GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 10, 10)
		BossData.Instance:SetCurInfo(0, 0)
	else
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
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
			BossData.Instance:AddListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
			self.boss_panel:Flush()
		elseif k == "team_type" then
			self.team_panel:Flush()
		elseif k == "open_flush" then
			self.boss_btn.toggle.isOn = true
			self:FlushTabHl(true)
		elseif k == "elite" then
			self:RefreshEliteDes()
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
	local scene_id = Scene.Instance:GetSceneId()
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		return BossData.Instance:GetBossFamilyList(scene_id)
	else
		return BossData.Instance:GetMikuBossList(scene_id)
	end
end

function BossFamilybossView:SetCurIndex(index)
	self.cur_index = index
end

function BossFamilybossView:GetCurIndex()
	return self.cur_index
end

function BossFamilybossView:Flush()
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
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 10, 10)
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
	else
		boss_info = BossData.Instance:GetMikuBossInfoList(self.data.scene_id)
	end
	if boss_info then
		for k,v in pairs(boss_info) do
			if v.boss_id == boss_id then
				return v
			end
		end
	end
	return nil
end

function BossFamilyBossItem:SetItemIndex(index)
	self.index = index
end

function BossFamilyBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		if 3 == monster_cfg.boss_type then
			self.name:SetValue(ToColorStr(monster_cfg.name,TEXT_COLOR.YELLOW))
		else
			self.name:SetValue(monster_cfg.name)
		end
		self.level_text:SetValue(monster_cfg.level)
	end
	local boss_data = self:GetBossData(self.data.bossID)
	if boss_data then
		self.time_color:SetValue("#00ff90")
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
		self.time_color:SetValue("#00ff90")
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
		self.time:SetValue(Language.Dungeon.CanKill)
	else
		self.time:SetValue(TimeUtil.FormatSecond(time))
	end
end

--组队------------------------------------
------------------------------------------
------------------------------------------
BossFamilyTeamInfo = BossFamilyTeamInfo or BaseClass(BaseRender)
function BossFamilyTeamInfo:__init()
	self.star_gray_list = {}
	self.team_cells = {}
	for i=1,3 do
		self.star_gray_list[i] = self:FindVariable("star_gray_" .. i)
	end

	self.add_exp_text = self:FindVariable("add_exp_text")
	self.show_add_exp = self:FindVariable("show_add_exp")
	self.show_exit_btn = self:FindVariable("show_exit_btn")
	self.show_create_team = self:FindVariable("show_create_team")
	self:ListenEvent("Exit_Click", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("OpenTeam", BindTool.Bind(self.OpenTeam, self))
	self:ListenEvent("CreateTeam", BindTool.Bind(self.CreateTeam, self))
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.contain_cell_list = {}
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function BossFamilyTeamInfo:__delete()
	self.add_exp_text = nil
	self.show_add_exp = nil
	self.show_exit_btn = nil
	self.show_create_team = nil
	for i=1,3 do
		self.star_gray_list[i] = nil
	end
	self.team_cells = {}
	self.star_gray_list = {}

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function BossFamilyTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossFamilyTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossFamilyTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossFamilyTeamInfo:OnChangeScene()
	self:Flush()
end

function BossFamilyTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossFamilyTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossFamilyTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 2
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossFamilyTeamInfo:OnFlush()
	self.team_list = ScoietyData.Instance:GetMemberList()
	self.show_create_team:SetValue(not next(self.team_list))
	for i=1,3 do
		self.star_gray_list[i]:SetValue(i <= #self.team_list and self.team_list[i].is_online == 1)
	end
	self.show_add_exp:SetValue(#self.team_list > 0)
	self.add_exp_text:SetValue(ScoietyData.Instance:GetTeamExp(self.team_list))
	self.show_exit_btn:SetValue(#self.team_list > 0)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function BossFamilyTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossFamilyTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossFamilyTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end
---------------------------------------------------------------
BossFamilyTeamCell = BossFamilyTeamCell or BaseClass(BaseCell)
function BossFamilyTeamCell:__init()
	self.role_name = self:FindVariable("Name")
	self.level_text = self:FindVariable("LevelText")
	self.menber_state = self:FindVariable("MenberState")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function BossFamilyTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossFamilyTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.role_name:SetValue(self.data.name)
	self.level_text:SetValue(Language.Mainui.Level3 .. self.data.level)
	self.menber_state:SetValue(member_state)

end

function BossFamilyTeamCell:ClickItem()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if main_role_id == self.data.role_id then
		self.show_hl:SetValue(false)
		return
	end

	self.parent:SetSelectIndex(self.index)
	self.parent:FlushAllHl()

	local function canel_callback()
		if self.root_node then
			self.show_hl:SetValue(false)
		end
	end

	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
end

function BossFamilyTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.show_hl:SetValue(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end