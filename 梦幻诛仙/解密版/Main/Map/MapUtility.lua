local Lplus = require("Lplus")
local MapUtility = Lplus.Class("MapUtility")
local def = MapUtility.define
def.static("number", "=>", "dynamic").GetMapCfg = function(mapid)
  local map = DynamicData.GetRecord(CFG_PATH.DATA_MAP_CONFIG, mapid)
  if map == nil then
    return nil
  end
  local cfg = {}
  cfg.mapId = map:GetIntValue("id")
  cfg.width = map:GetIntValue("width")
  cfg.height = map:GetIntValue("height")
  cfg.mapName = map:GetStringValue("mapName")
  cfg.mapResPath = map:GetStringValue("mapResPath")
  cfg.miniMapPath = map:GetStringValue("miniMapPath")
  cfg.defaultTransposX = map:GetIntValue("defaultTransposX")
  cfg.defaultTransposY = map:GetIntValue("defaultTransposY")
  cfg.mapDesc = map:GetStringValue("mapDesc")
  cfg.mapMark = map:GetIntValue("mapMarkValue")
  cfg.bgMusicIds = {}
  for i = 0, 9 do
    local bgMusicId = map:GetIntValue("bgMusicId" .. i)
    if bgMusicId > 0 then
      table.insert(cfg.bgMusicIds, bgMusicId)
    end
  end
  cfg.effMusicId = map:GetIntValue("effMusicId")
  cfg.battleBgId = map:GetIntValue("battleBgId")
  cfg.canFly = map:GetCharValue("canFly") ~= 0
  cfg.canPK = map:GetCharValue("canPK") ~= 0
  cfg.canDirectTransfer = map:GetCharValue("canDirectTransfer") ~= 0
  return cfg
end
def.static("string", "string", "=>", "dynamic").GetMapId = function(mapAtrrName, mapAtrrValue)
  local cfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MAP_CONFIG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  for i = 0, count - 1 do
    local map = DynamicDataTable.GetRecordByIdx(entries, i)
    cfg.mapId = map:GetIntValue("id")
    cfg.width = map:GetIntValue("width")
    cfg.height = map:GetIntValue("height")
    cfg.mapName = map:GetStringValue("mapName")
    cfg.mapResPath = map:GetStringValue("mapResPath")
    cfg.miniMapPath = map:GetStringValue("miniMapPath")
    cfg.defaultTransposX = map:GetIntValue("defaultTransposX")
    cfg.defaultTransposY = map:GetIntValue("defaultTransposY")
    if cfg[mapAtrrName] == mapAtrrValue then
      return cfg.mapId
    end
  end
  return nil
