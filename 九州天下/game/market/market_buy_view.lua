MarketBuyView = MarketBuyView or BaseClass(BaseRender)

local NUMBER = 5  -- 每页显示的数量
local DONTASSIGN = 0 -- 各种不指定

function MarketBuyView:__init(instance)
	if instance == nil then
		return
	end
	self.color_list = {GameEnum.ITEM_COLOR_GREEN, GameEnum.ITEM_COLOR_BLUE, GameEnum.ITEM_COLOR_PURPLE, GameEnum.ITEM_COLOR_ORANGE,
	GameEnum.ITEM_COLOR_RED}

	self.input_name = self:FindObj("InputName"):GetComponent("InputField")
	self.serach_window = self:FindObj("SearchWindow")
	self.right_panel = self:FindObj("RightPanel")
	self.type_panel = self:FindObj("TypePanel")

	self.qualityButton = self:FindObj("QualityButton")
	-- self.scrollRect = self:FindObj("ItemPanel"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.itemTypeText = self:FindObj("ItemTypeText"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemTypeText.text = Language.Market.CurrShaiXuanText
	self.filtrate_toggle = {}
	for i = 1, 2 do
		self.filtrate_toggle[i] = self:FindObj("FiltrateToggle" .. i)
	end

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
		self.variables[i].order = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Order")
		self.variables[i].show_price = self.info_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("ShowPrice")

		self:ListenEvent("ShowDetails" .. i,
		function()
			self:ShowDetails(i)
		end)
	end
	-- self.gold = self:FindVariable("Gold")
	self.variable_page = self:FindVariable("Page")
	-- self.arrow_down = self:FindVariable("ArrowDown")
	-- self.arrow_right = self:FindVariable("ArrowRight")
	self.quality_text = self:FindVariable("QualityText")
	self.class_text = self:FindVariable("ClassText")
	self.show_no_search = self:FindVariable("ShowNoSearch")
	self.is_unit_price_up = self:FindVariable("IsUnitPriceUp")
	self.is_unit_price_down = self:FindVariable("IsUnitPriceDown")
	self.is_total_price_up = self:FindVariable("IsTotalPriceUp")
	self.is_total_price_down = self:FindVariable("IsTotalPriceDown")
	self.show_no_search:SetValue(false)

	self:ListenEvent("OnSearch",BindTool.Bind(self.OnSearch, self))
	self:ListenEvent("WindowSeach",BindTool.Bind(self.WindowSeach, self))
	self:ListenEvent("OnPageUp",BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OnPageDown",BindTool.Bind(self.OnPageDown, self))
	self:ListenEvent("UnitPriceUp",BindTool.Bind(self.OnClickFlushUnitSort, self, 0))
	self:ListenEvent("UnitPriceDown",BindTool.Bind(self.OnClickFlushUnitSort, self, 1))
	self:ListenEvent("TotalPriceUp",BindTool.Bind(self.OnClickFlushTotalSort, self, 0))
	self:ListenEvent("TotalPriceDown",BindTool.Bind(self.OnClickFlushTotalSort, self, 1))
	self:ListenEvent("HideToggle",BindTool.Bind(self.HideToggle, self))

	self.cur_index = 0
	self.last_click_btn = -1
	self.is_loop = true
	self.father_index = 1
	self.last_click_list = {
		index = 0,
		prof = 0,
		color = 0,
		order = 0,
		sort_type = 0, 					--单价排序类型
		rank_type = 0,					--总价排序类型
		fuzzy_type_list = {},  			--多种类查询列表
	}

	self.sale_item_list_market = {}
	self.filtrate_list_market = {}
	self.contain_cell_list = {}
	self.market_type = {}
	self:CreatCell()
	self:CreatFliterCell()

	-- self.FlushGoodsList_timer_quest = GlobalTimerQuest:AddRunQuest(function() self:FlushCurPage() end, 2)  --每过两秒刷新当前页面的物品
	--self.FlushGoodsList_timer_quest = GlobalTimerQuest:AddRunQuest(function() self:OnSearch(1) end, 2)
end

function MarketBuyView:__delete()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	if self.FlushGoodsList_timer_quest then
		GlobalTimerQuest:CancelQuest(self.FlushGoodsList_timer_quest)
		self.FlushGoodsList_timer_quest = nil
	end
end

function MarketBuyView:FlushMarketBuy()
	self.sale_item_list_market = MarketData.Instance:GetSaleitemListMarket()

	self.filtrate_list_market = self.sale_item_list_market

	self:FlushPageCount()
	-- self:FlushGold()
	self:FlushPage(self.current_page)
end

-- function MarketBuyView:FlushGold()
-- 	local vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local gold = vo.gold
-- 	self.gold:SetValue(CommonDataManager.ConverMoney(gold))
-- end

-- 筛选
function MarketBuyView:OnClickFiltrateType(index)
	MarketData.Instance:SetFiltrateIndex(index)
	local searchFlag = 1
	self.filtrate_list_market = {}
	local f_isopen = MarketData.Instance:GetFiltrateIsOpen()
	for i = 1,2 do
		if not f_isopen then
			self.filtrate_toggle[i].toggle.isOn = false
			-- 重置筛选栏状态
			MarketData.Instance:SetFiltrateIsOpen(true)
		end
	end
	
	if index > 99 then
		searchFlag = self:SetSearchTypeBuffer(self.last_click_list.index, index - 100)
		self.last_click_list.color = index - 100
	else
		searchFlag = self:SetSearchTypeBuffer(self.last_click_list.index, self.last_click_list.color, index)
		self.last_click_list.order = index
	end

	if self.market_type ~= nil then
		local list_cfg = index < 100 and self.market_type.order or self.market_type.color
		if index < 100 then
			self.quality_text:SetValue(list_cfg[index + 1].order_name)
		else
			--阶数
			self.quality_text:SetValue(Language.Market.Quality)
			--品质
			self.class_text:SetValue(list_cfg[index - 99].order_name)
		end
	end
	if searchFlag == 0 then
		if index > 99 then
			local search_config = MarketData.Instance:GetSearchConfig()
			search_config.color = self.color_list[index - 100] or 0
			self:OnSearch(3)
		else
			self:OnSearch(1)
		end
	else
		self:OnSearch(searchFlag)
	end
end

-- 单价排序
function MarketBuyView:OnClickFlushUnitSort(type_sort)
	local searchFlag = 1
	local is_show_sort = type_sort == 1 or true and false
	self.is_unit_price_up:SetValue(is_show_sort)
	self.is_unit_price_down:SetValue(not is_show_sort)
	if type_sort == 0 then
		searchFlag = self:SetSearchTypeBuffer(self.last_click_list.index, self.last_click_list.color, self.last_click_list.order, MARKET_BUY_SORT_TYPE.SORT_TYPE_SINGLE, MARKET_BUY_RANK_TYPE.RANK_TYPE_SMALL_TO_BIG)
		self.last_click_list.sort_type = MARKET_BUY_SORT_TYPE.SORT_TYPE_SINGLE
		self.last_click_list.rank_type = MARKET_BUY_RANK_TYPE.RANK_TYPE_SMALL_TO_BIG
	else
		searchFlag = self:SetSearchTypeBuffer(self.last_click_list.index, self.last_click_list.color, self.last_click_list.order, MARKET_BUY_SORT_TYPE.SORT_TYPE_SINGLE, MARKET_BUY_RANK_TYPE.RANK_TYPE_BIG_TO_SMALL)		
		self.last_click_list.sort_type = MARKET_BUY_SORT_TYPE.SORT_TYPE_SINGLE		
		self.last_click_list.rank_type = MARKET_BUY_RANK_TYPE.RANK_TYPE_BIG_TO_SMALL
	end
	self:OnSearch(searchFlag)
end

-- 隐藏筛选下拉框
function MarketBuyView:HideToggle()
	for i = 1,2 do
		self.filtrate_toggle[i].toggle.isOn = false
	end
end
-- 总价排序
function MarketBuyView:OnClickFlushTotalSort(type_sort)
	local searchFlag = 1
	local is_show_sort = type_sort == 1 or true and false
	self.is_total_price_up:SetValue(is_show_sort)
	self.is_total_price_down:SetValue(not is_show_sort)
	if type_sort == 0 then
		searchFlag = self:SetSearchTypeBuffer(self.last_click_list.index, self.last_click_list.color, self.last_click_list.order, MARKET_BUY_SORT_TYPE.SORT_TYPE_ALL, MARKET_BUY_RANK_TYPE.RANK_TYPE_SMALL_TO_BIG)
		self.last_click_list.sort_type = MARKET_BUY_SORT_TYPE.SORT_TYPE_ALL
		self.last_click_list.rank_type = MARKET_BUY_RANK_TYPE.RANK_TYPE_SMALL_TO_BIG
	else
		searchFlag = self:SetSearchTypeBuffer(self.last_click_list.index, self.last_click_list.color, self.last_click_list.order, MARKET_BUY_SORT_TYPE.SORT_TYPE_ALL, MARKET_BUY_RANK_TYPE.RANK_TYPE_BIG_TO_SMALL)
		self.last_click_list.sort_type = MARKET_BUY_SORT_TYPE.SORT_TYPE_ALL
		self.last_click_list.rank_type = MARKET_BUY_RANK_TYPE.RANK_TYPE_BIG_TO_SMALL		
	end
	self:OnSearch(searchFlag)
end

-- 刷新页面数目
function MarketBuyView:FlushPageCount()
	self.current_page = MarketData.Instance:GetCurPage()
	self.total_page = MarketData.Instance:GetTotalPage()
	self.total_page = math.max(self.total_page , 1)
end

-- 更新页面
function MarketBuyView:FlushPage(page)
	self.variable_page:SetValue(self.current_page .. "/" .. self.total_page)
	self.info_count = #self.filtrate_list_market
	if self.info_count == 0 and page==1 then
		self.show_no_search:SetValue(true)
	else
		self.show_no_search:SetValue(false)
	end

	if self.info_count == 0 and page > 1 then --如果搜索不到东西且不是第一页
		local search_config = MarketData.Instance:GetSearchConfig()
		search_config.req_page = math.max(search_config.req_page - 1, 1)
		MarketCtrl.Instance:SendPublicSaleSearchReq()
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
	local info = self.filtrate_list_market[index]
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(info.item_id)
	self.item_cell[index].cell:SetData(info)
	self.variables[index].count:SetValue("X" .. info.num)
	self.variables[index].name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[info.color]))
	self.variables[index].total_price:SetValue(info.gold_price)
	self.variables[index].order:SetValue(info.order)

	self.variables[index].price:SetValue(math.floor(info.gold_price / info.num))
end

-- 向上翻页
function MarketBuyView:OnPageUp()
	local search_config = MarketData.Instance:GetSearchConfig()
	if(MarketData.Instance:GetTotalPage() < 1) then
		return
	end
	search_config.req_page = math.max(search_config.req_page - 1, 1)
	MarketCtrl.Instance:SendPublicSaleSearchReq()
	-- self.scrollRect.verticalNormalizedPosition = 1
end

-- 向下翻页
function MarketBuyView:OnPageDown()
	local search_config = MarketData.Instance:GetSearchConfig()
	if(MarketData.Instance:GetTotalPage() < 1) then
		return
	end
	search_config.req_page = math.min(search_config.req_page + 1, MarketData.Instance:GetTotalPage())
	MarketCtrl.Instance:SendPublicSaleSearchReq()
	-- self.scrollRect.verticalNormalizedPosition = 1
end

-- window搜索
function MarketBuyView:WindowSeach()
	-- 设置正在window搜索
	MarketData.Instance:SetWindowSearch(true)
	local search_config = MarketData.Instance:GetSearchConfig()
	
	MarketCtrl.Instance:SetNeedNotice(1)
	self:OnSearch()
	MarketCtrl.Instance:SetNeedNotice(0)
end
-- 搜索
function MarketBuyView:OnSearch(flag,page)
	local search_config = MarketData.Instance:GetSearchConfig()
	if page then
		search_config.req_page = page or 1
	end
	search_config.total_page = 0
	if flag == 1 then
		-- search_config.color = 0
		search_config.level = 0
		-- search_config.prof = 0
		search_config.color_interval = 0
		search_config.fuzzy_type_count = 0
		search_config.fuzzy_type_list = {}
		if search_config.color == 0 then
			local color = 0
			for i = 1, 5 do
				if self.toggle_list[i].isOn then
					color = self.color_list[i]
					break
				end
			end
			search_config.color = color
			MarketData.Instance:SetFiltrateIndex(100 + search_config.color)
		end
	elseif flag == 2 then
		search_config.level = 0
		search_config.color_interval = 0
	elseif flag == 3 then
		local fuzzy_type_list, has_input = self:GetFuzzyList()
		search_config.fuzzy_type_list = fuzzy_type_list
		search_config.fuzzy_type_count = #fuzzy_type_list
		if search_config.color == 0 then
			local color = 0
			for i = 1, 5 do
				if self.toggle_list[i].isOn then
					color = self.color_list[i]
					break
				end
			end
			search_config.color = color
			MarketData.Instance:SetFiltrateIndex(100 + search_config.color)
		end
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
		MarketData.Instance:SetFiltrateIndex(100 + search_config.color)
	end
	if search_config.fuzzy_type_count == 0 and flag ~= 0 and has_input then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.SelectEmpty)
		self:CloseSearchWindow()
		MarketData.Instance:SetCurPage(1)
		MarketData.Instance:SetTotalPage(0)
		MarketData.Instance:SetSaleitemListMarket({})
		self:FlushMarketBuy()
	else
		MarketCtrl.Instance:SendPublicSaleSearchReq(flag)
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
			if nil ~= item_cfg.search_type and (0 == search_type or search_type == item_cfg.search_type) and 
				nil ~= string.find(item_cfg.name, text_input) then
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
-- 获取多种类查找列表
function MarketBuyView:GetFuzzyList2(searchTypeList)
	local search_type = MarketData.Instance:GetSearchConfig().item_type
	local all_item_cfg = MarketData.Instance:GetItemAllConfig()

	local temp_fuzzy_list = {}
	local temp_fuzzy_count = 0

	for k, v in pairs(all_item_cfg) do
		for item_id, item_cfg in pairs(v) do
			if nil ~= item_cfg.search_type and self:is_include(item_cfg.search_type,searchTypeList) then
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

	return fuzzy_list
