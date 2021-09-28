--FactionAreaManager.lua
--/*-----------------------------------------------------------------
--* Module:  FactionAreaManager.lua
--* Author:  Li Yuanhao
--* Modified: 2016年3月23日
--* Purpose: Implementation of the class FactionAreaManager
-------------------------------------------------------------------*/
require "system.factionAreaFire.FactionAreaConstant"
require "system.factionAreaFire.FactionAreaFire"
require "system.factionAreaFire.FactionAreaServlet"

FactionAreaManager = class(nil, Singleton,Timer)

function FactionAreaManager:__init()	
	self._fireData = {}
	self._openFireFlag = false
	self._fireManager = {}
	self:loadConfig()
	self._timeStamp = {}	--保存时间戳
	self._notifyActivityStartTime = 0
	self._notifyActivityEndTime = 0
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 1000)
	print("FactionAreaManager Timer", self._timerID_)
end

function FactionAreaManager:loadConfig(  )
	local buffRecord = require "data.BuffDB" 
	for _, data in pairs(buffRecord or {}) do
		if FACTION_FIRE_EXP==data.id then		
			self._fireData.upEXP = tonumber(data.upEXP) or 500
			self._fireData.upEXPPer = tonumber(data.AddWood_exp) or 50
			break
		end
	end
end

function FactionAreaManager:on( )
	self._openFireFlag = true
end

function FactionAreaManager:off( )
	self._openFireFlag = false
end

--判断是否到了篝火活动开启时间
function FactionAreaManager:isFireTime()
	if self._openFireFlag then 
		return true 
	end
	
	return false
end

--十秒的BUFF
function FactionAreaManager:update()
	--[[
	self._count = self._count + 1 
	self:updateFire()
	if self._count == 1000 then 
		self._count = 0
	end
	]]
	local now = os.time()

	for factionID,fire in pairs(self._fireManager) do
		fire:updateFire()

		if fire:getFireState() == FationFireState.fireEnd then
			self._fireManager[factionID] = nil
			self._timeStamp[factionID] = time.toedition("day")
			updateCommonData(COMMON_DATA_ID_FACAREA_FIRE,self._timeStamp)

			--把行会入侵玩家的玩家T出去
			--print('closeFire ')
			g_factionInvadeMgr:clearAllInvadeRole(factionID)
		end
	end

	if not isSameDay(self._notifyActivityStartTime, now) and self:isFireTime() then
		self._notifyActivityStartTime = now
		local factions = g_factionMgr:getAllFactions()
		for factionID, _ in pairs(factions) do
			self:sendAllMemberStatus(factionID)
		end
	end

	if not isSameDay(self._notifyActivityEndTime, now) and isSameDay(self._notifyActivityStartTime, now) and not self:isFireTime() then
		self._notifyActivityEndTime = now
		local factions = g_factionMgr:getAllFactions()
		for factionID, _ in pairs(factions) do
			self:sendAllMemberStatus(factionID)
		end
	end
end

function FactionAreaManager:updateFire( )
	--[[
	for factionID,fire in pairs(self._fireManager) do
		fire._time = fire._time - 1
		if fire:getStarTime() < os.time() - FACTION_FIRE_DURATION - FACTION_FIRE_NOTIFY_TIME then 
			fire:closeFire()
			self._fireManager[factionID] = nil
			self._timeStamp[factionID] = time.toedition("day")
			self:sendAllMemberStatus(factionID)
			updateCommonData(COMMON_DATA_ID_FACAREA_FIRE,self._timeStamp)

			--把行会入侵玩家的玩家T出去
			--print('closeFire ')
			g_factionInvadeMgr:clearAllInvadeRole(factionID)
			return 
		end

		if fire:getStarTime() < os.time() - FACTION_FIRE_NOTIFY_TIME and math.mod(self._count, FACTION_FIRE_SPACE_TIME) == 0 then
			fire:freshExp()
		end
	end	
	]]

	
end

function FactionAreaManager:enterFactionArea(roleSID,x,y)
	print('FactionAreaManager:enterFactionArea')
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local fire = self._fireManager[player:getFactionID()]
	if fire then 
		fire:addBuffByFire(player)
	end
end

function FactionAreaManager:outFactionArea( roleSID )
	print('FactionAreaManager:outFactionArea')
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local fire = self._fireManager[player:getFactionID()]
	if fire then 
		fire:delBuffByFire(player)
	end
end

function FactionAreaManager:getCurrentMapPlayer(factionID)
	local scene = g_sceneMgr:getFacAreaScene(factionID)
	if scene then 
		local curScenePlayer = scene:getEntities(0, 19, 38, 500, eClsTypePlayer, 0) or {}
		return curScenePlayer
	end
end

