-- Filename: DestinyAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 天命属性

module("DestinyAffixModel", package.seeall)

require "script/ui/destiny/DestinyData"
--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	local affix = DestinyData.getDestinyAffix(p_hid)
	return affix
end