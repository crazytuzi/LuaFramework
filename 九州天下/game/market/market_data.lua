MarketData = MarketData or BaseClass()

MarketData.MaxPriceCoin = 99999999					-- 价格上限-铜币
MarketData.MaxPriceGold = 99999						-- 价格上限-元宝

MarketData.PriceTypeCoin = 1						-- 价格类型-铜币
MarketData.PriceTypeGold = 2						-- 价格类型-元宝

MarketData.SaleItemTypeCoin = 1						-- 出售物品类型-铜币
MarketData.SaleItemTypeItem = 2						-- 出售物品类型-物品

function MarketData:__init()
	if MarketData.Instance then
		print_error("[MarketData] Attempt to create singleton twice!")
		return
	end
	MarketData.Instance = self
	self.item_list = {}

	self.cur_page = 1
	self.total_page = 0

	self.sale_item_list_market = {}
	self.sale_item_list = {}

	self.search_config = {
		item_type = 0,
		req_page = 1,
		total_page = 0,
		prof = 0,
		color = 0,
		order = 0,
		sort_type = 0,
		rank_type = 0,
		need_notice = 0,
		fuzzy_type_count = 0,
		fuzzy_type_list = {},
	}

	self.item_id = 0
	self.window_search = false
	self.filtra_index = 0
	self.filtra_isopen = false
end

function MarketData:__delete()
	MarketData.Instance = nil
end

function MarketData:SetCurPage(value)
	self.cur_page = value
end

function MarketData:GetCurPage()
	return self.cur_page
end

function MarketData:SetTotalPage(value)
	self.total_page = value
end

function MarketData:GetTotalPage()
	return self.total_page
end

function MarketData:SetSaleitemListMarket(value)
	self.sale_item_list_market = value
	for _, v in pairs(self.sale_item_list_market) do
		if v.sale_item_type == MarketData.SaleItemTypeCoin then
			v.item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN
			v.num = v.sale_value
			v.color = nil
		end
	end
end

function MarketData:GetSaleitemListMarket()
	return self.sale_item_list_market
end

-- 设置自己拍卖物品列表
function MarketData:SetSaleItemList(value)
	self.sale_item_list = value

	for k, v in pairs(self.sale_item_list) do
		if v.sale_item_type == MarketData.SaleItemTypeCoin then
			v.item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN
			v.num = v.sale_value
			v.color = nil
		end
	end
end

function MarketData:GetSaleItemList()
	return self.sale_item_list
end

-- 获取一个空位
function MarketData:GetValidIndex()
	local sale_list = {}
	for k, v in pairs(self.sale_item_list) do
		sale_list[v.sale_index] = 1
	end
	for i = 0, COMMON_CONSTS.PUBLICSALE_MAX_ITEM_COUNT - 1 do
		if nil == sale_list[i] then
			return i
		end
	end

	return -1
end

function MarketData:GetSearchConfig()
	return self.search_config
end

-- 获取价格类型图标
function MarketData.GetPriceImgPath(price_type)
	if price_type == MarketData.PriceTypeGold then
		return ResPath.GetMainUIButton("glod")
	end

	return ResPath.GetMainUIButton("coin")
end

-- 市场价格按万来显示
function MarketData.ConverMoney(value)
	if value >= 10000 then
		return math.floor(value / 10000) .. Language.Common.Wan
	end
	return value
end

function MarketData:GetItemAllConfig()
	local item_all_config = {[GameEnum.ITEM_BIGTYPE_EQUIPMENT] = ConfigManager.Instance:GetAutoItemConfig("equipment_auto"),	--装备
						[GameEnum.ITEM_BIGTYPE_EXPENSE] = ConfigManager.Instance:GetAutoItemConfig("expense_auto"),				--消耗
						[GameEnum.ITEM_BIGTYPE_GIF] = ConfigManager.Instance:GetAutoItemConfig("gift_auto"),					--礼包
						[GameEnum.ITEM_BIGTYPE_OTHER] = ConfigManager.Instance:GetAutoItemConfig("other_auto"),					--其他
						[GameEnum.ITEM_BIGTYPE_VIRTUAL] = ConfigManager.Instance:GetAutoItemConfig("virtual_auto"),				--虚拟
					   }
	return item_all_config
