local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ExamDlg = Lplus.Extend(ECPanelBase, "ExamDlg")
local KejuConst = require("Main.Keju.KejuConst")
local KejuModule = Lplus.ForwardDeclare("KejuModule")
local KejuUtils = require("Main.Keju.KejuUtils")
local Vector = require("Types.Vector")
local dlg
local def = ExamDlg.define
def.static("=>", ExamDlg).Instance = function()
  if dlg == nil then
    dlg = ExamDlg()
  end
  return dlg
end
def.field("string").uiRes = RESPATH.PREFAB_KEJU_QUESTION
def.field("number").status = KejuConst.UIType.QUESTION
def.field("number").questionType = 0
def.field("table").questionData = nil
def.field("string").result = ""
def.field("number").leftTime = 0
def.field("number").secondTimer = 0
def.field("number").questionId = 0
def.field("string").title = ""
def.field("table").sequence = nil
def.field("function").callback = nil
def.field("number").all = 0
def.field("number").right = 0
def.field("number").current = 0
def.field("boolean").answerd = false
def.static("string").ReplaceUIRes = function(replaceUI)
  local panel = ExamDlg.Instance()
  panel.uiRes = replaceUI
end
def.static("number", "string", "table", "number", "number", "number", "number", "function").QuizeInTime = function(questionId, title, sequence, all, right, current, seconds, callback)
  local panel = ExamDlg.Instance()
  panel.status = KejuConst.UIType.WORDQUESTION
  panel.questionId = questionId
  panel.title = title
  panel.sequence = sequence
  panel.leftTime = seconds
  panel.callback = callback
  panel.all = all
  panel.right = right
  panel.current = current
  if panel.m_panel then
    panel:UpdatePanel()
  else
    panel:CreatePanel(panel.uiRes, 1)
    panel:SetModal(true)
  end
end
local firstOpenXianshiPanel = true
local firstOpenHuishiPanel = true
local firstOpenDianshiPanel = true
def.static("number", "table").ShowQuestion = function(type, data)
  if data.totalNum == nil then
    return
  end
  local panel = ExamDlg.Instance()
  panel.questionType = type
  panel.questionData = data
  panel.result = ""
  panel.leftTime = 0
  panel.status = KejuConst.UIType.QUESTION
  if panel.m_panel then
    panel:UpdatePanel()
  else
    panel:CreatePanel(panel.uiRes, 1)
    panel:SetModal(true)
  end
end
def.static("number").setKejuState = function(statetype)
  if statetype == KejuConst.ExamType.XIANG_SHI then
    KejuModule.Instance().data[statetype].enable = KejuConst.ExamStatus.FINISH
    KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable = KejuConst.ExamStatus.DENY
    KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable = KejuConst.ExamStatus.DENY
  elseif statetype == KejuConst.ExamType.HUI_SHI then
    KejuModule.Instance().data[statetype].enable = KejuConst.ExamStatus.FINISH
  elseif statetype == KejuConst.ExamType.DIAN_SHI then
    KejuModule.Instance().data[statetype].enable = KejuConst.ExamStatus.FINISH
  end
end
def.static("string", "number").ShowResult = function(res, lt)
  local panel = ExamDlg.Instance()
  panel.questionType = 0
  panel.questionData = nil
  panel.leftTime = lt
  panel.result = res
  panel.status = KejuConst.UIType.RESULT
  if panel.m_panel then
    panel:UpdatePanel()
  else
    panel:CreatePanel(panel.uiRes, 1)
    panel:SetModal(true)
  end
end
def.static("number").ShowLeftTime = function(lt)
  local panel = ExamDlg.Instance()
  panel.questionType = 0
  panel.questionData = nil
  panel.result = ""
  panel.leftTime = lt
  panel.status = KejuConst.UIType.LEFTTIME
  if panel.m_panel then
    panel:UpdatePanel()
  else
    panel:CreatePanel(panel.uiRes, 1)
    panel:SetModal(true)
  end
end
def.static().Close = function()
  ExamDlg.Instance():DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdatePanel()
end
def.override().OnDestroy = function(self)
  self.uiRes = RESPATH.PREFAB_KEJU_QUESTION
  self:ResetTimer()
  if self.status == KejuConst.UIType.WORDQUESTION and self.callback then
    self.callback(-1)
    self.callback = nil
  end
