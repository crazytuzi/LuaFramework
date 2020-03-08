local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local CustomActivityInterface = Lplus.Class("CustomActivityInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = CustomActivityInterface.define
local instance
CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID = 0
CustomActivityInterface.LIMIT_COST_ACTIVITY_ID = 0
def.const("string").LIMIT_FREE_GIFT_KEY = "LIMIT_FREE_GIFT_KEY"
def.const("number").LIMIT_CHARGE_ACTIVITY_ID_COUNT = 12
def.const("number").LIMIT_COST_ACTIVITY_ID_COUNT = 12
def.field("table").limitChargeInfo = nil
def.field("table").customActivityRed = nil
def.field("table").accumTotalCostInfos = nil
def.static("=>", CustomActivityInterface).Instance = function()
  if instance == nil then
    instance = CustomActivityInterface()
    instance:Init()
  end
  return instance
end
def.static("number", "=>", "table").GetSaveAMTCfgByActivityId = function(activityId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SAVE_AMT_CFG)
  if entries == nil then
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    if record:GetIntValue("activity_cfg_id") == activityId then
      local r = {}
      r.id = record:GetIntValue("id")
      r.award_id = record:GetIntValue("award_cfg_id")
      r.name = record:GetStringValue("name")
      r.desc = record:GetStringValue("desc")
      r.saveAmt = record:GetIntValue("save_amt_cond")
      r.sortid = record:GetIntValue("sort_id")
      r.display_save_amt_cond = record:GetIntValue("display_save_amt_cond")
      cfg[r.id] = r
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "=>", "table").GetAccumTotalCostAwardCfgByActivityId = function(activityId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACCUM_TOTAL_COST_AWARD_CFG)
  if entries == nil then
    return nil
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfg = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    if record:GetIntValue("activity_cfg_id") == activityId then
      local r = {}
      r.id = record:GetIntValue("id")
      r.award_id = record:GetIntValue("award_cfg_id")
      r.name = record:GetStringValue("name")
      r.desc = record:GetStringValue("desc")
      r.accum_total_cost_cond = record:GetIntValue("accum_total_cost_cond")
      r.sortid = record:GetIntValue("sort_id")
      r.display_accum_total_cost_cond = record:GetIntValue("display_accum_total_cost_cond")
      cfg[r.id] = r
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("=>", "table").GetAllTimeLimitedActivityIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TIME_LIMITED_GIFTBAG_CFG)
  if entries == nil then
    warn("GetTimeLimitedActivityIds return empty")
    return {}
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local ids = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    local activityId = record:GetIntValue("activityId")
    ids[activityId] = activityId
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return ids
end
def.static("number", "=>", "table").GetTimeLimitedGiftBagCfgsByActivityId = function(activityId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TIME_LIMITED_GIFTBAG_CFG)
  if entries == nil then
    warn("GetTimeLimitedGiftBagCfgsByActivityId return empty")
    return {}
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    if record:GetIntValue("activityId") == activityId then
      local cfg = CustomActivityInterface._GetTimeLimitedGiftBagCfg(record)
      cfgs[#cfgs + 1] = cfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetTimeLimitedGiftBagCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TIME_LIMITED_GIFTBAG_CFG, id)
  if record == nil then
    warn("GetTimeLimitedGiftBagCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = CustomActivityInterface._GetTimeLimitedGiftBagCfg(record)
  return cfg
end
def.static("userdata", "=>", "table")._GetTimeLimitedGiftBagCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.activityId = record:GetIntValue("activityId")
  cfg.giftBagType = record:GetIntValue("giftBagType")
  cfg.icon = record:GetIntValue("icon")
  cfg.icon2 = record:GetIntValue("icon2")
  cfg.icon3 = record:GetIntValue("icon3")
  cfg.rewardId = record:GetIntValue("rewardId")
  cfg.buyWeekDay = record:GetIntValue("buyWeekDay")
  cfg.maxCount = record:GetIntValue("maxCount")
  cfg.moneytype = record:GetIntValue("moneytype")
  cfg.originalPrice = record:GetIntValue("originalPrice")
  cfg.discountPrice = record:GetIntValue("discountPrice")
  cfg.minActiveValue = record:GetIntValue("minActiveValue")
  cfg.sort = record:GetIntValue("sort") or 0
  cfg.desc = record:GetStringValue("desc")
  cfg.bCan2Give = record:GetIntValue("canGift") == 1
  cfg.giftPrice = record:GetIntValue("giftPrice")
  cfg.minFriendIntimacy = record:GetIntValue("friendIntimacyMin")
  cfg.maxSendCount = record:GetIntValue("sendCountMax")
  cfg.maxP2PCount = record:GetIntValue("p2pCountMax")
  cfg.maxRcvCount = record:GetIntValue("receiveCountMax")
  cfg.giftMoneyType = record:GetIntValue("giftMoneyType")
  return cfg
end
def.static("number", "=>", "table").GetGiftBagTypeCfgByActivityId = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITYID_2_GIFTBAG_TYPE_CFG, activityId)
  if record == nil then
    warn("GetTimeLimitedGiftBagCfg(" .. activityId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.giftBagType = record:GetIntValue("giftBagType")
  cfg.giftBagIds = {}
  local giftBagTypeIdStruct = record:GetStructValue("giftBagTypeIdStruct")
  local size = giftBagTypeIdStruct:GetVectorSize("giftBagTypeIdList")
  for i = 0, size - 1 do
    local vectorRow = giftBagTypeIdStruct:GetVectorValueByIdx("giftBagTypeIdList", i)
    local id = vectorRow:GetIntValue("id")
    cfg.giftBagIds[i + 1] = id
  end
  return cfg
end
def.static("number", "=>", "table").GetBeginnerLoginSignCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BEGINNER_LOGIN_SIGN_CFG, id)
  if record == nil then
    warn("!!!!!!!!GetBeginnerLoginSignCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.openLevel = record:GetIntValue("openLevel")
  cfg.duration = record:GetIntValue("duration")
  cfg.banner = record:GetIntValue("banner")
  return cfg
end
def.method().Init = function(self)
  self.customActivityRed = {}
  self.accumTotalCostInfos = nil
  self.limitChargeInfo = nil
end
def.method().Reset = function(self)
  self.customActivityRed = {}
  self.limitChargeInfo = nil
  CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID = 0
  CustomActivityInterface.LIMIT_COST_ACTIVITY_ID = 0
end
def.method().setLimitChargeActivityId = function(self)
  local curTime = GetServerTime()
  for i = 0, CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID_COUNT do
    local activityId = constant.CQingfuCfgConsts["TIME_LIMITED_SAVE_AMT_ACTIVITY_CFG_ID_" .. i]
    if activityId and activityId > 0 then
      local openTime, timeList, closeTime = activityInterface:getActivityStatusChangeTime(activityId)
      if curTime >= openTime and (closeTime == 0 or curTime < closeTime) then
        CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID = activityId
        break
      end
    end
  end
end
def.method().setLimitCostActivityId = function(self)
  local curTime = GetServerTime()
  for i = 0, CustomActivityInterface.LIMIT_COST_ACTIVITY_ID_COUNT do
    local activityId = constant.CQingfuCfgConsts["TIME_LIMITED_ACCUM_TOTAL_COST_ACTIVITY_CFG_ID_" .. i]
    if activityId and activityId > 0 then
      local openTime, timeList, closeTime = activityInterface:getActivityStatusChangeTime(activityId)
      if curTime >= openTime and (closeTime == 0 or curTime < closeTime) then
        CustomActivityInterface.LIMIT_COST_ACTIVITY_ID = activityId
        break
      end
    end
  end
end
def.method("table").setLimitChargeInfo = function(self, info)
  if info.sortid == -1 then
    info.sortid = 0
  end
  info.base_save_amt = info.base_save_amt:ToNumber()
  self.limitChargeInfo = info
end
def.method("=>", "table").getLimitChargeInfo = function(self)
  if self.limitChargeInfo then
    return self.limitChargeInfo
  else
    local ItemModule = require("Main.Item.ItemModule")
    local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring())
    return {base_save_amt = totalRecharge, sortid = 0}
  end
end
def.method("number").changeLimtChargeSortid = function(self, sortid)
  self.limitChargeInfo.sortid = sortid
end
def.method().calcLimitChargeRedPoint = function(self)
  local canGetAward = false
  local activityId = CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID
  local isOpen = ActivityInterface.Instance():isActivityOpend(activityId)
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isServerOpen = feature:CheckFeatureOpen(Feature.TYPE_QING_FU_TIME_LIMITED_SAVE_AMT)
  if isOpen and isServerOpen then
    local totalChargeCfgs = CustomActivityInterface.GetSaveAMTCfgByActivityId(activityId)
    local chargeInfo = self:getLimitChargeInfo()
    local sortid = chargeInfo.sortid
    local chargeInfo = instance:getLimitChargeInfo()
    local totalRecharge = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT):tostring())
    local saveAmt = totalRecharge - chargeInfo.base_save_amt
    for _, v in pairs(totalChargeCfgs) do
      if v.sortid == sortid + 1 and saveAmt >= v.saveAmt then
        canGetAward = true
        break
      end
    end
  end
  self.customActivityRed.Tab_LimitRecharge = canGetAward
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, nil)
end
def.method("string", "=>", "boolean").getCustomActivityRedPointFlag = function(self, tabName)
  return self.customActivityRed[tabName] or false
