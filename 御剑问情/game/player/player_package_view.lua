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
	self.isCleanPackage = nil 			--nil表示不是点击整理按钮,true表示点击了背包的整理按钮，false表示点击了仓库的整理按钮
	-- 监听UI事件
	self:ListenEvent("ShowAll",
		BindTool.Bind(self.OnShowAll, self))
	self:ListenEvent("ShowEquip",
		BindTool.Bind(self.OnShowEquip, self))
	self:ListenEvent("ShowMaterial",
		BindTool.Bind(self.OnShowMaterial, self))
	self:ListenEvent("ShowConsume",
		BindTool.Bind(self.OnShowConsume, self))

	self:ListenEvent("OpenWarehouse",
		BindTool.Bind(self.HandleOpenWarehouse, self))
	self:ListenEvent("OpenRecycle",
		BindTool.Bind(self.HandleOpenRecycle, self))
	self:ListenEvent("CloseRecycle",
		BindTool.Bind(self.HandleCloseRecycle, self))
	self:ListenEvent("CombineItems",
		BindTool.Bind(self.HandleCombineItems, self))
	self:ListenEvent("CleanPackage",
		BindTool.Bind(self.HandleCleanPackage, self))

	self.is_open_recycle = self:FindVariable("IsOpeRecycle")
	self.is_show_button = self:FindVariable("IsShowButton")
	self.show_recycle_btn = self:FindVariable("show_recycle_btn")

	self.warehouse_content = self:FindObj("WarehousePanel")
	self.warehouse_view = PlayerWarehouseView.New(self.warehouse_content, instance, self)

	self.recycle_content = self:FindObj("RecyclePanel")
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

	-- 创建子面板
	-- self.warehouse_view = PlayerWarehouseView.New(ViewName.Warehouse)

	-- 监听系统事件
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	--开始监听魔晶变化
	self.score_change_callback = BindTool.Bind1(self.MoJingChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)

	self.close_recycle_content_event = GlobalEventSystem:Bind(
		RecycleEventType.CLOSE_RECYCLE_CONTENT,
		BindTool.Bind1(self.HandleCloseRecycle, self))

	self.global_event = GlobalEventSystem:Bind(OtherEventType.FLUSH_BAG_GRID, BindTool.Bind(self.Flush, self))
	-- 默认显示全部
	self:OnShowAll()
	self.need_jump = false
end

function PlayerPackageView:__delete()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	--结束监听魔晶改变
	if self.score_change_callback and ExchangeCtrl.Instance then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
		self.score_change_callback = nil
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

	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	self.min_index = 0
	self.max_index = 0
end

function PlayerPackageView:OpenCallBack()
	self.need_jump = false
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, true)
end

function PlayerPackageView:CloseCallBack()
	self.warehouse_content:SetActive(false)
	self:SetBagViewState(BAG_SHOW_ROLE)
	self.show_recycle_btn:SetValue(true)
	self.is_open_recycle:SetValue(false)
	self.is_show_button:SetValue(true)
	self.recycle_content:SetActive(false)
	PackageData.Instance:EmptyRecycleList()
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, false)
	self.recycle_view_state = false
end

function PlayerPackageView:SetRecycleContentState(value)
	self.recycle_content:SetActive(value)
	if not value then
		self.show_recycle_btn:SetValue(true)
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
	self.show_recycle_btn:SetValue(is_show)
end

function PlayerPackageView:SetDefualtShowState()
	self.tab_all_toggle.isOn = true
	self:OnShowAll()
end

function PlayerPackageView:OnShowAll()
	self.cur_index = -1
	self.show_state = SHOW_ALL
	self.current_page = 1

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
	self:Flush()
end

function PlayerPackageView:OnShowMaterial()
	self.cur_index = -1
	self.show_state = SHOW_MATIERAL
	self.current_page = 1
	self:Flush()
end

