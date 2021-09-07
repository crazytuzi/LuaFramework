MiDaoBossInfoView = MiDaoBossInfoView or BaseClass(BaseView)

function MiDaoBossInfoView:__init()
	self.ui_config = {"uis/views/lianfuactivity/lianfudaily", "MiDaoBossInfoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function MiDaoBossInfoView:LoadCallBack()
	self.select_index = 0
	self.boss_cell_list = {}
	self.show_panel = self:FindVariable("ShowPanel")
	self.boss_list = self:FindObj("BossList")
	local boss_list_view_delegate = self.boss_list.list_simple_delegate
	boss_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	boss_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function MiDaoBossInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for _, v in pairs(self.boss_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.boss_cell_list = {}

	self.show_panel = nil
	self.boss_list = nil
	self.select_index = 0
end

function MiDaoBossInfoView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function MiDaoBossInfoView:OnFlush()
	self:FlushBossList()
end

function MiDaoBossInfoView:GetNumberOfCells()
	local max_boss_num = 2
	return max_boss_num
end

function MiDaoBossInfoView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = MidaoBossInfoItem.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(LianFuDailyData.Instance:GetMiDaoBossInfo())
	boss_cell:FlushHL(self:GetSelectIndex())
end

function MiDaoBossInfoView:FlushBossList()
	if self.boss_list.scroller.isActiveAndEnabled then
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MiDaoBossInfoView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function MiDaoBossInfoView:GetSelectIndex()
	return self.select_index or 0
end

function MiDaoBossInfoView:FlushAllHL(select_index)
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL(select_index)
	end
end

function MiDaoBossInfoView:OnClickItemCallBack(cell, select_index)
	if nil == cell or nil == cell.data then
		return
	end
	cell.root_node.toggle.isOn = true
	self:SetSelectIndex(cell.index)
	self:FlushAllHL(cell.index)
end

------------------MidaoBossInfoItem---------------------
MidaoBossInfoItem = MidaoBossInfoItem or BaseClass(BaseCell)
function MidaoBossInfoItem:__init()
	self.boss_name = self:FindVariable("Name")
	self.boss_level = self:FindVariable("Level")
	self.show_hl = self:FindVariable("ShowHL")
	self.boss_pos = self:FindVariable("Pos")
	self.boss_status = self:FindVariable("Status")
	self.tips = self:FindVariable("Tips")
	self.boss_pos_list = {}

	self:ListenEvent("OnClick", BindTool.Bind(self.ClickItem, self))
end

function MidaoBossInfoItem:ClickItem(is_click)
	if is_click then
		if nil ~= self.click_callback then
			self.click_callback(self)
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), self.boss_pos_list[1], self.boss_pos_list[2], 3, 1)
		end
	end
end

function MidaoBossInfoItem:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local other_cfg = LianFuDailyData.Instance:GetCrossXYCityOtherCfg()
	if other_cfg then
		local select_boss_index = self.index == 1 and "" or "2"
		local boss_cfg = BossData.Instance:GetMonsterInfo(other_cfg["midao_task_monster" .. select_boss_index .. "_id"])
		if boss_cfg then
			self.boss_level:SetValue(boss_cfg.level)
			self.boss_name:SetValue(boss_cfg.name)
		end		
		self.boss_pos_list = Split(other_cfg["midao_task_monster" .. select_boss_index .."_born_pos"], ",")
		self.boss_pos:SetValue(string.format("%s(%d,%d)", Scene.Instance:GetSceneName(), self.boss_pos_list[1], self.boss_pos_list[2]))
	end
	self.tips:SetValue(Language.LianFuDaily.MiDaoBossRewardTips[self.index])
	if self.data.channel_state == CROSS_XYCITY_MIDAO_STATUS.MIDAO_STATE_OPEN then
		local boss_state = self.index == 1 and self.data.jiangong_state or self.data.zhuguan_state
		self.boss_status:SetValue(Language.LianFuDaily.MiDaoBossStatus[boss_state])
	elseif self.data.channel_state == CROSS_XYCITY_MIDAO_STATUS.MIDAO_STATE_CD then
		self.boss_status:SetValue(Language.LianFuDaily.MiDaoBossStatus[0])
	else
		self.boss_status:SetValue(Language.LianFuDaily.MiDaoBossStatus[2])
	end
end

function MidaoBossInfoItem:FlushHL(select_index)
	self.show_hl:SetValue(select_index == self.index)
end