-- Filename: FightSoulAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 战魂属性

require "script/model/hero/HeroModel"

module("FightSoulAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	local fightSoulInfo = HeroModel.getHeroFightSoulAffix(p_hid)
	local affix = {}
	for k,v in pairs(fightSoulInfo) do
		if affix[tonumber(k)] == nil then
			affix[tonumber(k)] = tonumber(v)
		else
			affix[tonumber(k)] = tonumber(v) + affix[tonumber(k)]
		end
	end
	return affix
end