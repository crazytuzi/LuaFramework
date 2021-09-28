-- Filename: LoyaltyAffixModel.lua.
-- Author: licheyang
-- Date: 2015-07-28
-- Purpose: 聚义厅属性

require "script/model/hero/HeroModel"

module("LoyaltyAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/star/loyalty/LoyaltyData"
	local affix = LoyaltyData.getSumAttr()	
	return affix
end