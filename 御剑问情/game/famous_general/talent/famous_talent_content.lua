FamousTalentContent = FamousTalentContent or BaseClass(BaseRender)

function FamousTalentContent:__init(instance)
	if instance == nil then
		return
	end
	self.cur_talent_type = 0

	self.cell_list = {}
	self.list_view = self:FindObj("List_View")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.equip_skill_cell_list = {}
	for i=1, GameEnum.TALENT_SKILL_GRID_MAX_NUM do
		self.equip_skill_cell_list[i] = FamousTalentEquipCell.New(self:FindObj("EquipCell"..i), self)
	end

	self.show_bag_redpoint = self:FindVariable("Show_Bag_Redpoint")
	self.zhanli_num = self:FindVariable("ZhanLi_Num")

	self:ListenEvent("OnOpenHelp", BindTool.Bind(self.OnOpenHelp, self))
	self:ListenEvent("OnOpenBag", BindTool.Bind(self.OnOpenBag, self))
end

function FamousTalentContent:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.equip_skill_cell_list) do
		v:DeleteMe()
	end
	self.equip_skill_cell_list = {}

	self.show_bag_redpoint = nil
	self.zhanli_num = nil
	self.free_times = nil
end

function FamousTalentContent:OpenCallBack()
	self:Flush()
end

function FamousTalentContent:CloseCallBack()
	
end

function FamousTalentContent:ItemDataChangeCallback()
	self:OnFlushTalentEquipView()

	if self.list_view then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function FamousTalentContent:OnFlush(param_t)
	self:OnFlushAll()
end

function FamousTalentContent:OnOpenTalent()
	self:OnFlushTalentEquipView()
end

function FamousTalentContent:OnOpenHelp()
	local tips_id = 253
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function FamousTalentContent:OnOpenBag()
	ViewManager.Instance:Open(ViewName.FamousTalentBagView, nil, "equip_talent", {})
end

function FamousTalentContent:GetNumberOfCells()
	return FamousGeneralData.Instance:GetListNum()
end

function FamousTalentContent:RefreshView(cell, data_index)
	data_index = data_index + 1
	local data_list = FamousGeneralData.Instance:GetSortGeneralList()
	local talent_type_cell = self.cell_list[cell]
	if talent_type_cell == nil then
		talent_type_cell = FamousTalentTypeCell.New(cell.gameObject, self)
		talent_type_cell.root_node.toggle.group = self.list_view.toggle_group
		self.cell_list[cell] = talent_type_cell
	end

	talent_type_cell:SetIndex(data_index - 1)
	if data_list[data_index] then
		talent_type_cell:SetData(data_list[data_index])
	end
	self.is_cell_active = true
end

function FamousTalentContent:ScrollerScrolledDelegate(go, param1, param2, param3)
	if not self.is_scroll_create then
		if self.is_cell_active and self.list_view and self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:JumpToDataIndex(self.cur_talent_type)
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
			self.is_scroll_create = true
		end
	end
end

function FamousTalentContent:GetCurSelectIndex()
	return self.cur_talent_type
end

function FamousTalentContent:SetCurSelectIndex(talent_type, is_jump)
	if nil == talent_type then
		return
	end

	self.cur_talent_type = talent_type
	self:OnFlushTalentEquipView()

	if is_jump and self.is_cell_active and self.is_scroll_create and self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:JumpToDataIndex(talent_type)
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function FamousTalentContent:OnFlushAll()
	self:OnFlushTalentEquipView()

	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function FamousTalentContent:OnFlushTalentEquipView()
	local talent_info = FamousTalentData.Instance:GetTalentAllInfo()
	if nil == next(talent_info) then
		return
	end
	local data = FamousGeneralData.Instance:GetSortGeneralList()
	local seq = data[self.cur_talent_type + 1].seq
	for k, v in ipairs(self.equip_skill_cell_list) do
		local data = talent_info[seq][k - 1]
		v:SetIndex(k - 1)
		v:SetData(data)
	end

	self.show_bag_redpoint:SetValue(false)

	local capability = FamousTalentData.Instance:GetTalentCapability(seq)
	self.zhanli_num:SetValue(capability)

	local talent_type_cfg = FamousTalentData.Instance:GetTalentConfig(seq)
	local type_skill_cfg = FamousTalentData.Instance:GetTalentTypeFirstConfigBySkillType(talent_type_cfg.skill_type)
	local item_cfg = ItemData.Instance:GetItemConfig(type_skill_cfg.book_id)
	if nil ~= item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetAsset(bundle, asset)
	end

	local top_talent_info = talent_info[seq][GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1]
	if top_talent_info and 1 == top_talent_info.is_open then
		if 0 ~= top_talent_info.skill_id then
			local skill_cfg = FamousTalentData.Instance:GetTalentSkillConfig(top_talent_info.skill_id, top_talent_info.skill_star)
			local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
			local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetAsset(bundle, asset)
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetIconGrayVisible(false)
		else
			self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetIconGrayVisible(true)
		end
	else
		self.equip_skill_cell_list[GameEnum.TALENT_SKILL_GRID_MAX_NUM]:SetIconGrayVisible(true)
	end
end


-------------------------------------------------------------------
-----------------------FamousTalentTypeCell-----------------
-------------------------------------------------------------------

