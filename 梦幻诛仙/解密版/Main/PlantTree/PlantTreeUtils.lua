local Lplus = require("Lplus")
local PlantTreeUtils = Lplus.Class("PlantTreeUtils")
local def = PlantTreeUtils.define
def.static("=>", "table").GetModuleActs = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PLANT_TREE_MODULE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local retData = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local data = {}
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    data.moduleId = record:GetIntValue("moduleid")
    data.actId = record:GetIntValue("activity_cfg_id")
    table.insert(retData, data)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
return PlantTreeUtils.Commit()
