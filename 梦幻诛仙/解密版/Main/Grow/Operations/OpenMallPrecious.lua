local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenMallPrecious = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenMallPrecious.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
  local itemId = 0
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, MallType.PRECIOUS_MALL)
  return false
end
return OpenMallPrecious.Commit()
