local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIVoiceQuestion = Lplus.Extend(ECPanelBase, MODULE_NAME)
local instance
local def = UIVoiceQuestion.define
local VoiceQuestionUtils = require("Main.VoiceQuestion.VoiceQuestionUtils")
local VoiceQuestionModule = require("Main.VoiceQuestion.VoiceQuestionModule")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local txtConst = textRes.VoiceQuestion
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("userdata")._voiceObj = nil
def.static("=>", UIVoiceQuestion).Instance = function()
  if instance == nil then
    instance = UIVoiceQuestion()
  end
  return instance
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.VOICE_QUESTION, gmodule.notifyId.VoiceQuestion.AnswerRes, UIVoiceQuestion.OnAnswerResult, self)
  Event.RegisterEventWithContext(ModuleId.VOICE_QUESTION, gmodule.notifyId.VoiceQuestion.GetLastQuestionRes, UIVoiceQuestion.OnGetLastQuestionRes, self)
  self:_initUI()
  self:_updateUI()
end
def.override().OnDestroy = function(self)
  self:_stopPlayVoice()
  self._uiGOs = nil
  self:PlayBgMusic()
  self._uiStatus = nil
  Event.UnregisterEvent(ModuleId.VOICE_QUESTION, gmodule.notifyId.VoiceQuestion.AnswerRes, UIVoiceQuestion.OnAnswerResult)
  Event.UnregisterEvent(ModuleId.VOICE_QUESTION, gmodule.notifyId.VoiceQuestion.GetLastQuestionRes, UIVoiceQuestion.OnGetLastQuestionRes)
end
def.method()._initUI = function(self)
  local groupHide = self.m_panel:FindDirect("Group_OnTime/Group_Question/Group_Hide")
  self._uiGOs.btnLblHide = groupHide:FindDirect("Label_Hide")
  self._uiGOs.lblQuestion = self.m_panel:FindDirect("Group_OnTime/Group_Question/Group_Hide/Group_Question/Scrollview/Label_Question")
  self._uiGOs.btnLblShow = self.m_panel:FindDirect("Group_OnTime/Group_Question/Group_Show/Label_Show")
  self._uiGOs.lblTalkContent = self.m_panel:FindDirect("Group_OnTime/Group_Question/Group_Show/Group_Texture/Group_Img/Label_Char")
  self._uiGOs.gridAnswer = self.m_panel:FindDirect("Group_OnTime/Group_Answer/Grid")
  self._uiGOs.btnSpeakAnswer = self.m_panel:FindDirect("Group_OnTime/Btn_SpeakAnswer")
  self._uiGOs.lblFinish = self.m_panel:FindDirect("Label_Finish")
  self._uiGOs.fxFinish = self.m_panel:FindDirect("Img_End")
  self._uiGOs.fxFinish:SetActive(false)
  local template = self._uiGOs.gridAnswer:FindDirect("Btn_Answer")
  template.name = "Btn_Answer_0"
  template:SetActive(false)
  self._uiGOs.GridItemTemplate = template
  GUIUtils.SetText(self._uiGOs.lblTalkContent, txtConst[1])
  self._uiGOs.btnSpeakAnswer:SetActive(false)
end
def.method()._updateUI = function(self)
  local questionCfg = VoiceQuestionUtils.GetQuestionCfgById(self._uiStatus.questionId or 0)
  if questionCfg ~= nil then
    self._uiStatus.questionCfg = questionCfg
    self:_updateUIQuestion(questionCfg.questionContent)
    if self._uiStatus.bHasAnswer then
      self:_playVoice(questionCfg.answerVoiceId)
    else
      self:_playVoice(questionCfg.questionVoiceId)
    end
  end
  self:_updateUIAnswers()
