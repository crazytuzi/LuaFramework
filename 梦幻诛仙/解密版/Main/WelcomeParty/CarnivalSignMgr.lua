local Lplus = require("Lplus")
local CarnivalSignMgr = Lplus.Class("CarnivalSignMgr")
local LimitTimeSignInMgr = require("Main.CustomActivity.LimitTimeSignInMgr")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = CarnivalSignMgr.define
local instance
def.static("=>", CarnivalSignMgr).Instance = function()
  if instance == nil then
    instance = CarnivalSignMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, CarnivalSignMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CarnivalSignMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, CarnivalSignMgr.OnLimitTimeSignInfoChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, CarnivalSignMgr.OnHeroLevelUp)
end
def.static("table", "table").OnNewDay = function(p1, p2)
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
    nodeId = NodeId.CarnivalSign
  })
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
    nodeId = NodeId.CarnivalSign
  })
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_BEGINNER_LOGIN_SIGN then
    local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
      nodeId = NodeId.CarnivalSign
    })
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
      nodeId = NodeId.CarnivalSign
    })
  end
end
def.static("table", "table").OnLimitTimeSignInfoChange = function(p1, p2)
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
    nodeId = NodeId.CarnivalSign
  })
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local cfg = CustomActivityInterface.GetBeginnerLoginSignCfg(activityId)
  local openLevel = cfg.openLevel
  if openLevel > p1.lastLevel and openLevel <= p1.level then
    local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
      nodeId = NodeId.CarnivalSign
    })
  end
end
def.method("=>", "boolean").isFinishAllSign = function(self)
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local info = LimitTimeSignInMgr.Instance():getLimitTimeSingInInfo(activityId)
  if info then
    local curSortId = info.sortid or 0
    local signCfgs = CustomActivityInterface.GetLimitTimeSingInCfgByActivityId(activityId)
    if signCfgs and curSortId >= #signCfgs then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").isOpenCarnivalSign = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_BEGINNER_LOGIN_SIGN) then
    return false
  end
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local cfg = CustomActivityInterface.GetBeginnerLoginSignCfg(activityId)
  if self:isFinishAllSign() then
    return false
  end
  local myLevel = _G.GetHeroProp().level
  if myLevel >= cfg.openLevel then
    local info = LimitTimeSignInMgr.Instance():getLimitTimeSingInInfo(activityId)
    local startTime = 0
    if info then
      startTime = info.start_time
    end
    if startTime > 0 then
      local startHour = os.date("%H", startTime)
      local startMin = os.date("%M", startTime)
      local startSec = os.date("%S", startTime)
      local zeroTime = startTime - startHour * 3600 - startMin * 60 - startSec
      local endTime = zeroTime + cfg.duration * 24 * 3600
      if endTime > _G.GetServerTime() then
        return true
      end
    end
  end
  return false
end
def.method("=>", "boolean").isHaveCarnivalSignAward = function(self)
  if self:isOpenCarnivalSign() then
    local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
    local info = LimitTimeSignInMgr.Instance():getLimitTimeSingInInfo(activityId)
    local curSortId = 0
    if info then
      curSortId = info.sortid
    end
    return self:canGetCarnivalSignAward(curSortId + 1)
  else
    return false
  end
end
def.method("=>", "number", "number").getCarnivalSignStartAndEndTime = function(self)
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local info = LimitTimeSignInMgr.Instance():getLimitTimeSingInInfo(activityId)
  local startTime = 0
  if info then
    local startTime = info.start_time
    local startHour = os.date("%H", startTime)
    local startMin = os.date("%M", startTime)
    local startSec = os.date("%S", startTime)
    local cfg = CustomActivityInterface.GetBeginnerLoginSignCfg(activityId)
    local zeroTime = startTime - startHour * 3600 - startMin * 60 - startSec
    local endTime = zeroTime + cfg.duration * 24 * 3600
    return startTime, endTime
  end
  return 0, 0
end
def.method("number", "=>", "boolean").canGetCarnivalSignAward = function(self, sortId)
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local info = LimitTimeSignInMgr.Instance():getLimitTimeSingInInfo(activityId)
  local curSortId = 0
  local lastSignTime = 0
  if info then
    curSortId = info.sortid
    lastSignTime = info.last_time
  end
  if sortId == curSortId + 1 then
    if lastSignTime == nil or lastSignTime == 0 then
      return true
    end
    local curTime = _G.GetServerTime()
    local lastTimeTable = AbsoluteTimer.GetServerTimeTable(lastSignTime)
    local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
    if lastTimeTable.year == curTimeTable.year and lastTimeTable.month == curTimeTable.month and lastTimeTable.day == curTimeTable.day then
      return false
    else
      local signCfgs = CustomActivityInterface.GetLimitTimeSingInCfgByActivityId(activityId)
      if signCfgs and sortId <= #signCfgs then
        return true
      end
    end
  else
    return false
  end
  return false
end
return CarnivalSignMgr.Commit()
