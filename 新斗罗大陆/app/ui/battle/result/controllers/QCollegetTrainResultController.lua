-- @Author: liaoxianbo
-- @Date:   2019-11-25 17:15:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-20 18:39:00

local QBaseResultController = import(".QBaseResultController")
local QCollegetTrainResultController = class("QCollegetTrainResultController", QBaseResultController)

local QCollegeTrainDialogWin = import("..dialogs.QCollegeTrainDialogWin")
local QBattleDialogLose = import("..dialogs.QBattleDialogLose")

function QCollegetTrainResultController:ctor(options)
end

function QCollegetTrainResultController:requestResult(isWin)

    self._isWin = isWin
    
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    -- QPrintTable(dungeonConfig)
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleFormation = dungeonConfig.battleFormation
    local passTime = math.floor(app.battle:getDungeonDuration() - app.battle:getTimeLeft())
    -- remote.collegetrain:collegeTrainFightEndRequestServer(isWin,passTime,dungeonConfig.int_id,fightReportData, dungeonConfig.verifyKey,
    local dungeonId = remote.collegetrain:getChooseChapterId()
    print("选中的关卡ID=",dungeonId,timeDes)
    remote.collegetrain:collegeTrainFightEndRequestServer(isWin,passTime,dungeonId,dungeonConfig.verifyKey,fightReportData,function(data)
        self:setResponse(data)
    end,function(data)
        -- self:requestFail(data)
        self:setResponse()
    end)
end

function QCollegetTrainResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()
    -- QPrintTable(dungeonConfig)
    local chapterId = remote.collegetrain:getChooseChapterId()
    -- QPrintTable(self.response)
    local awards = self.response.prizes or {}
    local info = {}
    info.heros = dungeonConfig.heroInfos or {}
    battleScene.curModalDialog = QCollegeTrainDialogWin.new({info=info, timeType = "2",chapterId=chapterId,awards = awards, isWin = self._isWin},self:getCallTbl())
end

return QCollegetTrainResultController