local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QuestionModule = Lplus.ForwardDeclare("QuestionModule")
local GUIUtils = require("GUI.GUIUtils")
local UIModelWrap = require("Model.UIModelWrap")
local AnswerQuestionPanel = Lplus.Extend(ECPanelBase, "AnswerQuestionPanel")
local def = AnswerQuestionPanel.define
local _instance
def.field(QuestionModule)._questionModule = nil
def.field("number").select = 0
def.field("number").tickTimer = 0
def.field(UIModelWrap).modelWrap1 = nil
def.field(UIModelWrap).modelWrap2 = nil
def.field(UIModelWrap).modelWrap3 = nil
def.field("number").helpUse = 0
def.field("boolean").debug = false
def.static("=>", AnswerQuestionPanel).new = function(self)
  local dlg = AnswerQuestionPanel()
  dlg._questionModule = QuestionModule.Instance()
  dlg.m_TrigGC = true
  return dlg
end
def.static("=>", AnswerQuestionPanel).Instance = function(self)
  if _instance == nil then
    _instance = AnswerQuestionPanel.new()
    _instance.m_TrigGC = true
  end
  return _instance
end
def.override().OnCreate = function(self)
  if self.helpUse ~= self._questionModule.questionId then
    self.helpUse = 0
  end
  self:InitModelWrap()
  self:HideFloatFirst()
  self:SetFindFirst()
  self:Update()
  self:StartTick()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.tickTimer)
  self.modelWrap1:Destroy()
  self.modelWrap2:Destroy()
  self.modelWrap3:Destroy()
  self.debug = false
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self.modelWrap1:PlayDefaultAct()
    self.modelWrap2:PlayDefaultAct()
    self.modelWrap3:PlayDefaultAct()
  end
end
def.method().InitModelWrap = function(self)
  local uiModel1 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgAnswer01/Model01"):GetComponent("UIModel")
  uiModel1:set_orthographic(true)
  local uiModel2 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgAnswer02/Model02"):GetComponent("UIModel")
  uiModel2:set_orthographic(true)
  local uiModel3 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgAnswer03/Model03"):GetComponent("UIModel")
  uiModel3:set_orthographic(true)
  self.modelWrap1 = UIModelWrap.new(uiModel1)
  self.modelWrap2 = UIModelWrap.new(uiModel2)
  self.modelWrap3 = UIModelWrap.new(uiModel3)
end
def.method().HideFloatFirst = function(self)
  self.m_panel:FindDirect("Img_Bg1/FloatIcon"):SetActive(false)
end
def.method().SetFindFirst = function(self)
  local find = self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Img_BgFind")
  local totalPage = self._questionModule.pageCount
  local page = self._questionModule.pageIndex
  local questionItemCfg = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONITEM, self._questionModule.questionId)
  local answerStruct = questionItemCfg:GetStructValue("answerStruct")
  for i = 1, 3 do
    local icon = find:FindDirect(string.format("Img_Icon%02d", i))
    if i <= totalPage then
      icon:SetActive(true)
      if i <= page then
        local rec = answerStruct:GetVectorValueByIdx("answerList", (i - 1) * 3)
        local refIcon = rec:GetIntValue("answerRefIcon")
        local headID = self:GetSmallIconByModel(refIcon)
        local tex = icon:FindDirect(string.format("Img_Find%02d", i)):GetComponent("UITexture")
        GUIUtils.FillIcon(tex, headID)
      end
    else
      icon:SetActive(false)
    end
  end
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Img_BgAnswer") then
    if self.select ~= 0 then
      return
    end
    local indexStr = string.sub(id, -2)
    local index = tonumber(indexStr)
    local myChoice = self._questionModule.answer[index].id
    self.select = index
    if self.debug then
      self:ShowResultAndNext(myChoice % 3 == 0)
    else
      self._questionModule:AnswerQuestion(self._questionModule.questionId, self._questionModule.pageIndex, index, self._questionModule.shuffleSession)
    end
  elseif id == "Btn_Help" then
    if require("Main.Gang.GangModule").Instance():HasGang() then
      if 0 < self.helpUse then
        local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
        if ChannelChatPanel.Instance():IsShow() then
          ChannelChatPanel.Instance():BringTop()
        end
        ChannelChatPanel.ShowChannelChatPanel(2, 2)
      else
        self._questionModule:UseGangHelp(self._questionModule.questionId, self._questionModule.pageIndex)
        self.helpUse = self._questionModule.questionId
        local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
        if ChannelChatPanel.Instance():IsShow() then
          ChannelChatPanel.Instance():BringTop()
        end
        ChannelChatPanel.ShowChannelChatPanel(2, 2)
      end
    else
      Toast(textRes.Question[17])
    end
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_Prize" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(constant.CEveryDayConsts.DESC_TIP_ID)
    require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
  end
