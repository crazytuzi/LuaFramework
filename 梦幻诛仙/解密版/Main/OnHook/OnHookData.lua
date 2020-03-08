local Lplus = require("Lplus")
local OnHookData = Lplus.Class("OnHookData")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local def = OnHookData.define
local instance
def.field("table").onHookScenes = nil
def.static("=>", OnHookData).Instance = function()
  if nil == instance then
    instance = OnHookData()
    instance.onHookScenes = {}
  end
  return instance
end
def.static().InitOnHookScenesData = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ON_HOOK_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local sceneInfo = {}
    sceneInfo.sendMapId = DynamicRecord.GetIntValue(entry, "sendMapId")
    sceneInfo.mapName = DynamicRecord.GetStringValue(entry, "mapName")
    sceneInfo.minLevel = DynamicRecord.GetIntValue(entry, "minLevel")
    sceneInfo.maxLevel = DynamicRecord.GetIntValue(entry, "maxLevel")
    sceneInfo.unLockLevel = DynamicRecord.GetIntValue(entry, "unLockLevel")
    sceneInfo.priority = DynamicRecord.GetIntValue(entry, "priority")
    sceneInfo.samallMapPath = DynamicRecord.GetIntValue(entry, "samallMapPath")
    sceneInfo.funSwitchId = DynamicRecord.GetIntValue(entry, "moduleFunSwitchId")
    sceneInfo.mods = {}
    local modsRecord = DynamicData.GetRecord(CFG_PATH.DATA_MAP_MONSTER_CFG, sceneInfo.sendMapId)
    if nil ~= modsRecord then
      local modStruct = modsRecord:GetStructValue("monsterListStruct")
      local size = modStruct:GetVectorSize("invisibleMonsterList")
      for i = 0, size - 1 do
        local modInfoRecord = modStruct:GetVectorValueByIdx("invisibleMonsterList", i)
        local modId = modInfoRecord:GetIntValue("modelId")
        local modName = modInfoRecord:GetStringValue("name")
        table.insert(sceneInfo.mods, {modId = modId, modName = modName})
      end
      table.insert(OnHookData.Instance().onHookScenes, sceneInfo)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(OnHookData.Instance().onHookScenes, function(a, b)
    return a.priority < b.priority
  end)
end
def.static("=>", "table").GetAllOnHookScenes = function()
  local openedScenes = {}
  local scenes = OnHookData.Instance().onHookScenes
  for i = 1, #scenes do
    if FeatureOpenListModule.Instance():CheckFeatureOpen(scenes[i].funSwitchId) then
      table.insert(openedScenes, scenes[i])
    end
  end
  return openedScenes
end
def.static("number", "=>", "boolean").IsOnHookMap = function(mapId)
  for k, v in pairs(OnHookData.Instance().onHookScenes) do
    if v.sendMapId == mapId then
      return true
    end
  end
  return false
end
def.static("=>", "number").GetRecommendOnHookMapId = function()
  local onHookScenes = OnHookData.Instance().onHookScenes
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local level = prop.level
  local mapId = 0
  for i, v in ipairs(onHookScenes) do
    if level >= v.minLevel and level <= v.maxLevel then
      mapId = v.sendMapId
      break
    end
  end
  if mapId == 0 and #onHookScenes > 0 then
    mapId = onHookScenes[#onHookScenes].sendMapId
  end
  return mapId
end
OnHookData.Commit()
return OnHookData
