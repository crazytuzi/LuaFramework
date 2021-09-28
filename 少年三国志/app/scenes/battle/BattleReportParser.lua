-- BattleReportParser
local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"

local BattleReportParser = class("BattleReportParser")

function BattleReportParser.parse(battleReport)
    return BattleReportParser.new(battleReport)
end

function BattleReportParser:ctor(battleReport)
    self._battleReport = battleReport
end

function BattleReportParser:set(battleReport)
    self._battleReport = battleReport
end

function BattleReportParser:clear()
    self._battleReport = nil
end

function BattleReportParser:report()
    return self._battleReport
end

-- 获取某一方的上阵人数
function BattleReportParser:getKnightUpAmount(identity)
    
    assert(self._battleReport, "The battlereport could not be nil !!")
    
    identity = identity or 1
    
    local bout = self._battleReport.bouts[1]
    local units = identity == 1 and 
        self._battleReport.own_teams[bout.own_team+1].units or 
        self._battleReport.enemy_teams[bout.enemy_team+1].units
    
    return #units
end

-- 获取我方最后剩余人数
function BattleReportParser:getLeftKnightUpAmount(identity)
    
    assert(self._battleReport, "The battlereport could not be nil !!")
    
    identity = identity or 1
    
    local units = identity == 1 and 
        (rawget(self._battleReport.result, "left_own_teams") or {}).units or 
        (rawget(self._battleReport.result, "left_enemy_teams") or {}).units

    return units and #units or 0
end

-- 获取某一方武将的总血量（初始血量），这里不考虑本地计算的初始血量的情况
function BattleReportParser:getKnightTotalHP(identity)
    
    assert(self._battleReport, "The battlereport could not be nil !!")
    
    identity = identity or 1
    
    local totalHP = 0

    for i=1, #self._battleReport.bouts do
        local bout = self._battleReport.bouts[i]
        if identity == 1 then
            local ownTeamID = bout.own_team
            for i=1, #self._battleReport.own_teams[ownTeamID+1].units do
                local unit = self._battleReport.own_teams[ownTeamID+1].units[i]
                totalHP = totalHP + unit.hp
            end
        elseif identity == 2 then
            local enemyTeamID = bout.enemy_team
            for i=1, #self._battleReport.enemy_teams[enemyTeamID+1].units do
                local unit = self._battleReport.enemy_teams[enemyTeamID+1].units[i]
                totalHP = totalHP + unit.hp
            end
        end
        break
    end

    return totalHP
end

-- 获取战斗中某一方的当前总血量
function BattleReportParser:getLeftKnightHP(identity)
    
    assert(self._battleReport, "The battlereport could not be nil !!")
    
    identity = identity or 1
    
    local currentHP = 0
    
    if identity == 1 then
        local units = (rawget(self._battleReport.result, "left_own_teams") or {units={}}).units
        for i=1, #units do
            currentHP = currentHP + units[i].hp
        end
    elseif identity == 2 then
        local units = (rawget(self._battleReport.result, "left_enemy_teams") or {units={}}).units
        for i=1, #units do
            currentHP = currentHP + units[i].hp
        end
    end
    
    return currentHP
end

-- 获取总共战斗回合数
function BattleReportParser:getRound()
    assert(self._battleReport, "The battlereport could not be nil !!")
    
    local roundNum = 0
    for i, v in ipairs(self._battleReport.bouts[1].rounds) do
        if v.type == BattleFieldConst.ROUND_NORMAL then
            roundNum = roundNum + 1
        end
    end

    return roundNum    
end

return BattleReportParser
