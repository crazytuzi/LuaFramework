local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenSpecialTrafficURL = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenSpecialTrafficURL.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local FreeFlowMgr = require("Main.FreeFlow.FreeFlowMgr")
  FreeFlowMgr.Instance():OpenSpecialTrafficURL()
  return false
end
return OpenSpecialTrafficURL.Commit()
