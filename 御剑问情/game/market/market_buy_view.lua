MarketBuyView = MarketBuyView or BaseClass(BaseRender)
local NUMBER = 4  -- 每页显示的数量
function MarketBuyView:__init(instance)
		self.color_list = {GameEnum.ITEM_COLOR_GREEN, GameEnum.ITEM_COLOR_BLUE, GameEnum.ITEM_COLOR_PURPLE, GameEnum.ITEM_COLOR_ORANGE,
	GameEnum.ITEM_COLOR_RED}

	self.input_name = self:FindObj("InputName"):GetComponent("InputField")
	self.serach_window = self:FindObj("SearchWindow")
	self.toggle_list = {}
	for i = 1, 5 do
		self.toggle_list[i] = self:FindObj("Toggle" .. i):GetComponent("Toggle")
	end

	self.info_list = {}
	self.variables = {}
	self.item_cell = {}
	for i = 1, NUMBER do
		self.info_list[i] = self:FindObj("Info" .. i)
		self.item_cell[i] = {}
		self.item_cell[i].obj = self.info_list[i]:GetComponent(typeof(UINameTable)):Find("ItemCell")
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(U3DObject(self.item_cell[i].obj))

		self.variables[i] = {}
		self.variables[i].count = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Count")
		self.variables[i].name = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
		self.variables[i].price = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Price")
		self.variables[i].total_price = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("TotalPrice")
		self.variables[i].show_price = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("ShowPrice")

		self:ListenEvent("ShowDetails" .. i,
		function()
			self:ShowDetails(i)
		end)
	end

	self.variable_page = self:FindVariable("Page")
	self.arrow_down = self:FindVariable("ArrowDown")
	self.arrow_right = self:FindVariable("ArrowRight")
	self.show_no_search = self:FindVariable("ShowNoSearch")
	self.is_show_condition1 = self:FindVariable("is_show_condition1")
	self.is_show_condition2 = self:FindVariable("is_show_condition2")
	self.is_show_condition3 = self:FindVariable("is_show_condition3")
	self.is_show_kinds = self:FindVariable("is_show_kinds")
	self.is_show_detail = self:FindVariable("is_show_detail")
	self.show_condition_list1 = self:FindVariable("ShowConditionList1")
	self.show_condition_list2 = self:FindVariable("ShowConditionList2")
	self.show_condition_list3 = self:FindVariable("ShowConditionList3")
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.is_show_condition_list3 = false
	self.show_page_panel = self:FindVariable("ShowPagePanel")
	self.order_text = self:FindVariable("OrderText")
	self.color_text = self:FindVariable("ColorText")
	self.star_text = self:FindVariable("StarText")

	self.show_no_search:SetValue(false)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)

	self:ListenEvent("OnSearch",
		BindTool.Bind(self.OnSearch, self))
	self:ListenEvent("OnPageUp",
		BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OnPageDown",
		BindTool.Bind(self.OnPageDown, self))
	self:ListenEvent("OpenConditonList1",
		BindTool.Bind(self.OpenConditonList1, self))
	self:ListenEvent("OpenConditonList2",
		BindTool.Bind(self.OpenConditonList2, self))
	self:ListenEvent("OpenConditonList3",
		BindTool.Bind(self.OpenConditonList3, self))
	self:ListenEvent("ClickAllOrder",
		BindTool.Bind(self.ClickAllOrder, self))
	self:ListenEvent("ClickAllColor",
		BindTool.Bind(self.ClickAllColor, self))
	self:ListenEvent("ClickAllStar",
		BindTool.Bind(self.ClickAllStar, self))
	self:ListenEvent("CloseSearchWindow",
		BindTool.Bind(self.CloseSearchWindow, self))
	self.sale_item_list_market = {}
	self.total_page = 0
	self.current_page = 0
	self.info_count = 0
	self:CreateParentList()
	self:CreateGradeList()
	self:CreateColorList()
	self:CreateStarList()
	self.parent_cell_list = {}
	self.child_cell_list = {}
	self.grade_cell_list = {}
	self.color_cell_list = {}
	self.star_cell_list = {}
	self.father_id = 0
	self.child_id = 0
	self.color = 0
	self.order = 0
	self.is_equipment = 0
	self.left_index = 0
