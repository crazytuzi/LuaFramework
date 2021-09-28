--TreasureManger.lua
--/*-----------------------------------------------------------------
 --* Module:  TreasureManger.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月11日
 -------------------------------------------------------------------*/

require ("system.treasure.TreasureServlet")
require ("system.treasure.TreasureRoleInfo")
require ("system.treasure.TreasureConstant")

TreasureManger = class(nil, Singleton, Timer)

--全局对象定义
g_TreasureServlet = TreasureServlet.getInstance()

function TreasureManger:__init()
	self._roleTreasureRoleInfoBySID = {}
	self._rolesInTreasure = {}

	self._openFlag = false
	self._startTime = 0
	self._needLvl = g_normalLimitMgr:getJoinLevel(ACTIVITY_NORMAL_ID.TREASURE) or 32
	self._mapInfo = {}
	self:parseMapData()
	gTimerMgr:regTimer(self, 1000, 1000)
	g_listHandler:addListener(self)
end

function TreasureManger:parseMapData()
	local records = require "data.MapDB"
	for _,v in pairs(records) do
		local tmp = {}
		local id = tonumber(v.q_map_id)
		if table.contains(TREASURE_MAP_INFO, id) then
			tmp.id = id
			tmp.min_lvl = tonumber(v.q_map_min_level)
			tmp.max_lvl = tonumber(v.q_map_max_level)
			tmp.enter_x = tonumber(v.q_map_die_x)
			tmp.enter_y = tonumber(v.q_map_die_y)
			self._mapInfo[id] = tmp
		end
		if table.size(self._mapInfo) == table.size(TREASURE_MAP_INFO) then
			break
		end
	end
end

function TreasureManger:join(roleSID, bExperience)
	print('TreasureManger:join()', roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return false
	end

	if not bExperience and not self:canJoin(player) then
		return false
	end

	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning('not find memInfo')
		return false
	end

	if not bExperience then
		local playerLvl = player:getLevel()
		for id,info in pairs(self._mapInfo) do
			if info.min_lvl <= playerLvl and playerLvl <=info.max_lvl then
				if table.contains(TREASURE_MAP_INFO, id) then
					memInfo:setTreasureMapID(id)
					break
				end
			end
		end
	else
		memInfo:setTreasureMapID(TREASURE_MAP_INFO[1])
	end

	if self:joinTreasureMap(player) then
		local nowDate = tonumber(time.toedition("day"))
		if not bExperience and nowDate ~= memInfo:getLastFreshTime() then
			memInfo:freshDay()
		end

		local now = os.time()
		memInfo:setStartTime(now)
		if bExperience then
			memInfo:setEndTime(now + TREASURE_EXPERIENCE_TIME)
			memInfo:setExperience(true)
		else
			memInfo:setEndTime(now + TREASURE_TIME - memInfo:getUsedTime())
			g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.BAODI, 1)
		end
		-- memInfo:setJoinCount(memInfo:getJoinCount() + 1)
		-- memInfo:cast2db()
		self._rolesInTreasure[roleSID] = true
		fireProtoMessage(player:getID(), TREASURE_SC_JOIN_RET, "TreasureJoinRetProtocol", {})
	else
		memInfo:setTreasureMapID(0)
		warning('join treasure map failed')
		return false
	end
	return true
end

function TreasureManger:joinTreasureMap(player)
	if not player then
		warning('not find player')
		return false
	end

	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find memInfo')
		return
	end

	local mapID = memInfo:getTreasureMapID()
	local curMapID = player:getMapID()
	if mapID == curMapID then
		return false
	end

	if g_sceneMgr:posValidate(mapID, self._mapInfo[mapID].enter_x, self._mapInfo[mapID].enter_y) then
		local pos = player:getPosition()
		player:setLastMapID(curMapID)
		player:setLastPosX(pos.x)
		player:setLastPosY(pos.y)
		print('enter mapID:', mapID, 'x:', self._mapInfo[mapID].enter_x, 'y:',self._mapInfo[mapID].enter_y)
		g_sceneMgr:enterPublicScene(player:getID(), mapID, self._mapInfo[mapID].enter_x, self._mapInfo[mapID].enter_y)
		return true
	end
	return false
