local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceGiftLeaveMsgPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceGiftLeaveMsgPanel.define
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local ECDebugOption = require("Main.ECDebugOption")
local SpaceInputCtrl = import(".SpaceInputCtrl")
def.field("table").m_UIGOs = nil
def.field(SpaceInputCtrl).m_msgInputCtrl = nil
def.field("function").m_onSendFunc = nil
def.field("number").m_charLimit = 0
def.field("number").m_lastCharNum = 0
def.field("string").m_tip = ""
local instance
def.static("=>", SpaceGiftLeaveMsgPanel).Instance = function()
  if instance == nil then
    instance = SpaceGiftLeaveMsgPanel()
  end
  return instance
end
def.method("string", "function").ShowPanel = function(self, tip, onSend)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_onSendFunc = onSend
  self.m_tip = tip
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_GIFT_LEAVE_MSG_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_msgInputCtrl = nil
  self.m_onSendFunc = nil
  self.m_charLimit = 0
  self.m_lastCharNum = 0
  self.m_tip = ""
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Send" then
    self:OnClickSendBtn()
  elseif id == "Btn_Look" then
    self.m_msgInputCtrl:ShowInputDlg()
  elseif id == "Btn_Clear" then
    self.m_msgInputCtrl:ClearContent()
  end
end
def.method().InitData = function(self)
  self.m_charLimit = ECSocialSpaceConfig.getGiftLeaveMsgCharLimit()
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_ChatInput = self.m_UIGOs.Img_Bg0:FindDirect("Group_ChatInput")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Img_Bg0:FindDirect("Label_Tips")
  self.m_UIGOs.Label_NameCount = self.m_UIGOs.Group_ChatInput:FindDirect("Label_NameCount")
  local Img_BgInput = self.m_UIGOs.Group_ChatInput:FindDirect("Img_BgInput")
  self.m_UIGOs.uiInput = Img_BgInput:GetComponent("UIInput")
  self.m_msgInputCtrl = SpaceInputCtrl.New(self, self.m_UIGOs.uiInput)
  self.m_msgInputCtrl:SetNeededMenus({
    SpaceInputCtrl.MenuType.Emoji
  })
  self.m_UIGOs.uiInput:set_characterLimit(self.m_charLimit)
end
def.method().UpdateUI = function(self)
  self:UpdateCharCountText()
  self:UpdateTip()
end
def.method().OnClickSendBtn = function(self)
  local uiInput = self.m_UIGOs.uiInput
  local inputValue = uiInput:get_value()
  self:OnSendContent(inputValue)
end
def.method("string", "=>", "boolean").OnSendContent = function(self, cnt)
  local msg = self.m_msgInputCtrl:GetContent(cnt)
  if self.m_onSendFunc then
    local closePanel = self.m_onSendFunc(msg)
    if closePanel then
      self:DestroyPanel()
    end
  else
    self:DestroyPanel()
  end
  return true
end
def.method("string", "string").onTextChange = function(self, id, text)
  if id == "Img_BgInput" then
    local charNum = _G.Strlen(text)
    if self.m_charLimit ~= 0 and charNum == self.m_charLimit and self.m_lastCharNum == self.m_charLimit then
      Toast(textRes.Common[82]:format(self.m_charLimit))
    end
    self.m_lastCharNum = charNum
    self:SetCharCountText(charNum)
  end
end
def.method().UpdateCharCountText = function(self)
  local uiInput = self.m_UIGOs.uiInput
  local inputValue = uiInput:get_value()
  local charNum = _G.Strlen(inputValue)
  self:SetCharCountText(charNum)
end
def.method("number").SetCharCountText = function(self, charNum)
  local charCountText = string.format("%d/%d", charNum, self.m_charLimit)
  GUIUtils.SetText(self.m_UIGOs.Label_NameCount, charCountText)
end
def.method().UpdateTip = function(self)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips, self.m_tip)
end
return SpaceGiftLeaveMsgPanel.Commit()
