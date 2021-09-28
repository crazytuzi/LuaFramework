PlayerRecycleView = PlayerRecycleView or  BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 144			-- 最大格子数
local BAG_PAGE_NUM = 9					-- 页数
local BAG_PAGE_COUNT = 16				-- 每页个数
local BAG_ROW = 4						-- 行
local BAG_COLUMN = 4					-- 列

local BAG_SHOW_STORGE = "show_storge"
local BAG_SHOW_ROLE = "show_role"
local BAG_SHOW_SALE = "show_sale"
local BAG_SHOW_SALE_JL = "show_sale_jl"

function PlayerRecycleView:__init(instance, package, package_init)
	self.package_view = package
	self.package_init = package_init

	self.global_event = GlobalEventSystem:Bind(OtherEventType.RECYCLE_FLUSH_CONTENT, BindTool.Bind(self.FlushRecycleView, self))
	self.open_callback_event = GlobalEventSystem:Bind(OtherEventType.OPEN_RECYCLE_VIEW, BindTool.Bind(self.OpenCallBack, self))
	self.current_page = 1
	self.view_state =BAG_SHOW_STORGE
	self.recycle_grid_list = {}
	self.is_auto = false

	self.warehouse_list_view_delegate = ListViewDelegate()

	-- 监听UI事件
	self:ListenEvent("RecycleAndClose", BindTool.Bind(self.RecycleAndClose, self))


	for i=1, BAG_PAGE_NUM do
		self:ListenEvent("Page" .. i, BindTool.Bind(self.WareJumpPage, self, i))
	end

	self:ListenEvent("ClickBlue", BindTool.Bind(self.ClickBlueAndUnder, self))
	self:ListenEvent("ClickPurple", BindTool.Bind(self.ClickPurple, self))
	self:ListenEvent("ClickOrange", BindTool.Bind(self.ClickOrange, self))
	self:ListenEvent("ClickMyProfession", BindTool.Bind(self.ClickRed, self))
	self:ListenEvent("ClickAuto", BindTool.Bind(self.ClickAuto, self))

	self.page_toggle_list = {}
	for i = 1, BAG_PAGE_NUM do
		self.page_toggle_list[i] = self:FindObj("PageToggle" .. i).toggle
	end

	--获取控件
	self.warehouse_list_view = self:FindObj("WarehouseListView")
	local list_delegate = self.warehouse_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.WareGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.WareRefreshCell, self)

	self.renown 			= self:FindVariable("renown")
	self.check_blue 		= self:FindVariable("check_blue")
	self.check_purple 		= self:FindVariable("check_purple")
	self.check_orange 		= self:FindVariable("check_orange")
	self.check_profession 	= self:FindVariable("check_profession")
	self.check_auto = self:FindVariable("check_auto")

	self.orange_crystal = self:FindVariable("OrangeCrystal")
	self.red_crystal = self:FindVariable("RedCrystal")
	self.show_orange_crystal = self:FindVariable("ShowOrangeCrystal")
	self.show_red_crystal = self:FindVariable("ShowRedCrystal")

	self.is_blue = true
	self.is_purple = false
	self.is_orange = false
	self.is_profession = false

	self.item_data_list = {}
end

function PlayerRecycleView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
	if self.open_callback_event ~= nil then
		GlobalEventSystem:UnBind(self.open_callback_event)
		self.open_callback_event = nil
	end

	self.package_view = nil
	self.package_init = nil
	self.warehouse_list_view = nil
	for k, v in pairs(self.recycle_grid_list) do
		v:DeleteMe()
	end
	self.recycle_grid_list = {}
end

function PlayerRecycleView:OpenCallBack()
	self.need_jump = true
	self.renown:SetValue(0)

	self:FlushToggleState()
	self:GetAllRecycleList()
end

function PlayerRecycleView:FlushToggleState()
	self.is_auto = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP)
	self.check_auto:SetValue(self.is_auto)

	self.is_blue = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_BLUE)

	self.is_purple = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_PURPLE)
	self.is_orange = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_ORANGE)
	self.is_profession = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_RED)

	self.check_blue:SetValue(self.is_blue)
	self.check_purple:SetValue(self.is_purple)
	self.check_orange:SetValue(self.is_orange)
	self.check_profession:SetValue(self.is_profession)
