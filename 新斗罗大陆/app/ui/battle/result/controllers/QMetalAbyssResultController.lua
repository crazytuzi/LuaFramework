
local QBaseResultController = import(".QBaseResultController")
local QMetalAbyssResultController = class("QMetalAbyssResultController", QBaseResultController)

local QBattleDialogMetalAbyssResult = import("..dialogs.QBattleDialogMetalAbyssResult")
local QReplayUtil = import(".....utils.QReplayUtil")

function QMetalAbyssResultController:ctor(options)
end

function QMetalAbyssResultController:requestResult(isWin)
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    self:setResponse(dungeonConfig.fightEndResponse)
end

function QMetalAbyssResultController:fightEndHandler()
    print("==QMetalAbyssResultController:fightEndHandler====")
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    self._scoreList = dungeonConfig.fightEndResponse.gfEndResponse.scoreList
    local winNum = 0
    local loseNum = 0
    local difficult = dungeonConfig.tempDifficulty or 1
    for _, score in ipairs(self._scoreList or {}) do 
        if score then
            winNum = winNum + 1
        else
            loseNum = loseNum + 1
        end
    end
    local awards = {}
    if dungeonConfig.fightEndResponse.gfEndResponse and dungeonConfig.fightEndResponse.gfEndResponse.abyssFightEndResponse and dungeonConfig.fightEndResponse.gfEndResponse.abyssFightEndResponse.fightEndReward then
        local rewards = dungeonConfig.fightEndResponse.gfEndResponse.abyssFightEndResponse.fightEndReward
        print(rewards)
        awards = remote.items:analysisServerItem(rewards, awards)
        QPrintTable(awards)
        -- for _, value in pairs(dungeonConfig.fightEndResponse.items or {}) do
        --     table.insert(awards, {id = value.id or value.type , typeName = remote.items:getItemType(value.id or value.type) or ITEM_TYPE.ITEM, count = value.count})
        -- end
    end
    battleScene.curModalDialog = QBattleDialogMetalAbyssResult.new({
            isWin = winNum >= 2,
            winNum = winNum,
            loseNum = loseNum,
            extAward = awards,
            difficult = difficult
        }, self:getSilvesCallTbl())
end

return QMetalAbyssResultController