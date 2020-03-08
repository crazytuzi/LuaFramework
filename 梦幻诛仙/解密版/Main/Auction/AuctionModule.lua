local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local AuctionData = require("Main.Auction.data.AuctionData")
local AuctionModule = Lplus.Extend(ModuleBase, "AuctionModule")
local instance
local def = AuctionModule.define
def.static("=>", AuctionModule).Instance = function()
  if instance == nil then
    instance = AuctionModule()
  end
  return instance
end
def.field("boolean")._bReddot = false
def.field("boolean")._bShowEntrance = false
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.Auction.AuctionProtocols").RegisterProtocols()
  require("Main.Auction.AuctionMgr").Instance():Init()
  AuctionData.Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  elseif false == self:ReachMinLevel(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AUCTION)
  if false == result and bToast then
    Toast(textRes.Auction.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("boolean", "=>", "boolean").ReachMinLevel = function(self, bToast)
  local result = false
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local minOpenLevel = AuctionData.Instance():GetMinOpenLevel()
  if heroProp ~= nil then
    local rolelevel = heroProp.level
    result = minOpenLevel <= rolelevel
  end
  if bToast and false == result then
    Toast(string.format(textRes.Auction.NOT_OPEN_LOW_LEVEL, minOpenLevel))
  end
  return result
end
def.method("boolean", "boolean").SetReddot = function(self, value, bForce)
  if not bForce and self._bReddot == value then
    return
  end
  warn("[AuctionModule:SetReddot] SetReddot:", value, debug.traceback())
  self._bReddot = value
  Event.DispatchEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_REDDOT_CHANGE, {bRed = value})
end
def.method("=>", "boolean").GetReddot = function(self)
  return self._bReddot
end
def.method("=>", "boolean").NeedReddot = function(self)
  return self:IsOpen(false) and self:GetReddot()
end
def.method("boolean", "boolean").SetShowEntrance = function(self, value, bForce)
  if not bForce and self._bShowEntrance == value then
    return
  end
  warn("[AuctionModule:SetShowEntrance] SetShowEntrance:", value, debug.traceback())
  self._bShowEntrance = value
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
end
def.method("=>", "boolean").NeedShowEntrance = function(self)
  return self:IsOpen(false) and self._bShowEntrance
end
return AuctionModule.Commit()