end
def.method().UpdatePanel = function(self)
  if self.status == KejuConst.UIType.QUESTION then
    self:ResetTimer()
    self.m_panel:FindDirect("Group_Other"):SetActive(false)
    local questionGroup = self.m_panel:FindDirect("Group_OnTime")
    questionGroup:SetActive(true)
    self:SetKejuInfo()
    self:SetQuestion(self.questionData.questionId, self.questionData.sequence)
  elseif self.status == KejuConst.UIType.RESULT then
    self:ResetTimer()
    self.m_panel:FindDirect("Group_OnTime"):SetActive(false)
    do
      local otherGroup = self.m_panel:FindDirect("Group_Other")
      otherGroup:SetActive(true)
      otherGroup:FindDirect("Group_AheadTime"):SetActive(false)
      local resultGroup = otherGroup:FindDirect("Group_Finish")
      resultGroup:SetActive(true)
      local result = resultGroup:FindDirect("Label_Finish")
      local resultLabel = result:GetComponent("UILabel")
      local str = ""
      if self.leftTime > 0 then
        str = string.format(self.result, self.leftTime)
      else
        str = string.format(self.result, 0)
        self:ResetTimer()
      end
      resultLabel:set_text(str)
      if self.leftTime > 0 then
        self.secondTimer = GameUtil.AddGlobalTimer(1, false, function()
          if self.m_panel then
            self.leftTime = self.leftTime - 1
            local str = ""
            if self.leftTime > 0 then
              str = string.format(self.result, self.leftTime)
            else
              str = string.format(self.result, 0)
              self:ResetTimer()
            end
            resultLabel:set_text(str)
          end
        end)
      else
        resultLabel:set_text(self.result)
      end
    end
  elseif self.status == KejuConst.UIType.LEFTTIME then
    self:ResetTimer()
    do
      local title = self.m_panel:FindDirect("Group_Title/Label_Title")
      local imgTitle = self.m_panel:FindDirect("Group_Title/Img_Title")
      title:SetActive(true)
      imgTitle:SetActive(false)
      title:GetComponent("UILabel"):set_text(textRes.Keju.Type[KejuConst.ExamType.DIAN_SHI])
      self.m_panel:FindDirect("Group_OnTime"):SetActive(false)
      local otherGroup = self.m_panel:FindDirect("Group_Other")
      otherGroup:SetActive(true)
      otherGroup:FindDirect("Group_Finish"):SetActive(false)
      local timeGroup = otherGroup:FindDirect("Group_AheadTime")
      timeGroup:SetActive(true)
      local time = timeGroup:FindDirect("Label_Time")
      local timeLabel = time:GetComponent("UILabel")
      timeLabel:set_text(self:ConvertTimeString(self.leftTime))
      self.secondTimer = GameUtil.AddGlobalTimer(1, false, function()
        self.leftTime = self.leftTime - 1
        if self.leftTime > 0 then
          timeLabel:set_text(self:ConvertTimeString(self.leftTime))
        else
          timeLabel:set_text(self:ConvertTimeString(0))
          if self.m_panel then
            self:DestroyPanel()
          end
          self:ResetTimer()
        end
      end)
    end
  elseif self.status == KejuConst.UIType.WORDQUESTION then
    self:ResetTimer()
    self.m_panel:FindDirect("Group_Other"):SetActive(false)
    self.m_panel:FindDirect("Btn_Close"):SetActive(false)
    local questionGroup = self.m_panel:FindDirect("Group_OnTime")
    questionGroup:SetActive(true)
    self:SetInTimeQuestion()
    self:SetQuestion(self.questionId, self.sequence)
  end
end
def.method().SetInTimeQuestion = function(self)
  local title = self.m_panel:FindDirect("Group_Title/Label_Title")
  local imgTitle = self.m_panel:FindDirect("Group_Title/Img_Title")
  title:SetActive(true)
  imgTitle:SetActive(false)
  local titleLabel = title:GetComponent("UILabel")
  titleLabel:set_text(self.title)
  local questionCounterName = self.m_panel:FindDirect("Group_OnTime/Group_Sum/Label_Title")
  local questionCounter = self.m_panel:FindDirect("Group_OnTime/Group_Sum/Label_Num")
  local accuracyCounter = self.m_panel:FindDirect("Group_OnTime/Group_Right/Label_Num")
  local countDown1 = self.m_panel:FindDirect("Group_OnTime/Group_CountDown")
  countDown1:SetActive(false)
  local countDown2 = self.m_panel:FindDirect("Group_OnTime/Group_Time")
  local countDownDesc2 = countDown2:FindDirect("Label_Title")
  local countDownLabel2 = countDown2:FindDirect("Label_Time")
  questionCounterName:GetComponent("UILabel"):set_text(self.title)
  questionCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.current, self.all))
  accuracyCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.right, self.current - 1))
  countDownDesc2:GetComponent("UILabel"):set_text(textRes.Question[30])
  countDownLabel2:GetComponent("UILabel"):set_text(string.format(textRes.Question[31], self.leftTime))
  self.secondTimer = GameUtil.AddGlobalTimer(1, false, function()
    self.leftTime = self.leftTime - 1
    countDownLabel2:GetComponent("UILabel"):set_text(string.format(textRes.Question[31], self.leftTime))
    if self.leftTime < 1 then
      GameUtil.RemoveGlobalTimer(self.secondTimer)
      self.secondTimer = 0
      if self.callback then
        self.callback(-1)
        self.callback = nil
      end
    end
  end)
