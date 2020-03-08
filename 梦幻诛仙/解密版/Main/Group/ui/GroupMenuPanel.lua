local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GroupModule = require("Main.Group.GroupModule")
local GroupMenuPanel = Lplus.Extend(ECPanelBase, "GroupMenuPanel")
local def = GroupMenuPanel.define
def.field("userdata").m_GroupId = nil
def.field("table").m_GroupBasicInfo = nil
def.field("table").m_OperationList = nil
def.field("table").m_AllOperations = nil
def.field("table").m_UIObjs = nil
local instance
def.static("=>", GroupMenuPanel).Instance = function()
  if nil == instance then
    instance = GroupMenuPanel()
    instance.m_GroupId = nil
    instance.m_GroupBasicInfo = nil
    instance.m_UIObjs = nil
    instance.m_OperationList = nil
    instance.m_AllOperations = nil
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, groupId)
  if not GroupModule.Instance():IsGroupExist(groupId) then
    Toast(textRes.Group[1])
    return
  end
  if self:IsShow() then
    if self.m_GroupId:eq(groupId) then
      return
    else
      self.m_GroupId = groupId
      self:UpdateData()
      self:UpdateUI()
    end
  else
    self.m_GroupId = groupId
    self:CreatePanel(RESPATH.PREFAB_GROUP_MENU_PANEL, 2)
    self:SetOutTouchDisappear()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitOperations()
  self:UpdateData()
  self:UpdateUI()
end
def.method("table").OnMemberInfoInited = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if not self.m_GroupId:eq(groupId) then
    return
  end
  self:DestroyPanel()
  local GroupSocialPanel = require("Main.Group.ui.GroupSocialPanel")
  GroupSocialPanel.Instance():ShowPanel(groupId)
end
def.override().OnDestroy = function(self)
  self.m_GroupId = nil
  self.m_GroupBasicInfo = nil
  self.m_OperationList = nil
  self.m_AllOperations = nil
  self.m_UIObjs = nil
end
def.method().InitUI = function(self)
  self.m_UIObjs = {}
  self.m_UIObjs.HeadIconGroup = self.m_panel:FindDirect("Img_BgMenu/Group_GroupInfo/Img_BgIconHead/Group_Member")
  self.m_UIObjs.GroupNameLabel = self.m_panel:FindDirect("Img_BgMenu/Group_GroupInfo/Label_Name")
  self.m_UIObjs.GroupNumLabel = self.m_panel:FindDirect("Img_BgMenu/Group_GroupInfo/Label_MemberNum")
  self.m_UIObjs.BtnGrid = self.m_panel:FindDirect("Img_BgMenu/Grid_Btn")
end
def.method().InitOperations = function(self)
  self.m_AllOperations = {
    require("Main.Group.operations.GroupInfoOperation"),
    require("Main.Group.operations.GroupInviteOperation"),
    require("Main.Group.operations.GroupDissolveOperation"),
    require("Main.Group.operations.GroupQuitOperation")
  }
end
def.method().UpdateData = function(self)
  self.m_GroupBasicInfo = GroupModule.Instance():GetGroupBasicInfo(self.m_GroupId)
  self.m_OperationList = {}
  for k, v in pairs(self.m_AllOperations) do
    local ope = v()
    if ope:CanOperate(self.m_GroupId) then
      table.insert(self.m_OperationList, ope)
    end
  end
end
def.method().UpdateUI = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupBasicInfo then
    return
  end
  local nameLabel = self.m_UIObjs.GroupNameLabel:GetComponent("UILabel")
  local numLabel = self.m_UIObjs.GroupNumLabel:GetComponent("UILabel")
  nameLabel:set_text(self.m_GroupBasicInfo.groupName)
  numLabel:set_text(string.format(textRes.Group[28], self.m_GroupBasicInfo.memberNum))
  self:UpdateGroupHeadIcon()
  self:UpdateGroupOperationGrid()
end
def.method().UpdateGroupHeadIcon = function(self)
  local headIconInfos = GroupModule.Instance():GetGroupHeadIconInfo(self.m_GroupId)
  local headIconGroup = self.m_UIObjs.HeadIconGroup
  local sprites = {}
  sprites[1] = headIconGroup:FindDirect("Img_Member3/Img_IconHead")
  sprites[2] = headIconGroup:FindDirect("Img_Member4/Img_IconHead")
  sprites[3] = headIconGroup:FindDirect("Img_Member2/Img_IconHead")
  sprites[4] = headIconGroup:FindDirect("Img_Member1/Img_IconHead")
  local defaults = {}
  defaults[1] = headIconGroup:FindDirect("Img_Member3/Img_HeadSM")
  defaults[2] = headIconGroup:FindDirect("Img_Member4/Img_HeadSM")
  defaults[3] = headIconGroup:FindDirect("Img_Member2/Img_HeadSM")
  defaults[4] = headIconGroup:FindDirect("Img_Member1/Img_HeadSM")
  for i = 1, 4 do
    local IconInfo = headIconInfos[i]
    if IconInfo then
      sprites[i]:SetActive(true)
      SetAvatarIcon(sprites[i], IconInfo.avatarId)
      defaults[i]:SetActive(false)
    else
      sprites[i]:SetActive(false)
      defaults[i]:SetActive(true)
    end
  end
end
def.method().UpdateGroupOperationGrid = function(self)
  if nil == self.m_UIObjs then
    return
  end
  local uiList = self.m_UIObjs.BtnGrid:GetComponent("UIList")
  local opeNum = #self.m_OperationList
  local items = GUIUtils.InitUIList(self.m_UIObjs.BtnGrid, opeNum, false)
  for i = 1, opeNum do
    local btnObj = items[i]
    local nameLabel = btnObj:FindDirect(string.format("Label_Info_%d", i)):GetComponent("UILabel")
    local ope = self.m_OperationList[i]
    if ope then
      local opeName = ope:GetOperationName()
      nameLabel:set_text(opeName)
    else
      nameLabel:set_text("")
    end
  end
  self.m_msgHandler:Touch(self.m_UIObjs.BtnGrid)
  GUIUtils.Reposition(self.m_UIObjs.BtnGrid, "UIList", 0.01)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self.m_panel:FindDirect("Img_BgMenu"):GetComponent("UITableResizeBackground"):Reposition()
    end
  end)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "Btn_Info_") then
    self:OnClickOperationBtn(id)
  end
end
def.method("string").OnClickOperationBtn = function(self, id)
  local strs = string.split(id, "_")
  local index = tonumber(strs[3])
  local ope = self.m_OperationList[index]
  if ope then
    ope:Operate()
  end
  if ope:GetOperationName() ~= textRes.Group.OperationName[1] then
    self:DestroyPanel()
  end
end
GroupMenuPanel.Commit()
return GroupMenuPanel
