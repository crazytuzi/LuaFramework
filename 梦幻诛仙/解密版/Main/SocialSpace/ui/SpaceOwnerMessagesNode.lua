local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SpaceFriendsCircleNode = import(".SpaceFriendsCircleNode")
local SpaceOwnerMessagesNode = Lplus.Extend(SpaceFriendsCircleNode, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = SpaceOwnerMessagesNode.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local SocialSpaceProfileMan = require("Main.SocialSpace.SocialSpaceProfileMan")
local ECDebugOption = require("Main.ECDebugOption")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local ChatUtils = require("Main.Chat.ChatUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local SpaceInputCtrl = import(".SpaceInputCtrl")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local MsgRefreshState = SpaceFriendsCircleNode.MsgRefreshState
local MsgPubType = SpaceFriendsCircleNode.MsgPubType
def.override("=>", "boolean").IsOpen = function(self)
  return true
end
def.override().OnCreate = function(self)
  self.m_bOnlyShowSelf = true
  self.m_spaceMan = ECSocialSpaceMan.Instance()
  self:UpdateTabName()
end
def.override().OnShow = function(self)
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  if self.m_base.m_targetMsgId ~= Zero_Int64 then
    self:ShowMsgDetailById(self.m_base.m_targetMsgId)
  else
    self:CheckHasNewMsg()
  end
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.MsgPublished, self.OnMsgPublished, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.MsgPublished, self.OnMsgPublished)
  if self.m_msgInputCtrl then
    self.m_msgInputCtrl:Destroy()
    self.m_msgInputCtrl = nil
  end
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
  self:ShowPubMsgOptions(false)
end
def.override().InitUI = function(self)
  SpaceFriendsCircleNode.InitUI(self)
end
def.override("=>", "boolean").IsTitleCanSee = function(self)
  return self.m_base:IsMySpace()
end
def.override("userdata", "table").SetMessage = function(self, go, messageInfo)
  go.name = "message_" .. tostring(messageInfo.ID)
  local Group_Head = go:FindDirect("Group_Head")
  local Label_Info = Group_Head:FindDirect("Label_Info")
  local Group_Texture = Group_Head:FindDirect("Group_Texture")
  local Group_Name = Group_Head:FindDirect("Group_Name")
  local Label_Time = Group_Head:FindDirect("Label_Time")
  self:SetOwnerGroupName(Group_Name, messageInfo)
  self:SetPhotoMessage(Group_Texture, messageInfo)
  self:SetTextMessage(Label_Info, messageInfo.strRichMsg)
  self:SetCreateTime(Label_Time, messageInfo.timestamp)
  self:RepositionMessage(go, 2)
  local Group_Oper = go:FindDirect("Group_Oper")
  local Group_Like = go:FindDirect("Group_Like")
  local Group_Text = go:FindDirect("Group_Text")
  local Group_ShowAll = go:FindDirect("Group_ShowAll")
  self:SetGroupOper(Group_Oper, messageInfo)
  self:SetGroupLike(Group_Like, messageInfo)
  self:SetGroupReply(Group_Text, messageInfo)
  self:SetGroupShowAll(Group_ShowAll, messageInfo)
end
def.method("userdata", "table").SetOwnerGroupName = function(self, Group_Name, messageInfo)
  local Label_Name = Group_Name:FindDirect("Label_Name")
  local Img_Sex = Group_Name:FindDirect("Img_Sex")
  local Img_School = Group_Name:FindDirect("Img_School")
  local Img_Friend = Group_Name:FindDirect("Img_Friend")
  GUIUtils.SetText(Label_Name, messageInfo.playerName)
  GUIUtils.SetSprite(Img_Sex, "nil")
  GUIUtils.SetSprite(Img_School, "nil")
  SocialSpaceProfileMan.Instance():AsyncGetRoleProfile(messageInfo.roleId, function(profile)
    if not self:IsNodeShow() then
      return
    end
    GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(profile.gender))
    GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(profile.prof))
  end)
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = messageInfo.roleId
  })
end
def.method().UpdateTabName = function(self)
  local tabGO = self.m_base:GetTabGOByNodeId(self.nodeId)
  local Label_Tap = tabGO:FindDirect("Label_Tap")
  local myRoleId = _G.GetMyRoleID()
  if myRoleId == self.m_ownerId then
    GUIUtils.SetText(Label_Tap, textRes.SocialSpace[10])
  else
    local spaceBaseInfo = self.m_base.m_baseInfo
    if spaceBaseInfo.gender == GenderEnum.MALE then
      GUIUtils.SetText(Label_Tap, textRes.SocialSpace[11])
    else
      GUIUtils.SetText(Label_Tap, textRes.SocialSpace[12])
    end
  end
end
return SpaceOwnerMessagesNode.Commit()
