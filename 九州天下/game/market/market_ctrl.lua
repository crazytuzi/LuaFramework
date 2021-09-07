require("game/market/market_view")
require("game/market/market_data")
require("game/market/market_quick_sell_view")

MarketCtrl = MarketCtrl or  BaseClass(BaseController)

function MarketCtrl:__init()
	if MarketCtrl.Instance ~= nil then
		print_error("[MarketCtrl] attempt to create singleton twice!")
		return
	end
	MarketCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MarketView.New(ViewName.Market)
	self.quick_sell_view = MarketQuickSellView.New(ViewName.QuickSell)
	self.market_data = MarketData.New()
end

function MarketCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.quick_sell_view then
		self.quick_sell_view:DeleteMe()
		self.quick_sell_view = nil
	end

	if self.market_data ~= nil then
		self.market_data:DeleteMe()
		self.market_data = nil
	end

	MarketCtrl.Instance = nil
end
function MarketCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSShopBuy)
	self:RegisterProtocol(SCAddPublicSaleItemAck, "OnAddPublicSaleItem")
	self:RegisterProtocol(SCGetPublicSaleItemListAck, "OnGetPublicSaleItemList")
	self:RegisterProtocol(SCPublicSaleSearchAck, "OnPublicSaleSearch")
	self:RegisterProtocol(SCBuyPublicSaleItemAck, "OnBuyPublicSaleItemAck")
	self:RegisterProtocol(SCRemovePublicSaleItemAck, 'OnRemovePublicSaleItemAck')
end

-- 商店购买请求
function MarketCtrl:SendShopBuy(item_id, item_num, is_bind, is_use, is_limit)
	local cmd = ProtocolPool.Instance:GetProtocol(CSShopBuy)
	cmd.item_id = item_id
	cmd.item_num = item_num
	cmd.is_bind = is_bind
	cmd.is_use = is_use
	cmd.is_limit = is_limit or 0
	cmd:EncodeAndSend()
end

function MarketCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.market_data ~= nil then
		self.market_data:DeleteMe()
		self.market_data = nil
	end

	MarketCtrl.Instance = nil
end

-- 物品上架返回
function MarketCtrl:OnAddPublicSaleItem(protocol)
	if self.view and self.view.sell_view then
		self.view.sell_view:Flush()
	end
	if(protocol.ret == 0) then    										-- 成功返回0
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.JiShouSucc)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.JiShouCountLimit)
	end
end

-- 拍卖物品上架
function MarketCtrl:SendAddPublicSaleItemReq(sale_index, knapsack_index, item_num, price, price_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAddPublicSaleItem)
	protocol.sale_index = sale_index
	protocol.knapsack_index = knapsack_index
	protocol.item_num = item_num
	protocol.gold_price = price
	protocol.price_type = price_type or MarketData.PriceTypeGold
	protocol.sale_item_type = MarketData.SaleItemTypeItem

	protocol:EncodeAndSend()
end

-- 请求获得自己的所有拍卖物品信息
function MarketCtrl:SendPublicSaleGetUserItemListReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSPublicSaleGetUserItemList)
	protocol:EncodeAndSend()
end

-- 获取自己出售物品列表
function MarketCtrl:OnGetPublicSaleItemList(protocol)
	MarketData.Instance:SetSaleItemList(protocol.sale_item_list)
	if self.view then
		self.view:FlushTable()
	end
end

-- 设置是否要求服务端提示
function MarketCtrl:SetNeedNotice(need_notice)
	self.need_notice = need_notice
end

-- 搜素请求
function MarketCtrl:SendPublicSaleSearchReq(flag)
	self.search_flag = flag
	local config = MarketData.Instance:GetSearchConfig()
	local protocol = ProtocolPool.Instance:GetProtocol(CSPublicSaleSearch)
	protocol.item_type = config.item_type
	protocol.req_page = config.req_page
	protocol.total_page = config.total_page
	protocol.prof = config.prof
	protocol.color = config.color
	protocol.order = config.order
	protocol.sort_type = config.sort_type
	protocol.rank_type = config.rank_type
	protocol.need_notice = self.need_notice or 0
	protocol.fuzzy_type_count = config.fuzzy_type_count
	protocol.fuzzy_type_list = config.fuzzy_type_list
	protocol.page_item_count = 5
	protocol:EncodeAndSend()
end

-- 搜索返回
function MarketCtrl:OnPublicSaleSearch(protocol)
	if (0 == protocol.count and (self.search_flag == nil)) then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Market.SelectEmpty)
	end
	local window_flag = MarketData.Instance:GetWindowSearch()
	if window_flag then
		self.view.buy_view:CloseSearchWindow()
		MarketData.Instance:SetWindowSearch(false)	
	end
	self.market_data:SetCurPage(protocol.cur_page or 1)
	self.market_data:SetTotalPage(protocol.total_page or 0)
	self.market_data:SetSaleitemListMarket(protocol.saleitem_list)
	self:Flush("flush_market_buy")
end

-- 购买物品
function MarketCtrl:SendBuyPublicSaleItem(seller_uid, sale_index, item_id, item_num, gold_price, sale_value, sale_item_type, price_type)
	local mine_uid = GameVoManager.Instance:GetMainRoleVo().role_id
	if mine_uid == seller_uid then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.GouMaiTips)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyPublicSaleItem)
	protocol.seller_uid = seller_uid
	protocol.sale_index = sale_index

	if MarketData.SaleItemTypeItem == sale_item_type then --只有物品类型需要，否则服务端严格检查时通不过
		protocol.item_id = item_id
		protocol.item_num = item_num
	else
		protocol.item_id = 0
		protocol.item_num = 0
	end

	protocol.gold_price = gold_price
	protocol.sale_value = sale_value or 0
	protocol.sale_item_type = sale_item_type
	protocol.price_type = price_type
	protocol:EncodeAndSend()
end

-- 购买物品返回
function MarketCtrl:OnBuyPublicSaleItemAck(protocol)
	if(protocol.ret == 0) then
		local config = MarketData.Instance:GetSearchConfig()
		self:SendPublicSaleSearchReq()
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.BuySucc)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.BuyFail)
	end
end

-- 物品下架
function MarketCtrl:SendRemovePublicSaleItem(sale_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRemovePublicSaleItem)
	protocol.sale_index = sale_index
	protocol:EncodeAndSend()
end

-- 物品撤回服务器返回
function MarketCtrl:OnRemovePublicSaleItemAck(protocol)
	SysMsgCtrl.Instance:ErrorRemind(Language.Market.RecallSucc)
end

-- 从包裹出售物品
function MarketCtrl:SellFormBag(item_cfg)
	if self.view then
		ViewManager.Instance:Open(ViewName.Market, TabIndex.market_sell)
		self.view:Flush()
	end
	MarketData.Instance:SetItemId(item_cfg.id)
end

function MarketCtrl:Flush(key, value_t)
	if self.view then
		self.view:Flush(key, value_t)
	end
end