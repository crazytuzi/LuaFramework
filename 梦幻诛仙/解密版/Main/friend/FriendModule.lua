local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local FriendData = require("Main.friend.FriendData")
local FriendMainDlg = require("Main.friend.ui.FriendMainDlg")
local FriendUtils = require("Main.friend.FriendUtils")
local FriendModule = Lplus.Extend(ModuleBase, "FriendModule")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local mailConsts = require("netio.protocol.mzm.gsp.mail.MailConsts")
local MailInfoPanel = require("Main.friend.ui.MailInfoPanel")
local SwornMgr = require("Main.Sworn.SwornMgr")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatMsgData = Lplus.ForwardDeclare("ChatMsgData")
local ShituData = require("Main.Shitu.ShituData")
local QingYuanMgr = require("Main.QingYuan.QingYuanMgr")
local def = FriendModule.define
local instance
def.field(FriendData)._data = nil
def.field("boolean")._bWaitToShow = false
def.field("boolean")._haveGrcFriend = false
def.static("=>", FriendModule).Instance = function()
  if nil == instance then
    instance = FriendModule()
    instance._data = FriendData.Instance()
    instance.m_moduleId = ModuleId.FRIEND
  end
  return instance
end
def.override().Init = function(self)
  Timer:RegisterListener(self.Update, self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendList", FriendModule.onSyncFriendList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendLevel", FriendModule.onSyncFriendLevel)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendAvatar", FriendModule.onSynFriendAvatar)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendOccupation", FriendModule.onSyncFriendOccupation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendAvatarFrame", FriendModule.onSSynFriendAvatarFrame)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendStatus", FriendModule.onSyncFriendStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendDelStatus", FriendModule.onSSynFriendDelStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SFindPlayerRes", FriendModule.onGetSearchResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SApplyFriendRes", FriendModule.onGetNewApplicant)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynApplyList", FriendModule.onSyncApplicants)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SFriendNormalResult", FriendModule.onCommonResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SAddNewFriendRes", FriendModule.onAddNewFriend)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SAgreeApplyRes", FriendModule.SAgreeApplyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SDisAgreeRes", FriendModule.SDisAgreeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SDelFriendRes", FriendModule.onDelFriend)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SUpdateRelationValue", FriendModule.onUpdateIntimacy)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendTeamMem", FriendModule.onUpdateFriendTeamMem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleInfoRes", FriendModule.onSetRoleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynFriendName", FriendModule.onSetFriendName)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SFriendNeedValidate", FriendModule.onSFriendNeedValidate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SRecomandFriend", FriendModule.OnSRecommendFriendList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSetFriendRemarkNameSuccess", FriendModule.OnSSetFriendRemarkNameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SMailInitData", FriendModule.onGetMailCatalog)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SReadMailRes", FriendModule.onGetMailInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SGetThingRes", FriendModule.onGetMailAttachment)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SNewMailRes", FriendModule.onGetNewMail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SDelMailRes", FriendModule.onDelMail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SAutoGetMailRes", FriendModule.onAutoGetMail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SAutoDeleteMailRes", FriendModule.onAutoDeleteMail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mail.SNormalResult", FriendModule.onWrongResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.blacklist.SBlacklistRes", FriendModule.onSBlacklistRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.blacklist.SAddBlackRoleRes", FriendModule.onSAddBlackRoleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.blacklist.SDelBlackRoleRes", FriendModule.onSDelBlackRoleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.blacklist.SBlacklistNormalResult", FriendModule.onSBlacklistNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSynRoleAddFriendRes", FriendModule.onSSynRoleAddFriendRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SSyncGRCFriends", FriendModule.onSSyncGRCFriends)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SWarnAddFriendAutoBan", FriendModule.onSWarnAddFriendAutoBan)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, FriendModule.OnUpdateFriendList)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_ADDFRIEND, FriendModule.OnAddFriendOrDeleteFriend)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, FriendModule.OnAnnouncementsChanged)
  Event.RegisterEvent(ModuleId.UPDATE_NOTICE, gmodule.notifyId.UpdateNotice.UPDATE_NOTICE_UPDATE, FriendModule.OnNewNotice)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.ShowShieldList, FriendModule.OnShowShieldList)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SOCIAL_CLICK, FriendModule._onShow)
  require("Main.friend.FriendAddLimitMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  local data = self._data
  data:SetAllNull()
  FriendCommonDlgManager.Clear()
  self._haveGrcFriend = false
end
def.static("table", "table")._onShow = function(p1, p2)
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  if FriendData.Instance():HasNewMail() then
    SocialDlg.ShowSocialDlg(SocialDlg.NodeId.Mail)
  else
    SocialDlg.ShowSocialDlg(0)
  end
end
def.static("table", "table").OnAnnouncementsChanged = function(tbl, p2)
end
def.static("table", "table").OnUpdateFriendList = function(tbl, p2)
  local roleId = tbl.roleId
  local data = FriendModule.Instance()._data
  local msgNum = tbl.new
  if -1 == msgNum then
    data:MoveFriendFromWithToWithout(roleId)
  else
    data:MoveFriendFromWithoutToWith(roleId)
  end
  data:ReSortFriendShowList()
end
def.static("table", "table").OnShowShieldList = function(tbl, p2)
  require("Main.friend.ui.BlackListDlg").ShowBlockList()
end
def.static("table").onSyncFriendList = function(p)
  local i = 1
  local data = FriendModule.Instance()._data
  data._friends = {}
  data._friendsWithChat = {}
  data._friendsWithoutChat = {}
  data._allFriends = nil
  data._bHaveSpecial = false
  data.friendRoleIdToUIIndex = {}
  for i = 1, #p.friendList do
    data:AddFriend(p.friendList[i])
  end
  data:ReSortFriendShowList()
end
def.static("table").onSyncFriendLevel = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.roleLevel = p.level
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendLevelChanged, nil)
end
def.static("table").onSynFriendAvatar = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.avatarId = p.avatarId
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnAvatarChange, nil)
end
def.static("table").onSSynFriendAvatarFrame = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.avatarFrameId = p.avatarFrameId
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnAvatarChange, nil)
end
def.static("table").onSyncFriendOccupation = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.occupationId = p.occupationId
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnOccupationChange, nil)
end
def.static("table").onSyncFriendStatus = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.onlineStatus = p.status
  end
  data:ReSortFriendShowList()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendOnlineChanged, nil)
  if p.reason == p.NORMAL and friend ~= nil then
    if require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == friend.onlineStatus then
      local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
      if mateInfo and mateInfo.mateId == friend.roleId then
        local gender = require("Main.Hero.Interface").GetBasicHeroProp().gender
        Toast(string.format(textRes.Marriage[36], textRes.Marriage.SelfGender2MateAppellation[gender], friend.roleName))
        return
      end
      if QingYuanMgr.Instance():IsQingYuanRelationWithRole(friend.roleId) then
        Toast(string.format(textRes.QingYuan[24], friend.roleName))
        return
      end
      if SwornMgr.GetSwornMemberInfo(friend.roleId) then
        Toast(textRes.Sworn[72]:format(friend.roleName))
        return
      end
      if ShituData.Instance():IsShituRelationWithPlayer(friend.roleId) then
        if ShituData.Instance():IsMyMaster(friend.roleId) then
          Toast(string.format(textRes.Shitu[19], textRes.Shitu[21], friend.roleName))
        else
          Toast(string.format(textRes.Shitu[19], textRes.Shitu[22], friend.roleName))
        end
        return
      end
      Toast(string.format(textRes.Friend[45], friend.roleName))
    elseif require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_OFFLINE == friend.onlineStatus then
      local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
      if mateInfo and mateInfo.mateId == friend.roleId then
        local gender = require("Main.Hero.Interface").GetBasicHeroProp().gender
        Toast(string.format(textRes.Marriage[37], textRes.Marriage.SelfGender2MateAppellation[gender], friend.roleName))
        return
      end
      if QingYuanMgr.Instance():IsQingYuanRelationWithRole(friend.roleId) then
        Toast(string.format(textRes.QingYuan[25], friend.roleName))
        return
      end
      if SwornMgr.GetSwornMemberInfo(friend.roleId) then
        Toast(textRes.Sworn[73]:format(friend.roleName))
        return
      end
      if ShituData.Instance():IsShituRelationWithPlayer(friend.roleId) then
        if ShituData.Instance():IsMyMaster(friend.roleId) then
          Toast(string.format(textRes.Shitu[20], textRes.Shitu[21], friend.roleName))
        else
          Toast(string.format(textRes.Shitu[20], textRes.Shitu[22], friend.roleName))
        end
        return
      end
      Toast(string.format(textRes.Friend[46], friend.roleName))
    end
  end