end

--判断table中是否包含某个值
function MarketBuyView:is_include(value, tab)
    for k,v in ipairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end


-- 关闭搜索弹窗
function MarketBuyView:CloseSearchWindow()
	self.serach_window:SetActive(false)
end

-- 类型弹窗
function MarketBuyView:IsOpenTypePanel(is_show)
	self.type_panel:SetActive(is_show)
end

-- 搜索结果弹窗
function MarketBuyView:IsOpenRightPanel(is_show)
	self.right_panel:SetActive(is_show)
end

-- 显示物品详细信息
function MarketBuyView:ShowDetails(index)
	local info = self.filtrate_list_market[index]
	if info ~= nil then
		info.price = math.floor(info.gold_price / info.num)
		TipsCtrl.Instance:OpenItem(info, TipsFormDef.FROME_MARKET_GOUMAI, {fromIndex = info.sale_index})
	end
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchType(index, prof, color, order, sort_type, rank_type,type_count,type_list)   -- 0为搜索全部
	local search_config = MarketData.Instance:GetSearchConfig()
	search_config.item_type = index
	search_config.prof = prof or DONTASSIGN
	search_config.color = color or DONTASSIGN
	search_config.order = order or DONTASSIGN
	search_config.sort_type = sort_type or DONTASSIGN
	search_config.rank_type = rank_type or DONTASSIGN

	search_config.fuzzy_type_count = type_count or DONTASSIGN
	search_config.fuzzy_type_list = type_list or {}

	self.input_name.text = ""
