PlayerWarehouseView = PlayerWarehouseView or  BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 140			-- 最大格子数
local BAG_PAGE_NUM = 7					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页格子数
local BAG_ROW = 4						-- 行
local BAG_COLUMN = 5					-- 列

local BAG_SHOW_STORGE = "show_storge"
local BAG_SHOW_ROLE = "show_role"
local BAG_SHOW_SALE = "show_sale"
local BAG_SHOW_SALE_JL = "show_sale_jl"

function PlayerWarehouseView:__init(instance, package, package_init)
	-- self.ui_config = {"uis/views/warehouse","WarehouseView"}
	self.package_view = package
	self.package_init = package_init
	-- self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self.is_start_check = 0
	self.count_down = nil

	self.global_event = GlobalEventSystem:Bind(OtherEventType.WAREHOUSE_FLUSH_VIEW, BindTool.Bind(self.FlushBagView, self))
	self.current_page = 0
	self.view_state = BAG_SHOW_STORGE
	self.ware_grid_list = {}

	self.warehouse_list_view_delegate = ListViewDelegate()

	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.WarehouseClose, self))

	for i = 1, BAG_PAGE_NUM do
		self:ListenEvent("Page" .. i, BindTool.Bind(self.WareJumpPage, self, i))
	end

	self.page_toggle_list = {}
	for i = 1, BAG_PAGE_NUM do
		self.page_toggle_list[i] = self:FindObj("PageToggle" .. i).toggle
	end
     
	--获取控件
	self.warehouse_list_view = self:FindObj("WarehouseListView")
	local list_delegate = self.warehouse_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.WareGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.WareRefreshCell, self)
end

function PlayerWarehouseView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
	self.package_view = nil
	self.package_init = nil
	self.warehouse_list_view = nil

	for k,v in pairs(self.ware_grid_list) do
		v:DeleteMe()
		v = nil
	end
	if self.count_down then
	    CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
    

	-- if self.item_data_event and ItemData.Instance then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end
end

--关闭仓库面板
function PlayerWarehouseView:WarehouseClose()
	-- ViewManager.Instance:Close(ViewName.Warehouse)
	PlayerCtrl.Instance:SetModelShow(true)
	self.root_node:SetActive(false)
	self.package_init:SetBagViewState("show_role")
	self.package_init:SetRecycleBtnShow(true)
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT,true)
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function PlayerWarehouseView:WareGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function PlayerWarehouseView:WareRefreshCell(index, cellObj)
	local cell = self.ware_grid_list[cellObj]
	if cell == nil then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.package_view.toggle_group)
		self.ware_grid_list[cellObj] = cell
	end
	-- 计算索引
	-- local page = math.floor(data_index / BAG_COLUMN)
	-- local column = data_index - page * BAG_COLUMN
	-- local grid_count = BAG_COLUMN * BAG_ROW
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN
	-- for i = 1, BAG_ROW do
		-- local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)
		local data = PackageData.Instance:GetWarehouseGridData(grid_index)
		data = data or {}
		data.locked = false
		data.index = data.index and data.index or grid_index + COMMON_CONSTS.MAX_BAG_COUNT
		cell:SetData(data, true)
		cell:ShowHighLight(false)
		cell:SetHighLight(self.cur_index == grid_index)
		cell:ListenClick(BindTool.Bind(self.HandleWareOnClick, self, data, cell))
		-- cell:ListenClick(BindTool.Bind(self.DoubleOnclick,self))
		cell:SetInteractable((nil ~= data.item_id or data.locked))
	-- end

	self.current_page = page
end

function PlayerWarehouseView:FlushBagView()
	if self.warehouse_list_view and self.warehouse_list_view.list_view
		and self.warehouse_list_view.list_view.isActiveAndEnabled then
		self.warehouse_list_view.list_view:Reload()
		self.warehouse_list_view.list_page_scroll2:JumpToPageImmidate(self.current_page)
	end
end

