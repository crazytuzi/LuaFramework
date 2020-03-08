local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceSignInputPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceSignInputPanel.define
def.field("table").m_UIGOs = nil
def.field("string").m_desc = ""
def.field("number").m_charLimit = 0
def.field("function").m_onConfirm = nil
def.field("number").m_lastCharNum = 0
local instance
def.static("=>", SpaceSignInputPanel).Instance = function()
  if instance == nil then
    instance = SpaceSignInputPanel()
  end
  return instance
end
def.method("string", "number", "function").ShowPanel = function(self, desc, charLimit, onConfirm)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_desc = desc
  self.m_charLimit = charLimit
  self.m_onConfirm = onConfirm
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_SIGN_INPUT_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_desc = ""
  self.m_onConfirm = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Cancel" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Img_Bg0:FindDirect("Label_Tips")
  self.m_UIGOs.Img_BgInput = self.m_UIGOs.Img_Bg0:FindDirect("Img_BgInput")
  self.m_UIGOs.uiInput = self.m_UIGOs.Img_BgInput:GetComponent("UIInput")
  self.m_UIGOs.uiInput:set_characterLimit(self.m_charLimit)
end
def.method().UpdateUI = function(self)
  if self.m_desc ~= "" then
    GUIUtils.SetText(self.m_UIGOs.Label_Tips, self.m_desc)
  end
end
def.method().OnClickConfirmBtn = function(self)
  local inputedValue = self.m_UIGOs.uiInput:get_value()
  local value = _G.TrimIllegalChar(inputedValue)
  local ret = self.m_onConfirm(value)
  if ret == true then
    self:DestroyPanel()
  end
end
def.method("string", "string").onTextChange = function(self, id, text)
  if id == "Img_BgInput" then
    local charNum = _G.Strlen(text)
    if self.m_charLimit ~= 0 and charNum == self.m_charLimit and self.m_lastCharNum == self.m_charLimit then
      Toast(textRes.Common[82]:format(self.m_charLimit))
    end
    self.m_lastCharNum = charNum
  end
end
return SpaceSignInputPanel.Commit()
