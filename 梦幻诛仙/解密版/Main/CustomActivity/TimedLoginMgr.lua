local Lplus = require("Lplus")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local ItemUtils = require("Main.Item.ItemUtils")
local DATA_TIMED_DAILY_LOGIN_CFG = CFG_PATH.DATA_TIMED_DAILY_LOGIN_CFG
local DATA_TIMED_ACCUMULATIVE_LOGIN_CFG = CFG_PATH.DATA_TIMED_ACCUMULATIVE_LOGIN_CFG
local instance
local TimedLoginMgr = Lplus.Class("TimedLoginMgr")
local def = TimedLoginMgr.define
def.field("table").m_allActCfgs = nil
def.field("table").m_allActData = nil
def.field("table").m_actIds = nil
def.field("number").m_bannerId = 0
def.const("table").ACT_TYPE = {DAILY = 1, ACCUMULATIVE = 2}
def.const("table").ACT_ID_LIST = {
  [1] = {
    constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID,
    constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID_1,
    constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID_2,
    constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID_3,
    constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID_4,
    constant.CLoginAwardCfgConsts.LOGIN_ACTIVITY_CFG_ID_5
  },
  [2] = {
    constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID,
    constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID_1,
    constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID_2,
    constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID_3,
    constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID_4,
    constant.CLoginAwardCfgConsts.LOGIN_SUM_ACTIVITY_CFG_ID_5
  }
}
def.const("table").BANNER_ID_LIST = {
  constant.CLoginAwardCfgConsts.OPR_LOGIN_ACTIVITY_BANNER,
  constant.CLoginAwardCfgConsts.OPR_LOGIN_ACTIVITY_BANNER_1,
  constant.CLoginAwardCfgConsts.OPR_LOGIN_ACTIVITY_BANNER_2,
  constant.CLoginAwardCfgConsts.OPR_LOGIN_ACTIVITY_BANNER_3,
  constant.CLoginAwardCfgConsts.OPR_LOGIN_ACTIVITY_BANNER_4,
  constant.CLoginAwardCfgConsts.OPR_LOGIN_ACTIVITY_BANNER_5
}
def.const("table").AWARD_STATUS = {
  NONE = 0,
  EXPIRE = 1,
  ALREADY = 2,
  CAN = 3,
  UNFINISHED = 4
}
def.static("=>", TimedLoginMgr).Instance = function()
  if instance == nil then
    instance = TimedLoginMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.m_actIds = {
    [TimedLoginMgr.ACT_TYPE.DAILY] = 0,
    [TimedLoginMgr.ACT_TYPE.ACCUMULATIVE] = 0
  }
  self.m_allActData = {}
  for i = 1, 2 do
    self:InitAllCfgs(i)
  end
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TimedLoginMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, TimedLoginMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, TimedLoginMgr.OnActivityEnd)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, TimedLoginMgr.NewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TimedLoginMgr.OnFunctionOpenChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SLoginActivityInfos", TimedLoginMgr.OnSLoginActivityInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SGetLoginAwardSuccess", TimedLoginMgr.OnSGetLoginAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SGetLoginAwardFailed", TimedLoginMgr.OnSGetLoginAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SLoginSumActivityInfos", TimedLoginMgr.OnSLoginSumActivityInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SGetLoginSumAwardSuccess", TimedLoginMgr.OnSGetLoginSumAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.loginaward.SGetLoginSumAwardFailed", TimedLoginMgr.OnSGetLoginSumAwardFailed)
end
def.method("=>", "number").GetDefaultActType = function(self)
  local act_type = 0
  if self:IsOpen(TimedLoginMgr.ACT_TYPE.DAILY) and self:IsFeatureOpen(TimedLoginMgr.ACT_TYPE.DAILY) then
    act_type = TimedLoginMgr.ACT_TYPE.DAILY
  elseif self:IsOpen(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE) and self:IsFeatureOpen(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE) then
    act_type = TimedLoginMgr.ACT_TYPE.ACCUMULATIVE
  end
  return act_type
end
def.method("=>", "number").GetDynamicActId = function(self)
  local actId = self:GetActId(TimedLoginMgr.ACT_TYPE.DAILY)
  if not ActivityInterface.Instance():isActivityOpend(actId) then
    actId = self:GetActId(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE)
  end
  return actId
end
def.method("=>", "string").GetDynamicActName = function(self)
  local actId = self:GetDynamicActId()
  local actCfg = ActivityInterface.GetActivityCfgById(actId)
  if actCfg then
    return actCfg.activityName
  else
    return ""
  end
end
def.method("=>", "number").GetDynamicFeatureType = function(self)
  local featureType = Feature.TYPE_LOGIN_ACTIVITY
  local actId = self:GetActId(TimedLoginMgr.ACT_TYPE.DAILY)
  if not ActivityInterface.Instance():isActivityOpend(actId) then
    featureType = Feature.TYPE_LOGIN_SUM_ACTIVITY
  end
  return featureType
