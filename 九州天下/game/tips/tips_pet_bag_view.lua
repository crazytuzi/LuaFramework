TipsPetBagView = TipsPetBagView or BaseClass(BaseView)

SHOW_BAG_TYPE =
{
	PET_BAG = 1,
	TREASURE_BAG = 2,
}

function TipsPetBagView:__init()
	self.ui_config = {"uis/views/tips/pettips", "PetBagTips"}
	-- self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.quality_type = nil
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsPetBagView:__delete()
end

function TipsPetBagView:LoadCallBack()
	self:InitListView()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.title_name = self:FindVariable("title_name")
end

function TipsPetBagView:OpenCallBack()
	self.list_view.scroller:ReloadData(0)
	if self.open_type then
		if self.open_type == SHOW_BAG_TYPE.PET_BAG then
			self.title_name:SetValue("宠物背包")
		elseif self.open_type == SHOW_BAG_TYPE.TREASURE_BAG then
			self.title_name:SetValue("奖励预览")
		end
	end
end

function TipsPetBagView:CloseCallBack()
	self.open_type = nil
end

function TipsPetBagView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsPetBagView:GetNumberOfCells()
	return 25
end

function TipsPetBagView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TipsPetBgContent.New(cell.gameObject,self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = PetData.Instance:GetCellIndexList(cell_index)
	contain_cell:SetGridIndex(cell_index_list)
	contain_cell:SetToggleGroup(self.list_view.toggle_group)
end

function TipsPetBagView:SetQualityType(quality_type)
	self.quality_type = quality_type
	self.can_active_list = PetData.Instance:GetPetCanActiveItem(quality_type)
end

function TipsPetBagView:SetCurGrid(cur_grid)
	self.cur_grid = cur_grid
end

function TipsPetBagView:SetOpenType(open_type)
	self.open_type = open_type
	if self.title_name then
		if self.open_type then
			if self.open_type == SHOW_BAG_TYPE.PET_BAG then
				self.title_name:SetValue("宠物背包")
			elseif self.open_type == SHOW_BAG_TYPE.TREASURE_BAG then
				self.title_name:SetValue("奖励预览")
			end
		end
	end
end

function TipsPetBagView:GetOpenType()
	return self.open_type
end

function TipsPetBagView:GetCurGrid()
	return self.cur_grid
end

function TipsPetBagView:OnCloseClick()
	self:Close()
end

function TipsPetBagView:SetItemId(item_id)
	self.select_item_id = item_id
end

function TipsPetBagView:SetAllHL()
	for k,v in pairs(self.contain_cell_list) do
		v:SetItemHL()
	end
end
-----------------------------------------------------------------
TipsPetBgContent = TipsPetBgContent  or BaseClass(BaseCell)
function TipsPetBgContent:__init(instance, parent)
	self.parent = parent
	self.ware_item_list = {}
	for i = 1, 3 do
		local handler = function()
			local replace_view = TipsCtrl.Instance:GetPetBagView()
			replace_view:SetCurGrid(self.ware_item_list[i].grid_index)
			replace_view:SetItemId(self.ware_item_list[i].warehouse_item:GetData().item_id)
			if self.ware_item_list[i].warehouse_item:GetData().item_id ~= nil then
				self.ware_item_list[i].warehouse_item:ShowHighLight(true)
			end
			local callback = function ()
				self.ware_item_list[i].warehouse_item:ShowHighLight(false)
			end
			-- print_error("####点击#####",self.ware_item_list[i].warehouse_item:GetData())
			local the_type = nil

			local open_type = self.parent:GetOpenType()
			if open_type == SHOW_BAG_TYPE.PET_BAG then
				the_type = TipsFormDef.FROM_BAG
			end
			TipsCtrl.Instance:OpenItem(self.ware_item_list[i].warehouse_item:GetData(),the_type,nil,callback)
		end
		self.ware_item_list[i] = {}
		self.ware_item_list[i].warehouse_item = ItemCell.New(self:FindObj("item_" .. i))

		self.ware_item_list[i].grid_index = 0
		self.ware_item_list[i].warehouse_item:ListenClick(handler)
	end
end

function TipsPetBgContent:ItemCellClick()
	local replace_view = TipsCtrl.Instance:GetPetBagView()
	replace_view:SetCurGrid(self.ware_item_list[i].grid_index)
	replace_view:SetAllHL()

end

function TipsPetBgContent:SetGridIndex(grid_index_list)
	local pet_data = PetData.Instance

	local pet_bag_data = nil
	local open_type = self.parent:GetOpenType()
	local is_treasure = false
	if open_type == SHOW_BAG_TYPE.PET_BAG then
		-- pet_bag_data = ItemData.Instance:GetPetBagNeeDData()
	elseif open_type == SHOW_BAG_TYPE.TREASURE_BAG then
		pet_bag_data = TreasureData.Instance:GetShowCfg()
		is_treasure = true
	end

	for i = 1, 3 do
		self.ware_item_list[i].warehouse_item:SetData(pet_bag_data[grid_index_list[i]])
		if is_treasure and grid_index_list[i] <= 6 then
			self.ware_item_list[i].warehouse_item:IsDestoryActivityEffect(false)
			self.ware_item_list[i].warehouse_item:SetActivityEffect()
		else
			self.ware_item_list[i].warehouse_item:IsDestoryActivityEffect(true)
			self.ware_item_list[i].warehouse_item:SetActivityEffect()
		end
		self.ware_item_list[i].warehouse_item:ShowHighLight(false)
		self.ware_item_list[i].grid_index = grid_index_list[i]
	end
	-- self:SetItemHL()
end

function TipsPetBgContent:SetItemHL()
	local replace_view = TipsCtrl.Instance:GetPetBagView()
	for i=1,3 do
		if self.ware_item_list[i].grid_index == replace_view:GetCurGrid() and nil ~= self.ware_item_list[i].warehouse_item:GetData().item_id then
			self.ware_item_list[i].warehouse_item:ShowHighLight(true)
		else
			self.ware_item_list[i].warehouse_item:ShowHighLight(false)
		end
	end
end

function TipsPetBgContent:SetToggleGroup(toggle_group)
	for i = 1 , 3 do
		self.ware_item_list[i].warehouse_item:SetToggleGroup(toggle_group)
	end
end