end
def.static("table").onSSynFriendDelStatus = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.delStatus = p.status
  end
end
def.static("table").onGetSearchResult = function(p)
  local resultTable = {}
  local friend = {
    roleId = p.roleId,
    roleName = p.roleName,
    roleLevel = p.roleLevel,
    occupationId = p.occupationId,
    sex = p.sex,
    onlineStatus = p.onlineStatus,
    isRecommend = false,
    avatarId = p.avatarId,
    avatarFrameId = p.avatarFrameId,
    isOnline = true,
    isGrcFriend = false
  }
  table.insert(resultTable, friend)
  require("Main.friend.ui.SocialDlg").Instance():SetSearchFriend(resultTable)
end
def.static().UpdateFriendChange = function()
  local tbl = {
    FriendModule.Instance():GetAllFriendCount()
  }
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, tbl)
end
def.static().UpdateMailChange = function()
  local unRead = FriendData.Instance():GetUnReadMailsNum()
  local hasRead = require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead()
  if hasRead == false then
    unRead = unRead + 1
  end
  local tbl = {unRead}
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, tbl)
end
def.static("table").onSyncApplicants = function(p)
  local i = 1
  local data = FriendModule.Instance()._data
  data._applicants = {}
  for i = 1, #p.applyList do
    data:AddApplicant(p.applyList[i])
  end
  FriendModule.UpdateFriendChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, nil)
