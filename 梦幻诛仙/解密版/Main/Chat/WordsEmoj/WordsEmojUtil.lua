local MODULE_NAME = (...)
local Lplus = require("Lplus")
local WordsEmojUtil = Lplus.Class(MODULE_NAME)
local Cls = WordsEmojUtil
local def = Cls.define
def.static("number", "=>", "string").GetWordsEmojById = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_WORDSEMOJ_CFG, id)
  if record == nil then
    warn("Load DATA_WORDSEMOJ_CFG error cfgId", id)
    return ""
  end
  local retData = record:GetStringValue("content")
  return retData
end
def.static("=>", "table").Load = function()
  local retData = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WORDSEMOJ_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = {}
    data.id = record:GetIntValue("id")
    data.name = record:GetStringValue("content")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
return Cls.Commit()