end

function PlayerRecycleView:ClickBlueAndUnder()
	self.is_blue = not self.is_blue
	self.check_blue:SetValue(self.is_blue)

	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_BLUE, self.is_blue, true)
	local blue_data_list = PackageData.Instance:GetBlueAndUnderDataList()
	PackageData.Instance:SetRecycleItemDataList(self.is_blue, blue_data_list, 2)
	self:FlushRecycleView()

	SettingCtrl.Instance:SendHotkeyInfoReq()
end
function PlayerRecycleView:ClickPurple()
	self.is_purple = not self.is_purple
	self.check_purple:SetValue(self.is_purple)

	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_PURPLE, self.is_purple, true)

	local purple_data_list = PackageData.Instance:GetEquipDataListByColor(3)
	PackageData.Instance:SetRecycleItemDataList(self.is_purple, purple_data_list,3)
	self:FlushRecycleView()

	SettingCtrl.Instance:SendHotkeyInfoReq()
end
function PlayerRecycleView:ClickOrange()
	self.is_orange = not self.is_orange
	self.check_orange:SetValue(self.is_orange)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_ORANGE, self.is_orange, true)

	local orange_data_list = PackageData.Instance:GetEquipDataListByColor(4)
	PackageData.Instance:SetRecycleItemDataList(self.is_orange, orange_data_list,4)
	self:FlushRecycleView()

	SettingCtrl.Instance:SendHotkeyInfoReq()
end

function PlayerRecycleView:ClickRed()
	self.is_profession = not self.is_profession
	self.check_profession:SetValue(self.is_profession)

	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_RED, self.is_profession, true)

	local red_data_list = PackageData.Instance:GetEquipDataListByColor(5)
	PackageData.Instance:SetRecycleItemDataList(self.is_profession, red_data_list, 5)
	self:FlushRecycleView()

	SettingCtrl.Instance:SendHotkeyInfoReq()
	-- GlobalEventSystem:Fire(OtherEventType.FLUSH_BAG_GRID)
end

function PlayerRecycleView:ClickAuto()
	self.is_auto = self.is_auto == false
	self.check_auto:SetValue(self.is_auto)
	-- SettingData.Instance:SetRecycleLimitValue(self.is_auto)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP, self.is_auto, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_BLUE, self.is_blue, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_PURPLE, self.is_purple, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_ORANGE, self.is_orange, true)
	SettingData.Instance:SetSettingData(SETTING_TYPE.AUTO_RECYCLE_RED, self.is_profession, true)

	SettingCtrl.Instance:SendHotkeyInfoReq()
	self:FlushToggleState()
	self:FlushRecycleView()
end

--回收
function PlayerRecycleView:RecycleAndClose()
	--回收
	local recycle_list = PackageData.Instance:GetRecycleItemDataList()
	for k,v in pairs(recycle_list) do
		if v and v.item_id then
			PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
		end
	end

	PackageData.Instance:EmptyRecycleList()
	self.item_data_list = {}
	self:FlushRecycleView()
end

function PlayerRecycleView:GetAllRecycleList()
	local blue_data_list = PackageData.Instance:GetBlueAndUnderDataList()
	PackageData.Instance:SetRecycleItemDataList(self.is_blue, blue_data_list, 2)

	local purple_data_list = PackageData.Instance:GetEquipDataListByColor(3)
	PackageData.Instance:SetRecycleItemDataList(self.is_purple, purple_data_list,3)

	local orange_data_list = PackageData.Instance:GetEquipDataListByColor(4)
	PackageData.Instance:SetRecycleItemDataList(self.is_orange, orange_data_list,4)

	local red_data_list = PackageData.Instance:GetEquipDataListByColor(5)
	PackageData.Instance:SetRecycleItemDataList(self.is_profession, red_data_list, 5)

	self:FlushRecycleView()
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function PlayerRecycleView:WareGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function PlayerRecycleView:WareRefreshCell(index, cellObj)
	local cell = self.recycle_grid_list[cellObj]
	if not cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.package_view.toggle_group)
		self.recycle_grid_list[cellObj] = cell
	end
	cell.local_index = index
	self:RefreshCell(cell)

