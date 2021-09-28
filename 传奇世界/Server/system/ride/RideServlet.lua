--RideServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  RideServlet.lua
 --* Author:  seezon
 --* Modified: 2014年6月9日
 --* Purpose: 坐骑消息接口
 -------------------------------------------------------------------*/

RideServlet = class(EventSetDoer, Singleton)

function RideServlet:__init()
	self._doer = {
		[RIDE_CS_CHANG_STATE]	=		RideServlet.doChangState,
}
end
function RideServlet:onDoerActive( )

end
function RideServlet:onDoerClose( )
	for k,v in pairs(g_rideMgr._roleRideInfos) do
		local player = g_entityMgr:getPlayer(k)
		if player then 
			v:setRideState(false)
			player:setRideID(0)
		end
	end
end

--上下坐骑
function RideServlet:doChangState(event)
    local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local data = CSRIDECHANGSTATE.readFun(pbc_string)
    local opType = data.opType
	local rideID = data.rideID
	
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end
	local roleID = player:getID()
    local memInfo = g_rideMgr:getRoleRideInfo(roleID)
    if not memInfo then
	return
    end

    --如果还没有激活
    if table.size(memInfo:getRide()) <= 0 then
		return
    end
    --战斗状态时不能上马
    if opType == RIDEOPTYPE.onRide then
		if g_entityMgr:isInBattleStatus(player) then
			g_rideServlet:sendErrMsg2Client(roleID, RIDE_ERR_PK_NOT_ALLOW_RIDE, 0)
			return
		end

		--变身状态不能骑马
		local buffmgr = player:getBuffMgr()
		if buffmgr:hasChangeBuff() then
			g_rideServlet:sendErrMsg2Client(roleID, RIDE_ERR_CHANGE_NOT_ALLOW_RIDE, 0)
			return
		end
    end

    --如果状态一致
    if (opType == RIDEOPTYPE.offRide and memInfo:getRideState() == false) then
		return
    end

    local mapRecords = require "data.MapDB"
    for _, record in pairs(mapRecords) do
		if record.q_map_id == player:getMapID() then
			if opType == RIDEOPTYPE.onRide and not (record.q_map_ride == 1) then
				g_rideServlet:sendErrMsg2Client(roleID, RIDE_ERR_NOT_ALLOW_RIDE, 0)
				return
			end
		end
    end
	if player:getShowItemID() ~= 0 then 
		fireProtoSysMessage(0, roleID, EVENT_FACTION_SETS, FACTION_DART_NO_RIDE , 0, {})
    	return
    end
    local rideProto = g_LuaRideDAO:getPrototype(rideID)

	if not rideProto then
		return
	end
    local addSpeed = rideProto.q_addSpeed
	local retRideID = 0
    if opType == RIDEOPTYPE.onRide then
		if memInfo:getRideState() then
			local oldRideID = memInfo:getCurRide()
			local oldrideProto = g_LuaRideDAO:getPrototype(oldRideID)
			if oldrideProto then
				player:setMoveSpeed(player:getMoveSpeed() -  tonumber(oldrideProto.q_addSpeed))
			end
		end

		if not memInfo:changeFirst(rideID) then
			return
		end
		player:setMoveSpeed(player:getMoveSpeed() +  addSpeed)
		memInfo:setRideState(true)
		player:setRideID(rideID)
		retRideID = rideID
    elseif opType == RIDEOPTYPE.offRide then
		player:setMoveSpeed(player:getMoveSpeed() -  addSpeed)
		memInfo:setRideState(false)
		player:setRideID(0)
		retRideID = 0
    end	

    CSRIDECHANGSTATERET.writeFun(roleID,retRideID)

	SCRIDEFRESHRIDE.writeFun(roleID,memInfo:getRide(), false, memInfo:getRideState(),0)
end

--给客户端发送错误提示的接口
function RideServlet:sendErrMsg2Client(roleID, eCode, paramCnt, params)
	fireProtoSysMessage(self:getCurEventID(), roleID, EVENT_RIDE_SETS, eCode, paramCnt, params)
end

function RideServlet.getInstance()
	return RideServlet()
end

g_eventMgr:addEventListener(RideServlet.getInstance())