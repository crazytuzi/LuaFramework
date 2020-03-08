local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local EveryNightQuestionPanel = Lplus.Extend(ECPanelBase, "EveryNightQuestionPanel")
local EveryNightQuestionModule = require("Main.Question.EveryNightQuestionModule")
local QyxtHelpStatus = require("netio.protocol.mzm.gsp.question.QyxtHelpStatus")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local QYXTUtils = require("Main.Question.QYXTUtils")
local Vector = require("Types.Vector")
local dlg
local def = EveryNightQuestionPanel.define
def.static("=>", EveryNightQuestionPanel).Instance = function()
  if dlg == nil then
    dlg = EveryNightQuestionPanel()
  end
  return dlg
end
def.field("number").questionId = 0
def.field("number").totalNum = 0
def.field("number").curNum = 0
def.field("boolean").answerd = false
def.field("number").rightNum = 0
def.field("number").tickTimer = 0
def.field("number").helpUse = 0
def.field("table").answerSequence = nil
def.static("number", "number", "number", "number", "table").AskQuestion = function(questionId, curNum, totalNum, rightNum, answerSequence)
  local panel = EveryNightQuestionPanel.Instance()
  panel.questionId = questionId
  panel.helpUse = 0
  panel.curNum = curNum
  panel.totalNum = totalNum
  panel.rightNum = rightNum
  panel.answerSequence = answerSequence
  if EveryNightQuestionModule.Instance().isInGangHelp == QyxtHelpStatus.YES_IN_HELP then
    panel.helpUse = panel.questionId
  end
  if panel.m_panel ~= nil and not panel.m_panel.isnil then
    panel:SetNumberInfo()
    panel:SetQuestion()
    panel:UpdateGangHelp()
  elseif not panel:IsActivityTimeWrong() then
    panel:CreatePanel(RESPATH.PREFAB_QYXT_QUIZ_PANEL, 1)
    panel:SetModal(true)
  else
    Toast(textRes.Question[108])
  end
end
def.static().Close = function()
  EveryNightQuestionPanel.Instance():DestroyPanel()
end
def.static("number").FakeShowQuestion = function(questionId)
  local panel = EveryNightQuestionPanel.Instance()
  if panel.m_panel == nil then
    panel.questionId = questionId
    panel:CreatePanel(RESPATH.PREFAB_QYXT_QUIZ_PANEL, 1)
    panel:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:SetPanelToFit()
  self:SetTitle()
  self:StartUITimer()
  self:SetNumberInfo()
  self:SetQuestion()
  self:UpdateGangHelp()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.tickTimer)
  self.tickTimer = 0
end
def.method().SetPanelToFit = function(self)
  self.m_panel:FindDirect("Group_Other"):SetActive(false)
  self.m_panel:FindDirect("Group_OnTime"):SetActive(true)
end
def.method("=>", "boolean").IsActivityTimeWrong = function()
  local serverTime = GetServerTime()
  local endTime = require("Main.activity.ActivityInterface").GetActivityEndingTime(constant.CQYXTQuestionConst.ACTIVITY_ID)
  return serverTime >= endTime
end
def.method().StartUITimer = function(self)
  local timeLabel = self.m_panel:FindDirect("Group_OnTime/Group_CountDown/Label_Time"):GetComponent("UILabel")
  local serverTime = GetServerTime()
  local endTime = require("Main.activity.ActivityInterface").GetActivityEndingTime(constant.CQYXTQuestionConst.ACTIVITY_ID)
  local leftTime = endTime - serverTime
  local hour = math.floor(leftTime / 3600)
  local min = math.floor(leftTime % 3600 / 60)
  local sec = math.floor(leftTime % 60)
  local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
  timeLabel:set_text(timeStr)
  self.tickTimer = GameUtil.AddGlobalTimer(1, false, function()
    leftTime = leftTime - 1
    local hour = math.floor(leftTime / 3600)
    local min = math.floor(leftTime % 3600 / 60)
    local sec = math.floor(leftTime % 60)
    local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    timeLabel:set_text(timeStr)
  end)
end
def.method().SetNumberInfo = function(self)
  local questionCounter = self.m_panel:FindDirect("Group_OnTime/Group_Sum/Label_Num")
  questionCounter:SetActive(true)
  questionCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.curNum, self.totalNum))
  local accuracyCounter = self.m_panel:FindDirect("Group_OnTime/Group_Right/Label_Num")
  accuracyCounter:SetActive(true)
  accuracyCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.rightNum, self.curNum - 1))
  local countDown1 = self.m_panel:FindDirect("Group_OnTime/Group_CountDown")
  countDown1:SetActive(true)
  local countDown2 = self.m_panel:FindDirect("Group_OnTime/Group_Time")
  countDown2:SetActive(false)