function PlayerPackageView:OnShowConsume()
	self.cur_index = -1
	self.show_state = SHOW_CONSUME
	self.current_page = 1
	self:Flush()
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
	-- ViewManager.Instance:Open(ViewName.Warehouse, TabIndex.role_bag_warehouse)
	if self.is_open_warehouse and self.warehouse_content.gameObject.activeSelf then
		self.warehouse_view:WarehouseClose()
		self.is_open_warehouse = false
	else
		self.warehouse_content:SetActive(true)
		self.show_recycle_btn:SetValue(false)
		GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, false)
		self:SetBagViewState(BAG_SHOW_STORGE)
		self.is_open_warehouse = true
		GlobalEventSystem:Fire(OtherEventType.WAREHOUSE_FLUSH_VIEW, ItemData.Instance:GetMaxStorageValidNum())
	end
end

--打开回收面板
function PlayerPackageView:HandleOpenRecycle()
	self.is_open_recycle:SetValue(true)
	self.is_show_button:SetValue(false)
	self.recycle_content:SetActive(true)
	self.show_recycle_btn:SetValue(false)
	GlobalEventSystem:Fire(OtherEventType.OPEN_RECYCLE_VIEW)
	GlobalEventSystem:Fire(OtherEventType.RECYCLE_FLUSH_CONTENT)
	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT, false)
	self:SetBagViewState(BAG_SHOW_RECYCLE)
	self.recycle_view_state = true
end

--关闭回收面板
function PlayerPackageView:HandleCloseRecycle()
	self.show_recycle_btn:SetValue(true)
	self.is_open_recycle:SetValue(false)
	self.is_show_button:SetValue(true)
	self.recycle_content:SetActive(false)
	self:SetBagViewState(BAG_SHOW_ROLE)

	PackageData.Instance:EmptyRecycleList()
	self.cur_index = -1
	self:Flush()

	GlobalEventSystem:Fire(WarehouseEventType.ROLE_DRESS_CONTENT,true)
	self.recycle_view_state = false
end

-- 合并道具
function PlayerPackageView:HandleCombineItems()
	local func = function ()
		if self.view_state == BAG_SHOW_RECYCLE then
			self:HandleCloseRecycle()
		end
		PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 1)
		self.need_jump = true
	end
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Role.MergeText, func)
end

--整理背包
function PlayerPackageView:HandleCleanPackage()
	-- if self.view_state == BAG_SHOW_SALE or self.view_state == BAG_SHOW_SALE_JL then
	-- 	self:SetBagViewState(BAG_SHOW_ROLE)
	-- end
	local close_callback = function()
		if self.view_state == BAG_SHOW_RECYCLE then
			self:HandleCloseRecycle()
		end
		PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)
		self.isCleanPackage = true
		self.need_jump = true
	end
	if #PackageData.Instance:GetQuickUseItem() <= 0 or BAG_SHOW_STORGE == self.view_state then
		close_callback()
	else
		TipsCtrl.Instance:ShowQuickUsePropView(nil, close_callback)
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

function PlayerPackageView:OnFlush(param,is_jump)
	if nil ~= self.bag_list_view.list_view then
		for key, value in pairs(param) do
			if param["index"] and not self.need_jump then
				for k,v in pairs(value) do
					local value_index = v
					if type(value_index) == "string" then
						value_index = -1
					end

					self.cur_index = value_index or self.cur_index or -1

					if v == "not_jump" then
						is_jump_to_first = false
						break
					end

					if self.cur_index == -1 then
						break
					end

					for k,v in pairs(self.bag_cell) do
						if v:GetActive() and k.transform.parent == self.bag_list_view.scroll_rect.content then
							local temp_data = v:GetData()
							if temp_data.index == self.cur_index then
								self:RefreshCell(v)
							end
						end
					end
				end
			else
				if next(self.bag_cell) ~= nil and (not self.need_jump or self.bag_list_view.list_page_scroll2:GetNowPage() == 0) then
					self:FlushBagList()
				else
					self.cur_index = self.cur_index or -1
					if -1 == self.cur_index or self.show_state ~= SHOW_ALL then
						self.bag_list_view.list_view:Reload(function()
							self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
						end)
						self.bag_list_view.list_view:JumpToIndex(0)
					end
					self.need_jump = false
				end
			end
		end
		self.cur_index = -1
	end
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function PlayerPackageView:FlushBagList()
	for k,v in pairs(self.bag_cell) do
		if v:GetActive() and k.transform.parent == self.bag_list_view.scroll_rect.content then
			self:RefreshCell(v)
		end
	end
