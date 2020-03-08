local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CurrencyFactory = Lplus.Class(CUR_CLASS_NAME)
local CurrencyBase = import(".CurrencyBase")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = CurrencyFactory.define
local function newObj(className)
  local Class = import("." .. className, CUR_CLASS_NAME)
  return Class.New()
end
local function getInstance(className)
  local Class = import("." .. className, CUR_CLASS_NAME)
  return Class.Instance()
end
def.static("number", "=>", CurrencyBase).Create = function(moneyType)
  return CurrencyFactory.MetaCreate(moneyType, newObj)
end
def.static("number", "=>", CurrencyBase).GetInstance = function(moneyType)
  return CurrencyFactory.MetaCreate(moneyType, getInstance)
end
def.static("number", "function", "=>", CurrencyBase).MetaCreate = function(moneyType, method)
  if moneyType == MoneyType.YUANBAO then
    return method("Yuanbao")
  elseif moneyType == MoneyType.GOLD then
    return method("Gold")
  elseif moneyType == MoneyType.SILVER then
    return method("Silver")
  elseif moneyType == MoneyType.GOLD_INGOT then
    return method("GoldIngot")
  elseif moneyType == MoneyType.GANGCONTRIBUTE then
    return method("GangContribute")
  else
    return method("CurrencyBase")
  end
end
return CurrencyFactory.Commit()
