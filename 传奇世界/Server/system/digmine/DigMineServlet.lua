--DigMineServlet.lua
--/*-----------------------------------------------------------------
--* Module:  DigMineServlet.lua
--* Author:  Andy
--* Modified: 2016年1月7日
--* Purpose: Implementation of the class DigMineServlet
-------------------------------------------------------------------*/

DigMineServlet = class(EventSetDoer, Singleton)

function DigMineServlet:__init()
	self._doer = {
		[DIGMINE_CS_OPEN]				= DigMineServlet.open,
		[DIGMINE_CS_EXCHANGE]			= DigMineServlet.exchange,
		[DIGMINE_CS_JOIN]				= DigMineServlet.join,
		[DIGMINE_CS_QUIT]				= DigMineServlet.quit,
		[DIGMINE_CS_START]				= DigMineServlet.start,
		[DIGMINE_CS_OFFMINE_REWARD]		= DigMineServlet.offMienReward,
		[DIGMINE_CS_SIMULATION_FINISH]	= DigMineServlet.simulationFinish,
		[DIGMINE_CS_SIMULATION_QUIR]	= DigMineServlet.simulationQuit,
	}
end

--打开活动界面
function DigMineServlet:open(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "DigMineOpen")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then return end
	local playerInfo = g_digMineMgr:getPlayerInfo(player:getID())
	if player and playerInfo then
		local exchangeTime = playerInfo:getExchangeTime()
		if exchangeTime == 0 or time.toedition("day", os.time()) ~= time.toedition("day", exchangeTime) then
			playerInfo:setExchangeTime(os.time())
			playerInfo:setExchangeCount(0)
			playerInfo:cast2DB()
		end
		local count, reward = g_digMineMgr:getRewardData(playerInfo:getExchangeCount() + 1)
		local canExchange = false
		if playerInfo:getExchangeCount() < DIGMINE_EXCHANGE_COUNT then
			canExchange = true
		end
		local reward = {}
		for _, item in pairs(reward or {}) do
			local tmp = {}
			tmp.itemID = item.itemID
			tmp.count = item.count
			table.insert(reward, tmp)
		end
		local ret = {}
		ret.canExchange = canExchange
		ret.reward = reward
		fireProtoMessage(player:getID(), DIGMINE_SC_OPEN_RET, "DigMineOpenRet", ret)
	end
end

--兑换奖励
function DigMineServlet:exchange(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "DigMineExchange")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then return end
	local roleID = player:getID()
	if player:getLevel() < DIGMINE_OPEN_LEVEL then
		g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_LESS_LEVEL2, 0, {})
		return
	end
	local playerInfo = g_digMineMgr:getPlayerInfo(roleID)
	if not player or not playerInfo then return end
	local exchangeTime = playerInfo:getExchangeTime()
	if exchangeTime == 0 or time.toedition("day", os.time()) ~= time.toedition("day", exchangeTime) then
		playerInfo:setExchangeTime(os.time())
		playerInfo:setExchangeCount(0)
		playerInfo:cast2DB()
	end
	local exchangeCount = playerInfo:getExchangeCount()
	if exchangeCount >= DIGMINE_EXCHANGE_COUNT then
		g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_MAX_EXCHANGE, 0, {})
		return
	end
	local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local count, reward = g_digMineMgr:getRewardData(exchangeCount + 1)
	if itemMgr:getItemCount(DIGMINE_MINE_ID) >= count then
		exchangeCount = exchangeCount + 1
		playerInfo:setExchangeCount(exchangeCount)
		playerInfo:cast2DB()
		g_normalMgr:activeness(roleID, ACTIVENESS_TYPE.DIGMINE)
		itemMgr:destoryItem(DIGMINE_MINE_ID, count, 0)
		g_logManager:writePropChange(dbid, 2 , 11, matID, 0, count, 1)
		local str1 = tostring(g_configMgr:getItemProto(DIGMINE_MINE_ID).name or "") .. "*" .. count
		local str2 = ""
		if itemMgr:getEmptySize(Item_BagIndex_Bag) >= #reward then
			for _, item in pairs(reward or {}) do
				itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
				g_logManager:writePropChange(dbid, 1, 11, itemID, 0, count, item.bind)
				str2 = str2 .. tostring(g_configMgr:getItemProto(item.itemID).name or "") .. "*" .. item.count
			end
		else
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			email:setDescId(DEGMINE_EMAIL_ID)
			for _, item in pairs(reward) do
				if item.bind == 0 then
					item.bind = false
				end
				email:insertProto(item.itemID, item.count, item.bind, item.strength)
				str2 = str2 .. tostring(g_configMgr:getItemProto(item.itemID).name or "") .. "*" .. item.count
			end
			offlineMgr:recvEamil(dbid, email, 11, 0)
		end
		g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_EXCHANGE_SUCCESS, 2, {str1, str2})

		local canExchange = false
		if playerInfo:getExchangeCount() < DIGMINE_EXCHANGE_COUNT then
			canExchange = true
		end
		local ret = {}
		ret.canExchange = canExchange
		fireProtoMessage(player:getID(), DIGMINE_SC_OPEN_RET, "DigMineOpenRet", ret)
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.DIGMINE, 1)
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.digMineExchage, 1)
	else
		g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_LESS_ITEM, 1, {count})
	end
