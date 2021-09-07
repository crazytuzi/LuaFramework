require("game/boss/boss_family_fight_view")
DabaoFamFightView = DabaoFamFightView or BaseClass(BaseView)

function DabaoFamFightView:__init()
	self.ui_config = {"uis/views/bossview","DabaoFamFightView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.item_t = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
end

function DabaoFamFightView:ReleaseCallBack()
	if BossData.Instance then
		BossData.Instance:RemoveListener(BossData.DABAO_BOSS, self.dabao_info_event)
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
	self.item_t = {}
end

function DabaoFamFightView:LoadCallBack()
	self.anger = self:FindVariable("Anger")
	BossData.Instance:AddListener(BossData.DABAO_BOSS, self.dabao_info_event)
	self.show_panel = self:FindVariable("ShowPanel")
	self.time = self:FindVariable("time")
	self.slider = self:FindVariable("slider")
	self.list_view = self:FindObj("TaskList")
	self:ListenEvent("boss_click", BindTool.Bind(self.BossClick, self))
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:Flush()
end

function DabaoFamFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function DabaoFamFightView:BossClick(is_click)
	if is_click then
		self:Flush()
	end
end

function DabaoFamFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function DabaoFamFightView:OpenCallBack()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	local info = nil
	info = BossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO)
	if info then
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 0, 0, nil, nil, true)
	end
end

function DabaoFamFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.show_panel:SetValue(state)
end

function DabaoFamFightView:OnFlush()
	local boss_data = BossData.Instance
	local max_val = boss_data:GetDabaoMaxValue()
	local angry_val = boss_data:GetDabaoBossInfo()
	self.anger:SetValue(angry_val .. "/".. max_val)
	self.slider:SetValue(angry_val/max_val)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
	local kick_time = BossData.Instance:GetDaBaoKickTime()
	local time = kick_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
			BindTool.Bind(self.OnBossUpdate, self), 1, time)
		self:OnBossUpdate()
	end
end

function DabaoFamFightView:OnBossUpdate()
	local kick_time = BossData.Instance:GetDaBaoKickTime()
	local time = math.max(0, kick_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		self.time:SetValue(string.format(Language.Common.DaBaoKickTime, TimeUtil.FormatSecond(time)))
	else
		GlobalTimerQuest:CancelQuest(self.time_coundown)
	end
end

function DabaoFamFightView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function DabaoFamFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = DaBaoBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function DabaoFamFightView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	return BossData.Instance:GetDaBaoBossList(scene_id)
end

function DabaoFamFightView:GetCurIndex()
	return self.cur_index
end

function DabaoFamFightView:SetCurIndex(index)
	self.cur_index = index
end

function DabaoFamFightView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end
----------------------------打宝bossItem
DaBaoBossItem = DaBaoBossItem or BaseClass(BaseRender)

function DaBaoBossItem:__init(instance, parent)
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

function DaBaoBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function DaBaoBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	-- MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 0, 0, nil, nil, true)
	self.parent:FlushAllHl()
	return
end

function DaBaoBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function DaBaoBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = BossData.Instance:GetDaBaoBossList(scene_id)
	for k,v in pairs(boss_info) do
		if v.bossID == boss_id then
			return v
		end
	end
end

function DaBaoBossItem:SetItemIndex(index)
	self.index = index
end

function DaBaoBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.name:SetValue(monster_cfg.name)
		self.level_text:SetValue(monster_cfg.level)
	end

	local boss_data = self:GetBossData(self.data.bossID)
	if boss_data then
		self.flush_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
		self.time_color:SetValue(self.flush_time <= 0 and TEXT_COLOR.GREEN_3 or "#ff0000ff")
		-- self.next_refresh_time = boss_data.next_refresh_time
		if self.flush_time <= 0 then
			self.time:SetValue(Language.Boss.CanKill)
		else
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	if scene_cfg then
		self.desc:SetValue(scene_cfg.name .. "(" .. self.data.born_x .. "," .. self.data.born_y .. ")")
	end
	self:FlushHl()
end

function DaBaoBossItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function DaBaoBossItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end