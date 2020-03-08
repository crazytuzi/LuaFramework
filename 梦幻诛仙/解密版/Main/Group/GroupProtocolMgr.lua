local Lplus = require("Lplus")
local GroupData = require("Main.Group.data.GroupData")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local GroupModule = Lplus.ForwardDeclare("GroupModule")
local GroupProtocolMgr = Lplus.Class("GroupProtocolMgr")
local def = GroupProtocolMgr.define
local waitingforbasicinfo = false
local waitingforsingleinfo = false
local waitingforToastInfo = {}
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SGetRoleGroupInfoSuccess", GroupProtocolMgr.OnSGetGroupBasicInfoSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SGetSingleGroupInfoSuccess", GroupProtocolMgr.OnSGetSingleGroupInfoSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SGetSingleGroupInfoFail", GroupProtocolMgr.OnSGetSingleGroupInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SCreateGroupSuccess", GroupProtocolMgr.OnSCreateGroupSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SCreateGroupFail", GroupProtocolMgr.OnSCreateGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SRenameGroupSuccessBrd", GroupProtocolMgr.OnSRenameGroupSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SRenameGroupFail", GroupProtocolMgr.OnSRenameGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SChangeGroupAnnouncementSuccessBrd", GroupProtocolMgr.OnSChangeGroupAnnouncementSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SChangeGroupAnnouncementFail", GroupProtocolMgr.OnSChangeGroupAnnouncementFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SQuitGroupSuccessBrd", GroupProtocolMgr.OnSQuitGroupSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SQuitGroupFail", GroupProtocolMgr.OnSQuitGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SKickGroupMemberSuccessBrd", GroupProtocolMgr.OnSKickGroupMemberSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SKickGroupMemberFail", GroupProtocolMgr.OnSKickGroupMemberFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SDissolveGroupSuccessBrd", GroupProtocolMgr.OnSDissolveGroupSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SDissolveGroupFail", GroupProtocolMgr.OnSDissolveGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SInviteJoinGroupSuccessBrd", GroupProtocolMgr.OnSInviteJoinGroupSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SJoinGroupNotify", GroupProtocolMgr.OnSJoinGroupNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SInviteJoinGroupFail", GroupProtocolMgr.OnSInviteJoinGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SSetMessageStateSuccess", GroupProtocolMgr.OnSSetMessageStateSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SSetMessageStateFail", GroupProtocolMgr.OnSSetMessageStateFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SMemberRenameBrd", GroupProtocolMgr.OnSMemberRename)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SMemberLevelUpBrd", GroupProtocolMgr.OnSMemberLevelUp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SMemberOnlineStateChangeBrd", GroupProtocolMgr.OnSMemberOnlineStateChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SSynRoleMessageState", GroupProtocolMgr.OnSSynRoleMessageState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SSynGroupJoinInfo", GroupProtocolMgr.OnSSynGroupJoinInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SSynGroupKickInfo", GroupProtocolMgr.OnSSynGroupKickInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.group.SSynGroupDissolveInfo", GroupProtocolMgr.OnSSynGroupDissolveInfo)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, GroupProtocolMgr.onMainUIReady)
end
def.static("=>", "boolean").CheckOpenGroupFeature = function()
  if _G.IsFeatureOpen(Feature.TYPE_GROUP) then
    return true
  else
    Toast(textRes.Group[30])
    return false
  end
end
def.static("table", "table").onMainUIReady = function(p1, p2)
  if waitingforToastInfo then
    for k, v in pairs(waitingforToastInfo) do
      Toast(v)
    end
    waitingforToastInfo = {}
  end
end
def.static("table").OnSSynRoleMessageState = function(p)
  warn("~~~~~~OnSSynRoleMessageState~~~~~~~")
  GroupData.Instance():SetGroupMessageStates(p.groupid2message_state)
end
def.static("table").OnSSynGroupJoinInfo = function(p)
  warn("~~~~~~~OnSSynGroupJoinInfo~~~~~~~~")
  for k, v in pairs(p.group_join_infos) do
    local groupName = GetStringFromOcts(v.group_name)
    local inviteName = GetStringFromOcts(v.inviter_name)
    local str = string.format(textRes.Group[22], inviteName, groupName)
    table.insert(waitingforToastInfo, str)
  end