end
def.static("table").onGetNewApplicant = function(p)
  local data = FriendModule.Instance()._data
  data:AddApplicant(p.strangerInfo)
  FriendModule.UpdateFriendChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, nil)
end
def.static("table").onCommonResult = function(p)
  local tipStr = string.format(textRes.Friend.CommonResult[p.result], unpack(p.args))
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").onAddNewFriend = function(p)
  local data = FriendModule.Instance()._data
  data:AddFriend(p.friendInfo)
  data:ReSortFriendShowList()
  Toast(string.format(textRes.Friend[37], p.friendInfo.roleName))
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, {
    p.friendInfo.roleId
  })
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, nil)
end
def.static("table").onDelFriend = function(p)
  local data = FriendModule.Instance()._data
  ChatModule.Instance():ClearFriendNewCount(p.friendId)
  ChatMsgData.Instance():DeleteFriendMsg64(p.friendId)
  data:RemoveFriend(p.friendId)
  data:ReSortFriendShowList()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, nil)
end
def.static("table").SAgreeApplyRes = function(p)
  local data = FriendModule.Instance()._data
  data:RemoveApplicant(p.strangerId)
  FriendModule.UpdateFriendChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, nil)
end
def.static("table").SDisAgreeRes = function(p)
  local data = FriendModule.Instance()._data
  local applicantName = data:GetApplicantNameById(p.strangerId)
  data:RemoveApplicant(p.strangerId)
  FriendModule.UpdateFriendChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, nil)
  if p.strangerId and "" ~= applicantName then
    require("Main.friend.FriendAddLimitMgr").Instance():OnRefuseAddFriend(p.strangerId, applicantName)
  end
