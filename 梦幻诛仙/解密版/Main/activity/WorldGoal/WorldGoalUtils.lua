local Lplus = require("Lplus")
local WorldGoalUtils = Lplus.Class("WorldGoalUtils")
local def = WorldGoalUtils.define
def.static("=>", "table").GetAllActivityCfg = function(self)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    if nil == cfg[activityId] then
      cfg[activityId] = {}
      local cache = cfg[activityId]
      cache.moduleId = record:GetIntValue("moduleid")
      cache.activityType = record:GetIntValue("activity_type")
      cache.enterNpcId = record:GetIntValue("activitenter_activity_map_npc_idyId")
      cache.enterNpcServiceId = record:GetIntValue("enter_activity_map_service_id")
      cache.mainNpcId = record:GetIntValue("npcId")
      cache.entityNpcId = record:GetIntValue("entityNpcId")
      cache.commitServiceId = record:GetIntValue("commitServiceId")
      cache.queryServiceId = record:GetIntValue("queryServiceId")
      cache.enterActivityMapId = record:GetIntValue("enter_activity_map_transfer_map_cfg_id")
      cache.totalCommitLimitNum = WorldGoalUtils.GetActicityCommitLimitNum(activityId)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return cfg
end
def.static("number", "=>", "number", "number").GetNpcIdByActivityId = function(targetActivityId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local mainNpcId = record:GetIntValue("npcId")
    local entityNpcId = record:GetIntValue("entityNpcId")
    if targetActivityId == activityId then
      return mainNpcId, entityNpcId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0, 0
end
def.static("number", "=>", "table").GetEntityModelPartInfo = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WORLD_GOAL_CFG, cfgId)
  if nil == record then
    warn("not find the world goal cfg ~~~~~~~~~~~~~ ", cfgId)
    return nil
  end
  local parts = {}
  local partStruct = record:GetStructValue("modelPartStruct")
  local vectorCount = DynamicRecord.GetVectorSize(partStruct, "modelPartVector")
  for i = 0, vectorCount - 1 do
    local partRecord = DynamicRecord.GetVectorValueByIdx(partStruct, "modelPartVector", i)
    local partName = partRecord:GetStringValue("modelPartName")
    table.insert(parts, partName)
  end
  return parts
end
def.static("number", "number", "=>", "number").GetActivityIdByNPCIdAndServiceId = function(npcId, serviceId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local mainNpcId = record:GetIntValue("npcId")
    local entityNpcId = record:GetIntValue("entityNpcId")
    local commitServiceId = record:GetIntValue("commitServiceId")
    local queryServiceId = record:GetIntValue("queryServiceId")
    local enterNpcId = record:GetIntValue("activitenter_activity_map_npc_idyId")
    local enterNpcServiceId = record:GetIntValue("enter_activity_map_service_id")
    local isRightNpcId = npcId == mainNpcId or npcId == entityNpcId or npcId == enterNpcId
    local isRightServiceId = serviceId == commitServiceId or serviceId == queryServiceId or serviceId == enterNpcServiceId
    if isRightServiceId and isRightNpcId then
      return activityId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("number", "=>", "number", "number").GetCommitAndQueryServiceId = function(targetActivityId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local commitServiceId = record:GetIntValue("commitServiceId")
    local queryServiceId = record:GetIntValue("queryServiceId")
    if targetActivityId == activityId then
      return commitServiceId, queryServiceId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0, 0
end
def.static("number", "=>", "number").GetActicityCommitLimitNum = function(targetActivityId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local commitLimitNum = record:GetIntValue("commitLimitNum")
    if targetActivityId == activityId then
      return commitLimitNum
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("number", "=>", "number", "number").GetSectionEffectInfo = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WORLD_GOAL_CFG, cfgId)
  if nil == record then
    warn("not find the world goal cfg ~~~~~~~~~~~~~ ")
    return 0, 0
  end
  local effectId = record:GetIntValue("effectId") or 0
  local effectPersistTime = record:GetIntValue("effectPersistTime") or 0
  return effectId, effectPersistTime
end
def.static("number", "=>", "table").GetActivityInfoByCfgId = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WORLD_GOAL_CFG, cfgId)
  if nil == record then
    warn("not find the world goal cfg ~~~~~~~~~~~~~ ")
    return nil
  end
  local cfgInfo = {}
  cfgInfo.activityId = record:GetIntValue("activityId")
  cfgInfo.sectionId = record:GetIntValue("sectionId")
  cfgInfo.mainNpcId = record:GetIntValue("npcId")
  cfgInfo.entityNpcId = record:GetIntValue("entityNpcId")
  cfgInfo.mapId = record:GetIntValue("mapId")
  cfgInfo.effectId = record:GetIntValue("effectId") or 0
  cfgInfo.effectPersistTime = record:GetIntValue("effectPersistTime") or 0
  cfgInfo.triggerPoint = record:GetIntValue("triggerPoint")
  return cfgInfo
end
def.static("number", "number", "=>", "number").GetSectionTotalPoint = function(targetActivityId, targetSectionId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local sectionId = record:GetIntValue("sectionId")
    local sectionTotalPoint = record:GetIntValue("sectionTotalPoint")
    if targetActivityId == activityId and targetSectionId == sectionId then
      return sectionTotalPoint
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return 0
end
def.static("number", "number", "=>", "table").GetSectionMapInfo = function(targetActivityId, targetSectionId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local sectionId = record:GetIntValue("sectionId")
    local mapId = record:GetIntValue("mapId")
    local posX = record:GetIntValue("entityPosX")
    local posY = record:GetIntValue("entityPosY")
    if targetActivityId == activityId and targetSectionId == sectionId then
      return {
        mapId = mapId,
        pos = {x = posX, y = posY}
      }
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return nil
end
def.static("number", "=>", "table").GetActivityCommitItemInfo = function(targetActivityId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_WORLD_GOAL_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local siftItemId = 0
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local activityId = record:GetIntValue("activityId")
    local equalPriceId = record:GetIntValue("equalPriceId")
    if targetActivityId == activityId then
      siftItemId = equalPriceId
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  if 0 ~= siftItemId then
    local ItemUtils = require("Main.Item.ItemUtils")
    local siftItemCfg = ItemUtils.GetItemFilterCfg(siftItemId)
    local commitItemCfg = {}
    commitItemCfg.siftName = siftItemCfg.name
    commitItemCfg.itemInfo = {}
    for k, v in pairs(siftItemCfg.siftCfgs) do
      local itemId = v.idvalue
      local itemBase = ItemUtils.GetItemBase(itemId)
      local itemCfg = {}
      itemCfg.itemId = itemId
      itemCfg.itemName = itemBase.name
      table.insert(commitItemCfg.itemInfo, itemCfg)
    end
    return commitItemCfg
  end
  return nil
end
WorldGoalUtils.Commit()
return WorldGoalUtils
