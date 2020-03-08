local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenWingsPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenWingsPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.Wing.WingInterface").OpenWingPanel(1)
  return true
end
return OpenWingsPanel.Commit()
