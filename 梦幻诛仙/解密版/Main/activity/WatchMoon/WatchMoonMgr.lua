local Lplus = require("Lplus")
local WatchMoonMgr = Lplus.Class("WatchMoonMgr")
local def = WatchMoonMgr.define
local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local WatchMoonList = require("Main.activity.WatchMoon.ui.WatchMoonList")
local instance
def.static("=>", WatchMoonMgr).Instance = function()
  if instance == nil then
    instance = WatchMoonMgr()
  end
  return instance
end
def.field("boolean").isWatchingMoon = false
def.field("boolean").isWatchingMoonReconnect = false
def.field("userdata").watchMoonRoleId1 = nil
def.field("userdata").watchMoonRoleId2 = nil
def.field("number").watchMoonEndTime = 0
def.field("number").requestTimer = 0
def.field("number").requestTime = 0
def.field("table").myRefuseMap = nil
def.method().Init = function(self)
  self.myRefuseMap = {}
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SGetWatchCountRes", WatchMoonList.SGetWatchCountRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SQueryRoleModelInfoRes", WatchMoonList.SQueryRoleModelInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SInviteWatchmoonFailedRes", WatchMoonMgr.OnInviteFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SAgreeWatchmoonFailedRes", WatchMoonMgr.OnAgreeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SSendInviteSuccessRes", WatchMoonMgr.OnSendSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SWatchmoonInviteRes", WatchMoonMgr.OnReceiveRequest)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SInviteSuccessRes", WatchMoonMgr.OnWatchMoonStartMove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SSynWatchmoonTarget", WatchMoonMgr.OnWatchMoonReConnect)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SRefuseWatchmoonRes", WatchMoonMgr.OnWatchMoonRefuse)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SStartWatchmoonSuccessRes", WatchMoonMgr.OnWatchMoonStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SWatchmoonSuccessRes", WatchMoonMgr.OnWatchMoonFinish)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.watchmoon.SWatchmoonFailedRes", WatchMoonMgr.OnWatchMoonFail)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, WatchMoonMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, WatchMoonMgr.OnMainUIReady)
end
def.method().Reset = function(self)
  self.myRefuseMap = {}
  self.watchMoonRoleId1 = nil
  self.watchMoonRoleId2 = nil
  self.isWatchingMoon = false
  self.isWatchingMoonReconnect = false
  self.watchMoonEndTime = 0
  self:ClearTimer()
end
def.method().ClearTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.requestTimer)
  self.requestTimer = 0
  self.requestTime = 0
end
def.method().ShowWatchMoonList = function(self)
  local GangModule = require("Main.Gang.GangModule")
  if not GangModule.Instance():HasGang() then
    Toast(textRes.WatchMoon[14])
    return
  end
  local activityId = constant.CWatchmoonConsts.ACTIVITY_ID
  local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityId)
  local minLv = actCfg.levelMin
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local myLv = heroProp.level
  local myRoleId = heroProp.id
  if minLv <= myLv then
    local GangData = require("Main.Gang.data.GangData")
    local gangMember = GangData.Instance():GetMemberList()
    local myGender = heroProp.gender
    local manlist = {}
    local womanlist = {}
    for k, v in ipairs(gangMember) do
      if v.roleId ~= myRoleId and minLv <= v.level and v.offlineTime < 0 then
        local watchMoonPerson = {
          name = v.name,
          roleId = v.roleId,
          level = v.level
        }
        if v.gender == SGenderEnum.MALE then
          table.insert(manlist, watchMoonPerson)
        elseif v.gender == SGenderEnum.FEMALE then
          table.insert(womanlist, watchMoonPerson)
        end
      end
    end
    local mathHelper = require("Common.MathHelper")
    mathHelper.ShuffleTable(womanlist)
    mathHelper.ShuffleTable(manlist)
    if myGender == SGenderEnum.MALE then
      table.insertto(womanlist, manlist)
      WatchMoonList.ShowWatchMoonList(womanlist)
    elseif myGender == SGenderEnum.FEMALE then
      table.insertto(manlist, womanlist)
      WatchMoonList.ShowWatchMoonList(manlist)
    end
  else
    Toast(string.format(textRes.WatchMoon[22], minLv))
  end
