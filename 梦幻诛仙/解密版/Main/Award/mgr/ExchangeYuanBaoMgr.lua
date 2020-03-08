local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local ExchangeYuanBaoMgr = Lplus.Extend(AwardMgrBase, "ExchangeYuanBaoMgr")
local def = ExchangeYuanBaoMgr.define
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local AwardUtils = require("Main.Award.AwardUtils")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local instance
local G_bFeatureOpen = false
local G_actId = 0
local G_mapTimeStamp = {}
local G_bNodeClicked = false
def.static("=>", ExchangeYuanBaoMgr).Instance = function()
  if instance == nil then
    instance = ExchangeYuanBaoMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.axe.SAttendAxeActivityFail", ExchangeYuanBaoMgr.OnSAttendAxeActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.axe.SAttendAxeActivitySuccess", ExchangeYuanBaoMgr.OnSAttendAxeActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.axe.SSynAxeActivityInfo", ExchangeYuanBaoMgr.OnSSynAxeActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.axe.SUnlockAxeActivityFail", ExchangeYuanBaoMgr.OnSUnlockAxeActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseAxeItemFail", ExchangeYuanBaoMgr.OnSUseAxeItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseAxeItemSuccess", ExchangeYuanBaoMgr.OnSUseAxeItemSuccess)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ExchangeYuanBaoMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ExchangeYuanBaoMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, ExchangeYuanBaoMgr.OnHeroLvUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, ExchangeYuanBaoMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ExchangeYuanBaoMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ExchangeYuanBaoMgr.OnLeaveWorld)
end
def.static("boolean").SetTabNodeClicked = function(bClicked)
  G_bNodeClicked = bClicked
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:IsOpen() and not G_bNodeClicked
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.static("=>", "boolean").IsFeatureOpen = function()
  return G_bFeatureOpen
end
def.override("=>", "boolean").IsOpen = function(self)
  if not ExchangeYuanBaoMgr.IsFeatureOpen() then
    return false
  end
  local actCfg = ExchangeYuanBaoMgr.GetRequirements(G_actId)
  local activityInfo = ActivityInterface.Instance():GetActivityInfo(G_actId)
  local curSection = 1
  if activityInfo ~= nil then
    curSection = activityInfo.count + 1
  end
  local roleLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local nowSec = _G.GetServerTime()
  if nowSec >= actCfg.sdate_sec and nowSec <= actCfg.edate_sec and roleLv >= actCfg.minLv and curSection <= actCfg.limitCount then
    return true
  else
    return false
  end
end
def.static("number", "=>", "table").GetLvRequirement = function(actId)
  local actCfg = ActivityInterface.GetActivityCfgById(actId)
  local retData = {}
  retData.maxLv = actCfg.levelMax
  retData.minLv = actCfg.levelMin
  return retData
end
def.static("number", "=>", "table").GetRequirements = function(actId)
  local actCfg = ActivityInterface.GetActivityCfgById(actId)
  local retData = {}
  local timeLimitCfg = TimeCfgUtils.GetTimeLimitCommonCfg(actCfg.activityLimitTimeid)
  retData.sdate_sec = TimeCfgUtils.GetTimeSec(timeLimitCfg.startYear, timeLimitCfg.startMonth, timeLimitCfg.startDay, timeLimitCfg.startHour, timeLimitCfg.startMinute, 0)
  retData.edate_sec = TimeCfgUtils.GetTimeSec(timeLimitCfg.endYear, timeLimitCfg.endMonth, timeLimitCfg.endDay, timeLimitCfg.endHour, timeLimitCfg.endMinute, 0)
  retData.sYear = timeLimitCfg.startYear
  retData.sMonth = timeLimitCfg.startMonth
  retData.sDay = timeLimitCfg.startDay
  retData.sHour = timeLimitCfg.startHour
  retData.sMin = timeLimitCfg.startMinute
  retData.sSec = 0
  retData.eYear = timeLimitCfg.endYear
  retData.eMonth = timeLimitCfg.endMonth
  retData.eDay = timeLimitCfg.endDay
  retData.eHour = timeLimitCfg.endHour
  retData.eMin = timeLimitCfg.endMinute
  retData.eSec = 0
  retData.maxLv = actCfg.levelMax
  retData.minLv = actCfg.levelMin
  retData.limitCount = actCfg.limitCount
  return retData
end
def.static("=>", "number").GetCurActId = function()
  return G_actId
end
def.static("number", "=>", "number").GetTimeStampByActId = function(actId)
  return G_mapTimeStamp[actId] or 0
end
def.static("number", "number").SetTimeStampByActId = function(actId, timestamp)
  G_mapTimeStamp[actId] = timestamp
end
def.static("=>", "boolean").IsUseAxesFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_USE_AXE_ITEM)
  return bFeatureOpen
