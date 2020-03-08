local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenCreditsShopPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local def = OpenCreditsShopPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local tokenType = params[1] and params[1] or TokenType.XIAYI_VALUE
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {tokenType})
  return false
end
return OpenCreditsShopPanel.Commit()