end

--设置搜索物品的类型，根据index的不同，自动处理模糊查询或者职业查询
function MarketBuyView:SetSearchTypeBuffer(index,color,order,sort_type,rank_type)
	--self.qualityButton:SetActive(false)  --物品没有品阶的时候隐藏品阶筛选按钮
	index = index or self.last_click_list.index or DONTASSIGN
	color = color or self.last_click_list.color or DONTASSIGN
	order = order or self.last_click_list.order or DONTASSIGN
	sort_type = sort_type or self.last_click_list.sort_type or MARKET_BUY_SORT_TYPE.SORT_TYPE_SINGLE
	rank_type = rank_type or self.last_click_list.rank_type or MARKET_BUY_RANK_TYPE.RANK_TYPE_BIG_TO_SMALL

	if index > 7 then
		self.last_click_list.index = index
		self:SetSearchType(index,0,color, order,sort_type, rank_type)
		if index >= 500 and index < 800 then
			self.qualityButton:SetActive(false)
		else
			self.qualityButton:SetActive(true)
		end
		return 1
	elseif index <= 7 then
		self.last_click_list.index = index
		if index < 5 then
			self.qualityButton:SetActive(true)
			self.last_click_list.prof = index
			self:SetSearchType(DONTASSIGN,index,color, order,sort_type, rank_type)
			if index == 0 then
				return 0   --返回OnSearch的参数类型
			else
				return 1
			end
		elseif index == 5 then
			self.qualityButton:SetActive(false)
			local fuzzy_type_list = self:GetFuzzyList2({501,502,503,504,505,506,507,508,509,510})
			self.last_click_list.fuzzy_type_list = fuzzy_type_list
			self:SetSearchType(index, 0, color, order,sort_type, rank_type,#fuzzy_type_list,fuzzy_type_list)
		elseif index == 6 then
			self.qualityButton:SetActive(false)
			local fuzzy_type_list = self:GetFuzzyList2({601,602,603,604,605,606,607})
			self.last_click_list.fuzzy_type_list = fuzzy_type_list
			self:SetSearchType(index, 0, color, order,sort_type, rank_type,#fuzzy_type_list,fuzzy_type_list)
		elseif index == 7 then
			self.qualityButton:SetActive(false)
			local fuzzy_type_list = self:GetFuzzyList2({701,702,703,704,705,706,707,708,709,710})
			self.last_click_list.fuzzy_type_list = fuzzy_type_list
			self:SetSearchType(index, 0, color, order,sort_type, rank_type,#fuzzy_type_list,fuzzy_type_list)
		end
		return 2
	end
end
-----------------------------------------------动态生成Cell------------------------------------------------------
local MAX_COUNT = 18
function MarketBuyView:CreatCell()
	self.market_type = MarketData.Instance:GetMarketTypeConfig()
	self.button_all = self:FindObj("ButtonAll")
	-- self.button_all:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() self:OnClickButton(0) end)
	self.toggle_group = self.button_all:GetComponent("ToggleGroup")
	self.button_table = {}
	
	for i = 1, #self.market_type.market_father do
		if i > MAX_COUNT then break end
		self.button_table[i] = self:FindObj("Button" .. i)
		self.button_table[i]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() 
											-- 记录打开了筛选栏，以免定时刷新数据给关闭掉
											MarketData.Instance:SetFiltrateIsOpen(true)
											self:OnClickButton(i - 1) end)
		self.button_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Name"):SetValue(self.market_type.market_father[i].father_name)
		-- self.list_table[i] = self:FindObj("List" .. i):GetComponent(typeof(UnityEngine.Transform))
	end
	self.button_table[1].toggle.isOn = true
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function MarketBuyView:CreatFliterCell()
	if self.type_list and next(self.type_list) then
		for k, v in ipairs(self.type_list) do
			if v ~= nil then
				GameObject.Destroy(v.gameObject)
				v = nil
			end
		end
	end

	if self.jie_list and next(self.jie_list) then
		for k, v in ipairs(self.jie_list) do
			if v ~= nil then
				GameObject.Destroy(v.gameObject)
				v = nil
			end
		end
	end
	self.list_table = {}
	self.type_list = {}
	self.jie_list = {}
	for x = 1, 2 do  --1表示阶数、2表示颜色
		self.list_table[x] = self:FindObj("List_" .. x):GetComponent(typeof(UnityEngine.Transform))
		PrefabPool.Instance:Load(AssetID("uis/views/market_prefab", "ItemType"), function (prefab)

			local list_cfg = {}
			if x == 1 then
				list_cfg = self.market_type.order
			else
				if self.last_click_btn >= 1 and self.last_click_btn <= 4 then
					list_cfg = self.market_type.equip_color
				else
					list_cfg = self.market_type.color
				end
			end
			if nil == prefab or nil == list_cfg then
				return
			end
			--控制阶数和颜色
			for k,v in pairs(list_cfg) do
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(self.list_table[x], false)
				obj:GetComponent("Toggle").group = self.toggle_group
				local index = x == 1 and v.order or v.color + 100 --加100用来区分阶数和颜色的index
				obj:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick", function() 
					-- 玩家选择了筛选项，可以关闭筛选框了
					MarketData.Instance:SetFiltrateIsOpen(false)
					self:OnClickFiltrateType(index) end)
				local obj_name = obj:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
				obj_name:SetValue(v.order_name)
				if x == 2 then
					self.type_list[k] = obj
				else
					self.jie_list[k] = obj
				end
			end
			PrefabPool.Instance:Free(prefab)
		end)--Load_end
	end