end
def.static("table").onUpdateIntimacy = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.relationValue = p.relationValue
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendIntimacyChanged, {
    roleId = p.friendId,
    relationValue = p.relationValue
  })
end
def.static("table").onUpdateFriendTeamMem = function(p)
  local data = FriendModule.Instance()._data
  local friend = data:GetFriendInfo(p.friendId)
  if friend ~= nil then
    friend.teamMemCount = p.teamMemCount
  end
end
def.static("table").onSetRoleInfo = function(p)
  FriendCommonDlgManager.SetRoleInfo(p.roleInfo)
end
def.static("table").onSetFriendName = function(p)
  local data = FriendModule.Instance()._data
  data:SetFriendName(p)
  data:ReSortFriendShowList()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, {
    roleId = p.friendId,
    roleName = p.name
  })
end
def.static("table").onSFriendNeedValidate = function(p)
  FriendMainDlg.ShowTestDlg(p.roleId, p.name)
end
def.static("table").OnSRecommendFriendList = function(p)
  local resultTable = {}
  local FriendConsts = require("netio.protocol.mzm.gsp.friend.FriendConsts")
  for k, v in ipairs(p.recomandFriends) do
    local friend = {
      roleId = v.roleId,
      roleName = v.roleName,
      roleLevel = v.roleLevel,
      occupationId = v.occupationId,
      sex = v.sex,
      onlineStatus = FriendConsts.STATUS_ONLINE,
      isRecommend = true,
      avatarId = v.avatarId,
      avatarFrameId = v.avatarFrameId,
      isOnline = v.isOnline ~= 0,
      isGrcFriend = v.isGrcFriend ~= 0
    }
    table.insert(resultTable, friend)
  end
  require("Main.friend.ui.SocialDlg").Instance():SetSearchFriend(resultTable)
end
def.static("table").OnSSetFriendRemarkNameSuccess = function(p)
  local data = FriendModule.Instance()._data
  local remarkName = GetStringFromOcts(p.remarkName) or ""
  data:SetFriendRemarkName(p.friendId, remarkName)
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, {
    roleId = p.friendId,
    remarkName = remarkName
  })
  Toast(textRes.Friend[79])
end
def.static("table").onSSynRoleAddFriendRes = function(p)
  local roleId = p.roleid
  local roleName = p.name
  if p.triggerType == p.TYPE_MASSWEDDING then
    local str = string.format(textRes.Friend[65], roleName)
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.Friend[66], str, textRes.WatchMoon[17], textRes.WatchMoon[18], 0, 30, function(select)
      if select == 1 then
        instance:RequestAddFriendToServer(roleId)
      end
    end, nil)
    if 0 < constant.CMassWeddingConsts.addFriendEffect then
      local effectPath = GetEffectRes(constant.CMassWeddingConsts.addFriendEffect)
      require("Fx.GUIFxMan").Instance():Play(effectPath.path, "newfriend", 0, 0, -1, false)
    end
  end
end
def.static("table").onSSyncGRCFriends = function(p)
  local self = FriendModule.Instance()
  self:SetGrcFriend(true)
end
def.static("table").onSWarnAddFriendAutoBan = function(p)
  require("GUI.CommonConfirmDlg").ShowCerternConfirm("", textRes.Friend[74], textRes.Friend[75], nil, nil)
end
def.method("=>", "boolean").HaveGrcFriend = function(self)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_RECOMMEND_QQ_WECHAT_FRIEND)
  if open then
    return self._haveGrcFriend
  else
    return false
  end
end
def.method("boolean").SetGrcFriend = function(self, value)
  local dispath = value ~= self._haveGrcFriend
  self._haveGrcFriend = value
  if dispath then
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_GrcFriendRecommend, nil)
  end
