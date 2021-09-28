HelperEquipView = HelperEquipView or BaseClass(BaseRender)

function HelperEquipView:__init(instance)
	HelperEquipView.Instance = self
	self.list_view = self:FindObj("list_view")
	self:InitListView()
end

function HelperEquipView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HelperEquipView:GetNumberOfCells()
	return 10
end

function HelperEquipView:RefreshCell(cell, cell_index)
	-- local vip_cell = self.vip_list[cell]
	-- if vip_cell == nil then
	-- 	vip_cell = VipItem.New(cell.gameObject, self)
	-- 	self.vip_list[cell] = vip_cell
	-- 	vip_cell:SetToggleGroup(self.list_view.toggle_group)
	-- end
end