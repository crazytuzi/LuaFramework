-- Filename: AllStarAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 名将属性

require "script/model/hero/HeroModel"

module("AllStarAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	local heroInfo = HeroModel.getHeroByHid(p_hid)
	require "script/ui/star/StarUtil"
	local affix = StarUtil.getStarAddNumBy(heroInfo.htid)
	return affix
end
