local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenTradingArcadeSell = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenTradingArcadeSell.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_TradingArcade, {itemKey = 0, itemId = 0})
  return false
end
return OpenTradingArcadeSell.Commit()
