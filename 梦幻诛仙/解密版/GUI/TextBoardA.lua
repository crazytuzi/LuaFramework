local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TextBoardA = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = TextBoardA
local def = Cls.define
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
def.field("string").m_content = ""
def.field("number").m_closeCountDown = 0
def.field("function").m_closeCallback = nil
def.field("string").m_confirmBtnText = ""
def.field("number").m_countDownTimerId = 0
def.static("string", "number", "function", "=>", Cls).ShowBoard = function(content, closeCountDown, closeCallback)
  local baord = Cls()
  baord.m_content = content
  baord.m_closeCountDown = closeCountDown
  baord.m_closeCallback = closeCallback
  baord:CreatePanel(RESPATH.PREFAB_ANRAN_FUBEN_NOTICE_PANEL, 0)
  return baord
end
def.method("string").SetConfirmBtnText = function(self, text)
  self.m_confirmBtnText = text
  if not self:IsLoaded() then
    return
  end
  self:UpdateConfirmBtnText()
end
def.override().OnCreate = function(self)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  if self.m_countDownTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self.m_countDownTimerId)
    self.m_countDownTimerId = 0
  end
end
def.method().ActiveClosePanel = function(self)
  self:DestroyPanel()
  if self.m_closeCallback then
    _G.SafeCallback(self.m_closeCallback, self.m_closeCountDown)
    self.m_closeCallback = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:ActiveClosePanel()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateContent()
  self:UpdateConfirmBtnText()
  self:UpdateCloseCountDown()
end
def.method().UpdateContent = function(self)
  local Label = self.m_panel:FindDirect("Group_Guide/Label")
  GUIUtils.SetText(Label, self.m_content)
end
def.method().UpdateConfirmBtnText = function(self)
  local Label = self.m_panel:FindDirect("Group_Guide/Btn_Close/Label")
  if self.m_confirmBtnText == "" then
    self.m_confirmBtnText = GUIUtils.GetUILabelTxt(Label)
  end
  local btnText
  if self.m_closeCountDown > 0 then
    btnText = textRes.Common[47]:format(self.m_confirmBtnText, self.m_closeCountDown)
  else
    btnText = self.m_confirmBtnText
  end
  GUIUtils.SetText(Label, btnText)
end
def.method().UpdateCloseCountDown = function(self)
  if self.m_closeCountDown > 0 then
    self.m_countDownTimerId = GameUtil.AddGlobalTimer(1, false, function()
      self.m_closeCountDown = self.m_closeCountDown - 1
      if self.m_closeCountDown > 0 then
        self:UpdateConfirmBtnText()
      else
        self:ActiveClosePanel()
      end
    end)
  end
end
return Cls.Commit()
