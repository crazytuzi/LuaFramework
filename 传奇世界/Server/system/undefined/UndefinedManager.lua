--UndefinedManager.lua
--/*-----------------------------------------------------------------
 --* Module:  UndefinedManager.lua
 --* Author:  Andy
 --* Modified: 2016年02月06日
 --* Purpose: Implementation of the class UndefinedManager
 -------------------------------------------------------------------*/
require ("system.undefined.UndefinedServlet")
require ("system.undefined.UndefinedConstant")

UndefinedManager = class(nil, Singleton, Timer)

function UndefinedManager:__init()
	self._bossConfig = {}		--Boss配置
	self._bossInfo = {}			--Boss数据
	self._bossDeathTime = {}	--Boss死亡时间,用于决定下个boss的出生时间
	self._bossLiveNum = 0		--地图上当前活着的Boss数量
	self._nextBossRank = 1		--下一个刷新的Boss顺序
	self._killInfo = {}			--BOSS击杀详情

	self._liveBoss = {}			--当前在地图上的boss(用于GM命令获取坐标)
	self._bossSID = {}			--boss静态ID,用于判定是否为未知暗殿的boss

	self._openSystem = true		--系统是否开放
	self._joinUser = {}			--在未知暗殿地图中的玩家
	self._tLogInfo = {}			--Tlog相关数据

	self:loadConfig()
	g_listHandler:addListener(self)

	if g_spaceID == 0 or g_spaceID == 1 then
		gTimerMgr:regTimer(self, 1000, 3000)
		print("UndefinedManager Timer", self._timerID_)
	end
end

function UndefinedManager:loadConfig()
	for _, record in pairs(require "data.UndefinedDB" or {}) do
		local tmp = {}
		tmp.id = record.q_id
		tmp.rank = record.q_rank
		tmp.position = record.q_pos
		tmp.refreshID = record.q_refreshID
		tmp.refreshTime = record.q_time
		self._bossConfig[tmp.rank] = tmp
		table.insert(self._bossSID, tmp.id)
	end
end

--根据刷新顺获取boss配置出生坐标
function UndefinedManager:getPosition(rank)
	local positions = unserialize(self._bossConfig[rank].position)
	local size = table.size(positions)
	if size == 1 then
		local position = positions[1]
		if position then
			return position[1], position[2]
		end
	elseif size > 1 then
		local random = math.random(1, size)
		local position = positions[random]
		if position then
			return position[1], position[2]
		end
	end
	return 0, 0
end

--根据刷新顺序获取bossID
function UndefinedManager:getBossID(rank)
	return self._bossConfig[rank].id
end

--获取boss刷新时间
function UndefinedManager:getBossRefreshTime(rank)
	return self._bossConfig[rank].refreshTime
end

--获取刷新表ID
function UndefinedManager:getRefreshID(rank)
	return self._bossConfig[rank].refreshID
end

function UndefinedManager:addBossDeathTime(time)
	table.insert(self._bossDeathTime, time)
end

function UndefinedManager:removeBossDeathTime(time)
	table.removeValue(self._bossDeathTime, time)
end

function UndefinedManager:getBossDeathTime()
	return self._bossDeathTime
end

function UndefinedManager:getBoss(rank)
	if self._bossInfo[rank] then
		return self._bossInfo[rank]
	end
end

function UndefinedManager:addBoss(rank, monster)
	self._bossInfo[rank] = monster
end

--刷新Boss
function UndefinedManager:freshBoss(rank)
	local monsterID = self:getBossID(rank)
	if not monsterID then return end
	local refreshID = self:getRefreshID(rank)
	local monster = g_entityMgr:getFactory():createMonster(monsterID)
	local scene = g_sceneMgr:getPublicScene(UNDEFINED_MAP_ID)
	if monster and scene and scene:addMonsterInfoByID(monster, refreshID) then
		local x, y = self:getPosition(rank)
		self:addBoss(rank, monster)
		self._bossLiveNum = self._bossLiveNum + 1
		self._nextBossRank = self._nextBossRank + 1
		self._liveBoss[monster:getID()] = monster
		scene:addMonster(monster)
		scene:attachEntity(monster:getID(), x, y)
	end
end

--杀怪通知
function UndefinedManager:onMonsterKill(monsterSID, roleID, monId, mapId)
	if mapId == UNDEFINED_MAP_ID and table.include(self._bossSID, monsterSID) then
		local monster = g_entityMgr:getMonster(monId)
		if monster then
			self._bossLiveNum = self._bossLiveNum - 1
			if self._bossLiveNum < 0 then
				self._bossLiveNum = 0
			else
				self:addBossDeathTime(os.time())
			end
			self._liveBoss[monster:getID()] = nil
		end
		local player = g_entityMgr:getPlayer(roleID)
		if player then
			local name = player:getName()
			self:sendErrMsg2Client(UNDEFINED_BOSS_KILL, 1, {name})
			table.insert(self._killInfo, {tick = os.time(), name = name})
			if #self._killInfo > 20 then
				table.remove(self._killInfo, 1)
			end
			for roleSID, _ in pairs(self._joinUser) do
				self:getKillInfo(roleSID)
			end
		end
	end
