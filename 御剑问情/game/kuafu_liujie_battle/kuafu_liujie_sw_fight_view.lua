KuaFuBossSwFightView = KuaFuBossSwFightView or BaseClass(BaseView)

function KuaFuBossSwFightView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab","KuaFuBossSwFightView"}
	self.active_close = false
	self.click_flag = false
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.info_event = BindTool.Bind(self.Flush, self)
	self.last_remind_time = 0
end

function KuaFuBossSwFightView:ReleaseCallBack()
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

	self:CanCelExitQuest()

	-- 清理变量和对象
	self.boss_btn = nil
	self.track_info = nil
	self.show_panel = nil
	self.time_text = nil
	self.show_boss_tab_hl = nil
	self.show_team_tab_hl = nil
	self.is_tired = nil
	self.exit_time = nil
end

function KuaFuBossSwFightView:LoadCallBack()
	self.boss_panel = KuFubossInfoView.New(self:FindObj("BossPanel"))
	self.team_panel = KuaFuBossTeamInfo.New(self:FindObj("TeamPanel"))
	self.boss_btn = self:FindObj("boss_btn")
	self.track_info = self:FindObj("track_info")
	self.show_panel = self:FindVariable("ShowPanel")
	self.time_text = self:FindVariable("time_text")
	self.show_boss_tab_hl = self:FindVariable("show_boss_tab_hl")
	self.show_team_tab_hl = self:FindVariable("show_team_tab_hl")
	self.is_tired = self:FindVariable("is_tired")
	self.exit_time = self:FindVariable("ExitTime")

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:ListenEvent("click_info", BindTool.Bind(self.ClickInfo, self))
	self:ListenEvent("click_boss", BindTool.Bind(self.ClickBoss, self))
	self:ListenEvent("click_team", BindTool.Bind(self.ClickTeam, self))
	self:Flush()
end

function KuaFuBossSwFightView:ClickInfo()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush("team_type")
		self:FlushTabHl(false)
	else
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
end

function KuaFuBossSwFightView:ClickBoss()
	self.click_flag = false
	self.boss_panel:Flush()
	self:FlushTabHl(true)
end

function KuaFuBossSwFightView:CloseCallBack()
	local boss_type = BossData.Instance:GetBossType()
	-- if BossData.Instance then
	-- 	BossData.Instance:RemoveListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
	-- end

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

function KuaFuBossSwFightView:FlushTabHl(show_boss)
	self.show_boss_tab_hl:SetValue(show_boss)
	self.show_team_tab_hl:SetValue(not show_boss)
end

function KuaFuBossSwFightView:OpenCallBack()
	local data = KuafuGuildBattleData.Instance
	-- local boss_type = BossData.Instance:GetBossType()
	-- self.main_role_do_hit = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_DO_HIT,
	-- 	BindTool.Bind(self.MainRoleDoHit, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self.boss_panel:Flush()
	local info = nil
	-- if boss_type == BOSS_TYPE.FAMILY_BOSS then
	local scene_id = Scene.Instance:GetSceneId()
	info = data:GetSwSceneList(scene_id)
	self:Flush("open_flush")
	if info then
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(info.scene_id)
		local cfg = data:GetLayerSwBossList(info.scene_id)
		for _,v in ipairs(cfg) do
			data:RegMonsterXY(scene_cfg, v.monster_id)
		end
		-- MoveCache.end_type = MoveEndType.Auto
		-- GuajiCtrl.Instance:MoveToPos(info.scene_id, info.enter_pos_x, info.enter_pos_y, 10, 10)
	end
	self:Flush("team_type")
	self:Flush("exit_time")
end

function KuaFuBossSwFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function KuaFuBossSwFightView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	self.show_panel:SetValue(state)
end

function KuaFuBossSwFightView:OnFlush(param_t)
	-- local boss_type = BossData.Instance:GetBossType()
	self.boss_panel:SetCurIndex(0)
	for k,v in pairs(param_t) do
		if k == "boss_type" then
			-- BossData.Instance:AddListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
			self.boss_panel:Flush()
		elseif k == "team_type" then
			self.team_panel:Flush()
		elseif k == "open_flush" then
			self.boss_btn.toggle.isOn = true
			self:FlushTabHl(true)
		elseif k == "elite" then
			self:RefreshEliteDes()
		elseif k == "exit_time" then
			self:FlushExitTime()
		else
			self.boss_panel:Flush()
		end
	end
	self.is_tired:SetValue(KuafuGuildBattleData.Instance:Istired())
end

function KuaFuBossSwFightView:SwitchButtonState(enable)
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end

function KuaFuBossSwFightView:FlushExitTime()
	self.exit_time:SetValue("")
	local time_stamp = KuafuGuildBattleData.Instance:GetShenWuBossSceneEndTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local diff = time_stamp - server_time
	if diff > 0 then
		if not self.exit_time_count then
			self.exit_time_count = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateExitTime, self), 0.5)
		end
	else
		self:CanCelExitQuest()
	end
	self:UpdateExitTime()
end