end
def.method().SetKejuInfo = function(self)
  self:SetTitle(self.questionType)
  local questionCounter = self.m_panel:FindDirect("Group_OnTime/Group_Sum/Label_Num")
  local accuracyCounter = self.m_panel:FindDirect("Group_OnTime/Group_Right/Label_Num")
  local countDown1 = self.m_panel:FindDirect("Group_OnTime/Group_CountDown")
  local countDownLabel1 = countDown1:FindDirect("Label_Time")
  local countDown2 = self.m_panel:FindDirect("Group_OnTime/Group_Time")
  local countDownDesc2 = countDown2:FindDirect("Label_Title")
  local countDownLabel2 = countDown2:FindDirect("Label_Time")
  if self.questionType == KejuConst.ExamType.XIANG_SHI then
    countDown2:SetActive(false)
    questionCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.questionData.answerdNum + 1, self.questionData.totalNum))
    accuracyCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.questionData.rightNum, self.questionData.answerdNum))
    do
      local curTime = GetServerTime()
      countDownLabel1:GetComponent("UILabel"):set_text(self:ConvertTimeString(self.questionData.endTime - curTime))
      self.secondTimer = GameUtil.AddGlobalTimer(1, false, function()
        if self.m_panel == nil or self.m_panel.isnil or self.questionData == nil then
          return
        end
        curTime = curTime + 1
        countDownLabel1:GetComponent("UILabel"):set_text(self:ConvertTimeString(self.questionData.endTime - curTime))
      end)
    end
  elseif self.questionType == KejuConst.ExamType.HUI_SHI then
    countDown2:SetActive(true)
    countDownDesc2:GetComponent("UILabel"):set_text(textRes.Keju[5])
    questionCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.questionData.answerdNum + 1, self.questionData.totalNum))
    accuracyCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.questionData.rightNum, self.questionData.answerdNum))
    do
      local curTime = GetServerTime()
      countDownLabel1:GetComponent("UILabel"):set_text(self:ConvertTimeString(self.questionData.endTime - curTime))
      countDownLabel2:GetComponent("UILabel"):set_text(self:ConvertTimeString(curTime - self.questionData.startTime + self.questionData.punishTime))
      self.secondTimer = GameUtil.AddGlobalTimer(1, false, function()
        if self.m_panel == nil or self.m_panel.isnil or self.questionData == nil then
          return
        end
        curTime = curTime + 1
        countDownLabel1:GetComponent("UILabel"):set_text(self:ConvertTimeString(self.questionData.endTime - curTime))
        countDownLabel2:GetComponent("UILabel"):set_text(self:ConvertTimeString(curTime - self.questionData.startTime + self.questionData.punishTime))
      end)
    end
  elseif self.questionType == KejuConst.ExamType.DIAN_SHI then
    countDown2:SetActive(true)
    countDownDesc2:GetComponent("UILabel"):set_text(textRes.Keju[5])
    questionCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.questionData.answerdNum + 1, self.questionData.totalNum))
    accuracyCounter:GetComponent("UILabel"):set_text(string.format("%d/%d", self.questionData.rightNum, self.questionData.answerdNum))
    do
      local curTime = GetServerTime()
      countDownLabel1:GetComponent("UILabel"):set_text(self:ConvertTimeString(self.questionData.endTime - curTime))
      local useTime = curTime - self.questionData.startTime + self.questionData.punishTime
      if not (useTime >= 0) or not useTime then
        useTime = 0
      end
      countDownLabel2:GetComponent("UILabel"):set_text(string.format(textRes.Keju[10], useTime))
      self.secondTimer = GameUtil.AddGlobalTimer(1, false, function()
        if self.m_panel == nil or self.m_panel.isnil or self.questionData == nil then
          return
        end
        curTime = curTime + 1
        countDownLabel1:GetComponent("UILabel"):set_text(self:ConvertTimeString(self.questionData.endTime - curTime))
        local useTime = curTime - self.questionData.startTime + self.questionData.punishTime
        if not (useTime >= 0) or not useTime then
          useTime = 0
        end
        countDownLabel2:GetComponent("UILabel"):set_text(string.format(textRes.Keju[10], useTime))
      end)
    end
  end
