local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CorpsInvite = Lplus.Extend(ECPanelBase, "CorpsInvite")
local GUIUtils = require("GUI.GUIUtils")
local def = CorpsInvite.define
def.field("function").onFilter = nil
def.field("function").onInvite = nil
def.field("table").roles = nil
def.static("function", "function").ShowInvite = function(filterFunc, inviteFunc)
  local dlg = CorpsInvite()
  dlg.onFilter = filterFunc
  dlg.onInvite = inviteFunc
  dlg:CreatePanel(RESPATH.DLG_TEAM_INVITE_UI_RES, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:HideOther()
  self:UpdateFriendList()
end
def.method().HideOther = function(self)
  self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Tap_Fiend"):SetActive(false)
  self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Tap_Around"):SetActive(false)
end
def.method().UpdateFriendList = function(self)
  local make_friend = function(role)
    return {
      roleId = role.roleId,
      roleName = role.roleName,
      roleLevel = role.roleLevel,
      occupationId = role.occupationId,
      gender = role.sex,
      avatarId = role.avatarId,
      avatarFrameId = role.avatarFrameId
    }
  end
  local roles = require("Main.friend.FriendModule").Instance():GetFriends()
  self.roles = {}
  local FriendConsts = require("netio.protocol.mzm.gsp.friend.FriendConsts")
  for i = 1, #roles do
    local role = roles[i]
    if self.onFilter then
      if self.onFilter(role.roleId, role.roleLevel, role.occupationId, role.onlineStatus == FriendConsts.STATUS_ONLINE) then
        table.insert(self.roles, make_friend(role))
      end
    else
      table.insert(self.roles, make_friend(role))
    end
  end
  local scroll = self.m_panel:FindDirect("Img_BgTeamIvite/Img_Bg02/Scroll View_FriendList")
  local roleList = scroll:FindDirect("List_FriendList")
  local uiList = roleList:GetComponent("UIList")
  uiList.itemCount = #self.roles
  uiList:Resize()
  local items = uiList:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local role = self.roles[i]
    self:FillFriend(uiGo, role, i)
    self.m_msgHandler:Touch(uiGo)
  end
  scroll:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "table", "number").FillFriend = function(self, uiGo, roleInfo, idx)
  uiGo:FindDirect("Label_NameFriendList_" .. idx):GetComponent("UILabel").text = roleInfo.roleName
  uiGo:FindDirect("Img_SchoolFriendList_" .. idx):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(roleInfo.occupationId)
  uiGo:FindDirect("Label_LvFriendList_" .. idx):GetComponent("UILabel").text = roleInfo.roleLevel .. textRes.Team[2]
  uiGo:FindDirect("Img_SexFriendList_" .. idx):GetComponent("UISprite").spriteName = GUIUtils.GetGenderSprite(roleInfo.gender)
  SetAvatarIcon(uiGo:FindDirect("Img_HeadFriendList_" .. idx), roleInfo.avatarId)
  SetAvatarFrameIcon(uiGo:FindDirect("Img_AvatarFrame_" .. idx), roleInfo.avatarFrameId)
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Refresh" then
    self:UpdateFriendList()
  elseif string.sub(id, 1, 21) == "Btn_InviteFriendList_" and self.onInvite then
    local index = tonumber(string.sub(id, 22))
    if index then
      local info = self.roles[index]
      if info then
        self.onInvite(info.roleId, info.roleLevel)
      end
    end
  end
end
return CorpsInvite.Commit()