function KuaFuBossSwFightView:UpdateExitTime()
	local time_stamp = KuafuGuildBattleData.Instance:GetShenWuBossSceneEndTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local diff = time_stamp - server_time
	self.exit_time:SetValue("")
	if diff > 0 then
		if diff <= 1800 then
			local time = TimeUtil.FormatSecond(diff, 4)
			self.exit_time:SetValue(string.format(Language.Boss.ShenWuBossFightViewCountDown, time))
		end
	else
		self:CanCelExitQuest()
	end
end

function KuaFuBossSwFightView:CanCelExitQuest()
	if self.exit_time_count then
		GlobalTimerQuest:CancelQuest(self.exit_time_count)
		self.exit_time_count = nil
	end
end

function KuaFuBossSwFightView:ClickTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

------------------------领主boss----------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
KuFubossInfoView = KuFubossInfoView or BaseClass(BaseRender)
function KuFubossInfoView:__init()
	-- 获取控件
	self.list_view = self:FindObj("TaskList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self:Flush()
end

function KuFubossInfoView:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function KuFubossInfoView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function KuFubossInfoView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BossKfBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function KuFubossInfoView:GetDataList()
	return KuafuGuildBattleData.Instance:GetLayerSwBossList(Scene.Instance:GetSceneId())
end

function KuFubossInfoView:SetCurIndex(index)
	self.cur_index = index
end

function KuFubossInfoView:GetCurIndex()
	return self.cur_index
end

function KuFubossInfoView:Flush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuFubossInfoView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

------------------------------------------------------------------------
------------------BossKfBossItem-------------------------------------
------------------------------------------------------------------------
BossKfBossItem = BossKfBossItem or BaseClass(BaseRender)

function BossKfBossItem:__init(instance, parent)
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

function BossKfBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end

	self.parent = nil
end

function BossKfBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	local boss_xy = KuafuGuildBattleData.Instance:GetBossXY(self.data.monster_id)
	if boss_xy then
		GuajiCtrl.Instance:MoveToPos(self.data.scene_id, boss_xy.x, boss_xy.y, 0, 0)
	end
	self.parent:FlushAllHl()
	return
end

function BossKfBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function BossData:GetFamilyBossInfo(scene_id)
    return self.family_boss_list.boss_list[scene_id]
end

function BossKfBossItem:SetItemIndex(index)
	self.index = index
end

function BossKfBossItem:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
	if monster_cfg then
		if 3 == monster_cfg.boss_type then
			self.name:SetValue(ToColorStr(monster_cfg.name,TEXT_COLOR.YELLOW))
		else
			self.name:SetValue(monster_cfg.name)
		end
		self.level_text:SetValue(monster_cfg.level)
	end
	local boss_data =  KuafuGuildBattleData.Instance:GetBossStatusByBossId(self.data.scene_id, self.data.monster_id)
	if boss_data then
		self.time_color:SetValue("#00ff90")
		self.next_refresh_time = boss_data.next_refresh_timestamp
		if boss_data.status == 1 then
			if self.time_coundown then
				GlobalTimerQuest:CancelQuest(self.time_coundown)
				self.time_coundown = nil
				self.time:SetValue(Language.Dungeon.CanKill)
			end
			self.time:SetValue(Language.Dungeon.CanKill)
		else
			self.time_color:SetValue("#ff3838")
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			end
			self:OnBossUpdate()
		end
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(Language.Dungeon.CanKill)
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	local boss_xy = KuafuGuildBattleData.Instance:GetBossXY(self.data.monster_id)
	if scene_cfg and boss_xy then
		self.desc:SetValue("(" .. boss_xy.x .. "," .. boss_xy.y .. ")")
	end

	self:FlushHl()
end

function BossKfBossItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function BossKfBossItem:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time:SetValue(Language.Dungeon.CanKill)
		self.time_color:SetValue("#00ff90")
	else
		self.time:SetValue(TimeUtil.FormatSecond(time))
		self.time_color:SetValue("#ff3838")
	end
end

--组队------------------------------------
------------------------------------------
------------------------------------------
KuaFuBossTeamInfo = KuaFuBossTeamInfo or BaseClass(BaseRender)
function KuaFuBossTeamInfo:__init()
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

function KuaFuBossTeamInfo:__delete()
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

function KuaFuBossTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function KuaFuBossTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossKfTeamCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function KuaFuBossTeamInfo:OnChangeScene()
	self:Flush()
end

function KuaFuBossTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function KuaFuBossTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function KuaFuBossTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 2
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function KuaFuBossTeamInfo:OnFlush()
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

function KuaFuBossTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function KuaFuBossTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function KuaFuBossTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end
---------------------------------------------------------------
BossKfTeamCell = BossKfTeamCell or BaseClass(BaseCell)
function BossKfTeamCell:__init(instance, parent)
	self.parent = parent
	self.role_name = self:FindVariable("Name")
	self.level_text = self:FindVariable("LevelText")
	self.menber_state = self:FindVariable("MenberState")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function BossKfTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossKfTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.role_name:SetValue(self.data.name)
	self.level_text:SetValue(Language.Mainui.Level3 .. self.data.level)
	self.menber_state:SetValue(member_state)

end

function BossKfTeamCell:ClickItem()
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

function BossKfTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.show_hl:SetValue(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end