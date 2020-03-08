local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local DailyGiftMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local AwardUtils = require("Main.Award.AwardUtils")
local NewServerAwardMgr = require("Main.Award.mgr.NewServerAwardMgr")
local PayModule = require("Main.Pay.PayModule")
local PayData = require("Main.Pay.PayData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = DailyGiftMgr.define
def.const("number").ActivityId = constant.CQingfuCfgConsts.RMB_GIFT_BAG_ACTIVITY_CFG_ID
def.const("string").PayTagPrefix = "Daily_Gift_"
def.field("table").awardStatusData = nil
def.field("table").todayGiftAwardData = nil
def.field("string").payingGiftTag = ""
def.field("boolean").isReceiveFreeAward = false
def.field("number").myOpenDays = 0
local instance
def.static("=>", DailyGiftMgr).Instance = function()
  if instance == nil then
    instance = DailyGiftMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncRMBGiftBagActivityInfo", DailyGiftMgr.OnSSyncRMBGiftBagActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetRMBGiftBagActivityAwardSuccess", DailyGiftMgr.OnGetGiftAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetRMBGiftBagActivityAwardFailed", DailyGiftMgr.OnGetGiftAwardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncDailyGiftInfo", DailyGiftMgr.OnSyncDailyGiftInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetDailyGiftSuccess", DailyGiftMgr.OnGetDailyGiftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetDailyGiftFailed", DailyGiftMgr.OnGetDailyGiftFailed)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, DailyGiftMgr.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, DailyGiftMgr.OnActivityClose)
  Event.RegisterEvent(ModuleId.PAY, gmodule.notifyId.Pay.PayStart, DailyGiftMgr.OnPayStart)
  Event.RegisterEvent(ModuleId.PAY, gmodule.notifyId.Pay.PaySuccess, DailyGiftMgr.OnPaySuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, DailyGiftMgr.Reset)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DailyGiftMgr.OnFeatureOpenChange)
end
def.static("table").OnSSyncRMBGiftBagActivityInfo = function(p)
  if p.activity_infos[DailyGiftMgr.ActivityId] ~= nil then
    instance:SetAwardStatusData(p.activity_infos[DailyGiftMgr.ActivityId])
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, nil)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.static("table").OnGetGiftAwardSuccess = function(p)
  if p.activity_cfgid == DailyGiftMgr.ActivityId then
    local tier = p.tier
    instance:ReceivedGiftAward(tier)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, nil)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.static("table").OnGetGiftAwardFail = function(p)
  if p.activity_cfgid == DailyGiftMgr.ActivityId then
    local retCode = p.retcode
    if textRes.Award.SGetRMBGiftBagActivityAwardFailed[retCode] ~= nil then
      Toast(textRes.Award.SGetRMBGiftBagActivityAwardFailed[retCode])
    end
  end
end
def.static("table").OnSyncDailyGiftInfo = function(p)
  if instance ~= nil then
    instance:SetIsReceiveFreeAward(p.is_receive == 1)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, nil)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.static("table").OnGetDailyGiftSuccess = function(p)
  if instance ~= nil then
    instance:SetIsReceiveFreeAward(true)
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, nil)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.static("table").OnGetDailyGiftFailed = function(p)
  if textRes.Award.SGetDailyGiftFailed[p.retcode] then
    Toast(textRes.Award.SGetDailyGiftFailed[p.retcode])
  end
end
def.static("table", "table").OnActivityReset = function(params, context)
  local activityId = params[1]
  if activityId == DailyGiftMgr.ActivityId then
    instance:ResetAwardData()
  end
end
def.static("table", "table").OnActivityClose = function(params, context)
  local activityId = params[1]
  if activityId == DailyGiftMgr.ActivityId then
  end
end
def.static("table", "table").OnPayStart = function(params, context)
  local payTag = params[1]
  instance:CheckStartPayStatus(payTag)
end
def.static("table", "table").OnPaySuccess = function(params, context)
  local payTag = params[1]
  instance:CheckPaySuccessStatus(payTag)