end

function PlayerPackageView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function PlayerPackageView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = PlayerPackageCell.New(cellObj)
		cell:SetToggleGroup(self.root_node.toggle_group)
		self.bag_cell[cellObj] = cell
	end
	cell.local_index = index
	self:RefreshCell(cell)
end

--刷新格子
function PlayerPackageView:RefreshCell(cell)
	local index = cell.local_index or 0
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

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
	cell:SetQualityGray(false)
	local recycle_list = PackageData.Instance:GetRecycleItemDataList()
	for k,v in pairs(recycle_list) do
		if cell_data.item_id == v.item_id and cell_data.index == v.index then
			cell:SetIconGrayScale(true)
			cell:SetQualityGray(true)
		end
	end

	cell:SetData(cell_data, true)
	cell:SetHighLight(self.cur_index == grid_index and nil ~= cell_data.item_id and self.view_state ~= BAG_SHOW_RECYCLE)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
	cell:SetInteractable((nil ~= cell_data.item_id or cell_data.locked))
	--背包和仓库icon缩小为0.9倍
	-- cell:SetIconScale(Vector3(0.9, 0.9, 0.9))
end

--点击格子事件
function PlayerPackageView:HandleBagOnClick(data, cell)
	if data.locked then
		local num = data.index - ItemData.Instance:GetMaxKnapsackValidNum() + 1
		local had_item_num = ItemData.Instance:GetItemNumInBagById(ItemDataKnapsackId.Id)
		local item_cfg = ItemData.Instance:GetItemConfig(ItemDataKnapsackId.Id)
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[ItemDataKnapsackId.Id]
		local need_number = PackageData.Instance:GetOpenCellNeedItemNum(ItemDataKnapsackId.Id, data.index)
		local func_gold = function ()
			cell:SetHighLight(false)
			PackageCtrl.Instance:SendKnapsackStorageExtendGridNum(GameEnum.STORAGER_TYPE_BAG, num, shop_item_cfg.gold * (need_number - had_item_num))
		end
		local func_enough = function ()
			cell:SetHighLight(false)
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
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
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
				self:Flush("index", {["index" .. data.index] = data.index})
				GlobalEventSystem:Fire(OtherEventType.RECYCLE_FLUSH_CONTENT, true)
			end
		else
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
		end
	end
end

function PlayerPackageView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num, useless_param, isLast) --isLast表示是否是当前协议的最后一个物品
	-- if self.isCleanPackage ~= nil then  --点击了整理按钮
	-- 	if self.view_state == BAG_SHOW_STORGE and index < COMMON_CONSTS.MAX_BAG_COUNT and self.isCleanPackage == true then
	-- 		local page = math.floor(index / (BAG_COLUMN * BAG_ROW)) + 1
	-- 		self.current_page = page
	-- 		self.page_toggle_list[self.current_page].isOn = true
	-- 		self:BagJumpPage(self.current_page)
	-- 	elseif self.view_state == BAG_SHOW_STORGE and index - COMMON_CONSTS.MAX_BAG_COUNT >= 0 and self.isCleanPackage == false then
	-- 		-- 刷新仓库
	-- 		if self.warehouse_view then
	-- 			self.warehouse_view:FlushWarehouseView(index)
	-- 		end
	-- 	end
	-- 	if isLast then  --如果是本次协议的最后一个物品
	-- 		self.isCleanPackage = nil
	-- 	end
	-- else
		if self.view_state == BAG_SHOW_STORGE and index < COMMON_CONSTS.MAX_BAG_COUNT then
			local page = math.floor(index / (BAG_COLUMN * BAG_ROW)) + 1
			self.current_page = page
			self.page_toggle_list[self.current_page].isOn = true
			self:BagJumpPage(self.current_page)
		elseif self.view_state == BAG_SHOW_STORGE and index - COMMON_CONSTS.MAX_BAG_COUNT >= 0 then
			-- 刷新仓库
			if self.warehouse_view then
				self.warehouse_view:FlushWarehouseView(index)
			end
		end
	-- end