end

function MarketData:GetMarketTypeConfig()
	local market_type_config = ConfigManager.Instance:GetAutoConfig("markettype_auto")
	if market_type_config then
		if market_type_config.market_father then
			table.sort(market_type_config.market_father, function(a,b) return a.order < b.order end)
		end
	end
	return market_type_config
end

function MarketData:GetMarketChildConfig()
	return ConfigManager.Instance:GetAutoConfig("markettype_auto").market_child
end

function MarketData:GetMarketChildIdConfig(child_id)
	local market_child_id_config = self:GetMarketChildConfig()
	for k,v in pairs(market_child_id_config) do
		if v.child_id == child_id then
			return v
		end
	end
end

function MarketData:GetMarketChildTypeConfig(type_id)
	local market_type_id_config = self:GetMarketChildConfig()
	local type_id_cfg = {}
	for k,v in pairs(market_type_id_config) do
		if v.father_id == type_id then
			table.insert(type_id_cfg, v)
		end
	end
	return type_id_cfg
end

--通过索引获得需要加载该索引的集合
function MarketData:GetMarketListByIndex(type_id,cell_index)
	local all_id_list = self:GetMarketChildTypeConfig(type_id)
	local market_id_list = {}
	if cell_index == 1 then
		for i=1,3 do
			if all_id_list[i] ~= nil then
				market_id_list[#market_id_list + 1] = all_id_list[i].child_id
			else
				market_id_list[#market_id_list + 1] = 0
			end
		end
		return market_id_list
	end
	for i=1,3 do
		if all_id_list[(cell_index - 1)*3 + i] == nil then
			market_id_list[#market_id_list + 1] = 0
		else
			market_id_list[#market_id_list + 1] = all_id_list[(cell_index - 1)*3 + i].child_id
		end
	end
	return market_id_list
end

function MarketData:GetSaleCount()
	local count = 0
	if self.sale_item_list then
		for k,v in pairs(self.sale_item_list) do
			count = count + 1
		end
	end
	return count
end

function MarketData:SetItemId(item_id)
	self.item_id = item_id
end

function MarketData:GetItemId()
	return self.item_id
end

-- 是否window搜索
function MarketData:SetWindowSearch(window_search)
	self.window_search = window_search
end

function MarketData:GetWindowSearch()
	return self.window_search 
end

-- 记录筛选的index
function MarketData:SetFiltrateIndex(filtra_index)
	self.filtra_index = filtra_index
end

function MarketData:GetFiltrateIndex()
	return self.filtra_index 
end

-- 记录筛选栏是否打开
function MarketData:SetFiltrateIsOpen(filtra_isopen)
	self.filtra_isopen = filtra_isopen
end

function MarketData:GetFiltrateIsOpen()
	return self.filtra_isopen 
end

function MarketData:GetBagSellItemList()
	local sell_list = ItemData.Instance:GetBagNoBindItemList()
	local get_list = TableCopy(sell_list)
	for i = #get_list, 1, -1 do
		if get_list[i].item_id ~= nil then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(get_list[i].item_id)	

			if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and item_cfg and item_cfg.color < GameEnum.ITEM_COLOR_RED then
				table.remove(get_list, i)
			end
			
			if get_list[i] ~= nil then
				local item_cfg, big_type = ItemData.Instance:GetItemConfig(get_list[i].item_id)	
				-- 不允许出售的物品
				if item_cfg.market_cansell == GameEnum.MARKET_INFO.NOTSELL then
					table.remove(get_list, i)
				end
			end
		end
	end
	return get_list
end

function MarketData:GetTax(value)
	if value == nil then return 0 end
	return 8
	-- if value < 100 then
	-- 	return 5
	-- elseif value < 300 then
	-- 	return 8
	-- elseif value < 500 then
	-- 	return 10
	-- elseif value < 1000 then
	-- 	return 15
	-- elseif value < 2000 then
	-- 	return 20
	-- elseif value < 3000 then
	-- 	return 30
	-- elseif value < 6000 then
	-- 	return 40
	-- else
	-- 	return 50
	-- end
end
