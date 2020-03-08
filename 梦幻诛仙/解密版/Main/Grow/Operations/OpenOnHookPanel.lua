local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenOnHookPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenOnHookPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.OnHook.OnHookModule").ShowPanel()
  return false
end
return OpenOnHookPanel.Commit()