end


function PlayerPackageView:MoJingChange()
	if self.view_state == BAG_SHOW_RECYCLE then
		PackageData.Instance:EmptyRecycleList()
		self.recycle_view:FlushRecycleView()
	end
end


function PlayerPackageView:BagJumpPage(page)
	if not self.bag_list_view.list_view.isActiveAndEnabled then
		return
	end

	self.bag_list_view.list_page_scroll2:JumpToPage(page - 1)
end


----------------------PackageCell------------------------------------
PlayerPackageCell = PlayerPackageCell or BaseClass(ItemCell)

function PlayerPackageCell:__init()
end

function PlayerPackageCell:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.lock_count_down then
		self.lock_count_down:DeleteMe()
		self.lock_count_down = nil
	end
	self.local_index = nil
end

function PlayerPackageCell:SetData(data, ...)
	ItemCell.SetData(self, data, ...)
	self:Flush()
end

function PlayerPackageCell:Flush()
	if self.data then
		if self.data.index == ItemData.Instance:GetMaxKnapsackValidNum() then
			self:ShowLockCellCountDown(true)
		else
			self:ShowLockCellCountDown(false)
		end
	end
end

function PlayerPackageCell:ShowLockCellCountDown(enable)
	if enable == true then
		if not self.lock_count_down then
			UtilU3d.PrefabLoad("uis/views/player_prefab", "LockCountDown",
				function(obj)
					obj.transform:SetParent(self.root_node.transform, false)
					obj = U3DObject(obj)
				 	self.lock_count_down = LockCountDown.New(obj)
					self:StartCountDown()
				end)
		else
			self.lock_count_down:SetActive(true)
			self:StartCountDown()
		end
	elseif self.lock_count_down then
		self.lock_count_down:DeleteMe()
		self.lock_count_down = nil
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
end

function PlayerPackageCell:StartCountDown()
	if self.time_quest == nil then
		self:FlushLockSlider()
		-- self.lock_count_down.root_node.transform.position = self.root_node.transform.position
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self:FlushLockSlider()
		end, 1)
	end
end
--刷新倒计时
function PlayerPackageCell:FlushLockSlider()
	local online_time = PackageCtrl.Instance:GetOnlineTime()							--人物在线时间
	local next_open_time = PackageData.Instance:GetNextKnapsackAutoAddTime()			--开启当前锁定格子所需的在线时间
	local before_open_time = PackageData.Instance:GetBeforeKnapsackAutoAddTime()		--开启上一个已开启的格子所需的在线时间
	self.lock_count_down.root_node.slider.value = 1 - (online_time - before_open_time) / (next_open_time - before_open_time)
	local need_online_time = next_open_time - online_time
	local str = ""
	if need_online_time >= 0 then
		local time_tab = TimeUtil.Format2TableDHMS(need_online_time)
		if time_tab.day ~= 0 then
			str = string.format(Language.Common.TimeStr8, time_tab.day, time_tab.hour)
		elseif time_tab.hour ~= 0 then
			str = string.format(Language.Common.TimeStr9, time_tab.hour, time_tab.min)
		elseif time_tab.min ~= 0 then
			str = string.format(Language.Common.TimeStr6, time_tab.min, time_tab.s)
		else
			str = string.format(Language.Common.TimeStr7, time_tab.s)
		end
	end
	self.lock_count_down:SetText(str)
end

----------------------LockCountDown------------------------------------
LockCountDown = LockCountDown or BaseClass(BaseRender)

function LockCountDown:__init()
	self.count_down_slider_text = self:FindVariable("LockCellCountDownText")
end

function LockCountDown:__delete()
	GameObject.Destroy(self.root_node.gameObject)
end

function LockCountDown:SetText(str)
	self.count_down_slider_text:SetValue(str)
end
