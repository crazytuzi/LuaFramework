local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WorldQuestionPanel = Lplus.Extend(ECPanelBase, "WorldQuestionPanel")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local PANEL_TYPE = {TYPE_QUESTION = 0, TYPE_RESULT = 1}
local def = WorldQuestionPanel.define
local instance
def.field("number")._panelType = PANEL_TYPE.TYPE_QUESTION
def.field("string")._content = ""
def.field("table")._uiObjs = nil
def.field("number")._leftShowTime = 0
def.field("number")._timerId = -1
def.static("=>", WorldQuestionPanel).Instance = function()
  if instance == nil then
    instance = WorldQuestionPanel()
  end
  return instance
end
def.method("string").ShowWorldQuestion = function(self, question)
  self._panelType = PANEL_TYPE.TYPE_QUESTION
  self._content = question
  self:_CreateWorldQuestion()
end
def.method("string").ShowWorldQuestionResult = function(self, result)
  self._panelType = PANEL_TYPE.TYPE_RESULT
  self._content = result
  self:_CreateWorldQuestion()
end
def.method()._CreateWorldQuestion = function(self)
  if self.m_panel == nil then
    self:CreatePanel(RESPATH.PREFAB_WORLD_QUESTION_PANEL, 2)
  else
    self:_UpdatePanel()
  end
end
def.method()._UpdatePanel = function(self)
  if self._panelType == PANEL_TYPE.TYPE_QUESTION then
    self:_UpdateQuestionPanel()
  else
    self:_UpdateResultPanel()
  end
  self:_StopPanelTimer()
  self:_StartQPanelStayTimer()
end
def.method()._UpdateQuestionPanel = function(self)
  if self._uiObjs == nil then
    return
  end
  self._uiObjs.Group_Question:SetActive(true)
  self._uiObjs.Group_NoAnswer:SetActive(false)
  self._uiObjs.Group_Question:FindDirect("Label_Question"):GetComponent("UILabel"):set_text(self._content)
end
def.method()._StartQPanelStayTimer = function(self)
  if self:_IsOpenWorldChatChanel() and self._panelType == PANEL_TYPE.TYPE_QUESTION then
    return
  end
  self._leftShowTime = constant.WorldQuestionConsts.TURN_DOWN__TIME
  self:_UpdatePanelRemainTime()
  self._timerId = GameUtil.AddGlobalTimer(1, false, function()
    self._leftShowTime = self._leftShowTime - 1
    self:_UpdatePanelRemainTime()
    if self._leftShowTime <= 0 then
      self:Close()
    end
  end)
end
def.method()._UpdatePanelRemainTime = function(self)
  if self._uiObjs == nil then
    return
  end
  local btnLabel
  if self._panelType == PANEL_TYPE.TYPE_QUESTION then
    btnLabel = self._uiObjs.Group_Question:FindDirect("Btn_Close"):FindDirect("Label_Close")
  else
    btnLabel = self._uiObjs.Group_NoAnswer:FindDirect("Btn_Close"):FindDirect("Label")
  end
  btnLabel:GetComponent("UILabel"):set_text(string.format(textRes.WorldQuestion[19], self._leftShowTime))
end
def.method()._UpdateResultPanel = function(self)
  if self._uiObjs == nil then
    return
  end
  self._uiObjs.Group_Question:SetActive(false)
  self._uiObjs.Group_NoAnswer:SetActive(true)
  self._uiObjs.Group_NoAnswer:FindDirect("Label"):GetComponent("UILabel"):set_text(self._content)
end
def.override().OnCreate = function(self)
  self:SetDepth(GUIDEPTH.TOP)
  self._uiObjs = {}
  self._uiObjs.Img_Bg1 = self.m_panel:FindDirect("Group_WorldQuestion/Img_Bg1")
  self._uiObjs.Group_Question = self._uiObjs.Img_Bg1:FindDirect("Group_Question")
  self._uiObjs.Group_NoAnswer = self._uiObjs.Img_Bg1:FindDirect("Group_NoAnswer")
  self:_UpdatePanel()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CHAT_CLICK, WorldQuestionPanel.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CloseChatPanel, WorldQuestionPanel.OnCloseChatPanel)
end
def.static("table", "table").OnChatBtnClick = function(params, tbl)
  if instance._panelType == PANEL_TYPE.TYPE_QUESTION then
    instance:_AnswerQuestion()
  end
end
def.static("table", "table").OnCloseChatPanel = function(params, tbl)
  if instance._panelType == PANEL_TYPE.TYPE_QUESTION then
    instance:Close()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Answer" then
    self:_AnswerQuestion()
  end
end
def.method()._AnswerQuestion = function(self)
  if not self:_IsOpenWorldChatChanel() then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
  end
  instance:_LetPanelStay()
end
def.method("=>", "boolean")._IsOpenWorldChatChanel = function(self)
  local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
  if channelChatPanel.m_panel == nil then
    return false
  end
  if channelChatPanel.channelType == ChatMsgData.MsgType.CHANNEL and channelChatPanel.channelSubType == ChatMsgData.Channel.WORLD then
    return true
  end
  return false
end
def.method().Close = function(self)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
end
def.method()._LetPanelStay = function(self)
  self:_StopPanelTimer()
  if self._uiObjs == nil then
    return
  end
  self._uiObjs.Group_Question:FindDirect("Btn_Close"):FindDirect("Label_Close"):GetComponent("UILabel"):set_text(textRes.WorldQuestion[20])
end
def.override().OnDestroy = function(self)
  self:_ClearData()
  self:_StopPanelTimer()
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CHAT_CLICK, WorldQuestionPanel.OnChatBtnClick)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CloseChatPanel, WorldQuestionPanel.OnCloseChatPanel)
end
def.method()._ClearData = function(self)
  self._uiObjs = nil
  self._content = ""
  self._leftShowTime = 0
end
def.method()._StopPanelTimer = function(self)
  if self._timerId ~= -1 then
    GameUtil.RemoveGlobalTimer(self._timerId)
    self._timerId = -1
  end
end
WorldQuestionPanel.Commit()
return WorldQuestionPanel
