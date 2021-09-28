-- Filename: WarfAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 阵法属性

module("WarfAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/warcraft/WarcraftData"
	local warcraftAffix = WarcraftData.getAffixes(tonumber(p_hid))or {}
	return warcraftAffix
end