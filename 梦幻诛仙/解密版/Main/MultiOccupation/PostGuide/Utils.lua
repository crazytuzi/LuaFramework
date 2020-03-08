local FILE_NAME = (...)
local Lplus = require("Lplus")
local Utils = Lplus.Class(FILE_NAME)
local Cls = Utils
local def = Cls.define
local instance
def.static("userdata", "=>", "table")._readRecord = function(entries)
  if entries == nil then
    return nil
  end
  local res = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local guideid = record:GetIntValue("guideid")
    table.insert(res, guideid)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return res
end
def.static("=>", "table").GetJiaDainGuideIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_JD)
  if entries == nil then
    warn(string.format("[ERROR: Load all %s failed!]", CFG_PATH.DATA_POST_GUIDE_JD))
    return nil
  end
  return Cls._readRecord(entries)
end
def.static("=>", "table").GetEquipGuideIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_EQUIP)
  if entries == nil then
    warn(string.format("[ERROR: Load all %s failed!]", CFG_PATH.DATA_POST_GUIDE_EQUIP))
    return nil
  end
  return Cls._readRecord(entries)
end
def.static("=>", "table").GetTianShuGuideIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_TS)
  if entries == nil then
    warn(string.format("[ERROR: Load all %s failed!]", CFG_PATH.DATA_POST_GUIDE_TS))
    return nil
  end
  return Cls._readRecord(entries)
end
def.static("=>", "table").GetLongJingGuideIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_LJ)
  if entries == nil then
    warn(string.format("[ERROR: Load all %s failed!]", CFG_PATH.DATA_POST_GUIDE_LJ))
    return nil
  end
  return Cls._readRecord(entries)
end
def.static("=>", "table").GetLingShiGuideIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_LS)
  if entries == nil then
    warn(string.format("[ERROR: Load all %s failed!]", CFG_PATH.DATA_POST_GUIDE_LS))
    return nil
  end
  return Cls._readRecord(entries)
end
def.static("=>", "table").GetWingGuideIds = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_WING)
  if entries == nil then
    warn(string.format("[ERROR: Load all %s failed!]", CFG_PATH.DATA_POST_GUIDE_WING))
    return nil
  end
  return Cls._readRecord(entries)
end
def.static("=>", "table").ReadAllGuideCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POST_GUIDE_CFG)
  local res = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local guideType = record:GetIntValue("guideType")
    local name = record:GetStringValue("name")
    local iconId = record:GetIntValue("icon")
    local desc = record:GetStringValue("description")
    res[guideType] = {
      name = name,
      iconid = iconId,
      desc = desc,
      guideType = guideType
    }
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return res
end
return Cls.Commit()
