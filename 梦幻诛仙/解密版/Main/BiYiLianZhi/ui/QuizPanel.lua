local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QuizPanel = Lplus.Extend(ECPanelBase, "QuizPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local BiYiLianZhiUtils = require("Main.BiYiLianZhi.BiYiLianZhiUtils")
local CoupleDailyConst = require("netio.protocol.mzm.gsp.coupledaily.CoupleDailyConst")
local BiYiLianZhiData = require("Main.BiYiLianZhi.BiYiLianZhiData")
local QuizPhase = {
  CLOSE = -1,
  WATING = 0,
  QUIZING = 1
}
local def = QuizPanel.define
local instance
def.field("userdata")._quizGroup = nil
def.field("userdata")._waitGroup = nil
def.field("number")._timerId = -1
def.field("number")._currentPhase = QuizPhase.CLOSE
def.field("number")._currentPhaseLeftTime = 0
def.field("number")._currentQuestionId = 0
def.field("userdata")._imgRight = nil
def.field("userdata")._imgWrong = nil
def.field("userdata")._btnAnser1 = nil
def.field("userdata")._btnAnser2 = nil
def.field("boolean")._isSelectedAnswer = false
def.field("userdata")._quizStatusLabel = nil
def.static("=>", QuizPanel).Instance = function()
  if instance == nil then
    instance = QuizPanel()
  end
  return instance
end
def.method().ShowQuizWatingPanel = function(self)
  if self:IsShow() then
    return
  end
  self._currentPhase = QuizPhase.WATING
  self._currentPhaseLeftTime = constant.CoupleDailyActivityConst.WAIT_COUPLE_QUESTION_CONFIRM_TIME
  self:CreatePanel(RESPATH.PREFAB_FUQI_QUIZ_PANEL, 1)
  self:SetModal(true)
end
def.method("number").ShowQuizPanel = function(self, questionId)
  if not self:IsShow() then
    self:ResetNewQuestionStatus(questionId)
    self:CreatePanel(RESPATH.PREFAB_FUQI_QUIZ_PANEL, 1)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:CreateTimer()
  if self._currentPhase == QuizPhase.QUIZING then
    self:UpdateQuiz()
  end
  self:UpdateTimerMessage()
end
def.method().InitUI = function(self)
  self.m_panel:FindDirect("Img_Bg/Btn_Close"):SetActive(false)
  self._quizGroup = self.m_panel:FindDirect("Img_Bg/Group_OnTime")
  self._waitGroup = self.m_panel:FindDirect("Img_Bg/Group_Wait")
  self._imgRight = self.m_panel:FindDirect("Img_Bg/Img_Right")
  self._imgWrong = self.m_panel:FindDirect("Img_Bg/Img_Wrong")
  self._btnAnser1 = self._quizGroup:FindDirect("Group_Answer/Btn_Answer1")
  self._btnAnser2 = self._quizGroup:FindDirect("Group_Answer/Btn_Answer2")
  self._quizStatusLabel = self.m_panel:FindDirect("Img_Bg/Group_OnTime/Group_CountDown/Label_Title"):GetComponent("UILabel")
  self._waitGroup:SetActive(true)
  self._quizGroup:SetActive(false)
end
def.method().CreateTimer = function(self)
  self._timerId = GameUtil.AddGlobalTimer(1, false, function()
    self:UpdateTimer()
  end)
end
def.method().UpdateTimer = function(self)
  if self._currentPhaseLeftTime <= 0 then
    return
  end
  self._currentPhaseLeftTime = self._currentPhaseLeftTime - 1
  if self._currentPhase == QuizPhase.WATING then
    self:ProcessWatingQuizTimer()
  elseif self._currentPhase == QuizPhase.QUIZING then
    self:ProcessQuizingTimer()
  end
end
def.method().ProcessWatingQuizTimer = function(self)
  self:UpdateTimerMessage()
  if self._currentPhaseLeftTime <= 0 then
    Toast(textRes.BiYiLianZhi[17])
    self:Close()
    return
  end
end
def.method().UpdateTimerMessage = function(self)
  if self._currentPhase == QuizPhase.WATING then
    local watingLabel = self._waitGroup:FindDirect("Img_Pao/Label"):GetComponent("UILabel")
    watingLabel:set_text(string.format(textRes.BiYiLianZhi[7], self._currentPhaseLeftTime))
  elseif self._currentPhase == QuizPhase.QUIZING then
    local quizTimeLabel = self._quizGroup:FindDirect("Group_CountDown/Label_Time"):GetComponent("UILabel")
    quizTimeLabel:set_pivot(3)
    quizTimeLabel:set_text(string.format("%02d", self._currentPhaseLeftTime))
  end
end
def.method().ProcessQuizingTimer = function(self)
  self:UpdateTimerMessage()
end
def.method("number").ShowQuiz = function(self, questionId)
  if not self:IsShow() then
    return
  end
  self:ResetNewQuestionStatus(questionId)
  self:UpdateTimerMessage()
  self:UpdateQuiz()
end
def.method("number").ResetNewQuestionStatus = function(self, questionId)
  self._currentPhase = QuizPhase.QUIZING
  self._currentPhaseLeftTime = constant.CoupleDailyActivityConst.WAIT_COUPLE_ANSWER_TIME
  self._currentQuestionId = questionId
  self._isSelectedAnswer = false
end
def.method().UpdateQuiz = function(self)
  local question = BiYiLianZhiUtils.GetFuqiQuestionById(self._currentQuestionId)
  local questionDescLabel = self._quizGroup:FindDirect("Group_Question/Label_Question"):GetComponent("UILabel")
  questionDescLabel:set_text(question.questionDesc)
  self._btnAnser1:FindDirect("Img_Right"):SetActive(false)
  self._btnAnser2:FindDirect("Img_Right"):SetActive(false)
  BiYiLianZhiUtils.SetButtonEnabled(self._btnAnser1, true)
  BiYiLianZhiUtils.SetButtonEnabled(self._btnAnser2, true)
  self._quizGroup:SetActive(true)
  self._waitGroup:SetActive(false)
  self._imgRight:SetActive(false)
  self._imgWrong:SetActive(false)
  self._quizStatusLabel:set_text(textRes.BiYiLianZhi[9])
  local btnShowLabels = {"A", "B"}
  local btnNames = {
    "Btn_Answer1",
    "Btn_Answer2"
  }
  local answers = {
    question.answerA,
    question.answerB
  }
  local btnAnswers = {
    self._btnAnser1,
    self._btnAnser2
  }
  BiYiLianZhiUtils.RandomAnswerAndBtnName(btnShowLabels, btnAnswers, btnNames, answers)
end
def.method("boolean").SetAnswerRight = function(self, isRight)
  if isRight then
    self._imgRight:SetActive(true)
    self._imgWrong:SetActive(false)
  else
    self._imgRight:SetActive(false)
    self._imgWrong:SetActive(true)
  end
end
def.method("number").ChooseAnswer = function(self, answer)
  if self._isSelectedAnswer then
    return
  end
  if answer == CoupleDailyConst.A_SELECTOR then
    self._quizGroup:FindDirect("Group_Answer/Btn_Answer1"):FindDirect("Img_Right"):SetActive(true)
  elseif answer == CoupleDailyConst.B_SELECTOR then
    self._quizGroup:FindDirect("Group_Answer/Btn_Answer2"):FindDirect("Img_Right"):SetActive(true)
  end
  BiYiLianZhiUtils.SetButtonEnabled(self._btnAnser1, false)
  BiYiLianZhiUtils.SetButtonEnabled(self._btnAnser2, false)
  self._isSelectedAnswer = true
  self._quizStatusLabel:set_text(textRes.BiYiLianZhi[10])
  local req = require("netio.protocol.mzm.gsp.coupledaily.CAnswerXinYouLingXiQuestion").new(answer, BiYiLianZhiData.Instance():GetCurrentSession())
  gmodule.network.sendProtocol(req)
end
def.method("boolean").ShowAnswerResult = function(self, isSame)
  if isSame then
    self._imgRight:SetActive(true)
  else
    self._imgWrong:SetActive(true)
  end
end
def.method("=>", "boolean").IsExistPanel = function(self)
  return self.m_panel ~= nil and not self.m_panel.isnil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Answer1" then
    self:ChooseAnswer(CoupleDailyConst.A_SELECTOR)
  elseif id == "Btn_Answer2" then
    self:ChooseAnswer(CoupleDailyConst.B_SELECTOR)
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self._timerId)
  self._quizGroup = nil
  self._waitGroup = nil
  self._timerId = -1
  self._currentPhase = QuizPhase.CLOSE
  self._currentPhaseLeftTime = 0
  self._currentQuestionId = 0
  self._imgRight = nil
  self._imgWrong = nil
  self._btnAnser1 = nil
  self._btnAnser2 = nil
  self._isSelectedAnswer = false
  self._quizStatusLabel = nil
end
QuizPanel.Commit()
return QuizPanel
