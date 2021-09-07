ComboRenderView = ComboRenderView or BaseClass(BaseRender)
function ComboRenderView:__init()
	self.cell_list = {}
	self.combo_seq = 0
	self.display_cell_list = {}
	self.attr_list = {}
	self.select_value = false
end

function ComboRenderView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.display_cell_list) do
		v:DeleteMe()
	end

	self.display_cell_list = {}
	self.combo_seq = 0
end

function ComboRenderView:LoadCallBack()
	self.is_select = self:FindVariable("IsSelect")
	self.attr_active = self:FindVariable("AttrActive")
	self.zuhe_list = self:FindObj("ListView")
	local list_delegate = self.zuhe_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetZuheNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshZuheCell, self)

	self.display_list = self:FindObj("DisplayList")
	local list_delegate = self.display_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetDisplayNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDisplayCell, self)

	self.icon = self:FindVariable("Icon")
	self.combo_name = self:FindVariable("ComboName")

	for i = 1, 7 do
		self.attr_list[FamousGeneralData.SHOW_ATTR[i]] = self:FindVariable("Attr_" .. i)
	end
	self:ListenEvent("OnClickReturn", BindTool.Bind(self.ChangeSelect, self, false))
	self:ListenEvent("OnClickShowAttr", BindTool.Bind(self.OnClickShowAttr, self))

	self.cap_value = self:FindVariable("CapValue")
end

function ComboRenderView:OnClickShowAttr()
	self:ChangeSelect(true)
	self:FlushComboInfo()
end

function ComboRenderView:GetZuheNum()
	return #FamousGeneralData.Instance:GetZuheCfg()
end

function ComboRenderView:RefreshZuheCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.cell_list[cell]
	local data_list = FamousGeneralData.Instance:GetZuheCfg()
	if not item_cell then
		item_cell = ComboItemRender.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	item_cell:SetParent(self)
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data_list[cell_index])
	item_cell:ListenClick(BindTool.Bind(self.OnClickComboCell, self, cell_index, item_cell))
	item_cell:FlushHL()
end

function ComboRenderView:OnClickComboCell(cell_index, item_cell)
	self.combo_seq = cell_index - 1
	self.display_list.scroller:ReloadData(0)
	self:FlushAllHl()
end

function ComboRenderView:GetDisplayNum()
	return #FamousGeneralData.Instance:GetComboDisplayList(self.combo_seq)
end

function ComboRenderView:RefreshDisplayCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.display_cell_list[cell]
	local data_list = FamousGeneralData.Instance:GetComboDisplayList(self.combo_seq)
	if not item_cell then
		item_cell = GeneralDisplayRender.New(cell.gameObject)
		self.display_cell_list[cell] = item_cell
	end
	item_cell:SetData(data_list[cell_index])
end

function ComboRenderView:FlushComboInfo()
	local cur_zuhe_cfg = FamousGeneralData.Instance:GetZuheSingleCfg(self.combo_seq)
	if not cur_zuhe_cfg then return end

	for k,v in pairs(cur_zuhe_cfg) do
		if self.attr_list[k] then
			self.attr_list[k]:SetValue(string.format(Language.FamousGeneral.ShowAttr, CommonDataManager.GetAttrName(k), v))
		end
	end
	local bundle, asset = ResPath.GetFamousGeneral("combo_" .. self.combo_seq)
	self.icon:SetAsset(bundle, asset)
	local str = FamousGeneralData.Instance:CheckComboIsActive(self.combo_seq) and Language.FamousGeneral.BeautHadActive or Language.FamousGeneral.BeautNotActive
	self.attr_active:SetValue(str)
	self.combo_name:SetValue(cur_zuhe_cfg.zuhe_name)

	self.cap_value:SetValue(CommonDataManager.GetCapability(cur_zuhe_cfg))
end

function ComboRenderView:ChangeSelect(bool)
	self.select_value = bool
	self:Flush()
end

function ComboRenderView:OnFlush()
	self.is_select:SetValue(self.select_value)
end

function ComboRenderView:GetSelectSeq()
	return self.combo_seq
end

function ComboRenderView:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end