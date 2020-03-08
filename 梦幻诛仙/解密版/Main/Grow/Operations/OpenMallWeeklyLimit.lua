local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenMallWeeklyLimit = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenMallWeeklyLimit.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local itemId = 0
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, MallType.LIMIT_MALL)
  return false
end
return OpenMallWeeklyLimit.Commit()