end
def.static("table", "table").OnFeatureInit = function(p, context)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local allActs = AwardUtils.GetAllAxeActs()
  for i = 1, #allActs do
    local actCfg = allActs[i]
    local bActOpen = featureOpenModule:CheckFeatureOpen(actCfg.moduleId)
    if bActOpen then
      G_bFeatureOpen = true
      G_actId = actCfg.actId
      return
    end
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local allActs = AwardUtils.GetAllAxeActs()
  if allActs == nil then
    return
  end
  for i = 1, #allActs do
    local actData = allActs[i]
    if p.feature == actData.moduleId then
      if p.open then
        G_bFeatureOpen = true
        G_actId = actData.actId
      else
        G_bFeatureOpen = false
      end
    end
  end
  ExchangeYuanBaoMgr.DispatchAwardNodeChange()
end
def.static("table", "table").OnHeroLvUp = function(p, context)
  if not G_bFeatureOpen then
    return
  end
  ExchangeYuanBaoMgr.DispatchAwardNodeChange()
end
def.static("table", "table").OnActivityStart = function(p, context)
  if not G_bFeatureOpen then
    return
  end
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local nowSec = _G.GetServerTime()
  local date = AbsoluteTimer.GetServerTimeTable(nowSec)
  if date.hour == 0 and date.min == 0 then
    ExchangeYuanBaoMgr.SetTabNodeClicked(false)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_TAB_NOTIFY_UPDATE, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(p, context)
  ExchangeYuanBaoMgr.SetTabNodeClicked(false)
  G_mapTimeStamp = {}
end
def.static().DispatchAwardNodeChange = function()
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NODE_OPEN_CHANGE, {
    nodeId = AwardPanel.NodeId.ExchangeYuanBao
  })
end
def.static("number").SendCAttendAxeActivityReq = function(actId)
  warn(">>>>Send CAttendAxeActivityReq actId = " .. actId .. "<<<<")
  local p = require("netio.protocol.mzm.gsp.axe.CAttendAxeActivityReq").new(actId)
  gmodule.network.sendProtocol(p)
end
def.static().SendCGetAxeActivityItemReq = function()
  warn(">>>>Send CGetAxeActivityItemReq<<<<")
  local p = require("netio.protocol.mzm.gsp.axe.CGetAxeActivityItemReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number").SendCUnlockAxeActivityReq = function(actId)
  warn(">>>>Send CUnlockAxeActivityReq actId = " .. actId .. "<<<<")
  local p = require("netio.protocol.mzm.gsp.axe.CUnlockAxeActivityReq").new(actId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").SendUseAxesReq = function(grid, num)
  warn(">>>>Send SendUseAxesReq<<<<")
  local p = require("netio.protocol.mzm.gsp.item.CUseAxeItemReq").new(grid, num)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAttendAxeActivityFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>YUAN_BAO_NUM_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>ITEM_NOT_ENOUGH<<<<")
  elseif p.res == 3 then
    warn(">>>>YUANBAO_NOT_ENOUGH<<<<")
  elseif p.res == 4 then
    warn(">>>>ADD_LOTTERY_FAIL<<<<")
  elseif p.res == 5 then
    warn(">>>>GRID_NOT_ENOUGH<<<<")
    Toast(textRes.Award.ExchangeYuanBao[12])
  elseif p.res == 6 then
    warn(">>>>ACTIVITY_IS_LOCKED<<<<")
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ATTEN_EXCHANGEYUANBAO_FAIL, p)
end
def.static("table").OnSAttendAxeActivitySuccess = function(p)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ATTEN_EXCHANGEYUANBAO_SUCCESS, p)
end
def.static("table").OnSSynAxeActivityInfo = function(p)
  for actId, timeSec in pairs(p.activity_infos) do
    G_mapTimeStamp[actId] = timeSec
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.UNLOCK_EXCHANGEYUANABO, nil)
end
def.static("table").OnSUnlockAxeActivityFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>YUAN_BAO_NUM_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == 2 then
    warn(">>>>ACTIVITY_IS_NOT_LOCKED<<<<")
  elseif p.res == 3 then
    warn(">>>>YUANBAO_NOT_ENOUGH<<<<")
  end
end
def.static("table").OnSUseAxeItemSuccess = function(p)
  warn("Use axe item success ")
end
def.static("table").OnSUseAxeItemFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<<")
  elseif p.res == 1 then
    warn(">>>>NOT_AXE_ITEM<<<<<")
  elseif p.res == 2 then
    warn(">>>>NUM_NOT_ENOUGH<<<<<")
  elseif p.res == 3 then
    warn(">>>>AWARD_FAIL<<<<<")
  end
end
return ExchangeYuanBaoMgr.Commit()
