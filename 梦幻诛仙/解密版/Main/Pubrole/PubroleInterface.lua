local Lplus = require("Lplus")
local PubroleInterface = Lplus.Class("PubroleInterface")
local def = PubroleInterface.define
def.static("number", "number", "=>", "number").FindModelIDByOccupationId = function(occupationId, gender)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_OCCUPATION_PROP_TABLE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local ret = 0
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfgID = DynamicRecord.GetIntValue(entry, "occupationId")
    local cfgGender = DynamicRecord.GetIntValue(entry, "gender")
    if cfgID == occupationId and cfgGender == gender then
      ret = DynamicRecord.GetIntValue(entry, "modelPath")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return ret
end
def.static("number", "=>", "table").GetModelCfg = function(modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  if modelRecord == nil then
    warn("PubroleInterface.GetModelCfg(", modelId, ") == nil")
    return nil
  end
  local cfg = {}
  cfg.id = modelRecord:GetIntValue("id")
  cfg.halfBodyIconId = modelRecord:GetIntValue("halfBodyIconId")
  cfg.headerIconId = modelRecord:GetIntValue("headerIconId")
  cfg.dyeColorId = modelRecord:GetIntValue("dyeColorId")
  cfg.modelResPath = modelRecord:GetStringValue("modelResPath")
  return cfg
end
def.static("number", "=>", "number").GetHalfBodyByModel = function(modelId)
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  if modelRecord == nil then
    return 0
  end
  local iconId = modelRecord:GetIntValue("halfBodyIconId")
  return iconId
end
def.static("number", "number").RequestMonsterPositionFromServer = function(cfgId, mapId)
  local request = require("netio.protocol.mzm.gsp.map.CGetMonsterLocationReq").new(cfgId, mapId)
  gmodule.network.sendProtocol(request)
end
PubroleInterface.Commit()
return PubroleInterface