end

function MarketBuyView:__delete()
	for k,v in pairs(self.parent_cell_list) do
		v:DeleteMe()
	end
	self.parent_cell_list = {}
	for k,v in pairs(self.child_cell_list) do
		v:DeleteMe()
	end
	self.child_cell_list = {}
	for k,v in pairs(self.grade_cell_list) do
		v:DeleteMe()
	end
	self.grade_cell_list = {}
	for k,v in pairs(self.color_cell_list) do
		v:DeleteMe()
	end
	self.color_cell_list = {}
	for k,v in pairs(self.star_cell_list) do
		v:DeleteMe()
	end
	self.star_cell_list = {}

	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}
	self.child_list = nil
	self.serach_window = nil
end

function MarketBuyView:CreateParentList()
	self.parent_list = self:FindObj("MarketTypeList")
	local parent_group = self.parent_list:GetComponent("ToggleGroup")
	local list_delegate = self.parent_list.list_simple_delegate
	local need_auto_select = true
	list_delegate.NumberOfCellsDel = function ()
		return #MarketData.Instance:GetMarketParentConfig()
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.parent_cell_list[cell]
		if cell_item == nil then
			cell_item = ParentListCell.New(cell.gameObject)
			self.parent_cell_list[cell] = cell_item
		end
		local data_list = MarketData.Instance:GetMarketParentConfig()
		local data = data_list[data_index + 1]
		cell_item:SetData(data)
		cell_item:SetToggleGroup(parent_group)

		if need_auto_select and data_index == 0 then
			cell_item:SetToggle(true)
			need_auto_select = false
		end
		cell_item:SetToggle(data_index == self.left_index)
		cell_item:ListenClick(BindTool.Bind(self.OnClickParentCell, self, data,data_index))
	end
end

function MarketBuyView:OnClickParentCell(data,data_index)
	self.left_index = data_index
	MarketCtrl.Instance:SendSaleTypeCountReq()
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)

	self.is_show_kinds:SetValue(true)
	self.is_show_detail:SetValue(false)
	self.father_id = data.parent_cfg.father_id
	self.child_id = 0
	self.is_equipment = 0
	self:SetSearchType(0)
	if self.father_id == 0 then
		self:SetSearchColor(0)
		self:SetSearchOrder(0)
		self:SetSearchStar(0)
		self.is_show_kinds:SetValue(false)
		self.is_show_detail:SetValue(true)
		self:OnSearch(0)
	elseif nil == self.child_list then
		self:CreateChildList()
	else
		if self.child_list.scroller.isActiveAndEnabled then
			self.child_list.scroller:ReloadData(0)
		end
	end
end

