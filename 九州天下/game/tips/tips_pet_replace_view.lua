TipsPetReplaceView = TipsPetReplaceView or BaseClass(BaseView)
function TipsPetReplaceView:__init()
	self.ui_config = {"uis/views/tips/pettips", "ShowPetActiveTips"}
	self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.quality_type = nil
	self.select_item_id = 0
	self.play_audio = true
end

function TipsPetReplaceView:__delete()
end

function TipsPetReplaceView:LoadCallBack()
	self:InitListView()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("sure_click",BindTool.Bind(self.OnSureClick, self))
end

function TipsPetReplaceView:OpenCallBack()
	self.list_view.scroller:ReloadData(0)
end

function TipsPetReplaceView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsPetReplaceView:GetNumberOfCells()
	return 25
end

function TipsPetReplaceView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TipsPetWareContent.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = PetData.Instance:GetCellIndexList(cell_index)
	contain_cell:SetGridIndex(cell_index_list)

	contain_cell:SetToggleGroup(self.list_view.toggle_group)
end

function TipsPetReplaceView:SetQualityType(quality_type)
	self.quality_type = quality_type
	self.can_active_list = PetData.Instance:GetPetCanActiveItem(quality_type)
end

function TipsPetReplaceView:SetCurGrid(cur_grid)
	self.cur_grid = cur_grid
end

function TipsPetReplaceView:GetCurGrid()
	return self.cur_grid
end

function TipsPetReplaceView:OnCloseClick()
	self:Close()
end

function TipsPetReplaceView:OnSureClick()
	if nil ~= self.select_item_id then
		PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHANGE_PET, PetForgeView.Instance:GetCurrentPetInfo().index, self.select_item_id, 0)
		self:Close()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.PetSelectTips)
	end
end

function TipsPetReplaceView:SetItemId(item_id)
	self.select_item_id = item_id
end

function TipsPetReplaceView:SetAllHL()
	for k,v in pairs(self.contain_cell_list) do
		v:SetItemHL()
	end
end
-----------------------------------------------------------------
TipsPetWareContent = TipsPetWareContent  or BaseClass(BaseCell)
function TipsPetWareContent:__init()
	self.ware_item_list = {}
	for i = 1, 3 do
		local handler = function()
			local replace_view = TipsCtrl.Instance:GetPetReplaceView()
			replace_view:SetCurGrid(self.ware_item_list[i].grid_index)
			replace_view:SetItemId(self.ware_item_list[i].warehouse_item:GetData().item_id)
			replace_view:SetAllHL()
		end
		self.ware_item_list[i] = {}
		self.ware_item_list[i].warehouse_item = ItemCell.New(self:FindObj("item_" .. i))

		self.ware_item_list[i].grid_index = 0
		self.ware_item_list[i].warehouse_item:ListenClick(handler)
	end
end

function TipsPetWareContent:SetGridIndex(grid_index_list)
	local pet_data = PetData.Instance
	for i = 1, 3 do
		local chest_item = pet_data:GetPetCanActiveItem(pet_data:GetSinglePetCfg(PetForgeView.Instance:GetCurrentPetInfo().id).quality_type)[grid_index_list[i]]
		local data = {}
		if chest_item == nil then
			data = ItemData.Instance:GetItemConfig(0)
		else
			data = ItemData.Instance:GetItemConfig(chest_item.item_id)
			data.item_id = chest_item.item_id
			data.is_bind = chest_item.is_bind
			data.num = chest_item.num
		end
		self.ware_item_list[i].warehouse_item:SetData(data)
		self.ware_item_list[i].grid_index = grid_index_list[i]
	end
	self:SetItemHL()
end

function TipsPetWareContent:SetItemHL()
	local replace_view = TipsCtrl.Instance:GetPetReplaceView()
	for i=1,3 do
		if self.ware_item_list[i].grid_index == replace_view:GetCurGrid() and nil ~= self.ware_item_list[i].warehouse_item:GetData().item_id then
			-- self.ware_item_list[i].warehouse_item:SetToggle(true)
			self.ware_item_list[i].warehouse_item:ShowHighLight(true)
		else
			-- self.ware_item_list[i].warehouse_item:SetToggle(false)
			self.ware_item_list[i].warehouse_item:ShowHighLight(false)
		end
	end
end

function TipsPetWareContent:SetToggleGroup(toggle_group)
	for i = 1 , 3 do
		self.ware_item_list[i].warehouse_item:SetToggleGroup(toggle_group)
	end
end
-- function TipsPetWareContent:OnFlushItem()
-- 	for i = 1, 3 do
-- 		local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
-- 		local data = {}
-- 		data = ItemData.Instance:GetItemConfig(chest_item.item_id)
-- 		data.item_id = chest_item.item_id
-- 		data.is_bind = chest_item.is_bind
-- 		data.num = chest_item.num
-- 		self.ware_item_list[i].warehouse_item:SetData(data)
-- 	end
-- end