end
def.method("number", "=>", "boolean").IsFeatureOpen = function(self, act_type)
  local open = false
  if act_type == TimedLoginMgr.ACT_TYPE.DAILY then
    open = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_LOGIN_ACTIVITY)
  else
    open = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_LOGIN_SUM_ACTIVITY)
  end
  return open
end
def.method("=>", "number").GetBannerIconId = function(self)
  return self.m_bannerId
end
def.method("=>", "string").GetActTimeStr = function(self)
  local actId = self:GetDynamicActId()
  local activityCfg = ActivityInterface.GetActivityCfgById(actId)
  local timeStr = ""
  if activityCfg then
    timeStr = activityCfg.timeDes
  end
  return timeStr
end
def.method("number", "=>", "boolean").IsOpen = function(self, act_type)
  local actId = self:GetActId(act_type)
  return ActivityInterface.Instance():isActivityOpend(actId)
end
def.method("number", "=>", "number").GetActId = function(self, act_type)
  local res = 0
  local actId = self.m_actIds[act_type]
  if actId and actId > 0 and ActivityInterface.Instance():isActivityOpend(actId) then
    res = actId
  else
    local id_list = TimedLoginMgr.ACT_ID_LIST[act_type]
    for i = 1, #id_list do
      local id = id_list[i]
      if id > 0 and ActivityInterface.Instance():isActivityOpend(id) then
        res = id
        self.m_actIds[act_type] = res
        self.m_bannerId = TimedLoginMgr.BANNER_ID_LIST[i]
        break
      end
    end
  end
  return res
end
def.method("number", "=>", "string").GetDataCfgPath = function(self, act_type)
  local DATA_CFG
  if act_type == TimedLoginMgr.ACT_TYPE.DAILY then
    DATA_CFG = DATA_TIMED_DAILY_LOGIN_CFG
  else
    DATA_CFG = DATA_TIMED_ACCUMULATIVE_LOGIN_CFG
  end
  return DATA_CFG
end
def.method("number").InitAllCfgs = function(self, act_type)
  local cfgs = {}
  local DATA_CFG = self:GetDataCfgPath(act_type)
  local entries = DynamicData.GetTable(DATA_CFG)
  if entries == nil then
    warn("----TimedLoginMgr InitAllCfgs return empty : act_type, DATA_CFG", act_type, DATA_CFG)
    return
  else
    DynamicDataTable.FastGetRecordBegin(entries)
    local actId = self:GetActId(act_type)
    local recordCount = DynamicDataTable.GetRecordsCount(entries)
    for i = 1, recordCount do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      local cfg = self:_Parse(record)
      if not cfgs[cfg.activityCfgId] then
        cfgs[cfg.activityCfgId] = {}
      end
      cfgs[cfg.activityCfgId][cfg.sortId] = cfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  table.sort(cfgs, function(a, b)
    if not a or not b then
      return
    end
    return a.sortId < b.sortId
  end)
  if not self.m_allActCfgs then
    self.m_allActCfgs = {}
  end
  self.m_allActCfgs[act_type] = cfgs
end
def.method("number", "=>", "table").GetAllCfgs = function(self, act_type)
  local cfgs
  if self.m_allActCfgs and self.m_allActCfgs[act_type] then
    cfgs = self.m_allActCfgs[act_type][self:GetActId(act_type)]
  end
  return cfgs
end
def.method("number", "number", "=>", "table").GetCfgByIdx = function(self, act_type, idx)
  local cfg
  local cfgs = self:GetAllCfgs(act_type)
  if cfgs then
    cfg = cfgs[idx]
  end
  return cfg
end
def.method("number", "number", "=>", "string", "number", "table", "string").GetInfoByIdx = function(self, act_type, idx)
  local desc = ""
  local status = TimedLoginMgr.AWARD_STATUS.UNFINISHED
  local items = {}
  local prgs = ""
  local cfg = self:GetCfgByIdx(act_type, idx)
  if cfg then
    desc = cfg.detailedDesc
    items = self:_GetAwardItems(cfg.awardCfgId)
    status = self:GetStatusByIdx(act_type, idx)
    prgs = self:GetPrgsByIdx(act_type, idx)
  end
  return desc, status, items, prgs