end
def.method("table").setAccumTotalCostInfos = function(self, infos)
  for _, v in pairs(infos) do
    if v.sortid == -1 then
      v.sortid = 0
    end
    v.base_accum_total_cost = v.base_accum_total_cost:ToNumber()
  end
  self.accumTotalCostInfos = infos
end
def.method("number", "number").changeAccumCostInfo = function(self, activityId, sortid)
  self.accumTotalCostInfos[activityId].sortid = sortid
end
def.method("number", "=>", "table").getAccumTotalCostInfo = function(self, activityId)
  if self.accumTotalCostInfos then
    return self.accumTotalCostInfos[activityId] or {base_accum_total_cost = 0, sortid = 0}
  end
  return {base_accum_total_cost = 0, sortid = 0}
end
def.method().calcAccumCostRedPoint = function(self)
  local activityId = CustomActivityInterface.LIMIT_COST_ACTIVITY_ID
  local isOpen = ActivityInterface.Instance():isActivityOpend(activityId)
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isServerOpen = feature:CheckFeatureOpen(Feature.TYPE_QING_FU_TIME_LIMITED_ACCUM_TOTAL_COST)
  warn("------calcAccumCostRedPoint:", isOpen, isServerOpen)
  local canGetAward = false
  if isOpen and isServerOpen then
    local accumCostCfgs = CustomActivityInterface.GetAccumTotalCostAwardCfgByActivityId(activityId)
    local accumCostInfo = self:getAccumTotalCostInfo(activityId)
    local totalCost = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST):tostring())
    local bindCost = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND):tostring())
    local curCostNum = totalCost + bindCost - accumCostInfo.base_accum_total_cost
    for _, v in pairs(accumCostCfgs) do
      if v.sortid == accumCostInfo.sortid + 1 and curCostNum >= v.accum_total_cost_cond then
        canGetAward = true
        break
      end
    end
  end
  self.customActivityRed.Tab_LimitCost = canGetAward
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, nil)
end
def.method().calcTimedLoginRedPoint = function(self)
  local TimedLoginMgr = require("Main.CustomActivity.TimedLoginMgr")
  local inst = TimedLoginMgr.Instance()
  local canGetAward = inst:IsCanGetAward(TimedLoginMgr.ACT_TYPE.DAILY) or inst:IsCanGetAward(TimedLoginMgr.ACT_TYPE.ACCUMULATIVE)
  self.customActivityRed.Tab_Carnival = canGetAward
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, nil)
end
def.method("=>", "boolean").isOwnRedPoint = function(self)
  if self.customActivityRed then
    for _, v in pairs(self.customActivityRed) do
      if v then
        return true
      end
    end
  end
  return false