function MarketBuyView:CreateChildList()
	self.child_list = self:FindObj("KindsList")
	local list_delegate = self.child_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return math.ceil(#MarketData.Instance:GetMarketChildConfig(self.father_id) / 3)
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.child_cell_list[cell]
		if cell_item == nil then
			cell_item = ChildListCell.New(cell.gameObject)
			self.child_cell_list[cell] = cell_item
		end
		local data_list = MarketData.Instance:GetMarketChildConfig(self.father_id)
		local data = {data_list[data_index * 3 + 1], data_list[data_index * 3 + 2], data_list[data_index * 3 + 3], }
		cell_item:SetData(data)
		cell_item:ListenClick(BindTool.Bind(self.OnClickChildCell, self))
	end
end

function MarketBuyView:FlushListData()
	if self.child_list then
		self.child_list.scroller:ReloadData(0)
	end
end

function MarketBuyView:OnClickChildCell(data)
	self:SetSearchColor(0)
	self:SetSearchOrder(0)
	self:SetSearchStar(0)
	self.child_id = data.child_id
	self.is_equipment = data.is_equipment
	self:SetSearchType(self.child_id)
	self:OnSearch(1)
end

function MarketBuyView:CreateGradeList()
	self.grade_list = self:FindObj("ConditionList1")
	local list_delegate = self.grade_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return 35
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.grade_cell_list[cell]
		if cell_item == nil then
			cell_item = OrderListCell.New(cell.gameObject)
			self.grade_cell_list[cell] = cell_item
		end
		-- cell_item:SetData(data_index + 1)
		-- cell_item:ListenClick(BindTool.Bind(self.OnClickGradeCell, self, data_index + 1))
		cell_item:SetData(data_index)
		cell_item:ListenClick(BindTool.Bind(self.OnClickGradeCell, self, data_index))
	end
end

function MarketBuyView:OnClickGradeCell(order)
	self.order = order
	self:SetSearchOrder(order)
	self:OnSearch(0)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.is_show_condition_list3 = false
end

function MarketBuyView:ClickAllOrder()
	self.order = 0
	self:SetSearchOrder(0)
	self:OnSearch(0)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.is_show_condition_list3 = false
end

function MarketBuyView:CreateColorList()
	self.colors_list = self:FindObj("ConditionList2")
	local list_delegate = self.colors_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return 6
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.color_cell_list[cell]
		if cell_item == nil then
			cell_item = ColorListCell.New(cell.gameObject)
			self.color_cell_list[cell] = cell_item
		end
		-- cell_item:SetData(data_index + 1)
		-- cell_item:ListenClick(BindTool.Bind(self.OnClickColorCell, self, data_index + 1))
		cell_item:SetData(data_index)
		cell_item:ListenClick(BindTool.Bind(self.OnClickColorCell, self, data_index))
	end
end

function MarketBuyView:OnClickColorCell(color)
	self.color=color
	if color==0 then
		self:SetSearchColor(color)
	else
		self:SetSearchColor(6-color)
	end
	self:OnSearch(0)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.is_show_condition_list3 = false
end

function MarketBuyView:ClickAllColor()
	self.color = 0
	self:SetSearchColor(0)
	self:OnSearch(0)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)
end

function MarketBuyView:CreateStarList()
	self.stars_list = self:FindObj("ConditionList3")
	local list_delegate = self.stars_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return 4
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.star_cell_list[cell]
		if cell_item == nil then
			cell_item = StarListCell.New(cell.gameObject)
			self.star_cell_list[cell] = cell_item
		end
		-- cell_item:SetData(data_index + 1)
		-- cell_item:ListenClick(BindTool.Bind(self.OnClickColorCell, self, data_index + 1))
		cell_item:SetData(data_index)
		cell_item:ListenClick(BindTool.Bind(self.OnClickStarCell, self, data_index))
	end
end

function MarketBuyView:OnClickStarCell(star)
	self.color=star
	if star==0 then
		self:SetSearchStar(star)
	else
		self:SetSearchStar(4-star)
	end
	self:OnSearch(0)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.is_show_condition_list3 = false
end

function MarketBuyView:ClickAllStar()
	self.color = 0
	self:SetSearchStar(0)
	self:OnSearch(0)
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.show_condition_list3:SetValue(false)
end

