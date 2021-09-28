-- Filename: AthenaAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 主角星魂

require "script/model/hero/HeroModel"

module("AthenaAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/athena/AthenaData"
	local affix = AthenaData.getAtrrInfoForFightForce()[tonumber(p_hid)] or {}
	return affix
end
