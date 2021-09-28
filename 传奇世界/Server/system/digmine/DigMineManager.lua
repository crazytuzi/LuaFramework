--DigMineManager.lua
--/*-----------------------------------------------------------------
--* Module:  DigMineManager.lua
--* Author:  Andy
--* Modified: 2016年1月7日
--* Purpose: Implementation of the class DigMineManager
-------------------------------------------------------------------*/

require ("system.digmine.DigMineConstant")
require ("system.digmine.DigMinePlayer")
require ("system.digmine.DigMineServlet")
require ("system.digmine.DigMineSimulation")

DigMineManager = class(nil, Singleton, Timer)

function DigMineManager:__init()
	self._mineConfig = {}		--挖矿配置
	self._mineInfo = {}	 		--矿实体ID对应的配置ID及坐标索引
	self._mineRewardNum = {}	--每个矿堆剩余可挖的矿数量
	self._refreshPosition = {}	--刷新坐标索引
	self._digMineUser = {}		--玩家在线挖矿数据
	self._rewardData = {}		--奖励数据
	self._mineUser = {}			--矿堆对应的玩家数据
	self._remindUser = {}		--当前已挖满扔继续挖需要提醒的玩家

	self._offMineConfig = {}	--离线挖矿配置
	self._pushOffMineUser = {}	--延时推送离线挖矿奖励的用户

	self._tick = os.time()

	self:initialize()
	g_listHandler:addListener(self)

	gTimerMgr:regTimer(self, 3000, 3000)
	print("DigMineManager TimeID:",self._timerID_)
end

function DigMineManager:initialize()
	self:initConfig()
	for times, data in pairs(DIGMINE_DROP_ID) do
		if not self._rewardData[times] then
			self._rewardData[times] = {}
			self._rewardData[times].reward = {}
			self._rewardData[times].count = data.count
		end
		local dropItem = dropString(0, 0, data.dropID)
		for _, item in pairs(dropItem) do
			local tmp = {
				itemID = item.itemID,
				count = item.count,
				strength = item.strength,
				bind = item.bind,
			}
			table.insert(self._rewardData[times].reward, tmp)
		end
	end
	for i = 1, #DEGMINE_MINE_POSITION do
		table.insert(self._refreshPosition, i)
	end
	local scene = g_sceneMgr:getPublicScene(DIGMINE_MAP_ID)
	if scene then
		for _, config in pairs(self._mineConfig) do
			local mine = g_entityFct:createMonster(config.mineID)
			if mine then
				self:enterMineScene(mine:getID(), config.id)
			end
		end
	end
end

function DigMineManager:enterMineScene(mineID, id)
	local random = math.random(table.size(self._refreshPosition))
	local index = self._refreshPosition[random] or 1
	table.removeValue(self._refreshPosition, index)
	local pos = DEGMINE_MINE_POSITION[index]
	g_sceneMgr:enterPublicScene(mineID, DIGMINE_MAP_ID, pos.x, pos.y, 1)
	self._mineUser[mineID] = 0
	self._mineInfo[mineID] = {id = id, index = index}
	self._mineRewardNum[mineID] = self:getMaxMineNum(mineID)
end

function DigMineManager:initConfig()
	for _, config in pairs(require "data.mineDB") do
		local tmp = {}
		tmp.id = config.q_id
		tmp.mineID = config.q_ore
		tmp.dropID = config.q_drop
		tmp.num = config.q_num
		self._mineConfig[tmp.id] = tmp
	end
	for _, dropData in pairs(require "data.MTRewardDB") do
		local tmp = {}
		tmp.level = dropData.q_level
		tmp.copper = dropData.q_copper_dl
		tmp.silver = dropData.q_silver_dl
		tmp.goal = dropData.q_goal_dl
		tmp.exp = dropData.q_exp
		self._offMineConfig[tmp.level] = tmp
	end
end

