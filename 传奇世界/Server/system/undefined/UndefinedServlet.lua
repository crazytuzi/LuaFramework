--UndefinedServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  UndefinedServlet.lua
 --* Author:  Andy
 --* Modified: 2016年02月06日
 --* Purpose: Implementation of the class UndefinedServlet
 -------------------------------------------------------------------*/

UndefinedServlet = class(EventSetDoer, Singleton)

function UndefinedServlet:__init()
	self._doer = {
		[UNDEFINED_CS_JOIN] 			= UndefinedServlet.doJoin,
		[UNDEFINED_CS_GET_KILL_INFO]	= UndefinedServlet.getKillInfo,
	}
end

--玩家请求参加活动
function UndefinedServlet:doJoin(event)
    local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "UndefinedJoin")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if g_UndefinedMgr:getOpenSystem() and player then
		g_UndefinedMgr:joinActivity(dbid)
		local x, y = 0, 0
		local random = math.random(1, #UNDEFINED_POS)
		local position = UNDEFINED_POS[random]
		if position then
			x = position[1]
			y = position[2]
		end
		if g_sceneMgr:posValidate(UNDEFINED_MAP_ID, x, y) then
			g_tlogMgr:TlogHDFlow(player, 3)
			local position = player:getPosition()
			player:setLastMapID(UNDEFINED_MAP_ID)
			player:setLastPosX(position.x)
			player:setLastPosY(position.y)
			g_sceneMgr:enterPublicScene(player:getID(), UNDEFINED_MAP_ID, x, y, 1)
		end
	end
end

--获取怪物击杀时间
function UndefinedServlet:getKillInfo(event)
    local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "UndefinedKillInfo")
	g_UndefinedMgr:getKillInfo(dbid)
end

function UndefinedServlet:onDoerClose()
	local joinUser = g_UndefinedMgr:getJoinUser()
	for roleSID, _ in pairs(joinUser) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if player and player:getMapID() == UNDEFINED_MAP_ID then
			local roleID = player:getID()
			-- local mapID = player:getLastMapID()
			-- local x = player:getLastPosX()
			-- local y = player:getLastPosY()
			-- if g_sceneMgr:posValidate(mapID, x, y) and mapID ~= UNDEFINED_MAP_ID then
			-- 	g_sceneMgr:enterPublicScene(roleID, mapID, x, y)
			-- else
			-- 	g_sceneMgr:enterPublicScene(roleID, 2100, 103, 97)
			-- end

			--系统关闭直接传送到中州
			g_sceneMgr:enterPublicScene(roleID, 2100, 103, 97)
		end
	end
	g_UndefinedMgr:setOpenSystem(false)
end

function UndefinedServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! UndefinedServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function UndefinedServlet:onDoerActive()
	g_UndefinedMgr:setOpenSystem(true)
end

function UndefinedServlet.getInstance()
	return UndefinedServlet()
end

g_eventMgr:addEventListener(UndefinedServlet.getInstance())