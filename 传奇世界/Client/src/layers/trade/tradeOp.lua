local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

local MObserver = require "src/young/observer"

local observable = MObserver.new()

-- 监听[数据源]
register = function(self, observer)
	observable:register(observer)
end

-- 取消监听[数据源]
unregister = function(self, observer)
	observable:unregister(observer)
end

-- 数据发生变化时通知观察者
local broadcast = function(...)
	observable:broadcast(M, ...)
end
--------------------------------------------------------------------------------------------------
-- 数据
local tTrade = {
	--req = {}
	--trading = {}
}

local cleanup = function()
	local record = tTrade.trading
	if record ~= nil then
		dump("trade[" .. tostring(record.mTradeId) .. "]cleanup")
		tTrade.trading = nil
	end
end

local ScriptEntry = nil

local cleanup_timer = function()
	if ScriptEntry ~= nil then
		Director:getScheduler():unscheduleScriptEntry(ScriptEntry)
		ScriptEntry = nil
	end
end

local cleanup_req = function()
	tTrade.req = nil
	cleanup_timer()
	broadcast("TradeReqVoid")
end

getTradeStruct = function(self)
	return tTrade
end

getTradeRecord = function(self)
	return tTrade.trading
end

getTradeReq = function(self)
	return tTrade.req
end
--------------------------------------------------------------------------------------------------
-- A给B发起交易请求
reqTrade = function(self, passiveId)
	dump({passiveId=passiveId}, "A给B发起交易请求")
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_AREQ, "ii", G_ROLE_MAIN.obj_id, passiveId)
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_AREQ, "TradeAReqProtocol", {bRoleID=passiveId})
end

local buildTradeStruct = function(roleId, tradeId, roleName, level)
	return {
		mRoleId = roleId,
		mTradeId = tradeId,
		mRoleName = roleName,
		mLevel = level,
	}
end

-- B收到A的交易请求
g_msgHandlerInst:registerMsgHandler(TRADE_SC_BREQ, function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TradeBReqProtocol", buff)
	--dump(t, "B收到A的交易请求")

	local tradeId = t.tradeID -- 数值总是0，目前没有用到
	local activeId = t.aRoleID
	local roleName = t.aRoleName
	local level = t.aRoleLevel
	
	dump({tradeId=tradeId, activeId=activeId, roleName=roleName, level=level}, "B收到A的交易请求")
	
	local record = buildTradeStruct(activeId, tradeId, roleName, level)
	tTrade.req = record
	cleanup_timer()
	
	ScriptEntry = Director:getScheduler():scheduleScriptFunc(function(dt)
		cleanup_req()
	end, 20.0, false)
	
	broadcast("TradeReqArrive", record)
end)

isTradeReqArrive = function(self)
	return tTrade.req ~= nil
end

-- B应答A的交易请求
resTrade = function(self, tradeId, response)
	dump({tradeId=tradeId, response=response}, "B应答A的交易请求")
	if tTrade.req ~= nil then
		--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_BRET, "iiib", G_ROLE_MAIN.obj_id, tTrade.req.mRoleId, 0, response)
		local t = {}
		t.aRoleID = tTrade.req.mRoleId
		t.tradeID = 0
		t.bAnswer = response
		--dump(t, "t")
		g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_BRET, "TradeBRetProtocol", t)
		cleanup_req()
	end
end

local buildTradingBarStruct = function(tradeId, version, roleId, roleName, level)
	local record = {}
	record.mTradeId = tradeId
	record.mVersion = version
	record.mRoleId = roleId
	record.mRoleName = roleName
	record.mLevel = level
	record.mOneself = {}
	record.mOther = {}
	return record
end

-- 返回给A和B[B应答A的交易请求]
g_msgHandlerInst:registerMsgHandler(TRADE_SC_RET, function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TradeRetProtocol", buff)
	--dump(t, "返回给A和B")
				
	local tradeId = t.tradeID
	local result = t.tradeRet
	local version = t.tradeVersion
	local passiveId = t.targetRoleID -- 和我建立起交易的对方id
	local level = t.targetLevel
	local roleName = t.targetName
	
	dump({tradeId=tradeId, result=result, version=version,passiveId=passiveId,level=level,roleName=roleName}, "返回给A和B[B应答A的交易请求]")
	
	-- AB同时给对方发送交易请求的特殊情况
	if tTrade.req ~= nil and tTrade.req.mRoleId == passiveId then
		cleanup_req()
	end
	
	if result then
		local record = buildTradingBarStruct(tradeId, version, passiveId, roleName, level)
		tTrade.trading = record
		broadcast("TradeEstablish", {record=record})
	else
		dump("对方/我 拒绝/不能 交易")
	end
end)

