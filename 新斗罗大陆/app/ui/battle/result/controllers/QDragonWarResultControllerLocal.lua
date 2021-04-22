local QBaseResultController = import(".QBaseResultController")
local QDragonWarResultControllerLocal = class("QDragonWarResultControllerLocal", QBaseResultController)

local QDragonWarDialogWin = import("..dialogs.QDragonWarDialogWin")
local QReplayUtil = import(".....utils.QReplayUtil")

function QDragonWarResultControllerLocal:ctor(options)
end

function QDragonWarResultControllerLocal:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()

    self._teamName = dungeonConfig.teamName or remote.teamManager.UNION_DRAGON_WAR_ATTACK_TEAM
    local myInfo = {name = dungeonConfig.team1Name, avatar = dungeonConfig.team1Icon, level = remote.user.level}
    myInfo.heros = self:_constructGloryAttackHero()
    local rivalInfo = {name = dungeonConfig.team2Name, avatar = dungeonConfig.team2Icon, level = dungeonConfig.enemyLevel}
	local hurt = app.battle:getUnionDragonWarFightBossHpReduce()
    
    -- remote.user:addPropNumForKey("todayDragonWarFightCount")

    -- app.taskEvent:updateTaskEventProgress(app.taskEvent.DRAGON_WAR_TASK_EVENT, 1, false, false)
    
    self._unionDragonWarHurt = hurt

    local data = self:makeResponse()
    self:setResponse(data)
end

function QDragonWarResultControllerLocal:makeResponse()
    local data = {
        gfEndResponse = {
            dragonWarFightEndResponse = {
                myInfo = {}
            }
        }
    }

    return data
end

function QDragonWarResultControllerLocal:fightEndHandler()
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

function QDragonWarResultControllerLocal:_constructGloryAttackHero()
    local attackHeroInfo = {}
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    for k, v in ipairs(teamHero) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

return QDragonWarResultControllerLocal