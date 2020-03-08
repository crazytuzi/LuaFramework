local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local BuyAndPublicCommon = require("Main.TradingArcade.ui.BuyAndPublicCommon")
local TradingArcadeBuy = Lplus.Extend(BuyAndPublicCommon, "TradingArcadeBuy")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local GUIUtils = require("GUI.GUIUtils")
local def = TradingArcadeBuy.define
local instance
def.static("=>", TradingArcadeBuy).Instance = function(self)
  if instance == nil then
    instance = TradingArcadeBuy()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  BuyAndPublicCommon.Init(self, base, node)
end
def.override().OnShow = function(self)
  BuyServiceMgr.Instance():SetMode(BuyServiceMgr.Mode.OnSell)
  BuyAndPublicCommon.OnShow(self)
end
def.override().UpdateStateBtn = function(self)
  self:ShowBuyBtn(true)
end
def.override("=>", "boolean").HasNotify = function(self)
  if self:HasSearchNotify() then
    return true
  end
  local BidMgr = require("Main.TradingArcade.BidMgr")
  if BidMgr.Instance():HasNotify() then
    return true
  end
  return false
end
def.override("=>", "boolean").HasSearchNotify = function(self)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  if CustomizedSearchMgr.Instance():HasOnSellNotify() then
    return true
  end
  return false
end
TradingArcadeBuy.Commit()
return TradingArcadeBuy
