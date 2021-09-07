require("game/player/player_warehouse_view")
require("game/player/player_recycle_view")

PlayerPackageView = PlayerPackageView or BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 160			-- 最大格子数
local BAG_PAGE_NUM = 8					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 4					-- 列数

local BAG_SHOW_STORGE = "show_storge"
local BAG_SHOW_ROLE = "show_role"
local BAG_SHOW_SALE = "show_sale"
local BAG_SHOW_SALE_JL = "show_sale_jl"
local BAG_SHOW_RECYCLE = "show_recycle"

local SHOW_ALL = 1
local SHOW_EQUIP = 2
local SHOW_MATIERAL = 3
local SHOW_CONSUME = 4

function PlayerPackageView:__init(instance)
	-- 初始化数据变量
	self.view_state = BAG_SHOW_ROLE
	self.current_page = 1
	self.is_open_warehouse = false
	self.bag_cell = {}
	self.recycle_view_state = false

	-- 监听UI事件
	self:ListenEvent("ShowAll",BindTool.Bind(self.OnShowAll, self))
	self:ListenEvent("ShowEquip",BindTool.Bind(self.OnShowEquip, self))
	self:ListenEvent("ShowMaterial",BindTool.Bind(self.OnShowMaterial, self))
	self:ListenEvent("ShowConsume",BindTool.Bind(self.OnShowConsume, self))

	self:ListenEvent("OpenWarehouse",BindTool.Bind(self.HandleOpenWarehouse, self))
	self:ListenEvent("OpenRecycle",BindTool.Bind(self.HandleOpenRecycle, self))
	self:ListenEvent("CloseRecycle",BindTool.Bind(self.HandleCloseRecycle, self))
	self:ListenEvent("CombineItems",BindTool.Bind(self.HandleCombineItems, self))
	self:ListenEvent("CleanPackage",BindTool.Bind(self.HandleCleanPackage, self))

	self.is_open_recycle = self:FindVariable("IsOpeRecycle")
	self.is_show_button = self:FindVariable("IsShowButton")
	self.show_recycle_btn = self:FindVariable("show_recycle_btn")

	self.warehouse_content = self:FindObj("WarehousePanel")
	self.warehouse_view = PlayerWarehouseView.New(self.warehouse_content, instance, self)

	self.recycle_content = self:FindObj("RecyclePanel")
	self.display = self:FindObj("Display")
	self.recycle_view = PlayerRecycleView.New(self.recycle_content, instance, self)

	--引导用按钮
	self.recycle_button = self:FindObj("RecycleButton")								--装备回收按钮
	self.recycle_and_closebutton = self:FindObj("RecycleAndCloseButton")			--立即回收按钮
	self.tab_equip = self:FindObj("TabEquip")				--装备标签
	self.tab_all_toggle = self:FindObj("TabAll").toggle		--全部标签

	-- 获取控件
	self.bag_list_view = self:FindObj("ListView")

	local list_delegate = self.bag_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.page_toggle_list = {}
	for i = 1, BAG_PAGE_NUM do
		self.page_toggle_list[i] = self:FindObj("PageToggle" .. i).toggle
	end

	self.is_start_check = 0
	self.count_down = nil

	-- 创建子面板
	-- self.warehouse_view = PlayerWarehouseView.New(ViewName.Warehouse)

	-- 监听系统事件
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self.close_recycle_content_event = GlobalEventSystem:Bind(
		RecycleEventType.CLOSE_RECYCLE_CONTENT,
		BindTool.Bind1(self.HandleCloseRecycle, self))

	self.global_event = GlobalEventSystem:Bind(OtherEventType.FLUSH_BAG_GRID, BindTool.Bind(self.FlushBagView, self))

	-- 默认显示全部
	self:OnShowAll()
	self:FlushModel()
end

function PlayerPackageView:__delete()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if nil ~= self.close_recycle_content_event then
		GlobalEventSystem:UnBind(self.close_recycle_content_event)
		self.close_recycle_content_event = nil
	end

	if nil ~= self.global_event then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

	if self.recycle_view then
		self.recycle_view:DeleteMe()
		self.recycle_view = nil
	end

	if self.warehouse_view then
		self.warehouse_view:DeleteMe()
		self.warehouse_view = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	self.min_index = 0
	self.max_index = 0

	if self.count_down then
	    CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function PlayerPackageView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.display.ui3d_display)
		self.role_model:SetIsNeedListenRoleChange(true)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:RemoveMount()
		self.role_model:ResetRotation()
		self.role_model:SetModelResInfo(role_vo, nil, nil, nil, nil, true)
	end
end