-- 搜索
function MarketBuyView:OnSearch(flag)
	local search_config = MarketData.Instance:GetSearchConfig()
	search_config.req_page = 1
	search_config.total_page = 0
	if flag then
		search_config.level = 0
		search_config.prof = 0
		search_config.color_interval = 0
		search_config.fuzzy_type_count = 0
		search_config.fuzzy_type_list = {}
	else
		local fuzzy_type_list, has_input = self:GetFuzzyList()
		search_config.fuzzy_type_list = fuzzy_type_list
		search_config.fuzzy_type_count = #fuzzy_type_list
		local color = 0
		for i = 1, 5 do
			if self.toggle_list[i].isOn then
				color = self.color_list[i]
				break
			end
		end
		search_config.color = color
	end
	if search_config.fuzzy_type_count == 0 and flag ~= 0 and has_input then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.SelectEmpty)
		self:CloseSearchWindow()
		MarketData.Instance:SetCurPage(1)
		MarketData.Instance:SetTotalPage(0)
		MarketData.Instance:SetSaleitemListMarket({})
		self:Flush()
	else
		MarketCtrl.Instance:SendPublicSaleSearchReq(flag)
	end
end

function MarketBuyView:Flush()
	self.is_show_kinds:SetValue(false)
	self.is_show_detail:SetValue(true)
	self.sale_item_list_market = MarketData.Instance:GetSaleitemListMarket() or {}
	self:FlushPageCount()
	self:FlushPage(self.current_page)
	local search_config = MarketData.Instance:GetSearchConfig()
	self.is_show_condition1:SetValue(not next(search_config.fuzzy_type_list) and self.is_equipment == 1)
	self.is_show_condition2:SetValue(not next(search_config.fuzzy_type_list) and self.is_equipment ~= 1)
	self.is_show_condition3:SetValue(not next(search_config.fuzzy_type_list) and self.is_equipment == 1)
end

-- 更新页面
function MarketBuyView:FlushPage(page)
	self.variable_page:SetValue(self.current_page .. "/" .. self.total_page)
	self.info_count = #self.sale_item_list_market
	if self.info_count == 0 then
		self.show_no_search:SetValue(true)
	else
		self.show_no_search:SetValue(false)
	end
	if(page == self.total_page) then  -- 如果是最后一页
		for i = 1, NUMBER do
			if(i <= NUMBER - self.info_count) then
				self.info_list[NUMBER + 1 - i]:SetActive(false)
			else
				self.info_list[NUMBER + 1 - i]:SetActive(true)
			end
		end
	else
		for i = 1, NUMBER do
			self.info_list[i]:SetActive(true)
		end
	end
	for i = 1, self.info_count do
		self:FlushRow(i)
	end
end

-- 更新每一行的信息
function MarketBuyView:FlushRow(index)
	if index > NUMBER then return end
	local info = self.sale_item_list_market[index] or {}
	if info and next(info) then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(info.item_id)
		self.item_cell[index].cell:SetData(info)
		self.variables[index].count:SetValue("X" .. info.num)
		if item_cfg.color == 1 then
			self.variables[index].name:SetValue(ToColorStr(item_cfg.name, SOUL_NAME_COLOR[7]))
		else
			self.variables[index].name:SetValue(ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color or 0]))
		end
		self.variables[index].total_price:SetValue(info.gold_price)
		local one_price = math.floor(info.gold_price / info.num) >= 1 and math.floor(info.gold_price / info.num) or 1
		self.variables[index].price:SetValue(one_price)
	end
end

-- 向上翻页
function MarketBuyView:OnPageUp()
	local search_config = MarketData.Instance:GetSearchConfig()

	if(MarketData.Instance:GetTotalPage() < 1) then
		return
	end
	search_config.req_page = math.max(search_config.req_page - 1, 1)
	MarketCtrl.Instance:SendPublicSaleSearchReq()
end

-- 向下翻页
function MarketBuyView:OnPageDown()
	local search_config = MarketData.Instance:GetSearchConfig()
	if(MarketData.Instance:GetTotalPage() < 1) then
		return
	end
	search_config.req_page = math.min(search_config.req_page + 1, MarketData.Instance:GetTotalPage())
	MarketCtrl.Instance:SendPublicSaleSearchReq()
end

function MarketBuyView:OpenConditonList1()
	self.is_show_condition_list1 = not self.is_show_condition_list1
	self.show_condition_list1:SetValue(self.is_show_condition_list1)
end

