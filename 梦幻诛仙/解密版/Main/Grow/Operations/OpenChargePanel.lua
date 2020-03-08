local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenChargePanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenChargePanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  return true
end
return OpenChargePanel.Commit()
