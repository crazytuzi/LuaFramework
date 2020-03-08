local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenMallToNode = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenMallToNode.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local node = tonumber(params[1])
  local itemId = tonumber(params[2] or 0)
  if node then
    local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, node)
    return true
  else
    return false
  end
  return false
end
return OpenMallToNode.Commit()
