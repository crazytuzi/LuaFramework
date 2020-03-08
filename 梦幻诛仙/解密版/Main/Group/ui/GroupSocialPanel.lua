local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECLuaString = require("Utility.ECFilter")
local GroupModule = require("Main.Group.GroupModule")
local GroupUtils = require("Main.Group.GroupUtils")
local GroupProtocolMgr = require("Main.Group.GroupProtocolMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GroupSocialPanel = Lplus.Extend(ECPanelBase, "GroupSocialPanel")
local def = GroupSocialPanel.define
def.field("userdata").m_GroupId = nil
def.field("table").m_GroupMemberList = nil
def.field("table").m_GroupBasicInfo = nil
def.field("table").m_UIObjs = nil
local instance
def.static("=>", GroupSocialPanel).Instance = function()
  if nil == instance then
    instance = GroupSocialPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, groupId)
  if nil == groupId then
    return
  end
  if self:IsShow() then
    return
  end
  self.m_GroupId = groupId
  self:CreatePanel(RESPATH.PRAFAB_GROUP_INFO_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Changed, GroupSocialPanel.OnMemberInfoChanged, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Invite, GroupSocialPanel.OnMemberNumChanged, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, GroupSocialPanel.OnMemberNumChanged, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Quit, GroupSocialPanel.OnMemberNumChanged, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, GroupSocialPanel.OnGroupNameChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_AnnounceMent_Changed, GroupSocialPanel.OnAnnounceMentChange, self)
  Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, GroupSocialPanel.OnLeaveGroup, self)
  Event.RegisterEventWithContext(ModuleId.CHAT, gmodule.notifyId.Chat.NotifyToPrivateChatFromPub, GroupSocialPanel.OnNotify2PrivateChat, self)
  self:InitUI()
  self:UpdateData()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Changed, GroupSocialPanel.OnMemberInfoChanged)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Invite, GroupSocialPanel.OnMemberNumChanged)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, GroupSocialPanel.OnMemberNumChanged)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Quit, GroupSocialPanel.OnMemberNumChanged)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, GroupSocialPanel.OnGroupNameChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_AnnounceMent_Changed, GroupSocialPanel.OnAnnounceMentChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, GroupSocialPanel.OnLeaveGroup)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifyToPrivateChatFromPub, GroupSocialPanel.OnNotify2PrivateChat)
  self.m_GroupId = nil
  self.m_GroupMemberList = nil
  self.m_GroupBasicInfo = nil
  self.m_UIObjs = nil
end
def.method("table").OnNotify2PrivateChat = function(self, params)
  self:DestroyPanel()
end
def.method("table").OnLeaveGroup = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local groupId = params.groupId
  if nil == groupId then
    return
  end
  if not groupId:eq(self.m_GroupId) then
    return
  end
  self:DestroyPanel()
end
def.method("table").OnGroupNameChange = function(self, params)
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
  self:UpdateData()
  self:UpdateGroupName()
end
def.method("table").OnAnnounceMentChange = function(self, params)
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
  self:UpdateData()
  self:UpdateGroupAnnounceMent()
end
def.method("table").OnMemberNumChanged = function(self, params)
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
  self:UpdateData()
  self:UpdateLeftList()
  self:UpdateGroupNum()
end
def.method("userdata").UpdateChangedItem = function(self, changedRoleId)
  local index = 1
  local isFind = false
  for k, v in pairs(self.m_GroupMemberList) do
    if changedRoleId:eq(v.roleId) then
      index = k
      isFind = true
      break
    end
  end
  if false == isFind then
    return
  end
  local uiScrollList = self.m_UIObjs.LeftScrollList:GetComponent("UIScrollList")
  if nil == uiScrollList then
    return
  end
  local itemObj = ScrollList_getItem(uiScrollList, index)
  if nil == itemObj or itemObj.isnil then
    return
  end
  self:FillMemberItem(itemObj, index)