function PlayerPackageView:OpenCallBack()
	if self.bag_list_view and self.bag_list_view.list_page_scroll2.isActiveAndEnabled then
		self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
	end
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT,true)
	self.warehouse_content:SetActive(false)
end

function PlayerPackageView:SetRecycleContentState(value)
	self.recycle_content:SetActive(value)
	if not value then
		-- self.show_recycle_btn:SetValue(true)
		self.is_open_recycle:SetValue(false)
		self.is_show_button:SetValue(true)
		self:SetBagViewState(BAG_SHOW_ROLE)
		PackageData.Instance:EmptyRecycleList()
	end
	self.recycle_view_state = value
end

function PlayerPackageView:GetRecycleViewState()
	return self.recycle_view_state
end

function PlayerPackageView:SetRecycleBtnShow(is_show)
	-- self.show_recycle_btn:SetValue(true)
end

function PlayerPackageView:CloseCallBack()
	self.warehouse_content:SetActive(false)
	self:SetBagViewState(BAG_SHOW_ROLE)
	-- self.show_recycle_btn:SetValue(true)
	self.is_open_recycle:SetValue(false)
	self.is_show_button:SetValue(true)
	self.recycle_content:SetActive(false)
	PackageData.Instance:EmptyRecycleList()
	self.recycle_view_state = false
	if self.count_down then
	    CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function PlayerPackageView:SetDefualtShowState()
	self.tab_all_toggle.isOn = true
	self:OnShowAll()
end

function PlayerPackageView:OnShowAll()
	self.cur_index = -1
	self.show_state = SHOW_ALL
	self.current_page = 1
	self:FlushBagView()
	self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)

	if self.view_state == BAG_SHOW_RECYCLE then
		self.is_show_button:SetValue(false)
		self.is_open_recycle:SetValue(true)
	else
		self.is_show_button:SetValue(true)
		self.is_open_recycle:SetValue(false)
	end

end

function PlayerPackageView:OnShowEquip()
	self.cur_index = -1
	self.show_state = SHOW_EQUIP
	self.current_page = 1
	self:FlushBagView()
	self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
end

function PlayerPackageView:OnShowMaterial()
	self.cur_index = -1
	self.show_state = SHOW_MATIERAL
	self.current_page = 1
	self:FlushBagView()
	self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
end

function PlayerPackageView:OnShowConsume()
	self.cur_index = -1
	self.show_state = SHOW_CONSUME
	self.current_page = 1
	self:FlushBagView()
	self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
end

function PlayerPackageView:GetWareHourseState()
	if self.warehouse_content then
		return self.warehouse_content.gameObject.activeSelf
	end
	return false
end

function PlayerPackageView:CloseWareHouse()
	if self.warehouse_view then
		self.warehouse_view:WarehouseClose()
		self.is_open_warehouse = false
	end
end

--打开仓库面板
function PlayerPackageView:HandleOpenWarehouse()
	if self.is_open_warehouse and self.warehouse_content.gameObject.activeSelf then
		PlayerCtrl.Instance:SetModelShow(true)
		self.warehouse_view:WarehouseClose()
		self.is_open_warehouse = false
	else
		PlayerCtrl.Instance:SetModelShow(false)
		self.warehouse_content:SetActive(true)
		GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, false)
		self:SetBagViewState(BAG_SHOW_STORGE)
		self.is_open_warehouse = true
		GlobalEventSystem:Fire(OtherEventType.WAREHOUSE_FLUSH_VIEW, ItemData.Instance:GetMaxStorageValidNum())
	end
end

--打开回收面板
function PlayerPackageView:HandleOpenRecycle()
	GlobalEventSystem:Fire(OtherEventType.OPEN_RECYCLE_VIEW)
end

--关闭回收面板
function PlayerPackageView:HandleCloseRecycle()
	-- self.show_recycle_btn:SetValue(true)
	self.is_open_recycle:SetValue(false)
	self.is_show_button:SetValue(true)
	self.recycle_content:SetActive(false)
	self:SetBagViewState(BAG_SHOW_ROLE)

	PackageData.Instance:EmptyRecycleList()
	self.cur_index = -1
	self:FlushBagView()

	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT,true)
	self.recycle_view_state = false
end

-- 合并道具
function PlayerPackageView:HandleCombineItems()
	local func = function ()
		PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 1)
	end
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Role.MergeText, func)
end

--整理背包
function PlayerPackageView:HandleCleanPackage()
	-- if self.view_state == BAG_SHOW_SALE or self.view_state == BAG_SHOW_SALE_JL then
	-- 	self:SetBagViewState(BAG_SHOW_ROLE)
	-- end

	local close_callback = function()
		PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)
	end
	if #PackageData.Instance:GetQuickUseItem() <= 0 or BAG_SHOW_STORGE == self.view_state then
		close_callback()
	else
		TipsCtrl.Instance:ShowQuickUsePropView(nil, close_callback)
	end

	if BAG_SHOW_STORGE == self.view_state then
		PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_STORAGER, 0)
	end
