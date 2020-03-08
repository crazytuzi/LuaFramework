local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local MonthCardMgr = Lplus.Extend(AwardMgrBase, "MonthCardMgr")
local def = MonthCardMgr.define
local AwardUtils = require("Main.Award.AwardUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local activity_id_low = 350000300
local activity_id_high = 350000299
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.field("table").monthCardInfo = nil
def.field("number").nextOpenId = 0
local instance
def.static("=>", MonthCardMgr).Instance = function()
  if instance == nil then
    instance = MonthCardMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MonthCardMgr.NewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MonthCardMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MonthCardMgr.OnLeaveWorld)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance then
    instance.monthCardInfo = nil
    instance.nextOpenId = 0
  end
end
def.static("number", "number", "=>", "table").GetMonthCardCfg = function(activityId, phase)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MONTH_CARD_CFG)
  if entries == nil then
    return
  end
  local cfg
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local activity_cfg_id = record:GetIntValue("activity_cfg_id")
    local curPhase = record:GetIntValue("phase")
    if activity_cfg_id == activityId and phase == curPhase then
      cfg = {}
      cfg.activity_cfg_id = activity_cfg_id
      cfg.phase = curPhase
      cfg.serviceId = record:GetIntValue("serviceId")
      cfg.res_background = record:GetIntValue("res_background")
      cfg.res_price = record:GetIntValue("res_price")
      cfg.res_rule = record:GetIntValue("res_rule")
      cfg.phase_switch = record:GetIntValue("phase_switch")
      cfg.phase_display_name = record:GetStringValue("phase_display_name")
      cfg.tips = record:GetStringValue("tips")
      break
    end
  end
  return cfg
end
def.method("table").setMonthCardInfo = function(self, data)
  self.monthCardInfo = {}
  local MonthCardActivityInfo = require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo")
  local STATUS_TODAY_IS_AWARDED = MonthCardActivityInfo.STATUS_TODAY_IS_AWARDED
  for i, v in pairs(data.activity_infos) do
    if v.status == STATUS_TODAY_IS_AWARDED and v.remain_days <= 1 and self:IsOpenMonthCardPhase(i, v.phase + 1) then
      v.phase = v.phase + 1
      v.status = MonthCardActivityInfo.STATUS_NOT_PURCHASE
      v.remain_days = 0
    end
  end
  local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
  local isFakePlatform = loginModule:IsFakeLoginPlatform()
  if _G.platform == 2 then
    for k, v in pairs(data.activity_infos) do
      if isFakePlatform then
        if k == activity_id_high then
          self.monthCardInfo[k] = v
        end
      elseif k == activity_id_low then
        self.monthCardInfo[k] = v
      end
    end
  elseif _G.platform == 1 then
    for k, v in pairs(data.activity_infos) do
      if k == activity_id_high then
        self.monthCardInfo[k] = v
      end
    end
  else
    self.monthCardInfo = data.activity_infos
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, nil)
end
def.method("table").updateMonthCardInfo = function(self, info)
  if self.monthCardInfo == nil then
    return
  end
  local MonthCardActivityInfo = require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo")
  for k, v in pairs(self.monthCardInfo) do
    if k == info.activity_id then
      v.status = MonthCardActivityInfo.STATUS_TODAY_IS_AWARDED
      if v.remain_days <= 1 then
        if self:IsOpenMonthCardPhase(k, v.phase + 1) then
          v.phase = v.phase + 1
          v.status = MonthCardActivityInfo.STATUS_NOT_PURCHASE
          v.remain_days = 0
          break
        end
        warn("------------monthCard next phase is close:", v.phase + 1)
        local nextMonthCardCfg = MonthCardMgr.GetMonthCardCfg(k, v.phase + 1)
        if nextMonthCardCfg then
          self.nextOpenId = nextMonthCardCfg.phase_switch
        end
      end
      break
    end
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, nil)
end
def.method().nextDay = function(self)
  if self.monthCardInfo == nil then
    return
  end
  local MonthCardActivityInfo = require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo")
  local isNotify = true
  for k, v in pairs(self.monthCardInfo) do
    if v.status ~= MonthCardActivityInfo.STATUS_NOT_PURCHASE then
      local curStatus = v.status
      v.status = MonthCardActivityInfo.STATUS_TODAY_NOT_AWARDED
      v.remain_days = v.remain_days - 1
      if v.remain_days <= 0 then
        v.remain_days = 0
        if self:IsOpenMonthCardPhase(k, v.phase + 1) then
          v.status = MonthCardActivityInfo.STATUS_NOT_PURCHASE
          v.phase = v.phase + 1
          break
        end
        local nextMonthCardCfg = MonthCardMgr.GetMonthCardCfg(k, v.phase + 1)
        if nextMonthCardCfg then
          self.nextOpenId = nextMonthCardCfg.phase_switch
        end
        v.status = curStatus
        isNotify = false
      end
    end
    break
  end
  if isNotify then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, nil)
  end