end
def.method("userdata", "=>", "number").SendWatchMoonRequest = function(self, roleId)
  if self.requestTimer ~= 0 then
    local leftTime = self.requestTime + constant.CWatchmoonConsts.DEFAULT_REFUSE_TIME - GetServerTime()
    if not (leftTime >= 0) or not leftTime then
      leftTime = 0
    end
    Toast(string.format(textRes.WatchMoon[9], constant.CWatchmoonConsts.DEFAULT_REFUSE_TIME, leftTime))
    return -1
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() then
    Toast(textRes.WatchMoon[31])
    return -1
  end
  if PlayerIsInFight() then
    Toast(textRes.WatchMoon[32])
    return -1
  end
  local protectTime = constant.CWatchmoonConsts.INVITE_INTERVAL_COOL_TIME
  local refuseTime = self.myRefuseMap[roleId:tostring()] or 0
  local pastTime = GetServerTime() - refuseTime
  if protectTime <= pastTime then
    local p = require("netio.protocol.mzm.gsp.watchmoon.CWatchmoonInviteReq").new(roleId)
    gmodule.network.sendProtocol(p)
    self.myRefuseMap[roleId:tostring()] = nil
    return 0
  else
    Toast(string.format(textRes.WatchMoon[21], protectTime - pastTime))
    return 1
  end
end
def.method("=>", "boolean").IsWatchingMoon = function(self)
  return self.isWatchingMoon
end
def.method("userdata", "number", "userdata").sendWatchMoonChoice = function(self, roleId, choice, inviteTime)
  local p = require("netio.protocol.mzm.gsp.watchmoon.CAgreeOrRefuseReq").new(roleId, choice, inviteTime)
  gmodule.network.sendProtocol(p)
end
def.method().startWatchMoon = function(self)
  local p = require("netio.protocol.mzm.gsp.watchmoon.CStartWatchmoonReq").new()
  gmodule.network.sendProtocol(p)
end
def.method("boolean").enterWatchMoonMode = function(self, enter)
  if enter then
    require("GUI.ECGUIMan").Instance():ShowAllUI(false)
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    self.isWatchingMoon = true
  else
    require("GUI.ECGUIMan").Instance():ShowAllUI(true)
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    self.isWatchingMoon = false
  end
end
def.method("userdata", "string").TryAddFriend = function(self, roleId, roleName)
  if roleId ~= GetMyRoleID() then
    local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(roleId)
    if friendInfo == nil then
      local str = string.format(textRes.WatchMoon[16], roleName)
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.WatchMoon[15], str, textRes.WatchMoon[17], textRes.WatchMoon[18], 0, constant.CWatchmoonConsts.DEFAULT_REFUSE_TIME, function(select)
        if select == 1 then
          require("Main.friend.FriendModule").Instance():RequestAddFriendToServer(roleId)
        end
      end, nil)
    end
  end
end
def.static("table").OnSendSuccess = function(p)
  Toast(textRes.WatchMoon[1])
  local self = WatchMoonMgr.Instance()
  self.requestTime = GetServerTime()
  self.requestTimer = GameUtil.AddGlobalTimer(constant.CWatchmoonConsts.DEFAULT_REFUSE_TIME, true, function()
    Toast(textRes.WatchMoon[19])
    self.requestTimer = 0
    self.requestTime = 0
    WatchMoonList.Instance():SetInviteResult(p.roleid2, WatchMoonList.WatchMoonState.Overtime)
  end)
  WatchMoonList.Instance():SetInviteResult(p.roleid2, WatchMoonList.WatchMoonState.Inviting)
end
def.static("table").OnReceiveRequest = function(p)
  local otherName = p.name1
  local str = string.format(textRes.WatchMoon[2], otherName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.WatchMoon[3], str, textRes.WatchMoon[10], textRes.WatchMoon[11], 0, constant.CWatchmoonConsts.DEFAULT_REFUSE_TIME, function(select)
    if select == 1 then
      WatchMoonMgr.Instance():sendWatchMoonChoice(p.roleid1, 1, p.invitetime)
    elseif select == 0 then
      WatchMoonMgr.Instance():sendWatchMoonChoice(p.roleid1, 0, p.invitetime)
    end
  end, nil)
end
def.static("table").OnInviteFail = function(p)
  if p.errorRoleid == GetMyRoleID() then
    local tip = textRes.WatchMoon.SelfError[p.rescode]
    if tip then
      Toast(tip)
    end
    if WatchMoonList.Instance():IsAuto() then
      Toast(textRes.WatchMoon[29])
      WatchMoonList.Instance():StopAutoInvite()
    end
  else
    local tip = textRes.WatchMoon.OtherError[p.rescode]
    if tip then
      Toast(tip)
    end
    if WatchMoonList.Instance():IsAuto() then
      WatchMoonList.Instance():SetInviteResult(p.errorRoleid, WatchMoonList.WatchMoonState.Unvailable)
    end
  end