end
def.method().UpdateApplicantList = function(self)
  local data = FriendModule.Instance()._data
  local applicantList = data:GetApplicantList()
  local removeTbl = {}
  for i = 1, #applicantList do
    local remainTime = FriendUtils.ComputeRemainTime(FriendUtils.GetApplyTimeMax(), applicantList[i].applyTime)
    if -1 == remainTime then
      table.insert(removeTbl, applicantList[i].roleId)
    end
  end
  if #removeTbl > 0 then
    for k, v in pairs(removeTbl) do
      data:RemoveApplicant(v)
    end
    FriendModule.UpdateFriendChange()
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendApplyChanged, nil)
  end
end
def.method().UpdateMailList = function(self)
  local data = FriendModule.Instance()._data
  local mailList = data:GetMailCatalog()
  local bNeedRemove = false
  local removeTbl = {}
  for i = 1, #mailList do
    local maxTime = 0
    local delTime = FriendUtils.GetMailDelTime(mailList[i])
    if delTime > 0 then
      maxTime = (delTime - mailList[i].createTime) / 3600
    else
      maxTime = FriendUtils.GetStoreHourByType(mailList[i].mailType)
    end
    local remainTime = FriendUtils.ComputeRemainTime(maxTime, mailList[i].createTime)
    if -1 == remainTime then
      table.insert(removeTbl, {
        index = mailList[i].mailIndex,
        readState = mailList[i].readState
      })
      bNeedRemove = true
    end
  end
  if bNeedRemove then
    for k, v in pairs(removeTbl) do
      data:RemoveMail(v.index)
      if v.readState == mailConsts.MAIL_DATA_STATE_NOT_READ then
        data:UnReadMailsAddNum(-1)
      end
    end
    FriendModule.UpdateMailChange()
    Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailCountChange, nil)
  else
  end
end
def.method("number").Update = function(self, dt)
  self:UpdateApplicantList()
  self:UpdateMailList()
end
def.static("table", "table").OnAddFriendOrDeleteFriend = function(tbl, p2)
  FriendModule.AddFriendOrDeleteFriend(tbl[1], tbl[2])
end
def.static("userdata", "string").AddFriendOrDeleteFriend = function(roleId, roleName)
  FriendMainDlg.RequireToAddFriend(roleId, roleName)
end
def.static("userdata", "string").AddShield = function(roleId, roleName)
  FriendMainDlg.AddShield(roleId, roleName)
end
def.static("string").RemoveShield = function(shieldName)
  FriendMainDlg.RemoveShield(shieldName)
end
def.static("userdata").RemoveShieldById = function(shieldId)
  FriendMainDlg.RemoveShieldById(shieldId)
end
def.static("table").onGetMailCatalog = function(p)
  local data = FriendModule.Instance()._data
  data._mails = {}
  data._unReadMailsNum = 0
  local i = 1
  for i = 1, #p.mailDatas do
    data:AddMail(p.mailDatas[i])
  end
  data:SortMailsByTime()
  FriendModule.UpdateMailChange()
end
def.static("number").ReadMail = function(mailIndex)
  local data = FriendModule.Instance()._data
  local mail = data:GetMail(mailIndex)
  if mail.readState == mailConsts.MAIL_DATA_STATE_NOT_READ then
    data:UnReadMailsAddNum(-1)
  end
  data:SetRead(mail.mailIndex)
  MailInfoPanel.ShowMailInfo(mail.title, mail.content, mail.createTime, mail.itemList, mail.notItemList, mail.mailType, mail.mailIndex, mail.contentType)
  FriendModule.UpdateMailChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailReadStateChange, nil)
end
def.static("table").onGetMailInfo = function(p)
  local data = FriendModule.Instance()._data
  data:SetAttachments(p.mailIndex, p.itemList, p.notItemList)
  FriendModule.ReadMail(p.mailIndex)
