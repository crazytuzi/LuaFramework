local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local BuyAndPublicCommon = require("Main.TradingArcade.ui.BuyAndPublicCommon")
local TradingArcadePublic = Lplus.Extend(BuyAndPublicCommon, "TradingArcadePublic")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local GUIUtils = require("GUI.GUIUtils")
local def = TradingArcadePublic.define
local instance
def.static("=>", TradingArcadePublic).Instance = function(self)
  if instance == nil then
    instance = TradingArcadePublic()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  BuyAndPublicCommon.Init(self, base, node)
end
def.override().OnShow = function(self)
  BuyServiceMgr.Instance():SetMode(BuyServiceMgr.Mode.Public)
  BuyAndPublicCommon.OnShow(self)
end
def.override().UpdateStateBtn = function(self)
  self:ShowBuyBtn(false)
end
def.override("=>", "boolean").HasNotify = function(self)
  return self:HasSearchNotify()
end
def.override("=>", "boolean").HasSearchNotify = function(self)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  return CustomizedSearchMgr.Instance():HasPublicNotify()
end
TradingArcadePublic.Commit()
return TradingArcadePublic
