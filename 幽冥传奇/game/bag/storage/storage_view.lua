------------------------------------------------------------
-- 仓库
------------------------------------------------------------
StorageView = StorageView or BaseClass(BaseView)

function StorageView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetBag("titile_cangku")
	self.texture_path_list = {'res/xui/bag.png'}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"bag_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}
end

function StorageView:__delete()
end

function StorageView:ReleaseCallBack()
	-- if self.grid_storage_scroll_list then
	-- 	self.grid_storage_scroll_list:DeleteMe()
	-- end
	-- self.grid_storage_scroll_list = nil

	if self.sto_bag_grid ~= nil then
		self.sto_bag_grid:DeleteMe()
		self.sto_bag_grid = nil
	end

	if self.storage_grid ~= nil then
		self.storage_grid:DeleteMe()
		self.storage_grid = nil
	end
end

function StorageView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:RegisterEvents()
		BagCtrl.Instance:SendStorageLockTypeReq()
		self:CreateStorage()
		self:CreateBagGrid()

		XUI.AddClickEventListener(self.node_t_list.btn_add.node,function () BagCtrl.Instance:OpenCellView(self:GetViewDef()) end, true)
		XUI.AddClickEventListener(self.node_t_list.btn_storage_protect.node, BindTool.Bind(self.OnClickStorageProtectHandler, self))
		XUI.AddClickEventListener(self.node_t_list.btn_storage_cleanup.node, BindTool.Bind(self.OnClickStorageCleanupHandler, self))
	end
end

function StorageView:OnClickStorageProtectHandler()
	local lock_type = BagData.Instance:GetStorageLockType()
	if lock_type == LOCKSTATEID.NOT_LOCKED then
		ViewManager.Instance:OpenViewByDef(ViewDef.StorageEncryption)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.StorageProtect)
	end
end

function StorageView:OnClickStorageCleanupHandler()
	BagData.Instance:SortStorageList()
	self:Flush()
end

function StorageView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function StorageView:ShowIndexCallBack(index)
	self:Flush()
end

function StorageView:CreateBagGrid()
	self.sto_bag_grid = BaseGrid.New()
	self.sto_bag_grid:SetGridName(GRID_TYPE_BAG)
	self.sto_bag_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
	local ph_baggrid = self.ph_list.ph_bag_item_list
	local grid_node = self.sto_bag_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count=30, col=4, row=5, itemRender = StorageCell, direction = ScrollDir.Vertical})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_stroge.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	-- self.sto_bag_grid:SetDataList(ItemData.Instance:GetBagItemDataList())
	self.sto_bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
end

function StorageView:CreateStorage()
	-- if nil == self.storage_grid then
		-- local ph = self.ph_list.ph_stroge_item_list
		-- self.grid_storage_scroll_list = GridScroll.New()
		-- self.grid_storage_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 4, 110, StorageRender, ScrollDir.Vertical, false, self.ph_list.ph_item)
		-- self.node_t_list.layout_stroge.node:addChild(self.grid_storage_scroll_list:GetView(), 100)
		-- self.grid_storage_scroll_list:SetDataList(self:GetStorageList())
		-- self.grid_storage_scroll_list:JumpToTop()
	-- end

		self.storage_grid = BaseGrid.New()
		self.storage_grid:SetGridName(GRID_TYPE_STORAGE)
		self.storage_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnStoragePageChange, self))
		local ph_storage_grid = self.ph_list.ph_stroge_item_list
		local grid_node = self.storage_grid:CreateCells({w=ph_storage_grid.w, h=ph_storage_grid.h, cell_count=30, 
			itemRender = StorageCell, col=6, row=5,direction = ScrollDir.Vertical})
		grid_node:setAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_stroge.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_storage_grid.x, ph_storage_grid.y)
		-- self.storage_grid:SetIsShowTips(false)
		self.storage_grid:SetDataList(BagData.Instance:GetStorageList())
		-- self:OnUpdateStorageExtend()
		self.storage_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
end

function StorageView:OnBagPageChange(grid_view, cur_page_index, prve_page_index)

end

function StorageView:OnStoragePageChange(grid_view, cur_page_index, prve_page_index)
end

