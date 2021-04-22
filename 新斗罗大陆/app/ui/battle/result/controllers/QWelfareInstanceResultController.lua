local QBaseResultController = import(".QBaseResultController")
local QWelfareInstanceResultController = class("QWelfareInstanceResultController", QBaseResultController)
local QBattleDialogWelfareInstance = import("..dialogs.QBattleDialogWelfareInstance")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QBuriedPoint = import(".....utils.QBuriedPoint")

function QWelfareInstanceResultController:ctor(options)
end

function QWelfareInstanceResultController:requestResult(isWin)
    -- print("[Kumo] QWelfareInstanceResultController:requestResult(isWin) ", isWin)
    if type(isWin) == "number" then
        if isWin == 1 then
            self._isWin = true
        else
            self._isWin = false
        end
    else
        self._isWin = isWin
    end
    
    local battleScene = self:getScene()
    self._dungeonConfig = battleScene:getDungeonConfig()
    app.taskEvent:updateTaskEventProgress(app.taskEvent.WELFARE_DUNGEON_TASK_EVENT, 1)

    if self._isWin then
        local oldUser = remote.user:clone()
        self._teamName = self._dungeonConfig.teamName
        local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
        local heroTotalCount = #teamHero
        self._heroOldInfo = {}
        for i = 1, heroTotalCount, 1 do
          self._hero = remote.herosUtil:getHeroByID(teamHero[i])
          self._heroOldInfo[i] = self._hero 
        end
        local battleLog = app.battle:getBattleLog()
        remote.welfareInstance:welfareFightSuccessRequest(BattleTypeEnum.DUNGEON_WELFARE,battleLog.startTime, battleLog.endTime, battleLog.dungeonId, self._dungeonConfig.verifyKey, 
            function(data)
                data = {result = data, oldUser = oldUser}
                self._invasion = data.result.userIntrusionResponse -- @qinyuanji wow-6314
                --xurui: 更新每日军团副本活跃任务
                remote.union.unionActive:updateActiveTaskProgress(20004, 6)

                self:setResponse(data)
        end,function(data)
            self:requestFail(data)
        end)
    else
        local id = self._dungeonConfig.id
        app:getClient():fightFailRequest(BattleTypeEnum.DUNGEON_WELFARE, id, self._dungeonConfig.verifyKey, function ()
            remote.welfareInstance:updateFailCount(remote.welfareInstance:getLostCount() + 1)
        end)
        self._dungeonConfig.lostCount = (self._dungeonConfig.lostCount or 0) + 1
        self:setResponse({})
    end
end

