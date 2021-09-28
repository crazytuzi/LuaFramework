--RedBagManager.lua
--/*-----------------------------------------------------------------
--* Module:  RedBagManager.lua
--* Author:  Andy
--* Modified: 2016年05月09日
--* Purpose: Implementation of the class RedBagManager
-------------------------------------------------------------------*/

require ("system.redBag.RedBagConstants")
require ("system.redBag.RedBagServlet")

RedBagManager = class(nil, Singleton, Timer)

function RedBagManager:__init()
	self._userInfo = {}
	self._redBag = {}
	self._redBagId = 0
	self._releaseIDs = {}
	
	g_listHandler:addListener(self)

	gTimerMgr:regTimer(self, 1000, 3600000)
	print("RedBagManager TimeID:",self._timerID_)
end

function RedBagManager:update()
	local now = os.time()
	for redBagID, redBag in pairs(self._redBag) do
		if now - redBag.t > 1800 then
			self:deleteRedBag(redBagID)
		end
	end
end

--玩家上线
function RedBagManager:onPlayerLoaded(player)
	self:getPlayerInfo(player:getID())
end

--玩家注销的消息
function RedBagManager:onPlayerOffLine(player)
	self._userInfo[player:getID()] = nil
end

--玩家充值
function RedBagManager:onPlayerCharge(player, ingot)
	if math.floor(ingot / 10) >= 30 then
		self:sendRedBag(player, math.floor(ingot / 10), 0)
	end
end

--仙翼进阶
function RedBagManager:WingLevelUp(player, level)
	if level >= 3 then
		self:sendRedBag(player, math.min(100, level * level), 0)
	end
end

--技能进阶
function RedBagManager:skillLevelUp(player)
	self:sendRedBag(player, 88, 0)
end

--消耗七彩石打造装备
function RedBagManager.makeEquipment(roleSID, num)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_RedBagMgr:sendRedBag(player, num * 10, 0)
	end
end

--世界boss被击杀
function RedBagManager:worldBossKill(player, bossLevel, bossName)
	self:sendRedBag(player, math.min(100, bossLevel), 1, bossName)
end

--获得中州战胜利
function RedBagManager:winnerManorWar(roleSID, name)
	local num = 666
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		self:sendRedBag(player, num, 2)
	else
		self:sendRedBag2(roleSID, name, num, 2)
	end
end

--获得沙城战胜利
function RedBagManager:winnerShaWar(roleSID, name)
	local num = 888
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		self:sendRedBag(player, num, 3)
	else
		self:sendRedBag2(roleSID, name, num, 3)
	end
end

--申请ID优先从回收表取
function RedBagManager:reqNewID()
	if table.size(self._releaseIDs) > 0 then
		local id = self._releaseIDs[1]
		table.remove(self._releaseIDs, 1)
		return id
	else
		self._redBagId = self._redBagId + 1
		return self._redBagId
	end
end

function RedBagManager:addRedbagUser(redBagID, roleID)
	local redBag = self:getRedBag(redBagID)
	if redBag then
		table.insert(redBag.user, roleID)
		if redBag.num <= 0 then
			g_RedBagMgr:deleteRedBag(redBagID)
		end
	end
end

--能否抢红包
function RedBagManager:canGetRedBag(redBagID, roleID)
	local redBag = self:getRedBag(redBagID)
	if redBag and redBag.num > 0 and not table.contains(redBag.user, roleID) then
		return true
	end
	return false
end

--发红包
function RedBagManager:sendRedBag(player, num, type, param)
	local redBagID = self:reqNewID()
	self._redBag[redBagID] = {num = num, roleSID = player:getSerialID(), name = player:getName(), t = os.time(), user = {}}
	local roleID = player:getID()
	local ret = {}
	ret.id = redBagID
	ret.name = player:getName()
	ret.num = num
	ret.type = type
	ret.param = param or ""
	for k, _ in pairs(self._userInfo) do
		if k ~= roleID and self:getplayerCount(k) < REDBAG_DAY_MAX then
			fireProtoMessage(k, PUSH_SC_RED_BAG, "PushSendRedBag", ret)
		end
	end
	-- self:sendErrMsg2Client(roleID, REDBAG_ERR_SEND_SELF, 1, {num})
end

function RedBagManager:sendRedBag2(roleSID, name, num, type, param)
	local redBagID = self:reqNewID()
	self._redBag[redBagID] = {num = num, roleSID = roleSID, name = name, t = os.time(), user = {}}
	local ret = {}
	ret.id = redBagID
	ret.name = name
	ret.num = num
	ret.type = type
	ret.param = param or ""
	for k, _ in pairs(self._userInfo) do
		if self:getplayerCount(k) < REDBAG_DAY_MAX then
			fireProtoMessage(k, PUSH_SC_RED_BAG, "PushSendRedBag", ret)
		end
	end
end

function RedBagManager:deleteRedBag(redBagID)
	if self._redBag[redBagID] then
		self._redBag[redBagID] = nil
		table.insert(self._releaseIDs, redBagID)
	end
end

function RedBagManager:getPlayerInfo(roleID)
	local playerInfo = self._userInfo[roleID]
	if not playerInfo then
		playerInfo = {time = 0, count = 0}
		self._userInfo[roleID] = playerInfo
	end
	return playerInfo
end

function RedBagManager:getPlayerTime(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		return playerInfo.time
	end
end

function RedBagManager:setPlayerTime(roleID, time)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		playerInfo.time = time
	end
end

function RedBagManager:getplayerCount(roleID)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		return playerInfo.count
	end
end

function RedBagManager:setPlayerCount(roleID, count)
	local playerInfo = self:getPlayerInfo(roleID)
	if playerInfo then
		playerInfo.count = count
	end
end

function RedBagManager:getRedBag(redBagID)
	return self._redBag[redBagID]
end

function RedBagManager:cast2db(roleID)
	local datas = {}
	datas.count = self:getplayerCount(roleID)
	datas.time = self:getPlayerTime(roleID)
	g_commonMgr:setRedBagData(roleID, datas)
end

function RedBagManager:loadDBData(roleID, datas)
	self:setPlayerTime(roleID, datas.time)
	self:setPlayerCount(roleID, datas.count)
	local timeTick = time.toedition("day")
	if self:getPlayerTime(roleID) ~= timeTick then
		self:setPlayerCount(roleID, 0)
		self:setPlayerTime(roleID, timeTick)
	end
end

function RedBagManager:sendErrMsg2Client(roleID, errId, paramCount, params)
	fireProtoSysMessage(RedBagServlet.getInstance():getCurEventID(), roleID, EVENT_PUSH_MESSAGE, errId, paramCount, params)
end

function RedBagManager.getInstance()
	return RedBagManager()
end

g_RedBagMgr = RedBagManager.getInstance()