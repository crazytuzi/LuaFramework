local tbUi = Ui:CreateClass("ActivityQuestion");

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnClose = function (self)
    self:CloseUi()
end
for i = 1, 4 do
    tbUi.tbOnClick["BtnAnswer" .. i] = function (tbParentWnd)
        tbParentWnd:AnswerQuestion(i);
    end
end

function tbUi:RegisterEvent()
    return {
    { UiNotify.emNOTIFY_TASK_HAS_CHANGE, self.OnTaskChange, self },
    { UiNotify.emNOTIFY_DATI_DATA_CHANGE, self.Update, self }
    }
end

function tbUi:OnOpenEnd(...)
    self:Update(...)
end

function tbUi:Update(szType, nQuestionId, ...)
    self.szType      = szType
    self.tbCurQues   = DaTi:GetQuestionInfo(szType, nQuestionId)
    self.bAnswered   = false
    self.tbParam     = {...}

    self:UpdateQuestion()
    if szType == "ZhongQiuJie" or szType == "WeekendQuestion" then
        self:UpdateZQJ_LastTime()
        self:CloseZQJ_Timer()
        self.nZQJ_Timer = Timer:Register(Env.GAME_FPS,
            function()
                return self:UpdateZQJ_LastTime()
            end)
    end
end

function tbUi:UpdateQuestion()
    self:UpdateDetail()
    self:UpdateAward()
    local nNpcTemplateId = self.tbCurQues.nNpcTemplateId or 75 --纳兰真
    local _1, _2, nBigFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId)
    local BigIconAtlas, BigIcon = Npc:GetFace(nBigFaceId)
    self.pPanel:Sprite_SetSprite("Npc", BigIcon, BigIconAtlas)

    self.pPanel:SetActive("ResidualTime", self.szType == "ZhongQiuJie" or self.szType == "WeekendQuestion")
    self.pPanel:SetActive("ProgressRate", self.szType == "ZhongQiuJie")

    local nCompleteNum = 1
    if self.szType == "Task" then
        nCompleteNum = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_ANSWERID_NUM) + 1
    elseif self.szType == "Activity" then
        nCompleteNum = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.HAD_ANSWER_NUM) + 1;
        local bMax   = ActivityQuestion:IsAnswerNumMax();
        for i = 1, 4 do
            self.pPanel:SetActive("BtnAnswer" .. i, not bMax);
        end
        if bMax then
            self.pPanel:Label_SetText("QuestionTitle", "答题");
            self.pPanel:Label_SetText("QuestionCon", "今天的题已答完，请明天再来");
            return;
        end
    elseif self.szType == "ZhongQiuJie" then
        local nMax = Activity.ZhongQiuJie.MAX_QUESTION
        nCompleteNum = math.min(Activity.ZhongQiuJie:GetComplete(me) + 1, nMax)
    elseif self.szType == "WeekendQuestion" then
        local nMax = Activity.WeekendQuestion.MAX_COUNT
        nCompleteNum = math.min(Activity.WeekendQuestion:GetComplete(me) + 1, nMax)
    end

    self.pPanel:Label_SetText("QuestionTitle", string.format("第%d题", nCompleteNum));
    self.pPanel:Label_SetText("QuestionCon", self.tbCurQues.szTitle);
    for nIdx = 1, 4 do
        local bShow = not Lib:IsEmptyStr(self.tbCurQues["szA" .. nIdx])
        self.pPanel:SetActive("BtnAnswer" .. nIdx, bShow)
        if bShow then
            self.pPanel:SetActive("BtnAnswer" .. nIdx, true)
            self.pPanel:SetActive("CorrectBg" .. nIdx, false);
            self.pPanel:SetActive("wrong" .. nIdx, false);
            self.pPanel:SetActive("correct" .. nIdx, false);
            self.pPanel:Label_SetText("TxtAnswer" .. nIdx, self.tbCurQues["szA" .. nIdx]);
        end
    end
end

