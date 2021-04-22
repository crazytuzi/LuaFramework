--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗结算控制类
-- 

local QBaseResultController = import(".QBaseResultController")
local QSilvesArenaResultController = class("QSilvesArenaResultController", QBaseResultController)

local QBattleDialogSilvesArenaResult= import("...QBattleDialogSilvesArenaResult")
local QBattleDialogSilvesArenaEnding= import("...QBattleDialogSilvesArenaEnding")

function QSilvesArenaResultController:ctor(options)
end

function QSilvesArenaResultController:requestResult(isWin)
    print("<<<QSilvesArenaResultController>>>")
    self._isWin = isWin
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    print("<<<QSilvesArenaResultController>>>", dungeonConfig.isFightEnd, self._isWin)
    
    if dungeonConfig.isFightEnd then
        battleScene.curModalDialog = QBattleDialogSilvesArenaEnding.new({
                index = dungeonConfig.index,
                --[[Kumo]]
                callback = dungeonConfig.callback,
                isWin = self._isWin,
            }, self:getSilvesCallTbl())
        return
    else
        battleScene.curModalDialog = QBattleDialogSilvesArenaResult.new({
                index = dungeonConfig.index,
                --[[Kumo]]
                callback = dungeonConfig.callback,
                isWin = self._isWin,
            }, self:getSilvesCallTbl())
        return
    end
end

function QSilvesArenaResultController:fightEndHandler()
end

return QSilvesArenaResultController