--头顶满后道具直接进背包
function DigMineManager.addMineItem(roleSID, itemID, count, bind, strength)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	g_digMineMgr:sendErrMsg2Client(player:getID(), DIGMINE_ERR_GET_MINE, 0, {})
	local itemMgr = player:getItemMgr()
	if itemMgr and itemMgr:getEmptySize(Item_BagIndex_Bag) >= 1 then
		itemMgr:addItem(Item_BagIndex_Bag, itemID, count, bind, 0, 0, strength)
		g_logManager:writePropChange(roleSID, 1, 11, itemID, 0, count, bind)
	else
		local offlineMgr = g_entityMgr:getOfflineMgr()
		local email = offlineMgr:createEamil()
		email:setDescId(DEGMINE_EMAIL_ID)
		email:insertProto(itemID, count, bind, strength)
		offlineMgr:recvEamil(roleSID, email, 11, 0)
	end
	local playerInfo = g_digMineMgr:getPlayerInfo(player:getID())
	if playerInfo then
		playerInfo:setMineNum(playerInfo:getMineNum() + count)
	end
end

function DigMineManager:update()
	local now = os.time()
	for roleID, t in pairs(self._pushOffMineUser) do
		if now - t >= 3 then
			self:pushOffmineReward(roleID)
			self._pushOffMineUser[roleID] = nil
		end
	end
	for mineID, roleID in pairs(self._mineUser) do
		if roleID ~= 0 then
			local player = g_entityMgr:getPlayer(roleID)
			if player and player:hasEffectState(DIGMINE_INMINE) then
				if not self:canDigMine(player, mineID) then
					self:releaseMineUser(mineID)
					local buffmgr = player:getBuffMgr()
					if buffmgr then
						buffmgr:delBuff(DIGMINE_BUFFID)
					end
				else
					local dropID = self:getDropID(mineID)
					local result = g_entityMgr:dropMineItem(roleID, dropID, DIGMINE_MINE_ID, DIGMINE_MAX_REWARD)
					if result == -1 and not self:getRemindUser(roleID) then
						fireProtoMessage(roleID, DIGMINE_SC_MAX_REWARD, "DigMineMaxReward", {})
						self:setRemindUser(roleID, now)
					end
					if result > 0 then
						self:setMineRewardNum(mineID, self:getMineRewardNum(mineID) - result)
					end
				end
			else
				self:releaseMineUser(mineID)
			end
		end
	end
	for roleID, tick in pairs(self._remindUser) do
		if now - tick >= 60 then
			self._remindUser[roleID] = nil
		end
	end
	if now - self._tick > 30 then
		self._tick = now
		local timeTick = time.toedition("day")
		for roleID, playerInfo in pairs(self._digMineUser) do
			if now - playerInfo:getCast2DBTime()  > DIGMINE_PERIOD then
				playerInfo:cast2DB()
				playerInfo:setCast2DBTime(now)
			end
			if timeTick ~= time.toedition("day", playerInfo:getExchangeTime()) then
				playerInfo:setExchangeTime(now)
				playerInfo:setExchangeCount(0)
				fireProtoMessage(roleID, DIGMINE_SC_OPEN_RET, "DigMineOpenRet", {canExchange = true})
			end
		end
	end
end

function DigMineManager:canDigMine(player, mineID)
	local mine = g_entityMgr:getMonster(mineID)
	if player:getMapID() == DIGMINE_MAP_ID and mine then
		local playerTile, mineTile = player:getTile(), mine:getTile()
		local x, y = math.abs(playerTile.x - mineTile.x), math.abs(playerTile.y - mineTile.y)
		if x * x + y * y <= 9 then
			return true
		end
	end
	return false
end

--头顶物品时间到进包裹
function DigMineManager:onGotDropItem(player, itemID)
	if itemID ~= DIGMINE_MINE_ID then
		return
	end
	local playerInfo = self:getPlayerInfo(player:getID())
	if playerInfo then
		playerInfo:setMineNum(playerInfo:getMineNum() + 1)
	end
end

--捡到矿石结晶
function DigMineManager:onShowDropItem(player, itemID)
	if player:getRideID() ~= 0 and itemID == DIGMINE_MINE_ID then
		g_rideMgr:offRide(player:getSerialID())
	end
end