function tbUi:UpdateDetail()
    local szAccuracy = ""
    local szComplete = ""
    local szComplete_Sub = ""
    if self.szType == "Task" then
        local nCorrect     = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_CORRECT_NUM)
        local nAccuracy    = (self.tbCurQues.nId == 1 or nCorrect == 0) and 0 or math.modf(nCorrect*100 / (self.tbCurQues.nId-1))
        local nQuestionNum = ActivityQuestion.tbTaskQuestion:GetQuestionNum()

        szAccuracy = nAccuracy .. "%"
        szComplete = string.format("%d/%d", math.min(self.tbCurQues.nId, nQuestionNum), nQuestionNum)
    elseif self.szType == "Activity" then
        local nCompleteNum = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.HAD_ANSWER_NUM);
        local nCorrect     = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.CORRECT_NUM);
        local nAccuracy    = nCompleteNum == 0 and 0 or math.modf(nCorrect * 100 / nCompleteNum);

        szAccuracy = nAccuracy .. "%"
        szComplete = string.format("%d/%d", math.min(nCompleteNum + 1, ActivityQuestion.ANSWER_NUM_MAX), ActivityQuestion.ANSWER_NUM_MAX)

        local tbAward = {ActivityQuestion.tbRightAward, ActivityQuestion.tbWrongAward, ActivityQuestion.tbMaxAward}
        for i = 1, 3 do
            local tbItemframe = self["itemframe" .. i]
            tbItemframe:SetGenericItem(tbAward[i]);
            tbItemframe.fnClick = tbItemframe.DefaultClick;
        end
    elseif self.szType == "ZhongQiuJie" then
        local nMax = Activity.ZhongQiuJie.MAX_QUESTION
        local nCompleteNum = math.min(Activity.ZhongQiuJie:GetComplete(me) + 1, nMax)
        szComplete_Sub = string.format("%d/%d", nCompleteNum, nMax)

        szAccuracy = string.format("%d/%d", Activity.ZhongQiuJie:GetRightNum(me), nMax)
        szComplete = string.format("%d秒", Activity.ZhongQiuJie:GetTotalTime(me))
    elseif self.szType == "WeekendQuestion" then
        local nRight = Activity.WeekendQuestion:GetRightNum()
        local nQuestionNum = Activity.WeekendQuestion.MAX_COUNT
        local nCompleteNum = Activity.WeekendQuestion:GetComplete()
        local nAccuracy = nCompleteNum == 0 and 0 or math.modf(nRight * 100 / nCompleteNum)
        szAccuracy = nAccuracy .. "%"
        szComplete = string.format("%d/%d", math.min(nCompleteNum + 1, nQuestionNum), nQuestionNum)
    end

    self.pPanel:Label_SetText("AccuracyTitle", self.szType == "ZhongQiuJie" and "正确题数：" or "正确率：")
    self.pPanel:Label_SetText("ProgressTitle", self.szType == "ZhongQiuJie" and "答题耗时：" or "答题进度：")
    self.pPanel:Label_SetText("AccuracyTxt", szAccuracy)
    self.pPanel:Label_SetText("ProgressTxt", szComplete)

    if self.szType == "ZhongQiuJie" then
        self.pPanel:Label_SetText("RateTxt", szComplete_Sub)
    end
    self.pPanel:SetActive("QuizContainer", self.szType ~= "Task")
end

function tbUi:UpdateAward()
    self.pPanel:SetActive("RightAward", self.szType == "ZhongQiuJie" or self.szType == "Activity" or self.szType == "WeekendQuestion")
    self.pPanel:SetActive("WrongAward", self.szType == "ZhongQiuJie" or self.szType == "Activity" or self.szType == "WeekendQuestion")
    self.pPanel:SetActive("Award", self.szType == "Activity")
    local nRightX = (self.szType == "ZhongQiuJie" or self.szType == "WeekendQuestion") and -660 or -720
    local nWrongX = (self.szType == "ZhongQiuJie" or self.szType == "WeekendQuestion") and -540 or -600
    local tbAward
    if self.szType == "ZhongQiuJie" then
        tbAward = {Activity.ZhongQiuJie.tbQuestionAward_Right, Activity.ZhongQiuJie.tbQuestionAward_Wrong}
    elseif self.szType == "Activity" then
        tbAward = {ActivityQuestion.tbRightAward, ActivityQuestion.tbWrongAward, ActivityQuestion.tbMaxAward}
    elseif self.szType == "WeekendQuestion" then
        tbAward = {Activity.WeekendQuestion.RIGHT_AWARD[1], Activity.WeekendQuestion.WRONG_AWARD[1]}
    end
    self.pPanel:ChangePosition("RightAward", nRightX, -270)
    self.pPanel:ChangePosition("WrongAward", nWrongX, -270)
    if tbAward then
        for i = 1, #tbAward do
            local tbItemframe = self["itemframe" .. i]
            tbItemframe:SetGenericItem(tbAward[i]);
            tbItemframe.fnClick = tbItemframe.DefaultClick;
        end
    end
