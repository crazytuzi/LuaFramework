--RideEventParse.lua
--/*-----------------------------------------------------------------
 --* Module:  RideEventParse.lua
 --* Author:  seezon
 --* Modified: 2014年6月16日
 --* Purpose: Implementation of the class RideEventParse
 -------------------------------------------------------------------*/

 --上下坐骑
CSRIDECHANGSTATE = {}
--RIDE_CS_CHANG_STATE后端读消息
CSRIDECHANGSTATE.readFun = function(pbc_string)
	local data = protobuf.decode("RideChangeStateProtocol" , pbc_string)
	return data
end

--服务器响应上下坐骑
CSRIDECHANGSTATERET = {}
--RIDE_CS_CHANG_STATE_RET后端写消息
CSRIDECHANGSTATERET.writeFun = function(roleID,opType)
	local retData = {opType = opType}
	fireProtoMessage(roleID,RIDE_CS_CHANG_STATE_RET,"RideChangeStateRetProtocol",retData)
end

--刷新坐骑
SCRIDEFRESHRIDE = {}
--RIDE_SC_FRESH_RIDE后端写消息
SCRIDEFRESHRIDE.writeFun = function(roleID,rideIds, isActive , rideState,newRideID)
	local idT = {}
	for _,id in ipairs(rideIds) do
		table.insert(idT,id)
	end
	local retData = {
			isActive = isActive,
			num = num,
			rideIDs = idT,
			state = rideState,
			newRideID = newRideID,

}
	fireProtoMessage(roleID,RIDE_SC_FRESH_RIDE,"RideFreshRideRetProtocol",retData)
end