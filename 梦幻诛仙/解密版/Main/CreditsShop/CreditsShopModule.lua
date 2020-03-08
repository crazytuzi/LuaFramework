local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CreditsShopModule = Lplus.Extend(ModuleBase, "CreditsShopModule")
local def = CreditsShopModule.define
local CreditsShopPanel = require("Main.CreditsShop.ui.CreditsShopPanel")
local CreditsShopData = require("Main.CreditsShop.data.CreditsShopData")
local instance
def.static("=>", CreditsShopModule).Instance = function()
  if instance == nil then
    instance = CreditsShopModule()
    instance.m_moduleId = ModuleId.CREDITSSHOP
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, CreditsShopModule.OnCreditsShopPanelIconClick)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mall.SExchangeItemRes", CreditsShopModule.OnSExchangeItemRes)
end
def.static("table", "table").OnCreditsShopPanelIconClick = function(params, tbl)
  CreditsShopPanel.Instance():ShowPanel(params[1])
end
def.static("table").OnSExchangeItemRes = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(p.itemid)
  Toast(string.format(textRes.Mall[3], itemBase.name, p.num))
  Event.DispatchEvent(ModuleId.CREDITSSHOP, gmodule.notifyId.CreditsShop.SucceedBuyItem, {
    p.jifentype
  })
end
return CreditsShopModule.Commit()