end
def.method("table").OnMemberInfoChanged = function(self, params)
  if nil == self.m_panel or self.m_panel.isnil then
    return
  end
  local groupId = params.groupId
  local changedRoleId = params.roleId
  if nil == groupId or nil == changedRoleId then
    return
  end
  if not self.m_GroupId:eq(groupId) then
    return
  end
  self:UpdateData()
  self:UpdateChangedItem(changedRoleId)
end
def.method().InitUI = function(self)
  self.m_UIObjs = {}
  self.m_UIObjs.GroupNameLabel = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Label_NameContent")
  self.m_UIObjs.GroupNameCancelBtn = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Btn_X")
  self.m_UIObjs.GroupNameModifyBtn = self.m_panel:FindDirect("Img_Bg/Group_Name/Btn_Modify")
  self.m_UIObjs.AnnounceLabel = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent/Label_TargetContent")
  self.m_UIObjs.AnnounceCancelBtn = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent/Btn_X")
  self.m_UIObjs.AnnounceModifyBtn = self.m_panel:FindDirect("Img_Bg/Group_Target/Btn_Modify")
  self.m_UIObjs.GroupMasterBtns = self.m_panel:FindDirect("Img_Bg/Group_LeaderBtn")
  self.m_UIObjs.GroupMemberBtns = self.m_panel:FindDirect("Img_Bg/Group_MemberBtn")
  self.m_UIObjs.LeftScrollList = self.m_panel:FindDirect("Img_Bg/Content_Group/Container/Scroll View_Friend/List_Group")
  self.m_UIObjs.GroupSetToggle = self.m_panel:FindDirect("Img_Bg/Group_Setting/Toggle_Off")
end
def.method().UpdateData = function(self)
  if nil == self.m_GroupId then
    return
  end
  self.m_GroupBasicInfo = GroupModule.Instance():GetGroupBasicInfo(self.m_GroupId)
  self.m_GroupMemberList = GroupModule.Instance():GetGroupMemberList(self.m_GroupId)
end
def.method().UpdateUI = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupBasicInfo then
    return
  end
  self:UpdateLeftList()
  self:UpdateGroupNum()
  self:UpdateGroupName()
  self:UpdateGroupAnnounceMent()
  self:UpdateSetting()
  self:UpdateGroupBtn()
end
def.method().UpdateGroupBtn = function(self)
  if nil == self.m_UIObjs then
    return
  end
  local isMaster = GroupModule.Instance():IsGroupMaster(self.m_GroupId)
  if isMaster then
    self.m_UIObjs.GroupMasterBtns:SetActive(true)
    self.m_UIObjs.GroupMemberBtns:SetActive(false)
  else
    self.m_UIObjs.GroupMasterBtns:SetActive(false)
    self.m_UIObjs.GroupMemberBtns:SetActive(true)
  end
end
def.method().UpdateSetting = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupBasicInfo then
    return
  end
  warn("~~~~~UpdateSetting~~~~~~~~")
  local uiToggle = self.m_UIObjs.GroupSetToggle:GetComponent("UIToggle")
  if uiToggle and not uiToggle.isnil then
    local groupshild = GroupModule.Instance():GetMessageShildState(self.m_GroupId)
    uiToggle.value = groupshild
  end
end
def.method().UpdateGroupNum = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupBasicInfo then
    return
  end
  local groupNumLabel = self.m_panel:FindDirect("Img_Bg/Content_Group/Label_GroupNum"):GetComponent("UILabel")
  groupNumLabel:set_text(self.m_GroupBasicInfo.memberNum)
end
def.method().UpdateGroupAnnounceMent = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupBasicInfo then
    return
  end
  warn("~~~~UpdateGroupAnnounceMent~~~~~~", self.m_GroupBasicInfo.announcement)
  local groupAnnounceMent = self.m_GroupBasicInfo.announcement
  local announceLabel = self.m_UIObjs.AnnounceLabel:GetComponent("UILabel")
  announceLabel:set_text(groupAnnounceMent)
  local isMaster = GroupModule.Instance():IsGroupMaster(self.m_GroupId)
  if isMaster then
    self.m_UIObjs.AnnounceModifyBtn:SetActive(true)
    self.m_UIObjs.AnnounceCancelBtn:SetActive(true)
    self.m_UIObjs.AnnounceLabel:GetComponent("BoxCollider").enabled = true
  else
    self.m_UIObjs.AnnounceModifyBtn:SetActive(false)
    self.m_UIObjs.AnnounceCancelBtn:SetActive(false)
    self.m_UIObjs.AnnounceLabel:GetComponent("BoxCollider").enabled = false
  end