function MarketBuyView:OpenConditonList2()
	self.is_show_condition_list2 = 	not self.is_show_condition_list2
	self.show_condition_list2:SetValue(self.is_show_condition_list2)
end

function MarketBuyView:OpenConditonList3()
	self.is_show_condition_list3 = 	not self.is_show_condition_list3
	self.show_condition_list3:SetValue(self.is_show_condition_list3)
end

-- 刷新页面数目
function MarketBuyView:FlushPageCount()
	self.current_page = MarketData.Instance:GetCurPage()
	self.total_page = MarketData.Instance:GetTotalPage()
	self.total_page = math.max(self.total_page , 1)
end

-- 显示物品详细信息
function MarketBuyView:ShowDetails(index)
	local info = self.sale_item_list_market[index] or {}
	if info and next(info) then
		local one_price = math.floor(info.gold_price / info.num) >= 1 and math.floor(info.gold_price / info.num) or 1
		info.price = one_price
		TipsCtrl.Instance:OpenItem(info, TipsFormDef.FROME_MARKET_GOUMAI, {fromIndex = info.sale_index})
	end
end

-- 关闭搜索弹窗
function MarketBuyView:CloseSearchWindow()
	self.serach_window.animator:SetBool("show", false)
	GlobalTimerQuest:AddDelayTimer(function()
		if self.serach_window then
			self.serach_window:SetActive(false)
		end
	end, 0.12)
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchType(index)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().item_type = index
	self.input_name.text = ""
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchColor(color)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().color = color
	self.input_name.text = ""
	if color == 0 then
		self.color_text:SetValue(Language.Market.ColorDefTxt)
	else
		self.color_text:SetValue(Language.Common.ColorName[color])
	end
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchStar(color)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().color = color
	self.input_name.text = ""
	if color == 0 then
		self.star_text:SetValue(Language.Market.StarDefTxt)
	else
		self.star_text:SetValue(Language.Common.StarName[color])
	end
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchOrder(order)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().order = order
	self.input_name.text = ""
	if order == 0 then
		self.order_text:SetValue(Language.Market.OrderDefTxt)
	else
		self.order_text:SetValue(CommonDataManager.GetDaXie(order) .. Language.Common.Jie)
	end
end

function MarketBuyView:FlushCurPage()
	self:SetSearchType(self.child_id)
	if self.child_id == 0 then
		self:OnSearch(0)
	else
		self:OnSearch(1)
	end
end

-- 获取模糊查找列表
function MarketBuyView:GetFuzzyList()
	local text_input = self.input_name.text
	if "" == text_input then
		return {}, false
	end

	local search_type = MarketData.Instance:GetSearchConfig().item_type
	local all_item_cfg = MarketData.Instance:GetItemAllConfig()

	local temp_fuzzy_list = {}
	local temp_fuzzy_count = 0

	for k, v in pairs(all_item_cfg) do
		for item_id, item_cfg in pairs(v) do
			if nil ~= item_cfg.search_type and (0 == search_type or search_type == item_cfg.search_type) and nil ~= string.find(item_cfg.name, text_input) then
				local info = temp_fuzzy_list[item_cfg.search_type]
				if nil == info and temp_fuzzy_count < COMMON_CONSTS.FUZZY_SEARCH_ITEM_TYPE_COUNT then
					info = {
						item_sale_type = item_cfg.search_type,
						item_count = 0,
						item_id_list = {},
					}
					temp_fuzzy_list[item_cfg.search_type] = info
					temp_fuzzy_count = temp_fuzzy_count + 1
				end
				if nil ~= info then
					if info.item_count < COMMON_CONSTS.FUZZY_SEARCH_ITEM_ID_COUNT then
						table.insert(info.item_id_list, item_id)
						info.item_count = info.item_count + 1
					end
				end
			end
		end
	end

	local fuzzy_list = {}
	for k, v in pairs(temp_fuzzy_list) do
		table.sort(v.item_id_list)
		table.insert(fuzzy_list, v)
	end

	return fuzzy_list, true
