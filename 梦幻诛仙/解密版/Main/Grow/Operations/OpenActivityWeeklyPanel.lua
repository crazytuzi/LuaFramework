local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenActivityWeeklyPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenActivityWeeklyPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.activity.ui.ActivityWeekly").Instance():ShowDlg()
  return false
end
return OpenActivityWeeklyPanel.Commit()