end

--刷新格子
function PlayerRecycleView:RefreshCell(cell)
	local index = cell.local_index or 0
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
		local data = self.item_data_list[grid_index + 1]
		data = data or {}
		data.locked = false
		data.index = data.index and data.index or grid_index
		cell:SetData(data, true)
		cell:ShowHighLight(false)
		cell:ShowQuality(nil ~= data.item_id)
		cell:ListenClick(BindTool.Bind(self.HandleWareOnClick, self, data, cell))
		cell:SetInteractable((nil ~= data.item_id or data.locked))
	-- end
end

function PlayerRecycleView:FlushRecyleList()
	for k,v in pairs(self.recycle_grid_list) do
		if v:GetActive() and k.transform.parent == self.warehouse_list_view.scroll_rect.content then
			self:RefreshCell(v)
		end
	end
end

function PlayerRecycleView:FlushRecycleView(not_flush_bag)
	self.item_data_list = PackageData.Instance:GetRecycleItemDataList()

	local renown_value = 0
	local orange_crystal_value = 0
	local red_crystal_value = 0
	local now_compose_cfg = nil

	for k, v in pairs(self.item_data_list) do
		local item_cfg, _ = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			renown_value = renown_value + item_cfg.recyclget
			if item_cfg.color == 4 then
				orange_crystal_value = orange_crystal_value + self:GetCrystalValue(v)
			elseif item_cfg.color == 5 then
				red_crystal_value = red_crystal_value + self:GetCrystalValue(v)
			end
		end
	end
	if not not_flush_bag then
		GlobalEventSystem:Fire(OtherEventType.FLUSH_BAG_GRID)
	end

	self.renown:SetValue(renown_value)
	if self.warehouse_list_view and nil ~= self.warehouse_list_view.list_view
		and self.warehouse_list_view.list_view.isActiveAndEnabled then
		if next(self.recycle_grid_list) ~= nil and (not self.need_jump or self.warehouse_list_view.list_page_scroll2:GetNowPage() == 0) then
			self:FlushRecyleList()
		else
			self.warehouse_list_view.list_view:Reload(function()
				self.warehouse_list_view.list_page_scroll2:JumpToPageImmidate(0)
			end)
			self.warehouse_list_view.list_view:JumpToIndex(0)
			self.need_jump = false
		end
	end

	self:SetCrystalValue(orange_crystal_value, red_crystal_value)
end

-- 设置回收水晶数值
function PlayerRecycleView:SetCrystalValue(orange_crystal_value, red_crystal_value)
	self.orange_crystal:SetValue(orange_crystal_value or 0)
	self.red_crystal:SetValue(red_crystal_value or 0)

	self.show_orange_crystal:SetValue(nil ~= orange_crystal_value and orange_crystal_value > 0)
	self.show_red_crystal:SetValue(nil ~= red_crystal_value and red_crystal_value > 0)
end

function PlayerRecycleView:GetCrystalValue(data)
	if nil == data or nil == data.param then return 0 end

	local now_cfg = ForgeData.Instance:GetRedEquipComposeCfg(data.item_id, math.max(#data.param.xianpin_type_list, 0))
	local crystal_value = 0
	if nil ~= now_cfg and now_cfg.discard_return[0] then
		crystal_value = crystal_value + now_cfg.discard_return[0].num
	end
	return crystal_value
end

--滑动翻页
function PlayerRecycleView:WareJumpPage(page)
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

--点击格子
function PlayerRecycleView:HandleWareOnClick(data, cell)
	self.view_state = BAG_SHOW_STORGE
	cell:SetHighLight(self.cur_index == index)
	if data.item_id ~= nil and data.item_id > 0 then
		PackageData.Instance:RemoveRecycData(data)
		self:FlushRecycleView(true)
		GlobalEventSystem:Fire(OtherEventType.FLUSH_BAG_GRID, "index", {["index" .. data.index] = data.index})
	end
end

function PlayerRecycleView:FlushRecycleViewFromPackage()
	self:FlushRecycleView()
end