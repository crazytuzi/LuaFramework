local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GroupModule = require("Main.Group.GroupModule")
local GroupUtils = require("Main.Group.GroupUtils")
local GroupInvitePanel = Lplus.Extend(ECPanelBase, "GroupInvitePanel")
local def = GroupInvitePanel.define
def.field("userdata").m_GroupId = nil
def.field("table").m_CanInviteList = nil
def.field("table").m_HasInviteList = nil
def.field("table").m_UIObjs = nil
local instance
def.static("=>", GroupInvitePanel).Instance = function()
  if nil == instance then
    instance = GroupInvitePanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, groupId)
  if nil == groupId then
    return
  end
  local memberNum = GroupModule.Instance():GetGroupMemberNum(groupId)
  local limitNum = GroupUtils.GetGroupMaxMemberNum()
  if memberNum >= limitNum then
    Toast(textRes.Group[29])
    return
  end
  if self:IsShow() then
    return
  end
  self.m_GroupId = groupId
  self:CreatePanel(RESPATH.PREFAB_GROUP_INVITE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, GroupInvitePanel.OnLeaveGroup, self)
  self:InitUI()
  self:UpdateData()
  self:UpdateUI()
end
def.method("table").OnGroupInviteMember = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local groupId = params.groupId
  local inviteRoleId = params.inviteRoleId
  if nil == groupId or nil == inviteRoleId then
    return
  end
  if not self.m_GroupId:eq(groupId) then
    return
  end
  self:UpdateData()
  self:UpdateUI()
end
def.method("table").OnLeaveGroup = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if groupId:eq(self.m_GroupId) then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, GroupInvitePanel.OnLeaveGroup)
  self.m_GroupId = nil
  self.m_CanInviteList = nil
  self.m_HasInviteList = nil
  self.m_UIObjs = nil
end
def.method().InitUI = function(self)
  self.m_UIObjs = {}
  self.m_UIObjs.InviteNumLabel = self.m_panel:FindDirect("Img_Bg0/Label_InviteNum")
  self.m_UIObjs.TipsLabel = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  self.m_UIObjs.ScrollListView = self.m_panel:FindDirect("Img_Bg0/Container/Scroll View_Friend/List_Friend")
end
def.method().UpdateData = function(self)
  self.m_CanInviteList = GroupModule.Instance():GetCanInviteFriendList(self.m_GroupId)
end
def.method().UpdateUI = function(self)
  if nil == self.m_UIObjs then
    return
  end
  local tipStr = string.format(textRes.Group[11], GroupUtils.GetGroupJoinLevel())
  local tipLable = self.m_UIObjs.TipsLabel:GetComponent("UILabel")
  tipLable:set_text(tipStr)
  self:UpdateSelectNumView()
  self:UpdateFriendList()
end
def.method().UpdateSelectNumView = function(self)
  local selectNum = self.m_HasInviteList and #self.m_HasInviteList or 0
  local selectStr = string.format(textRes.Group[13], selectNum)
  self.m_UIObjs.InviteNumLabel:GetComponent("UILabel"):set_text(selectStr)
end
def.method().UpdateFriendList = function(self)
  if nil == self.m_UIObjs then
    return
  end
  local friendList = self.m_CanInviteList
  if nil == friendList then
    friendList = {}
  end
  local scrollListObj = self.m_UIObjs.ScrollListView
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, index)
    self:FillFriendItem(item, index)
  end)
  ScrollList_setCount(uiScrollList, #friendList)
  self.m_msgHandler:Touch(scrollListObj)
end
def.method("userdata", "number").FillFriendItem = function(self, itemObj, index)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local friendInfo = self.m_CanInviteList[index]
  if nil == friendInfo then
    return
  end
  _G.SetAvatarIcon(itemObj:FindDirect("Img_IconHead"), friendInfo.avatarId)
  _G.SetAvatarFrameIcon(itemObj:FindDirect("Img_IconHead/Img_BgIconHead"), friendInfo.avatarFrameId)
  local levelLabel = itemObj:FindDirect("Img_IconHead/Label_Num"):GetComponent("UILabel")
  levelLabel:set_text(friendInfo.roleLevel)
  local occupationSprite = itemObj:FindDirect("Img_School"):GetComponent("UISprite")
  local occupationSpriteName = string.format("%d-8", friendInfo.occupationId)
  occupationSprite:set_spriteName(occupationSpriteName)
  local genderSprite = itemObj:FindDirect("Img_Sex"):GetComponent("UISprite")
  genderSprite:set_spriteName(GUIUtils.GetGenderSprite(friendInfo.sex))
  local nameLabel = itemObj:FindDirect("Label_FriendName"):GetComponent("UILabel")
  nameLabel:set_text(friendInfo.roleName)
  local relationLabel = itemObj:FindDirect("Label_Num"):GetComponent("UILabel")
  relationLabel:set_text(friendInfo.relationValue)
  itemObj:FindDirect("Img_NewRedPiont"):SetActive(false)
  local uiToggle = itemObj:FindDirect("Toggle_Select"):GetComponent("UIToggle")
  if self:IsSelectedFriend(friendInfo.roleId) then
    uiToggle:set_value(true)
  else
    uiToggle:set_value(false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("on click obj ~~~~~~~~~ ", id)
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Btn_Invite" == id then
    self:OnClickInviteBtn()
  elseif "Toggle_Select" == id then
    self:OnToggleSelectFriend(clickObj)
  end
end
def.method().OnClickInviteBtn = function(self)
  if nil == self.m_HasInviteList or 0 == #self.m_HasInviteList then
    Toast(textRes.Group[14])
    return
  end
  local inviteList = {}
  for k, v in pairs(self.m_HasInviteList) do
    table.insert(inviteList, v.roleId)
  end
  local inviteNum = #inviteList
  local hasNum = GroupModule.Instance():GetGroupMemberNum(self.m_GroupId)
  local limitNum = GroupUtils.GetGroupMaxMemberNum()
  if limitNum < hasNum + inviteNum then
    Toast(textRes.Group[15])
    return
  end
  local groupProtocolMgr = require("Main.Group.GroupProtocolMgr")
  groupProtocolMgr.CInviteJoinGroupReq(self.m_GroupId, inviteList)
  self.m_HasInviteList = {}
  self:DestroyPanel()
end
def.method("userdata").OnToggleSelectFriend = function(self, toggleObj)
  local parentObj = toggleObj.parent
  local itemObj, index = ScrollList_getItem(parentObj)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local friendInfo = self.m_CanInviteList[index]
  if nil == friendInfo then
    return
  end
  local active = toggleObj:GetComponent("UIToggle"):get_value()
  if active then
    if nil == self.m_HasInviteList then
      self.m_HasInviteList = {}
    end
    table.insert(self.m_HasInviteList, friendInfo)
  else
    local roleId = friendInfo.roleId
    if self.m_HasInviteList then
      local index = -1
      for k, v in pairs(self.m_HasInviteList) do
        if v.roleId:eq(roleId) then
          index = k
          break
        end
      end
      if index > 0 then
        table.remove(self.m_HasInviteList, index)
      end
    end
  end
  self:UpdateSelectNumView()
end
def.method("userdata", "=>", "boolean").IsSelectedFriend = function(self, friendRoleId)
  if nil == self.m_HasInviteList then
    return false
  end
  if nil == friendRoleId then
    return false
  end
  for k, v in pairs(self.m_HasInviteList) do
    if friendRoleId:eq(v.roleId) then
      return true
    end
  end
  return false
end
GroupInvitePanel.Commit()
return GroupInvitePanel