end
def.method("number", "number", "=>", "boolean").IsOpenMonthCardPhase = function(self, activityId, phase)
  local monthCardCfg = MonthCardMgr.GetMonthCardCfg(activityId, phase)
  if monthCardCfg then
    if IsFeatureOpen(monthCardCfg.phase_switch) then
      return true
    else
      return false
    end
  end
  return false
end
def.method("=>", "table").GetMonthCardInfo = function(self)
  return self.monthCardInfo
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  if self.monthCardInfo == nil then
    return false
  end
  for i, v in pairs(self.monthCardInfo) do
    if not self:IsOpenMonthCardPhase(i, v.phase) then
      return false
    end
  end
  if self:IsOpen() == false then
    return false
  end
  for k, v in pairs(self.monthCardInfo) do
    if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_TODAY_NOT_AWARDED then
      return true
    end
  end
  return false
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.override("=>", "boolean").IsOpen = function(self)
  if self.monthCardInfo == nil then
    return false
  end
  local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
  local isFakePlatform = loginModule:IsFakeLoginPlatform()
  if isFakePlatform then
    for k, v in pairs(self.monthCardInfo) do
      if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_NOT_PURCHASE then
        return false
      else
        break
      end
    end
  end
  for k, v in pairs(self.monthCardInfo) do
    if not self:IsOpenMonthCardPhase(k, v.phase) then
      return false
    end
    if v.status == require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo").STATUS_NOT_PURCHASE then
      do return true end
      break
    end
    if v.remain_days < 1 then
      do return false end
      break
    end
    do return true end
    break
  end
  return self.monthCardInfo ~= nil
end
def.method("=>", "string").GetCurMonthCardName = function(self)
  if self.monthCardInfo then
    for k, v in pairs(self.monthCardInfo) do
      local monthCardCfg = MonthCardMgr.GetMonthCardCfg(k, v.phase)
      if monthCardCfg then
        return monthCardCfg.phase_display_name
      end
    end
  end
  return ""
end
def.static("table", "table").NewDay = function(params)
  MonthCardMgr.Instance():nextDay()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if instance and p1.feature == instance.nextOpenId and instance.monthCardInfo then
    local MonthCardActivityInfo = require("netio.protocol.mzm.gsp.qingfu.MonthCardActivityInfo")
    local STATUS_TODAY_IS_AWARDED = MonthCardActivityInfo.STATUS_TODAY_IS_AWARDED
    for i, v in pairs(instance.monthCardInfo) do
      if v.status ~= MonthCardActivityInfo.STATUS_NOT_PURCHASE and (v.status == STATUS_TODAY_IS_AWARDED and v.remain_days == 1 or v.remain_days <= 0) and instance:IsOpenMonthCardPhase(i, v.phase + 1) then
        v.phase = v.phase + 1
        v.status = MonthCardActivityInfo.STATUS_NOT_PURCHASE
        v.remain_days = 0
      end
    end
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, nil)
  end
end
return MonthCardMgr.Commit()
