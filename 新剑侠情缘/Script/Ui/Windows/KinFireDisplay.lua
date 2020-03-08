local tbUi = Ui:CreateClass("KinFireDisplay")

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_KINGATHER_UPDATE,   self.Update,        self },
        { UiNotify.emNOTIFY_MAP_ENTER,          self.OnEnterMap,    self },
    };

    return tbRegEvent;
end

function tbUi:OnOpen()
    if not Calendar:IsActivityInOpenState("KinGather") then
        return 0
    end
    self:Update()
    self.nTimer = Timer:Register(Env.GAME_FPS * 1, self.UpdateLastTime, self)
    self.pPanel:SetActive("BtnDrink", true)
    self.pPanel:SetActive("BtnAnswer", true)
    self.pPanel:SetActive("BtnClose", false)
    self.pPanel:SetActive("Main", true)
end

function tbUi:OnClose()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil;
    end
end

function tbUi:OnEnterMap(nMapTemplateID)
    Log("[KinFireDisplay OnEnterMap]", nMapTemplateID)
    self.pPanel:SetActive("Main", nMapTemplateID == Kin.Def.nKinMapTemplateId)
end

function tbUi:Update()
    local tbData    = Kin:GetGatherOtherData() or {}

    local szMemberNum = string.format("%d", tbData.nMemberNum or 0)
    self.pPanel:Label_SetText("PeopleNumber", szMemberNum)

    local tbQuestionData = tbData[Kin.GatherDef.QuestionData]
    local bQuestionBegin = tbQuestionData and tbQuestionData.nIndex > 0 or false
    if bQuestionBegin then
        local nCurIdx = math.min(tbData.nCurQuestionIdx or 0, Kin.GatherDef.QuizCount)
        local szQuestion = string.format("%d/%d", nCurIdx or 1, Kin.GatherDef.QuizCount)
        self.pPanel:Label_SetText("AnswerExp", szQuestion)
    else
        self.pPanel:Label_SetText("AnswerExp", "未开始")
    end
    self.pPanel:Button_SetEnabled("BtnAnswer", bQuestionBegin)

    local nQuotiety = tbData.nQuotiety or 100
    local szExpRate = string.format("%d%%", nQuotiety)
    self.pPanel:Label_SetText("ExpRate", szExpRate)

    local bHadDice = tbData.nScore
    local bCanDice = Kin.nGatherAnswerRightCount and Kin.nGatherAnswerRightCount >= Kin.GatherDef.DiceOpenAnswerCount
    self.pPanel:SetActive("DicePoints1", not bHadDice and not bCanDice)
    self.pPanel:SetActive("DicePoints2", not bHadDice and bCanDice)
    self.pPanel:SetActive("DiceNum", bHadDice)
    self.pPanel:Label_SetText("DiceNum", string.format("%d", tbData.nScore or 0))

    self:UpdateLastTime()
end

function tbUi:UpdateLastTime()
    local tbData    = Kin:GetGatherOtherData() or {}
    local nLastTime = tbData.nLastTime or 10 * 60
    local nLastMin  = math.floor(nLastTime / 60)
    local nLastSec  = nLastTime % 60
    local szTime    = string.format("%d:%02d", nLastMin, nLastSec)
    self.pPanel:Label_SetText("RemainingTime", szTime)

    tbData.nLastTime = tbData.nLastTime - 1
    if tbData.nLastTime < 0 then
        self.pPanel:Label_SetText("RemainingTime", "已结束")
        self.pPanel:Label_SetText("Countdown", "")
        self.pPanel:SetActive("BtnDrink", false)
        self.pPanel:SetActive("BtnAnswer", false)
        self.pPanel:SetActive("BtnClose", true)
        self.nTimer = nil
        return
    end

    local tbQuestionData = tbData[Kin.GatherDef.QuestionData]
    if tbQuestionData then
        local nRestTime = tbQuestionData.nTimeOut - GetTime()
        self.pPanel:SetActive("Countdown", nRestTime > 0)
        if nRestTime > 0 then
            local szTime = string.format("(%d秒)", nRestTime)
            self.pPanel:Label_SetText("Countdown", szTime)
        end
    else
        self.pPanel:SetActive("Countdown", false)
    end

    return true
end

tbUi.tbOnClick = {
    BtnDrink = function (self)
        Kin:GatherDrink()
    end,

    BtnAnswer = function (self)
        local tbGatherData = Kin:GetGatherOtherData()
        if tbGatherData[Kin.GatherDef.QuestionOver] then
            me.CenterMsg("所有答题已结束")
            return
        end
        
        local tbQuestionData = tbGatherData[Kin.GatherDef.QuestionData]
        if not tbQuestionData then
            return
        end
        Ui:OpenWindow("KinAnswerPanel", tbQuestionData)
    end,

    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}