function QWelfareInstanceResultController:fightEndHandler()
    -- print("[Kumo] QWelfareInstanceResultController:fightEndHandler()")
    local battleScene = self:getScene()
    self._dungeonConfig = battleScene:getDungeonConfig()

    -- 埋点: “结算关卡X-Y点击”
    app:triggerBuriedPoint(QBuriedPoint:getDungeonWinBuriedPointID(self._dungeonID))

    if self._isWin then
        local shops = nil
        if self.response.result.shops ~= nil then
          shops = self.response.result.shops
        end

        local isFirst = remote.welfareInstance:isFirstWin()
        local awards = {}
        local itmes = {}
        --节日活动掉落
        if self.response.result.extraExpItem and type(self.response.result.extraExpItem) == "table" then
            for _, value in pairs(self.response.result.extraExpItem) do
                local id = value.id
                if id == nil then
                    id = "type"..value.type
                end
                if itmes[id] == nil then
                    itmes[id] = clone(value)
                else
                    itmes[id].count = itmes[id].count + value.count
                end
            end
        end
        -- 活动券
        local prizeWheelMoneyGot = self._dungeonConfig.prizeWheelMoneyGot or 0
        if prizeWheelMoneyGot > 0 then
            itmes[ITEM_TYPE.PRIZE_WHEEL_MONEY] = {type = ITEM_TYPE.PRIZE_WHEEL_MONEY, count = prizeWheelMoneyGot, isActivity = true}
        end
        if app.battle:isActiveDungeon() == true and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_TIME then
            local awards = app.battle:getDeadEnemyRewards(true)
            for k, value in pairs(awards) do 
                local id = value.id
                if id == nil then
                    id = "type"..value.type
                end
                if itmes[id] == nil then
                    itmes[id] = clone(value)
                else
                    itmes[id].count = itmes[id].count + value.count
                end
            end
            itmes[ITEM_TYPE.TEAM_EXP] = {type = ITEM_TYPE.TEAM_EXP, count = self._dungeonConfig.team_exp}
        else
            if self._dungeonConfig.awards ~= nil then
                for k, value in pairs(self._dungeonConfig.awards) do 
                    local id = value.id
                    if id == nil then
                        id = "type"..value.type
                    end
                    if itmes[id] == nil then
                        itmes[id] = clone(value)
                    else
                        itmes[id].count = itmes[id].count + value.count
                    end
                end
            end

            if self._dungeonConfig.awards2 ~= nil then
                for k, value in pairs(self._dungeonConfig.awards2) do 
                    local id = value.id
                    if id == nil then
                        id = "type"..value.type
                    end
                    if itmes[id] == nil then
                        itmes[id] = clone(value)
                    else
                        itmes[id].count = itmes[id].count + value.count
                    end
                end
            end
        end
        local exp = 0
        local money = 0
        local isActivityDungeon = remote.activityInstance:checkIsActivityByDungenId(self._dungeonID)
        for _,value in pairs(itmes) do
            local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(value.id)
            if itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY and isActivityDungeon then
                money = money + (itemInfo.selling_price or 0) * value.count
            else
                local typeName = remote.items:getItemType(value.type)
                if typeName == ITEM_TYPE.ITEM then
                    table.insert(awards, {id = value.id, type = ITEM_TYPE.ITEM, count = value.count, isActivity = value.isActivity})
                elseif typeName == ITEM_TYPE.MONEY then
                    money = money + value.count
                elseif typeName == ITEM_TYPE.TEAM_EXP then
                    exp = value.count
                elseif typeName == ITEM_TYPE.HERO then
                    table.insert(awards, {id = value.id, type = ITEM_TYPE.HERO, count = value.count, isActivity = value.isActivity})
                elseif self._dungeonConfig.isWelfare and typeName == ITEM_TYPE.TOKEN_MONEY and not isFirst then
                    table.insert(awards, {type = value.type, count = value.count, isActivity = value.isActivity})
                elseif typeName ~= ITEM_TYPE.TOKEN_MONEY then
                    table.insert(awards, {type = value.type, count = value.count, isActivity = value.isActivity})
                end
            end
        end

        -- battleScene.curModalDialog = QBattleDialogWelfareInstance.new({config = self._dungeonConfig, isShowStar = false, oldUser = self.response.oldUser, 
        --     heroInfo = self._heroOldInfo, shops = shops, invasion = self._invasion, isFirst = isFirst, extAward = self.response.result.extraExpItem }, self:getCallTbl())
        remote.welfareInstance:setBattleEnd(true)
        
        battleScene.curModalDialog = QBattleDialogWelfareInstance.new({
            heroOldInfo = self._heroOldInfo,
            oldTeamLevel = self.response.oldUser.level,
            teamName = self._teamName,
            timeType = "2",
            teamExp = self._dungeonConfig.team_exp,
            heroExp = self._dungeonConfig.heroExp,
            money = money, 
            awards = awards, -- 奖励物品
            stores = shops,
            invasion = self._invasion,
            isWin = true
            },self:getCallTbl())
    else
        battleScene.curModalDialog = QBattleDialogWelfareInstance.new({
            isWin = false
            }, self:getLoseCallTbl())
    end
end

return QWelfareInstanceResultController