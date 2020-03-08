_G.TABLE_MODEL_RESPATH = {}
local GetCfgResPath = function()
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.model.confbean.CModelCfg.bny")
  local count = DynamicDataTable.GetRecordsCount(entries)
  local res
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "modelResPath")
    print("model resName = " .. res)
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(TABLE_MODEL_RESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  entries = DynamicData.GetTable("data/cfg/mzm.gsp.util.confbean.CEffectSourceCfg.bny")
  count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "path")
    print("effect resName = " .. res)
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(TABLE_MODEL_RESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  print("res_end !")
end
local resPaths = GetCfgResPath()
return TABLE_MODEL_RESPATH