end
def.method().UpdateGroupName = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupBasicInfo then
    return
  end
  warn("UpdateGroupName~~~~~~~~~")
  local curGroupName = self.m_GroupBasicInfo.groupName
  local nameLabel = self.m_UIObjs.GroupNameLabel:GetComponent("UILabel")
  nameLabel:set_text(curGroupName)
  local isMaster = GroupModule.Instance():IsGroupMaster(self.m_GroupId)
  if isMaster then
    self.m_UIObjs.GroupNameModifyBtn:SetActive(true)
    self.m_UIObjs.GroupNameCancelBtn:SetActive(true)
    self.m_UIObjs.GroupNameLabel:GetComponent("BoxCollider").enabled = true
  else
    self.m_UIObjs.GroupNameModifyBtn:SetActive(false)
    self.m_UIObjs.GroupNameCancelBtn:SetActive(false)
    self.m_UIObjs.GroupNameLabel:GetComponent("BoxCollider").enabled = false
  end
end
def.method().UpdateLeftList = function(self)
  if nil == self.m_UIObjs then
    return
  end
  if nil == self.m_GroupMemberList then
    return
  end
  warn("UpdateLeftList~~~~~~~~~~")
  local scrollListObj = self.m_UIObjs.LeftScrollList
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, index)
    self:FillMemberItem(item, index)
  end)
  ScrollList_setCount(uiScrollList, #self.m_GroupMemberList)
  self.m_msgHandler:Touch(scrollListObj)
end
def.method("userdata", "number").FillMemberItem = function(self, itemObj, index)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local memberInfo = self.m_GroupMemberList[index]
  _G.SetAvatarIcon(itemObj:FindDirect("Img_BgIconHead/Icon_User"), memberInfo.avatarId)
  _G.SetAvatarFrameIcon(itemObj:FindDirect("Img_BgIconHead"), memberInfo.avatarFrameId)
  local levelLabel = itemObj:FindDirect("Img_BgIconHead/Icon_User/Label_Lv"):GetComponent("UILabel")
  levelLabel:set_text(memberInfo.roleLevel)
  local nameLabel = itemObj:FindDirect("Label_MemberName"):GetComponent("UILabel")
  nameLabel:set_text(memberInfo.roleName)
  local occupationSprite = itemObj:FindDirect("Img_MenPai"):GetComponent("UISprite")
  local occupationSpriteName = string.format("%d-8", memberInfo.occupation)
  occupationSprite:set_spriteName(occupationSpriteName)
  local genderSprite = itemObj:FindDirect("Img_Sex"):GetComponent("UISprite")
  genderSprite:set_spriteName(GUIUtils.GetGenderSprite(memberInfo.gender))
  local kickBtn = itemObj:FindDirect("Btn_Delete")
  local isMaster = GroupModule.Instance():IsGroupMaster(self.m_GroupId)
  local myRoleId = GetMyRoleID()
  if isMaster and not myRoleId:eq(memberInfo.roleId) then
    kickBtn:SetActive(true)
  else
    kickBtn:SetActive(false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("onclickObj ~~~~~ ", id)
  if id ~= "Btn_X" and id ~= "Btn_Modify" and id ~= "Label_TargetContent" and id ~= "Label_NameContent" then
    self:CkeckNameAndAnnounceMent()
  end
  if "Btn_X" == id then
    self:OnClickCancelBtn(clickObj)
  elseif "Btn_Modify" == id then
    self:OnClickModifyBtn(clickObj)
  elseif "Toggle_Off" == id then
    self:OnClickSettingToggle()
  elseif "Btn_CancelGroup" == id then
    self:OnClickDissolveGroup()
  elseif "Btn_LeaderClear" == id or "Btn_MemberClear" == id then
    self:OnClickClearChatMgs()
  elseif "Btn_Leave" == id then
    self:OnClickLeaveGroup()
  elseif "Img_BgGroup" == id then
    self:OnClickMemberBtn(clickObj)
  elseif "Btn_Delete" == id then
    self:OnClickKickMember(clickObj)
  elseif "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Img_CreateGroup" == id then
    self:OnClickOpenInvitePanel()
  end
end
def.method().OnClickOpenInvitePanel = function(self)
  if nil == self.m_GroupId then
    return
  end
  local GroupInvitePanel = require("Main.Group.ui.GroupInvitePanel")
  GroupInvitePanel.Instance():ShowPanel(self.m_GroupId)
end
def.method("userdata").OnClickKickMember = function(self, clickObj)
  local itemObj, index = ScrollList_getItem(clickObj)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local memberInfo = self.m_GroupMemberList[index]
  if nil == memberInfo then
    return
  end
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Group[27], memberInfo.roleName), function(select, tag)
    if 1 == select then
      GroupProtocolMgr.CCkickGroupMemberReq(self.m_GroupId, memberInfo.roleId)
    end
  end, nil)