end
def.method("table").SetAwardStatusData = function(self, awardStatusData)
  self.myOpenDays = awardStatusData.opendays
  for tier, status in pairs(awardStatusData.tiers) do
    self:SetAwardStatus(tier, status)
    if self.awardStatusData[tier].waiting and status.buy_times > status.award_times then
      self:SetAwardWaitingStatus(tier, false)
    end
  end
end
def.method("number", "=>", "table").GetDailyGiftItemsOfDay = function(self, serverOpenDay)
  if self.myOpenDays > 0 then
    return AwardUtils.GetDailyGiftItemsOfDay(DailyGiftMgr.ActivityId, self.myOpenDays)
  else
    return AwardUtils.GetDailyGiftItemsOfDay(DailyGiftMgr.ActivityId, serverOpenDay)
  end
end
def.method("number", "table").SetAwardStatus = function(self, tier, status)
  if self.awardStatusData == nil then
    self.awardStatusData = {}
  end
  if self.awardStatusData[tier] == nil then
    self.awardStatusData[tier] = {}
  end
  self.awardStatusData[tier].buy_times = status.buy_times
  self.awardStatusData[tier].award_times = status.award_times
end
def.method("number", "boolean").SetAwardWaitingStatus = function(self, tier, waiting)
  if self.awardStatusData == nil or self.awardStatusData[tier] == nil then
    return
  end
  self.awardStatusData[tier].waiting = waiting
end
def.method().ResetAwardStatusData = function(self)
  self.isReceiveFreeAward = false
  if self.awardStatusData == nil then
    return
  end
  for tier, status in pairs(self.awardStatusData) do
    status.buy_times = 0
    status.award_times = 0
    status.waiting = false
  end
end
def.method().LazyInitTodayGift = function(self)
  self:InitTodayGiftAwardData()
end
def.method().ResetAwardData = function(self)
  self.myOpenDays = 0
  self:InitTodayGiftAwardData()
  self:ResetAwardStatusData()
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, nil)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_CHANGE, nil)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, nil)
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
end
def.method().InitTodayGiftAwardData = function(self)
  local serverOpenDay = NewServerAwardMgr.Instance():getServerOpenDayNum()
  if serverOpenDay <= 0 then
    return
  end
  local giftAwards = self:GetDailyGiftItemsOfDay(serverOpenDay)
  for idx, giftAward in ipairs(giftAwards) do
    local awardCfgId = giftAward.awardCfgId
    local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(awardCfgId)
    giftAward.giftItemInfo = awardCfg.itemList[1]
  end
  self.todayGiftAwardData = giftAwards
end
def.method("boolean").SetIsReceiveFreeAward = function(self, isReceive)
  self.isReceiveFreeAward = isReceive
end
def.method("number", "=>", "table").GetAwardStatusDataByTier = function(self, tier)
  if self.awardStatusData == nil then
    return nil
  end
  return self.awardStatusData[tier]
end
def.method("number").ReceivedGiftAward = function(self, tier)
  if self.awardStatusData ~= nil then
    local status = self.awardStatusData[tier]
    status.award_times = status.award_times + 1
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:GetNotifyMessageCount() > 0
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:IsOpen() and self:CanGetAward() then
    return 1
  end
  if self:IsFreeAwardOpen() and self:CanReceiveFreeAward() then
    return 1
  end
  return 0
end
def.method("=>", "boolean").CanGetAward = function(self)
  if self.awardStatusData == nil then
    return false
  end
  for tier, status in pairs(self.awardStatusData) do
    if status.buy_times > status.award_times then
      return true
    end
  end
  return false
end
def.override("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QING_FU_RMB_GIFT_BAG) then
    return false
  end
  local serverOpenDay = NewServerAwardMgr.Instance():getServerOpenDayNum()
  if serverOpenDay <= 0 then
    return false
  end
  return ActivityInterface.Instance():isActivityOpend(DailyGiftMgr.ActivityId)
end
def.method("=>", "boolean").IsFreeAwardOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GET_DAILY_GIFT) then
    return false
  end
  return true