-- 提交|取消 本次交易返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_TRADERET, function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TradeDoRetProtocol", buff)
	--dump(t, "提交|取消 本次交易返回")
				
	local tradeId = t.tradeID
	local roleId = t.roleID -- 表示操作是由谁发起的，交易的双方都会收到该消息
	local result = t.isTrade
	
	dump({tradeId=tradeId, roleId=roleId, result=result}, "提交|取消 交易返回")
	
	local record = tTrade.trading
	if not record then
		dump("没有进行中的交易")
		return
	end
	
	if tradeId ~= record.mTradeId then
		dump("交易ID不匹配")
		return
	end
	
	if roleId == G_ROLE_MAIN.obj_id then
		record.mOneselfState = result and "ok" or "cancel"
		dump(record, "mOneself")
	elseif roleId == record.mRoleId then
		record.mOtherState = result and "ok" or "cancel"
		dump(record, "trademOther")
	else
		dump("无效的roleId:"..tostring(roleId))
	end
	
	if record.mOneselfState == "cancel" then
		cleanup()
		broadcast("oneselfCanceled")
	elseif record.mOtherState == "cancel" then
		cleanup()
		broadcast("otherCanceled")
	elseif record.mOneselfState == "ok" and record.mOtherState == "ok" then
		cleanup()
		broadcast("tradeCompleted")
	elseif record.mOneselfState == "ok" then
		broadcast("oneselfCompleted")
	elseif record.mOtherState == "ok" then
		TIPS({ type = 1  , str = game.getStrByKey("trade_opposite_side_confirmed_tips") })
	end
end)

-- 提交|取消 本次交易
submit = function(self, value)
	dump({value=value}, "提交|取消 交易")
	
	local record = tTrade.trading
	if not record then
		dump("没有进行中的交易")
		return
	end
	
	if value then
		if not record.mOneselfLocked then
			TIPS({ type = 1  , str = game.getStrByKey("trade_initiative_lock_tips") })
			return
		elseif not record.mOtherLocked then
			TIPS({ type = 1  , str = game.getStrByKey("trade_passive_lock_tips") })
			return
		end
	end
	--if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_TRADE, "iibi", record.mTradeId, G_ROLE_MAIN.obj_id, value, record.mVersion)
	local t = {}
	t.tradeID = record.mTradeId
	t.isTrade = value
	t.version = record.mVersion
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_TRADE, "TradeDoProtocol", t)
end

local buildTradingBarItem = function(bagPos, tradingBarPos, protoId, tradingBarNum, grid)
	local item = {}
	item.bagPos = bagPos
	item.tradingBarPos = tradingBarPos
	item.protoId = protoId
	item.tradingBarNum = tradingBarNum
	item.grid = grid
	return item
end

-- 放入|取出 物品返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_ITEMRET, function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TradeItemRetProtocol", buff)
	--dump(t, "放入|取出 物品返回")

	local MPackManager  = require "src/layers/bag/PackManager"
	local roleId = t.roleID
	local tradingBarPos = t.tradeItemSlot
	local tradingBarNum = t.itemNum
	local version = t.version
	local pbitem = t.itemInfo
	
	dump({roleId=roleId, tradingBarPos=tradingBarPos, tradingBarNum=tradingBarNum, version=version}, "放入|取出 物品返回")
	
	local bagPos, grid, protoId
	if tradingBarPos ~= -1 then -- -1 表示放入的是元宝
		local item = protobuf.decode("PBItem", pbitem)
		bagPos = item.slot
		dump(bagPos, "bagPos")
		grid = MPackManager:convertPBItemToGrid(item)
		dump(grid, "grid")
		protoId = item.protoId
	end
	-------------------------------
	local record = tTrade.trading
	if not record then
		dump("没有进行中的交易")
		return
	end
	
	record.mVersion = version
	
	local goods = buildTradingBarItem(bagPos, tradingBarPos, protoId, tradingBarNum, grid)
	
	if roleId == G_ROLE_MAIN.obj_id then
		record.mOneself[tradingBarPos] = goods
		broadcast("oneselfGoodsChanged", goods)
	elseif roleId == record.mRoleId then
		record.mOther[tradingBarPos] = goods
		broadcast("otherGoodsChanged", goods)
	else
		dump("无效的roleId:"..tostring(roleId))
	end
