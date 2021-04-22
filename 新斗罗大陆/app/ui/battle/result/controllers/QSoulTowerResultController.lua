-- @Author: xurui
-- @Date:   2017-04-27 11:05:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-23 17:43:06
local QBaseResultController = import(".QBaseResultController")
local QSoulTowerResultController = class("QSoulTowerResultController", QBaseResultController)
local QReplayUtil = import(".....utils.QReplayUtil")
local QSoulTowerDialogWin = import("..dialogs.QSoulTowerDialogWin")

function QSoulTowerResultController:ctor(options)
end

function QSoulTowerResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    -- 击败波数
    local battleFloor = remote.soultower:getBattleFloor()
    local passWave = remote.soultower:getBattleDungenID()
    self._teamName = dungeonConfig.teamName or remote.teamManager.SOUL_TOWER_BATTLE_TEAM
    local myInfo = {name = dungeonConfig.team1Name, avatar = dungeonConfig.team1Icon, level = remote.user.level}
    myInfo.heros = self:_constructGloryAttackHero()

    local rivalInfo = {name = dungeonConfig.team2Name, avatar = dungeonConfig.team2Icon, level = dungeonConfig.enemyLevel}
    local replayInfo = QReplayUtil:generateReplayInfo(myInfo, rivalInfo, 1)

    local teamVO = remote.teamManager:getTeamByKey(self._teamName, false)
    local heroIdList = teamVO:getAllTeam()
    local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)

    remote.soultower:soulTowerFightEndRequest(battleFloor,passWave, dungeonConfig.verifyKey,battleFormation,function (data)
        
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function ()
                    self:setResponse(data)
                end, function ()
                    self:setResponse(data)
                end, REPORT_TYPE.SOUL_TOWER)
        -- self:setResponse(data)
    end, function(data)
        self:requestFail(data)
    end, false)
end

function QSoulTowerResultController:fightEndHandler()

    local battleScene = self:getScene()
    local battleFloor = remote.soultower:getBattleFloor()
    local passWave = remote.soultower:getBattleDungenID()
    local battleAwards = remote.soultower:getAwardsByfloorWave(battleFloor,passWave)

    local index = 1
    local awards = {}
    if battleAwards.floor_reward ~= nil then
        local items = db:getluckyDrawById(battleAwards.floor_reward)
        for i = 1, #items, 1 do
            awards[index] = items[i]
            index = index + 1
        end 
    end

    if battleAwards.wave_reward ~= nil then
        local items = db:getluckyDrawById(battleAwards.wave_reward)
        for i = 1, #items, 1 do
            awards[index] = items[i]
            index = index + 1
        end 
    end

 	battleScene.curModalDialog = QSoulTowerDialogWin.new(
            {
                curWave = passWave,
                battleFloor = battleFloor,
                battleTime = app.battle:getDungeonDuration() - app.battle:getTimeLeft(),
                awards = awards,
                isWin = self._isWin,
            }, self:getCallTbl())
end

function QSoulTowerResultController:_constructGloryAttackHero()
    local attackHeroInfo = {}
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    for k, v in ipairs(teamHero) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

return QSoulTowerResultController