end
def.static("table").OnSSynGroupKickInfo = function(p)
  warn("~~~~~~~OnSSynGroupKickInfo~~~~~~~")
  for k, v in pairs(p.group_kick_infos) do
    local groupName = GetStringFromOcts(v.group_name)
    local inviteName = GetStringFromOcts(v.master_name)
    local str = string.format(textRes.Group[20], groupName)
    table.insert(waitingforToastInfo, str)
  end
end
def.static("table").OnSSynGroupDissolveInfo = function(p)
  warn("~~~~~~OnSSynGroupDissolveInfo~~~~~~~")
  for k, v in pairs(p.group_dissolve_infos) do
    local dissolveGroupName = GetStringFromOcts(v)
    local str = string.format(textRes.Group[21], dissolveGroupName)
    table.insert(waitingforToastInfo, str)
  end
end
def.static("table").OnSGetGroupBasicInfoSuc = function(p)
  warn("~~~~~~OnSGetGroupBasicInfoSuc~~~~~", p)
  GroupData.Instance():SetBasicGroup(p.groupid2group_basic_info)
  local groups = {}
  for k, v in pairs(p.groupid2group_basic_info) do
    table.insert(groups, k)
  end
  if waitingforbasicinfo then
    Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, {groupIds = groups})
    waitingforbasicinfo = false
  end
end
def.static("table").OnSGetSingleGroupInfoSuc = function(p)
  warn("~~~~~OnSGetSingleGroupInfoSuc~~~~~", p, " ", p.group_info, " ", p.group_info.groupid)
  GroupData.Instance():SetSingleGroup(p.group_info)
  if waitingforsingleinfo then
    warn("dispath event ~~~~~~~~~~")
    Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Inited, {
      groupId = p.group_info.groupid
    })
    waitingforsingleinfo = false
  end
end
def.static("table").OnSGetSingleGroupInfoFail = function(p)
  warn("~~~~~~~OnSGetSingleGroupInfoFail~~~~~~~", p.res)
  local errMsg = textRes.Group.GetSingleGroupInfoError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSCreateGroupSuc = function(p)
  warn("~~~~~~~~~~OnSCreateGroupSuc~~~~~~~~~~~~", p)
  GroupData.Instance():AddGroup(p.group_info, true)
  local GroupMemberInfo = require("netio.protocol.mzm.gsp.group.GroupMemberInfo")
  GroupData.Instance():ChangeGroupMessageState(p.group_info.groupid, GroupMemberInfo.MSG_STATE_ACCEPT)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_JoinGroup, {
    groupId = p.group_info.groupid
  })
  Toast(string.format(textRes.Group[18], GetStringFromOcts(p.group_info.group_name)))
end
def.static("table").OnSCreateGroupFail = function(p)
  warn("~~~~~~~~OnSCreateGroupFail~~~~~~~~~~~", p.res)
  local errMsg = textRes.Group.CreatGroupError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSRenameGroupSuc = function(p)
  warn("~~~~~~~~~OnSRenameGroupSuc~~~~~~~~~~~~~", p)
  local newName = GetStringFromOcts(p.new_group_name)
  GroupData.Instance():ChangeGroupName(p.groupid, newName, p.info_version)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Name_Changed, {
    groupId = p.groupid
  })
  if GroupData.Instance():IsGroupMaster(p.groupid:tostring()) then
    Toast(textRes.Group[16])
  end
end
def.static("table").OnSRenameGroupFail = function(p)
  warn("~~~~~~~~~OnSRenameGroupFail~~~~~~~~~", p.res)
  local errMsg = textRes.Group.GroupRenameError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSChangeGroupAnnouncementSuc = function(p)
  warn("~~~~~OnSChangeGroupAnnouncementSuc~~~~~", p, GetStringFromOcts(p.announcement))
  local announcement = GetStringFromOcts(p.announcement)
  GroupData.Instance():ChangeGroupAnnounceMent(p.groupid, announcement, p.info_version)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_AnnounceMent_Changed, {
    groupId = p.groupid,
    newAnnounceMent = announcement
  })
  if GroupData.Instance():IsGroupMaster(p.groupid:tostring()) then
    Toast(textRes.Group[17])
  end