end
def.method("userdata").OnClickMemberBtn = function(self, clickObj)
  local itemObj, index = ScrollList_getItem(clickObj)
  if nil == itemObj or itemObj.isnil then
    return
  end
  local memberInfo = self.m_GroupMemberList[index]
  if nil == memberInfo then
    return
  end
  local myRoleId = GetMyRoleID()
  local memberId = memberInfo.roleId
  if not myRoleId:eq(memberId) then
    local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(memberId, FriendCommonDlgManager.StateConst.Null)
  end
end
def.method().OnClickLeaveGroup = function(self)
  if nil == self.m_GroupId then
    return
  end
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Group[25], self.m_GroupBasicInfo.groupName), function(select, tag)
    if 1 == select then
      GroupProtocolMgr.CQuitGroupReq(self.m_GroupId)
    end
  end, nil)
end
def.method().OnClickClearChatMgs = function(self)
  if nil == self.m_GroupId then
    return
  end
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  local groupId = SocialDlg.Instance():GetCurGroupId()
  if SocialDlg.Instance():IsShow() and groupId and self.m_GroupId:eq(groupId) then
    SocialDlg.Instance():ClearGroupMsg()
  else
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.GROUP, self.m_GroupId)
    ChatModule.Instance():ClearGroupNewCount(self.m_GroupId)
  end
  Toast(textRes.Group[33])
end
def.method().OnClickDissolveGroup = function(self)
  if nil == self.m_GroupId then
    return
  end
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Group[26], self.m_GroupBasicInfo.groupName), function(select, tag)
    if 1 == select then
      GroupProtocolMgr.CDissolveGroupReq(self.m_GroupId)
    end
  end, nil)
end
def.method().OnClickSettingToggle = function(self)
  local uiToggle = self.m_UIObjs.GroupSetToggle:GetComponent("UIToggle")
  local GroupMemberInfo = require("netio.protocol.mzm.gsp.group.GroupMemberInfo")
  local state = 0
  local toggleValue = uiToggle:get_value()
  if toggleValue then
    state = GroupMemberInfo.MSG_STATE_REFUSE
  else
    state = GroupMemberInfo.MSG_STATE_ACCEPT
  end
  GroupProtocolMgr.CSetMessageStateReq(self.m_GroupId, state)
end
def.method("userdata").OnClickCancelBtn = function(self, clickObj)
  local parentName = clickObj.parent.name
  if "Group_NameContent" == parentName then
    self.m_UIObjs.GroupNameLabel:GetComponent("UILabel"):set_text("")
  elseif "Group_TargetContent" == parentName then
    self.m_UIObjs.AnnounceLabel:GetComponent("UILabel"):set_text("")
  end
