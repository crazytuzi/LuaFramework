-- Filename: GuildIconData.lua
-- Author: bzx
-- Date: 2015-1-14
-- Purpose: 军团军旗数据

module("GuildIconData", package.seeall)
require "db/DB_Legion_icon"

--[[
	@desc: 		得到军旗总数
	@return:	number
--]]
function getIconCount( ... )
	return table.count(DB_Legion_icon.Legion_icon)
end
