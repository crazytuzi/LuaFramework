BabyBossFightView = BabyBossFightView or BaseClass(BaseView)

function BabyBossFightView:__init()
	self.ui_config = {"uis/views/bossview_prefab","BabyBossFightView"}
	self.active_close = false
	self.fight_info_view = true
	self.cur_monster_id = 0
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.boss_cell_list = {}
	self.elite_cell_list = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
end

function BabyBossFightView:__delete()

end

function BabyBossFightView:ReleaseCallBack()
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	if self.boss_cell_list then
		for _,v in pairs(self.boss_cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.boss_cell_list = {}
	end

	if self.elite_cell_list then
		for _,v in pairs(self.elite_cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.elite_cell_list = {}
	end

	self:StopTimeQuest()

	-- 清理变量和对象
	self.anger = nil
	self.show_panel = nil
	self.time = nil
	self.slider = nil
	self.show_limit = nil
	self.boss_list = nil
	self.elite_list = nil
	self.max_anger = nil
	self.is_boss_active = nil
	self.boss_text = nil
	self.is_boss = nil
end

function BabyBossFightView:LoadCallBack()
	self.anger = self:FindVariable("Anger")
	self.show_panel = self:FindVariable("ShowPanel")
	self.time = self:FindVariable("time")
	self.slider = self:FindVariable("slider")
	self.show_limit = self:FindVariable("show_limit")
	self.boss_text = self:FindVariable("BossText")
	self.max_anger = self:FindVariable("max_anger")
	self.is_boss_active = self:FindVariable("IsBoss")
	self.max_anger:SetValue(BossData.Instance:GetActiveMaxValue())

	self.boss_list = self:FindObj("BossList")
	local list_delegate = self.boss_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfBossCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossCell, self)

	self.elite_list = self:FindObj("EliteList")
	local list_delegate = self.elite_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfEliteCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshEliteCell, self)

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:ListenEvent("ClickBoss", BindTool.Bind(self.OnClickBoss, self))
	self:ListenEvent("ClickExchange", BindTool.Bind(self.OnClickExchange, self))
	self:ListenEvent("ClickTeam", BindTool.Bind(self.ClickTeam, self))

end

function BabyBossFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function BabyBossFightView:OnClickBoss(is_click)
	if is_click then
		self:Flush()
	end
end

function BabyBossFightView:ClickTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BabyBossFightView:OnClickExchange()
	self.is_boss = not self.is_boss
	self.is_boss_active:SetValue(self.is_boss)
	local task_desc = self.is_boss and Language.Boss.BabyFBBossText or Language.Boss.BabyFBEliteText
	self.boss_text:SetValue(task_desc)
end

function BabyBossFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end

	self.layer = nil
end

function BabyBossFightView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_ROLE_INFO_REQ)   -- 请求宝宝boss人物信息

	local info = nil
	info = BossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_BABY)
	if info then
		self.cur_monster_id = info.monster_id
		-- MoveCache.end_type = MoveEndType.Auto
		-- local loc_x, loc_y = BossData.Instance:GetBabyBossLocationByBossID(info.scene_id, info.monster_id)
		-- GuajiCtrl.Instance:MoveToPos(info.scene_id, loc_x, loc_y, 10, 10)
	end

	self.is_boss = true
	self.boss_text:SetValue(Language.Boss.BabyFBBossText)
	self.layer = BossData.Instance:GetBabyBossLayerBySceneID(scene_id)
end

function BabyBossFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.show_panel:SetValue(state)
end

function BabyBossFightView:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BabyBossFightView:OnFlush()
	self:StopTimeQuest()

	local max_val = BossData.Instance:GetBabyBossMaxAngryValue()
	local angry_val = BossData.Instance:GetBabyBossAngryValue()
	self.anger:SetValue(angry_val .. "/".. max_val)
	self.slider:SetValue(angry_val / max_val)

	if self.boss_list.scroller.isActiveAndEnabled then
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.elite_list.scroller.isActiveAndEnabled then
		self.elite_list.scroller:RefreshAndReloadActiveCellViews(true)
	end

	local kick_time = BossData.Instance:GetBabyBossKickTime()
	local time = kick_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
			BindTool.Bind(self.OnBossUpdate, self), 1, time)
		self:OnBossUpdate()
	end
end

