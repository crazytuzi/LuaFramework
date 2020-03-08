local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgTeamInvite = Lplus.Extend(ECPanelBase, "DlgTeamInvite")
local def = DlgTeamInvite.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
def.field("number").idx = 0
def.field("table").roles = nil
def.static("=>", DlgTeamInvite).Instance = function()
  if dlg == nil then
    dlg = DlgTeamInvite()
  end
  return dlg
end
def.override().OnCreate = function(self)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_TEAM_INVITE_UI_RES, 2)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Refresh" then
    self:Refresh()
  elseif string.find(id, "Btn_InviteFriendList_") == 1 then
    if teamData:GetMemberCount() >= 5 then
      Toast(textRes.Team[49])
      return
    end
    local index = tonumber(string.sub(id, 22))
    if self.roles[index] == nil then
      return
    end
    local roleId = self.roles[index].roleid or self.roles[index].roleId
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CInviteTeamReq").new(roleId))
    table.remove(self.roles, index)
    if self.idx == 1 then
      self:UpdateFriends()
    else
      self:UpdateNearby()
    end
  elseif id == "Tap_Fiend" then
    if self.idx == 1 then
      return
    end
    self.idx = 1
    self:ShowFriends()
  elseif id == "Tap_Around" then
    if self.idx == 2 then
      return
    end
    self.idx = 2
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CRequestRoleInfoInView").new())
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.idx = 1
  self:ShowFriends()
end
def.method().Refresh = function(self)
  if self.idx == 1 then
    self:ShowFriends()
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.map.CRequestRoleInfoInView").new())
  end
end
def.method().ShowNearBy = function(self)
  self.roles = teamData.rolesInView
  self:UpdateNearby()
end
def.method().UpdateNearby = function(self)
  local roleListPanel = self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Scroll View_FriendList/List_FriendList")
  local uiList = roleListPanel:GetComponent("UIList")
  if self.roles == nil then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = #self.roles
  uiList:Resize()
  for i = 1, #self.roles do
    local roleItem = roleListPanel:FindDirect("Img_BgFriendList001_" .. i)
    roleItem:FindDirect("Label_NameFriendList_" .. i):GetComponent("UILabel").text = self.roles[i].name
    roleItem:FindDirect("Img_SchoolFriendList_" .. i):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(self.roles[i].occupationId)
    roleItem:FindDirect("Label_LvFriendList_" .. i):GetComponent("UILabel").text = self.roles[i].level .. textRes.Team[2]
    _G.SetAvatarIcon(roleItem:FindDirect("Img_HeadFriendList_" .. i), self.roles[i].avatarId)
    local Img_AvatarFrame = roleItem:FindDirect("Img_AvatarFrame_" .. i)
    _G.SetAvatarFrameIcon(Img_AvatarFrame, self.roles[i].avatarFrameid)
    local genderIcon = roleItem:FindDirect("Img_SexFriendList_" .. i)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(self.roles[i].gender))
  end
  self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Scroll View_FriendList"):GetComponent("UIScrollView"):ResetPosition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ShowFriends = function(self)
  local roles = require("Main.friend.FriendModule").Instance():GetFriends()
  self.roles = {}
  local idx = 1
  for i = 1, #roles do
    if teamData:GetTeamMember(roles[i].roleId) == nil and 1 > roles[i].teamMemCount and roles[i].onlineStatus == require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE then
      self.roles[idx] = roles[i]
      idx = idx + 1
    end
  end
  self:UpdateFriends()
end
def.method().UpdateFriends = function(self)
  local roleListPanel = self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Scroll View_FriendList/List_FriendList")
  local uiList = roleListPanel:GetComponent("UIList")
  if self.roles == nil then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  uiList.itemCount = #self.roles
  uiList:Resize()
  if uiList.itemCount == 0 then
    return
  end
  local idx = 1
  for i = 1, #self.roles do
    if 1 > self.roles[i].teamMemCount then
      local roleItem = roleListPanel:FindDirect("Img_BgFriendList001_" .. idx)
      roleItem:FindDirect("Label_NameFriendList_" .. idx):GetComponent("UILabel").text = self.roles[i].roleName
      roleItem:FindDirect("Img_SchoolFriendList_" .. idx):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(self.roles[i].occupationId)
      roleItem:FindDirect("Label_LvFriendList_" .. idx):GetComponent("UILabel").text = self.roles[i].roleLevel .. textRes.Team[2]
      _G.SetAvatarIcon(roleItem:FindDirect("Img_HeadFriendList_" .. idx), self.roles[i].avatarId)
      local Img_AvatarFrame = roleItem:FindDirect("Img_AvatarFrame_" .. idx)
      _G.SetAvatarFrameIcon(Img_AvatarFrame, self.roles[i].avatarFrameId)
      local genderIcon = roleItem:FindDirect("Img_SexFriendList_" .. i)
      GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(self.roles[i].sex))
      idx = idx + 1
    end
  end
  self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Scroll View_FriendList"):GetComponent("UIScrollView"):ResetPosition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
return DlgTeamInvite.Commit()