end
def.static("table").onDelMail = function(p)
  local data = FriendModule.Instance()._data
  local nextmail = data:RemoveMail(p.mailIndex)
  if nil ~= nextmail then
    local SocialDlg = require("Main.friend.ui.SocialDlg")
    SocialDlg.Instance():ReadMail(nextmail.mailIndex)
  else
    MailInfoPanel.CloseMailInfo()
  end
  FriendModule.UpdateMailChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailCountChange, nil)
end
def.static("table").onGetMailAttachment = function(p)
  local data = FriendModule.Instance()._data
  data:AttachmentClaimed(p.mailIndex)
  MailInfoPanel.Instance():SucceedCollectMailThings(p.mailIndex)
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailReadStateChange, nil)
end
def.static("table").onAutoGetMail = function(p)
  local data = FriendModule.Instance()._data
  data:AutoAttachmentClaimed(p.mailIndexs)
  data:SetUnReadMailsNum(0)
  FriendModule.UpdateMailChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailReadStateChange, nil)
  for k, v in pairs(p.mailIndexs) do
    MailInfoPanel.Instance():SucceedCollectMailThings(v)
  end
end
def.static("table").onAutoDeleteMail = function(p)
  local data = FriendModule.Instance()._data
  data:DeleteAllMails(p.mailIndexs)
  data:SetUnReadMailsNum(0)
  MailInfoPanel.CloseMailInfo()
  FriendModule.UpdateMailChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailCountChange, nil)
end
def.static("table").onGetNewMail = function(p)
  local data = FriendModule.Instance()._data
  data:AddMail(p.mailData)
  data:SortMailsByTime()
  FriendModule.UpdateMailChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailCountChange, nil)
end
def.static("table").onWrongResult = function(p)
  local data = FriendModule.Instance()._data
  local SNormalResult = require("netio.protocol.mzm.gsp.mail.SNormalResult")
  if p.ret ~= SNormalResult.UNKNOW then
    local t = p.args[1]
    local ItemUtils = require("Main.Item.ItemUtils")
    if p.ret == SNormalResult.TOKEN_FULL then
      local cfg = ItemUtils.GetTokenCfg(t)
      if not cfg then
        return
      end
      Toast(cfg.name .. textRes.Mail.WrongResult[3])
    elseif p.ret == SNormalResult.MONEY_FULL then
      local t = p.args[1]
      local cfg = ItemUtils.GetMoneyCfg(t)
      if not cfg then
        return
      end
      Toast(cfg.name .. textRes.Mail.WrongResult[3])
    elseif textRes.Mail.WrongResult[p.ret] ~= nil then
      Toast(textRes.Mail.WrongResult[p.ret])
    end
  end
end
def.static("table", "table").OnNewNotice = function(params, tbl)
  FriendModule.UpdateMailChange()
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailReadStateChange, nil)
end
def.static("table").onSBlacklistRes = function(p)
  local i = 1
  local data = FriendModule.Instance()._data
  data._shields = {}
  for i = 1, #p.list do
    local info = {}
    info.roleId = p.list[i].roleid
    info.roleName = p.list[i].name
    info.roleLevel = p.list[i].level
    info.occupationId = p.list[i].menpai
    info.sex = p.list[i].gender
    info.onlineStatus = p.list[i].status
    info.avatarId = p.list[i].avatarid
    info.avatarFrameId = p.list[i].avatar_frame
    data:AddShield(info)
  end
end
def.static("table").onSAddBlackRoleRes = function(p)
  local data = FriendModule.Instance()._data
  local info = {}
  info.roleId = p.black_role.roleid
  info.roleName = p.black_role.name
  info.roleLevel = p.black_role.level
  info.occupationId = p.black_role.menpai
  info.sex = p.black_role.gender
  info.onlineStatus = p.black_role.status
  info.avatarId = p.black_role.avatarid
  info.avatarFrameId = p.black_role.avatar_frame
  data:AddShield(info)
  Toast(textRes.Friend[49])