function BabyBossFightView:OnBossUpdate()
	local kick_time = BossData.Instance:GetBabyBossKickTime()
	local time = math.max(0, kick_time - TimeCtrl.Instance:GetServerTime())
	if time > 0 then
		time = math.floor(time)
		self.time:SetValue(string.format(Language.Boss.BabyBossFightViewCountDown, time))
	else
		GlobalTimerQuest:CancelQuest(self.time_coundown)
	end
end

function BabyBossFightView:GetNumOfBossCell()
	local data_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	return #data_list
end

function BabyBossFightView:RefreshBossCell(cell, data_index)
	data_index = data_index + 1
	local item = self.boss_cell_list[cell]
	if nil == item then
		item = BabyBossItem.New(cell.gameObject)
		self.boss_cell_list[cell] = item
		item:SetClickCallBack(BindTool.Bind(self.OnClickMonsterItem, self))
	end

	local data_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	if data_list[data_index] then
		item:SetData(data_list[data_index])
	end
	item:SetIndex(data_index)
	item:FlushHl(self.cur_monster_id)
end

function BabyBossFightView:GetNumOfEliteCell()
	local data_list = BossData.Instance:GetBabyEliteList(self.layer)
	return #data_list
end

function BabyBossFightView:RefreshEliteCell(cell, data_index)
	data_index = data_index + 1
	local item = self.elite_cell_list[cell]
	if nil == item then
		item = BabyBossItem.New(cell.gameObject)
		self.elite_cell_list[cell] = item
		item:SetClickCallBack(BindTool.Bind(self.OnClickMonsterItem, self))
	end

	local data_list = BossData.Instance:GetBabyEliteList(self.layer)
	if data_list[data_index] then
		item:SetData(data_list[data_index])
	end
	item:SetIndex(data_index)
	item:FlushHl(self.cur_monster_id)
end

function BabyBossFightView:OnClickMonsterItem(item)
	if item.data == nil then return end

	local boss_id = item.data.boss_id or 0
	local scene_id = item.data.scene_id or 0
	self:SetCurMonsterID(boss_id)

	-- 寻怪
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	local loc_x, loc_y = BossData.Instance:GetBabyBossLocationByBossID(scene_id, boss_id)
	GuajiCtrl.Instance:MoveToPos(item.data.scene_id, loc_x, loc_y, 0, 0)

	self:FlushAllHl()
	return
end

function BabyBossFightView:GetCurMonsterID()
	return self.cur_monster_id
end

function BabyBossFightView:SetCurMonsterID(id)
	self.cur_monster_id = id
end

function BabyBossFightView:FlushAllHl()
	list = self.is_boss and self.boss_cell_list or self.elite_cell_list
	for k,v in pairs(list) do
		v:FlushHl(self.cur_monster_id)
	end
end

--------------------- 宝宝bossItem ---------------------
BabyBossItem = BabyBossItem or BaseClass(BaseCell)

function BabyBossItem:__init()
	-- self.parent = parent
	self.desc = self:FindVariable("Desc")
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.show_hl = self:FindVariable("show_hl")
	self.time_color = self:FindVariable("TimeColor")
	self.level_text = self:FindVariable("Level")
	self.index = 0
	self.next_refresh_time = 0
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function BabyBossItem:__delete()
	self:StopTimeQuest()
end

function BabyBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function BabyBossItem:SetIndex(index)
	self.index = index
end

function BabyBossItem:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BabyBossItem:FlushHl(select_id)
	if self.show_hl then
		self.show_hl:SetValue(select_id == self.data.boss_id)
	end
end

function BabyBossItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time:SetValue(Language.Boss.CanKill)
	else
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function BabyBossItem:Flush()
	self:StopTimeQuest()

	local boss_info = self.data.boss_info
	if nil == self.data or nil == self.data.boss_info then
		return
	end

	self.name:SetValue(boss_info.name)
	self.level_text:SetValue(boss_info.level)

	self.flush_time = self.data.next_refresh_time
	if nil == self.flush_time or self.flush_time == 0 then
		self.time:SetValue(Language.Boss.CanKill)
	else
		self.time_coundown = GlobalTimerQuest:AddTimesTimer(
			BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
		self:OnBossUpdate()
	end

	local angry_des = string.format(Language.Boss.BabyMonsterAngryValue, boss_info.angry_value)
	self.desc:SetValue(angry_des)

end