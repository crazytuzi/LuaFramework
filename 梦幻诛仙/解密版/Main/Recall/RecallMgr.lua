local Lplus = require("Lplus")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local RecallData = require("Main.Recall.data.RecallData")
local EnterWorldAlertMgr = require("Main.Common.EnterWorldAlertMgr")
local RecallProtocols = require("Main.Recall.RecallProtocols")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local RecallMgr = Lplus.Class("RecallMgr")
local def = RecallMgr.define
local instance
def.static("=>", RecallMgr).Instance = function()
  if instance == nil then
    instance = RecallMgr()
  end
  return instance
end
local UPDATE_INTERVAL = 3600
def.field("number")._updateTimerID = 0
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, RecallMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, RecallMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, RecallMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, RecallMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, RecallMgr.OnNewDay)
  EnterWorldAlertMgr.Instance():Register(EnterWorldAlertMgr.CustomOrder.BindRecallFriend, RecallMgr.CheckShowBindRecallFriend, self)
  EnterWorldAlertMgr.Instance():Register(EnterWorldAlertMgr.CustomOrder.ReCallFriend, RecallMgr.CheckShowRecallRecommand, self)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, RecallMgr.OnClickMapFindpath)
end
def.static("table", "table").OnEnterWorld = function(param, context)
  local self = RecallMgr.Instance()
  self._updateTimerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
  RecallData.Instance():OnEnterWorld()
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  RecallMgr.Instance():_ClearUpdateTimer()
  RecallData.Instance():OnLeaveWorld()
end
def.static("table", "table").OnFeatureOpenInit = function(param, context)
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, nil)
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, nil)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_CROSS_SERVER_RECALL_FRIEND or param.feature == ModuleFunSwitchInfo.TYPE_RECALL_FRIEND_REBATE or param.feature == ModuleFunSwitchInfo.TYPE_RECALL_FRIEND_BIND then
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, nil)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, nil)
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
  RecallData.Instance():OnNewDay()
end
def.method()._Update = function(self)
  if require("Main.Recall.RecallModule").Instance():IsOpen(false) and RecallData.Instance():GetBindedFriendActiveCount() > 0 then
    RecallProtocols.SendCGetBindVitalityInfoReq()
  end
  if require("Main.Recall.RecallModule").Instance():IsRebateOpen(false) and 0 < RecallData.Instance():GetBindedRecalledFriendCount() then
    RecallProtocols.SendCGetRecallRebateInfoReq()
  end
end
def.method()._ClearUpdateTimer = function(self)
  if self._updateTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._updateTimerID)
    self._updateTimerID = 0
  end
end
def.method().CheckShowBindRecallFriend = function(self)
  if not require("Main.Recall.RecallModule").Instance():IsOpen(false) or not require("Main.Recall.RecallModule").Instance():IsBindActiveOpen(false) then
    EnterWorldAlertMgr.Instance():Next()
    return
  end
  if RecallData.Instance():IsFirstReturnLogin() and RecallData.Instance():CanBindRecallFriend() then
    warn("[RecallMgr:CheckShowBindRecallFriend] show BindPanel on EnterWorld.")
    require("Main.Recall.ui.BindPanel").ShowPanel()
  else
    EnterWorldAlertMgr.Instance():Next()
  end
end
def.method().CheckShowRecallRecommand = function(self)
  if not require("Main.Recall.RecallModule").Instance():IsOpen(false) then
    warn("[RecallMgr:CheckShowRecallRecommand] IDIP closed!")
    EnterWorldAlertMgr.Instance():Next()
    return
  end
  if not RecallMgr.Instance():HaveRecommandRecallToday() and not RecallData.Instance():ReachDayRecallLimit() and RecallData.Instance():HaveCanRecallAfkFriend() then
    RecallMgr.Instance():MarkRecommandRecallToday()
    require("Main.Recall.ui.RecommandPanel").Instance():ShowPanel()
  else
    EnterWorldAlertMgr.Instance():Next()
  end
end
local recallKeyPrefix = "RecallRecommand_"
def.static("=>", "string").GetRecallFriendsStorageKey = function()
  local serverTime = _G.GetServerTime()
  local key = recallKeyPrefix .. tonumber(os.date("%Y%m%d", serverTime))
  return key
end
def.method("=>", "boolean").HaveRecommandRecallToday = function(self)
  local storageKey = RecallMgr.GetRecallFriendsStorageKey()
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    warn("[RecallMgr:HaveRecommandRecallToday] already recommand today, key:", storageKey)
    return true
  end
  return false
end
def.method().MarkRecommandRecallToday = function(self)
  local storageKey = RecallMgr.GetRecallFriendsStorageKey()
  LuaPlayerPrefs.SetRoleString(storageKey, "1")
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
RecallMgr.Commit()
return RecallMgr
