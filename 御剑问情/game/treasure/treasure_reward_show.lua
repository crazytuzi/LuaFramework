TreasureRewardShowView = TreasureRewardShowView or BaseClass(BaseView)
local ROW = 3
local LOW = 5
local MAX_NUM = 30

function TreasureRewardShowView:__init()
	self.ui_config = {"uis/views/treasureview_prefab", "ShowRewardView"}
	-- self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.quality_type = nil
	self.select_item_id = 0
	self.play_audio = true
end

function TreasureRewardShowView:LoadCallBack()
	self:InitListView()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.title_name = self:FindVariable("title_name")
end

function TreasureRewardShowView:ReleaseCallBack()
	-- 清理变量和对象
	self.list_view = nil
	self.title_name = nil
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function TreasureRewardShowView:OpenCallBack()
	self.list_view.scroller:ReloadData(0)
	self.title_name:SetValue(Language.Treasure.ShowReward)
end

function TreasureRewardShowView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TreasureRewardShowView:GetNumberOfCells()
	return MAX_NUM / ROW
end

function TreasureRewardShowView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TreasueContent.New(cell.gameObject,self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = PetData.Instance:GetCellIndexList(cell_index)
	contain_cell:SetGridIndex(cell_index_list)
	contain_cell:SetToggleGroup(self.list_view.toggle_group)
end

function TreasureRewardShowView:SetQualityType(quality_type)
	self.quality_type = quality_type
	self.can_active_list = PetData.Instance:GetPetCanActiveItem(quality_type)
end

function TreasureRewardShowView:SetCurGrid(cur_grid)
	self.cur_grid = cur_grid
end

function TreasureRewardShowView:SetOpenType()
	if self.title_name then
		self.title_name:SetValue(Language.Treasure.ShowReward)
	end
end

function TreasureRewardShowView:GetCurGrid()
	return self.cur_grid
end

function TreasureRewardShowView:OnCloseClick()
	self:Close()
end

function TreasureRewardShowView:SetItemId(item_id)
	self.select_item_id = item_id
end

function TreasureRewardShowView:SetAllHL()
	for k,v in pairs(self.contain_cell_list) do
		v:SetItemHL()
	end
end
-----------------------------------------------------------------
TreasueContent = TreasueContent  or BaseClass(BaseCell)
function TreasueContent:__init(instance, parent)
	self.parent = parent
	self.ware_item_list = {}
	for i = 1, ROW do
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

			TipsCtrl.Instance:OpenItem(self.ware_item_list[i].warehouse_item:GetData(),nil ,nil ,callback)
		end
		self.ware_item_list[i] = {}
		self.ware_item_list[i].warehouse_item = ItemCell.New()
		self.ware_item_list[i].warehouse_item:SetInstanceParent(self:FindObj("item_" .. i))

		self.ware_item_list[i].grid_index = 0
		self.ware_item_list[i].warehouse_item:ListenClick(handler)
	end
end

function TreasueContent:__delete()
	for k,v in pairs(self.ware_item_list) do
		v.warehouse_item:DeleteMe()
	end
	self.ware_item_list = {}
	self.parent = nil
end

function TreasueContent:ItemCellClick()
	local replace_view = TipsCtrl.Instance:GetPetBagView()
	replace_view:SetCurGrid(self.ware_item_list[i].grid_index)
	replace_view:SetAllHL()

end

function TreasueContent:SetGridIndex(grid_index_list)
	local show_list = TreasureData.Instance:GetShowCfg()

	for i = 1, ROW do
		self.ware_item_list[i].warehouse_item:SetData(show_list[grid_index_list[i]])
		if grid_index_list[i] <= 6 then
			self.ware_item_list[i].warehouse_item:IsDestoryActivityEffect(false)
			self.ware_item_list[i].warehouse_item:SetActivityEffect()
		else
			self.ware_item_list[i].warehouse_item:IsDestoryActivityEffect(true)
			self.ware_item_list[i].warehouse_item:SetActivityEffect()
		end
		self.ware_item_list[i].warehouse_item:ShowHighLight(false)
		self.ware_item_list[i].grid_index = grid_index_list[i]
	end
end

function TreasueContent:SetItemHL()
	local replace_view = TipsCtrl.Instance:GetPetBagView()
	for i=1,ROW do
		if self.ware_item_list[i].grid_index == replace_view:GetCurGrid() and nil ~= self.ware_item_list[i].warehouse_item:GetData().item_id then
			self.ware_item_list[i].warehouse_item:ShowHighLight(true)
		else
			self.ware_item_list[i].warehouse_item:ShowHighLight(false)
		end
	end
end

function TreasueContent:SetToggleGroup(toggle_group)
	for i = 1 , ROW do
		self.ware_item_list[i].warehouse_item:SetToggleGroup(toggle_group)
	end
end