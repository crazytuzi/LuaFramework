-- Filename: DressRoomAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 时装屋属性

module("DressRoomAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/dressRoom/DressRoomCache"
	local affix = DressRoomCache.getExtenseAffixes() or {}
	return affix
end