end
def.method().SetTitle = function(self)
  local title = self.m_panel:FindDirect("Group_Title/Label_Title")
  local imgTitle = self.m_panel:FindDirect("Group_Title/Img_Title")
  local questionCounterTitle = self.m_panel:FindDirect("Group_OnTime/Group_Sum/Label_Title")
  title:SetActive(true)
  imgTitle:SetActive(false)
  questionCounterTitle:SetActive(true)
  local titleLabel = title:GetComponent("UILabel")
  titleLabel:set_text(textRes.Question[100])
  questionCounterTitle:GetComponent("UILabel"):set_text(textRes.Question[100] .. ": ")
end
def.method().SetQuestion = function(self)
  local questionInfo = QYXTUtils.GetQuestion(self.questionId)
  if questionInfo == nil then
    return
  end
  local questionLabel = self.m_panel:FindDirect("Group_OnTime/Group_Question/Label_Question"):GetComponent("UILabel")
  questionLabel:set_text(questionInfo.question)
  local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
  while answers:get_childCount() > 1 do
    Object.DestroyImmediate(answers:GetChild(answers:get_childCount() - 1))
  end
  if self.answerSequence then
    require("Common.MathHelper").ShuffleTableBySequence(questionInfo.answers, self.answerSequence)
  else
    require("Common.MathHelper").ShuffleTable(questionInfo.answers)
  end
  local answerTemplate = answers:FindDirect("Btn_Answer")
  answerTemplate:SetActive(false)
  for i = 1, #questionInfo.answers do
    local answerInfo = questionInfo.answers[i]
    local answerNew = Object.Instantiate(answerTemplate)
    answerNew.name = string.format("answer_%d_%d", answerInfo.id, i)
    answerNew.parent = answers
    answerNew:set_localScale(Vector.Vector3.one)
    answerNew:FindDirect("Img_Right"):SetActive(false)
    answerNew:FindDirect("Img_Wrong"):SetActive(false)
    answerNew:FindDirect("Img_Correct"):SetActive(false)
    local answerText = answerNew:FindDirect("Label")
    if answerInfo.id == 0 then
      answerText:GetComponent("UILabel"):set_text(textRes.Keju[i] .. answerInfo.text)
    else
      answerText:GetComponent("UILabel"):set_text(textRes.Keju[i] .. answerInfo.text)
    end
    answerNew:SetActive(true)
    self.m_msgHandler:Touch(answerNew)
  end
  answers:GetComponent("UIGrid"):Reposition()
  self.answerd = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
    answers:GetComponent("UIGrid"):Reposition()
  end
end
def.method("string", "boolean").ShowAnswer = function(self, answerName, right)
  local answerBtn = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid/" .. answerName)
  if right then
    answerBtn:FindDirect("Img_Right"):SetActive(true)
  else
    answerBtn:FindDirect("Img_Wrong"):SetActive(true)
  end
  if not right and self.m_panel and not self.m_panel.isnil then
    local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
    local answerBtn = answers:FindChildByPrefix("answer_0_")
    if answerBtn then
      answerBtn:FindDirect("Img_Correct"):SetActive(true)
    end
  end
end
def.method("=>", "boolean").IsExistPanel = function(self)
  return self.m_panel ~= nil and not self.m_panel.isnil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "answer_") then
    if self.answerd then
      return
    end
    do
      local answerId = tonumber(string.sub(id, 8, 8))
      local index = tonumber(string.sub(id, 10, 10))
      self:ShowAnswer(id, answerId == 0)
      self.answerd = true
      local questionId = self.questionId
      local waitTime = index == 0 and 0.5 or 0.5
      GameUtil.AddGlobalTimer(waitTime, true, function()
        require("Main.Question.EveryNightQuestionModule").Instance():AnswerQuestion(questionId, index)
      end)
    end
  elseif id == "Btn_Help" then
    if require("Main.Gang.GangModule").Instance():HasGang() then
      local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
      local chatPanel = ChannelChatPanel.Instance()
      if chatPanel:IsShow() then
        chatPanel:BringTop()
      end
      ChannelChatPanel.ShowChannelChatPanel(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
      if 0 >= self.helpUse then
        EveryNightQuestionModule.Instance():AskForGangHelp(self.questionId)
        self.helpUse = self.questionId
      end
    else
      Toast(textRes.Question[17])
    end
  end
end
def.method().UpdateGangHelp = function(self)
  if self.m_panel then
    if self.helpUse > 0 then
      local helpButtonLabel = self.m_panel:FindDirect("Btn_Help/Label"):GetComponent("UILabel")
      helpButtonLabel:set_text(textRes.Question[18])
    else
      local questionModule = EveryNightQuestionModule.Instance()
      local helpButtonLabel = self.m_panel:FindDirect("Btn_Help/Label"):GetComponent("UILabel")
      local btnStr = string.format(textRes.Question[22005], questionModule.gangHelpUsed, questionModule.totalGangHelp)
      helpButtonLabel:set_text(btnStr)
      if questionModule.gangHelpUsed >= questionModule.totalGangHelp then
        self.m_panel:FindDirect("Btn_Help"):GetComponent("UIButton"):set_isEnabled(false)
      end
    end
  end
end
EveryNightQuestionPanel.Commit()
return EveryNightQuestionPanel