end

function tbUi:UpdateZQJ_LastTime()
    local nEndTime = self.tbParam[1]
    local nMaxTime = self.szType == "ZhongQiuJie" and Activity.ZhongQiuJie.TIME_OUT or Activity.WeekendQuestion.TIME_OUT
    local nLastTime = math.min(math.max(0, nEndTime - GetTime()), nMaxTime)
    self.pPanel:Label_SetText("ResidualTime", string.format("(答题时间：%d秒)", nLastTime))
    if nLastTime <= 0 then
        self.nZQJ_Timer = nil
        DaTi:TryAnswerQuestion(self.szType, self.tbCurQues.nId, 0, true)
        if self.szType == "WeekendQuestion" then
            self:CloseUi()
        end
        return
    end
    return true
end

function tbUi:AnswerQuestion(nIdx)
    if self.szType == "Task" then
        if self.nCloseTimer then
            return
        end
    elseif self.szType == "Activity" then
        if not ActivityQuestion:IsTaskDoing() or self.nCloseTimer or self.bAnswered then
            return
        end
    elseif self.szType == "ZhongQiuJie" then

    elseif self.szType == "WeekendQuestion" then
        if self.bAnswered then
            return
        end

        local tbActUi = Activity:GetUiSetting("WeekendQuestion")
        local bRet, szMsg = tbActUi:CheckTeamMember()
        if not bRet then
            me.CenterMsg(szMsg or "")
            Ui:CloseWindow(self.UI_NAME)
            return
        end
    end

    local nRightIdx = self.tbCurQues.nAnswerId or 1;
    local bRight = nIdx == nRightIdx;
    me.CenterMsg(bRight and "回答正确" or "回答错误")

    self.pPanel:SetActive("correct" .. nIdx, bRight);
    self.pPanel:SetActive("CorrectBg" .. nIdx, bRight);
    self.pPanel:SetActive("wrong" .. nIdx, not bRight);
    if not bRight then
        self.pPanel:SetActive("correct" .. nRightIdx, true);
        self.pPanel:SetActive("CorrectBg" .. nRightIdx, true);
    end

    if self.szType == "Task" then
        self.nCloseTimer = Timer:Register(Env.GAME_FPS,
            function()
                self:DoNextQuestion()
            end)
    elseif self.szType == "Activity" or self.szType == "WeekendQuestion" then
        self.nCloseTimer = Timer:Register(Env.GAME_FPS * 2, self.CloseUi, self)
        self.bAnswered = true
    else
        self.bAnswered = true
        self:CloseTimer()
    end

    DaTi:TryAnswerQuestion(self.szType, self.tbCurQues.nId, nIdx)
end

function tbUi:DoNextQuestion()
    self.nCloseTimer = nil
    local bCanFinish, nTId = ActivityQuestion.tbTaskQuestion:CheckCanFinish();
    if bCanFinish then
        Task:OnTrack(nTId);
        Ui:CloseWindow(self.UI_NAME);
        return
    end

    self:Update("Task")
end

function tbUi:OnTaskChange(nTaskId)
    if self.szType ~= "Task" then
        return
    end

    local bCanFinish, nTId = ActivityQuestion.tbTaskQuestion:CheckCanFinish();
    if bCanFinish then
        Task:OnTrack(nTId);
        self:CloseUi()
    end
end

function tbUi:CloseUi()
    Ui:CloseWindow(self.UI_NAME)
    self:CloseTimer()
end

function tbUi:OnClose()
    self:CloseTimer()
    self:CloseZQJ_Timer()
    if self.bAnswered and self.szType == "Activity" then
        ActivityQuestion:OnTrack()
    end
    if self.szType == "WeekendQuestion" and not self.bAnswered then
        DaTi:BeginWeekendQuestionTimer(self.tbParam[1] - GetTime(), self.szType, self.tbCurQues.nId, 0)
    end
end

function tbUi:CloseTimer()
    if self.nCloseTimer then
        Timer:Close(self.nCloseTimer)
        self.nCloseTimer = nil
    end
end

function tbUi:CloseZQJ_Timer()
    if self.nZQJ_Timer then
        Timer:Close(self.nZQJ_Timer)
        self.nZQJ_Timer = nil
    end
end