--玩家被杀(killID:杀人的玩家动态ID)
function DigMineManager:onPlayerDied(player, killerID)
	local playerInfo, killPlayerInfo = self:getPlayerInfo(player:getID()), self:getPlayerInfo(killerID)
	if playerInfo then
		playerInfo:setKillerNum(playerInfo:getKillerNum() + 1)
	end
	if killPlayerInfo then
		killPlayerInfo:setKillNum(killPlayerInfo:getKillNum() + 1)
	end
end

--切换场景
function DigMineManager:onSwitchScene(player, mapID)
	local buffmgr = player:getBuffMgr()
	if buffmgr and player:hasEffectState(DIGMINE_INMINE) then
		buffmgr:delBuff(DIGMINE_BUFFID)
	end
	if mapID == DIGMINE_MAP_ID then
		local playerInfo = self:getPlayerInfo(player:getID())
		if not playerInfo then
			return
		end
		playerInfo:setEnterTime(os.time())
		player:setLastMapID(mapID)
	end
	if mapID ~= DIGMINE_MAP_ID and player:getLastMapID() == DIGMINE_MAP_ID then
		local playerInfo = self:getPlayerInfo(player:getID())
		if not playerInfo or playerInfo:getEnterTime() == 0 then
			return
		end
		g_tlogMgr:TlogMXWKFlow(player, os.time() - playerInfo:getEnterTime(), playerInfo:getKillNum(), playerInfo:getKillerNum(), playerInfo:getMineNum())
		playerInfo:setEnterTime(0)
		playerInfo:setKillNum(0)
		playerInfo:setKillerNum(0)
		playerInfo:setMineNum(0)
	end
end

--玩家上线
function DigMineManager:onPlayerLoaded(player)
end

--玩家掉线
function DigMineManager:onPlayerInactive(player)
	local mineID = self:getUserMineID(player:getID())
	if mineID ~= 0 then
		self:releaseMineUser(mineID)
	end
end

--玩家下线
function DigMineManager:onPlayerOffLine(player)
	local roleID = player:getID()
	local mineID = self:getUserMineID(roleID)
	if mineID ~= 0 then
		self:releaseMineUser(mineID)
	end
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		--玩家离线奖励没有领取下线前通过邮件发送
		local reward = playerInfo:getOffMineMergeReward()
		if #reward > 0 then
			local offlineMgr = g_entityMgr:getOfflineMgr()
			local email = offlineMgr:createEamil()
			email:setDescId(DEGMINE_OFF_EMAIL_ID)
			if playerInfo:getOffMineExp() > 0 then
				email:insertProto(ITEM_EXP_ID, playerInfo:getOffMineExp(), false)
			end
			for _, item in pairs(reward) do
				if item.bind == 0 then
					item.bind = false
				end
				email:insertProto(item.itemID, item.count, item.bind, item.strength)
			end
			offlineMgr:recvEamil(player:getSerialID(), email, 90, 0)
			playerInfo:setOffMineReward({})
			playerInfo:setOffMineMergeReward({})
			playerInfo:setOffMineExp(0)
			playerInfo:setLastDigTime(0)
		end
		playerInfo:cast2DB()
		self._digMineUser[roleID] = nil
	end
end

--加载数据
function DigMineManager.loadDBData(player, cacha_buf, roleSID)
	if #cacha_buf > 0 then
		local roleID = player:getID()
		local playerInfo = g_digMineMgr:getPlayerInfo(roleID)
		playerInfo:loadDBData(cacha_buf)
		if player:getLevel() >= DIGMINE_OFFMINE_LEVEL then
			g_digMineMgr:calcOffMineReward(roleID)
		end
	end
end

function DigMineManager:getPlayerInfo(roleID)
	if not self._digMineUser[roleID] then
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			self._digMineUser[roleID] = DigMinePlayer(player:getSerialID(), roleID)
		end
	end
	return self._digMineUser[roleID]
end

