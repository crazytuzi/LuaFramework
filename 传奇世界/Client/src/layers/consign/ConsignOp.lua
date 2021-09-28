local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local MPackManager = require "src/layers/bag/PackManager"
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
-- 数据
local isOpen = false
local tIwillSell = {}
local tIwillBuy = {}
local tMyEarnings = {}
--------------------------------------------------------------------
getSellSource = function(self)
	return tIwillSell
end

getEarningsSource = function(self)
	return tMyEarnings
end

-- 接收我的摊位数据
g_msgHandlerInst:registerMsgHandler(STALL_SC_OPENSTALL, function(buff)
	dump("STALL_SC_OPENSTALL", "接收我的摊位数据")
	local t = g_msgHandlerInst:convertBufferToTable("StallSellProtocol", buff)
	--dump(t, "接收我的摊位数据")
	local items = t.stalls
	local num = #items
	local result = {}
	for i = 1, num do
		local cur = items[i]
		local id = cur.guid
		local gridId = cur.slot
		local grid = MPackManager:convertPBItemToGrid(cur)
		result[id] = grid
	end
	dump(result, "我的摊位数据")
	---------------------------------------
	table.clear(tIwillSell)
	for k, v in pairs(result) do
		tIwillSell[k] = v
	end
	
	result = nil
	
	dataSourceChanged("IwillSellInit", {sell_src = tIwillSell})
end)

-- 接收我的收益数据
g_msgHandlerInst:registerMsgHandler(STALL_SC_OPENBACK, function(buff)
	dump("STALL_SC_OPENBACK", "接收我的收益数据")
	local t = g_msgHandlerInst:convertBufferToTable("StallBackProtocol", buff)
	--dump(t, "接收我的收益数据")
	local items = t.stalls
	local num = #items
	local result = {}
	for i = 1, num do
		local cur = items[i]
		local id = cur.guid
		local gridId = cur.slot
		local grid = MPackManager:convertPBItemToGrid(cur)
		result[id] = grid
	end
	dump(result, "我的收益数据")
	
	table.clear(tMyEarnings)
	for k, v in pairs(result) do
		tMyEarnings[k] = v
	end
	
	result = nil
	
	isOpen = true
	dataSourceChanged("MyEarningsInit", {earnings_src = tMyEarnings})
end)
	
-- 打开摊位
openConsign = function(self)
	if isOpen then return end
	
	--g_msgHandlerInst:sendNetDataByFmt(STALL_CS_OPENSTALL, "i", userInfo.currRoleStaticId)
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_OPENSTALL, "StallOpenProtocol", {})
	--addNetLoading(STALL_CS_OPENSTALL, STALL_SC_OPENBACK)
end

-- 关闭摊位
closeConsign = function(self)
	isOpen = false
	table.clear(tIwillSell)
	table.clear(tMyEarnings)
	table.clear(tIwillBuy)
end

-- 物品上架返回
g_msgHandlerInst:registerMsgHandler(STALL_SC_PUTUPITEM, function(buff)
	dump("STALL_SC_PUTUPITEM", "物品上架返回")
	local t = g_msgHandlerInst:convertBufferToTable("PBItem", buff)
	--dump(t, "物品上架返回")
	
	local id = t.guid
	local gridId = t.slot
	local grid = MPackManager:convertPBItemToGrid(t)
	
	dump({id = id, grid = grid}, "物品上架返回")
	tIwillSell[id] = grid
	dataSourceChanged("putInStorage", {id = id, grid = grid})
end)

-- 物品上架
putInStorage = function(self, from, count, price, cate)
	dump({ from = from, count = count, price = price, cate = cate }, "物品上架")
	--g_msgHandlerInst:sendNetDataByFmt(STALL_CS_PUTUPITEM, "iiiic", userInfo.currRoleStaticId, from, count, price, cate)
	local t = {}
	t.upType = cate
	t.price = price
	t.slot = from
	t.count = count
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_PUTUPITEM, "StallUpProtocol", t)
end

-- 物品下架返回
g_msgHandlerInst:registerMsgHandler(STALL_SC_PUTDOWNITEM, function(buff)
	dump("STALL_SC_PUTDOWNITEM", "物品下架返回")
	local t = g_msgHandlerInst:convertBufferToTable("StallDownRetProtocol", buff)
	--dump(t, "物品下架返回")

	local key = t.stallGuid
	local item = t.item
	
	local id = item.guid
	local gridId = item.slot
	local grid = MPackManager:convertPBItemToGrid(item)
	dump({key = key, id = id, grid = grid}, "物品下架返回")
	
	tIwillSell[key] = nil
	tMyEarnings[id] = grid
	dataSourceChanged("soldOut", {id = id, key = key, grid = grid})
end)

-- 物品下架
soldOut = function(self, id)
	--g_msgHandlerInst:sendNetDataByFmt(STALL_CS_PUTDOWNITEM, "iS", userInfo.currRoleStaticId, id)
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_PUTDOWNITEM, "StallDownProtocol", {stallGuid=id})
end