function FactionAreaManager:sendFireStatus(roleID,factionID)
	-- local fire = g_factionAreaManager._fireManager[factionID]
	-- local status = fire and true or false
	-- local addexp =  fire and fire._AddEXP or 0
	-- local totalWood =  fire and fire._sumWoodCount or 0
	-- local times 	= fire and fire._time or 0
	-- local isAlready = times ~= 0 and (times - FACTION_FIRE_DURATION) > 0 and true or false 
	-- local state = 0 --0 活动未开启 1 等待会长开启 2 预开启 3 已开启 4 活动结束
	-- if self:isFireTime() then 
	-- 	if times == 0 then 
	-- 		state = 1
	-- 	else
	-- 		state = isAlready and 2 or 3
	-- 	end
	-- 	if self._timeStamp[factionID] == time.toedition("day") then 
	-- 		state = 4
	-- 	end
	-- else
	-- 	state = 0
	-- end
	-- if state == 2 then 
	-- 	times = times - FACTION_FIRE_DURATION
	-- end
	-- local retData = {
	-- 			status = status,
	-- 			addExp = addexp,
	-- 			totalWood = totalWood,
	-- 			time = times,
	-- 			state = state,
	-- }

	-- fireProtoMessage(roleID,FACTIONAREA_SC_FIRE_STATUS,"FactionAreaFireStatusRetProcotol",retData)

	local retData = {
			status = false,
			addExp = 0,
			totalWood = 0,
			time = 0,
			state = 0,
		}

	local fire = g_factionAreaManager._fireManager[factionID]
	if fire then
		retData.status = true
		retData.addExp = fire._AddEXP
		retData.totalWood = fire._sumWoodCount
		if fire:getFireState() == FationFireState.prepareStart then
			retData.time = fire:getPrepareStartLeftTime()
		else
			retData.time = fire:getLeftTime()
		end
	end
	retData.state = self:getFireState(factionID)

	fireProtoMessage(roleID,FACTIONAREA_SC_FIRE_STATUS,"FactionAreaFireStatusRetProcotol",retData)
end

function FactionAreaManager:sendAllMemberStatus(factionID )
	local curScenePlayer = self:getCurrentMapPlayer(factionID)
	for i=1, #curScenePlayer do
		local roleID = curScenePlayer[i]
		local player = g_entityMgr:getPlayer(roleID)
		self:sendFireStatus(roleID,factionID)
	end
end

function FactionAreaManager:loadAreaStamp(data)
	self._timeStamp = unserialize(data)
	-- body
end

function FactionAreaManager:openFactionFire(roleID,factionID)
	-- if self._openFireFlag == false then 
	-- 	return false 
	-- end
	if not self:isFireTime() then 
		--g_factionAreaServlet:sendErrMsg2Client(roleID,FACTIONAREA_FIRE_CLOSE,0,{})
		return false
	end
	if self._timeStamp[factionID] == time.toedition("day") then 
		g_factionAreaServlet:sendErrMsg2Client(roleID,FACTIONAREA_HAD_OPEN,0,{})
		return false
	end
	local player = g_entityMgr:getPlayer(roleID)

	if player and g_factionMgr._enterOtherArea[player:getSerialID()] then
		return false
	end

	if factionID ~= player:getFactionID() then
		return false
	end

	local faction = g_factionMgr:getFaction(factionID)
	if faction:getLevel() < tonumber(FACTION_FIRE_NEED_LV) then
		--错误提示
		g_factionAreaServlet:sendErrMsg2Client(roleID,FACTIONAREA_LV_NOT_ENOUGTH,0,{})
		return false
	end

	if faction:getLeaderID() ~= player:getSerialID() then
		return false
	end

	if self._fireManager[factionID] then 
		return false
	end

	self._fireManager[factionID] = FactionAreaFire(factionID,os.time())
	self._fireManager[factionID]:prepareOpenFire()
	g_normalLimitMgr:sendErrMsg2Client(101,1,{faction:getName()})
	self:sendAllMemberStatus(factionID)
	return true
end

function FactionAreaManager:addWood(roleID,factionID)
	local player = g_entityMgr:getPlayer(roleID)
	local fire = self._fireManager[factionID]
	if fire and player then 
		fire:addWood(player)
	end
end

function FactionAreaManager:getFireState(factionID)
	print('FactionAreaManager:getFireStatus')
	--[[
	local fire = g_factionAreaManager._fireManager[factionID]
	local times 	= fire and fire._time or 0
	local isAlready = times ~= 0 and (times - FACTION_FIRE_DURATION) > 0 and true or false 
	local state = 0 --0 活动未开启 1 等待会长开启 2 预开启 3 已开启 4 活动结束
	if self:isFireTime() then 
		if times == 0 then 
			state = 1
		else
			state = isAlready and 2 or 3
		end
		if self._timeStamp[factionID] == time.toedition("day") then 
			state = 4
		end
	else
		state = 0
	end

	return state
	]]

	local state = 0
	local fire = g_factionAreaManager._fireManager[factionID]
	if fire then
		state = fire:getFireState()
	else
		if self:isFireTime() then
			if self._timeStamp[factionID] == time.toedition("day") then 
				state = FationFireState.fireEnd
			else
				state = FationFireState.waitLearderStart
			end
		else
			state = FationFireState.activityNotStart
		end
	end

	return state
end

function FactionAreaManager:onPlayerRelive(player)
	if player then
		local faction = g_factionMgr:getFaction(player:getFactionID())
		if faction then
			local fire = self._fireManager[player:getFactionID()]
			if fire and player:getMapID() == FACTION_AREA_MAP_ID then
				local curScenePlayer = self:getCurrentMapPlayer(player:getFactionID())
				for i=1,#curScenePlayer do
					if curScenePlayer[i] == player:getID() then
						fire:addBuffByFire(player)
					end
				end
			end
		end
	end
end

function FactionAreaManager:getAllFactionAreaInfo()
	return self._fireManager
end

-- 入侵
function FactionAreaManager:invadeFactionEnter(roleSID, factionID)
	local fire = self._fireManager[factionID]
	if fire then
		fire:invadeFactionEnter(roleSID)
	end
end


function FactionAreaManager.getInstance()
	return FactionAreaManager()
end




g_factionAreaManager = FactionAreaManager.getInstance()