end
def.static("table").OnAgreeFail = function(p)
  if p.errorRoleid == GetMyRoleID() then
    local tip = textRes.WatchMoon.SelfError[p.rescode]
    if tip then
      Toast(tip)
    end
  else
    local tip = textRes.WatchMoon.OtherError[p.rescode]
    if tip then
      Toast(tip)
    end
  end
end
def.static("table").OnWatchMoonStartMove = function(p)
  WatchMoonMgr.Instance():ClearTimer()
  WatchMoonList.CloseWatchMoonList()
  instance.watchMoonRoleId1 = p.roleid1
  instance.watchMoonRoleId2 = p.roleid2
  warn("OnWatchMoonStartMove", instance.watchMoonRoleId1, instance.watchMoonRoleId2)
  instance:enterWatchMoonMode(true)
end
def.static("table").OnWatchMoonRefuse = function(p)
  local curTime = GetServerTime()
  local roleId = p.roleid2
  WatchMoonMgr.Instance().myRefuseMap[roleId:tostring()] = curTime
  local otherName = p.name2
  Toast(string.format(textRes.WatchMoon[4], otherName))
  WatchMoonMgr.Instance():ClearTimer()
  WatchMoonList.Instance():SetInviteResult(p.roleid2, WatchMoonList.WatchMoonState.Refuse)
end
def.static("table").OnWatchMoonStart = function(p)
  local CollectSliderPanel = require("GUI.CollectSliderPanel")
  CollectSliderPanel.ShowCollectSliderPanel(textRes.WatchMoon[5], constant.CWatchmoonConsts.STAY_TIME, function()
    Toast(textRes.WatchMoon[6])
  end, function(tag)
  end, nil)
  local effectPath = GetEffectRes(constant.CWatchmoonConsts.WATCHING_EFFECT1)
  require("Fx.GUIFxMan").Instance():Play(effectPath.path, "watchmoon", 0, 0, constant.CWatchmoonConsts.STAY_TIME + 1, false)
  effectPath = GetEffectRes(constant.CWatchmoonConsts.WATCHING_EFFECT2)
  require("Fx.GUIFxMan").Instance():Play(effectPath.path, "watchmoon", 0, 0, constant.CWatchmoonConsts.STAY_TIME + 1, false)
end
def.static("table").OnWatchMoonReConnect = function(p)
  warn("OnWatchMoonReConnect")
  instance.isWatchingMoonReconnect = true
  instance.watchMoonRoleId1 = GetMyRoleID()
  instance.watchMoonRoleId2 = p.partnerroleid
  instance.watchMoonEndTime = p.endTime:ToNumber()
end
def.static("table").OnWatchMoonFinish = function(p)
  Toast(textRes.WatchMoon[7])
  instance:enterWatchMoonMode(false)
  WatchMoonMgr.Instance():TryAddFriend(p.partnerRoleid, p.partnerName)
end
def.static("table").OnWatchMoonFail = function(p)
  Toast(textRes.WatchMoon[8])
  instance:enterWatchMoonMode(false)
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = constant.CWatchmoonConsts.ACTIVITY_ID
  if activityId == p1[1] then
    instance:ShowWatchMoonList()
  end
end
def.static("table", "table").OnMainUIReady = function()
  if instance.isWatchingMoonReconnect then
    instance:enterWatchMoonMode(true)
    if instance.watchMoonEndTime > 0 then
      local leftTime = instance.watchMoonEndTime - GetServerTime()
      if leftTime > 0 then
        local CollectSliderPanel = require("GUI.CollectSliderPanel")
        CollectSliderPanel.ShowCollectSliderPanel(textRes.WatchMoon[5], leftTime, function()
          Toast(textRes.WatchMoon[6])
        end, function(tag)
        end, nil)
        local effectPath = GetEffectRes(constant.CWatchmoonConsts.WATCHING_EFFECT1)
        require("Fx.GUIFxMan").Instance():Play(effectPath.path, "watchmoon", 0, 0, leftTime + 1, false)
        effectPath = GetEffectRes(constant.CWatchmoonConsts.WATCHING_EFFECT2)
        require("Fx.GUIFxMan").Instance():Play(effectPath.path, "watchmoon", 0, 0, leftTime + 1, false)
      end
    end
    instance.isWatchingMoonReconnect = false
  end
end
return WatchMoonMgr.Commit()
