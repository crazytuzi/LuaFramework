local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local GUIUtils = require("GUI.GUIUtils")
local AuctionModule = require("Main.Auction.AuctionModule")
local ActivityInterface = require("Main.activity.ActivityInterface")
local CarnivalUtils = require("Main.Carnival.CarnivalUtils")
local AuctionEntry = Lplus.Extend(TopFloatBtnBase, MODULE_NAME)
local def = AuctionEntry.define
local instance
def.static("=>", AuctionEntry).Instance = function()
  if instance == nil then
    instance = AuctionEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return AuctionModule.Instance():NeedShowEntrance()
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  self:_HandleEventListeners(true)
end
def.override().OnHide = function(self)
  self:_HandleEventListeners(false)
end
def.method().UpdateNotifyBadge = function(self)
  local hasNotify = AuctionModule.Instance():NeedReddot()
  if hasNotify then
    GUIUtils.SetLightEffect(self.m_node, GUIUtils.Light.Round)
  else
    GUIUtils.SetLightEffect(self.m_node, GUIUtils.Light.None)
  end
end
def.override("string").onClick = function(self, id)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AUCTION_CLICK, nil)
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_REDDOT_CHANGE, AuctionEntry.OnNotifyUpdate)
  end
end
def.static("table", "table").OnNotifyUpdate = function(params, context)
  if instance then
    instance:UpdateNotifyBadge()
  end
end
return AuctionEntry.Commit()