end
def.method()._updateUIAnswers = function(self)
  local answerNum = self._uiStatus.answerList and #self._uiStatus.answerList or 1
  self:_resetAnswerList(answerNum)
  local comUIGrid = self._uiGOs.gridAnswer:GetComponent("UIGrid")
  local gridChildCount = comUIGrid:GetChildListCount()
  local ctrlGridList = comUIGrid:GetChildList()
  self._uiStatus.ctrlGridList = ctrlGridList
  for i = 1, gridChildCount do
    self:_fillAnswerInfo(self._uiGOs.gridAnswer:FindDirect("Btn_Answer_" .. i), self._uiStatus.answerList[i])
  end
end
def.method("userdata", "string")._fillAnswerInfo = function(self, ctrl, answerInfo)
  local lblAnswer = ctrl:FindDirect("Label")
  local imgRight = ctrl:FindDirect("Img_Right")
  local imgWrong = ctrl:FindDirect("Img_Wrong")
  local imgCorrect = ctrl:FindDirect("Img_Correct")
  if self._uiStatus and self._uiStatus.bHasAnswer then
    imgRight:SetActive(true)
    self._uiGOs.lblFinish:SetActive(true)
    self._uiGOs.btnSpeakAnswer:SetActive(true)
  else
    imgRight:SetActive(false)
    self._uiGOs.lblFinish:SetActive(false)
  end
  imgWrong:SetActive(false)
  imgCorrect:SetActive(false)
  GUIUtils.SetText(lblAnswer, answerInfo)
