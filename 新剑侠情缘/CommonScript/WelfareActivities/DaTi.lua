function DaTi:GetQuestionInfo(szType, nQuestionId)
    local tbTypeQuestion = self.tbAllQuestion[szType]
    if szType == "Task" then
        local nCurId = ActivityQuestion.tbTaskQuestion:GetCurQuestionId()
        return tbTypeQuestion[nCurId][me.nFaction]
    elseif szType == "Activity" or szType == "ZhongQiuJie" or szType == "WeekendQuestion" then
        return tbTypeQuestion[nQuestionId]
    end
end

function DaTi:LoadSetting()
    self.tbAllQuestion = {}
    local tbFile = Lib:LoadTabFile("Setting/Activity/ZhongQiuJie.tab", {nAnswerId = 1, nA1 = 1, nA2 = 2, nA3 = 1, nA4 = 1})
    self.tbAllQuestion["ZhongQiuJie"] = {}
    for nIdx, tbInfo in ipairs(tbFile) do
        tbInfo.nId = nIdx
        self.tbAllQuestion["ZhongQiuJie"][tbInfo.nId] = tbInfo
    end

    tbFile = Lib:LoadTabFile("Setting/Activity/ActivityQuestion.tab", {nId = 1, nAnswerId = 1, nA1 = 1, nA2 = 2, nA3 = 1, nA4 = 1, nNpcTemplateId = 1, nMapTemplateId = 1})
    self.tbAllQuestion["Activity"] = {}
    for _, tbInfo in ipairs(tbFile) do
        self.tbAllQuestion["Activity"][tbInfo.nId] = tbInfo
    end

    tbFile = Lib:LoadTabFile("Setting/Task/TaskQuestion.tab", {nId = 0, nFaction = 1, nAnswerId = 1})
    self.tbAllQuestion["Task"] = {}
    for _, tbInfo in ipairs(tbFile) do
        local nQuestionIdx = tbInfo.nId
        self.tbAllQuestion["Task"][nQuestionIdx] = self.tbAllQuestion["Task"][nQuestionIdx] or {}
        self.tbAllQuestion["Task"][nQuestionIdx][tbInfo.nFaction] = tbInfo
    end

    tbFile = Lib:LoadTabFile("Setting/Activity/WeekendQuestion.tab", {nId = 1, nAnswerId = 1, nA1 = 1, nA2 = 2, nA3 = 1, nA4 = 1, nNpcTID = 1})
    self.tbAllQuestion["WeekendQuestion"] = {}
    for _, tbInfo in ipairs(tbFile) do
        self.tbAllQuestion["WeekendQuestion"][tbInfo.nId] = tbInfo
    end
end
DaTi:LoadSetting()


---------------client---------------
if not MODULE_GAMECLIENT then
    return
end
function DaTi:BeginQuestion(szType, nQuestionId, ...)
    if Ui:WindowVisible("ActivityQuestion") then
        UiNotify.OnNotify(UiNotify.emNOTIFY_DATI_DATA_CHANGE, szType, nQuestionId, ...)
    else
        Ui:OpenWindow("ActivityQuestion", szType, nQuestionId, ...)
    end
end

function DaTi:CloseUi()
    Ui:CloseWindow("ActivityQuestion")
end

function DaTi:TryAnswerQuestion(szType, nQuestionId, nAnswerId, ...)
    RemoteServer.AnswerQuestion(szType, nQuestionId, nAnswerId, ...)
    if szType == "WeekendQuestion" then
        self:CloseWeekendQuestionTimer()
    end
end

function DaTi:BeginWeekendQuestionTimer(nTime, ...)
    if self.nWeekendTimer then
        Timer:Close(self.nWeekendTimer)
    end
    local nPlayerId = me.dwID
    local tbParam = {...}
    self.nWeekendTimer = Timer:Register(nTime * Env.GAME_FPS, function ()
        self.nWeekendTimer = nil
        if nPlayerId ~= me.dwID then
            return
        end
        local tbActUi = Activity:GetUiSetting("WeekendQuestion")
        local bRet = tbActUi:CheckTeamMember()
        if not bRet then
            return
        end
        DaTi:TryAnswerQuestion(unpack(tbParam))
    end)
end

function DaTi:CloseWeekendQuestionTimer()
    if not self.nWeekendTimer then
        return
    end
    Timer:Close(self.nWeekendTimer)
    self.nWeekendTimer = nil
end