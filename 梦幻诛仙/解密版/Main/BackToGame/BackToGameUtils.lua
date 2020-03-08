local Lplus = require("Lplus")
local BackToGameUtils = Lplus.Class("BackToGameUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = BackToGameUtils.define
def.static("userdata", "=>", "number").MsToDay = function(ms)
  local sec = (ms / 1000):ToNumber()
  return BackToGameUtils.SecToDay(sec)
end
def.static("number", "=>", "number").SecToDay = function(sec)
  local day = math.floor((sec + GetServerZoneOffset()) / 86400)
  return day
end
def.static("number", "=>", "table").GetBackGameActivity = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityCfg, activityId)
  if not record then
    warn("GetBackGameActivity nil:", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = activityId
  cfg.backGameCycleDay = record:GetIntValue("backGameCycleDay")
  cfg.signCfgId = record:GetIntValue("signCfgId")
  cfg.pointCfgId = record:GetIntValue("pointCfgId")
  cfg.expCfgId = record:GetIntValue("expCfgId")
  cfg.awardCfgId = record:GetIntValue("awardCfgId")
  cfg.giftCfgId = record:GetIntValue("giftCfgId")
  cfg.taskCfgId = record:GetIntValue("taskCfgId")
  cfg.rechargeCfgId = record:GetIntValue("rechargeCfgId")
  return cfg
end
def.static("number", "=>", "table").GetDailySignCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivitySignAwardCfg, id)
  if not record then
    warn("GetDailySignCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.signs = {}
  local signStruct = record:GetStructValue("signStruct")
  local signSize = DynamicRecord.GetVectorSize(signStruct, "signList")
  for i = 0, signSize - 1 do
    local rec = signStruct:GetVectorValueByIdx("signList", i)
    local awardId = rec:GetIntValue("awardId")
    table.insert(cfg.signs, awardId)
  end
  return cfg
end
def.static("number", "number", "=>", "number").GetDailySignCfgByLevel = function(cfgId, level)
  local typeId = BackToGameUtils.GetDailySignTypeCfg(cfgId)
  if typeId > 0 then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivitySignLevelTierCfg, typeId)
    if not record then
      warn("DATA_CBackGameActivitySignLevelTierCfg nil:", typeId)
      return 0
    end
    local levelStruct = record:GetStructValue("levelStruct")
    local levelSize = DynamicRecord.GetVectorSize(levelStruct, "levelList")
    for i = 0, levelSize - 1 do
      local rec = levelStruct:GetVectorValueByIdx("levelList", i)
      local minLevel = rec:GetIntValue("levelMin")
      local maxLevel = rec:GetIntValue("levelMax")
      warn("GetDailySignCfgByLevel", minLevel, maxLevel)
      if level >= minLevel and level <= maxLevel then
        local signAwardCfgTypeId = rec:GetIntValue("signAwardCfgTypeId")
        return signAwardCfgTypeId
      end
    end
    return 0
  else
    return 0
  end
end
def.static("number", "=>", "number").GetDailySignTypeCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivitySignCfg, id)
  if not record then
    warn("GetDailySignTypeCfg nil:", id)
    return 0
  end
  local typeId = record:GetIntValue("levelTierTypeId")
  return typeId
end
def.static("number", "=>", "number").GetJifenTipsId = function(id, day)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityPointCfg, id)
  if not record then
    warn("GetJifenTipsId nil:", id)
    return 0
  end
  local tipsId = record:GetIntValue("tipsId")
  return tipsId
end
def.static("number", "=>", "table").GetRelatedActivityIds = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityPointCfg, id)
  if not record then
    warn("GetRelatedActivityIds nil:", id)
    return nil
  end
  local list = {}
  local actStruct = record:GetStructValue("activityStruct")
  local actSize = DynamicRecord.GetVectorSize(actStruct, "activityList")
  for i = 0, actSize - 1 do
    local rec = actStruct:GetVectorValueByIdx("activityList", i)
    local activityId = rec:GetIntValue("activityId")
    list[activityId] = true
  end
  return list