end
def.method("number")._resetAnswerList = function(self, count)
  local comUIGrid = self._uiGOs.gridAnswer:GetComponent("UIGrid")
  local gridChildCount = comUIGrid:GetChildListCount()
  if count > gridChildCount then
    for i = gridChildCount + 1, count do
      local gridItem = GameObject.Instantiate(self._uiGOs.GridItemTemplate)
      gridItem.name = "Btn_Answer_" .. i
      gridItem.transform.parent = self._uiGOs.gridAnswer.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif count < gridChildCount then
    for i = gridChildCount, count + 1, -1 do
      local gridItem = self._uiGOs.gridAnswer:FindDirect("Btn_Answer_" .. i)
      gridItem.transform.parent = nil
      GameObject.Destroy(gridItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  comUIGrid:Reposition()
end
def.method("string")._updateUIQuestion = function(self, strQuestion)
  GUIUtils.SetText(self._uiGOs.lblQuestion, strQuestion)
end
def.method("number", "number", "table").ShowPanel = function(self, actId, questionId, answerList)
  if self:IsLoaded() then
    return
  end
  self._uiGOs = {}
  self._uiStatus = {}
  self._uiStatus.actId = actId
  self._uiStatus.questionId = questionId
  self._uiStatus.answerList = answerList
  self._uiStatus.actCfg = VoiceQuestionUtils.GetVoiceQuestionActCfgByActId(actId)
  local bActFinish, finishCount = VoiceQuestionModule.IsActivityFinish(actId)
  if finishCount >= self._uiStatus.actCfg.maxTimes then
    self._uiStatus.bHasAnswer = true
  else
    self._uiStatus.bHasAnswer = false
  end
  self:CreatePanel(RESPATH.PREFAB_QUESTION_PANEL, 1)
  self:SetModal(true)
end
def.method("number")._playVoice = function(self, voiceId)
  local SoundData = require("Sound.SoundData")
  local path = SoundData.Instance():GetSoundPath(voiceId)
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():StopBackgroundMusic(0)
  self._uiStatus.bPlayMusic = false
  self._voiceObj = ECSoundMan.Instance():Play2DSoundExWithCallback(path, SOUND_TYPES.GUI, 10, function(isOver)
    if isOver and (self.m_panel == nil or self.m_panel.isnil) then
      return
    end
  end)
end
def.method().PlayBgMusic = function(self)
  require("Main.Map.MapModule").PlayBgMusic()
end
def.method()._stopPlayVoice = function(self)
  if self._voiceObj == nil or self._voiceObj.isnil or self._voiceObj:get_isnil() then
    self._voiceObj = nil
    return
  end
  self._voiceObj:Stop(0)
  self._voiceObj = nil
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Help" then
    if self._uiStatus.actCfg ~= nil then
      GUIUtils.ShowHoverTip(self._uiStatus.actCfg.hoverTipsId, 0, 0)
    end
  elseif id == "Btn_SpeakAnswer" then
    self:_onClickBtnSpeakAnswer()
  elseif id == "Btn_SpeakQuestion" then
    self:_onClickBtnSpeakQuestion()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Show" then
    self:_onClickBtnShow(clickObj)
  elseif string.find(id, "Btn_Answer_") then
    if self._uiStatus.bHasAnswer then
      Toast(txtConst[8])
      return
    end
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:_onClickAnswer(idx - 1)
  end
end
def.method()._onClickBtnSpeakAnswer = function(self)
  self:_stopPlayVoice()
  if self._uiStatus.questionCfg ~= nil then
    self:_playVoice(self._uiStatus.questionCfg.answerVoiceId)
  end
end
def.method()._onClickBtnSpeakQuestion = function(self)
  self:_stopPlayVoice()
  if self._uiStatus.questionCfg ~= nil then
    self:_playVoice(self._uiStatus.questionCfg.questionVoiceId)
  end
end
def.method("userdata")._onClickBtnShow = function(self, btn)
  local comToggle = btn:GetComponent("UIToggleEx")
  local bShowTxt = comToggle.value
  if bShowTxt then
    self:_stopPlayVoice()
  else
    self:_onClickBtnSpeakQuestion()
  end
end
def.method("number")._onClickAnswer = function(self, idx)
  local Protocols = VoiceQuestionModule.GetProtocols()
  local actCfg = self._uiStatus.actCfg
  if actCfg ~= nil then
    Protocols.CSendAnswerVoiceQuestionReq(actCfg.actId, actCfg.npcId, self._uiStatus.questionId, idx, Protocols.GetSessionId())
  end
end
def.method("table").OnAnswerResult = function(self, p)
  self._uiGOs.btnSpeakAnswer:SetActive(true)
  self._uiStatus.bHasAnswer = true
  local ctrlList = self._uiStatus.ctrlGridList
  local rightIdx = p.rightIdx + 1
  if ctrlList ~= nil then
    for i = 1, #ctrlList do
      local ctrl = self._uiGOs.gridAnswer:FindDirect("Btn_Answer_" .. i)
      local imgRight = ctrl:FindDirect("Img_Right")
      local imgWrong = ctrl:FindDirect("Img_Wrong")
      local imgCorrect = ctrl:FindDirect("Img_Correct")
      imgWrong:SetActive(rightIdx ~= i)
      if p.result == true and rightIdx == i then
        Toast(txtConst[6])
        imgCorrect:SetActive(true)
      else
        imgRight:SetActive(rightIdx == i)
      end
    end
  end
  if p.result ~= true then
    Toast(txtConst[7])
  end
  self._uiGOs.lblFinish:SetActive(true)
  self._uiGOs.fxFinish:SetActive(true)
  _G.GameUtil.AddGlobalTimer(0.8, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self._uiGOs.fxFinish:SetActive(false)
  end)
end
def.static("table").OnGetLastQuestionRes = function(self, p)
  self._uiGOs.btnSpeakAnswer:SetActive(true)
  self._uiStatus.bHasAnswer = true
  local ctrlList = self._uiStatus.ctrlGridList
  if ctrlList ~= nil then
    for i = 1, #ctrlList do
      local ctrl = self._uiGOs.gridAnswer:FindDirect("Btn_Answer_" .. i)
      local imgRight = ctrl:FindDirect("Img_Right")
      local imgWrong = ctrl:FindDirect("Img_Wrong")
      local strAnswer = self._uiStatus.answerList[i]
      imgWrong:SetActive(rightIdx ~= i)
      if p.answer == strAnswer then
        imgRight:SetActive(true)
      end
    end
  end
end
return UIVoiceQuestion.Commit()