--设置占据矿堆的玩家
function DigMineManager:addMineUser(mineID, roleID)
	if roleID <= 0 then return false end
	--如果之前占据一个矿堆,先让出原来矿堆才能在新的矿堆
	for k, v in pairs(self._mineUser) do
		if v == roleID then
			self:releaseMineUser(k)
		end
	end
	for k, v in pairs(self._mineUser) do
		if k == mineID then
			self._mineUser[mineID] = roleID
			return true
		end
	end
	return false
end

--释放矿堆
function DigMineManager:releaseMineUser(mineID)
	for k, v in pairs(self._mineUser) do
		if k == mineID then
			self._mineUser[mineID] = 0
			break
		end
	end
end

--获取占据矿堆的玩家
function DigMineManager:getMineUser(mineID)
	return self._mineUser[mineID] or 0
end

--获取玩家占据的矿堆ID
function DigMineManager:getUserMineID(roleID)
	for k, v in pairs(self._mineUser) do
		if v == roleID then
			return k
		end
	end
	return 0
end

--获取兑换获得的道具数据及所需的材料个数
function DigMineManager:getRewardData(times)
	if not times or times <= 0 then
		times = 1
	elseif times > table.size(self._rewardData) then
		times = table.size(self._rewardData)
	end
	return self._rewardData[times].count, self._rewardData[times].reward
end

function DigMineManager:getDropID(mineID)
	local config = self:getMineConfig(mineID)
	if config then
		return config.dropID
	end
	return 0
end

function DigMineManager:getMaxMineNum(mineID)
	local config = self:getMineConfig(mineID)
	if config then
		return config.num
	end
	return 0
end

function DigMineManager:getMineConfig(mineID)
	local info = self._mineInfo[mineID]
	if info then
		return self._mineConfig[info.id]
	end
end

function DigMineManager:setRemindUser(roleID, time)
	self._remindUser[roleID] = time
end

function DigMineManager:getRemindUser(roleID)
	return self._remindUser[roleID]
end

function DigMineManager:setMineRewardNum(mineID, num)
	self._mineRewardNum[mineID] = num
	if self._mineRewardNum[mineID] <= 0 then
		local mine = g_entityMgr:getMonster(mineID)
		if mine then
			local roleID = self:getMineUser(mineID)
			if roleID > 0 then
				local player = g_entityMgr:getPlayer(roleID)
				if player then
					local buffmgr = player:getBuffMgr()
					if buffmgr then
						buffmgr:delBuff(DIGMINE_BUFFID)
					end
				end
			end
			self:releaseMineUser(mineID)
			mine:quitScene()
			local info = self._mineInfo[mineID]
			if info then
				local id, index = info.id, info.index
				self:enterMineScene(mineID, id)
				table.insert(self._refreshPosition, index)
			end
		end
	end
end

function DigMineManager:getMineRewardNum(mineID)
	return self._mineRewardNum[mineID] or 0
end

function DigMineManager:canJoin(player)
	local roleID = player:getID()
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo and player:getLevel() >= DIGMINE_OPEN_LEVEL and playerInfo:getExchangeCount() < DIGMINE_EXCHANGE_COUNT and
	g_entityMgr:dropMineItem(roleID, 0, DIGMINE_MINE_ID, DIGMINE_MAX_REWARD) then
		return true
	end
	return false
end

--获取玩家等级对应的离线掉落数据
function DigMineManager:getOffMineConfig(level)
	return self._offMineConfig[level]
end

