TreasureWarehouseView = TreasureWarehouseView or BaseClass(BaseRender)

function TreasureWarehouseView:__init(instance)
	self.warehouse_contain_list = {}
	self.page_toggle_1 = self:FindObj("page_toggle_1")
	self.list_view = self:FindObj("list_view")
	--引导用按钮
	self.get_all_btn = self:FindObj("GetAllBtn")

	self.auto_get = self:FindVariable("AutoGetRed")
	self:ListenEvent("get_all_click", BindTool.Bind(self.OnGetAllClick, self))
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TreasureWarehouseView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	for _,v in pairs(self.warehouse_contain_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.warehouse_contain_list = {}
end

function TreasureWarehouseView:GetNumberOfCells()
	return TREASURE_ALL_ROW
end

function TreasureWarehouseView:OnFlush()
	self:ReloadData()
	self:CheckAutoRedPoint()
end

function TreasureWarehouseView:RefreshCell(cell, cell_index)
	local warehouse_contain = self.warehouse_contain_list[cell]
	if warehouse_contain == nil then
		warehouse_contain = TreasureWarehouseContain.New(cell.gameObject, self)
		self.warehouse_contain_list[cell] = warehouse_contain
		warehouse_contain:SetToggleGroup(self.list_view.toggle_group)
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = CommonDataManager.GetCellIndexList(cell_index, TREASURE_ROW, TREASURE_COLUMN)
	warehouse_contain:SetGridIndex(cell_index_list)
end

function TreasureWarehouseView:OnGetAllClick()
	TreasureCtrl.Instance:SendQuchuItemReq(0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 1)
end

function TreasureWarehouseView:ReloadData()
	local page = self.list_view.list_page_scroll:GetNowPage()
	if page < 1 then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TreasureWarehouseView:CheckAutoRedPoint()
	if self.auto_get and ItemData.Instance:GetEmptyNum() > 0 and TreasureData.Instance:GetChestCount() > 0 then
		self.auto_get:SetValue(true)
	else
		self.auto_get:SetValue(false)
	end
end
-------------------------------------------------------------------------------
TreasureWarehouseContain = TreasureWarehouseContain  or BaseClass(BaseCell)

function TreasureWarehouseContain:__init()
	self.warehouse_item_list = {}
	for i = 1, TREASURE_COLUMN do
		local handler = function()
			local close_call_back = function()
				self.warehouse_item_list[i].warehouse_item:SetToggle(false)
				self.warehouse_item_list[i].warehouse_item:ShowHighLight(false)
			end
			if self.warehouse_item_list[i].warehouse_item:GetData().item_id ~= nil then
				self.warehouse_item_list[i].warehouse_item:ShowHighLight(true)
			else
				self.warehouse_item_list[i].warehouse_item:SetToggle(false)
				self.warehouse_item_list[i].warehouse_item:ShowHighLight(false)
			end
			TipsCtrl.Instance:OpenItem(self.warehouse_item_list[i].warehouse_item:GetData(), TipsFormDef.FROM_BAOXIANG, nil, close_call_back)
		end
		self.warehouse_item_list[i] = {}
		self.warehouse_item_list[i].warehouse_item = ItemCell.New()
		self.warehouse_item_list[i].warehouse_item:SetInstanceParent(self:FindObj("item_" .. i))
		self.warehouse_item_list[i].grid_index = 0
		self.warehouse_item_list[i].warehouse_item:ListenClick(handler)
	end
end

function TreasureWarehouseContain:__delete()
	for _,v in pairs(self.warehouse_item_list) do
		if v then
			v.warehouse_item:DeleteMe()
		end
	end
	self.warehouse_item_list = {}
end


function TreasureWarehouseContain:SetGridIndex(grid_index_list)
	for i = 1, TREASURE_COLUMN do
		local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
		self.warehouse_item_list[i].warehouse_item:SetData(chest_item)
		self.warehouse_item_list[i].grid_index = grid_index_list[i]
	end
end

function TreasureWarehouseContain:SetToggleGroup(toggle_group)
	for i = 1, TREASURE_COLUMN do
		self.warehouse_item_list[i].warehouse_item:SetToggleGroup(toggle_group)
	end
end

function TreasureWarehouseContain:OnFlushItem()
	for i = 1, TREASURE_COLUMN do
		local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
		self.warehouse_item_list[i].warehouse_item:SetData(chest_item)
	end
end