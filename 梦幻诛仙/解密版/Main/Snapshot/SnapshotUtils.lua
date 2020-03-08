local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SnapshotUtils = Lplus.Class(MODULE_NAME)
local def = SnapshotUtils.define
def.static("=>", "table").GetAllFontColorCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNAPSHOT_CFontColorCfg)
  if entries == nil then
    warn(string.format("SnapshotUtils.GetAllFontColorCfgs failed"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.fontColor = record:GetIntValue("fontColor")
    cfg.sortid = record:GetIntValue("sortid")
    cfg.isDefault = record:GetCharValue("defaultOpt") == 1
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(lhs, rhs)
    return lhs.sortid < rhs.sortid
  end)
  return cfgs
end
def.static("=>", "table").GetAllFontSizeCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNAPSHOT_CFontSizeCfg)
  if entries == nil then
    warn(string.format("SnapshotUtils.GetAllFontSizeCfgs failed"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.fontSize = record:GetIntValue("fontSize")
    cfg.isDefault = record:GetCharValue("defaultOpt") == 1
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(lhs, rhs)
    return lhs.fontSize < rhs.fontSize
  end)
  return cfgs
end
def.static("=>", "table").GetAllTextBackgroundCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNAPSHOT_CTextBackgroundFrameCfg)
  if entries == nil then
    warn(string.format("SnapshotUtils.GetAllTextBackgroundCfgs failed"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.iconId = record:GetIntValue("iconRes")
    cfg.resId = record:GetIntValue("res")
    cfg.sortid = record:GetIntValue("sortid")
    cfg.isDefault = record:GetCharValue("defaultOpt") == 1
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(lhs, rhs)
    return lhs.sortid < rhs.sortid
  end)
  return cfgs
end
def.static("=>", "table").GetAllStickImageCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNAPSHOT_CTextureMappingCfg)
  if entries == nil then
    warn(string.format("SnapshotUtils.GetAllStickImageCfgs failed"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.iconId = record:GetIntValue("iconRes")
    cfg.resId = record:GetIntValue("res")
    cfg.sortid = record:GetIntValue("sortid")
    cfg.isDefault = record:GetCharValue("defaultOpt") == 1
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(lhs, rhs)
    return lhs.sortid < rhs.sortid
  end)
  return cfgs
end
def.static("=>", "table").GetAllImageFrameCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SNAPSHOT_CPhotoFrameCfg)
  if entries == nil then
    warn(string.format("SnapshotUtils.GetAllImageFrameCfgs failed"))
    return {}
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.iconId = record:GetIntValue("iconRes")
    cfg.resId = record:GetIntValue("res")
    cfg.sortid = record:GetIntValue("sortid")
    cfg.isDefault = record:GetCharValue("defaultOpt") == 1
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(lhs, rhs)
    return lhs.sortid < rhs.sortid
  end)
  return cfgs
end
return SnapshotUtils.Commit()