end
def.static("table").OnSChangeGroupAnnouncementFail = function(p)
  warn("~~~~~~~~OnSChangeGroupAnnouncementFail~~~~~~~~~", p.res)
  local errMsg = textRes.Group.ChangeAnnouceMentError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSQuitGroupSuc = function(p)
  warn("~~~~~~~~~OnSQuitGroupSuc~~~~~~~~~~~", p.groupid, p.memberid)
  local groupId = p.groupid
  local quitRoleId = p.memberid
  local newVersion = p.info_version
  local myHeroRoleId = GetMyRoleID()
  if myHeroRoleId:eq(quitRoleId) then
    local basicInfo = GroupData.Instance():GetGroupBasicInfo(groupId)
    if basicInfo then
      Toast(string.format(textRes.Group[19], basicInfo.groupName))
    end
    GroupModule.Instance():RemoveNewJoinGroup(groupId)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local ChatModule = require("Main.Chat.ChatModule")
    ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.GROUP, groupId)
    ChatModule.Instance():ClearGroupNewCount(groupId)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {groupId = groupId})
    local FriendModule = require("Main.friend.FriendModule")
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
      FriendModule.Instance():GetAllFriendCount()
    })
    GroupData.Instance():RemoveGroup(groupId)
    Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, {
      groupId = p.groupid
    })
  else
    local quitMemberInfo = GroupData.Instance():GetGroupMemberByRoleId(groupId, quitRoleId)
    if quitMemberInfo then
      GroupData.Instance():RemoveGroupMember(groupId, quitRoleId, newVersion)
      local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local ChatModule = require("Main.Chat.ChatModule")
      local SocialDlg = require("Main.friend.ui.SocialDlg")
      local quitRoleName = quitMemberInfo.roleName
      local content = string.format(textRes.Group[24], quitRoleName)
      local msg = ChatMsgBuilder.BuildNoteMsg64(ChatMsgData.MsgType.GROUP, groupId, content)
      ChatModule.Instance().msgData:AddMsg64(msg)
      SocialDlg.Instance():AddGroupMsg(msg)
      Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Quit, {
        groupId = p.groupid,
        quitRoleId = quitRoleId,
        quitRoleName = quitMemberInfo.roleName
      })
      Toast(string.format(textRes.Group[24], quitMemberInfo.roleName))
    end
  end
end
def.static("table").OnSQuitGroupFail = function(p)
  warn("~~~~~~~~OnSQuitGroupFail~~~~~~~~~", p.res)
  local errMsg = textRes.Group.QuitGroupError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSKickGroupMemberSuc = function(p)
  warn("~~~~~~~~OnSKickGroupMemberSuc~~~~~~~~", p)
  local groupId = p.groupid
  local kickRoleId = p.memberid
  local newVersion = p.info_version
  local myRoleId = GetMyRoleID()
  if myRoleId:eq(kickRoleId) then
    local basicInfo = GroupData.Instance():GetGroupBasicInfo(groupId)
    if basicInfo then
      Toast(string.format(textRes.Group[20], basicInfo.groupName))
    end
    GroupModule.Instance():RemoveNewJoinGroup(groupId)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local ChatModule = require("Main.Chat.ChatModule")
    ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.GROUP, groupId)
    ChatModule.Instance():ClearGroupNewCount(groupId)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {groupId = groupId})
    local FriendModule = require("Main.friend.FriendModule")
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
      FriendModule.Instance():GetAllFriendCount()
    })
    GroupData.Instance():RemoveGroup(groupId)
    Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, {
      groupId = p.groupid
    })
  else
    GroupData.Instance():RemoveGroupMember(groupId, kickRoleId, newVersion)
    Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Kick, {
      groupId = p.groupid,
      kickRoleId = kickRoleId
    })
    if GroupData.Instance():IsGroupMaster(groupId:tostring()) then
      Toast(textRes.Group[32])
    end
  end
