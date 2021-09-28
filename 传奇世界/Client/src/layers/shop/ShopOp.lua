local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
--------------------------------------------------------------------
--------------------------------------------------------------------
local MObserver = require "src/young/observer"

local observable = MObserver.new()

-- 监听
register = function(self, observer)
	observable:register(observer)
end

-- 取消监听
unregister = function(self, observer)
	observable:unregister(observer)
end

-- 数据发生变化时通知观察者
local dataSourceChanged = function(...)
	observable:broadcast(M, ...)
end
--------------------------------------------------------------------
-- 请求魂值商城商品列表返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYSTRET, function(buff)
	dump("TRADE_SC_MYSTRET", "请求魂值商城商品列表返回")
	local t = g_msgHandlerInst:convertBufferToTable("MysteryShopReqRetProtocol", buff)
	--dump(t, "请求魂值商城商品列表返回")
	
	local storeId = t.mallID
	local itemNum = t.itemNum
	local refresh_time = t.param1
	-----------------------
	
	local items = t.itemInfo
	local ret = {}
	local goodsNum = #items
	for i = 1, goodsNum do
		local cur = items[i]
		local item = {}
		item.Type = cur.moneyType
		item.Index = cur.arrayIndex
		item.itemID = cur.itemID
		item.Price = cur.price
		item.Count = cur.itemLeft
		item.sourceCount = cur.souceNum
		ret[#ret + 1] = item
	end
	
	local params = {list = ret, refresh_time=refresh_time,storeId=-3}
	--dump(params, "请求魂值商城商品列表返回")
	dataSourceChanged("store_list", params)
end)

-- 请求其他商店商品列表返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_MALLRET, function(buff)
	dump("TRADE_SC_MALLRET", "请求其他商店商品列表返回")
	local t = g_msgHandlerInst:convertBufferToTable("TradeMallReqRetProtocol", buff)
	--dump(t, "请求其他商店商品列表返回")
				
	local storeId = t.shopType
	local items = t.itemInfo
	local ret = {}
	local goodsNum = #items
	for i = 1, goodsNum do
		local cur = items[i]
		local item = {}
		item.mGoodsID = cur.itemBuyID
		item.mProtoID = cur.itemID
		item.mSellState = cur.sellState
		item.mSellingPrice = cur.sellPrice
		item.mOriginalPrice = cur.sourcePrice
		item.mWholeBuyLimits = cur.allLimite
		item.mWholeRemaining = cur.allLimiteLeft
		item.mSingleBuyLimits = cur.roleLimite
		item.mSingleBuyNums = cur.roleBuy
		item.effectTime = cur.effectTime -- 下架剩余时间
        item.label = cur.label;             -- //1 hot,2 limit time,3 recommend,4 new
		ret[#ret + 1] = item
	end
	--dump(ret, "ret")
	--cb(storeType, ret)
	dataSourceChanged("store_list", {list = ret, storeId=storeId})
end)
		
-- 请求商品列表
requestGoodsList = function(self, storeType)
	dump(storeType, "请求商品列表")
	if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
	-- 魂值商城
	if storeType == -3 then
		--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_MYSTREQ, "ii", G_ROLE_MAIN.obj_id, -storeType)
		g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_MYSTREQ, "MysteryShopReqProtocol", {shopType=-storeType})
		addNetLoading(TRADE_CS_MYSTREQ, TRADE_SC_MYSTRET)
	else
		--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_MALLREQ, "ii", G_ROLE_MAIN.obj_id, storeType)
		g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_MALLREQ, "TradeMallReqProtocol", {shopType=storeType})
		addNetLoading(TRADE_CS_MALLREQ, TRADE_SC_MALLRET)
	end
