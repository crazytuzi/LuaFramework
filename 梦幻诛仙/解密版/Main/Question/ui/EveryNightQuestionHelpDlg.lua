local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local EveryNightQuestionHelpDlg = Lplus.Extend(ECPanelBase, "EveryNightQuestionHelpDlg")
local QYXTUtils = require("Main.Question.QYXTUtils")
local Vector = require("Types.Vector")
local dlg
local def = EveryNightQuestionHelpDlg.define
def.field("number").questionId = 0
def.field("function").callback = nil
def.field("boolean").answerd = false
def.field("table").answers = nil
def.static("number", "function").ShowHelp = function(questionId, cb)
  local dlg = EveryNightQuestionHelpDlg()
  dlg.questionId = questionId
  dlg.callback = cb
  dlg.answers = {}
  dlg:CreatePanel(RESPATH.PREFAB_QYXT_QUIZ_HELP_PANEL, 2)
  dlg:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:SetQuestion()
end
def.method().SetQuestion = function(self)
  local questionInfo = QYXTUtils.GetQuestion(self.questionId)
  local questionLabel = self.m_panel:FindDirect("Group_OnTime/Group_Question/Label_Question"):GetComponent("UILabel")
  questionLabel:set_text(questionInfo.question)
  local answers = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
  while answers:get_childCount() > 1 do
    Object.DestroyImmediate(answers:GetChild(answers:get_childCount() - 1))
  end
  require("Common.MathHelper").ShuffleTable(questionInfo.answers)
  local answerTemplate = answers:FindDirect("Btn_Answer")
  answerTemplate:SetActive(false)
  for i = 1, #questionInfo.answers do
    local answerInfo = questionInfo.answers[i]
    local answerNew = Object.Instantiate(answerTemplate)
    answerNew.name = string.format("answer_%d", answerInfo.id)
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
    self.answers[answerInfo.id] = answerInfo
  end
  answers:GetComponent("UIGrid"):Reposition()
  self.answerd = false
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "answer_") then
    if self.answerd then
      return
    end
    local index = tonumber(string.sub(id, 8))
    self.answerd = true
    self.callback(self.questionId, self.answers[index].text)
    self:DestroyPanel()
  end
end
EveryNightQuestionHelpDlg.Commit()
return EveryNightQuestionHelpDlg
