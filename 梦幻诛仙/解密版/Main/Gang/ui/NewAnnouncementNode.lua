local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local NewAnnouncementNode = Lplus.Extend(TabNode, "NewAnnouncementNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangGroupMgr = require("Main.Gang.GangGroup.GangGroupMgr")
local GangGroupData = require("Main.Gang.GangGroup.GangGroupData")
local GangPurposeValidator = require("Main.Gang.GangPurposeValidator")
local GangAnnouncementPanel = Lplus.ForwardDeclare("GangAnnouncementPanel")
local def = NewAnnouncementNode.define
def.field("table").uiNodes = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:UpdateInfo()
  self:UpdateGangGroupInfo()
end
def.override().OnHide = function(self)
  self.uiNodes = nil
end
def.method("userdata").FocusOnInput = function(self, clickobj)
  local input = clickobj:GetComponent("UIInput")
  input:set_isSelected(true)
end
def.method().UpdateInfo = function(self)
  local inputContent = self.m_node:FindDirect("Label_Content"):GetComponent("UIInput")
  local Label_Count = self.m_node:FindDirect("Label_Count"):GetComponent("UILabel")
  local val = inputContent:get_value()
  local contentMax = GangUtility.GetGangConsts("ANNOUNCEMENT_MAX_LENGTH")
  local b, _, len = GangPurposeValidator.Instance():IsValid(val)
  Label_Count:set_text(string.format("%d/%d", len, contentMax))
  inputContent:set_characterLimit(0)
end
def.method().UpdateGangGroupInfo = function(self)
  local Group_QQ = self.m_node:FindDirect("Group_QQ")
  local Group_Weixin = self.m_node:FindDirect("Group_Weixin")
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    Group_Weixin:SetActive(false)
    Group_QQ:SetActive(false)
    return
  end
  self.uiNodes = {}
  self.uiNodes.groupUIRoot = nil
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
    Group_QQ:SetActive(false)
    self.uiNodes.groupUIRoot = Group_Weixin
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    Group_Weixin:SetActive(false)
    if _G.platform == _G.Platform.android then
      self.uiNodes.groupUIRoot = Group_QQ
    elseif _G.platform == _G.Platform.ios then
      Group_QQ:SetActive(false)
      self.uiNodes.groupUIRoot = nil
    end
  end
  if not self.uiNodes.groupUIRoot then
    return
  end
  local isInGroup = GangGroupData.Instance():IsInGroup()
  if isInGroup then
    self.uiNodes.groupUIRoot:SetActive(true)
    self.uiNodes.checkBox = self.uiNodes.groupUIRoot:FindDirect("Img_Default")
    self.uiNodes.checkBox:GetComponent("UIToggle").value = false
  else
    self.uiNodes.groupUIRoot:SetActive(false)
  end
end
def.override("string", "string").onTextChange = function(self, id, val)
  local inputContent = self.m_node:FindDirect("Label_Content"):GetComponent("UIInput")
  if inputContent:get_isSelected() then
    local Label_Count = self.m_node:FindDirect("Label_Count"):GetComponent("UILabel")
    local val = inputContent:get_value()
    local contentMax = GangUtility.GetGangConsts("ANNOUNCEMENT_MAX_LENGTH")
    GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
    local b, _, len = GangPurposeValidator.Instance():IsValid(val)
    if contentMax < len then
      Toast(string.format(textRes.Gang[95], contentMax))
      local real = GangPurposeValidator.Instance():GetWordMaxVal(val)
      inputContent:set_value(real)
    else
      Label_Count:set_text(string.format("%d/%d", len, contentMax))
    end
  end
end
def.method().OnNewAnnouncementClick = function(self)
  local costVigor = GangUtility.GetGangConsts("PUBLISH_ANNOUNCEMENT_COST_VIGOR")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if costVigor > heroProp.energy then
    Toast(string.format(textRes.Gang[90], costVigor))
    return
  end
  local inputContent = self.m_node:FindDirect("Label_Content"):GetComponent("UIInput")
  local val = inputContent:get_value()
  if val == "" then
    Toast(textRes.Gang[111])
    return
  end
  local contentMax = GangUtility.GetGangConsts("ANNOUNCEMENT_MAX_LENGTH")
  GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
  local isValid = GangUtility.ValidEnteredContent(val)
  if false == isValid then
    return
  end
  if self.uiNodes and self.uiNodes.checkBox then
    local isSendAnno = self.uiNodes.checkBox:GetComponent("UIToggle").value
    warn("***Group Test--->OnNewAnnouncementClick--->Check box value", isSendAnno)
    if isSendAnno then
      warn("***Group Test--->OnNewAnnouncementClick--->Anno content", val)
      GangGroupData.Instance():SetGangAnno(val)
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CPublicAnnouncementReq").new(val))
  GangAnnouncementPanel.Instance():Hide()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Label_Content" == id then
    self:FocusOnInput(clickobj)
  elseif "Btn_Cancel" == id then
    GangAnnouncementPanel.Instance():Hide()
  elseif "Btn_Conform" == id then
    self:OnNewAnnouncementClick()
  end
end
NewAnnouncementNode.Commit()
return NewAnnouncementNode
