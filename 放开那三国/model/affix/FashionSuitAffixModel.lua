-- FileName: FashionSuitAffixModel.lua
-- Author: lichenyang
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("FashionSuitAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid()
	require "script/ui/fashion/fashionsuit/FashionSuitData"
	local affix = FashionSuitData.getHaveActivateSuitAttr() or {}
	return affix
end