--计算离线挖矿奖励
function DigMineManager:calcOffMineReward(roleID)
	local player = g_entityMgr:getPlayer(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if not player or not playerInfo then
		return
	end
	local lastLogout = playerInfo:getLastLogout()
	if not lastLogout or lastLogout < g_ActivityMgr:getStartTime() then
		return
	end
	local now = os.time()
	local digTime = now - lastLogout
	if digTime < DIGMINE_PERIOD then
		return
	end
	local dropData = self:getOffMineConfig(player:getLevel())
	if not dropData then
		return
	end
	local school = player:getSchool()
	local sex = player:getSex()
	if digTime > DIGMINE_MAX_TIME then
		digTime = DIGMINE_MAX_TIME
	end
	local multiple = math.floor(digTime / DIGMINE_PERIOD)
	digTime = multiple * DIGMINE_PERIOD
	local exp, reward = dropData.exp * multiple, {}
	if digTime >= DIGMINE_GOAL_LIMIT then
		local times = math.floor(digTime / DIGMINE_GOAL_LIMIT)
		if times > DIGMINE_GOAL_MAX_BOX then
			times = DIGMINE_GOAL_MAX_BOX
		end
		--新手离线挖矿(第一次离线奖励必掉)
		if playerInfo:getNewOffMine() then
			times = times - 1
			local harvest = self:dropOffMineItem(school, sex, DIGMINE_NEW_DROPID, 1, 1)
			reward = table.join(reward, harvest)
			playerInfo:setNewOffMine(false)
		end
		if times > 0 then
			local harvest = self:dropOffMineItem(school, sex, dropData.goal, 1, times)
			reward = table.join(reward, harvest)
		end
	end
	if digTime >= DIGMINE_SILVER_LIMIT then
		local times = math.floor(digTime / DIGMINE_SILVER_LIMIT)
		local harvest = self:dropOffMineItem(school, sex, dropData.silver, 2, times)
		reward = table.join(reward, harvest)
	end
	if digTime >= DIGMINE_COPPER_LIMIT then
		local times = math.floor(digTime / DIGMINE_COPPER_LIMIT)
		local harvest = self:dropOffMineItem(school, sex, dropData.copper, 3, times)
		reward = table.join(reward, harvest)
	end
	playerInfo:setLastDigTime(digTime)
	playerInfo:setOffMineExp(exp)
	if g_ActivityMgr:isEmpty(reward) then
		return
	end
	local mergeReward = {}		--合并相同的道具
	for _, item in pairs(reward) do
		local isMerge, itemID, count, bind, strength = false, item.itemID, item.count, item.bind, item.strength
		for _, v in pairs(mergeReward) do
			if itemID == v.itemID and bind == v.bind then
				v.count = v.count + count
				isMerge = true
				break
			end
		end
		if not isMerge then
			table.insert(mergeReward, {itemID = itemID, count = count, bind = bind, strength = strength})
		end
	end
	playerInfo:setOffMineReward(reward)
	playerInfo:setOffMineMergeReward(mergeReward)
	self._pushOffMineUser[roleID] = now
end

function DigMineManager:dropOffMineItem(school, sex, dropID, type, multiple)
	local reward = {}
	for i = 1, multiple do
		local itemResult = dropString(school, sex, dropID)
		for _, item in pairs(itemResult) do
			local tmp = {}
			tmp.type = type
			tmp.itemID = item.itemID
			tmp.count = item.count
			tmp.bind = item.bind
			tmp.strength = item.strength
			table.insert(reward, tmp)
		end
	end
	return reward
end

--推送离线挖矿奖励
function DigMineManager:pushOffmineReward(roleID, reward)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		local offMineReward = playerInfo:getOffMineReward()
		if #offMineReward > 0 then
			local reward = {}
			for _, item in pairs(offMineReward) do
				local tmp = {}
				tmp.itemID = item.itemID
				tmp.count = item.count
				tmp.type = item.type
				table.insert(reward, tmp)
			end
			local ret = {}
			ret.logout = playerInfo:getLastLogout()
			ret.digTime = playerInfo:getLastDigTime()
			ret.exp = playerInfo:getOffMineExp()
			ret.reward = reward
			fireProtoMessage(roleID, DIGMINE_SC_OFFMINE_RET, 'DigOffMineRet', ret)
		end
	end
end

function DigMineManager:hotUpdateConfig()
	package.loaded["data.mineDB"] = nil
	self:initConfig()
end

function DigMineManager:sendErrMsg2Client(roleID, errId, paramCount, params)
	fireProtoSysMessage(DigMineServlet.getInstance():getCurEventID(), roleID, EVENT_DIGMINE_SETS, errId, paramCount, params)
end

function DigMineManager.getInstance()
	return DigMineManager()
end

g_digMineMgr = DigMineManager.getInstance()