local Lplus = require("Lplus")
local FestivalCountDownUtils = Lplus.Class("FestivalCountDownUtils")
local def = FestivalCountDownUtils.define
local MAX_TIME_INTERNAL = 2592000
def.static("=>", "table", "table").GetAllValidCfg = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FESTIVAL_COUNT_DOWN_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local curTime = _G.GetServerTime()
  local cfg = {}
  local mapEffectCfg = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local festivalBeginTime = record:GetIntValue("festivalBeginTime")
    local mapEffectBeginTime = festivalBeginTime + record:GetIntValue("mapEffectStartInterVal")
    local mapEffectEndTime = festivalBeginTime + record:GetIntValue("mapEffectEndInterVal")
    local cfgId = record:GetIntValue("id")
    if curTime < festivalBeginTime and festivalBeginTime <= curTime + MAX_TIME_INTERNAL then
      cfg[cfgId] = {}
      local cache = cfg[cfgId]
      cache.cfgName = record:GetStringValue("name")
      cache.cfgDesc = record:GetStringValue("desc")
      cache.bulletinBeginTime = record:GetIntValue("bulletinBeginTime")
      cache.bulletinInterval = record:GetIntValue("bulletinInterval")
      cache.countdownEffectBeginTime = record:GetIntValue("countdownEffectBeginTime")
      cache.countdownEffectId = record:GetIntValue("countdownEffectId")
      cache.festivalBeginTime = festivalBeginTime
      cache.festivalEffectId = record:GetIntValue("festivalEffectId")
      cache.festivalEffectPlayTime = record:GetIntValue("festivalEffectPlayTime")
      cache.redPacketIconId = record:GetIntValue("redPacketIconId")
      cache.redPacketDesc = record:GetStringValue("redPacketDesc")
      cache.festivalSoundId = record:GetIntValue("festivalSoundId")
      cache.mapEffectBeginTime = mapEffectBeginTime
      cache.mapEffectEndTime = mapEffectEndTime
      mapEffectCfg[cfgId] = {}
      mapEffectCfg[cfgId].mapEffectId = record:GetIntValue("mapEffectId")
      mapEffectCfg[cfgId].mapEffectBeginTime = mapEffectBeginTime
      mapEffectCfg[cfgId].mapEffectEndTime = mapEffectEndTime
      mapEffectCfg[cfgId].effectMaps = {}
      local mapStruct = record:GetStructValue("mapStruct")
      local size = DynamicRecord.GetVectorSize(mapStruct, "mapVector")
      for i = 0, size - 1 do
        local mapRecord = DynamicRecord.GetVectorValueByIdx(mapStruct, "mapVector", i)
        local mapId = mapRecord:GetIntValue("mapId")
        table.insert(mapEffectCfg[cfgId].effectMaps, mapId)
      end
    elseif curTime >= mapEffectBeginTime and curTime < mapEffectEndTime then
      mapEffectCfg[cfgId] = {}
      local cache = mapEffectCfg[cfgId]
      cache.mapEffectId = record:GetIntValue("mapEffectId")
      cache.mapEffectBeginTime = mapEffectBeginTime
      cache.mapEffectEndTime = mapEffectEndTime
      cache.effectMaps = {}
      local mapStruct = record:GetStructValue("mapStruct")
      local size = DynamicRecord.GetVectorSize(mapStruct, "mapVector")
      for i = 0, size - 1 do
        local mapRecord = DynamicRecord.GetVectorValueByIdx(mapStruct, "mapVector", i)
        local mapId = mapRecord:GetIntValue("mapId")
        table.insert(cache.effectMaps, mapId)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return cfg, mapEffectCfg
end
def.static("=>", "table").GetFestivalMapEffectCfg = function()
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FESTIVAL_COUNT_DOWN_CFG)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  local curTime = _G.GetServerTime()
  local cfg = {}
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local mapEffectBeginTime = record:GetIntValue("mapEffectBeginTime")
    local mapEffectEndTime = record:GetIntValue("mapEffectEndTime")
    if curTime >= mapEffectBeginTime and curTime < mapEffectEndTime then
      local cfgId = record:GetIntValue("id")
      cfg[cfgId] = {}
      local cache = cfg[cfgId]
      cache.mapEffectBeginTime = mapEffectBeginTime
      cache.mapEffectEndTime = mapEffectEndTime
      cache.mapEffectId = record:GetIntValue("mapEffectId")
      cache.effectMaps = {}
      local mapStruct = record:GetStructValue("mapStruct")
      local size = DynamicRecord.GetVectorSize(mapStruct, "mapVector")
      for i = 0, size - 1 do
        local mapRecord = DynamicRecord.GetVectorValueByIdx(mapStruct, "mapVector", i)
        local mapId = mapRecord:GetIntValue("mapId")
        table.insert(cache)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  return cfg
end
def.static("table", "=>", "table").CheckValidNotGetRedPacketCfgId = function(notGetRedPacketCfgs)
  if nil == notGetRedPacketCfgs then
    return nil
  end
  local validCfg = {}
  local curTime = _G.GetServerTime()
  for k, v in pairs(notGetRedPacketCfgs) do
    local cfgId = v
    local record = DynamicData.GetRecord(CFG_PATH.DATA_FESTIVAL_COUNT_DOWN_CFG, cfgId)
    if record then
      local festivalBeginTime = record:GetIntValue("festivalBeginTime")
      local festivalEffectPlayTime = record:GetIntValue("festivalEffectPlayTime")
      local GetRedPacketNormalTime = festivalBeginTime + festivalEffectPlayTime + 5
      local redPacketDuringTime = record:GetIntValue("redPacketDuringTime")
      local GetRedPacketLastTime = festivalBeginTime + redPacketDuringTime
      if curTime > GetRedPacketNormalTime and curTime < GetRedPacketLastTime then
        validCfg[cfgId] = {}
        validCfg[cfgId].festivalEffectId = record:GetIntValue("festivalEffectId")
        validCfg[cfgId].festivalEffectPlayTime = festivalEffectPlayTime
        validCfg[cfgId].redPacketIconId = record:GetIntValue("redPacketIconId")
        validCfg[cfgId].redPacketDesc = record:GetStringValue("redPacketDesc")
        validCfg[cfgId].festivalSoundId = record:GetIntValue("festivalSoundId")
      end
    else
      warn("the invalid cfg id ~~~~ ")
    end
  end
  return validCfg
end
FestivalCountDownUtils.Commit()
return FestivalCountDownUtils