end
def.static("number", "number", "=>", "table").GetJifenCfg = function(id, day)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityPointCfg, id)
  if not record then
    warn("GetJifenCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.tipsId = record:GetIntValue("tipsId")
  cfg.activity = {}
  local actStruct = record:GetStructValue("activityStruct")
  local actSize = DynamicRecord.GetVectorSize(actStruct, "activityList")
  for i = 0, actSize - 1 do
    local rec = actStruct:GetVectorValueByIdx("activityList", i)
    local activityId = rec:GetIntValue("activityId")
    local activityMaxCount = rec:GetIntValue("activityMaxCount")
    local pointCountEachRun = rec:GetIntValue("pointCountEachRun")
    table.insert(cfg.activity, {
      activityId = activityId,
      activityMaxCount = activityMaxCount,
      pointCountEachRun = pointCountEachRun
    })
  end
  cfg.items = {}
  local itemStruct = record:GetStructValue("itemStruct")
  local itemSize = DynamicRecord.GetVectorSize(itemStruct, "itemList")
  for i = 0, itemSize - 1 do
    local rec = itemStruct:GetVectorValueByIdx("itemList", i)
    local index = rec:GetIntValue("index")
    local showItemId = rec:GetIntValue("showItemId")
    table.insert(cfg.items, {index = index, showItemId = showItemId})
  end
  table.sort(cfg.items, function(a, b)
    return a.index < b.index
  end)
  return cfg
end
def.static("number", "number", "=>", "number").GetExpTypeIdByLevel = function(id, level)
  warn("GetExpTypeIdByLevel", id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityExpCfg, id)
  if not record then
    warn("GetExpTypeIdByLevel nil:", id)
    return 0
  end
  local levelStruct = record:GetStructValue("levelStruct")
  local levelSize = DynamicRecord.GetVectorSize(levelStruct, "levelList")
  for i = 0, levelSize - 1 do
    local rec = levelStruct:GetVectorValueByIdx("levelList", i)
    local minLevel = rec:GetIntValue("levelMin")
    local maxLevel = rec:GetIntValue("levelMax")
    if level >= minLevel and level <= maxLevel then
      local expawardTypeId = rec:GetIntValue("expawardTypeId")
      return expawardTypeId
    end
  end
  return 0
end
def.static("number", "=>", "table").GetExpCfg = function(id)
  warn("GetExpCfg", id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityExpAwardCfg, id)
  if not record then
    warn("GetExpCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.exps = {}
  cfg.total = 0
  local expStruct = record:GetStructValue("expStruct")
  local expSize = DynamicRecord.GetVectorSize(expStruct, "expList")
  for i = 0, expSize - 1 do
    local rec = expStruct:GetVectorValueByIdx("expList", i)
    local index = rec:GetIntValue("index")
    local awardId = rec:GetIntValue("awardId")
    local items = {}
    local itemStruct = rec:GetStructValue("itemStruct")
    local itemSize = DynamicRecord.GetVectorSize(itemStruct, "itemList")
    for i = 0, itemSize - 1 do
      local rec2 = itemStruct:GetVectorValueByIdx("itemList", i)
      local icon = rec2:GetIntValue("icon")
      local num = rec2:GetIntValue("num")
      if i == 0 then
        cfg.total = cfg.total + num
      end
      table.insert(items, {iconId = icon, num = num})
    end
    table.insert(cfg.exps, {index = index, items = items})
  end
  table.sort(cfg.exps, function(a, b)
    return a.index < b.index
  end)
  return cfg
end
def.static("number", "=>", "table").GetBackHomeAward = function(id)
  warn("GetBackHomeAward", id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityAwardTierCfg, id)
  if not record then
    warn("GetBackHomeAward nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.awardId = record:GetIntValue("awardId")
  cfg.buffId1 = record:GetIntValue("buffId1")
  cfg.buff1Desc = record:GetStringValue("buff1Desc")
  cfg.buffId2 = record:GetIntValue("buffId2")
  cfg.buff2Desc = record:GetStringValue("buff2Desc")
  return cfg
end
def.static("number", "=>", "table").GetTaskCfg = function(id)
  warn("GetTaskCfg", id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityTaskCfg, id)
  if not record then
    warn("GetTaskCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.graphId = record:GetIntValue("graphId")
  cfg.awardId = record:GetIntValue("awardId")
  cfg.memberCount = record:GetIntValue("memberCount")
  cfg.tipsId = record:GetIntValue("tipsId")
  cfg.teamPlatformId = record:GetIntValue("teamPlatformId")
  return cfg
end
def.static("number", "=>", "table").GetLimitSellCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityGiftCfg, id)
  if not record then
    warn("GetLimitSellCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.tier = {}
  local tierStruct = record:GetStructValue("tierStruct")
  local tierSize = DynamicRecord.GetVectorSize(tierStruct, "tierList")
  for i = 0, tierSize - 1 do
    local rec = tierStruct:GetVectorValueByIdx("tierList", i)
    local needRecharge = rec:GetIntValue("needRecharge")
    local goods = {}
    local itemStruct = rec:GetStructValue("itemStruct")
    local itemSize = DynamicRecord.GetVectorSize(itemStruct, "itemList")
    for i = 0, itemSize - 1 do
      local rec2 = itemStruct:GetVectorValueByIdx("itemList", i)
      local giftItemCfgId = rec2:GetIntValue("giftItemCfgId")
      local giftItemCfg = BackToGameUtils.GetLimitSellItemCfg(giftItemCfgId)
      if giftItemCfg then
        table.insert(goods, {
          id = giftItemCfg.id,
          itemId = giftItemCfg.itemId,
          price = giftItemCfg.price,
          originalPrice = giftItemCfg.originalPrice,
          buyCount = giftItemCfg.buyCount,
          refreshType = giftItemCfg.refreshType
        })
      end
    end
    table.insert(cfg.tier, {needRecharge = needRecharge, goods = goods})
  end
  return cfg
end
def.static("number", "=>", "table").GetLimitSellItemCfg = function(id)
  warn("GetLimitSellItemCfg", id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityGiftItemCfg, id)
  if not record then
    warn("GetLimitSellItemCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.originalPrice = record:GetIntValue("originalPrice")
  cfg.price = record:GetIntValue("price")
  cfg.buyCount = record:GetIntValue("buyCount")
  cfg.itemId = record:GetIntValue("itemId")
  cfg.refreshType = record:GetIntValue("refreshType")
  return cfg
end
def.static("number", "=>", "table").GetAccumulateRechargeCfg = function(id)
  local rechargeRecord = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityRechargeCfg, id)
  if not rechargeRecord then
    warn("Get CBackGameActivityRechargeCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = rechargeRecord:GetIntValue("id")
  cfg.tipId = rechargeRecord:GetIntValue("tipId")
  cfg.accumulateRechargeTypeId = rechargeRecord:GetIntValue("accumulateRechargeTypeId")
  cfg.accumulateRecharge = {}
  local accumulateRecord = DynamicData.GetRecord(CFG_PATH.DATA_CTBackGameActivityAccumulateRechargeCfg, cfg.accumulateRechargeTypeId)
  if not accumulateRecord then
    warn("Get CTBackGameActivityAccumulateRechargeCfg nil:", cfg.accumulateRechargeTypeId)
  else
    local accumulateStruct = accumulateRecord:GetStructValue("rechargeStruct")
    local accumulateCount = accumulateStruct:GetVectorSize("rechargeList")
    for i = 1, accumulateCount do
      local accumulateCfg = accumulateStruct:GetVectorValueByIdx("rechargeList", i - 1)
      local seg = {}
      seg.accumulateRechargeCount = accumulateCfg:GetIntValue("accumulateRechargeCount")
      seg.rechargeAwardTypeId = accumulateCfg:GetIntValue("rechargeAwardTypeId")
      seg.rechargeAwards = {}
      table.insert(cfg.accumulateRecharge, seg)
      local awardRecord = DynamicData.GetRecord(CFG_PATH.DATA_CTBackGameActivityRechargeAwardCfg, seg.rechargeAwardTypeId)
      if not awardRecord then
        warn("Get CTBackGameActivityRechargeAwardCfg nil:", seg.rechargeAwardTypeId)
      else
        local awardStruct = awardRecord:GetStructValue("awardStruct")
        local awardCount = awardStruct:GetVectorSize("awardList")
        for i = 1, awardCount do
          local awardCfg = awardStruct:GetVectorValueByIdx("awardList", i - 1)
          local award = {}
          award.manekiTokenCfgId = awardCfg:GetIntValue("manekiTokenCfgId")
          award.manekiTokenCount = awardCfg:GetIntValue("manekiTokenCount")
          award.index = 1
          local awardCfg = BackToGameUtils.GetRechargeAwardCfg(award.manekiTokenCfgId)
          if awardCfg then
            award.index = awardCfg.index
          end
          table.insert(seg.rechargeAwards, award)
        end
      end
      table.sort(seg.rechargeAwards, function(a, b)
        return a.index < b.index
      end)
    end
  end
  table.sort(cfg.accumulateRecharge, function(a, b)
    return a.accumulateRechargeCount < b.accumulateRechargeCount
  end)
  return cfg
end
def.static("number", "=>", "table").GetRechargeAwardCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CBackGameActivityManekiTokenCfg, id)
  if not record then
    warn("GetRechargeAwardCfg nil:", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.manekiTokenName = record:GetStringValue("manekiTokenName")
  cfg.manekiTokenIconId = record:GetIntValue("manekiTokenIconId")
  cfg.manekiNekoName = record:GetStringValue("manekiNekoName")
  cfg.manekiNekoHappyIconId = record:GetIntValue("manekiNekoHappyIconId")
  cfg.manekiNekoUnhappyIconId = record:GetIntValue("manekiNekoUnhappyIconId")
  cfg.manekiNekoLightEffectId = record:GetIntValue("manekiNekoLightEffectId")
  cfg.index = record:GetIntValue("index")
  cfg.getYuanBaoCount = record:GetIntValue("getYuanBaoCount")
  return cfg
end
def.static("=>", "table").GetAllRechargeAwardCfg = function()
  local awards = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CBackGameActivityManekiTokenCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.manekiTokenName = entry:GetStringValue("manekiTokenName")
    cfg.manekiTokenIconId = entry:GetIntValue("manekiTokenIconId")
    cfg.manekiNekoName = entry:GetStringValue("manekiNekoName")
    cfg.manekiNekoHappyIconId = entry:GetIntValue("manekiNekoHappyIconId")
    cfg.manekiNekoUnhappyIconId = entry:GetIntValue("manekiNekoUnhappyIconId")
    cfg.manekiNekoLightEffectId = entry:GetIntValue("manekiNekoLightEffectId")
    cfg.index = entry:GetIntValue("index")
    cfg.getYuanBaoCount = entry:GetIntValue("getYuanBaoCount")
    table.insert(awards, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(awards, function(a, b)
    return a.index < b.index
  end)
  return awards
end
BackToGameUtils.Commit()
return BackToGameUtils
