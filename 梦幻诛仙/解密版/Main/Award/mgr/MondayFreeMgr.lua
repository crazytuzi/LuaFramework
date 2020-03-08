local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local MondayFreeMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local ActivityInterface = require("Main.activity.ActivityInterface")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local def = MondayFreeMgr.define
local instance
def.field("userdata").sundayAwardTime = nil
def.field("userdata").mondayAwardTime = nil
def.field("userdata").finishShimenTime = nil
def.field("userdata").finishBaotuTime = nil
def.static("=>", MondayFreeMgr).Instance = function()
  if instance == nil then
    instance = MondayFreeMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mondayfree.SSyncMondayFree", MondayFreeMgr.OnSSyncMondayFree)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mondayfree.SGetSundayAwardRes", MondayFreeMgr.OnSGetSundayAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mondayfree.SFinishShimenRes", MondayFreeMgr.OnSFinishShimenRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mondayfree.SFinishBaotuRes", MondayFreeMgr.OnSFinishBaotuRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mondayfree.SGetMondayAwardRes", MondayFreeMgr.OnSGetMondayAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mondayfree.SMondayFreeNormalResult", MondayFreeMgr.OnSMondayFreeNormalResult)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MondayFreeMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MondayFreeMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, MondayFreeMgr.OnServeLvChange)
end
def.method().Reset = function(self)
  self.sundayAwardTime = nil
  self.mondayAwardTime = nil
  self.finishShimenTime = nil
  self.finishBaotuTime = nil
end
def.static("table", "table").OnNewDay = function(p1, p2)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local openId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MONDAY_FREE
  if p1.feature == openId then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
  end
end
def.static("table", "table").OnServeLvChange = function(p1, p2)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
end
def.static("table").OnSSyncMondayFree = function(p)
  warn("------OnSSyncMondayFree:", p.sunday_award_time, p.monday_award_time, p.finish_shimen_time, p.finish_baotu_time)
  instance.sundayAwardTime = p.sunday_award_time
  instance.mondayAwardTime = p.monday_award_time
  instance.finishShimenTime = p.finish_shimen_time
  instance.finishBaotuTime = p.finish_baotu_time
end
def.static("table").OnSGetSundayAwardRes = function(p)
  warn("-----OnSGetSundayAwardRes")
  instance.sundayAwardTime = Int64.new(_G.GetServerTime())
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
end
def.static("table").OnSFinishShimenRes = function(p)
  instance.finishShimenTime = Int64.new(_G.GetServerTime())
  local effres = _G.GetEffectRes(constant.CMondayFreeConsts.FinishShimenEffect)
  if effres then
    require("Fx.GUIFxMan").Instance():Play(effres.path, "mondayShimenEffect", 0, 0, -1, false)
  else
    warn("!!!!!!!!!invalid effectId:", constant.CMondayFreeConsts.FinishShimenEffect)
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
end
def.static("table").OnSFinishBaotuRes = function(p)
  instance.finishBaotuTime = Int64.new(_G.GetServerTime())
  local effres = _G.GetEffectRes(constant.CMondayFreeConsts.FinishBaotuEffect)
  if effres then
    require("Fx.GUIFxMan").Instance():Play(effres.path, "mondayBaotuEffect", 0, 0, -1, false)
  else
    warn("!!!!!!!!!invalid effectId:", constant.CMondayFreeConsts.FinishBaotuEffect)
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
end
def.static("table").OnSGetMondayAwardRes = function(p)
  instance.mondayAwardTime = Int64.new(_G.GetServerTime())
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, nil)
end
def.static("table").OnSMondayFreeNormalResult = function(p)
  warn("!!!!!OnSMondayFreeNormalResult:", p.result)
