KuaFuBossTjFightView = KuaFuBossTjFightView or BaseClass(BaseView)

function KuaFuBossTjFightView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab","KuaFuBossTjFightView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.item_t = {}
	self.boss_xy = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
	self.is_boss = true
end

function KuaFuBossTjFightView:__delete()

end

function KuaFuBossTjFightView:ReleaseCallBack()
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
	self.item_t = {}

	self:StopTimeQuest()

	-- 清理变量和对象
	self.anger = nil
	self.show_panel = nil
	self.time = nil
	self.slider = nil
	self.show_limit = nil
	self.list_view = nil
	self.max_anger = nil
	self.name = nil
	self.is_count = nil
end

function KuaFuBossTjFightView:LoadCallBack()
	self.anger = self:FindVariable("Anger")
	-- BossData.Instance:AddListener(BossData.ACTIVE_BOSS, self.dabao_info_event)
	self.show_panel = self:FindVariable("ShowPanel")
	self.time = self:FindVariable("time")
	self.slider = self:FindVariable("slider")
	self.show_limit = self:FindVariable("show_limit")
	self.max_anger = self:FindVariable("max_anger")
	self.name = self:FindVariable("name")
	self.is_count = self:FindVariable("is_count")
	self.max_anger:SetValue(KuafuGuildBattleData.Instance:GetActiveMaxValue(Scene.Instance:GetSceneId()))
	self.name:SetValue(Language.KuafuGuildBattle.KfName1)
	self:ListenEvent("boss_click", BindTool.Bind(self.BossClick, self))
	self:ListenEvent("boss_info_change", BindTool.Bind(self.BossChange, self))
	self:ListenEvent("click_team", BindTool.Bind(self.ClickTeam, self))
	self.list_view = self:FindObj("TaskList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:Flush()
end

function KuaFuBossTjFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function KuaFuBossTjFightView:BossClick(is_click)
	if is_click then
		self:Flush()
	end
end

function KuaFuBossTjFightView:BossChange()
	if self.is_boss then
		self.is_boss = false
	else
		self.is_boss = true
	end
	-- self.list_view.scroller:ReloadData(0)
	self:Flush()
end

function KuaFuBossTjFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuaFuBossTjFightView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	local info = nil
	info = KuafuGuildBattleData.Instance:GetTjSceneList(scene_id)
	-- boss_id = KuafuGuildBattleData.Instance:GetSelectBoss(scene_id)
	if info then
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(info.scene_id)
		local cfg = KuafuGuildBattleData.Instance:GetTianjiangBossCfg()
		for _,v in ipairs(cfg.monster) do
			KuafuGuildBattleData.Instance:RegMonsterXY(scene_cfg, v.monster_id)
		end
		-- local boss_xy = KuafuGuildBattleData.Instance:GetBossXY(boss_id)
		-- if boss_xy then
		-- 	MoveCache.end_type = MoveEndType.Auto
		-- 	GuajiCtrl.Instance:MoveToPos(info.scene_id, boss_xy.x, boss_xy.y, 10, 10)
		-- end
	end
end

function KuaFuBossTjFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.show_panel:SetValue(state)
end

function KuaFuBossTjFightView:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuaFuBossTjFightView:OnFlush()
	self:StopTimeQuest()

	local data = KuafuGuildBattleData.Instance
	local max_val = data:GetActiveMaxValue(Scene.Instance:GetSceneId())
	local angry_val = data:GetTianjiangBossAngryInfo()
	self.anger:SetValue(angry_val .. "/".. max_val)
	self.slider:SetValue(angry_val/max_val)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
	if self.is_boss then
		self.name:SetValue(Language.KuafuGuildBattle.KfName1)
	else
		self.name:SetValue(Language.KuafuGuildBattle.KfName2)
	end

	local kick_time = data.Instance:GetTianjiangBossTimeInfo()
	local time = kick_time - TimeCtrl.Instance:GetServerTime()
	if time > 0  and not self.time_coundown then
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
			BindTool.Bind(self.OnBossUpdate, self), 1, time)
		self:OnBossUpdate()
	end
end

function KuaFuBossTjFightView:OnBossUpdate()
	local kick_time = KuafuGuildBattleData.Instance:GetTianjiangBossTimeInfo()
	local time = math.max(0, kick_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		self.time:SetValue(math.ceil(time))
		self.is_count:SetValue(true)
	else
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.is_count:SetValue(false)
		self.time_coundown = nil
	end
end

function KuaFuBossTjFightView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function KuaFuBossTjFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = KuaFuBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function KuaFuBossTjFightView:GetDataList()
	if self.is_boss then
		return KuafuGuildBattleData.Instance:GetLayerBossList(Scene.Instance:GetSceneId())
	else
		return KuafuGuildBattleData.Instance:GetLayerEliteList(Scene.Instance:GetSceneId())
	end
end

function KuaFuBossTjFightView:GetCurIndex()
	return self.cur_index
end

function KuaFuBossTjFightView:SetCurIndex(index)
	self.cur_index = index
end

function KuaFuBossTjFightView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

function KuaFuBossTjFightView:ClickTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end
----------------------------打宝bossItem
KuaFuBossItem = KuaFuBossItem or BaseClass(BaseRender)

function KuaFuBossItem:__init(instance, parent)
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

function KuaFuBossItem:__delete()
	self:StopTimeQuest()

	self.parent = nil
end

function KuaFuBossItem:ClickKill(is_click)
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

function KuaFuBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function KuaFuBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = KuafuGuildBattleData.Instance:GetLayerBossList(scene_id)
	for k,v in pairs(boss_info) do
		if v.monster_id == boss_id then
			return v
		end
	end
end

function KuaFuBossItem:SetItemIndex(index)
	self.index = index
end

function KuaFuBossItem:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuaFuBossItem:OnFlush()
	self:StopTimeQuest()

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

	local boss_data = self:GetBossData(self.data.monster_id)
	if boss_data then
		self.flush_time = KuafuGuildBattleData.Instance:GetTjStatusByBossId(self.data.monster_id, self.data.scene_id)
		self.time_color:SetValue("#00ff90")
		if self.flush_time - TimeCtrl.Instance:GetServerTime() <= 0 then
			self.time:SetValue(Language.Boss.CanKill)
		else
			self.time_color:SetValue("#ff3838")
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
	end
	-- local scene_cfg = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	-- local boss_xy = KuafuGuildBattleData.Instance:GetBossXY(self.data.monster_id)
	-- if scene_cfg and boss_xy then
		local string = string.format(Language.KuafuGuildBattle.KfLiuJieAnger, ToColorStr(self.data.angry_val, COLOR.RED))
		self.desc:SetValue(string)
	-- end
	self:FlushHl()
end

function KuaFuBossItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function KuaFuBossItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time_color:SetValue("#00ff90")
		self.time:SetValue(Language.Boss.CanKill)
	else
		self.time_color:SetValue("#ff3838")
		self.time:SetValue(TimeUtil.FormatSecond(time))
	end
end