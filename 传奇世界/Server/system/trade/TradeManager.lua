--TradeManager.lua
--/*-----------------------------------------------------------------
 --* Module:  TradeManager.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月14日
 --* Purpose: Implementation of the class TradeManager
 -------------------------------------------------------------------*/

require ("system.trade.UserInfo")
require ("system.trade.Trade")
require ("system.trade.TradeServlet")
require ("system.trade.TradeConstants")
require ("system.trade.TradeMallDB")

TradeManager = class(nil, Singleton, Timer)

function TradeManager:__init()
	self._tradeActive = 1
	self._mallActive = 1	
	self._meritoriousActive = 1
	self._factionshopActive = 1

	self._UserInfos = {} --运行时ID 
	self._AllTrade = {}
	self._mTradeID = 0
	self._releaseTradeIDs = {}
	self._roleDBData = {}
	self._serverLimitTable = {}

	self._updateMinite = 0 						--math.random(5)  刷新分钟数随机
	--if self._updateMinite < 1 then
		--self._updateMinite = 1
	--end

	--self._AllLimitData = {}			--全服限购数据	20151030
	gTimerMgr:regTimer(self, 1000, 10000)
	print("TradeManager Timer ID: ", self._timerID_, self._updateMinite)
	
	loadShopDB()
	loadVIPDB()
	loadTradeLimit()
	
	self._refreshDay = 0
	self._refreshMin = 0
	
	--gTimerMgr:regTimer(self, 0, 1000)
	g_listHandler:addListener(self)
end

--20151030
function TradeManager:setAllLimitData(data)
	g_TradePublic:setAllLimitData(data)
	--self._AllLimitData = unserialize(data)
end


function TradeManager:hotUpdate()
	ShopTable = {}
	ShopCount = {}
	PriceTable = {}
	--LimitTable = {}
	--VIPshopTable = {}
	loadShopDB()
	--loadVIPDB()
end

function TradeManager:hotUpdateLimit()
	loadTradeLimit()
end

function TradeManager.loadDBData(player, cache_buf, roleSid)
	g_tradeMgr:onloadDBData(player, cache_buf, roleSid)
end

function TradeManager:onloadDBData(player, cache_buf, roleSid)
	if not player then return end
	local UID = player:getID()

	local User = self:getUserInfo(player:getID())
	if not User then
		User = UserInfo(UID)
		self._UserInfos[UID] = User
	end

	if User then
		User:loadDBMyData(cache_buf)
	end
end

function TradeManager:serverDailyInit()
end

function TradeManager:serverMinInit()	
end

--玩家上线
function TradeManager:onPlayerLoaded(player)	
	if not player then return end
	local UID = player:getID()

	local User = self:getUserInfo(player:getID())
	if not User then
		User = UserInfo(UID)
		self._UserInfos[UID] = User
	end
end

--玩家掉线
function TradeManager:onPlayerInactive(player)
	local UID = player:getID()
	local User = self:getUserInfo(UID)
	if User then
		User:setUpdateDB(true)
		User:cast2DB()
		User:Offline()		
	end
end

----玩家下线
function TradeManager:onPlayerOffLine(player)
	local UID = player:getID()
	local User = self:getUserInfo(UID)
	if User then
		User:setUpdateDB(true)
		User:cast2DB()
		User:Offline()	
		self._UserInfos[UID] = nil
	end
end

--玩家掉线
function TradeManager:onPlayerInactive(player)
end

--玩家掉线登陆
function TradeManager:onActivePlayer(player)
end

--玩家死亡
function TradeManager:onPlayerDied(UID)
	local User = self:getUserInfo(UID)
	if User then
		User:Offline()
	end
end

--切换出world的通知
function TradeManager:onSwitchWorld2(roleID, peer, dbid, mapID)
end

--切换到本world的通知
function TradeManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_TRADE_SETS then
	end
end

--创建交易
function TradeManager:tradeCreate(AID, BID)
    local UserA = self:getUserInfo(AID)
	local UserB = self:getUserInfo(BID)
	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)

	if not playerA or not playerB then 
		return 
	end
	
	local spaceA = playerA:getServerID()
	local spaceB = playerB:getServerID()
		
	--玩家是否在线
	if not UserA or not UserB then
		self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
		--print("not on line")
		return
	end
	
	--不同服
	if spaceA ~= spaceB then
		self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_SPACE, 0, {})
		return
	end
	
	--玩家A的背包空间
	if playerA:getItemMgr():getEmptySize() < 4 then
	    self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_BAG_NOTENOUGH, 0, {})
		return
	end
	--玩家是否在交易
	local stateA = UserA:getTradeState()
	local stateB = UserB:getTradeState()
	if TRADE_ON == stateA or TRADE_ON == stateB then
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_ON_TRADING, 0, {})
		self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
		--print("somebody is trading")
		return
	end
	--B玩家是否允许交易
	local permitB = UserB:getBlockTrade()
	if true == permitB then
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_BLOCK_TRADE, 0, {})
	    self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
		--print("b is not permitted")
		return
	end
	
	local TID = self:reqNewID()
	local trade = Trade(TID, AID, BID)
	if trade then
		table.insert(self._AllTrade, TID, trade) 
		UserA:addTrade(TID)
		UserB:addTrade(TID)
		self:SEND_TRADE_SC_ARET(AID, BID, TID, true, playerB:getName(), playerB:getLevel())
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_REQ_SEND, 0, {})
		return trade
	end
	
	self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
	print("unknown situation")
end

