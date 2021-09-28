--LuaFactionDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaFactionDAO.lua
 --* Author:  seezon
 --* Modified: 2016年4月11日
 --* Purpose: 帮会数据池
 -------------------------------------------------------------------*/
--]]

--------------------------------------------------------------------------------
LuaFactionDAO = class(nil, Singleton)

function LuaFactionDAO:__init()
	self._facData = {}

	local facDBs = require "data.FactionLvl"
	for _, record in pairs(facDBs or table.empty) do
		table.insert(self._facData, record)
	end
end

--获取帮会最大人数
function LuaFactionDAO:getfacMaxMemNum(level)
	for _,data in pairs(self._facData) do
		if tonumber(data.FacLevel) == level then
			return tonumber(data.FACTION_MEMBER_COUNT)
		end
	end
	return 10000
end

function LuaFactionDAO:getUpNeedXp(level)
	for _,data in pairs(self._facData) do
		if tonumber(data.FacLevel) == level then
			return tonumber(data.upNeedXp)
		end
	end
	return 10000
end

function LuaFactionDAO:getMaxLevel()
	local maxLevel = 1
	for _,data in pairs(self._facData) do
		if tonumber(data.FacLevel) > maxLevel then
			maxLevel = tonumber(data.FacLevel)
		end
	end
	return maxLevel
end

function LuaFactionDAO:getBannerBuffId(level)
	for _,data in pairs(self._facData) do
		if tonumber(data.FacLevel) == level then
			return tonumber(data.bannerBuffid)
		end
	end
	return 17
end

function LuaFactionDAO.getInstance()
	return LuaFactionDAO()
end

g_luaFactionDAO = LuaFactionDAO.getInstance()