end

function MarketBuyView:GetNumberOfCells()
	local recharge_id_list = MarketData.Instance:GetMarketChildTypeConfig(self.father_index)
	local number_cell = 0
	for k,v in pairs(recharge_id_list) do
		if v.father_id == self.father_index then
			number_cell = number_cell + 1
		end
	end
	if number_cell % 3 ~= 0 then
		return math.floor(number_cell/3) + 1
	else
		return number_cell/3
	end
end

function MarketBuyView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = MarketBuyItemType.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local id_list = MarketData.Instance:GetMarketListByIndex(self.father_index, cell_index)
	contain_cell:SetItemId(id_list)
	contain_cell:SetIndex(cell_index)


end

function MarketBuyView:OnClickButton(index)
	self:IsOpenTypePanel(true)
	self:IsOpenRightPanel(false)
	self.father_index = index
	self.list_view.scroller:ReloadData(0)

	-- self.toggle_group:SetAllTogglesOff()
	if index == 0 then
		self.last_click_list.index = 0
	end
	local obj = self.jie_list[self.last_click_list.index]
	if obj then
		obj:GetComponent("Toggle").isOn = true
	end
	self:SetSearchType(DONTASSIGN)
	if index == 0 then
		local filert = MarketData.Instance:GetFiltrateIndex()
		self:OnClickFiltrateType(filert)
		self:IsOpenTypePanel(false)
		self:IsOpenRightPanel(true)
		self.itemTypeText.text = Language.Market.CurrShaiXuanText
	end
	self.last_click_btn = index
	MarketData.Instance:SetWindowSearch(false)	
	self:CreatFliterCell()
	self:OnClickFiltrateType(0)
	self:OnClickFiltrateType(100)