end
def.override("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MONDAY_FREE) then
    return false
  end
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  local serverLevel = serverLevelData.level
  if serverLevel < constant.CMondayFreeConsts.NeedServerLevel then
    return false
  end
  return true
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:GetNotifyMessageCount() > 0
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:IsOpen() and (self:canGetSundayAward() or self:canGetMondayAward()) then
    return 1
  end
  return 0
end
def.method("number", "=>", "boolean").isSameDate = function(self, timeSec)
  local curTime = _G.GetServerTime()
  local curYear = tonumber(os.date("%Y", curTime))
  local curMonth = tonumber(os.date("%m", curTime))
  local curDay = tonumber(os.date("%d", curTime))
  local lastYear = tonumber(os.date("%Y", timeSec))
  local lastMonth = tonumber(os.date("%m", timeSec))
  local lastDay = tonumber(os.date("%d", timeSec))
  if curYear == lastYear and curMonth == lastMonth and curDay == lastDay then
    return true
  end
  return false
end
def.method("number", "=>", "boolean").isInTime = function(self, cfgId)
  local durationCfg = TimeCfgUtils.GetTimeDurationCommonCfg(cfgId)
  if durationCfg then
    local curTime = _G.GetServerTime()
    local timeCommonCfg = durationCfg.timeCommonCfg
    if timeCommonCfg.activeWeekDay ~= 0 then
      local weekday = tonumber(os.date("%w", curTime))
      if weekday + 1 ~= timeCommonCfg.activeWeekDay then
        return false
      end
    end
    local curHour = tonumber(os.date("%H", curTime))
    local curMins = tonumber(os.date("%M", curTime))
    local curSec = tonumber(os.date("%S", curTime))
    local zeroTime = curTime - curHour * 3600 - curMins * 60 - curSec
    local activeTime = zeroTime + timeCommonCfg.activeHour * 3600 + timeCommonCfg.activeMinute * 60
    local endTime = activeTime + durationCfg.lastDay * 86400 + durationCfg.lastHour * 3600 + durationCfg.lastMinute * 60
    if curTime >= activeTime and curTime < endTime then
      return true
    end
    return false
  else
    warn("!!!!!!!!!durationCfg is nil:", cfgId)
  end
  return false
end
def.method("=>", "boolean").canGetSundayAward = function(self)
  if not self:isInTime(constant.CMondayFreeConsts.SundayTimeDurationCfgid) then
    return false
  end
  if self.sundayAwardTime == nil then
    return true
  end
  local lastAwardTime = self.sundayAwardTime:ToNumber()
  if lastAwardTime == 0 then
    return true
  end
  if self:isSameDate(lastAwardTime) then
    return false
  end
  return true
end
def.method("=>", "boolean").canGetMondayAward = function(self)
  if not self:isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
    return false
  end
  if self.mondayAwardTime == nil then
    return true
  end
  local lastAwardTime = self.mondayAwardTime:ToNumber()
  if lastAwardTime == 0 then
    return true
  end
  if self:isSameDate(lastAwardTime) then
    return false
  end
  return true
end
def.method("=>", "boolean").canDoShimen = function(self)
  if not self:isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
    return false
  end
  local shimenActivityId = constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID
  local activityInterface = ActivityInterface.Instance()
  if not activityInterface:isAchieveActivityLevel(shimenActivityId) then
    return false
  end
  if not activityInterface:isActivityOpend2(shimenActivityId) then
    return false
  end
  if activityInterface:isFinishActivity(shimenActivityId) then
    return false
  end
  if self.finishShimenTime == nil then
    return true
  end
  local lastTime = self.finishShimenTime:ToNumber()
  if lastTime == 0 then
    return true
  end
  if self:isSameDate(lastTime) then
    return false
  end
  return true
end
def.method("=>", "boolean").canDoBaotu = function(self)
  if not self:isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
    return false
  end
  local baotuActivityId = constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID
  local activityInterface = ActivityInterface.Instance()
  if not activityInterface:isAchieveActivityLevel(baotuActivityId) then
    return false
  end
  if not activityInterface:isActivityOpend2(baotuActivityId) then
    return false
  end
  if activityInterface:isFinishActivity(baotuActivityId) then
    return false
  end
  if self.finishBaotuTime == nil then
    return true
  end
  local lastTime = self.finishBaotuTime:ToNumber()
  if lastTime == 0 then
    return true
  end
  if self:isSameDate(lastTime) then
    return false
  end
  return true
end
def.method("=>", "boolean").isShowFinishShimen = function(self)
  if not self:isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
    return false
  end
  local shimenActivityId = constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID
  if ActivityInterface.Instance():isFinishActivity(shimenActivityId) then
    return true
  end
  return false
end
def.method("=>", "boolean").isShowFinsihBaotu = function(self)
  if not self:isInTime(constant.CMondayFreeConsts.MondayTimeDurationCfgid) then
    return false
  end
  local baotuActivityId = constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID
  if ActivityInterface.Instance():isFinishActivity(baotuActivityId) then
    return true
  end
  return false
end
return MondayFreeMgr.Commit()