--滑动翻页
function PlayerWarehouseView:WareJumpPage(page)
	self.warehouse_list_view.list_page_scroll2:JumpToPageImmidate(page - 1)
	-- local jump_index = (page - 1 ) * BAG_COLUMN
	-- local scrollerOffset = 0
	-- local cellOffset = 0
	-- local useSpacing = false
	-- local scrollerTweenType = self.warehouse_list_view.scroller.snapTweenType
	-- local scrollerTweenTime = 0.2
	-- local scroll_complete = function()
	-- 	self.current_page = page
	-- end
	-- self.warehouse_list_view.scroller:JumpToDataIndex(
	-- 	jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

--点击仓库格子
function PlayerWarehouseView:HandleWareOnClick(data, cell)
	self.view_state = BAG_SHOW_STORGE
	if data.locked then
		self.cur_index = data.index
		local storage_id = ShopData.Instance:GetShopOtherByStr("open_depot_item") or 0
		local num = data.index - ItemData.Instance:GetMaxStorageValidNum() + 1 - COMMON_CONSTS.MAX_BAG_COUNT
		local had_item_num = ItemData.Instance:GetItemNumInBagById(storage_id)
		local item_cfg = ItemData.Instance:GetItemConfig(storage_id)
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[storage_id]
		local need_number = PackageData.Instance:GetOpenCellNeedItemNum(GameEnum.STORAGER_TYPE_STORAGER, data.index - COMMON_CONSTS.MAX_BAG_COUNT)

		local func_gold = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_STORAGER, num, shop_item_cfg.gold * (need_number - had_item_num))
		end
		local func_enough = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_STORAGER, num)
		end
		if need_number - had_item_num > 0 then
			local str = string.format(Language.BackPack.KaiQiCangKuBuZu, num, need_number, item_cfg.name, had_item_num, need_number - had_item_num,
				shop_item_cfg.gold * (need_number - had_item_num))
			TipsCtrl.Instance:ShowCommonTip(func_gold, nil, str)
		else
			local str = string.format(Language.BackPack.KaiQiCangKuZu, num, need_number, item_cfg.name, had_item_num)
			TipsCtrl.Instance:ShowCommonTip(func_enough, nil, str)
		end
		cell:SetHighLight(true)
		return
	end
	cell:SetHighLight(true)
	local close_callback = function ()
		cell:SetHighLight(false)
	end
	self.is_start_check = self.is_start_check + 1
	if self.count_down then
	    CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	function diff_time_func()
	-- 弹出面板	
		if self.is_start_check == 1 then
			local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
			if nil ~= item_cfg1 then
				if self.view_state == BAG_SHOW_STORGE then
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_STORGE_ON_BAG_STORGE, nil, close_callback)
				elseif self.view_state == BAG_SHOW_SALE then
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE,{{fromIndex = data.index}})
				elseif self.view_state == BAG_SHOW_SALE_JL then
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE_JL, {fromIndex = data.index})
				else
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG)
				end
			end
		end		
	 	self.is_start_check = 0
	end
	self.count_down = CountDown.Instance:AddCountDown(0.5, 0.5, diff_time_func)
	if self.is_start_check == 2 then
		PackageCtrl.Instance:SendRemoveItem(data.index, self:GetBagNum(index))
		self.is_start_check = 0
	end
end

function PlayerWarehouseView:GetBagNum(index)
    index = -1
	local max_bag_grid_num = ItemData.Instance:GetMaxKnapsackValidNum()
	for i = 0, max_bag_grid_num - 1 do
		if nil == ItemData.Instance:GetGridData(i) then
			index = i
			break
		end
	end
	if index < 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.StorgeFull)
		return
	end
	return index
end

function PlayerWarehouseView:FlushWarehouseView(index)
	if self.warehouse_list_view and self.warehouse_list_view.list_view
		and self.warehouse_list_view.list_view.isActiveAndEnabled then
		-- if index - COMMON_CONSTS.MAX_BAG_COUNT >= 0 then
			self.cur_index = (index - COMMON_CONSTS.MAX_BAG_COUNT) or self.cur_index
			local page = math.floor(self.cur_index / (BAG_COLUMN * BAG_ROW)) + 1
			self.page_toggle_list[page].isOn = true
			self:WareJumpPage(page)
			self:FlushBagView()
		-- end
	end
end

-- function PlayerWarehouseView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
-- 	if ViewManager.Instance:IsOpen(ViewName.Player) then
-- 		if self.warehouse_list_view and self.warehouse_list_view.scroller
-- 			and self.warehouse_list_view.scroller.isActiveAndEnabled then
-- 			if index - COMMON_CONSTS.MAX_BAG_COUNT >= 0 then
-- 				self.cur_index = (index - COMMON_CONSTS.MAX_BAG_COUNT) or self.cur_index
-- 				local page = math.floor(self.cur_index / (BAG_COLUMN * BAG_ROW)) + 1
-- 				self.page_toggle_list[page].isOn = true
-- 				self:WareJumpPage(page)
-- 				self:FlushBagView()
-- 			end
-- 		end
-- 	end
-- end

function PlayerWarehouseView:OnFlush(param_t)
	-- self:FlushBagView()
	-- local cur_index = self:GetShowIndex()
	-- print("执行了 PlayerWarehouseView:OnFlush  ====cur_index",cur_index)
	-- for k, v in pairs(param_t) do
	-- 	if k == "all" then
	-- 		if cur_index == TabIndex.role_bag_warehouse then
	-- 			print("刷新仓库格子")
	-- 			self:FlushBagView()
	-- 		end
	-- 	end
	-- end
end

-- WarehouseItemCellGroup = WarehouseItemCellGroup or BaseClass(BaseRender)

-- function WarehouseItemCellGroup:__init()
-- 	self.cells = {}
-- 	for i = 1, BAG_ROW do
-- 		self.cells[i] = ItemCell.New(self:FindObj("Item" .. i))
-- 	end

-- 	for k,v in pairs(self.cells) do
-- 		v:SetNotShowRedPoint(true)
-- 	end
-- end

-- function WarehouseItemCellGroup:__delete()
-- 	for k, v in pairs(self.cells) do
-- 		v:DeleteMe()
-- 	end
-- 	self.cells = {}
-- end

-- function WarehouseItemCellGroup:SetData(i, data, enable)
-- 	self.cells[i]:SetData(data, true)
-- end

-- function WarehouseItemCellGroup:ListenClick(i, handler)
-- 	self.cells[i]:ListenClick(handler)
-- end

-- function WarehouseItemCellGroup:SetToggleGroup(toggle_group)
-- 	for k, v in pairs(self.cells) do
-- 		self.cells[k]:SetToggleGroup(toggle_group)
-- 	end
-- end

-- function WarehouseItemCellGroup:SetHighLight(i, enable)
-- 	self.cells[i]:SetHighLight(enable)
-- end

-- function WarehouseItemCellGroup:ShowHighLight(i, enable)
-- 	self.cells[i]:ShowHighLight(enable)
-- end

-- function WarehouseItemCellGroup:SetInteractable(i, enable)
-- 	self.cells[i]:SetInteractable(enable)
-- end