end
def.method("number").SetTitle = function(self, type)
  local title = self.m_panel:FindDirect("Group_Title/Label_Title")
  local imgTitle = self.m_panel:FindDirect("Group_Title/Img_Title")
  title:SetActive(true)
  imgTitle:SetActive(false)
  local titleLabel = title:GetComponent("UILabel")
  titleLabel:set_text(textRes.Keju.Type[type])
end
def.method("number", "table").SetQuestion = function(self, questionId, sequence)
  local questionInfo = KejuUtils.GetQuestion(questionId)
  local questionLabel = self.m_panel:FindDirect("Group_OnTime/Group_Question/Label_Question"):GetComponent("UILabel")
  questionLabel:set_text(questionInfo.question)
  local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
  while answers:get_childCount() > 1 do
    Object.DestroyImmediate(answers:GetChild(answers:get_childCount() - 1))
  end
  if sequence then
    require("Common.MathHelper").ShuffleTableBySequence(questionInfo.answers, sequence)
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
def.method("string", "boolean").ShowAnswer = function(self, answerName, right)
  local answerBtn = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid/" .. answerName)
  if right then
    answerBtn:FindDirect("Img_Right"):SetActive(true)
  else
    answerBtn:FindDirect("Img_Wrong"):SetActive(true)
  end
  if self.status == KejuConst.UIType.QUESTION and self.questionType == KejuConst.ExamType.XIANG_SHI and not right then
    GameUtil.AddGlobalTimer(1, true, function()
      if self.m_panel and not self.m_panel.isnil then
        local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
        local answerBtn = answers:FindChildByPrefix("answer_0_")
        if answerBtn then
          answerBtn:FindDirect("Img_Correct"):SetActive(true)
        end
      end
    end)
  elseif self.status == KejuConst.UIType.WORDQUESTION and not right and self.m_panel and not self.m_panel.isnil then
    local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
    local answerBtn = answers:FindChildByPrefix("answer_0_")
    if answerBtn then
      answerBtn:FindDirect("Img_Correct"):SetActive(true)
    end
  end
end
def.method("number").AddTime = function(self, seconds)
  if self.m_panel then
    if seconds <= 0 then
      return
    end
    local template = self.m_panel:FindDirect("Group_OnTime/Group_Time/Label_TweenAdd")
    local new = Object.Instantiate(template)
    new.parent = template.parent
    new:set_localScale(Vector.Vector3.one)
    new:set_localPosition(template:get_localPosition())
    new:GetComponent("UILabel"):set_text("+" .. seconds)
    new:SetActive(true)
  end
end
def.method("number").MinusTime = function(self, seconds)
  if self.m_panel then
    if seconds <= 0 then
      return
    end
    local template = self.m_panel:FindDirect("Group_OnTime/Group_Time/Label_TweenMinus")
    local new = Object.Instantiate(template)
    new.parent = template.parent
    new:set_localScale(Vector.Vector3.one)
    new:set_localPosition(template:get_localPosition())
    new:GetComponent("UILabel"):set_text("-" .. seconds)
    new:SetActive(true)
  end
end
def.method("number", "=>", "string").ConvertTimeString = function(self, seconds)
  if seconds >= 0 then
    local HMS = Seconds2HMSTime(seconds)
    local timeStr = string.format("%02d:%02d:%02d", HMS.h, HMS.m, HMS.s)
    return timeStr
  else
    return "00:00:00"
  end
end
def.method().ResetTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.secondTimer)
  self.secondTimer = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "answer_") then
    if self.answerd then
      return
    end
    local answerId = tonumber(string.sub(id, 8, 8))
    local index = tonumber(string.sub(id, 10, 10))
    self:ShowAnswer(id, answerId == 0)
    self.answerd = true
    if self.status == KejuConst.UIType.WORDQUESTION then
      GameUtil.RemoveGlobalTimer(self.secondTimer)
      self.secondTimer = 0
      if self.callback then
        self.callback(index)
        self.callback = nil
      end
    else
      KejuModule.Instance():AnswerQuestion(self.questionType, self.questionData.questionId, index, self.questionData.shuffleSession)
    end
  end
end
ExamDlg.Commit()
return ExamDlg