end
def.method("=>", "number").GetTimeLimitedGiftActivityId = function(self)
  local GiftBagType = require("consts.mzm.gsp.qingfu.confbean.GiftBagType")
  local activityGiftInfos = require("Main.CustomActivity.GiftActivityMgr").Instance():GetActivityGiftInfosByGiftBagType(GiftBagType.TYPE_TIME_LIMIT)
  if #activityGiftInfos == 0 then
    return 0
  end
  local giftBagInfo = activityGiftInfos[1]
  return giftBagInfo.activityId
end
def.method("number").markTimeLimitedFreeGift = function(self, giftBagId)
  local key = CustomActivityInterface.LIMIT_FREE_GIFT_KEY
  LuaPlayerPrefs.SetRoleInt(key, giftBagId)
  LuaPlayerPrefs.Save()
  self:calcTimeLimitedGiftRedPoint()
end
def.method().calcTimeLimitedGiftRedPoint = function(self)
  local canGetAward = false
  local activityId = self:GetTimeLimitedGiftActivityId()
  if activityId == 0 then
  else
    local isOpen = ActivityInterface.Instance():isActivityOpend(activityId)
    local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
    local isServerOpen = feature:CheckFeatureOpen(Feature.TYPE_TIME_LIMIT_GIFT)
    if isOpen and isServerOpen then
      local GiftActivityMgr = require("Main.CustomActivity.GiftActivityMgr")
      local giftBagInfo = GiftActivityMgr.Instance():GetActivityGiftInfo(activityId)
      if giftBagInfo == nil then
      else
        local timestamp = _G.GetServerTime()
        local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
        local t = AbsoluteTimer.GetServerTimeTable(timestamp)
        local wday = t.wday
        local WeekDay_NO_DAY = 0
        local key = CustomActivityInterface.LIMIT_FREE_GIFT_KEY
        for k, v in pairs(giftBagInfo.gift_bag_id_2_remain_count) do
          local giftBagId = k
          local remainPurchaseTimes = v
          local giftBagCfg = CustomActivityInterface.GetTimeLimitedGiftBagCfg(giftBagId)
          local buyWeekDay = giftBagCfg.buyWeekDay
          if (wday == buyWeekDay or buyWeekDay == WeekDay_NO_DAY) and giftBagCfg.discountPrice == 0 and remainPurchaseTimes > 0 then
            canGetAward = true
            break
          end
        end
      end
    end
  end
  self.customActivityRed.Tab_LimitGiftBa = canGetAward
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, nil)
end
def.method("=>", "boolean").IsStartWorkBenefitsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_OPEN_WELFARE) then
    return false
  end
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actInfo = giftMgr:GetActivityGiftInfo(constant.COpenWelfareConst.activity_cfg_id)
  if actInfo then
    return true
  else
    return false
  end
