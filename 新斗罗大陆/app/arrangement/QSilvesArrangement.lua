--
-- Kumo.Wang
-- Silves挑战
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSilvesArrangement = class("QSilvesArrangement", QBaseArrangement)

local QReplayUtil = import("..utils.QReplayUtil")

function QSilvesArrangement:ctor(options)
end

function QSilvesArrangement:makeReplayBuffer(index, battleVerifyKey, callback, failCallback)
    if q.isEmpty(remote.silvesArena.fightInfo) or q.isEmpty(remote.silvesArena.fightInfo.attackFightInfo) or q.isEmpty(remote.silvesArena.fightInfo.defenseFightInfo) then
        if failCallback then
            failCallback()
        end
        return
    end 
    
    local battleFormation = {}
    local myInfo = {}
    for _, attackFight in ipairs(remote.silvesArena.fightInfo.attackFightInfo) do
        if attackFight.silvesArenaFightPos == index then
            battleFormation = remote.silvesArena:encodeBattleFormation(attackFight)
            myInfo = attackFight
            break
        end
    end
    local rivalInfo = {}
    for _, defenseFight in ipairs(remote.silvesArena.fightInfo.defenseFightInfo) do
        if defenseFight.silvesArenaFightPos == index then
            rivalInfo = defenseFight
            break
        end
    end
    
    local config = db:getDungeonConfigByID("arena")
    config.isPVPMode = true
    config.isSilvesArena = true
    config.isQuick = true

    config.team1Name = myInfo.name
    config.team1Icon = myInfo.avatar
    if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
        config.team1Icon = db:getDefaultAvatarIcon()
    end
    config.myInfo = myInfo
    config.heroRecords = myInfo.collectedHero or {}

    config.team2Name = rivalInfo.name
    config.team2Icon = rivalInfo.avatar
    if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
        config.team2Icon = db:getDefaultAvatarIcon()
    end
    config.pvp_archaeology = rivalInfo.apiArchaeologyInfoResponse
    config.rivalId = rivalInfo.userId
    config.rivalsInfo = rivalInfo
    config.pvpRivalHeroRecords = rivalInfo.collectedHero or {}

    config.battleDT = 1 / 30
    config.battleFormation = battleFormation
    config.verifyKey = battleVerifyKey
    config.teamName = remote.teamManager.SILVES_ARENA_TEAM
    
    self:addOtherPropForArena(myInfo)
    self:addOtherPropForArena(rivalInfo)
    self:_initSilvesDungeonConfig(config, myInfo, rivalInfo)
    
    local fightReportData, record = QReplayUtil:createSilvesReplayBuffer(config)
    -- writeToBinaryFile("last.reppb", fightReportData)

    if callback then
        callback(fightReportData)
    end
end

return QSilvesArrangement
