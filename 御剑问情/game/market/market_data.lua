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

	self.tips_market_remind_item = {}

	self.search_config = {
		item_type = 0,
		req_page = 1,
		total_page = 0,
		color = 0,
		order = 0,
		fuzzy_type_count = 0,
		fuzzy_type_list = {},
	}

	self.item_id = 0

	self.market_type_cfg = {}
	self:InitMarketTypeCfg()
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

function MarketData:InitMarketTypeCfg()
	self.market_type_cfg = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local market_type_config = ConfigManager.Instance:GetAutoConfig("markettype_auto")
	for i,v in ipairs(market_type_config.market_father) do
		local vo = {}
		vo.parent_cfg = v
		vo.child_cfg = {}
		for i1,v1 in ipairs(market_type_config.market_child) do
			if v.father_id == v1.father_id and v1.appear_level <= role_level then
				table.insert(vo.child_cfg, v1)
			end
		end
		self.market_type_cfg[#self.market_type_cfg +1] = vo
	end
	table.sort(self.market_type_cfg, function(a,b) return a.parent_cfg.order < b.parent_cfg.order end)
end

function MarketData:GetMarketParentConfig()
	return self.market_type_cfg
end

function MarketData:GetMarketChildConfig(father_id)
	for k,v in pairs(self.market_type_cfg) do
		if v.parent_cfg.father_id == father_id then
			return v.child_cfg
		end
	end
	return {}
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

function MarketData:GetTax(value)
	if value == nil then return 0 
	
	else return 5
	-- if value < 6000 then
		-- return 5
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
	end
end

function MarketData:SetSaleTypeCountAck(protocol)
	self.count_list = protocol.info_list
end

function MarketData:GetCountBySaleType(sale_type)
	if self.count_list == nil then return 0 end
	for k,v in pairs(self.count_list) do
		if v.sale_type == sale_type then
			return v.item_count
		end
	end
	return 0
end

function MarketData:SetMarketNoticeGoodItem(protocol)
	self.tips_market_remind_item.item_id = protocol.item_id or 0
	self.tips_market_remind_item.star = protocol.star or 0
end

function MarketData:GetMarketNoticeGoodItem()
	return self.tips_market_remind_item
end
