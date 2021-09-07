HelperEnergyView = HelperEnergyView or BaseClass(BaseRender)

function HelperEnergyView:__init(instance)
	HelperEnergyView.Instance = self
	self.list_view = self:FindObj("list_view")
	self:InitListView()
end

function HelperEnergyView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HelperEnergyView:GetNumberOfCells()
	return 10
end

function HelperEnergyView:RefreshCell(cell, cell_index)
	-- local vip_cell = self.vip_list[cell]
	-- if vip_cell == nil then
	-- 	vip_cell = VipItem.New(cell.gameObject, self)
	-- 	self.vip_list[cell] = vip_cell
	-- 	vip_cell:SetToggleGroup(self.list_view.toggle_group)
	-- end
end