end
--------------------------------------------------------------------
-- 请求购买商品返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_TRADEMALLOK, function(buff)
	dump("TRADE_SC_TRADEMALLOK", "购买商品返回")
	local t = g_msgHandlerInst:convertBufferToTable("TradeaMallRetProtocol", buff)
	--dump(t, "购买商品返回")
	
	local storeId = t.shopType
	local result = t.mallRet
	local wholeRemaining = t.allLimit
	local singleBuyNums = t.roleLimit
	dump({result=result, wholeRemaining=wholeRemaining, singleBuyNums=singleBuyNums}, "购买商品返回")
	dataSourceChanged("buy_goods_ret", {result=result, wholeRemaining=wholeRemaining, singleBuyNums=singleBuyNums, storeId=storeId})
end)

-- 请求购买魂值商城物品返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYSTBUY_RET, function(buff)
	dump("TRADE_SC_MYSTBUY_RET", "请求购买魂值商城物品返回")
	local t = g_msgHandlerInst:convertBufferToTable("MysteryShopBuyRetProtocol", buff)
	--dump(t, "请求购买魂值商城物品返回")
	
	local result = t.buyRet
	local nextBuyExtraIngot = t.needMoreIngot
	local buyRemain = t.buyCountLeft
	local params = {result=result, nextBuyExtraIngot=nextBuyExtraIngot, buyRemain=buyRemain,storeId=-3}
	dump(params, "请求购买魂值商城物品返回")
	dataSourceChanged("buy_goods_ret", params)
end)

-- 魂值商城请求购买商品通过商品ID
buyHunZhiStore = function(self, storeType, moneyType, index, protoId, num)
	local t = {}
	t.shopType = -storeType
	t.moneyType = moneyType
	t.arrayIndex = index
	t.itemID = protoId
	t.buyNum = num
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_MYSTBUY, "MysteryShopBuyProtocol", t)
	addNetLoading(TRADE_CS_MYSTBUY, TRADE_SC_MYSTBUY_RET)
end
	
-- 请求购买商品通过商品ID
buy = function(self, storeType, goodsId, num, protoId)
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_TRADEMALL, "iii", G_ROLE_MAIN.obj_id, goodsId, num)
	local t = {}
	t.itemBuyID = goodsId
	t.num = num
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_TRADEMALL, "TradeMallProtocol", t)
	addNetLoading(TRADE_CS_TRADEMALL, TRADE_SC_TRADEMALLOK)
end

-- 请求购买商品通过物品原型ID
buyProtoId = function(self, storeType, protoId, num)
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_TRADEMALLBYITEMID, "iiii", G_ROLE_MAIN.obj_id, storeType, protoId, num)
	local t = {}
	t.shopType = storeType
	t.itemID = protoId
	t.num = num
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_TRADEMALLBYITEMID, "TradeByItemIDProtocol", t)
end
--------------------------------------------------------------------
-- 限购查询
LimitsBuyQuery = function(self, goodsID, cb)
	dump("TRADE_CS_ALLLIMITREQ", "限购查询")
	
	-- 限购查询返回
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_ALLLIMITRET, function(buff)
		g_msgHandlerInst:registerMsgHandler(TRADE_SC_ALLLIMITRET, nil)
		
		dump("TRADE_SC_ALLLIMITRET", "限购查询返回")
		local t = g_msgHandlerInst:convertBufferToTable("AllLimitRetProtocol", buff)
		--dump(t, "限购查询返回")
		
		local params = 
		{
			allLimit = t.allLimit,
			wholeRemaining = t.allLimitLeft,
			roleLimit = t.roleLimit,
			roleLimitLeft = t.roleLimitLeft,
		}
		
		dump(params, "params")
		
		if type(cb) == "function" then
			cb(params)
		end
	end)
	
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_ALLLIMITREQ, "ii", G_ROLE_MAIN.obj_id, goodsID)
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_ALLLIMITREQ, "AllLimitReqProtocol", {itemBuyID=goodsID})
	addNetLoading(TRADE_CS_ALLLIMITREQ, TRADE_SC_ALLLIMITRET)
end

