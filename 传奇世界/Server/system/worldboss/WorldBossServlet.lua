--WorldBossServlet.lua
--/*-----------------------------------------------------------------
--* Module:  WorldBossServlet.lua
--* Author:  HE Ningxu
--* Modified: 2014Äê6ÔÂ24ÈÕ
--* Purpose: Implementation of the class WorldBossServlet
-------------------------------------------------------------------*/
require ("system.worldboss.WorldBossConstant")

WorldBossServlet = class(EventSetDoer, Singleton)

function WorldBossServlet:__init()
	self._doer = {
			[WORLDBOSS_CS_REQ]		    =	WorldBossServlet.Req,
			[WORLDBOSS_CS_GETOWNERID]   =	WorldBossServlet.getOwnerID,
		}			
end

function WorldBossServlet:Req(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("WorldBossReqProtocol" , pbc_string)
	if not req then
		print('WorldBossServlet:Req '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	
	local bossNum = g_WorldBossMgr:getWorldBossCount()
	local bossLiveInfo = g_WorldBossMgr:getWorldBossLiveInfo()
	local retData = {}
	retData.bossNum = bossNum
	retData.bossInfo = {}
	for i = 1, bossNum do
		if bossLiveInfo[i] then
			local bossInfoTmp = {}
			bossInfoTmp.bossID = bossLiveInfo[i].monID or 0
			bossInfoTmp.bossLive = bossLiveInfo[i].live or 0
			bossInfoTmp.nextLiveTime = bossLiveInfo[i].nextFresh or ""
			local activeTick = bossLiveInfo[i].activeTick or 0
			local nextDay = 0
			if tonumber(os.time()) < activeTick then
				nextDay = 1
			end
			bossInfoTmp.isTomorrow = nextDay
			table.insert(retData.bossInfo,bossInfoTmp)
		end
	end
	fireProtoMessage(UID,WORLDBOSS_SC_RET,"WorldBossReqRetProtocol",retData)
end

function WorldBossServlet:getOwnerID(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("WorldBossGetOwnerProtocol" , pbc_string)
	if not req then
		print('WorldBossServlet:getOwnerID '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	local monsterDID = req.bossID
	local isWorldBoss,ownerSID,ownerName = g_WorldBossMgr:getWorldBossOwner(monsterDID)

	if isWorldBoss then
		local ret = {}
		ret.ownerSID = ownerSID
		ret.ownerName = ownerName
		fireProtoMessageBySid(roleSID, WORLDBOSS_SC_OWNERID, "WorldBossOwnerRetProtocol", ret)
	end
end

function WorldBossServlet:onDoerActive()
	g_normalLimitMgr:setActiveState(ACTIVITY_NORMAL_ID.WORLD_BOSS, true)
end

function WorldBossServlet:onDoerClose()
	g_normalLimitMgr:setActiveState(ACTIVITY_NORMAL_ID.WORLD_BOSS, false)
end

function WorldBossServlet.getInstance()
	return WorldBossServlet()
end

g_eventMgr:addEventListener(WorldBossServlet.getInstance())
