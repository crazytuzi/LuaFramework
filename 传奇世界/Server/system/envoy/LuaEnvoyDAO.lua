--LuaEnvoyDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaEnvoyDAO.lua
 --* Author:  seezon
 --* Modified: 2014年12月3日
 --* Purpose: 重装使者怪物刷新数据池
 -------------------------------------------------------------------*/
--]]

--------------------------------------------------------------------------------
LuaEnvoyDAO = class(nil, Singleton)

function LuaEnvoyDAO:__init()
	self._envoyFresh = {}

	local envoyDBs = require "data.EnvoyDB"
	for _, record in pairs(envoyDBs or table.empty) do
		self._envoyFresh[tonumber(record.q_floor)] = record
	end
end

--根据任务地图层数取数据
function LuaEnvoyDAO:getProto(mapFloor)
	return self._envoyFresh[mapFloor]
end

function LuaEnvoyDAO.getInstance()
	return LuaEnvoyDAO()
end