-- 查询物品返回
g_msgHandlerInst:registerMsgHandler(STALL_SC_REQUESTSTALL, function(buff)
	dump("STALL_SC_REQUESTSTALL", "查询物品返回")
	local t = g_msgHandlerInst:convertBufferToTable("StallQueryProtocol", buff)
	--dump(t, "查询物品返回")
	
	local total_count = t.allStallCnt -- 本次查询类型的物品总数量
	local count = t.stallSize -- 本次返回的物品数量
	local next_start_idx = t.queryIdx -- 本次查询末尾位置

	local items = t.items
    print("tttttttttttttttttttt ",total_count,count,next_start_idx,#items)
	local result = {}
	for i = 1, #items do
		local cur = items[i]
		local id = cur.guid -- 寄售物品key
		local seller = "" -- 寄售人名字
		local gridId = cur.slot
		local grid = MPackManager:convertPBItemToGrid(cur)
		
		local item = {}
		item.id = id
		item.seller = seller
		item.gridId = gridId
		item.grid = grid
		
		result[i] = item
	end
	
	dump(result, "查询物品返回")
	dataSourceChanged("PullSaleList", {total_count=total_count, next_start_idx = next_start_idx, cur_list = result})
end)

-- 查询物品
query = function(self, cate, start_idx, order) -- order为true表示从小到大排列
	dump({cate=cate, start_idx=start_idx, order=order}, "查询物品")
	--g_msgHandlerInst:sendNetDataByFmt(STALL_CS_REQUIRESTALL, "iiib", userInfo.currRoleStaticId, cate, start_idx, order)
	
	local t = {}
	t.queryType = cate
	t.queryIdx = start_idx
	t.bAsc = order
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_REQUIRESTALL, "StallRequestProtocol", t)
			
	addNetLoading(STALL_CS_REQUIRESTALL, STALL_SC_REQUESTSTALL)
end

-- 模糊查询
search = function(self, key, start_idx, order, list) -- order为true表示从小到大排列
	dump({key=key, start_idx=start_idx, order=order, list=list}, "查询物品")

	local t = {}
	t.queryType = key
	t.queryIdx = start_idx
	t.bAsc = order
	
	local idList = {}
	local num = #list
	if start_idx > 0 then num = 0 end
	for i = 1, num do
		idList[i] = list[i]
	end
	t.idList = idList
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_FINDSTALL, "StallFindProtocol", t)
	addNetLoading(STALL_CS_FINDSTALL, STALL_SC_REQUESTSTALL)
end

-- 出售物品成功，放入收益列表
g_msgHandlerInst:registerMsgHandler(STALL_SC_SELLITEM, function(buff)
	dump("STALL_SC_SELLITEM", "出售物品成功，放入收益列表")
	local t = g_msgHandlerInst:convertBufferToTable("StallSellRetProtocol", buff)
	--dump(t, "出售物品成功，放入收益列表")
	local item = t.item
	local key = t.stallGuid
	local id = item.guid
	local gridId = item.slot
	local grid = MPackManager:convertPBItemToGrid(item)
	
	dump({key = key, id = id, grid = grid}, "出售物品成功，放入收益列表")
	
	tIwillSell[key] = nil
	tMyEarnings[id] = grid
	
	dataSourceChanged("someoneBuyIt", {id = id, key = key, grid = grid})
end)

-- 购买物品成功，放入收益列表
g_msgHandlerInst:registerMsgHandler(STALL_SC_BUYITEM, function(buff)
	dump("STALL_SC_BUYITEM", "购买物品成功，放入收益列表")
	local t = g_msgHandlerInst:convertBufferToTable("StallBuyRetProtocol", buff)
	--dump(t, "购买物品成功，放入收益列表")
	local item = t.item
	
	local key = t.stallGuid
	local id = item.guid
	local gridId = item.slot
	local grid = MPackManager:convertPBItemToGrid(item)
	
	dump({id = id, key = key, grid = grid}, "购买物品成功，放入收益列表")
	
	tMyEarnings[id] = grid
	dataSourceChanged("iBuyIt", {id = id, key = key, grid = grid})
	
	TIPS({ type = 1  , str = game.getStrByKey("consign_buy_succeed_tips")})
end)

-- 购买物品
buy = function(self, id)
	--g_msgHandlerInst:sendNetDataByFmt(STALL_CS_BUYITEM, "iS", userInfo.currRoleStaticId, id)
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_BUYITEM, "StallBuyProtocol", {stallGuid=id})
end

-- 领取收益返回
g_msgHandlerInst:registerMsgHandler(STALL_SC_GOTITEM, function(buff)
	dump("STALL_SC_GOTITEM", "领取收益返回")
	local t = g_msgHandlerInst:convertBufferToTable("StallGotRetProtocol", buff)
	--dump(t, "领取收益返回")
	
	local id = t.stallGuid
	dump(id, "领取收益返回")
	
	tMyEarnings[id] = nil
	dataSourceChanged("getEarnings", {id = id})
end)

-- 领取收益
get = function(self, id)
	--g_msgHandlerInst:sendNetDataByFmt(STALL_CS_GOTITEM, "iS", userInfo.currRoleStaticId, id)
	g_msgHandlerInst:sendNetDataByTable(STALL_CS_GOTITEM, "StallGotProtocol", {stallGuid=id})
end
