local Lplus = require("Lplus")
local WeddingTourUtils = Lplus.Class("WeddingTourUtils")
local def = WeddingTourUtils.define
def.static("=>", "table").GetAllWeddingTourModes = function()
  local modes = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MARRIAGE_PARADE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local mode = {}
    mode.id = DynamicRecord.GetIntValue(entry, "id")
    mode.titleName = DynamicRecord.GetStringValue(entry, "titileName")
    mode.modelDisplayId = DynamicRecord.GetIntValue(entry, "modelDisplay")
    mode.cost = DynamicRecord.GetIntValue(entry, "yuanBaoNum")
    mode.desc = DynamicRecord.GetStringValue(entry, "paradeDes")
    mode.effects = {}
    local effectsStruct = entry:GetStructValue("palyEffectsStruct")
    local size = effectsStruct:GetVectorSize("palyEffects")
    for i = 0, size - 1 do
      local effect = effectsStruct:GetVectorValueByIdx("palyEffects", i)
      local effectId = effect:GetIntValue("playEffect")
      table.insert(mode.effects, effectId)
    end
    mode.paradeMapid = DynamicRecord.GetIntValue(entry, "paradeMapid")
    table.insert(modes, mode)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return modes
end
def.static("number", "=>", "table").GetWeddingTourModeById = function(id)
  local modeRecord = DynamicData.GetRecord(CFG_PATH.DATA_MARRIAGE_PARADE_CFG, id)
  if modeRecord == nil then
    warn(string.format("\230\184\184\232\161\151\230\168\161\230\157\191ID=%d\228\184\141\229\173\152\229\156\168", id))
    return nil
  end
  local mode = {}
  mode.id = DynamicRecord.GetIntValue(modeRecord, "id")
  mode.titleName = DynamicRecord.GetStringValue(modeRecord, "titileName")
  mode.modelDisplayId = DynamicRecord.GetIntValue(modeRecord, "modelDisplay")
  mode.cost = DynamicRecord.GetIntValue(modeRecord, "yuanBaoNum")
  mode.desc = DynamicRecord.GetStringValue(modeRecord, "paradeDes")
  mode.paradeMapid = DynamicRecord.GetIntValue(modeRecord, "paradeMapid")
  mode.prepareSec = DynamicRecord.GetIntValue(modeRecord, "prepareSec")
  mode.rideIconid = DynamicRecord.GetIntValue(modeRecord, "rideIconid")
  mode.effects = {}
  local effectsStruct = modeRecord:GetStructValue("palyEffectsStruct")
  local size = effectsStruct:GetVectorSize("palyEffects")
  for i = 0, size - 1 do
    local effect = effectsStruct:GetVectorValueByIdx("palyEffects", i)
    local effectId = effect:GetIntValue("playEffect")
    table.insert(mode.effects, effectId)
  end
  return mode
end
def.static("number", "=>", "table").GetWeddingTourPath = function(paradeCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MARRIAGE_PARADE_CONTROL_CFG, paradeCfgId)
  if record == nil then
    warn(string.format("GetWeddingTourPath(%d) return nil", paradeCfgId))
    return {}
  end
  local path = {}
  local paradeControlConfigsStruct = record:GetStructValue("paradeControlConfigsStruct")
  local size = paradeControlConfigsStruct:GetVectorSize("paradeControlConfigs")
  for i = 0, size - 1 do
    local rowRecord = paradeControlConfigsStruct:GetVectorValueByIdx("paradeControlConfigs", i)
    local pos = {
      idx = i + 1
    }
    pos.x = rowRecord:GetIntValue("x")
    pos.y = rowRecord:GetIntValue("y")
    table.insert(path, pos)
  end
  return path
end
WeddingTourUtils.Commit()
return WeddingTourUtils
