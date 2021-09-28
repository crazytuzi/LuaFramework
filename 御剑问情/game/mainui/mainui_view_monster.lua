MainUIViewMonster = MainUIViewMonster or BaseClass(BaseRender)

function MainUIViewMonster:__init()
	-- 获取控件
	self.show_tip = self:FindVariable("Show_Tips")
	self.list_view = self:FindObj("TaskList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self:Flush()
end

function MainUIViewMonster:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t= {}
	self.list_view = nil
	self.show_tip = nil
end

function MainUIViewMonster:OnChangeScene()

end

function MainUIViewMonster:IsShowTip()
	self.show_tip:SetValue(true)
	GlobalTimerQuest:AddDelayTimer(function()
		self.show_tip:SetValue(false)
	end, 15)
end

function MainUIViewMonster:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function MainUIViewMonster:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = MainUIViewMonsterCell.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function MainUIViewMonster:GetDataList()
	local monster_list = KuafuGuildBattleData.Instance:GetMonsterData()
	return monster_list or {}
end

function MainUIViewMonster:SetCurIndex(index)
	self.cur_index = index
end

function MainUIViewMonster:GetCurIndex()
	return self.cur_index
end

function MainUIViewMonster:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.list_view.scroller:ReloadData(0)
	end
end

function MainUIViewMonster:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

----------------------------------------------------------------------------
--MainUIViewMonsterCell 		滚动条格子
----------------------------------------------------------------------------

MainUIViewMonsterCell = MainUIViewMonsterCell or BaseClass(BaseCell)

function MainUIViewMonsterCell:__init(instance, parent)
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
	self.cur_scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function MainUIViewMonsterCell:__delete()
	self:StopTimeQuest()
end

function MainUIViewMonsterCell:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	local scene_id = Scene.Instance:GetSceneId()
	GuajiCtrl.Instance:MoveToPos(scene_id, self.pos_x, self.pos_y, 10, 10)
	self.parent:FlushAllHl()
	return
end

function MainUIViewMonsterCell:SetData(data)
	self.data = data
	self:Flush()
end

function MainUIViewMonsterCell:SetItemIndex(index)
	self.index = index
end

function MainUIViewMonsterCell:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function MainUIViewMonsterCell:OnFlush()
	--刷新的时候先停止定时器
	self:StopTimeQuest()

	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.name:SetValue(monster_cfg.name)
		self.level_text:SetValue(monster_cfg.level)
	end

	self:FlushHl()

	--不在一线直接不计时
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	if scene_key ~= 0 then
		self.time:SetValue("")
		self.desc:SetValue(Language.Dungeon.OneKeyRefreshDes)
		return
	end

	self.next_refresh_time = self.data.next_refresh_time
	if self.next_refresh_time == 0 then
		self.time_color:SetValue("#00ff90")
		self.time:SetValue(Language.Dungeon.CanKill)
	else
		self.time_color:SetValue("#fe3030")
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddRunQuest(
				function()
					self:OnBossUpdate()
					self:CancelQuest()
				end
			, 0)
		end
	end
	local scene_id = YewaiGuajiData.Instance:GetGuaJiSceneId()
	if 0 == scene_id then
		scene_id = Scene.Instance:GetSceneId()
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	self.pos_x, self.pos_y = self:GetMonsterPosition(scene_cfg.monsters)
	if scene_cfg then
		self.desc:SetValue(scene_cfg.name .. "(" .. self.pos_x .. "," .. self.pos_y .. ")")
	end
end

function MainUIViewMonsterCell:CancelQuest()
	if self.time_coundown then
		GlobalTimerQuest.CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function MainUIViewMonsterCell:GetMonsterPosition(list)
	local list = list
	if list == nil then return 0, 0 end
	for k,v in pairs(list) do
		if self.data.boss_id == v.id then
			return v.x, v.y
		end
	end
	return 0, 0
end

function MainUIViewMonsterCell:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function MainUIViewMonsterCell:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time_color:SetValue("#00ff90")
		self.time:SetValue(Language.Dungeon.CanKill)
	else
		self.time_color:SetValue("#fe3030")
		self.time:SetValue(TimeUtil.FormatSecond(time))
	end
end