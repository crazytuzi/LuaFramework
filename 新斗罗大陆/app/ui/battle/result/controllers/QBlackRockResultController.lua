
local QBaseResultController = import(".QBaseResultController")
local QBlackRockResultController = class("QBlackRockResultController", QBaseResultController)

local QBlackRockDialogWin = import("..dialogs.QBlackRockDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QBlackRockResultController:ctor(options)
end

function QBlackRockResultController:requestResult(isWin)

    self._isWin = isWin
    if self._isWin then 
        
        remote.user:addPropNumForKey("todayBlackFightCount")

        local battleScene = self:getScene()
        local dungeonConfig = battleScene:getDungeonConfig()
        -- 保留旧魂师
        self._teamName = dungeonConfig.teamName or remote.teamManager.BLACK_ROCK_FRIST_TEAM
        local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
        local heroTotalCount = #teamHero
        self._heroOldInfo = {}
        for i = 1, heroTotalCount, 1 do
            self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
        end

        local blackrockProgress = dungeonConfig.blackrockProgress
        local fightStep = dungeonConfig.blackrockStepInfo
        fightStep.npcsHpMp = app.battle:getMonstersHpLeft()
        fightStep.isComplete = isWin
        fightStep.battleVerify = fightStep.battleVerify --q.battleVerifyHandler(fightStep.battleVerify)

        local herosHpMp = app.battle:getHeroesHpLeft(isWin) 
        -- if isWin then
        local content = readFromBinaryFile("last.reppb")
        local fightReportData = crypto.encodeBase64(content)
        local battleFormation = dungeonConfig.battleFormation
        remote.blackrock:blackRockMemberStepFightEndRequest(fightStep, herosHpMp, fightReportData, battleFormation, dungeonConfig.progressId, dungeonConfig.verifyKey,
            function(data)
                self:setResponse(data)
        end,function(data)
            self:requestFail(data)
        end)
        -- end
    else
        self:setResponse({})
    end
end

function QBlackRockResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    local awards = {}
    local score = 0
    if self.response.gfEndResponse ~= nil and self.response.gfEndResponse.blackRockMemberStepFightEndResponse ~= nil then
        if self.response.gfEndResponse.blackRockMemberStepFightEndResponse.stepWinAward ~= nil then
            awards = remote.items:analysisServerItem(self.response.gfEndResponse.blackRockMemberStepFightEndResponse.stepWinAward, awards)
        end
        if self.response.gfEndResponse.blackRockMemberStepFightEndResponse.awardScore ~= nil then
            score = self.response.gfEndResponse.blackRockMemberStepFightEndResponse.awardScore
        end
    end
    local info = {}
    info.heros = {}
    local attackTeam = remote.teamManager:getActorIdsByKey(dungeonConfig.teamName, 1)
    for _,actorId in pairs(attackTeam) do
        table.insert(info.heros, remote.herosUtil:getHeroByID(actorId))
    end
    battleScene.curModalDialog = QBlackRockDialogWin.new({info=info, timeType = "2",teamName = self._teamName,heroOldInfo =self._heroOldInfo ,awards = awards, score = score, isWin = self._isWin},self:getCallTbl())
end

return QBlackRockResultController