end

function PlayerPackageView:SetBagViewState(view_state)
	if self.view_state == view_state then
		return
	end
	self.view_state = view_state
	if self.view_state == BAG_SHOW_ROLE then
		PackageCtrl.Instance:CloseBagRecycle()
	end
end

function PlayerPackageView:GetCurPage()
	for i, v in pairs(self.page_toggle_list) do
		if v.isOn then
			self.current_page = i
			return
		end
	end
end

function PlayerPackageView:FlushBagView(param)
	if nil ~= self.bag_list_view.list_view and self.bag_list_view.list_view.isActiveAndEnabled then
		if param == nil or self.show_state ~= SHOW_ALL then
			self.cur_index = self.cur_index or -1
			if -1 == self.cur_index or self.show_state ~= SHOW_ALL then
				self.bag_list_view.list_view:Reload()
				-- self.page_toggle_list[1].isOn = true
			end
		else
			-- self.bag_list_view.list_view:Reload()
			for k,v in pairs(param) do
				if type(v) == "string" then
					v = -1
				end
				self.cur_index = v or self.cur_index or -1
				if self.cur_index == -1 then
					break
				end

				self:GetCurPage()
				local max_index = (self.current_page + 1) * BAG_COLUMN * BAG_ROW - 1
				local min_index = max_index - (BAG_COLUMN * BAG_ROW * 3) + 1
				if self.cur_index >= min_index and self.cur_index <= max_index then
					local data = nil
					if self.show_state == SHOW_MATIERAL then
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE)
					elseif self.show_state == SHOW_EQUIP then
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.EQUIP_TOGGLE)
					elseif self.show_state == SHOW_CONSUME then
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.CONSUME_TOGGLE)
					else
						data = PackageData.Instance:GetCellData(self.cur_index, GameEnum.TOGGLE_INFO.ALL_TOGGLE)
					end

					data = data or {}

					local cell_data = {}
					cell_data.item_id = data.item_id
					cell_data.num = data.num
					cell_data.locked =self.cur_index >= ItemData.Instance:GetMaxKnapsackValidNum()
					cell_data.index = data.index or self.cur_index
					cell_data.param = data.param
					cell_data.is_bind = data.is_bind
					cell_data.invalid_time = data.invalid_time

					local flag = false
					local index = 0

					for k,v in pairs(self.bag_cell) do
						if v:GetActive() then
							v:FlushArrow(true)
							if v:GetData().index == self.cur_index then
								v:ShowQuality(nil ~= cell_data.item_id)
								v:SetData(cell_data, true)
								v:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, v))
								v:SetInteractable(nil ~= cell_data.item_id or cell_data.locked)
							end
						end
					end
				end
			end
			if -1 == self.cur_index or self.cur_index >= COMMON_CONSTS.MAX_BAG_COUNT then
				self.bag_list_view.list_view:Reload()
			end
		end
		self.cur_index = -1
	end
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function PlayerPackageView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function PlayerPackageView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.root_node.toggle_group)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN
	-- local column = data_index - page * BAG_COLUMN
	-- local grid_count = BAG_COLUMN * BAG_ROW

	-- 获取数据信息
	local data = nil
	if self.show_state == SHOW_MATIERAL then
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE)
	elseif self.show_state == SHOW_EQUIP then
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.EQUIP_TOGGLE)
	elseif self.show_state == SHOW_CONSUME then
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.CONSUME_TOGGLE)
	else
		data = PackageData.Instance:GetCellData(grid_index, GameEnum.TOGGLE_INFO.ALL_TOGGLE)
	end
	data = data or {}

	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.locked = grid_index >= ItemData.Instance:GetMaxKnapsackValidNum()
	cell_data.is_bind = data.is_bind
	cell_data.invalid_time = data.invalid_time

	cell:SetIconGrayScale(false)
	cell:ShowQuality(nil ~= cell_data.item_id)
	local recycle_list = PackageData.Instance:GetRecycleItemDataList()
	for k,v in pairs(recycle_list) do
		if cell_data.item_id == v.item_id and cell_data.index == v.index then
			cell:SetIconGrayScale(true)
			cell:ShowQuality(false)
		end
	end

	cell:SetData(cell_data, true)
	cell:SetHighLight(self.cur_index == grid_index and nil ~= cell_data.item_id and self.view_state ~= BAG_SHOW_RECYCLE)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
	cell:SetInteractable((nil ~= cell_data.item_id or cell_data.locked))