end
def.static("table").onSDelBlackRoleRes = function(p)
  local data = FriendModule.Instance()._data
  data:RemoveShieldById(p.del_roleid)
  Toast(textRes.Friend[8])
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_SucceedShield, {
    p.del_roleid
  })
end
def.static("table").onSBlacklistNormalResult = function(p)
  if textRes.Friend.WrongResult[p.result] ~= nil then
    Toast(textRes.Friend.WrongResult[p.result])
  end
end
def.method("userdata", "=>", "table").GetFriendInfo = function(self, id)
  return self._data:GetFriendInfo(id)
end
def.method("userdata", "=>", "boolean").IsFriend = function(self, id)
  return self._data:GetFriendInfo(id) ~= nil
end
def.method("userdata", "=>", "boolean").IsInApplyList = function(self, roleId)
  return self._data:GetApplyFriendInfo(roleId) ~= nil
end
def.method("userdata", "=>", "boolean").IsFriendOnline = function(self, id)
  local friendInfo = self._data:GetFriendInfo(id)
  return friendInfo ~= nil and friendInfo.onlineStatus == require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE
end
def.method("=>", "number").GetAllFriendCount = function(self)
  local chatNum = ChatModule.Instance():GetChatNewCount(nil)
  local applicantNum = #self._data:GetApplicantList()
  local groupChatNum = ChatModule.Instance():GetGroupChatNewCount(nil)
  local newGroupNum = require("Main.Group.GroupModule").Instance():GetNewJoinGroupNum()
  local shituInteractNum = 0
  if require("Main.Shitu.interact.InteractMgr").Instance():NeedReddot() then
    shituInteractNum = 1
  end
  return chatNum + applicantNum + groupChatNum + newGroupNum + shituInteractNum
end
def.method("userdata", "=>", "boolean").IsInShieldList = function(self, id)
  return self._data:GetShieldInfo(id) ~= nil
end
def.method("userdata", "=>", "number").GetIntimacy = function(self, roleId)
  return self._data:GetFriendInfo(roleId).relationValue
end
def.method().ShowIntimacyDlg = function(self)
end
def.method().IsIntimacyUpToMax = function(self)
  return self._data:GetFriendInfo(roleId).relationValue >= FriendUtils.GetMaxQinMiDu()
end
def.method("=>", "table").GetFriends = function(self)
  return self._data:GetFriendList()