end
def.static("number", "=>", "number").GetOccupationMapId = function(occupationId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_OCCUPATION_PROP_TABLE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local i = 1
  local mapId
  for i = 0, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local id = DynamicRecord.GetIntValue(entry, "id")
    if DynamicRecord.GetIntValue(entry, "occupationId") == occupationId then
      mapId = DynamicRecord.GetIntValue(entry, "occupationMapId")
      break
    end
  end
  return mapId
end
def.static("number", "=>", "table").GetMiniMapNPC = function(mapId)
  local MiniMapNPCs = DynamicData.GetRecord(CFG_PATH.DATA_MINI_MAP_NPC_CONFIG, mapId)
  if MiniMapNPCs == nil then
    return {}
  end
  local npcVectorStruct = DynamicRecord.GetStructValue(MiniMapNPCs, "npcIdVectorStruct")
  local npcNum = DynamicRecord.GetVectorSize(npcVectorStruct, "npcIdVector")
  local npcs = {}
  for i = 1, npcNum do
    local npcVector = DynamicRecord.GetVectorValueByIdx(npcVectorStruct, "npcIdVector", i - 1)
    local npcId = DynamicRecord.GetIntValue(npcVector, "npcId")
    table.insert(npcs, npcId)
  end
  return npcs
end
def.static("number", "number", "number").TransportToMap = function(mapId, x, y)
  local targetPos = require("netio.protocol.mzm.gsp.map.Location").new()
  targetPos.x = x
  targetPos.y = y
  gmodule.moduleMgr:GetModule(ModuleId.HERO):EnterMap(mapId, targetPos)
end
def.static("number", "=>", "table").GetMapTransportCfg = function(mapTransferId)
  local transfer = DynamicData.GetRecord(CFG_PATH.DATA_MAP_TRANSPORT_CONFIG, mapTransferId)
  if transfer == nil then
    warn("GetMapTransferCfg(" .. mapTransferId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.mapId = transfer:GetIntValue("mapId")
  cfg.color = transfer:GetIntValue("color")
  return cfg
end
def.static("number", "=>", "table").GetMapTransfers = function(mapId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAP_TRANSFERS_CFG, mapId)
  if record == nil then
    warn("GetMapTransfersCfg(" .. mapId .. ") return nil")
    return nil
  end
  local cfg = {}
  local transfers = {}
  local size = record:GetVectorSize("rgnlist")
  for i = 0, size - 1 do
    local vectorRow = record:GetVectorValueByIdx("rgnlist", i)
    local row = {}
    row.center_x = vectorRow:GetIntValue("center_x")
    row.center_y = vectorRow:GetIntValue("center_y")
    row.default_target_map_id = vectorRow:GetIntValue("default_target_map_id")
    table.insert(transfers, row)
  end
  return transfers
end
def.static("number", "=>", "string").GetMiniMapResPath = function(mapId)
  local mapCfg = MapUtility.GetMapCfg(mapId)
  local resId = tonumber(mapCfg.miniMapPath)
  local resPath = GetIconPath(resId)
  return resPath
end
local PreloadResType = {ChangeMap = 1}
local mapTimer, mapTimeoutTimer
def.static().StartLoading = function(...)
  if mapTimer ~= nil then
    GameUtil.RemoveGlobalTimer(mapTimer)
  end
  MapUtility._NotifyLoadingProgress(0)
  mapTimer = GameUtil.AddGlobalTimer(0.1, false, function()
    if _G.MapNodeMax == 0 then
      return
    end
    local val = (_G.MapNodeMax - _G.MapNodeCount) / _G.MapNodeMax
    if _G.IsLoadMap == false then
      val = 1
      GameUtil.RemoveGlobalTimer(mapTimer)
      mapTimer = nil
      if mapTimeoutTimer then
        GameUtil.RemoveGlobalTimer(mapTimeoutTimer)
        mapTimeoutTimer = nil
      end
    end
    MapUtility._NotifyLoadingProgress(val)
  end)
  if mapTimeoutTimer then
    GameUtil.RemoveGlobalTimer(mapTimeoutTimer)
    mapTimeoutTimer = nil
  end
  mapTimeoutTimer = GameUtil.AddGlobalTimer(6, true, function()
    if _G.IsLoadMap then
      warn("Load map timeout")
      MapUtility._NotifyLoadingProgress(1)
      if mapTimer ~= nil then
        GameUtil.RemoveGlobalTimer(mapTimer)
      end
    end
  end)
  if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
    return
  end
  local taskList = {
    [PreloadResType.ChangeMap] = 1
  }
  local LoadingMgr = require("Main.Common.LoadingMgr")
  MapUtility.WatchMapLoading(function(value)
    if value >= 1 then
      Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.CHANGE_MAP_LOADING_FINISHED, nil)
    end
  end, true)
end
def.static().EndLoading = function(...)
  MapUtility._NotifyLoadingProgress(1)
  GameUtil.RemoveGlobalTimer(mapTimer)
  mapTimer = nil
  _G.IsLoadMap = false
end
local watchers = {}
def.static("function", "boolean").WatchMapLoading = function(handler, autoRemove)
  if handler == nil then
    return
  end
  watchers[handler] = {handler = handler, autoRemove = autoRemove}
end
def.static("function").UnwatchMapLoading = function(handler)
  if handler == nil then
    return
  end
  watchers[handler] = nil
end
def.static("number")._NotifyLoadingProgress = function(val)
  for k, watcher in pairs(watchers) do
    watcher.handler(val)
    if val == 1 and watcher.autoRemove then
      watchers[k] = nil
    end
  end
end
def.static("number", "=>", "table").GetMapStatueCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAP_STATUE_CONFIG, cfgId)
  if record == nil then
    Debug.LogWarning(string.format("GetMapStatueCfg get nil record for id : %d", cfgId))
    return nil
  end
  local cfg = {}
  cfg.occupation = record:GetIntValue("occupation")
  cfg.gender = record:GetIntValue("gender")
  cfg.modelId = record:GetIntValue("model")
  cfg.appellation = record:GetIntValue("appellation")
  cfg.title = record:GetIntValue("title")
  return cfg
end
def.static("number", "=>", "string").GetChineseNumber = function(num)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHINESE_NUMBER_CONFIG, num)
  if record == nil then
    Debug.LogWarning(string.format("[GetChineseNumber]get nil for number : %d", num))
    return ""
  end
  return record:GetStringValue("name")
end
MapUtility.Commit()
return MapUtility
