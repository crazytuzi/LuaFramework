_G.TABLERESPATH = {}
local GetCfgResPath = function()
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.model.confbean.CModelCfg.bny")
  local count = DynamicDataTable.GetRecordsCount(entries)
  local res
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "modelResPath")
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(TABLERESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  entries = DynamicData.GetTable("data/cfg/mzm.gsp.util.confbean.CIconResourceCfg.bny")
  count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "path")
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(TABLERESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  entries = DynamicData.GetTable("data/cfg/mzm.gsp.music.confbean.CMusicCfg.bny")
  count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "musicFilePath")
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(TABLERESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  entries = DynamicData.GetTable("data/cfg/mzm.gsp.task.confbean.COperaCfg.bny")
  count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "path")
    if res and res ~= "" then
      table.insert(TABLERESPATH, res)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  entries = DynamicData.GetTable("data/cfg/mzm.gsp.item.confbean.CEquipModelCfg.bny")
  count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "resPath")
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(TABLERESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
local resPaths = GetCfgResPath()
return TABLERESPATH