end
def.method("=>", "table").GetStartWorkBenefitsInfo = function(self)
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actInfo = giftMgr:GetActivityGiftInfo(constant.COpenWelfareConst.activity_cfg_id)
  if actInfo then
    local infos = {}
    for k, v in pairs(actInfo.gift_bag_id_2_remain_count) do
      local info = {}
      local giftCfg = CustomActivityInterface.GetTimeLimitedGiftBagCfg(k)
      if giftCfg then
        info.sort = giftCfg.sort
        info.id = giftCfg.id
        info.icon1 = giftCfg.icon
        info.icon2 = giftCfg.icon2
        info.icon3 = giftCfg.icon3
        info.weekday = giftCfg.buyWeekDay
        info.minActiveValue = giftCfg.minActiveValue
        info.rewardId = giftCfg.rewardId
        info.desc = giftCfg.desc
        info.times = v
      end
      table.insert(infos, info)
    end
    table.sort(infos, function(a, b)
      return a.sort < b.sort
    end)
    return infos
  else
    return nil
  end
end
def.method("=>", "boolean").IsStartWorkHasThing = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_OPEN_WELFARE) then
    return false
  end
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actInfo = giftMgr:GetActivityGiftInfo(constant.COpenWelfareConst.activity_cfg_id)
  if actInfo then
    local serverTime = GetServerTime()
    local timeTbl = require("Main.Common.AbsoluteTimer").GetServerTimeTable(serverTime)
    local weekDay = timeTbl.wday
    local curActive = require("Main.activity.ActivityInterface").Instance():GetCurActive()
    for k, v in pairs(actInfo.gift_bag_id_2_remain_count) do
      local giftCfg = CustomActivityInterface.GetTimeLimitedGiftBagCfg(k)
      if giftCfg and giftCfg.buyWeekDay == weekDay then
        if v > 0 and curActive >= giftCfg.minActiveValue then
          return true
        else
          return false
        end
      end
    end
    return false
  else
    return false
  end
