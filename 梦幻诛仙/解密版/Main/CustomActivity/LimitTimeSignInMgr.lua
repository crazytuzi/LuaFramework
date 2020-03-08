local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local LimitTimeSignInMgr = Lplus.Class(CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local customActivityInterface = CustomActivityInterface.Instance()
local def = LimitTimeSignInMgr.define
local instance
def.field("number").curSortId = 0
def.field("number").lastSignTime = 0
def.field("table").LimitTimeSingInfos = nil
def.static("=>", LimitTimeSignInMgr).Instance = function()
  if instance == nil then
    instance = LimitTimeSignInMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SLoginSignActivityInfo", LimitTimeSignInMgr.OnSLoginSignActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SGetLoginSignAwardSuccess", LimitTimeSignInMgr.OnSGetLoginSignAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SGetLoginSignAwardFailed", LimitTimeSignInMgr.OnSGetLoginSignAwardFailed)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, LimitTimeSignInMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LimitTimeSignInMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, LimitTimeSignInMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, LimitTimeSignInMgr.OnActivityEnd)
end
def.static("table", "table").OnNewDay = function(p1, p2)
  customActivityInterface:calcLimitTimeSignInRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, {})
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance then
    instance.curSortId = 0
    instance.lastSignTime = 0
    instance.LimitTimeSingInfos = nil
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  local signActivityId = customActivityInterface:GetLimitTimeSingInActivityId()
  if activityId == signActivityId then
    customActivityInterface:calcLimitTimeSignInRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {activityId = activityId})
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  local signActivityId = customActivityInterface:GetLimitTimeSingInActivityId()
  if activityId == signActivityId then
    customActivityInterface:calcLimitTimeSignInRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {activityId = activityId})
  end
end
def.static("table").OnSLoginSignActivityInfo = function(p)
  instance.LimitTimeSingInfos = instance.LimitTimeSingInfos or {}
  local signActivityId = customActivityInterface:GetLimitTimeSingInActivityId()
  for i, v in pairs(p.activity_infos) do
    if signActivityId == i then
      instance.curSortId = v.sortid
      instance.lastSignTime = v.last_time
      customActivityInterface:calcLimitTimeSignInRedPoint()
    end
    instance.LimitTimeSingInfos[i] = v
  end
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, {})
end
def.static("table").OnSGetLoginSignAwardSuccess = function(p)
  local signActivityId = customActivityInterface:GetLimitTimeSingInActivityId()
  if signActivityId == p.activity_cfgid then
    instance.curSortId = p.sortid
    instance.lastSignTime = _G.GetServerTime()
    customActivityInterface:calcLimitTimeSignInRedPoint()
  end
  local info = instance.LimitTimeSingInfos and instance.LimitTimeSingInfos[p.activity_cfgid]
  if info then
    info.sortid = p.sortid
    info.last_time = _G.GetServerTime()
  end
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, {})
end
def.static("table").OnSGetLoginSignAwardFailed = function(p)
end
def.method("number", "=>", "boolean").canGetSignInAward = function(self, soriId)
  if soriId == self.curSortId + 1 then
    if self.lastSignTime == 0 then
      return true
    end
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local curTime = _G.GetServerTime()
    local lastTimeTable = AbsoluteTimer.GetServerTimeTable(self.lastSignTime)
    local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
    if lastTimeTable.year == curTimeTable.year and lastTimeTable.month == curTimeTable.month and lastTimeTable.day == curTimeTable.day then
      return false
    else
      return true
    end
  else
    return false
  end
end
def.method("number", "=>", "table").getLimitTimeSingInInfo = function(self, activityId)
  if self.LimitTimeSingInfos then
    return self.LimitTimeSingInfos[activityId]
  end
  return nil
end
return LimitTimeSignInMgr.Commit()
