--FactionAreaServlet.lua
--/*-----------------------------------------------------------------
--* Module:  FactionAreaServlet.lua
--* Author:  Li Yuanhao
--* Modified: 2016年3月23日
--* Purpose: Implementation of the class FactionAreaServlet
-------------------------------------------------------------------*/
FactionAreaServlet = class(EventSetDoer, Singleton)

function FactionAreaServlet:__init()
	self._doer = {
			--行会篝火
		[FACTIONAREA_CS_OPEN_FIRE]			= 		FactionAreaServlet.openFactionFire,
		[FACTIONAREA_CS_ADD_WOOD]			=		FactionAreaServlet.addWood,
		[FACTIONAREA_CS_GET_WOOD_NUM]		= 		FactionAreaServlet.getWoodNum,
		[FACTIONAREA_CS_FIRE_STATUS]		= 		FactionAreaServlet.getFireStatus,
	}
end

-- -- 点击NPC
-- function FactionAreaServlet.clickNPC(roleID, npcId)
-- 	local player = g_entityMgr:getPlayer(roleID)
-- end

--打开行会篝火
function FactionAreaServlet:openFactionFire(event)
	local params = event:getParams()
	local pbc_string ,roleSID= params[1],params[2]
	local data = protobuf.decode("FactionAreaOpenFireProtocol" , pbc_string)
	local factionID = data.factionID
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		g_factionAreaManager:openFactionFire(player:getID(),factionID)
	end
end

function FactionAreaServlet:addWood(event)
	local params = event:getParams()
	local pbc_string ,roleSID= params[1],params[2]
	local data = protobuf.decode("FactionAreaAddWoodProtocol" , pbc_string)
	local factionID = data.factionID
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		g_factionAreaManager:addWood(player:getID(),factionID)
	end
end

function FactionAreaServlet:getWoodNum(event)
	local params = event:getParams()
	local pbc_string ,roleSID= params[1],params[2]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		return
	end
	local roleID = player:getID()
	local faction = g_factionMgr:getFaction(player:getFactionID())
	local mem = faction:getMember(roleSID)
	if not mem then
		return
	end
	
	local count = mem:getFireNum()
	local isLeader = player:getSerialID() == faction:getLeaderID() or player:getSerialID() == faction:getAssLeaderID() and true or false
	local retData = {count = count,isTime = g_factionAreaManager:isFireTime(),isLeader = isLeader}
	fireProtoMessage(roleID,FACTIONAREA_SC_GET_WOOD_NUM,"FactionAreaGetWoodNumRetProtocol",retData)
end

function FactionAreaServlet:getFireStatus(event)
	local params = event:getParams()
	local pbc_string ,roleSID= params[1],params[2]
	local data = protobuf.decode("FactionAreaFireStatusPtotocol" , pbc_string)
	local factionID = data.factionID
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
		g_factionAreaManager:sendFireStatus(player:getID(),factionID)
	end
end

function FactionAreaServlet:sendErrMsg2Client(roleID, eCode, paramCnt, params)
	fireProtoSysMessage(self:getCurEventID(), roleID, EVENT_FACTIONAREA_SETS, eCode, paramCnt, params)
end

function FactionAreaServlet:send( ... )
	-- body
end


function FactionAreaServlet.getInstance()
	return FactionAreaServlet()
end


g_factionAreaServlet = FactionAreaServlet.getInstance()
g_eventMgr:addEventListener(g_factionAreaServlet)