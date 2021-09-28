
-- FileName: FightDBUtil.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 数据查询的公共方法

module("FightDBUtil", package.seeall)

--[[
    @des: 从armyId得到teamid
    @parm:pIndex 部队索引
    @ret: teamId
--]]
function getTeamIdByArmyId( pArmyIndex )
    local retId = nil
    require "db/DB_Army"
    local armyInfo = DB_Army.getDataById(pArmyIndex)
    if armyInfo.monster_group_npc then
        retId = armyInfo.monster_group_npc
    else
        retId = armyInfo.monster_group
    end
end