function TradeManager:createNewTrade(AID, BID)
	local UserA = self:getUserInfo(AID)
	local UserB = self:getUserInfo(BID)
	
	local TID = self:reqNewID()
	local trade = Trade(TID, AID, BID)
	if trade then
		table.insert(self._AllTrade, TID, trade) 
		UserA:addTrade(TID)
		UserB:addTrade(TID)
		--self:SEND_TRADE_SC_ARET(AID, BID, TID, true, playerB:getName(), playerB:getLevel())
		--g_tradeMgr:sendErrMsg2Client(AID, TRADE_REQ_SEND, 0, {})
		return trade
	end
end

--删除交易
function TradeManager:tradeDelete(TID)
	local trade = self:getTradeInfo(TID)
	if not trade then
		return
	end
	local AID = trade:getUserAID()
	local BID = trade:getUserBID()

	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerA or not playerB then return end

	local UserA = self:getUserInfo(AID)	
	if UserA then
		UserA:delTrade(TID)

		self:SEND_TRADE_SC_RET(AID, TID, false,BID,playerB:getLevel(),playerB:getName())
	end				
		
	local UserB = self:getUserInfo(BID)	
	if UserB then
		UserB:delTrade(TID)
		self:SEND_TRADE_SC_RET(BID, TID, false,AID,playerA:getLevel(),playerA:getName())
		UserB:setRecvApplyTick(0)
	end		
	table.insert(self._releaseTradeIDs, TID)
	self._AllTrade[TID] = nil
end

--交易完成
function TradeManager:tradeFinish(TID)
	local trade = self:getTradeInfo(TID)
	if not trade then
		return
	end
	local AID = trade:getUserAID()	
	local UserA = self:getUserInfo(AID)	
	if UserA then
		UserA:delTrade(TID)
	end				
	local BID = trade:getUserBID()	
	local UserB = self:getUserInfo(BID)	
	if UserB then
		UserB:delTrade(TID)
	end		
	table.insert(self._releaseTradeIDs, TID)
	self._AllTrade[TID] = nil
end

function TradeManager:SEND_TRADE_SC_ARET(UID, BID, TID, b_trade, Name_A, Level_A)
	local retData = {}
	retData.bRoleID = BID
	retData.tradeID = TID
	retData.tradeRet = b_trade
	retData.bName = Name_A
	retData.bLevel = Level_A	
	fireProtoMessage(UID,TRADE_SC_ARET,"TradeARetProtocol",retData)
end

function TradeManager:SEND_TRADE_SC_RET(UID, TID, b_trade, targetID, targetLvl, targetName)
	local retData = {}
	retData.tradeID = TID
	retData.tradeRet = b_trade
	retData.tradeVersion = 0
	retData.targetRoleID = targetID
	retData.targetLevel = targetLvl
	retData.targetName = targetName	
	fireProtoMessage(UID,TRADE_SC_RET,"TradeRetProtocol",retData)
end

function TradeManager:getPrice(itemID, shopType)
	if shopType == nil then
		shopType = 0
	end
	return PriceTable[shopType][itemID].price
end

function TradeManager.getShopPrice(itemID)
	return PriceTable[0][itemID].price
end

function TradeManager:getItem(itemID)
	if itemID and MallItemTable[itemID] then
		local shopType = MallItemTable[itemID].shop_type
		if shopType then
			return ShopTable[shopType][itemID]
		end
	end
	return nil
end

function TradeManager:getTradeInfo(TID)
	return self._AllTrade[TID]
end

function TradeManager:getUserInfo(UID)
	return self._UserInfos[UID]
end

--缓存下数据库的商城数据
function TradeManager.LoadTradeData(roleID, buff)
	g_tradeMgr._roleDBData[roleID] = buff
end

--申请tradeID优先从回收表取
function TradeManager:reqNewID()
	if table.size(self._releaseTradeIDs) > 0 then
		local id = self._releaseTradeIDs[1]
		table.remove(self._releaseTradeIDs, 1)
		return id
	else
		self._mTradeID = self._mTradeID + 1
		return self._mTradeID
	end
end

function TradeManager:formalTime()
	local time = os.date
	
end	

function TradeManager:test(UID)
	
end

--整点更新商城受限物品购买记录	20150921
--function TradeManager:onWholeClock(hour)
--end

function TradeManager:update()
	local nowHour = tonumber(os.date("%H"))
	local nowMinite = tonumber(os.date("%M"))
	local nowSecond = tonumber(os.date("%S"))
	
	if 0==nowHour and self._updateMinite==nowMinite and nowSecond<10 then
		g_TradePublic:updateAllLimitData("{}")
		--updateCommonData(MALL_ALL_LIMIT,self._AllLimitData)

		for i,v in pairs(self._UserInfos) do
			local user = self:getUserInfo(i)
			if user then
				user:updateTimetick()
				user:clearRoleLimit()
			end
		end
	end
end

function TradeManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(TradeServlet.getInstance():getCurEventID(), roleId, EVENT_TRADE_SETS, errId, paramCount, params)	
end

function TradeManager:sendErrMsg2Client2(roleId, eventID, errId, paramCount, params)
	fireProtoSysMessage(TradeServlet.getInstance():getCurEventID(), roleId, eventID, errId, paramCount, params)
end

function TradeManager:setTradeActive(value)
	self._tradeActive = tonumber(value)
end

function TradeManager:getTradeActive()
	return self._tradeActive
end

function TradeManager:setMallActive(value)
	self._mallActive = tonumber(value)
end

function TradeManager:getMallActive()
	return self._mallActive
end

function TradeManager:setMeritoriousActive(value)
	self._meritoriousActive = tonumber(value)
end

function TradeManager:getMeritoriousActive()
	return self._meritoriousActive
end

function TradeManager:setFactionshopActive(value)
	self._factionshopActive = tonumber(value)
end

function TradeManager:getFactionshopActive()
	return self._factionshopActive
end

function TradeManager.getInstance()
	return TradeManager()
end

g_tradeMgr = TradeManager.getInstance()