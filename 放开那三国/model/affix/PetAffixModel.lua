-- Filename: PetAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 神兵

module("PetAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	require "script/ui/pet/PetData"
	local affixs = PetData.getPetAffixValue()
	return affixs
end