end

--进入挖矿地图
function DigMineServlet:join(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "DigMineJoin")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then return end
	local roleID = player:getID()
	local playerInfo = g_digMineMgr:getPlayerInfo(roleID)
	if player:getLevel() >= DIGMINE_OPEN_LEVEL and playerInfo then
		local exchangeTime = playerInfo:getExchangeTime()
		if exchangeTime == 0 or time.toedition("day", os.time()) ~= time.toedition("day", exchangeTime) then
			playerInfo:setExchangeTime(os.time())
			playerInfo:setExchangeCount(0)
			playerInfo:cast2DB()
		end
		if playerInfo:getExchangeCount() >= DIGMINE_EXCHANGE_COUNT then
			g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_NO_TIMES, 0, {})
			return
		end
		local x, y = DIGMINE_ENTER_POSITION.x, DIGMINE_ENTER_POSITION.y
		if g_sceneMgr:posValidate(DIGMINE_MAP_ID, x, y) then
			local position = player:getPosition()
			player:setLastMapID(player:getMapID())
			player:setLastPosX(position.x)
			player:setLastPosY(position.y)
			g_sceneMgr:enterPublicScene(roleID, DIGMINE_MAP_ID, x, y, 1)
		end
	end
end

--退出挖矿地图
function DigMineServlet:quit(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "DigMineQuit")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player and player:getMapID() == DIGMINE_MAP_ID then
		g_sceneMgr:enterPublicScene(player:getID(), 3100, 59, 70)
	end
end

--开始挖矿
function DigMineServlet:start(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "DigMineStart")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then return end
	local roleID = player:getID()
	local flag, mineID = req.flag, req.mineID
	if flag == 0 then
		if not g_digMineSimulation:startDigMine(roleID, mineID) then
			g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_KILL_OTHER, 0, {})
		else			
			local buffmgr = player:getBuffMgr()
			buffmgr:addBuff(DIGMINE_BUFFID, 0)
		end
		return
	elseif flag ~= 1 then
		return
	end
	if player:getLevel() < DIGMINE_OPEN_LEVEL then
		g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_LESS_LEVEL, 0, {})
		return
	end
	local playerInfo = g_digMineMgr:getPlayerInfo(roleID)
	if playerInfo then
		local mineUser = g_digMineMgr:getMineUser(mineID)
		if mineUser ~= 0 and mineUser ~= roleID then
			g_digMineMgr:sendErrMsg2Client(roleID, DIGMINE_ERR_KILL_OTHER, 0, {})
			return
		end
		if g_entityMgr:dropMineItem(roleID, 0, DIGMINE_MINE_ID, DIGMINE_MAX_REWARD) == -1 then
			fireProtoMessage(roleID, DIGMINE_SC_MAX_REWARD, "DigMineMaxReward", {})
			return
		end
		if mineUser == 0 and g_digMineMgr:canDigMine(player, mineID) and g_digMineMgr:addMineUser(mineID, roleID) then
			if player:getRideID() ~= 0 then
				g_rideMgr:offRide(dbid)
			end
			g_tlogMgr:TlogHDFlow(player, 1)
			local buffmgr = player:getBuffMgr()
			buffmgr:addBuff(DIGMINE_BUFFID, 0)
		end
	end