end
def.method().Update = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if self._questionModule.questionId == -1 then
    self.m_panel:FindDirect("Img_Bg1/Img_End"):SetActive(true)
    GameUtil.AddGlobalTimer(2, true, function()
      self:DestroyPanel()
    end)
  else
    self.select = 0
    self:UpdateQuestion()
    self:UpdateAnswer()
    self:UpdateReward()
    self:UpdateGangHelp()
    self:UpdateIcon()
  end
end
def.method("boolean").ShowResultAndNext = function(self, isRight)
  self.helpUse = 0
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if isRight then
    self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg2/Img_BgAnswer%02d/Img_Right%02d", self.select, self.select)):SetActive(true)
    do
      local selectWidget = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg2/Img_BgAnswer%02d", self.select))
      require("Fx.GUIFxMan").Instance():PlayAsChild(selectWidget, RESPATH.QUESTION_SELECT, 0, 0, -1, false)
      local floatIcon = self.m_panel:FindDirect("Img_Bg1/FloatIcon")
      floatIcon:SetActive(true)
      local modelId = self._questionModule.answer[self.select].icon
      local headId = self:GetSmallIconByModel(modelId)
      local uitexture = floatIcon:GetComponent("UITexture")
      GUIUtils.FillIcon(uitexture, headId)
      local from = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg2/Img_BgAnswer%02d/Img_Answer%02d", self.select, self.select)).transform
      local page = self._questionModule.pageIndex + 1
      local to = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg3/Img_BgFind/Img_Icon%02d/Img_Find%02d", page, page)).transform
      TweenTransform.BeginEx(floatIcon, 0.3, from, to)
      GameUtil.AddGlobalTimer(0.5, true, function()
        if self.m_panel and not self.m_panel.isnil then
          floatIcon:SetActive(false)
          local findIcon = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg3/Img_BgFind/Img_Icon%02d/Img_Find%02d", page, page))
          findIcon:SetActive(true)
          local tex = findIcon:GetComponent("UITexture")
          GUIUtils.FillIcon(tex, headId)
        end
      end)
    end
  else
    local mark = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg2/Img_BgAnswer%02d/Img_Wrongt%02d", self.select, self.select))
    mark:SetActive(true)
    local rightUI = 0
    for i = 1, 3 do
      local index = self._questionModule.answer[i].id
      if index % 3 == 0 then
        rightUI = i
        break
      end
    end
    if self.m_panel and not self.m_panel.isnil and rightUI > 0 then
      local gou = self.m_panel:FindDirect(string.format("Img_Bg1/Img_Bg2/Img_BgAnswer%02d/Img_Correct", rightUI))
      if gou then
        gou:SetActive(true)
      end
    end
  end
  local waitTime = isRight and 0.5 or 0.5
  GameUtil.AddGlobalTimer(waitTime, true, function()
    self:Update()
  end)
end
def.method().StartTick = function(self)
  if self.debug then
    return
  end
  local timeLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Label_Time"):GetComponent("UILabel")
  local questionConstRecord = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONCONST, QuestionModule.questionCfgId)
  local activityId = questionConstRecord:GetIntValue("activityId")
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local enddingTimeInSec = ActivityInterface.GetActivityEndingTime(activityId)
  local serverTime = GetServerTime()
  local leftTime = enddingTimeInSec - serverTime
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
def.method().UpdateQuestion = function(self)
  local totalCount = self._questionModule.totalCount
  local currentCount = self._questionModule.answered + 1
  local countStr = string.format(textRes.Question[22001], currentCount, totalCount)
  local prefixStr = string.format(textRes.Question[22002], currentCount)
  local countLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Label_Count"):GetComponent("UILabel")
  countLabel:set_text(countStr)
  local prefixLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Label_QuizeNum"):GetComponent("UILabel")
  prefixLabel:set_text(prefixStr)
  local totalPage = self._questionModule.pageCount
  local question = self._questionModule.questionDesc
  if totalPage > 1 then
    question = question .. string.format(textRes.Question[22003], self._questionModule.pageIndex + 1, totalPage)
  end
  local questionLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Label_Question"):GetComponent("UILabel")
  questionLabel:set_text(question)