end
def.method("userdata", "boolean", "=>", "userdata", "string").GetPreviousOrNextFriendInfo = function(self, roleId, bIsPrevious)
  local allFriends = self._data:GetAllFriends()
  local returnId = -1
  local returnName = ""
  local index = -1
  local destIndex = -1
  if #allFriends == 0 then
    return returnId, returnName
  end
  for k, v in pairs(allFriends) do
    if v.roleId == roleId then
      index = k
    end
  end
  if bIsPrevious then
    destIndex = index - 1
  else
    destIndex = index + 1
  end
  if nil ~= allFriends[destIndex] then
    returnId = allFriends[destIndex].roleId
    returnName = allFriends[destIndex].roleName
  elseif roleId == allFriends[#allFriends].roleId and bIsPrevious == false then
    returnId = allFriends[1].roleId
    returnName = allFriends[1].roleName
  elseif roleId == allFriends[1].roleId and bIsPrevious == true then
    returnId = allFriends[#allFriends].roleId
    returnName = allFriends[#allFriends].roleName
  end
  return returnId, returnName
end
def.method("userdata", "=>", "boolean").SetTop = function(self, roleId)
  if self._data:GetIsHaveSpecial() then
    return false
  end
  local friendInfo = self._data:GetFriendInfo(roleId)
  self._data:RemoveFriend(roleId)
  self._data:AddFirst(friendInfo)
  self._data:ReSortFriendShowList()
  return true
end
def.method("userdata", "=>", "boolean").RemoveTop = function(self, roleId)
  if false == self._data:GetIsHaveSpecial() then
    return false
  end
  local friendInfo = self._data:GetFriendInfo(roleId)
  self._data:RemoveFirst(roleId)
  self._data:AddFriend(friendInfo)
  self._data:ReSortFriendShowList()
  return true
end
def.method().RequestRecommend = function(self)
  if CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.friend.CRecomandFriend").new()
  gmodule.network.sendProtocol(p)
end
def.method("userdata").AgreeFriendApply = function(self, agreeFriendId)
  if #self._data:GetFriendList() >= FriendUtils.GetMaxFriendNum() then
    Toast(textRes.Friend[7])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CAgreeApply").new(agreeFriendId))
end
def.method("userdata").RefuseFriendApply = function(self, refuseFriendId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CDisAgreeApply").new(refuseFriendId))
end
def.method("table").CReadMaill = function(self, mail)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CReadMailReq").new(mail.mailIndex))
end
def.method("userdata", "string").CRequestAddRoleToShield = function(self, roleId, roleName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local tag = {id = roleId}
  local callback = function(id, tag)
    if 1 == id then
      local shieldRoleId = tag.id
      if shieldRoleId ~= nil then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.blacklist.CAddBlackRoleReq").new(shieldRoleId))
      end
    end
  end
  CommonConfirmDlg.ShowConfirm(textRes.Friend[47], string.format(textRes.Friend[48], roleName), callback, tag)
end
def.method("userdata").RequestAddFriendToServer = function(self, friendId)
  if self:IsFriend(friendId) then
    Toast(textRes.Friend[64])
  elseif self:IsInApplyList(friendId) then
    Toast(textRes.Friend[63])
    return
  else
    if #self._data:GetFriendList() >= FriendUtils.GetMaxFriendNum() then
      Toast(textRes.Friend[7])
      return
    end
    local shieldInfo = self._data:GetShieldInfo(friendId)
    if shieldInfo ~= nil then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", textRes.Friend[51], function(select)
        if select == 1 then
          self:CAddFriend(friendId)
        end
      end, nil)
    else
      self:CAddFriend(friendId)
    end
  end
end
def.method("userdata").CAddFriend = function(self, roleId)
  if CheckCrossServerAndToast() then
    return
  end
  if #self._data:GetFriendList() >= FriendUtils.GetMaxFriendNum() then
    Toast(textRes.Friend[7])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CAddFriend").new(roleId))
end
def.method("userdata").CRemoveShield = function(self, roleId)
  if roleId ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.blacklist.CDelBlackRoleReq").new(roleId))
  end
end
def.method().LeadToSetting = function(self)
  local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ADD_FRIEND_LV)
  if setting.isEnabled then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Friend[55], string.format(textRes.Friend[9], FriendUtils.GetAddFriendLevel()), function(select)
    if select == 1 then
      require("Main.SystemSetting.ui.SystemSettingPanel").Instance():ShowPanelToSelection("SettingClass2", "Toggle_AddFriendLv")
    end
  end, nil)
end
def.method("userdata").ChangeRemark = function(self, friendId)
  local remarkNameOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FRIEND_REMARK_NAME)
  if not remarkNameOpen then
    Toast(textRes.Common[55])
    return
  end
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Friend[76], false, function(name, tag)
    remarkNameOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FRIEND_REMARK_NAME)
    if not remarkNameOpen then
      Toast(textRes.Common[55])
      return
    end
    local _, zh, en = Strlen(name)
    local len = zh * 0.5 + en
    local MAX = 6
    if len > MAX then
      Toast(string.format(textRes.Friend[78], MAX, MAX * 2))
      return true
    elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
      Toast(textRes.Friend[77])
      return true
    elseif not CheckCharSectionInString(name) then
      Toast(textRes.Friend[80])
      return true
    else
      local nameOctets = require("netio.Octets").rawFromString(name)
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.friend.CSetFriendRemarkNameReq").new(friendId, nameOctets))
      return false
    end
  end, self)
end
FriendModule.Commit()
return FriendModule