end
def.method("number", "number", "=>", "number").GetStatusByIdx = function(self, act_type, idx)
  local status = TimedLoginMgr.AWARD_STATUS.NONE
  local sortIds = self:GetSortIds(act_type)
  local cfg = self:GetCfgByIdx(act_type, idx)
  if sortIds then
    for i = 1, #sortIds do
      if sortIds[i] == cfg.sortId then
        status = TimedLoginMgr.AWARD_STATUS.ALREADY
        break
      end
    end
  end
  if status == TimedLoginMgr.AWARD_STATUS.NONE then
    if act_type == TimedLoginMgr.ACT_TYPE.ACCUMULATIVE then
      local loginDays = self:GetAccumulativeDays()
      if loginDays >= cfg.loginSum then
        status = TimedLoginMgr.AWARD_STATUS.CAN
      else
        status = TimedLoginMgr.AWARD_STATUS.UNFINISHED
      end
    elseif act_type == TimedLoginMgr.ACT_TYPE.DAILY then
      local actId = self:GetActId(act_type)
      local actStartTime = ActivityInterface.GetActivityBeginningTime(actId)
      local serverTime = GetServerTime()
      local diff = serverTime - actStartTime
      if diff >= 0 then
        local currDays = math.floor(diff / 3600 / 24) + 1
        if currDays == cfg.loginDay then
          status = TimedLoginMgr.AWARD_STATUS.CAN
        elseif currDays >= cfg.loginDay then
          status = TimedLoginMgr.AWARD_STATUS.EXPIRE
        else
          status = TimedLoginMgr.AWARD_STATUS.UNFINISHED
        end
      end
    end
  end
  return status
end
def.method("number", "number", "=>", "string").GetPrgsByIdx = function(self, act_type, idx)
  local prgs = ""
  if act_type == TimedLoginMgr.ACT_TYPE.ACCUMULATIVE then
    local loginDays = self:GetAccumulativeDays()
    local cfg = self:GetCfgByIdx(act_type, idx)
    if cfg and loginDays < cfg.loginSum then
      prgs = string.format(textRes.customActivity[105], cfg.loginSum - loginDays)
    end
  end
  return prgs
end
def.method("number", "=>", "boolean").IsCanGetAward = function(self, act_type)
  if self:IsFeatureOpen(act_type) then
    local cfgs = self:GetAllCfgs(act_type)
    if cfgs then
      for i = 1, #cfgs do
        if self:GetStatusByIdx(act_type, i) == TimedLoginMgr.AWARD_STATUS.CAN then
          return true
        end
      end
    end
  end
  return false
end
def.method("number", "=>", "number").GetFocusIndex = function(self, act_type)
  local cfgs = self:GetAllCfgs(act_type)
  if cfgs then
    for i = 1, #cfgs do
      if self:GetStatusByIdx(act_type, i) == TimedLoginMgr.AWARD_STATUS.CAN then
        return i
      end
    end
  end
  return 0
end
def.method("number", "=>", "table").GetSortIds = function(self, act_type)
  local sortIds = {}
  if self.m_allActData then
    local allData = self.m_allActData[act_type]
    if allData then
      local actId = self:GetActId(act_type)
      local data = allData[actId]
      if data and data.sortIds then
        sortIds = data.sortIds
      end
    end
  end
  return sortIds
end
def.method("=>", "number").GetAccumulativeDays = function(self)
  local act_type = TimedLoginMgr.ACT_TYPE.ACCUMULATIVE
  local loginDays = 0
  if self.m_allActData then
    local allData = self.m_allActData[act_type]
    if allData then
      local actId = self:GetActId(act_type)
      local data = allData[actId]
      if data and data.loginDays then
        loginDays = data.loginDays
      end
    end
  end
  return loginDays
end
def.method()._AddAccumulativeDays = function(self)
  local act_type = TimedLoginMgr.ACT_TYPE.ACCUMULATIVE
  if not self.m_allActData then
    self.m_allActData = {}
  end
  if not self.m_allActData[act_type] then
    self.m_allActData[act_type] = {}
  end
  local actId = self:GetActId(act_type)
  if not self.m_allActData[act_type][actId] then
    self.m_allActData[act_type][actId] = {}
  end
  if not self.m_allActData[act_type][actId].loginDays then
    self.m_allActData[act_type][actId].loginDays = 0
  end
  self.m_allActData[act_type][actId].loginDays = self.m_allActData[act_type][actId].loginDays + 1
end
def.method("number", "=>", "table")._GetAwardItems = function(self, awardId)
  local cfg = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
  local items = {}
  if cfg then
    items = cfg.itemList
  end
  return items
end
def.method("userdata", "=>", "table")._Parse = function(self, record)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.activityCfgId = record:GetIntValue("activityCfgId")
  cfg.sortId = record:GetIntValue("sortId")
  local loginDay = record:GetIntValue("loginDay")
  if loginDay then
    cfg.loginDay = loginDay
  end
  local loginSum = record:GetIntValue("loginSum")
  if loginSum then
    cfg.loginSum = loginSum
  end
  cfg.detailedDesc = record:GetStringValue("detailedDesc")
  cfg.awardCfgId = record:GetIntValue("awardCfgId")
  return cfg
