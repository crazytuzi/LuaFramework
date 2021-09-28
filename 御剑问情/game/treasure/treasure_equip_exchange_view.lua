TreasureEquipExchangeView = TreasureEquipExchangeView or BaseClass(BaseRender)

local ROW = 2						-- 行数
local COLUMN = 4					-- 列数
function TreasureEquipExchangeView:__init(instance)
	self.select_order_index = 1
	self.order_list = {}
	self.exchange_list = {}

	self.tab_toggle_1 = self:FindObj("tab_1").toggle
	self.tab_toggle_2 = self:FindObj("tab_2").toggle
	self.tab_toggle_3 = self:FindObj("tab_3").toggle

	self.pagecount = self:FindVariable("PageCount")
	self.tab_text_1 = self:FindVariable("tab_text_1")
	self.tab_text_2 = self:FindVariable("tab_text_2")
	self.tab_text_3 = self:FindVariable("tab_text_3")

	for i = 1, 3 do
		self:ListenEvent("ClickTab" .. i, BindTool.Bind(self.ClickTab, self, i))
	end

	self.list_view = self:FindObj("list_view")
	self.exchange_contain_list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	local page = math.max(self:GetNumberOfCells(), 1)
	self.pagecount:SetValue(page)
	self.list_view.list_page_scroll:SetPageCount(page)
end

function TreasureEquipExchangeView:__delete()
	for k, v in pairs(self.exchange_contain_list) do
		v:DeleteMe()
	end
	self.exchange_contain_list = nil
end

function TreasureEquipExchangeView:ClickTab(index)
	if self.select_order_index == index then
		return
	end

	self.select_order_index = index

	self:FlushData()
	self:FlushList(true)
end

function TreasureEquipExchangeView:GetNumberOfCells()
	local count = #self.exchange_list
	return math.ceil(count / (ROW*COLUMN))
end

function TreasureEquipExchangeView:RefreshCell(cell, cell_index)
	local exchange_contain = self.exchange_contain_list[cell]
	if exchange_contain == nil then
		exchange_contain = TreasureEquipExchangeGroup.New(cell.gameObject, self)
		self.exchange_contain_list[cell] = exchange_contain
	end
	local max_count = ROW*COLUMN
	for i = 1, max_count do
		local index = max_count * cell_index + i
		exchange_contain:SetData(self.exchange_list[index], i)
	end
end

function TreasureEquipExchangeView:InitView()
	self.select_order_index = 1
	self:FlushData()
	self:FlushTabText()
	self:FlushOrderSelect()
	self:FlushList(true)
end

function TreasureEquipExchangeView:FlushOrderSelect()
	for i = 1, 3 do
		self["tab_toggle_" .. i].isOn = (self.select_order_index == i)
	end
end

function TreasureEquipExchangeView:FlushData()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.order_list = ExchangeData.Instance:GetOrderListByLevel(main_vo.level)
	self.exchange_list = ExchangeData.Instance:GetExchangeEquipCfgListByOrder(EXCHANGE_CONVER_TYPE.SCORE_TO_ITEM_TYPE_RED_EQUIP,
																				EXCHANGE_PRICE_TYPE.SCORE_TO_ITEM_PRICE_TYPE_ITEM_STUFF,
																				main_vo.prof,
																				self.order_list[self.select_order_index])
end

function TreasureEquipExchangeView:FlushTabText()
	for k, v in ipairs(self.order_list) do
		local tab_var = self["tab_text_" .. k]
		if tab_var then
			local des = string.format(Language.Treasure.EquipTabDes, v)
			tab_var:SetValue(des)
		end
	end
end

function TreasureEquipExchangeView:FlushList(is_reload)
	if is_reload then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function TreasureEquipExchangeView:OnFlush()
	self:FlushOrderSelect()
	self:FlushList()
end

----------------------------------------------------------------------------
TreasureEquipExchangeGroup = TreasureEquipExchangeGroup or BaseClass(BaseRender)
function TreasureEquipExchangeGroup:__init()
	self.item_list = {}
	for i=1, 8 do
		self.item_list[i] = TreasureEquipExchangeItem.New(self:FindObj("item_"..i))
	end
end
function TreasureEquipExchangeGroup:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function TreasureEquipExchangeGroup:SetData(data, index)
	self.item_list[index]:SetData(data)
end

--------------------------------------------------------------------------------
TreasureEquipExchangeItem = TreasureEquipExchangeItem or BaseClass(BaseCell)

function TreasureEquipExchangeItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.had_use_times = self:FindVariable("HadUseTimes")
	self.show_no_limit = self:FindVariable("ShowNoLimit")
	self.max_times = self:FindVariable("MaxTimes")
	self.show_limit = self:FindVariable("ShowLimit")
	self.left_day = self:FindVariable("LeftDay")
	self.left_hour = self:FindVariable("LeftHour")
	self.left_minute = self:FindVariable("LeftMinute")
	self.left_second = self:FindVariable("LeftSecond")
	self.least_time = self:FindVariable("least_time")
	self.need_item_res = self:FindVariable("NeedItemRes")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self:ListenEvent("click", BindTool.Bind(self.OnExchangeClick, self))
end

function TreasureEquipExchangeItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function TreasureEquipExchangeItem:OnExchangeClick()
	if nil == self.data then
		return
	end

	local conver_count = TreasureData.Instance:GetEquipConverCount(self.data.seq)
	if conver_count >= self.data.limit_convert_count then
		SysMsgCtrl.Instance:ErrorRemind(Language.Exchange.MaxExchangeTimes)
		return
	end

	local need_count = self.data.need_stuff_count
	local need_item_id = self.data.need_stuff_id
	if not ItemData.Instance:GetItemNumIsEnough(need_item_id, need_count) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Exchange.NotEnoughItem)
		return
	end

	local used_item_cfg = ItemData.Instance:GetItemConfig(need_item_id)
	if nil == used_item_cfg then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local function ok_func()
		TreasureCtrl.Instance:ReqRedEquipItemConvert(self.data.seq)
	end

	local used_name = ToColorStr(used_item_cfg.name, ITEM_COLOR[used_item_cfg.color])
	local name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	local des = string.format(Language.Exchange.Max_Multiple_Tip, need_count, used_name, name)
	TipsCtrl.Instance:ShowCommonAutoView("equip_exchange", des, ok_func)
end

function TreasureEquipExchangeItem:OnFlush()
	if self.data == nil then
		self:SetActive(false)
		return
	end
	self:SetActive(true)

	local data = BossData.Instance:GetShowEquipItemList(self.data.item_id, 3)
	self.item_cell:SetData(data)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	self.name:SetValue(name)

	local conver_count = TreasureData.Instance:GetEquipConverCount(self.data.seq)
	self.had_use_times:SetValue(conver_count)
	self.max_times:SetValue(self.data.limit_convert_count)

	self.coin:SetValue(self.data.need_stuff_count)
	self.need_item_res:SetAsset(ResPath.GetItemIcon(self.data.need_stuff_id))
end