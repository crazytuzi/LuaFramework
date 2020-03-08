local Lplus = require("Lplus")
local DeliveryGameUtils = Lplus.Class("DeliveryGameUtils")
local ActivitySubtype = require("consts.mzm.gsp.gratefuldelivery.confbean.ActivitySubtype")
local def = DeliveryGameUtils.define
def.static("=>", "table").GetAllDeliveryActivity = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DELIVERY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activityId")
    table.insert(list, activityId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("=>", "table").GetRelatedSwitch = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DELIVERY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activityId")
    local switchId = entry:GetIntValue("switchId")
    list[switchId] = list[switchId] or {}
    table.insert(list[switchId], activityId)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetDeliveryCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DELIVERY_CFG, activityId)
  if record == nil then
    warn("GetDeliveryCfg nil", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.switchId = record:GetIntValue("switchId")
  cfg.iconId = record:GetIntValue("itemIconId")
  cfg.maxDeliveryCount = record:GetIntValue("maxDeliveryCountPerDay")
  cfg.descId = record:GetIntValue("descriptionId")
  cfg.type = record:GetIntValue("activitySubtype")
  cfg.sendCardSpecialEffectId = record:GetIntValue("sendCardSpecialEffectId")
  cfg.sendCardTargetCount = record:GetIntValue("sendCardTargetCount")
  return cfg
end
def.static("number", "=>", "table").GetDeliverStageCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DELIVERY_STAGE_CFG, activityId)
  if not record then
    warn("GetDeliverStageCfg nil", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.stages = {}
  local stageStruct = record:GetStructValue("stageStruct")
  local stagesCount = DynamicRecord.GetVectorSize(stageStruct, "stages")
  for i = 0, stagesCount - 1 do
    local entry = stageStruct:GetVectorValueByIdx("stages", i)
    local count = entry:GetIntValue("count")
    local iconId = entry:GetIntValue("iconId")
    table.insert(cfg.stages, {count = count, iconId = iconId})
  end
  return cfg
end
def.static("number", "=>", "table").GetActivityRes = function(actId)
  local deliveryCfg = DeliveryGameUtils.GetDeliveryCfg(actId)
  local res = {}
  if deliveryCfg.type == ActivitySubtype.MOTHERSDAY then
    res.text = textRes.DeliveryGame.Mother
    res.PREFAB_DELIVERY_PANEL = RESPATH.PREFAB_DELIVERY_PANEL
    res.PREFAB_DELIVERY_NOTICE_BIG = RESPATH.PREFAB_DELIVERY_NOTICE_BIG
    res.PREFAB_DELIVERY_NOTICE_SMALL = RESPATH.PREFAB_DELIVERY_NOTICE_SMALL
    res.PREFAB_DELIVERY_TO = RESPATH.PREFAB_DELIVERY_TO
  elseif deliveryCfg.type == ActivitySubtype.FATHERSDAY then
    res.text = textRes.DeliveryGame.Father
    res.PREFAB_DELIVERY_PANEL = RESPATH.PREFAB_DELIVERY_PANEL_2
    res.PREFAB_DELIVERY_NOTICE_BIG = RESPATH.PREFAB_DELIVERY_NOTICE_BIG_2
    res.PREFAB_DELIVERY_NOTICE_SMALL = RESPATH.PREFAB_DELIVERY_NOTICE_SMALL_2
    res.PREFAB_DELIVERY_TO = RESPATH.PREFAB_DELIVERY_TO_2
  end
  return res
end
return DeliveryGameUtils.Commit()
