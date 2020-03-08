local Lplus = require("Lplus")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AtData = require("Main.Chat.At.data.AtData")
local AtUtils = require("Main.Chat.At.AtUtils")
local AtProtocols = require("Main.Chat.At.AtProtocols")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local AtMgr = Lplus.Class("AtMgr")
local def = AtMgr.define
local instance
def.static("=>", AtMgr).Instance = function()
  if instance == nil then
    instance = AtMgr()
  end
  return instance
end
def.field("string")._atPackRoleName = ""
def.const("number").CLICK_PACK_WAIT_DURATION = 1.5
def.field("number")._clickPackTimerId = 0
def.field("userdata")._longPressRoleId = nil
def.field("userdata")._parentObj = nil
def.const("number").LONG_PRESS_WAIT_DURATION = 1.5
def.field("number")._longPressTimerId = 0
local EFFECT_DURATION = 3
def.field("userdata")._atEffect = nil
def.field("number")._effectTimerID = 0
def.method().Init = function(self)
  AtData.Instance():Init()
  AtProtocols.RegisterProtocols()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AtMgr._OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, AtMgr._OnRoleLogin)
  Event.RegisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_LeaveGroup, AtMgr._OnLeaveGroup)
  Event.RegisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, AtMgr._OnGroupInit)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, AtMgr._OnGangChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, AtMgr._OnTeamChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, AtMgr._OnTeamChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, AtMgr._OnTeamChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_TEAM_DISMISS, AtMgr._OnTeamChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, AtMgr._OnTeamChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.SYNC_TEAM_INFO, AtMgr._OnTeamChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AtMgr._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_BOX_BTN_CLICKED, AtMgr._OnAtBoxBtnClicked)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, AtMgr.OnClickMapFindpath)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AT) then
    result = false
    if bToast then
      Toast(textRes.Chat.At.FEATRUE_IDIP_NOT_OPEN)
    end
  end
  return result
end
def.method("=>", "boolean").NeedGroupReddot = function(self)
  return self:IsOpen(false) and AtData.Instance():GetGroupAtMsgCount() > 0
end
def.method("=>", "boolean").NeedChatReddot = function(self)
  return self:IsOpen(false) and AtData.Instance():GetChatAtMsgCount() > 0
end
def.method("=>", "boolean").CanOpenChatAtInput = function(self)
  local result = false
  if not _G.IsCrossingServer() then
    local channelType = AtUtils.GetCurrentChannel()
    result = AtUtils.CanChannelSendReceiveAt(channelType)
  end
  return result
end
def.method("number", "table", "table", "=>", "boolean").CheckMsgAtMe = function(self, channel, chatContent, msgData)
  local result, orgId = AtUtils.IsRawMsgAtMe(channel, chatContent, msgData)
  if result and orgId then
    AtData.Instance():AddAtMsg(channel, orgId, msgData, true)
  end
  return result
end
def.static("table", "table")._OnLeaveWorld = function(param, context)
  AtMgr.Instance():_CancelWaitClickPack()
  AtMgr.Instance():_CancelWaitLongPress()
  AtData.Instance():OnLeaveWorld()
end
def.static("table", "table")._OnRoleLogin = function(param, context)
  AtData.Instance():LoadAtMsgRecords()
end
def.static("table", "table")._OnFunctionOpenChange = function(param, context)
  if param.feature ~= ModuleFunSwitchInfo.TYPE_AT or false == param.open then
  else
  end
end
def.static("table", "table")._OnAtBoxBtnClicked = function(param, context)
  if not AtMgr.Instance():IsOpen(true) then
    warn("[AtMgr:_OnAtBoxBtnClicked] featrue closed.")
    return
  end
  local AtBoxPanel = require("Main.Chat.At.ui.AtBoxPanel")
  AtBoxPanel.ShowPanel(nil)
