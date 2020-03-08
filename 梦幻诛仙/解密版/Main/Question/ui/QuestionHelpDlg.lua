local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QuestionHelpDlg = Lplus.Extend(ECPanelBase, "QuestionHelpDlg")
local def = QuestionHelpDlg.define
local QuestionModule = Lplus.ForwardDeclare("QuestionModule")
local GUIUtils = require("GUI.GUIUtils")
local UIModelWrap = require("Model.UIModelWrap")
def.field("number").questionId = 0
def.field("number").pageId = 0
def.field("function").callback = nil
def.field("table").answers = nil
def.field(UIModelWrap).modelWrap1 = nil
def.field(UIModelWrap).modelWrap2 = nil
def.field(UIModelWrap).modelWrap3 = nil
def.static("number", "number", "function").ShowHelp = function(questionId, pageId, cb)
  local dlg = QuestionHelpDlg()
  dlg.questionId = questionId
  dlg.pageId = pageId
  dlg.callback = cb
  dlg.answers = {}
  dlg:CreatePanel(RESPATH.QUESTION_HELP_PANEL, 2)
  dlg:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:InitModelWrap()
  self:SetContent()
end
def.override().OnDestroy = function(self)
  self.modelWrap1:Destroy()
  self.modelWrap2:Destroy()
  self.modelWrap3:Destroy()
end
def.method().InitModelWrap = function(self)
  local uiModel1 = self.m_panel:FindDirect("Img_Bg2/Img_BgAnswer01/Model01"):GetComponent("UIModel")
  uiModel1:set_orthographic(true)
  local uiModel2 = self.m_panel:FindDirect("Img_Bg2/Img_BgAnswer02/Model02"):GetComponent("UIModel")
  uiModel2:set_orthographic(true)
  local uiModel3 = self.m_panel:FindDirect("Img_Bg2/Img_BgAnswer03/Model03"):GetComponent("UIModel")
  uiModel3:set_orthographic(true)
  self.modelWrap1 = UIModelWrap.new(uiModel1)
  self.modelWrap2 = UIModelWrap.new(uiModel2)
  self.modelWrap3 = UIModelWrap.new(uiModel3)
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Img_BgAnswer") then
    local index = tonumber(string.sub(id, -2))
    self.callback(self.questionId, self.pageId, self.answers[index].text)
    self:DestroyPanel()
    self = nil
  end
end
def.method().SetContent = function(self)
  local questionItemCfg = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONITEM, self.questionId)
  local questionDesc = questionItemCfg:GetStringValue("questionDesc")
  local questionLabel = self.m_panel:FindDirect("Img_Bg2/Label_Question"):GetComponent("UILabel")
  questionLabel:set_text(questionDesc)
  local answerStruct = questionItemCfg:GetStructValue("answerStruct")
  local page = self.pageId
  for i = page * 3, page * 3 + 2 do
    local rec = answerStruct:GetVectorValueByIdx("answerList", i)
    local answer = rec:GetStringValue("answer")
    local refIcon = rec:GetIntValue("answerRefIcon")
    local opt = {icon = refIcon, text = answer}
    table.insert(self.answers, opt)
  end
  require("Common.MathHelper").ShuffleTable(self.answers)
  self:UpdateAnswer()
end
def.method().UpdateAnswer = function(self)
  local answers = self.answers
  local answer1 = self.m_panel:FindDirect("Img_Bg2/Img_BgAnswer01")
  local answer1Label = answer1:FindDirect("Label_Answer01"):GetComponent("UILabel")
  answer1Label:set_text(answers[1].text)
  local img1 = answer1:FindDirect("Img_Answer01")
  self:SetTexureOrModel(img1, self.modelWrap1, answers[1].icon)
  local answer2 = self.m_panel:FindDirect("Img_Bg2/Img_BgAnswer02")
  local answer2Label = answer2:FindDirect("Label_Answer02"):GetComponent("UILabel")
  answer2Label:set_text(answers[2].text)
  local img2 = answer2:FindDirect("Img_Answer02")
  self:SetTexureOrModel(img2, self.modelWrap2, answers[2].icon)
  local answer3 = self.m_panel:FindDirect("Img_Bg2/Img_BgAnswer03")
  local answer3Label = answer3:FindDirect("Label_Answer03"):GetComponent("UILabel")
  answer3Label:set_text(answers[3].text)
  local img3 = answer3:FindDirect("Img_Answer03")
  self:SetTexureOrModel(img3, self.modelWrap3, answers[3].icon)
end
def.method("userdata", UIModelWrap, "number").SetTexureOrModel = function(self, texture, modelWrap, modelId)
  local halfIconId = self:GetIconByModel(modelId)
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, halfIconId)
  if iconRecord == nil then
    print("Icon res get nil record for id: ", halfIconId)
    texture:SetActive(false)
    modelWrap:Destroy()
    return
  end
  local resourceType = iconRecord:GetIntValue("iconType")
  if resourceType == 1 then
    texture:SetActive(false)
    local resourcePath = iconRecord:GetStringValue("path")
    if resourcePath == "" then
      warn("Resource path is nil: " .. halfIconId)
    end
    modelWrap:Load(resourcePath .. ".u3dext")
  else
    texture:SetActive(true)
    modelWrap:Destroy()
    local uiTexture = texture:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, halfIconId)
  end
end
def.method("number", "=>", "number").GetIconByModel = function(self, modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  print("Geting ModelId:", modelId)
  local iconId = modelRecord:GetIntValue("halfBodyIconId")
  return iconId
end
QuestionHelpDlg.Commit()
return QuestionHelpDlg
