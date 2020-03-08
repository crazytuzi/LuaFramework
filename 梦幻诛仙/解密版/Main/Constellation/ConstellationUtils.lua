local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ConstellationsUtils = Lplus.Class(MODULE_NAME)
local def = ConstellationsUtils.define
def.static("string", "=>", "dynamic").GetConstant = function(name)
  return constant.CConstellationConsts[name]
end
def.static("number", "=>", "table").GetCardStarCfg = function(starLevel)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CONSTELLATION_CARD_START_CFG, starLevel)
  if record == nil then
    warn(string.format("GetCardStarCfg(%d) return nil", starLevel))
    return nil
  end
  local cfg = {}
  cfg.starLevel = starLevel
  cfg.icon = record:GetIntValue("icon")
  return cfg
end
def.static("number", "=>", "table").GetConstellationCfg = function(constellation)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CONSTELLATION_CFG, constellation)
  if record == nil then
    warn(string.format("GetConstellationCfg(%d) return nil", constellation))
    return nil
  end
  local cfg = {}
  cfg.constellation = constellation
  cfg.icon = record:GetIntValue("icon")
  cfg.name = record:GetStringValue("name")
  cfg.fortunes = {}
  local fortunesStruct = record:GetStructValue("fortunesStruct")
  local fortunesSize = DynamicRecord.GetVectorSize(fortunesStruct, "fortunes")
  for i = 0, fortunesSize - 1 do
    local rec = fortunesStruct:GetVectorValueByIdx("fortunes", i)
    local fortune = rec:GetStringValue("fortune")
    table.insert(cfg.fortunes, fortune)
  end
  return cfg
end
def.static("=>", "table").GetAllConstellations = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CONSTELLATION_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local constellations = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local constellation = DynamicRecord.GetIntValue(entry, "constellation")
    constellations[#constellations + 1] = constellation
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return constellations
end
return ConstellationsUtils.Commit()