end

--选择子类型之后调用
function MarketBuyView:OnClickType(index,item_name)
	-- self.scrollRect.verticalNormalizedPosition = 1  --购买列表scrollRect复位
	self:OnSearch(self:SetSearchTypeBuffer(index))
	self.itemTypeText.text = item_name
	self:IsOpenTypePanel(false)
	self:IsOpenRightPanel(true)
end

function MarketBuyView:FlushCurPage()	
	local search_config = MarketData.Instance:GetSearchConfig()
	-- 是否检索过
	local window_flag = MarketData.Instance:GetWindowSearch()
	local filert = MarketData.Instance:GetFiltrateIndex()
 	if window_flag then
		self:OnClickFiltrateType(filert)
	else
		-- 如果window搜索框打开，不关闭window搜索框
		MarketData.Instance:SetWindowSearch(false)
		self:OnClickFiltrateType(filert)
	end
end

MarketBuyItemType = MarketBuyItemType  or BaseClass(BaseCell)

function MarketBuyItemType:__init()
	self.item_type_list = {}
	for i = 1, 3 do
		self.item_type_list[i] = {}
		self.item_type_list[i] = BuyItemType.New(self:FindObj("item_" .. i))
	end
end
  
function MarketBuyItemType:__delete()
	for i=1,3 do
		self.item_type_list[i]:DeleteMe()
		self.item_type_list[i] = nil
	end
