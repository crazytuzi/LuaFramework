local Lplus = require("Lplus")
local Operation = import(".Operation")
local OperationOpenWingPanel = Lplus.Extend(Operation, "OperationOpenWingPanel")
local def = OperationOpenWingPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.Wing.WingInterface").OpenWingPanel(1)
  return false
end
OperationOpenWingPanel.Commit()
return OperationOpenWingPanel