end)

-- 放入|取出 物品
preparingItems = function(self, bag, num, tradingBar)
	dump({bagPos=bag, num=num, tradingBarPos=tradingBar}, "放入|取出 物品")
	
	local record = tTrade.trading
	if not record then
		dump("没有进行中的交易")
		return
	end
	
	if record.mOneselfLocked then
		dump("已锁定")
		return
	end
	
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_ITEMREQ, "iiiii", record.mTradeId, G_ROLE_MAIN.obj_id, bag, num, tradingBar)
	local t = {}
	t.tradeID = record.mTradeId
	t.bagSlot = bag
	t.itemNum = num
	t.operation = tradingBar
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_ITEMREQ, "TradeItemReqProtocol", t)
end

-- 锁定|解锁 物品返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_LOCKRET, function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TradeLockRetProtocol", buff)
	--dump(t, "锁定|解锁 物品返回")
			
	local tradeId = t.tradeID
	local roleId = t.roleID
	
	dump({tradeId=tradeId, roleId=roleId}, "锁定|解锁 物品返回")
	
	local record = tTrade.trading
	if not record then
		dump("没有进行中的交易")
		return
	end
	
	if tradeId ~= record.mTradeId then
		dump("交易ID不匹配")
		return
	end
	
	if roleId == G_ROLE_MAIN.obj_id then
		record.mOneselfLocked = true
		broadcast("oneselfLocked")
	elseif roleId == record.mRoleId then
		record.mOtherLocked = true
		broadcast("otherLocked")
	else
		dump("无效的roleId:"..tostring(roleId))
	end
	
end)

-- 锁定|解锁 物品
lock = function(self)
	local record = tTrade.trading
	if not record then
		dump("没有进行中的交易")
		return
	end
	--if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
	--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_LOCK, "ii", record.mTradeId, G_ROLE_MAIN.obj_id)
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_LOCK, "TradeLockProtocol", {tradeID=record.mTradeId})
end

-- 屏蔽|开启交易 返回
g_msgHandlerInst:registerMsgHandler(TRADE_SC_BLOCKTRADE, function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("TradeBlockRetProtocol", buff)
	--dump(t, "屏蔽|开启交易 返回")
				
	local blocked = t.isBlock
	dump( "自动屏蔽交易请求返回:" .. (blocked and "是" or "否") )
end)

-- 屏蔽|开启交易
block = function(self, value)
	if G_ROLE_MAIN then
		dump( "自动屏蔽交易请求:" .. (value and "是" or "否") )
		--g_msgHandlerInst:sendNetDataByFmtExEx(TRADE_CS_BLOCKTRADE, "ib", G_ROLE_MAIN.obj_id, value)
		g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_BLOCKTRADE, "TradeBlockProtocol", {isBlock=value})
		setGameSetById(GAME_SET_ID_FORBID_TRADE, value and 1 or 0)
	end
end
--------------------------------------------------------------------------------------------------
-- 己方的交易栏数据
oneselfTradingBar = function(self)
	local record = tTrade.trading
	if record then return record.mOneself end
end

-- 对方的交易栏数据
otherTradingBar = function(self)
	local record = tTrade.trading
	if record then return record.mOther end
end

-- 用自己背包中的格子在交易栏中搜索
searchInTradingBar = function(self, gridId)
	local tradingBar = self:oneselfTradingBar()
	if tradingBar then
		for k, v in pairs(tradingBar) do
			if v.bagPos == gridId then
				return tradingBar[k]
			end
		end
	end
end
--------------------------------------------------------------------------------------------------