end
def.static("table").OnSKickGroupMemberFail = function(p)
  warn("~~~~~~~OnSKickGroupMemberFail~~~~~~~~", p.res)
  local errMsg = textRes.Group.KickMemberError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSDissolveGroupSuc = function(p)
  warn("~~~~~~~~OnSDissolveGroupSuc~~~~~~~~~~", p)
  local dissolveGroupId = p.groupid
  if not GroupData.Instance():IsGroupExist(dissolveGroupId) then
    return
  end
  local basicInfo = GroupData.Instance():GetGroupBasicInfo(dissolveGroupId)
  if basicInfo then
    Toast(string.format(textRes.Group[21], basicInfo.groupName))
  end
  GroupModule.Instance():RemoveNewJoinGroup(dissolveGroupId)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local ChatModule = require("Main.Chat.ChatModule")
  ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.GROUP, dissolveGroupId)
  ChatModule.Instance():ClearGroupNewCount(dissolveGroupId)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {groupId = dissolveGroupId})
  local FriendModule = require("Main.friend.FriendModule")
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
    FriendModule.Instance():GetAllFriendCount()
  })
  GroupData.Instance():RemoveGroup(dissolveGroupId)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, {groupId = dissolveGroupId})
end
def.static("table").OnSDissolveGroupFail = function(p)
  warn("~~~~~~OnSDissolveGroupFail~~~~~~", p.res)
  local errMsg = textRes.Group.DissolveGroupError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSInviteJoinGroupSuc = function(p)
  warn("~~~~~~~~~OnSInviteJoinGroupSuc~~~~~~~~~~~", p)
  GroupData.Instance():AddGroupMember(p.groupid, p.newmember, p.info_version)
  local inviterInfo = GroupData.Instance():GetGroupMemberByRoleId(p.groupid, p.inviter)
  warn("invite success ", p.groupid, p.inviter, inviterInfo)
  if inviterInfo then
    local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local ChatModule = require("Main.Chat.ChatModule")
    local SocialDlg = require("Main.friend.ui.SocialDlg")
    local inviteRoleName = GetStringFromOcts(p.newmember.name)
    local toInviteRoleName = inviterInfo.roleName
    local content = string.format(textRes.Group[23], toInviteRoleName, inviteRoleName)
    local msg = ChatMsgBuilder.BuildNoteMsg64(ChatMsgData.MsgType.GROUP, p.groupid, content)
    ChatModule.Instance().msgData:AddMsg64(msg)
    SocialDlg.Instance():AddGroupMsg(msg)
    if p.inviter:eq(GetMyRoleID()) then
      Toast(string.format(textRes.Group[31], inviteRoleName))
    else
      Toast(string.format(textRes.Group[23], inviterInfo.roleName, inviteRoleName))
    end
    Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_Member_Invite, {
      groupId = p.groupid,
      inviteRoleId = p.newmember.roleid,
      inviteRoleName = inviteRoleName,
      toInviteRoleName = inviterInfo.roleName
    })
  end
end
def.static("table").OnSInviteJoinGroupFail = function(p)
  warn("~~~~~~~~OnSInviteJoinGroupFail~~~~~~~~~~", p.res)
  local errMsg = textRes.Group.InviteMemberError[p.res]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSJoinGroupNotify = function(p)
  warn("~~~~~~~~~OnSJoinGroupNotify~~~~~~~~~~", p)
  local invitorId = p.inviterid
  local invitorName = GetStringFromOcts(p.inviter_name)
  local basicGroupInfo = p.group_basic_info
  local groupName = GetStringFromOcts(basicGroupInfo.group_name)
  GroupData.Instance():AddGroup(basicGroupInfo, false)
  GroupModule.Instance():AddNewJoinGroup(basicGroupInfo.groupid)
  local GroupMemberInfo = require("netio.protocol.mzm.gsp.group.GroupMemberInfo")
  GroupData.Instance():ChangeGroupMessageState(basicGroupInfo.groupid, GroupMemberInfo.MSG_STATE_ACCEPT)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_JoinGroup, {
    groupId = basicGroupInfo.groupid
  })
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupUnreadCountChange, {
    groupId = basicGroupInfo.groupid
  })
  local FriendModule = require("Main.friend.FriendModule")
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
    FriendModule.Instance():GetAllFriendCount()
  })
  Toast(string.format(textRes.Group[22], invitorName, groupName))
end
def.static("table").OnSSetMessageStateSuc = function(p)
  warn("~~~~~~~~OnSSetMessageStateSuc~~~~~~~~~~~~", p)
  local groupId = p.groupid
  local state = p.message_state
  GroupData.Instance():ChangeGroupMessageState(groupId, state)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, {groupId = groupId})
