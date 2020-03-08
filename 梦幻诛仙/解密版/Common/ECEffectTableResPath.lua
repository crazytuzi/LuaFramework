_G.EFFECTTABLERESPATH = {}
local GetCfgResPath = function()
  local res
  local entries = DynamicData.GetTable("data/cfg/mzm.gsp.util.confbean.CEffectSourceCfg.bny")
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    res = DynamicRecord.GetStringValue(entry, "path")
    if res and res ~= "" then
      local resName = res .. ".u3dext"
      table.insert(EFFECTTABLERESPATH, resName)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
local resPaths = GetCfgResPath()
return EFFECTTABLERESPATH
