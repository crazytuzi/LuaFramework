local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local InputViewCtrl = require("Main.Chat.ui.InputViewCtrl")
local DanmuInputViewCtrl = Lplus.Extend(InputViewCtrl, "DanmuDanmuInputViewCtrl")
local def = DanmuInputViewCtrl.define
def.override(ECPanelBase, "userdata", "function", "function").Init = function(self, base, node, delegate, delegate2)
  self.m_base = base
  self.m_node = node
  self.submitDelegate = delegate
  self.voiceDelegate = delegate2
  self.input = self.m_node:FindDirect("Img_BgInput"):GetComponent("UIInput")
  self:SetInputToWord()
end
def.override().SetInputToWord = function(self)
  local btnInput = self.m_node:FindDirect("Btn_Input")
  local btnSpeak = self.m_node:FindDirect("Btn_Speak")
  local input = self.m_node:FindDirect("Img_BgInput")
  local speak = self.m_node:FindDirect("Img_BgSpeak")
  local face = self.m_node:FindDirect("Btn_Add")
  btnInput:SetActive(false)
  btnSpeak:SetActive(false)
  input:SetActive(true)
  speak:SetActive(false)
  face:SetActive(true)
end
def.override().OpenChatInput = function(self)
  self.m_base:ToggleEmoji()
end
DanmuInputViewCtrl.Commit()
return DanmuInputViewCtrl