end
def.method("number", "=>", "boolean").GetStartWorkBenefitsGift = function(self, giftId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_OPEN_WELFARE) then
    Toast(textRes.activity[393])
    return false
  end
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local ret = giftMgr:GetGiftAwardReq(constant.COpenWelfareConst.activity_cfg_id, giftId, 1)
  return ret
end
def.method("=>", "boolean").IsAllowPushOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PUSH_AWARD) then
    return false
  end
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actId = constant.PushAwardConst.activityid
  local info = giftMgr:GetActivityGiftInfo(actId)
  return info ~= nil
end
def.method("=>", "boolean").IsAllowPushRed = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PUSH_AWARD) then
    return false
  end
  if self:IsAllowPushHasThing() then
    local PlayerPref = require("Main.Common.LuaPlayerPrefs")
    local weekRecord = PlayerPref.GetRoleInt("AllowPush")
    local stime = GetServerTime()
    local weekSeconds = 604800
    warn("IsAllowPushRed", stime, weekRecord)
    if weekSeconds < stime - weekRecord then
      return true
    elseif stime - weekRecord > 0 then
      local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
      local timeTbl1 = AbsoluteTimer.GetServerTimeTable(stime)
      local timeTbl2 = AbsoluteTimer.GetServerTimeTable(weekRecord)
      local wday1 = 0 < timeTbl1.wday - 1 and timeTbl1.wday - 1 or 7
      local wday2 = 0 < timeTbl2.wday - 1 and timeTbl2.wday - 1 or 7
      if stime - weekRecord > 86400 then
        return wday1 <= wday2
      else
        return wday1 < wday2
      end
    else
      return false
    end
  else
    return false
  end
end
def.method().RemoveRed = function(self)
  local stime = GetServerTime()
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  PlayerPref.SetRoleInt("AllowPush", stime)
  PlayerPref.Save()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.ALLOWPUSH_RED_CHANGE, nil)
end
def.method("=>", "boolean").IsAllowPushHasThing = function(self)
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actId = constant.PushAwardConst.activityid
  local info = giftMgr:GetActivityGiftInfo(actId)
  if info and info.gift_bag_id_2_remain_count then
    local giftId, times = next(info.gift_bag_id_2_remain_count)
    if giftId and times and times > 0 then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "number").GetAllowPushAwardInfo = function(self)
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actId = constant.PushAwardConst.activityid
  local info = giftMgr:GetActivityGiftInfo(actId)
  if info and info.gift_bag_id_2_remain_count then
    local giftId, times = next(info.gift_bag_id_2_remain_count)
    if giftId then
      local info = {}
      local giftCfg = CustomActivityInterface.GetTimeLimitedGiftBagCfg(giftId)
      if giftCfg then
        return giftCfg.rewardId
      else
        return 0
      end
    else
      return 0
    end
  else
    return 0
  end