end

--点击格子事件
function PlayerPackageView:HandleBagOnClick(data, cell)
	if self.count_down then
	    CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if data.locked then
		local num = data.index - ItemData.Instance:GetMaxKnapsackValidNum() + 1
		local knapsack_id = ShopData.Instance:GetShopOtherByStr("bag_open_item") or 0
		local had_item_num = ItemData.Instance:GetItemNumInBagById(knapsack_id)
		local item_cfg = ItemData.Instance:GetItemConfig(knapsack_id)
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[knapsack_id]
		local need_number = PackageData.Instance:GetOpenCellNeedItemNum(knapsack_id, data.index)
		local func_gold = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_BAG, num, shop_item_cfg.gold * (need_number - had_item_num))
		end
		local func_enough = function ()
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_BAG, num)
		end
		local close_callback = function()
			cell:SetHighLight(false)
		end
		if need_number - had_item_num > 0 then
			local str = string.format(Language.BackPack.KaiQiBeiBaoBuZu, num, need_number, item_cfg.name, had_item_num, need_number - had_item_num,
				shop_item_cfg.gold * (need_number - had_item_num))
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, func_gold, close_callback)
		else
			local str = string.format(Language.BackPack.KaiQiBeiBaoZu, num, need_number, item_cfg.name, had_item_num)
			TipsCtrl.Instance:ShowCommonAutoView(nil, str, func_enough, close_callback)
		end
		cell:SetHighLight(true)
		return
	end

	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end

	self.cur_index = data.index
	cell:SetHighLight(self.view_state ~= BAG_SHOW_RECYCLE)

	self.is_start_check = self.is_start_check + 1
	function diff_time_func()
		-- 弹出面板
		local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
		if self.is_start_check == 1 then
			if nil ~= item_cfg1 then
				if self.view_state == BAG_SHOW_STORGE then
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_STORGE, nil, close_callback)
				elseif self.view_state == BAG_SHOW_SALE then
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE,{{fromIndex = data.index}})
				elseif self.view_state == BAG_SHOW_SALE_JL then
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE_JL, {fromIndex = data.index})
				elseif item_cfg1.recycltype == 6 and self.view_state == BAG_SHOW_RECYCLE and big_type1 == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
					if cell:GetIconGrayScaleIsGray() then
						TipsCtrl.Instance:ShowSystemMsg("已锁定")
					else
						PackageData.Instance:AddItemToRecycleList(data)
						cell:SetIconGrayScale(true)
						self:FlushBagView()
						GlobalEventSystem:Fire(OtherEventType.RECYCLE_FLUSH_CONTENT)
					end
				else
					TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
				end
			end
		end	
		self.is_start_check = 0
	end
	if self.view_state == BAG_SHOW_STORGE then
		self.count_down = CountDown.Instance:AddCountDown(0.5, 0.5, diff_time_func)
	else
		self.count_down = CountDown.Instance:AddCountDown(0.1, 0.1, diff_time_func)
	end
	if self.is_start_check == 2 then
		PackageCtrl.Instance:SendRemoveItem(data.index, self:GetStoreNum(index))
		self.is_start_check = 0
	end
end
function PlayerPackageView:GetStoreNum(index)
	local index = -1
	local storage_index_max = ItemData.Instance:GetMaxStorageValidNum() + COMMON_CONSTS.MAX_BAG_COUNT - 1
	for i = COMMON_CONSTS.MAX_BAG_COUNT , storage_index_max do
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


function PlayerPackageView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.view_state == BAG_SHOW_STORGE and index < COMMON_CONSTS.MAX_BAG_COUNT then
		local page = math.floor(index / (BAG_COLUMN * BAG_ROW)) + 1
		self.current_page = page
		self.page_toggle_list[self.current_page].isOn = true
		-- self:BagJumpPage(self.current_page)
	elseif self.view_state == BAG_SHOW_STORGE and index - COMMON_CONSTS.MAX_BAG_COUNT >= 0 then
		-- 刷新仓库
		if self.warehouse_view then
			self.warehouse_view:FlushWarehouseView(index)
		end
	end
	-- GlobalEventSystem:Fire(BagFlushEventType.BAG_FLUSH_CONTENT, index)
end

function PlayerPackageView:BagJumpPage(page)
	if not self.bag_list_view.list_view.isActiveAndEnabled then
		return
	end

	self.bag_list_view.list_page_scroll2:JumpToPage(page - 1)
end

function PlayerPackageView:FlushModelShow(bool)
	if self.role_model then
		self.role_model:SetVisible(bool)
	end
end