end
def.method("number", "number")._AddNewSortId = function(self, act_type, sortId)
  if not self.m_allActData then
    self.m_allActData = {}
  end
  if not self.m_allActData[act_type] then
    self.m_allActData[act_type] = {}
  end
  local actId = self:GetActId(act_type)
  if not self.m_allActData[act_type][actId] then
    self.m_allActData[act_type][actId] = {}
  end
  if not self.m_allActData[act_type][actId].sortIds then
    self.m_allActData[act_type][actId].sortIds = {}
  end
  local len = #self.m_allActData[act_type][actId].sortIds
  self.m_allActData[act_type][actId].sortIds[len + 1] = sortId
end
def.method("number", "number", "=>", "boolean")._CheckActType = function(self, act_type, actId)
  local id_list = TimedLoginMgr.ACT_ID_LIST[act_type]
  for i = 1, #id_list do
    local id = id_list[i]
    if id == actId then
      return true
    end
  end
  return false
end
def.static("table", "table").OnLeaveWorld = function(...)
  instance.m_allActData = {}
end
def.static("table", "table").OnActivityStart = function(params)
  if not instance then
    return
  end
  local actId = params and params[1] or 0
  if not actId or actId <= 0 then
    warn("----TimedLoginMgr OnActivityStart invalid actId : ", actId)
    return
  end
  if not instance:_CheckActType(TimedLoginMgr.ACT_TYPE.DAILY, actId) and not instance:_CheckActType(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE, actId) then
    return
  end
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {activityId = actId})
end
def.static("table", "table").OnActivityEnd = function(params)
  if not instance then
    return
  end
  local actId = params and params[1] or 0
  if not actId or actId <= 0 then
    warn("----TimedLoginMgr OnActivityEnd invalid actId : ", actId)
    return
  end
  if not instance:_CheckActType(TimedLoginMgr.ACT_TYPE.DAILY, actId) and not instance:_CheckActType(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE, actId) then
    return
  end
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {activityId = actId})
end
def.static("table", "table").NewDay = function()
  if instance and instance:IsOpen(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE) then
    instance:_AddAccumulativeDays()
  end
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, {})
end
def.method("number").CGetLoginAward = function(self, idx)
  if not instance then
    return
  end
  local actId = instance:GetActId(TimedLoginMgr.ACT_TYPE.DAILY)
  local p = require("netio.protocol.mzm.gsp.loginaward.CGetLoginAward").new(actId, idx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSLoginActivityInfos = function(p)
  instance.m_allActData[TimedLoginMgr.ACT_TYPE.DAILY] = p.activityInfos
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, {})
end
def.static("table").OnSGetLoginAwardSuccess = function(p)
  if not instance then
    return
  end
  if not instance:_CheckActType(TimedLoginMgr.ACT_TYPE.DAILY, p.activityId) then
    return
  end
  instance:_AddNewSortId(TimedLoginMgr.ACT_TYPE.DAILY, p.sortId)
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, {})
end
def.static("table").OnSGetLoginAwardFailed = function(p)
  local retcode = p.retcode
  local text = textRes.customActivity.SGetTimedLoginFailedRes[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("TimedLoginMgr OnSGetLoginAwardFailed not handle retcode=%d", retcode))
  end
end
def.method("number").CGetLoginSumSignAward = function(self, idx)
  if not instance then
    return
  end
  local actId = instance:GetActId(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE)
  local p = require("netio.protocol.mzm.gsp.loginaward.CGetLoginSumSignAward").new(actId, idx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSLoginSumActivityInfos = function(p)
  if not instance then
    return
  end
  instance.m_allActData[TimedLoginMgr.ACT_TYPE.ACCUMULATIVE] = p.activityInfos
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, {})
end
def.static("table").OnSGetLoginSumAwardSuccess = function(p)
  if not instance then
    return
  end
  if not instance:_CheckActType(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE, p.activityId) then
    return
  end
  instance:_AddNewSortId(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE, p.sortId)
  CustomActivityInterface.Instance():calcTimedLoginRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.TIMED_LOGIN_INFO_CHANGE, {})
end
def.static("table").OnSGetLoginSumAwardFailed = function(p)
  local retcode = p.retcode
  local text = textRes.customActivity.SGetTimedLoginFailedRes[retcode]
  if text then
    Toast(text)
  else
    warn(string.format("TimedLoginMgr OnSGetLoginSumAwardFailed not handle retcode=%d", retcode))
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1 and p1.open and p1.feature == Feature.TYPE_LOGIN_SUM_ACTIVITY and TimedLoginMgr.Instance():IsOpen(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE) then
    local p = require("netio.protocol.mzm.gsp.loginaward.CGetLoginSumActivityInfos").new()
    gmodule.network.sendProtocol(p)
  end
end
return TimedLoginMgr.Commit()
