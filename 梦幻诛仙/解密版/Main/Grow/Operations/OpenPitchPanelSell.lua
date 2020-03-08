local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPitchPanelSell = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPitchPanelSell.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local tbl = {itemKey = 0, itemId = 0}
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_Pitch, tbl)
  return false
end
return OpenPitchPanelSell.Commit()
