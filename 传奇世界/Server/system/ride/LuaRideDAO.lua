--LuaRideDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaRideDAO.lua
 --* Author:  seezon
 --* Modified: 2014年6月16日
 --* Purpose: 坐骑数据池
 -------------------------------------------------------------------*/
--]]
require "data.RideDB"

--------------------------------------------------------------------------------
LuaRideDAO = class(nil, Singleton)

function LuaRideDAO:__init()
	self._staticRides = {}

	--加载所有的坐骑原型
	local rideDBs = require "data.RideDB"
	for _, record in pairs(rideDBs or table.empty) do
		self._staticRides[record.q_ID] = record
	end
end


--根据坐骑ID取数据
function LuaRideDAO:getPrototype(sID)
	if sID then
	    return self._staticRides[sID]
	end
end

function LuaRideDAO.getInstance()
	return LuaRideDAO()
end