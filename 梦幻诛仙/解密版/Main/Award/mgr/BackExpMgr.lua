local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local BackExpMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = BackExpMgr.define
def.field("table").backExpInfo = nil
def.field("boolean").isCrossDay = false
local instance
def.static("=>", BackExpMgr).Instance = function()
  if instance == nil then
    instance = BackExpMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSynAllLostExpInfo", BackExpMgr.OnSSynAllLostExpInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSynSingleLostExpInfo", BackExpMgr.OnSSynSingleLostExpInfo)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, BackExpMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BackExpMgr.OnFunctionOpenChange)
end
def.method().Reset = function()
  instance.backExpInfo = {}
  instance.isCrossDay = false
end
def.override("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GAIN_LOST_EXP) then
    return false
  end
  local activityInterface = ActivityInterface.Instance()
  local activityId = constant.LostExpConst.activityid
  if activityInterface:isAchieveActivityLevel(activityId) then
    return ActivityInterface.Instance():isActivityOpend(activityId)
  end
  return false
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:GetNotifyMessageCount() > 0
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:IsOpen() and self.backExpInfo and not self:isInCollectTime() then
    local activityList = BackExpMgr.GetAllActivityLostExpCfg()
    local activityInterface = ActivityInterface.Instance()
    for i, v in pairs(activityList) do
      local info = self.backExpInfo[v.activityid]
      if info and info.alreadyGetExp == 0 and 0 < info.totalValue - info.alreadyGetValue then
        local activityInfo = activityInterface:GetActivityInfo(v.activityid)
        local count = 0
        if activityInfo then
          count = activityInfo.count
        end
        if count >= v.finishCount then
          return 1
        end
      end
    end
  end
  return 0
end
def.method("number", "=>", "boolean").canGetBackInfoAward = function(self, activityId)
  local info = self.backExpInfo[activityId]
  if info and info.alreadyGetExp == 0 and 0 < info.totalValue - info.alreadyGetValue then
    local activityInterface = ActivityInterface.Instance()
    local activityInfo = activityInterface:GetActivityInfo(activityId)
    local count = 0
    if activityInfo then
      count = activityInfo.count
    end
    local lostExpCfg = BackExpMgr.GetAcitvityLostExpCfg(activityId)
    if lostExpCfg and count >= lostExpCfg.finishCount then
      return true
    end
  end
  return false
end
def.static("=>", "table").GetAllActivityLostExpCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_LOST_EXP_CFG)
  if entries == nil then
    warn("--------GetAllActivityLostExpCfg is nil:", CFG_PATH.DATA_ACTIVITY_LOST_EXP_CFG)
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.activityid = record:GetIntValue("activityid")
    cfg.finishCount = record:GetIntValue("finishCount")
    cfg.sort = record:GetIntValue("sort")
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetAcitvityLostExpCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_LOST_EXP_CFG, activityId)
  if record == nil then
    warn("!!!!GetAcitvityLostExpCfg(" .. activityId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.activityid = record:GetIntValue("activityid")
  cfg.finishCount = record:GetIntValue("finishCount")
  cfg.sort = record:GetIntValue("sort")
  return cfg
end
def.static("table", "table").OnNewDay = function()
  if instance and instance:IsOpen() then
    instance.isCrossDay = true
    if not instance:isInCollectTime() then
      for i, v in pairs(instance.backExpInfo) do
        v.alreadyGetExp = 0
      end
      Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, {})
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local type_Lost_Exp = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GAIN_LOST_EXP
  if p1.feature == type_Lost_Exp and IsFeatureOpen(type_Lost_Exp) then
    local p = require("netio.protocol.mzm.gsp.award.CGetAllLostExpInfoReq").new()
    gmodule.network.sendProtocol(p)
  end
end
def.static("table").OnSSynAllLostExpInfo = function(p)
  warn("-------OnSSynAllLostExpInfo----")
  instance.backExpInfo = p.activityId2LostExpInfo
  instance.isCrossDay = false
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, {})
end
def.static("table").OnSSynSingleLostExpInfo = function(p)
  warn("--------OnSSynSingleLostExpInfo------")
  if instance.backExpInfo then
    instance.backExpInfo[p.activityId] = p.lostExpInfo
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, {})
  end
end
def.method("=>", "boolean").isNeedRefresh = function(self)
  return self.isCrossDay
end
def.method("=>", "boolean").isInCollectTime = function(self)
  local openTime, timeList, closeTime = ActivityInterface.Instance():getActivityStatusChangeTime(constant.LostExpConst.activityid)
  local curTime = GetServerTime()
  local intervalTime = constant.LostExpConst.collectExpInterval
  if openTime <= curTime and curTime < openTime + intervalTime * 24 * 3600 then
    return true
  end
  return false
end
def.method("number", "=>", "table").getBackExpInfo = function(self, activityId)
  if self.backExpInfo then
    return self.backExpInfo[activityId]
  end
  return nil
end
return BackExpMgr.Commit()
