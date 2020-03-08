local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECLuaString = require("Utility.ECFilter")
local GroupUtils = require("Main.Group.GroupUtils")
local GroupCreatePanel = Lplus.Extend(ECPanelBase, "GroupCreatePanel")
local def = GroupCreatePanel.define
local instance
def.static("=>", GroupCreatePanel).Instance = function()
  if nil == instance then
    instance = GroupCreatePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GROUP_CREATE_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateUI = function(self)
  self:UpdateName()
  self:UpdateGroupNum()
end
def.method().UpdateName = function(self)
end
def.method().UpdateGroupNum = function(self)
  local myGroupNum = require("Main.Group.GroupModule").Instance():GetMyCreateGroupNum()
  local maxGroupNum = GroupUtils.GetCurGroupLimitNum()
  local canCreateNum = maxGroupNum - myGroupNum
  if canCreateNum >= 0 then
    local numLabel = self.m_panel:FindDirect("Img_Bg/Label_Num"):GetComponent("UILabel")
    numLabel:set_text(canCreateNum)
  end
end
def.method("string").OnSubmitCreateName = function(self, inputName)
  local nameLen = ECLuaString.Len(inputName)
  local maxNameLen = GroupUtils.GetGroupMaxNameLength()
  if nameLen > maxNameLen then
    Toast(textRes.Group[3])
    self.m_CreateName = ""
  elseif SensitiveWordsFilter.ContainsSensitiveWord(inputName) then
    Toast(textRes.Group[4])
    self.m_CreateName = ""
  else
    self.m_CreateName = inputName
  end
  self:UpdateName()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("~~~~~onClickObj~~~~~~", id)
  if "Btn_Create" == id then
    self:OnClickCreateGroup()
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Btn_Cancel" == id then
    local nameLabel = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Label_NameContent"):GetComponent("UILabel")
    nameLabel:set_text("")
  end
end
def.method().OnClickCreateGroup = function(self)
  local nameLabel = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Label_NameContent"):GetComponent("UILabel")
  local createName = nameLabel:get_text()
  if "" == createName or textRes.Group[2] == createName then
    Toast(textRes.Group[2])
    return
  end
  local nameLen = ECLuaString.Len(createName)
  local maxNameLen = GroupUtils.GetGroupMaxNameLength()
  if nameLen > maxNameLen then
    Toast(textRes.Group[3])
    return
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(createName) then
    Toast(textRes.Group[4])
    return
  end
  local GroupInfo = require("netio.protocol.mzm.gsp.group.GroupInfo")
  local groupProtocolMgr = require("Main.Group.GroupProtocolMgr")
  groupProtocolMgr.CCreateGroupReq(GroupInfo.TYPE_FRIEND, createName)
  self:DestroyPanel()
end
GroupCreatePanel.Commit()
return GroupCreatePanel
