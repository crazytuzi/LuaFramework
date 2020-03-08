local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QingAnPanel = Lplus.Extend(ECPanelBase, "QingAnPanel")
local GUIUtils = require("GUI.GUIUtils")
local ShituModule = Lplus.ForwardDeclare("ShituModule")
local TipsHelper = require("Main.Common.TipsHelper")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = QingAnPanel.define
local instance
def.const("string").MESSAGE_TIPS_KEY = "MESSAGE_TIPS_KEY"
def.field("userdata").contentLabel = nil
def.static("=>", QingAnPanel).Instance = function()
  if instance == nil then
    instance = QingAnPanel()
  end
  return instance
end
def.method().ShowQingAnPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_QINGAN_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.method().InitUI = function(self)
  local Group_SayHello = self.m_panel:FindDirect("Img_Bg0/Group_SayHello")
  local Group_Response = self.m_panel:FindDirect("Img_Bg0/Group_Response")
  Group_SayHello:SetActive(true)
  Group_Response:SetActive(false)
  local Label_Info = Group_SayHello:FindDirect("Label_Info")
  local Label_Content = Group_SayHello:FindDirect("Label_Content")
  Label_Content:FindDirect("Sprite"):GetComponent("UIInput").characterLimit = 0
  local lastTips = LuaPlayerPrefs.GetRoleString(QingAnPanel.MESSAGE_TIPS_KEY)
  if lastTips ~= nil and lastTips ~= "" then
    GUIUtils.SetText(Label_Content, lastTips)
  else
    GUIUtils.SetText(Label_Content, TipsHelper.GetHoverTip(constant.ShiTuConsts.payRespectDefaultTips))
  end
  GUIUtils.SetText(Label_Info, TipsHelper.GetHoverTip(constant.ShiTuConsts.apprenticePayRespectTips))
  self.contentLabel = Label_Content
end
def.method().SendQinganContent = function(self)
  local content = self.contentLabel:GetComponent("UILabel").text
  if SensitiveWordsFilter.ContainsSensitiveWord(content) then
    Toast(textRes.Shitu[45])
    return
  end
  local length = _G.Strlen(content)
  if length < 0 or length > constant.ShiTuConsts.payRespectStrMaxLength then
    Toast(string.format(textRes.Shitu[46], 0, constant.ShiTuConsts.payRespectStrMaxLength))
    return
  end
  content = _G.TrimIllegalChar(content)
  LuaPlayerPrefs.SetRoleString(QingAnPanel.MESSAGE_TIPS_KEY, content)
  ShituModule.QingAn(content)
  self:Close()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Later" then
    self:Close()
  elseif id == "Btn_SayHello" then
    self:SendQinganContent()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.contentLabel = nil
end
QingAnPanel.Commit()
return QingAnPanel