function StorageView:TryOpenCell(cell)
	if cell == nil then return end

	local grid_name = cell:GetName()
	if grid_name == GRID_TYPE_STORAGE then
		if cell:GetIsOpen() == false then
			-- ViewManager.Instance:Open(StorageViews.OpenCell)
			-- ViewManager.Instance:FlushView(StorageViews.OpenCell, 0, "cell_id", {cell_id = cell:GetIndex() + 1})
			return true
		end
	end
	return false
end

function StorageView:SelectCellCallBack(cell)
	if cell == nil then
		return
	end
	local cell_data = cell:GetData()
	local is_try_open_cell = self:TryOpenCell(cell)
	if nil == cell_data or is_try_open_cell then
		return
	end
	if cell:GetName() == GRID_TYPE_BAG then							--打开tip，提示存仓库
		TipCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_BAG_ON_BAG_STORAGE)
	elseif cell:GetName() == GRID_TYPE_STORAGE then							--打开tip，提示取回背包
		local storage_id = math.floor((cell:GetIndex() + 1) / BagData.STORAGE_PAGE_COUNT)
		TipCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_STORAGE_ON_BAG_STORAGE)
	end
end

function StorageView:OnFlush(param_t, index)
	local max_cell_cout = bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STALL_GRID_COUNT), 16)
	self.node_t_list.lbl_stroge_num.node:setString(#BagData.Instance:GetStorageList() .. "/" .. max_cell_cout)
	local cur_cell_count = self.storage_grid:GetPageCellCount()
	if max_cell_cout > cur_cell_count then
		self.storage_grid:ExtendGrid(max_cell_cout)
	end


	local bag_cells = bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STALL_GRID_COUNT), 16)
	if self.storage_grid then
		self.storage_grid:SetDataList(self:GetStorageList())
		self.storage_grid:OpenCellToIndex(bag_cells - 1)
	end

	local bag_list = BagData.Instance:GetBagItemDataListByBagType(1)
	local cur_bag_cell_count = self.sto_bag_grid:GetPageCellCount()
	local need_bag_cell_count = #bag_list + 1
	if need_bag_cell_count > cur_bag_cell_count then
		self.sto_bag_grid:ExtendGrid(need_bag_cell_count)
	end
	self.sto_bag_grid:SetDataList(BagData.Instance:GetBagItemDataListByBagType(1))
end

function StorageView:GetStorageList()
	local sto_item = DeepCopy(BagData.Instance:GetStorageList())

	if not sto_item[0] and sto_item[1] then
		sto_item[0] = table.remove(sto_item, 1)
	end
	return sto_item
end

function StorageView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function StorageView:RegisterEvents()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.STORAGE_ITEM_CHANGE, BindTool.Bind(self.OnStorageItemChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnStorageChangeCallback, self))
end

function StorageView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_STALL_GRID_COUNT then
		self:Flush()
	end
end

function StorageView:OnStorageItemChange()
	self:Flush(0, "baglist_change")
end

function StorageView:OnStorageChangeCallback(event)
	self:Flush()
end


StorageCell = StorageCell or BaseClass(GridCell)

function StorageCell:OnFlush(...)
	GridCell.OnFlush(self, ...)
	local lock_type = BagData.Instance:GetStorageLockType()
	self:MakeGray(lock_type == LOCKSTATEID.LOCKED)
end


StorageRender = StorageRender or BaseClass(BaseRender)
function StorageRender:__init()
	self:AddClickEventListener()
end

function StorageRender:__delete()
end

function StorageRender:CreateChild()
	BaseRender.CreateChild(self)
	-- local ph = self.ph_list.ph_cell
	-- self.cell = BaseCell.New()
	-- self.cell:SetCellBg(ResPath.GetCommon("cell_111"))
	-- self.cell:GetView():setAnchorPoint(0.5, 0.5)
	-- self.cell:SetPosition(ph.x, ph.y)
	-- self.view:addChild(self.cell:GetView(), 99)
end

function StorageRender:OnFlush()
	if not self.data then return end
	-- local item_data = ItemData.Instance:GetItemConfig(self.data.item_id)

	-- self.cell:SetData(self.data)
	-- self.cell:SetItemTipFrom(EquipTip.FROM_STORAGE_ON_BAG_STORAGE)


	-- self.node_tree.lbl_item_name.node:setString(item_data.name)
	-- local color = Str2C3b(string.sub(string.format("%06x", item_data.color), 1, 6))
	-- self.node_tree.lbl_item_name.node:setColor(color)
end

function StorageRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function StorageRender:CreateSelectEffect()
end