end
def.method("=>", "boolean").CanReceiveFreeAward = function(self)
  return self.isReceiveFreeAward == false
end
def.method("=>", "table").GetDailyGiftItems = function(self)
  if self.todayGiftAwardData == nil then
    self:LazyInitTodayGift()
  end
  return self.todayGiftAwardData
end
def.method("number").BuyGiftAward = function(self, idx)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QING_FU_RMB_GIFT_BAG) then
    Toast(textRes.Pay[3])
    return
  end
  if not self:IsOpen() then
    Toast(textRes.Award[77])
    return
  end
  local serviceId = self.todayGiftAwardData[idx].productServiceId
  local payCfg = PayData.GetQingFuCfgByServerId(serviceId)
  if payCfg == nil or #payCfg == 0 then
    Toast(textRes.Award[77])
    return
  end
  local payTag = DailyGiftMgr.PayTagPrefix .. idx
  self:StartPay(payCfg[1], payTag)
end
def.method("number").GetGiftAward = function(self, awardIdx)
  local tier = self.todayGiftAwardData[awardIdx].tier
  local p = require("netio.protocol.mzm.gsp.qingfu.CGetRMBGiftBagActivityAward").new(DailyGiftMgr.ActivityId, tier)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "string").GetActivityTimeInfo = function(self)
  local cfg = ActivityInterface.GetActivityCfgById(DailyGiftMgr.ActivityId)
  if cfg ~= nil then
    return cfg.timeDes
  else
    return ""
  end
end
def.method().GetFreeAward = function(self)
  if not self:IsOpen() or not self:IsFreeAwardOpen() then
    Toast(textRes.Award[101])
    return
  end
  if not self:CanReceiveFreeAward() then
    Toast(textRes.Award[100])
    return
  end
  local p = require("netio.protocol.mzm.gsp.qingfu.CGetDailyGift").new()
  gmodule.network.sendProtocol(p)
end
def.method("=>", "string").GetDailyGiftDescription = function(self)
  local serverOpenDay = NewServerAwardMgr.Instance():getServerOpenDayNum()
  if serverOpenDay <= 0 then
    return ""
  end
  local curTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local curWeekDay = t.wday
  local week = 7
  local openDayNextWeek = serverOpenDay + week - curWeekDay + 1
  local desc = {}
  for i = 2, week + 1 do
    local openDayInWeek = (openDayNextWeek + i - 1 - 1) % week + 1
    local weekDay = (i - 1 + week) % week + 1
    table.insert(desc, textRes.Award.WeekDay[weekDay] .. textRes.Award.DaiyGiftDesc[openDayInWeek])
  end
  return table.concat(desc, "\n")
end
def.method("table", "string").StartPay = function(self, payCfg, payTag)
  self.payingGiftTag = payTag
  PayModule.PayWithTag(payCfg, payTag)
end
def.method().CancelPay = function(self)
  self.payingGiftTag = ""
end
def.method().PaySuccess = function(self)
  if self.todayGiftAwardData == nil then
    return
  end
  local idx = tonumber(string.sub(self.payingGiftTag, string.len(DailyGiftMgr.PayTagPrefix) + 1))
  local tier = self.todayGiftAwardData[idx].tier
  self:SetAwardWaitingStatus(tier, true)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, nil)
end
def.method("string").CheckStartPayStatus = function(self, payTag)
  if self.payingGiftTag == "" then
    return
  end
  if self.payingGiftTag ~= payTag then
    self:CancelPay()
  end
end
def.method("string").CheckPaySuccessStatus = function(self, payTag)
  if self.payingGiftTag == "" then
    return
  end
  if self.payingGiftTag ~= payTag then
    self:CancelPay()
  else
    self:PaySuccess()
  end
end
def.static("table", "table").Reset = function()
  local self = instance
  self.awardStatusData = nil
  self.todayGiftAwardData = nil
  self.payingGiftTag = ""
  self.isReceiveFreeAward = false
  self.myOpenDays = 0
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GET_DAILY_GIFT then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, nil)
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
return DailyGiftMgr.Commit()
