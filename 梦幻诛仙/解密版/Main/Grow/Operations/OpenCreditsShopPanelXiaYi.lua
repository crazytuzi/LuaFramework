local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenCreditsShopPanelXiaYi = Lplus.Extend(Operation, CUR_CLASS_NAME)
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local def = OpenCreditsShopPanelXiaYi.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local tokenType = TokenType.XIAYI_VALUE
  local OpenCreditsShopPanel = import(".OpenCreditsShopPanel", CUR_CLASS_NAME)
  return OpenCreditsShopPanel():Operate({tokenType})
end
return OpenCreditsShopPanelXiaYi.Commit()
