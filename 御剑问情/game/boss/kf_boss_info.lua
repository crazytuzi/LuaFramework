KfBossInfoView = KfBossInfoView or BaseClass(BaseView)

function KfBossInfoView:__init()
	self.ui_config = {"uis/views/bossview_prefab","CrossBossInfo"}
	self.view_layer = UiLayer.MainUI
	self.cur_index = 0
end

function KfBossInfoView:__delete()

end

function KfBossInfoView:ReleaseCallBack()
	for k, v in pairs(self.boss_list) do
		v:DeleteMe()
	end
	self.boss_list = {}
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
end

function KfBossInfoView:LoadCallBack()
	self.list_state = false
	self.boss_data = {}
	self.boss_list = {}

	--获取变量
	self.show_kfboss_info = self:FindVariable("ShowKfBossInfo")

	--获取组件
	self.cross_boss_list = self:FindObj("CrossBossList")

	local rank_list_delegate = self.cross_boss_list.list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBossListItemNum, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossList, self)

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
end

function KfBossInfoView:OpenCallBack()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	-- self.panel_animator:SetBool("Hide", false)
	local info = KfBossData.Instance:GetCurInfo()
	if info then
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:MoveToPos(info.scene_id, info.flush_pos_x, info.flush_pos_y, 10, 10)
	end
end

function KfBossInfoView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function KfBossInfoView:CloseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function KfBossInfoView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.show_kfboss_info:SetValue(state)
end

function KfBossInfoView:ChangeState()
	self.list_state = not self.list_state
	-- self.panel_animator:SetBool("Hide", self.list_state)
end

function KfBossInfoView:RankState()
	self.list_state = state == "0" and true or false
end

-- function KfBossInfoView:SwitchButtonState(state)
-- 	self.show_kfboss_info:SetValue(state)
-- end

function KfBossInfoView:GetBossListItemNum()
	return #self.boss_data or 0
end

function KfBossInfoView:RefreshBossList(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.boss_list[cell]
	if boss_cell == nil then
		boss_cell = KfBossInfoItem.New(cell.gameObject, self)
		boss_cell.parent_view = self
		self.boss_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
	boss_cell:SetItemIndex(data_index)
end

function KfBossInfoView:OnFlush()
	local boss_list = KfBossData.Instance:GetBossList()
	self.boss_data = boss_list
	self.cross_boss_list.scroller:RefreshAndReloadActiveCellViews(true)
end

function KfBossInfoView:FlushAllHl()
	for k,v in pairs(self.boss_list) do
		v:FlushHl()
	end
end

function KfBossInfoView:SetCurIndex(index)
	self.cur_index = index
end

function KfBossInfoView:GetCurIndex()
	return self.cur_index
end

-----------------------------------------------------------------------
KfBossInfoItem = KfBossInfoItem or BaseClass(BaseCell)

function KfBossInfoItem:__init(instance, parent)
	self.parent = parent
	self.monster_name = self:FindVariable("Name")
	self.state = self:FindVariable("Time")
	self.desc = self:FindVariable("Desc")
	self.show_hl = self:FindVariable("show_hl")
	self.time_color = self:FindVariable("TimeColor")
	self.level_text = self:FindVariable("Level")
	self:ListenEvent("Click", BindTool.Bind(self.ClickAttr, self))
	self.index = 0
end

function KfBossInfoItem:__delete()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KfBossInfoItem:SetItemIndex(index)
	self.index = index
end

function KfBossInfoItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function KfBossInfoItem:ClickAttr()
	self.parent:SetCurIndex(self.index)
	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(scene_id, self.data.pos_x, self.data.pos_y, 10, 10)
	-- GuajiCtrl.Instance:SelectAtkTarget(true)
	self.parent:FlushAllHl()
end

function KfBossInfoItem:OnFlush()
	if not next(self.data) then return end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.monster_name:SetValue(monster_cfg.name)
		self.level_text:SetValue(monster_cfg.level)
	end
	self:SetState()
	self:FlushHl()

	local scene_id = Scene.Instance:GetSceneId()
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene_cfg then
		self.desc:SetValue(scene_cfg.name .. "(" .. self.data.pos_x .. "," .. self.data.pos_y .. ")")
	end
end

function KfBossInfoItem:SetState()
	local can_kill_str = string.format("<color=#00ff00ff>%s</color>", Language.Boss.CanKill)

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	local function timer_func(elapse_time, total_time)
		if not self.parent_view:IsOpen() then return end
		if elapse_time >= total_time then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.state:SetValue(can_kill_str)
			return
		end
		local left_time = math.floor(total_time - elapse_time)
		local time_str = TimeUtil.FormatSecond(left_time)
		self.time_color:SetValue("#00ff90")
		self.state:SetValue(time_str)
	end

	if self.data.is_alive == 1 then
		self.state:SetValue(can_kill_str)
	else
		local server_time = TimeCtrl.Instance:GetServerTime()
		local next_flush_time = self.data.next_flush_time
		local total_time = next_flush_time - server_time
		if total_time > 0 then
			self.count_down = CountDown.Instance:AddCountDown(total_time, 1, timer_func)
		end
	end

end