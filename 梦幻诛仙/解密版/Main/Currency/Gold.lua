local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CurrencyBase = import(".CurrencyBase")
local Gold = Lplus.Extend(CurrencyBase, CUR_CLASS_NAME)
local ItemModule = require("Main.Item.ItemModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = Gold.define
local instance
def.static("=>", Gold).Instance = function()
  if instance == nil then
    instance = Gold.New()
  end
  return instance
end
def.static("=>", Gold).New = function()
  local instance = Gold()
  instance:Init()
  return instance
end
def.method().Init = function(self)
end
def.override("=>", "string").GetName = function(self)
  return textRes.Item.MoneyName[MoneyType.GOLD] or ""
end
def.override("=>", "string").GetSpriteName = function(self)
  return "Icon_Gold"
end
def.override("=>", "userdata").GetHaveNum = function(self)
  return ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
end
def.override("function").RegisterCurrencyChangedEvent = function(self, func)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, func)
end
def.override("function").UnregisterCurrencyChangedEvent = function(self, func)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, func)
end
def.override().AcquireWithQuery = function(self)
  local needQuest = true
  _G.GoToBuyGold(needQuest)
end
def.override().OnAcquire = function(self)
  _G.GoToBuyGold()
end
return Gold.Commit()
