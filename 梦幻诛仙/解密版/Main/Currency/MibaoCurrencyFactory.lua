local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MibaoCurrencyFactory = Lplus.Class(CUR_CLASS_NAME)
local CurrencyBase = import(".CurrencyBase")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local def = MibaoCurrencyFactory.define
local function create(className)
  local Class = import("." .. className, CUR_CLASS_NAME)
  return Class.New()
end
def.static("number", "=>", CurrencyBase).Create = function(currencyType)
  if currencyType == CurrencyType.YUAN_BAO then
    return create("Yuanbao")
  elseif currencyType == CurrencyType.GOLD then
    return create("Gold")
  else
    return create("CurrencyBase")
  end
end
return MibaoCurrencyFactory.Commit()
