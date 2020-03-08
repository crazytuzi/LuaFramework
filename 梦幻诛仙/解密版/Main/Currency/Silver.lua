local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CurrencyBase = import(".CurrencyBase")
local Silver = Lplus.Extend(CurrencyBase, CUR_CLASS_NAME)
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = Silver.define
local instance
def.static("=>", Silver).Instance = function()
  if instance == nil then
    instance = Silver.New()
  end
  return instance
end
def.static("=>", Silver).New = function()
  local instance = Silver()
  instance:Init()
  return instance
end
def.method().Init = function(self)
end
def.override("=>", "string").GetName = function(self)
  return textRes.Item.MoneyName[MoneyType.SILVER] or ""
end
def.override("=>", "string").GetSpriteName = function(self)
  return "Icon_Sliver"
end
def.override("=>", "userdata").GetHaveNum = function(self)
  return ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
end
def.override("function").RegisterCurrencyChangedEvent = function(self, func)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, func)
end
def.override("function").UnregisterCurrencyChangedEvent = function(self, func)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, func)
end
def.override().AcquireWithQuery = function(self)
  local needQuest = true
  _G.GoToBuySilver(needQuest)
end
def.override().OnAcquire = function(self)
  _G.GoToBuySilver()
end
return Silver.Commit()
