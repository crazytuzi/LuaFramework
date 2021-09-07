SelectGeneralView = SelectGeneralView or BaseClass(BaseView)
local COL_NUM = 5

--引导用格子
local ITEM_SELECT = {
	ROW = 1,			--行
	COL = 1,			--列
}

function SelectGeneralView:__init(instance)
	self.ui_config = {"uis/views/famousgeneralview", "SelectGeneralView"}
	self:SetMaskBg(true)
	self.general_list = {}
	self.chose_seq = 0
end

function SelectGeneralView:ReleaseCallBack()
	for k, v in pairs(self.reward_contain_list) do
		v:DeleteMe()
	end
	self.reward_contain_list = {}
	self.list_view = nil
	self.select_item_cell = nil
end

function SelectGeneralView:CloseCallBack()	
	self.chose_seq = 0
end

function SelectGeneralView:LoadCallBack()
	self.reward_contain_list = {}
	self.list_view = self:FindObj("ListView")
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function SelectGeneralView:ChangeGeneralList()
	local data_list = {}
	local index = 1
	local general_info = TableCopy(FamousGeneralData.Instance:GetGeneralInfoList())
	local temp_info = general_info[0]
	general_info[0] = nil
	table.insert(general_info, temp_info)
	SortTools.SortAsc(general_info, "is_active", "color")
	for i = 1, #general_info, COL_NUM do
		data_list[index] = {general_info[i], general_info[i+1], general_info[i+2], general_info[i+3], general_info[i+4]}
		index = index +1
	end
	self.general_list = data_list
end

function SelectGeneralView:OpenCallBack()
	self:ChangeGeneralList()
	self.list_view.scroller:ReloadData(0)
end

function SelectGeneralView:GetNumberOfCells()
	-- if #self.general_list % COL_NUM ~= 0 then
	-- 	return math.floor(#self.general_list / COL_NUM) + 1
	-- else
	-- 	return #self.general_list / COL_NUM
	-- end
	return #self.general_list
end

function SelectGeneralView:RefreshCell(cell, cell_index)
	local reward_contain = self.reward_contain_list[cell]
	if reward_contain == nil then
		reward_contain = SelectContain.New(cell.gameObject, self)
		self.reward_contain_list[cell] = reward_contain
	end
	cell_index = cell_index + 1
	reward_contain:SetData(self.general_list[cell_index])

	if FunctionGuide.Instance:GetIsGuide() then
		reward_contain:SetIndex(cell_index)
		if cell_index == ITEM_SELECT.ROW then
			self.select_item_cell = nil
			self.select_item_cell = reward_contain:GetItemCell()
		end
	end
end

function SelectGeneralView:SetChoseSeq(chose_seq)
	self.chose_seq = chose_seq
end

function SelectGeneralView:GetChoseSeq()
	return self.chose_seq
end

function SelectGeneralView:GetSelectItemCell()
	return self.select_item_cell
end

----------------------------------------------------------------------------
SelectContain = SelectContain or BaseClass(BaseCell)
function SelectContain:__init(instance, parent)
	self.item_list = {}
	self.item_cell_list = {}
	for i = 1, COL_NUM do
		if FunctionGuide.Instance:GetIsGuide() then
			if i == ITEM_SELECT.COL then
				table.insert(self.item_cell_list, self:FindObj("Item_"..i))
			end
		end
		self.item_list[i] = GeneralSelectCell.New(self:FindObj("Item_"..i), parent)
	end
end

function SelectContain:OnFlush()
	if not self.data or not next(self.data) then return end
	for i = 1, COL_NUM do
		self.item_list[i]:SetData(self.data[i])
		self.item_list[i]:SetActive(not (self.data[i] == nil))
	end
end

function SelectContain:OnFlushAllItem()
	for i = 1, COL_NUM do
		self.item_list[i]:Flush()
	end
end

function SelectContain:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function SelectContain:GetItemCell()
	if self:GetIndex() == ITEM_SELECT.ROW then
		return self.item_cell_list[self:GetIndex()]
	end
end

----------------------------------------------------------------------
GeneralSelectCell = GeneralSelectCell or BaseClass(BaseCell)
function GeneralSelectCell:__init(instance, parent)
	self.parent = parent
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.is_active = self:FindVariable("IsActive")
	self.slot_name = self:FindVariable("Slot")

	self.show_top_left = self:FindVariable("ShowTopLeft")
	self.top_left_des = self:FindVariable("TopLeftDes")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClickGeneral, self))
end

function GeneralSelectCell:__delete()
	self.parent = nil
end

function GeneralSelectCell:OnFlush()
	if not self.data then return end
	local cfg = FamousGeneralData.Instance:GetSingleDataBySeq(self.data.seq)
	if not cfg then return end
	self.name:SetValue(cfg.name)
	self.is_active:SetValue(FamousGeneralData.Instance:CheckGeneralIsActive(self.data.seq))
	local item_cfg = ItemData.Instance:GetItemConfig(cfg.item_id)
	if not item_cfg then print_error("item_cfg == nil") return end
	self.icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	self.quality:SetAsset(ResPath.GetQualityIcon(item_cfg.color))
	local slot_seq = FamousGeneralData.Instance:GetCurSlotBySeq(self.data.seq)
	local name = FamousGeneralData.Instance:GetSlotName(slot_seq)
	--self.slot_name:SetValue(name)
	if name ~= nil and name ~= "" then
		self.top_left_des:SetValue(name)
		self.show_top_left:SetValue(true)
	else
		self.top_left_des:SetValue("")
		self.show_top_left:SetValue(false)
	end
end

function GeneralSelectCell:OnClickGeneral()
	if not self.data then return end
	local chose_seq = self.parent:GetChoseSeq()
	local is_active = FamousGeneralData.Instance:CheckGeneralIsActive(self.data.seq)
	if is_active then
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_PUTON, self.data.seq, chose_seq)
		ViewManager.Instance:Close(ViewName.GeneralSelectView)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.FamousGeneral.NeedActive)
	end
end