-- @Author: xurui
-- @Date:   2017-04-27 11:05:09
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-05-15 17:27:24
local QBaseResultController = import(".QBaseResultController")
local QDragonWarResultController = class("QDragonWarResultController", QBaseResultController)

local QDragonWarDialogWin = import("..dialogs.QDragonWarDialogWin")
local QReplayUtil = import(".....utils.QReplayUtil")

function QDragonWarResultController:ctor(options)
end

function QDragonWarResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()

    self._teamName = dungeonConfig.teamName or remote.teamManager.UNION_DRAGON_WAR_ATTACK_TEAM
    local myInfo = {name = dungeonConfig.team1Name, avatar = dungeonConfig.team1Icon, level = remote.user.level}
    myInfo.heros = self:_constructGloryAttackHero()
    local rivalInfo = {name = dungeonConfig.team2Name, avatar = dungeonConfig.team2Icon, level = dungeonConfig.enemyLevel}
    local replayInfo = QReplayUtil:generateReplayInfo(myInfo, rivalInfo, 1)
	local hurt = app.battle:getUnionDragonWarFightBossHpReduce()
    
    remote.unionDragonWar:dragonWarFightEndRequest(hurt, dungeonConfig.verifyKey, self._isWin, function (data)
        remote.user:addPropNumForKey("todayDragonWarFightCount")

        app.taskEvent:updateTaskEventProgress(app.taskEvent.DRAGON_WAR_TASK_EVENT, 1, false, false)
        
        self._unionDragonWarHurt = hurt

        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function()
            self:setResponse(data)
        end, function() end, REPORT_TYPE.DRAGON_WAR)

    end, function(data)
        self:requestFail(data)
    end, false)
end

function QDragonWarResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local realHurt = self.response.gfEndResponse.dragonWarFightEndResponse.realHurt or 0
    if realHurt == 0 then
        realHurt = self._unionDragonWarHurt
    end
    battleScene.curModalDialog = QDragonWarDialogWin.new(
        {   
            isWin = true,
            currentHurt = realHurt,
            battleResult = self.response,
        }, self:getCallTbl())
end

function QDragonWarResultController:_constructGloryAttackHero()
    local attackHeroInfo = {}
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    for k, v in ipairs(teamHero) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

return QDragonWarResultController