end
def.method("userdata").OnClickModifyBtn = function(self, clickObj)
  local parentName = clickObj.parent.name
  if "Group_Name" == parentName then
    local curName = self.m_UIObjs.GroupNameLabel:GetComponent("UILabel"):get_text()
    if not self:IsInvalidGroupName(curName) then
      return
    end
    GroupProtocolMgr.CRenameGroupReq(self.m_GroupId, curName)
  elseif "Group_Target" == parentName then
    local curAnnounce = self.m_UIObjs.AnnounceLabel:GetComponent("UILabel"):get_text()
    if not self:IsInvalidAnnounceMent(curAnnounce) then
      return
    end
    GroupProtocolMgr.CChangeAnnounceMentReq(self.m_GroupId, curAnnounce)
  end
end
def.method().CkeckNameAndAnnounceMent = function(self)
  warn("~~~~~~~~~~~CkeckNameAndAnnounceMent~~~~~~~~~~")
  local nameLabel = self.m_UIObjs.GroupNameLabel:GetComponent("UILabel")
  local announceLabel = self.m_UIObjs.AnnounceLabel:GetComponent("UILabel")
  local curName = nameLabel:get_text()
  local curAnnounce = announceLabel:get_text()
  if curName ~= self.m_GroupBasicInfo.groupName then
    nameLabel:set_text(self.m_GroupBasicInfo.groupName)
  end
  if curAnnounce ~= self.m_GroupBasicInfo.announcement then
    announceLabel:set_text(self.m_GroupBasicInfo.announcement)
  end
end
def.method("string", "=>", "boolean").IsInvalidGroupName = function(self, inputName)
  local len = ECLuaString.Len(inputName)
  local maxNameLen = GroupUtils.GetGroupMaxNameLength()
  if "" == inputName then
    Toast(textRes.Group[2])
    return false
  end
  if inputName == self.m_GroupBasicInfo.groupName then
    Toast(textRes.Group[8])
    return false
  end
  if len > maxNameLen then
    Toast(textRes.Group[3])
    return false
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(inputName) then
    Toast(textRes.Group[4])
    return false
  end
  return true
end
def.method("string", "=>", "boolean").IsInvalidAnnounceMent = function(self, inputName)
  local len = ECLuaString.Len(inputName)
  local maxAnnounceLen = GroupUtils.GetGroupMaxAnnounceLength()
  if "" == inputName then
    Toast(textRes.Group[7])
    return false
  end
  if inputName == self.m_GroupBasicInfo.announcement then
    Toast(textRes.Group[9])
    return false
  end
  if len > maxAnnounceLen then
    Toast(textRes.Group[3])
    return false
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(inputName) then
    Toast(textRes.Group[4])
    return false
  end
  return true
end
def.method("string").OnSubmitNewGroupName = function(self, inputName)
  local len = ECLuaString.Len(inputName)
  local maxNameLen = GroupUtils.GetGroupMaxNameLength()
  local nameLabel = self.m_UIObjs.GroupNameLabel:GetComponent("UILabel")
  if len > maxNameLen then
    Toast(textRes.Group[3])
    nameLabel:set_text("")
    return
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(inputName) then
    Toast(textRes.Group[4])
    nameLabel:set_text("")
    return
  end
  nameLabel:set_text(inputName)
end
def.method("string").OnSubmitNewAnnouncement = function(self, inputName)
  local len = ECLuaString.Len(inputName)
  local maxAnnounceLen = GroupUtils.GetGroupMaxAnnounceLength()
  local announceLabel = self.m_UIObjs.AnnounceLabel:GetComponent("UILabel")
  if len > maxAnnounceLen then
    Toast(textRes.Group[3])
    announceLabel:set_text("")
    return
  end
  if SensitiveWordsFilter.ContainsSensitiveWord(inputName) then
    Toast(textRes.Group[4])
    announceLabel:set_text("")
    return
  end
  announceLabel:set_text(inputName)
end
GroupSocialPanel.Commit()
return GroupSocialPanel
