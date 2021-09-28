-- Filename: GodWeaponBookAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 神兵

module("GodWeaponBookAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/godweapon/GodWeaponData"
	--TODO by hid
	local godWeaponAffix = GodWeaponData.getWeaponBookAtrr() or {}
	return godWeaponAffix
end