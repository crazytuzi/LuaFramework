-- @Author: xurui
-- @Date:   2018-08-14 18:54:26
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 11:04:30
local QBaseResultController = import(".QBaseResultController")
local QMetalCityResultController = class("QMetalCityResultController", QBaseResultController)

local QMetalCityDialogWin = import("..dialogs.QMetalCityDialogWin")
local QReplayUtil = import(".....utils.QReplayUtil")

function QMetalCityResultController:ctor(options)
end

function QMetalCityResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()

    local oldUser = remote.user:clone()
    self.teamName = dungeonConfig.teamName

    local teamHero = remote.teamManager:getActorIdsByKey(dungeonConfig.teamName, 1)
    local heroTotalCount = #teamHero
    self._heroInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._hero = remote.herosUtil:getHeroByID(teamHero[i])
        self._heroInfo[i] = self._hero 
    end

    if self._isWin then
        local myInfo = {}
        myInfo.name = remote.user.nickname
        myInfo.avatar = remote.user.avatar
        myInfo.level = remote.user.level        
          
        local rivalInfo = {name = dungeonConfig.team2Name, avatar = dungeonConfig.team2Icon, level = dungeonConfig.enemyLevel}

        local replayInfo = QReplayUtil:generatePVEMultipleTeamReplayInfo(myInfo, rivalInfo, dungeonConfig.pveMultipleInfos, isWin == 1 and 1 or 2)


        remote.metalCity:requestMetalCityFightEnd(dungeonConfig.metalCityNum, self._isWin, dungeonConfig.verifyKey,dungeonConfig.battleFormation,dungeonConfig.battleFormation2,function (response)
            QReplayUtil:uploadReplay(response.reportId, replayInfo, function ()
                end, function ()
                end, REPORT_TYPE.METAL_CITY)

            data = {result = response, oldUser = oldUser}
            
            remote.user:addPropNumForKey("todayMetalCityFightCount")
            remote.user:addPropNumForKey("totalMetalCityFightCount")

            app.taskEvent:updateTaskEventProgress(app.taskEvent.METAILCITY_EVENT, 1, false, self._isWin)
            
            self:setResponse(data)
            
        end, function(data)
            self:requestFail(data)
        end, false)
    else
        self:setResponse({})
    end
end

function QMetalCityResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local userComeBackRatio = self.response.result and self.response.result.userComeBackRatio or 1
    local activityYield = 1
    if userComeBackRatio > 0 then
        activityYield = userComeBackRatio
    end

    if self._isWin then
        remote.metalCity:setCurrentPassMetalNum(dungeonConfig.metalCityNum)

        battleScene.curModalDialog = QMetalCityDialogWin.new({config = dungeonConfig,
            teamName = self.teamName,
            isWin = true, 
            timeType = "2",
            star = 3,
            heroExp = 0, money = 0, score = 0, 
            isHero = true,
            heroOldInfo = self._heroInfo, 
            activityYield = activityYield,
            extAward = {}
        }, self:getCallTbl())
    else
        battleScene.curModalDialog = QMetalCityDialogWin.new({config = dungeonConfig, 
            isWin = false, 
            star = 0, text = "", 
            exp = 0, money = 0, score = 0, 
            isHero = false, isMatch = false, isFightData = false, 
            activityYield = activityYield,
            isAward = false, isEquation = false
        }, self:getLoseCallTbl())
    end
end

function QMetalCityResultController:_constructGloryAttackHero()
    local attackHeroInfo = {}
    local teamHero = remote.teamManager:getActorIdsByKey(self.teamName, 1)
    for k, v in ipairs(teamHero) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

return QMetalCityResultController