end

function MarketBuyItemType:SetItemId(item_id_list)
	for i=1,3 do
		self.item_type_list[i]:SetItemId(item_id_list[i])
	end
end

function MarketBuyItemType:OnFlushAllCell()
	for i=1,3 do
		self.item_type_list[i]:OnFlush()
	end
end

BuyItemType = BuyItemType or BaseClass(BaseCell)

function BuyItemType:__init()
	self.name_text = self:FindVariable("Name")
	self.ItemIcon = self:FindVariable("ItemIcon")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnTypeClick, self))
	self.item_id = 0
end

function BuyItemType:SetItemId(item_id)
	self.item_id = item_id
	self:OnFlush()
end

function BuyItemType:OnFlush()
	self.root_node:SetActive(true)
	if self.item_id == 0 then
		self.root_node:SetActive(false)
		return
	end
	local market_cfg = MarketData.Instance:GetMarketChildIdConfig(self.item_id)
	self.name_text:SetValue(market_cfg.child_name)
	self.ItemIcon:SetAsset(ResPath.GetItemIcon(market_cfg.resource_id))
end

function BuyItemType:OnTypeClick()
	MarketCtrl.Instance:Flush("flush_buy", {item_id = self.item_id,item_name = "当前搜索："..MarketData.Instance:GetMarketChildIdConfig(self.item_id).child_name})
	-- local f_isopen = MarketData.Instance:GetFiltrateIsOpen()
	-- for i = 1,2 do
	-- 	if f_isopen then
	-- 		-- 重置筛选栏状态
	-- 		MarketData.Instance:SetFiltrateIsOpen(false)
	-- 	end
	-- end
end