end

function UndefinedManager:update()
	if self._bossLiveNum < 2 then
		--boss刷新顺序超过boss数量时重新从第一个boss开始刷
		if self._nextBossRank > table.size(self._bossConfig) then
			self._nextBossRank = 1
		end
		local bossDeathTime = 0
		if table.size(self._bossDeathTime) > 0 then
			bossDeathTime = math.min(unpack(self._bossDeathTime))
		end
		if os.time() >= bossDeathTime + self:getBossRefreshTime(self._nextBossRank) then
			self:removeBossDeathTime(bossDeathTime)
			self:freshBoss(self._nextBossRank)
		end
	end
end

function UndefinedManager:GMFreshBoss()
	if self._bossLiveNum < 2 then
		--boss刷新顺序超过boss数量时重新从第一个boss开始刷
		if self._nextBossRank > table.size(self._bossConfig) then
			self._nextBossRank = 1
		end
		local bossDeathTime = 0
		if table.size(self._bossDeathTime) > 0 then
			bossDeathTime = math.min(unpack(self._bossDeathTime))
		end
		self:removeBossDeathTime(bossDeathTime)
		self:freshBoss(self._nextBossRank)
	end
end

function UndefinedManager:onPlayerLoaded(player)
	if player:getMapID() == UNDEFINED_MAP_ID then
		self:joinActivity(player:getSerialID())
	end
end

--玩家被杀(killID:杀人的玩家动态ID)
function UndefinedManager:onPlayerDied(player, killerID)
	local tLogInfo = self:getTlogInfo(player:getSerialID())
	tLogInfo.killerNum = tLogInfo.killerNum + 1
	local killPlayer = g_entityMgr:getPlayer(killerID)
	if not killPlayer then
		return
	end
	local killTlogInfo = self:getTlogInfo(killPlayer:getSerialID())
	killTlogInfo.killNum = killTlogInfo.killNum + 1
end

--切换场景
function UndefinedManager:onSwitchScene(player, mapID)
	if mapID ~= UNDEFINED_MAP_ID and player:getLastMapID() == UNDEFINED_MAP_ID then
		local tLogInfo = self:getTlogInfo(player:getSerialID())
		if tLogInfo.enterTime == 0 then
			return
		end
		g_tlogMgr:TlogWZADFlow(player, os.time() - tLogInfo.enterTime, tLogInfo.killNum, tLogInfo.killerNum)
		tLogInfo.enterTime = 0
		tLogInfo.killNum = 0
		tLogInfo.killerNum = 0
	end
end

function UndefinedManager:getOpenSystem()
	return self._openSystem
end

function UndefinedManager:setOpenSystem(flag)
	self._openSystem = flag
	if flag == false then
		self._joinUser = {}
	end
end

function UndefinedManager:getJoinUser()
	return self._joinUser or {}
end

function UndefinedManager:joinActivity(roleSID)
	self._joinUser[roleSID] = true
	self._tLogInfo[roleSID] = {enterTime = os.time(), killNum = 0, killerNum = 0}
end

function UndefinedManager:getTlogInfo(roleSID)
	if not self._tLogInfo[roleSID] then
		self._tLogInfo[roleSID] = {enterTime = os.time(), killNum = 0, killerNum = 0}
	end
	return self._tLogInfo[roleSID]
end

function UndefinedManager:getKillInfo(roleSID)
	fireProtoMessageBySid(roleSID, UNDEFINED_SC_GET_KILL_INFO_RET, "UndefinedKillInfoRet", {info = self._killInfo})
end

--GM命令获取boss当前位置
function UndefinedManager:GMGetBossPos()
	local result = "liveNum:" .. table.size(self._liveBoss) .." "
	for _, monster in pairs(self._liveBoss) do
		local pos = monster:getPosition()
		result = result .. monster:getName() ..":(" .. pos.x .. "," .. pos.y .. ")"
	end
	if table.size(self._liveBoss) == 0 then
		result = result .. "deathTime:"
		for i = 1, #self._bossDeathTime do
			result = result .. time.tostring(self._bossDeathTime[i]) .. " "
		end
	end
	return result
end

function UndefinedManager:sendErrMsg2Client(errId, paramCount, params)
	local ret = {}
	ret.eventId = EVENT_UNDEFINED_SETS
	ret.eCode = errId
	ret.mesId = UndefinedServlet.getInstance():getCurEventID()
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function UndefinedManager.getInstance()
	return UndefinedManager()
end

g_UndefinedMgr = UndefinedManager.getInstance()