end
def.method().UpdateAnswer = function(self)
  local GUIUtils = require("GUI.GUIUtils")
  local answers = self._questionModule.answer
  local answer1 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgAnswer01")
  local answer1Label = answer1:FindDirect("Label_Answer01"):GetComponent("UILabel")
  answer1Label:set_text(answers[1].text)
  answer1:FindDirect("Img_Right01"):SetActive(false)
  answer1:FindDirect("Img_Wrongt01"):SetActive(false)
  answer1:FindDirect("Img_Correct"):SetActive(false)
  local img1 = answer1:FindDirect("Img_Answer01")
  self:SetTexureOrModel(img1, self.modelWrap1, answers[1].icon)
  local answer2 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgAnswer02")
  local answer2Label = answer2:FindDirect("Label_Answer02"):GetComponent("UILabel")
  answer2Label:set_text(answers[2].text)
  answer2:FindDirect("Img_Right02"):SetActive(false)
  answer2:FindDirect("Img_Wrongt02"):SetActive(false)
  answer2:FindDirect("Img_Correct"):SetActive(false)
  local img2 = answer2:FindDirect("Img_Answer02")
  self:SetTexureOrModel(img2, self.modelWrap2, answers[2].icon)
  local answer3 = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Img_BgAnswer03")
  local answer3Label = answer3:FindDirect("Label_Answer03"):GetComponent("UILabel")
  answer3Label:set_text(answers[3].text)
  answer3:FindDirect("Img_Right03"):SetActive(false)
  answer3:FindDirect("Img_Wrongt03"):SetActive(false)
  answer3:FindDirect("Img_Correct"):SetActive(false)
  local img3 = answer3:FindDirect("Img_Answer03")
  self:SetTexureOrModel(img3, self.modelWrap3, answers[3].icon)
end
def.method().UpdateReward = function(self)
  local moneyLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Img_BgGet/Img_Money/Label_MoneyNum"):GetComponent("UILabel")
  local expLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Img_BgGet/Img_Exp/Label_Exp"):GetComponent("UILabel")
  local moneyStr = string.format("+%s", self._questionModule.curMoney:tostring())
  local expStr = string.format("+%s", self._questionModule.curExp:tostring())
  moneyLabel:set_text(moneyStr)
  expLabel:set_text(expStr)
end
def.method().UpdateGangHelp = function(self)
  if self.m_panel then
    if self.helpUse > 0 then
      local helpButtonLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Btn_Help/Label_Help"):GetComponent("UILabel")
      helpButtonLabel:set_text(textRes.Question[18])
    else
      local helpButtonLabel = self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Btn_Help/Label_Help"):GetComponent("UILabel")
      local btnStr = string.format(textRes.Question[22004], self._questionModule.gangHelpUsed, self._questionModule.totalGangHelp)
      helpButtonLabel:set_text(btnStr)
      if self._questionModule.gangHelpUsed >= self._questionModule.totalGangHelp then
        self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Btn_Help"):GetComponent("UIButton"):set_isEnabled(false)
      end
    end
  end
end
def.method().UpdateIcon = function(self)
  if self._questionModule.pageIndex ~= 0 then
    return
  end
  local find = self.m_panel:FindDirect("Img_Bg1/Img_Bg3/Img_BgFind")
  local totalPage = self._questionModule.pageCount
  local page = self._questionModule.pageIndex
  for i = 1, 3 do
    local icon = find:FindDirect(string.format("Img_Icon%02d", i))
    if i <= totalPage then
      icon:SetActive(true)
      icon:FindDirect(string.format("Img_Find%02d", i)):SetActive(false)
    else
      icon:SetActive(false)
    end
  end
end
def.method("userdata", UIModelWrap, "number").SetTexureOrModel = function(self, texture, modelWrap, modelId)
  local halfIconId = self:GetIconByModel(modelId)
  local resourcePath, resourceType = GetIconPath(halfIconId)
  if resourcePath == nil or resourcePath == "" then
    texture:SetActive(false)
    modelWrap:Destroy()
    return
  end
  if resourceType == 1 then
    texture:SetActive(false)
    modelWrap:Load(resourcePath)
  else
    texture:SetActive(true)
    modelWrap:Destroy()
    local uiTexture = texture:GetComponent("UITexture")
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    GUIUtils.FillIcon(uiTexture, halfIconId)
  end
end
def.method("number", "=>", "number").GetIconByModel = function(self, modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  print("Geting ModelId:", modelId)
  local iconId = modelRecord:GetIntValue("halfBodyIconId")
  return iconId
end
def.method("number", "=>", "number").GetSmallIconByModel = function(self, modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local iconId = modelRecord:GetIntValue("headerIconId")
  return iconId
end
AnswerQuestionPanel.Commit()
return AnswerQuestionPanel
