local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenActivityPanelFestival = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenActivityPanelFestival.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  ActivityMain.Instance():ShowDlgToProductType(ActivityMain.ActivityType.FESTIVAL, ActivityMain.ProductType.ALL)
  return false
end
return OpenActivityPanelFestival.Commit()