end



ParentListCell = ParentListCell or BaseClass(BaseCell)

function ParentListCell:__init(instance)
	self.name = self:FindVariable("Name")
end

function ParentListCell:__delete()

end

function ParentListCell:OnFlush()
	self.name:SetValue(self.data.parent_cfg.father_name)
end

function ParentListCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ParentListCell:SetToggle(value)
	self.root_node.toggle.isOn = value
end

function ParentListCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end


ChildListCell = ChildListCell or BaseClass(BaseCell)

function ChildListCell:__init(instance)
	self.name1 = self:FindVariable("name1")
	self.name2 = self:FindVariable("name2")
	self.name3 = self:FindVariable("name3")
	self.icon_name1 = self:FindVariable("icon_name1")
	self.icon_name2 = self:FindVariable("icon_name2")
	self.icon_name3 = self:FindVariable("icon_name3")
	self.is_show_cell1 = self:FindVariable("is_show_cell1")
	self.is_show_cell2 = self:FindVariable("is_show_cell2")
	self.is_show_cell3 = self:FindVariable("is_show_cell3")
	self.icon_quality1 = self:FindVariable("icon_quality1")
	self.icon_quality2 = self:FindVariable("icon_quality2")
	self.icon_quality3 = self:FindVariable("icon_quality3")
	self.item_num1 = self:FindVariable("item_num1")
	self.item_num2 = self:FindVariable("item_num2")
	self.item_num3 = self:FindVariable("item_num3")
	self:ListenEvent("OnClick1", BindTool.Bind(self.OnClickCell, self, 1))
	self:ListenEvent("OnClick2", BindTool.Bind(self.OnClickCell, self, 2))
	self:ListenEvent("OnClick3", BindTool.Bind(self.OnClickCell, self, 3))
end

function ChildListCell:__delete()

end

function ChildListCell:OnFlush()
	for i = 1, 3 do
		if self.data[i] then
			self["name" .. i]:SetValue(self.data[i].child_name)
			local item_cfg = ItemData.Instance:GetItemConfig(self.data[i].item_id)
				-- 设置图标
			if item_cfg then
				local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
				self["icon_name" .. i]:SetAsset(bundle, asset)

				local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
				self["icon_quality" .. i]:SetAsset(bundle1, asset1)
				local item_num = MarketData.Instance:GetCountBySaleType(self.data[i].child_id)
				self["item_num" .. i]:SetValue(item_num)
			end
		end
		self["is_show_cell" .. i]:SetValue(self.data[i] ~= nil)
	end
end

function ChildListCell:ListenClick(handler)
	self.handler = handler
end


function ChildListCell:OnClickCell(index)
	if self.data and self.handler then
		self.handler(self.data[index])
	end
end


OrderListCell = OrderListCell or BaseClass(BaseCell)

function OrderListCell:__init(instance)
	self.name = self:FindVariable("Name")
end

function OrderListCell:__delete()

end

function OrderListCell:OnFlush()
	if self.data == 0 then
		self.name:SetValue(Language.Common.MarketAllJie)
	else
		self.name:SetValue(CommonDataManager.GetDaXie(self.data) .. Language.Common.Jie)
	end
end

function OrderListCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end


ColorListCell = ColorListCell or BaseClass(BaseCell)

function ColorListCell:__init(instance)
	self.name = self:FindVariable("Name")
end

function ColorListCell:__delete()

end

function ColorListCell:OnFlush()
	self.name:SetValue(Language.Common.ColorNameToMarket[self.data])
end

function ColorListCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end

StarListCell = StarListCell or BaseClass(BaseCell)

function StarListCell:__init(instance)
	self.name = self:FindVariable("Name")
end

function StarListCell:__delete()

end

function StarListCell:OnFlush()
	self.name:SetValue(Language.Common.StarNameToMarket[self.data])
end

function StarListCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end