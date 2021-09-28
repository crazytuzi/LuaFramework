-- Filename: GodWeaponAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 神兵属性

module("GodWeaponAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/item/GodWeaponItemUtil"
	local affix = GodWeaponItemUtil.getGodWeaponFightScore(tonumber(p_hid)) or {}
	return affix
end