FamousTalentTypeCell = FamousTalentTypeCell or BaseClass(BaseCell)
function FamousTalentTypeCell:__init(instance, parent)
	self.parent = parent
	self.show_red_point = self:FindVariable("show_red_point")
	self.type_icon = self:FindVariable("type_icon")
	self.quality = self:FindVariable("quality")
	self.type_name = self:FindVariable("type_name")
	self.view_flag = self:FindVariable("view_flag")

	self:ListenEvent("OnItemClick", BindTool.Bind(self.OnItemClick, self))
end

function FamousTalentTypeCell:__delete()
	self.parent = nil
	self.show_red_point = nil
	self.type_icon = nil
	self.type_name = nil
end

function FamousTalentTypeCell:OnFlush()
	if nil == self.data then
		return
	end

	self.root_node.toggle.isOn = self.parent:GetCurSelectIndex() == self.index
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.type_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	self.type_name:SetValue(self.data.name)

	self.quality:SetAsset(ResPath.GetQualityIcon(self.data.color))
	self.view_flag:SetValue(self.data.is_active == true)

	local is_show_red_point = FamousTalentData.Instance:GetIsShowTalentRedPoint(self.data.seq)
	self.show_red_point:SetValue(is_show_red_point)
end

function FamousTalentTypeCell:OnItemClick()
	self.parent:SetCurSelectIndex(self.index)
end


-----------------------------------------------------------------------------------------------------------------------
--FamousTalentEquipCell
-----------------------------------------------------------------------------------------------------------------------

FamousTalentEquipCell = FamousTalentEquipCell or BaseClass(BaseCell)

function FamousTalentEquipCell:__init(instance, parent)
	self.parent = parent

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickItem, self))
	self.item_cell:SetInteractable(true)

	self.show_plus = self:FindVariable("Show_Plus")
	self.show_arrow = self:FindVariable("Show_Arrow")
end

function FamousTalentEquipCell:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
	end

	self.show_plus = nil
end

function FamousTalentEquipCell:SetIndex(index)
	self.seq = index
end

function FamousTalentEquipCell:OnFlush()
	if nil == self.data then
		return
	end

	if 1 == self.data.is_open then
		self.item_cell:SetCellLock(false)
		if 0 ~= self.data.skill_id then
			local skill_cfg = FamousTalentData.Instance:GetTalentSkillConfig(self.data.skill_id, self.data.skill_star)
			local item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.need_item_id)
			self.show_arrow:SetValue(item_num >= skill_cfg.need_item_count)
			self.show_plus:SetValue(false)
			self.item_cell:ShowQuality(true)
			self.item_cell:SetData({item_id = skill_cfg.book_id})
			self.item_cell:SetShowStar(skill_cfg.skill_star)
		else
			local list = FamousGeneralData.Instance:GetSortGeneralList()
			local sort_index = self.parent:GetCurSelectIndex()
			local select_info = {talent_type = list[sort_index + 1].seq, grid_index = self.seq}
			local item_list = FamousTalentData.Instance:GetBagTalentBookItems(select_info)
			self.show_arrow:SetValue(#item_list > 0)
			self.show_plus:SetValue(true)
			self.item_cell:SetData(nil)
			self.item_cell:ShowQuality(false)
		end
	else
		self.show_arrow:SetValue(false)
		self.show_plus:SetValue(false)
		self.item_cell:SetCellLock(true)
		self.item_cell:SetData(nil)
		self.item_cell:ShowQuality(false)
	end
end

function FamousTalentEquipCell:SetAsset(bundle, asset)
	self.item_cell:SetAsset(bundle, asset)
end

function FamousTalentEquipCell:SetIconGrayVisible(bundle, asset)
	self.item_cell:SetIconGrayVisible(bundle, asset)
end

function FamousTalentEquipCell:OnClickItem()
	if nil == self.data then
		return
	end

	self.item_cell:SetToggle(false)
	self.talent_type = self.parent:GetCurSelectIndex()
	local data_list = FamousGeneralData.Instance:GetSortGeneralList()
	local seq = data_list[self.talent_type + 1].seq
	local select_info = {talent_type = seq , grid_index = self.seq}
	if 1 ~= self.data.is_open then
		if select_info.grid_index == GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 then
			FamousGeneralCtrl.Instance:OpenTalentSkillUpgradeView(select_info)
		else
			local str = FamousTalentData.Instance:GetTalentGridActiveCondition(self.parent:GetCurSelectIndex(), self.seq)
			if nil ~= str then
				SysMsgCtrl.Instance:ErrorRemind(str)
			end
		end
		return
	end

	if 0 ~= self.data.skill_id then
		if select_info.grid_index == GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 then
			FamousGeneralCtrl.Instance:OpenTalentSkillUpgradeView(select_info)
		else
			FamousGeneralCtrl.Instance:OpenTalentUpgradeView(select_info)
		end
	else
		if select_info.grid_index == GameEnum.TALENT_SKILL_GRID_MAX_NUM - 1 and #FamousTalentData.Instance:GetBagTalentBookItems(select_info) <= 0 then
			FamousGeneralCtrl.Instance:OpenTalentSkillUpgradeView(select_info)
		else
			ViewManager.Instance:Open(ViewName.FamousTalentBagView, nil, "equip_talent", select_info)
		end
	end
end