end
def.static("table", "table")._OnLeaveGroup = function(param, context)
  local groupId = param and param.groupId or nil
  warn("[AtMgr:_OnLeaveGroup] leave groupId:", groupId and Int64.tostring(groupId))
  AtData.Instance():OnLeaveGroup(groupId)
end
def.static("table", "table")._OnGroupInit = function(param, context)
  warn("[AtMgr:_OnGroupInit] _OnGroupInit.")
  AtData.Instance():OnGroupInit()
end
def.static("table", "table")._OnTeamChange = function(param, context)
  warn("[AtMgr:_OnTeamChange] _OnTeamChange.")
  AtData.Instance():OnTeamChange()
end
def.static("table", "table")._OnGangChange = function(param, context)
  warn("[AtMgr:_OnGangChange] _OnGangChange.")
  AtData.Instance():OnGangChange()
end
def.static("table").OnSGetRoleInfoRes = function(p)
  local self = AtMgr.Instance()
  if self:_IsWaitingLongPress() and Int64.eq(self._longPressRoleId, p.roleInfo.roleId) then
    warn("[AtMgr:OnSGetRoleInfoRes] Add roleinfo Pack OnLongPress Role:", self._longPressRoleId and Int64.tostring(self._longPressRoleId))
    AtUtils.AddAtInfoPack(p.roleInfo)
    self:PlayAtEffect(self._parentObj)
    self:_CancelWaitLongPress()
  elseif self:_IsWaitingClickRolenamePack() and self._atPackRoleName == p.roleInfo.name then
    warn("[AtMgr:OnSGetRoleInfoRes] show role panel On click rolename pack:", self._atPackRoleName)
    p.roleInfo.bNeedAt = true
    FriendCommonDlgManager.ShowFriendCommonDlg(p.roleInfo, 154, 304)
    self:_CancelWaitClickPack()
  end
end
def.static("table").OnSGetRoleInfoByNameFail = function(p)
  local self = AtMgr.Instance()
  if self:_IsWaitingClickRolenamePack() then
    self:_CancelWaitClickPack()
    local SGetRoleInfoByNameFail = require("netio.protocol.mzm.gsp.role.SGetRoleInfoByNameFail")
    local errString
    if SGetRoleInfoByNameFail.NO_SUCH_ROLE == p.res then
      errString = textRes.Chat.At.NO_SUCH_ROLE
    else
      warn("[ERROR][AtMgr:OnSGetRoleInfoByNameFail] unhandled p.res:", p.res)
    end
    if errString then
      Toast(errString)
    end
  end
end
def.static("string").OnClickAtInfoPack = function(linkStr)
  local self = AtMgr.Instance()
  if not self:IsOpen(true) then
    warn("[ERROR][AtMgr:OnClickAtInfoPack] at featrue closed.")
    return
  end
  if _G.CheckCrossServerAndToast(textRes.Chat.At.CROSS_SERVER) then
    warn("[AtMgr:OnClickAtInfoPack] disable click at info pack when crossing server.")
    return
  end
  local strs = string.split(string.sub(linkStr, string.len(AtUtils.GetHTMLAtPrefix()) + 1), "_")
  local roleId = strs[3] and Int64.new(strs[3]) or nil
  if roleId then
    warn("[AtMgr:OnClickAtInfoPack] roleId:", Int64.tostring(roleId))
    local state = FriendCommonDlgManager.StateConst.OtherChat
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, state)
  else
    local rolename = string.sub(linkStr, string.len(AtUtils.GetHTMLAtPrefix()) + 1)
    local heroName = _G.GetHeroProp() and _G.GetHeroProp().name
    if rolename and rolename ~= heroName then
      warn("[AtMgr:OnClickAtInfoPack] rolename:", rolename)
      AtProtocols.SendCGetRoleInfoByNameReq(rolename)
      self:_StartWaitClickPack(rolename)
    else
      warn("[ERROR][AtMgr:OnClickAtInfoPack] invalid rolename for linkStr:", rolename)
    end
  end