end

function TreasureManger:out(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return
	end

	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning('not find memInfo')
		return
	end

	local roleID = player:getID()
	if self:quitTreasureMap(roleSID) then
		fireProtoMessage(roleID, TREASURE_SC_OUT_RET, "TreasureOutRetProtocol", {})
	end
end

function TreasureManger:quitTreasureMap(roleSID)
	print('TreasureManger:quitTreasureMap()')
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return false
	end

	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning('not find memInfo')
		return false
	end

	local mapID = player:getMapID()
	if not table.contains(TREASURE_MAP_INFO, mapID) then
		print('not in TreasureManger map',mapID)
		return false
	end

	local sing = player:getSing()
	if sing and sing:isSinging() then
		sing:stopSinging()
	end

	local lastMapID = player:getLastMapID()
	local x = player:getLastPosX()
	local y = player:getLastPosY()
	local roleID = player:getID()

	if not table.contains(TREASURE_MAP_INFO, lastMapID) and g_sceneMgr:posValidate(lastMapID, x, y) then
		print('enter enterPublicScene')	
		g_sceneMgr:enterPublicScene(roleID, lastMapID, x, y)
	else
		g_sceneMgr:enterPublicScene(roleID, 1100, 17, 85)
	end

	if not memInfo:getExperience() then
		memInfo:setUsedTime(os.time() - memInfo:getStartTime() + memInfo:getUsedTime())
		memInfo:cast2db()
	else
		memInfo:setExperience(false)
	end
	memInfo:setTreasureMapID(0)
	self._rolesInTreasure[roleSID] = nil

	return true
end

function TreasureManger:remainTime(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		warning('not find player')
		return
	end

	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		warning('not find memInfo')
		return
	end

	local time = memInfo:getEndTime() - os.time()
	--print('remainTime:', time)
	fireProtoMessage(player:getID(), TREASURE_SC_REMAIN_TIME_RET, "TreasureReaminTimeRetProtocol", {remainTime = time})
end

function TreasureManger:clearAllRoles()
	for roleSID,_ in pairs(self._rolesInTreasure) do
	 	self:quitTreasureMap(roleSID)
	 end
end

function TreasureManger:update()
	if self._startTime == 0 then
		return
	end

	--tickout all timeout player
	local now = os.time()
	for roleSID,_ in pairs(self._rolesInTreasure) do
	 	local memInfo = self:getPlayerInfoBySID(roleSID)
	 	if not memInfo then
	 		warning('not find memInfo')
	 	else
	 		if memInfo:getEndTime() < now then
	 			self:quitTreasureMap(roleSID)
	 		end
	 	end
	 end 
end

function TreasureManger:canJoin(player)
	if not player then
		warning('not find player')
		return false
	end

	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find memInfo')
		return false
	end

	if not self._openFlag then
		g_TreasureServlet:sendErrMsg2Client(player:getID(), TREASURE_NOT_START, 0)
		return false
	end

	if player:getScene() and player:getScene():switchLimitOut() then
		g_TreasureServlet:sendErrMsg2Client(player:getID(), TREASURE_NOT_TRAN, 0)
		return false
	end

	if g_copyMgr:inCopyTeam(player:getID()) then
		g_TreasureServlet:sendErrMsg2Client(player:getID(), TREASURE_IN_COPYTEAM, 0)
		return false
	end

	if player:getLevel() < self._needLvl then
		g_TreasureServlet:sendErrMsg2Client(player:getID(), TREASURE_NOT_ENOUGH_LEVEL, 0)
		return false
	end

	if memInfo:getUsedTime() >= TREASURE_TIME then
		g_TreasureServlet:sendErrMsg2Client(player:getID(), TREASURE_NOT_ENOUGH_TIME, 0)
		return false
	end

	if g_normalMgr:getActivenessIntegral(player:getID()) < TREASURE_NEED_ACTIVITY then
		g_TreasureServlet:sendErrMsg2Client(player:getID(), TREASURE_NOT_ENOUGH_ACTIVITY, 0)
		return false
	end

	return true
end

function TreasureManger:canJoin2(player)
	if not player then
		warning('not find player')
		return false
	end

	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find memInfo')
		return false
	end

	if not self._openFlag then
		return false
	end

	if player:getScene() and player:getScene():switchLimitOut() then
		return false
	end

	if g_copyMgr:inCopyTeam(player:getID()) then
		return false
	end

	if player:getLevel() < self._needLvl then
		return false
	end

	if memInfo:getUsedTime() >= TREASURE_TIME then
		return false
	end

	if g_normalMgr:getActivenessIntegral(player:getID()) < TREASURE_NEED_ACTIVITY then
		return false 
	end

	return true
end

--活动开启
function TreasureManger:openTreasure()
	if not self._openFlag then
		self._openFlag = true
		self._startTime = os.time()
	end
end

--活动关闭
function TreasureManger:closeTreasure()
	if self._openFlag then
		self:clearAllRoles()
		self._openFlag = false
		self._startTime = 0
	end
end

function TreasureManger:onPlayerLoaded(player)
	if not player then
		warning('not find player')
		return
	end

	local memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find memInfo')
		return
	end

	local lastFreshTime = memInfo:getLastFreshTime()
	local now = tonumber(time.toedition("day"))
	if now ~= lastFreshTime and lastFreshTime ~= 0 then
		memInfo:freshDay()
	end
end

function TreasureManger:onPlayerOffLine(player)
	print('TreasureManger:onPlayerOffLine()')
	if not player then
		warning('not find player')
		return
	end
	local roleSID = player:getSerialID()
	if self._rolesInTreasure[roleSID] then
		self:quitTreasureMap(roleSID)
		-- local memInfo = self:getPlayerInfoBySID(roleSID)
		-- if memInfo then
		-- 	memInfo:setUsedTime(os.time() - memInfo:getStartTime() + memInfo:getUsedTime())
		-- 	memInfo:cast2db()
		-- end
		-- self._rolesInTreasure[roleSID] = nil
	end
	self._roleTreasureRoleInfoBySID[roleSID]= nil
end

function TreasureManger:onPlayerInactive(player)
	print('TreasureManger:onPlayerInactive()')
	if not player then
		warning('not find player')
		return
	end

	local roleSID = player:getSerialID()
	if self._rolesInTreasure[roleSID] then
		self:quitTreasureMap(roleSID)
	end
end

function TreasureManger.loadDBData(player, cache_buf, roleSid)
	if not player then
		warning('not find player')
		return
	end

	local roleSID = player:getSerialID()

	local memInfo = g_TreasureManger:initRoleInfo(roleSID)
	if not memInfo then
		warning('not find memInfo')
		return
	end
	print('TreasureManger.loadDBData()', roleSID)
	if #cache_buf > 0 then
		print('memInfo load db data')
		memInfo:loadTreasureData(cache_buf)
	end

end

function TreasureManger:initRoleInfo(roleSID)
	print('TreasureManger:initRoleInfo()')
	local memInfo = self:getPlayerInfoBySID(roleSID)
	if not memInfo then
		memInfo = TreasureRoleInfo()
		memInfo:setRoleSID(roleSID)
		self._roleTreasureRoleInfoBySID[roleSID] = memInfo
		self._roleTreasureRoleInfoBySID[roleSID]:print()
	end
	return memInfo
end

function TreasureManger:experienceTreasure(roleSID,mapID, xPos,yPos)
	print('TreasureManger:experienceTreasure', roleSID, mapID, xPos, yPos)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return false
	end

	local  memInfo = self:getPlayerInfoBySID(player:getSerialID())
	if not memInfo then
		warning('not find player memInfo')
		return false
	end
	if self:join(roleSID, true) then
		return true
	end
	return false
end

function TreasureManger:inTreasureMap(roleSID)
	print("TreasureManger:inTreasureMap()", roleSID)
	if self._rolesInTreasure[roleSID] then
		return true
	end
	return false
end

function TreasureManger:getPlayerInfoBySID(roleSID)
	return self._roleTreasureRoleInfoBySID[roleSID]
end

function TreasureManger.getInstance()
	return TreasureManger()
end

g_TreasureManger = TreasureManger.getInstance()