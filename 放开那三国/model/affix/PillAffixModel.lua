-- Filename: PillAffixModel.lua.
-- Author: DJN
-- Date: 2015-06-02
-- Purpose: 丹药

module("PillAffixModel", package.seeall)

--[[
    @parm: p_hid 武将id
    @ret:{
        affixId => affixValue,
        ...
    }
--]]
function getAffixByHid( p_hid )
    require "script/ui/pill/PillData"
    local affixs = PillData.getAffixByHid(p_hid)
    return affixs
end