end
def.method().RequestAllowPush = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PUSH_AWARD) then
    Toast(textRes.Award[87])
    return
  end
  local giftMgr = require("Main.CustomActivity.GiftActivityMgr").Instance()
  local actId = constant.PushAwardConst.activityid
  local info = giftMgr:GetActivityGiftInfo(actId)
  if info and info.gift_bag_id_2_remain_count then
    local giftId, times = next(info.gift_bag_id_2_remain_count)
    if giftId then
      giftMgr:GetGiftAwardReq(actId, giftId, 1)
    end
  end
end
def.method("=>", "boolean").IsInviteOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_INVITE_FRIENDS) then
    return false
  end
  local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
  local openLevel = RelationShipChainMgr.GetInviteFriendConstant("OPEN_NEED_ROLE_LEVEL")
  local HeroProp = require("Main.Hero.Interface").GetHeroProp()
  local roleLv = HeroProp.level
  return openLevel <= roleLv and _G.LoginPlatform ~= MSDK_LOGIN_PLATFORM.GUEST
end
def.method("=>", "boolean").IsInviteAwardHasThing = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_INVITE_FRIENDS) then
    return false
  end
  local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
  local inviteFriendData = RelationShipChainMgr.GetInviteFriendData()
  if inviteFriendData.award_gift_times and inviteFriendData.award_gift_times > 0 then
    return true
  end
  return false
end
def.method("=>", "boolean").IsBindPhoneAwardOpen = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").IsBindPhone = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  local ECUniSDK = require("ProxySDK.ECUniSDK")
  if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
    return not ECUniSDK.Instance():IsBindPhone()
  else
    return false
  end
end
def.method("=>", "number").GetLimitTimeSingInActivityId = function(self)
  return constant.CLoginAwardCfgConsts.LOGIN_SIGN_ACTIVITY_CFG_ID
end
def.method().calcLimitTimeSignInRedPoint = function(self)
  local activityId = self:GetLimitTimeSingInActivityId()
  local isOpen = ActivityInterface.Instance():isActivityOpend(activityId)
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isServerOpen = feature:CheckFeatureOpen(Feature.TYPE_LOGIN_SIGN_ACTIVITY)
  local canGetAward = false
  if isOpen and isServerOpen then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local level = 0
    if heroProp ~= nil then
      level = heroProp.level
    end
    local needLv = constant.CLoginAwardCfgConsts.LOGIN_SIGN_ACTIVITY_LEVEL_LIMIT
    if level >= needLv then
      local LimitTimeSignInMgr = require("Main.CustomActivity.LimitTimeSignInMgr")
      local limitTimeSignInMgr = LimitTimeSignInMgr.Instance()
      local cfgList = CustomActivityInterface.GetLoginSignActivityCfg()
      for i, v in ipairs(cfgList) do
        if limitTimeSignInMgr:canGetSignInAward(i) then
          canGetAward = true
          break
        end
      end
    end
  end
  self.customActivityRed.Tab_QianDao = canGetAward
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, nil)
end
def.static("=>", "table").GetLoginSignActivityCfg = function()
  local signActivityId = instance:GetLimitTimeSingInActivityId()
  return CustomActivityInterface.GetLimitTimeSingInCfgByActivityId(signActivityId)
end
def.static("number", "=>", "table").GetLimitTimeSingInCfgByActivityId = function(activityId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_LOGIN_SIGN_ACTIVITY_CFG)
  if entries == nil then
    warn("!!!!!!!!GetLoginSignActivityCfg return ni")
    return {}
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  for j = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, j - 1)
    local curActivityId = record:GetIntValue("activityCfgid")
    if curActivityId == activityId then
      local cfg = {}
      cfg.id = record:GetIntValue("id")
      cfg.sortId = record:GetIntValue("sortId")
      cfg.awardCfgId = record:GetIntValue("awardCfgId")
      cfg.precious = record:GetCharValue("precious") ~= 0
      table.insert(cfgs, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local comp = function(cfg1, cfg2)
    return cfg1.sortId < cfg2.sortId
  end
  table.sort(cfgs, comp)
  return cfgs
end
return CustomActivityInterface.Commit()
