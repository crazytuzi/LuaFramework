local Lplus = require("Lplus")
local AuctionData = require("Main.Auction.data.AuctionData")
local ItemUtils = require("Main.Item.ItemUtils")
local AuctionProtocols = Lplus.Class("AuctionProtocols")
local def = AuctionProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SGetAuctionInfoRsp", AuctionProtocols.OnSGetAuctionInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SGetAuctionInfoError", AuctionProtocols.OnSGetAuctionInfoError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SSynAuctionItemInfo", AuctionProtocols.OnSSynAuctionItemInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SGetAuctionItemInfoError", AuctionProtocols.OnSGetAuctionItemInfoError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SBidRsp", AuctionProtocols.OnSBidRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SBidError", AuctionProtocols.OnSBidError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SGetBidRankRsp", AuctionProtocols.OnSGetBidRankRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.auction.SGetBidRankError", AuctionProtocols.OnSGetBidRankError)
end
def.static("number", "number").SendCGetAuctionInfoReq = function(activityId, roundIdx)
  warn("[AuctionProtocols:SendCGetAuctionInfoReq] Send CGetAuctionInfoReq:", activityId, roundIdx)
  local p = require("netio.protocol.mzm.gsp.auction.CGetAuctionInfoReq").new(activityId, roundIdx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetAuctionInfoRsp = function(p)
  warn("[AuctionProtocols:OnSGetAuctionInfoRsp] On SGetAuctionInfoRsp:", p.activityId, p.turnIndex, p.itemInfoList and #p.itemInfoList)
  if p.itemInfoList and #p.itemInfoList > 0 then
    for _, itemInfo in ipairs(p.itemInfoList) do
      AuctionData.Instance():SyncItemInfo(p.activityId, p.turnIndex, itemInfo, false)
    end
    Event.DispatchEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_ITEMS_CHANGE, {
      activityId = p.activityId,
      roundIdx = p.turnIndex
    })
  end
  require("Main.Auction.AuctionMgr").OnSGetAuctionInfoRsp(p)
end
def.static("table").OnSGetAuctionInfoError = function(p)
  warn("[AuctionProtocols:OnSGetAuctionInfoError] On SGetAuctionInfoError! p.errorCode:", p.errorCode)
  local errString = textRes.Auction.SGetAuctionInfoError[p.errorCode]
  if errString then
    Toast(errString)
  end
end
def.static("number", "number", "number").SendCGetAuctionItemInfoReq = function(activityId, roundIdx, auctionitemId)
  warn("[AuctionProtocols:SendCGetAuctionItemInfoReq] Send CGetAuctionItemInfoReq:", activityId, roundIdx, auctionitemId)
  local p = require("netio.protocol.mzm.gsp.auction.CGetAuctionItemInfoReq").new(activityId, roundIdx, auctionitemId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSSynAuctionItemInfo = function(p)
  warn("[AuctionProtocols:OnSSynAuctionItemInfo] On SSynAuctionItemInfo:", p.activityId, p.turnIndex)
  local auctionItemInfo = AuctionData.Instance():GetItemInfo(p.activityId, p.turnIndex, p.itemInfo.itemCfgId)
  if auctionItemInfo and Int64.eq(auctionItemInfo.bidderRoleId, _G.GetMyRoleID()) and not Int64.eq(auctionItemInfo.bidderRoleId, p.itemInfo.bidderRoleId) then
    local itemId = auctionItemInfo:GetItemId()
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase then
      local str = string.format(textRes.Auction.AUCTION_BID_SURPASSED, itemBase.name)
      Toast(str)
    end
  end
  AuctionData.Instance():SyncItemInfo(p.activityId, p.turnIndex, p.itemInfo, true)
end
def.static("table").OnSGetAuctionItemInfoError = function(p)
  warn("[AuctionProtocols:OnSGetAuctionItemInfoError] On SGetAuctionItemInfoError! p.errorCode:", p.errorCode)
  local errString = textRes.Auction.SGetAuctionItemInfoError[p.errorCode]
  if errString then
    Toast(errString)
  end
end
def.static("number", "number", "number", "userdata").SendCBidReq = function(activityId, roundIdx, auctionitemId, bidCount)
  warn("[AuctionProtocols:SendCBidReq] Send CBidReq:", activityId, roundIdx, auctionitemId, bidCount and Int64.tostring(bidCount))
  local p = require("netio.protocol.mzm.gsp.auction.CBidReq").new(activityId, roundIdx, auctionitemId, bidCount)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSBidRsp = function(p)
  warn("[AuctionProtocols:OnSBidRsp] On SBidRsp:", p.activityId, p.turnIndex, p.itemCfgId, p.moneyCount and Int64.tostring(p.moneyCount))
  Toast(textRes.Auction.BID_SUCCESS)
end
def.static("table").OnSBidError = function(p)
  warn("[AuctionProtocols:OnSBidError] On SBidError! p.errorCode:", p.errorCode)
  local SBidError = require("netio.protocol.mzm.gsp.auction.SBidError")
  if SBidError.MONEY_BELOW_MIN_PRICE == p.errorCode then
    AuctionData.Instance():SyncItemInfo(p.activityId, p.turnIndex, p.itemInfo, true)
  end
  local errString = textRes.Auction.SBidError[p.errorCode]
  if errString then
    Toast(errString)
  end
end
def.static("number").SendCGetBidRankReq = function(activityId)
  warn("[AuctionProtocols:SendCGetBidRankReq] Send CGetBidRankReq, activityId:", activityId)
  local p = require("netio.protocol.mzm.gsp.auction.CGetBidRankReq").new(activityId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetBidRankRsp = function(p)
  warn("[AuctionProtocols:OnSGetBidRankRsp] On SGetBidRankRsp, #p.itemInfoList:", p.itemInfoList and #p.itemInfoList or 0)
  local AuctionBidderListPanel = require("Main.Auction.ui.AuctionBidderListPanel")
  if AuctionBidderListPanel.Instance():IsShow() then
    AuctionBidderListPanel.OnSGetBidRankRsp(p)
  end
end
def.static("table").OnSGetBidRankError = function(p)
  warn("[AuctionProtocols:OnSGetBidRankError] On SGetBidRankError! p.errorCode:", p.errorCode)
  local errString = textRes.Auction.SGetBidRankError[p.errorCode]
  if errString then
    Toast(errString)
  end
end
AuctionProtocols.Commit()
return AuctionProtocols