end
def.static("table").OnSSetMessageStateFail = function(p)
  warn("~~~~~~~~OnSSetMessageStateFail~~~~~~~~", p.res)
end
def.static("table").OnSMemberRename = function(p)
  warn("~~~~~~~~~OnSMemberRename~~~~~~~~~")
  local newName = GetStringFromOcts(p.name)
  GroupData.Instance():ChangeMemberName(p.groupid, p.memberid, newName, p.info_version)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Changed, {
    groupId = p.groupid,
    roleId = p.memberid
  })
end
def.static("table").OnSMemberLevelUp = function(p)
  warn("~~~~~~~~~OnSMemberLevelUp~~~~~~~~~~")
  GroupData.Instance():ChangeMemberLevel(p.groupid, p.memberid, p.level, p.info_version)
  Event.DispatchEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_MemberInfo_Changed, {
    groupId = p.groupid,
    roleId = p.memberid
  })
end
def.static("table").OnSMemberOnlineStateChange = function(p)
  warn("~~~~~~~OnSMemberOnlineStateChange~~~~~~~")
  GroupData.Instance():ChangeMemberOnlineState(p.groupid, p.memberid, p.online_state, p.info_version)
end
def.static().CGroupBasicInfoReq = function()
  if not GroupProtocolMgr.CheckOpenGroupFeature() then
    return
  end
  local allGroup = GroupData.Instance():GetAllGroupInfo()
  if nil == allGroup then
    allGroup = {}
  end
  local id2version = {}
  for k, v in pairs(allGroup) do
    local basicInfo = v.basicInfo
    if basicInfo then
      id2version[basicInfo.groupId] = basicInfo.groupVersion
    end
  end
  local p = require("netio.protocol.mzm.gsp.group.CGetRoleGroupInfoReq").new(id2version)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "userdata").CSingleGroupInfoReq = function(groupId, groupVersion)
  if not GroupProtocolMgr.CheckOpenGroupFeature() then
    return
  end
  if nil == groupId then
    warn("groupId or groupVersion is nil ~~~ ", groupId, groupVersion)
    return
  end
  local p = require("netio.protocol.mzm.gsp.group.CGetSingleGroupInfoReq").new(groupId, Int64.new(-1))
  gmodule.network.sendProtocol(p)
end
def.static("number", "string").CCreateGroupReq = function(groupType, groupName)
  if not GroupProtocolMgr.CheckOpenGroupFeature() then
    return
  end
  local createName = require("netio.Octets").rawFromString(groupName)
  local p = require("netio.protocol.mzm.gsp.group.CCreateGroupReq").new(groupType, createName)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "table").CInviteJoinGroupReq = function(groupId, inviteRoleIds)
  local p = require("netio.protocol.mzm.gsp.group.CInviteJoinGroupReq").new(groupId, inviteRoleIds)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "string").CRenameGroupReq = function(groupId, newName)
  local rename = require("netio.Octets").rawFromString(newName)
  local p = require("netio.protocol.mzm.gsp.group.CRenameGroupReq").new(groupId, rename)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "string").CChangeAnnounceMentReq = function(groupId, announceMent)
  local newAnnounceMent = require("netio.Octets").rawFromString(announceMent)
  local p = require("netio.protocol.mzm.gsp.group.CChangeGroupAnnouncementReq").new(groupId, newAnnounceMent)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CQuitGroupReq = function(groupId)
  local p = require("netio.protocol.mzm.gsp.group.CQuitGroupReq").new(groupId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "userdata").CCkickGroupMemberReq = function(groupId, memberRoleId)
  local p = require("netio.protocol.mzm.gsp.group.CKickGroupMemberReq").new(groupId, memberRoleId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CDissolveGroupReq = function(groupId)
  local p = require("netio.protocol.mzm.gsp.group.CDissolveGroupReq").new(groupId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CSetMessageStateReq = function(groupId, state)
  local p = require("netio.protocol.mzm.gsp.group.CSetMessageStateReq").new(groupId, state)
  gmodule.network.sendProtocol(p)
end
def.static("boolean").SetWaitForBasicInfo = function(isWait)
  waitingforbasicinfo = isWait
end
def.static("boolean").SetWaitForSingleInfo = function(isWait)
  waitingforsingleinfo = isWait
end
GroupProtocolMgr.Commit()
return GroupProtocolMgr