end
def.method("string")._StartWaitClickPack = function(self, rolename)
  self:_CancelWaitClickPack()
  self._atPackRoleName = rolename
  self._clickPackTimerId = GameUtil.AddGlobalTimer(AtMgr.CLICK_PACK_WAIT_DURATION, true, function()
    self:_CancelWaitClickPack()
  end)
end
def.method()._CancelWaitClickPack = function(self)
  self._atPackRoleName = ""
  self:_ClearClickPackTimer()
end
def.method()._ClearClickPackTimer = function(self)
  if self._clickPackTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self._clickPackTimerId)
    self._clickPackTimerId = 0
  end
end
def.method("=>", "boolean")._IsWaitingClickRolenamePack = function(self)
  return self._atPackRoleName and "" ~= self._atPackRoleName and self._clickPackTimerId > 0
end
def.method("userdata", "userdata").OnLongPressRoleHead = function(self, clickObj, roleId)
  if not self:IsOpen(false) then
    warn("[ERROR][AtMgr:OnLongPressRoleHead] at featrue closed.")
    return
  end
  if nil == clickObj or nil == roleId then
    warn("[ERROR][AtMgr:OnLongPressRoleHead] nil==clickObj or nil==roleId:", clickObj, roleId)
    return
  end
  warn("[AtMgr:OnLongPressRoleHead] OnLongPress Role:", Int64.tostring(roleId), clickObj.name)
  if Int64.lt(roleId, 1) then
    warn("[AtMgr:OnLongPressRoleHead] can not @ zhouyixian.")
    return
  elseif not Int64.eq(_G.GetMyRoleID(), roleId) and (nil == self._longPressRoleId or not Int64.eq(self._longPressRoleId, roleId)) then
    self:_StartWaitLongPress(clickObj, roleId)
    AtProtocols.SendCGetRoleInfoByIdReq(roleId)
  end
end
def.method("userdata", "userdata")._StartWaitLongPress = function(self, clickObj, roleId)
  self:_CancelWaitLongPress()
  self._parentObj = clickObj
  self._longPressRoleId = roleId
  self._longPressTimerId = GameUtil.AddGlobalTimer(AtMgr.LONG_PRESS_WAIT_DURATION, true, function()
    self:_CancelWaitLongPress()
  end)
end
def.method()._CancelWaitLongPress = function(self)
  self._parentObj = nil
  self._longPressRoleId = nil
  self:_ClearLongPressTimer()
end
def.method()._ClearLongPressTimer = function(self)
  if self._longPressTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self._longPressTimerId)
    self._longPressTimerId = 0
  end
end
def.method("=>", "boolean")._IsWaitingLongPress = function(self)
  return nil ~= self._longPressRoleId and self._longPressTimerId > 0
end
def.method("userdata").PlayAtEffect = function(self, effectParent)
  if effectParent == nil then
    warn("[ERROR][AtMgr:PlayAtEffect] effectParent nil!")
    return
  end
  self:_ClearEffectTimer()
  self:_DestroyAtEffect()
  local effectId = AtUtils.GetAtEffectId()
  local effectCfg = GetEffectRes(effectId)
  if effectCfg then
    warn("[AtMgr:PlayAtEffect] effectId:", effectId)
    self._atEffect = require("Fx.GUIFxMan").Instance():PlayAsChild(effectParent, effectCfg.path, 0, 0, -1, false)
  else
    warn("[ERROR][AtMgr:PlayAtEffect] effectCfg nil for effectid:", effectId)
  end
  if self._atEffect then
    self._effectTimerID = GameUtil.AddGlobalTimer(EFFECT_DURATION, true, function()
      self:_DestroyAtEffect()
    end)
  end
end
def.method()._DestroyAtEffect = function(self)
  if self._atEffect then
    self._atEffect:Destroy()
    self._atEffect = nil
  end
end
def.method()._ClearEffectTimer = function(self)
  if self._effectTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._effectTimerID)
    self._effectTimerID = 0
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
AtMgr.Commit()
return AtMgr