end

--领取离线挖矿奖励
function DigMineServlet:offMienReward(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "DigOffMine")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player or not req then return end
	local playerInfo = g_digMineMgr:getPlayerInfo(player:getID())
	if not playerInfo then
		return
	end
	local reward = playerInfo:getOffMineMergeReward()
	if #reward == 0 then
		return
	end
	local quality = unserialize(req.quality)
	local smelteItemList = {}	--需要熔炼的道具
	for i = #reward, 1, -1 do
		local item = reward[i]
		if item.itemID == ITEM_INGOT_ID then
			table.remove(reward, i)
			player:setIngot(player:getIngot() + item.count)
			g_logManager:writeMoneyChange(dbid, "", 3, 90, player:getIngot(), item.count, 1)
		elseif item.itemID == ITEM_BIND_INGOT_ID then
			table.remove(reward, i)
			player:setBindIngot(player:getBindIngot() + item.count)
			g_logManager:writeMoneyChange(dbid, "", 4, 90, player:getBindIngot(), item.count, 1)
		elseif item.itemID == ITEM_MONEY_ID then
			table.remove(reward, i)
			player:setMoney(player:getMoney() + item.count)
			g_logManager:writeMoneyChange(dbid, "", 1, 90, player:getMoney(), item.count, 1)
		elseif #quality > 0 then
			local itemProto = g_entityMgr:getConfigMgr():getItemProto(item.itemID)
			if itemProto and itemProto.type == 1 then
				local color = itemProto.defaultColor
				if color and table.contains(quality, color) then
					table.insert(smelteItemList, {item.itemID, item.count})
					table.remove(reward, i)
				end
			end
		end
	end
	if #smelteItemList > 0 then
		smelterRewardEquip(player, smelteItemList)
	end
	local itemMgr = player:getItemMgr()
	if itemMgr and itemMgr:getEmptySize(Item_BagIndex_Bag) >= #reward then
		for _, item in pairs(reward) do
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
			g_ActivityMgr:writeLog(dbid, 1, 90, item.itemID, item.count, item.bind, player)
		end
	else
		local offlineMgr = g_entityMgr:getOfflineMgr()
		local email = offlineMgr:createEamil()
		email:setDescId(DEGMINE_OFF_EMAIL_ID)
		for _, item in pairs(reward) do
			if item.bind == 0 then
				item.bind = false
			end
			email:insertProto(item.itemID, item.count, item.bind, item.strength)
		end
		offlineMgr:recvEamil(dbid, email, 90, 0)
	end
	--player:setXP(player:getXP() + playerInfo:getOffMineExp())
	--Tlog[PlayerExpFlow]
	addExpToPlayer(player,playerInfo:getOffMineExp(),90)

	playerInfo:setOffMineReward({})
	playerInfo:setOffMineMergeReward({})
	playerInfo:setOffMineExp(0)
	playerInfo:setLastDigTime(0)
	playerInfo:cast2DB()
end

--完成模拟挖矿
function DigMineServlet:simulationFinish(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "DigMineSimulationFinish")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		g_digMineSimulation:finishCopy(player:getID())
	end
end

--退出模拟挖矿地图
function DigMineServlet:simulationQuit(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "DigMineSimulationQuit")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		g_digMineSimulation:quitCopy(player:getID())
	end
end

function DigMineServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! DigMineServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function DigMineServlet.getInstance()
	return DigMineServlet()
end

g_eventMgr:addEventListener(DigMineServlet.getInstance())