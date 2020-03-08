local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TradingArcadeProtocol = Lplus.Class(MODULE_NAME)
local TradingArcadeModule = Lplus.ForwardDeclare("TradingArcadeModule")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local BuyServiceMgr = Lplus.ForwardDeclare("Main.TradingArcade.BuyServiceMgr")
local SellServiceMgr = Lplus.ForwardDeclare("Main.TradingArcade.SellServiceMgr")
local SearchMgrDelegate = Lplus.ForwardDeclare("Main.TradingArcade.SearchMgr")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local MarketState = require("netio.protocol.mzm.gsp.market.MarketState")
local BidMgr = require("Main.TradingArcade.BidMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = TradingArcadeProtocol.define
local _Debug = false
local _Debug2 = false
local _gmodule = gmodule
local gmodule = gmodule
local GameUtil = GameUtil
if _Debug then
  gmodule = {}
  gmodule.notifyId = _gmodule.notifyId
  gmodule.network = {}
  gmodule.network.registerProtocol = _gmodule.network.registerProtocol
  function gmodule.network.sendProtocol(...)
    print("fake sendProtocol", ...)
  end
else
  GameUtil = {}
  function GameUtil.AddGlobalTimer()
  end
end
local REQ_TIMEOUT_TIME = 10
local _itemInfoReqList, _petInfoReqList, _itemPriceReqList, _petPriceReqList
local _customizing = false
local _queryAllAuctionReq = 0
local _queryBuyLogReqList, _querySellLogReqList, _queryPubOrSellNumberReqList, _queryAuctionConcernNumReqList
def.static().Init = function()
  _itemInfoReqList = {}
  _petInfoReqList = {}
  _itemPriceReqList = {}
  _petPriceReqList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TradingArcadeProtocol.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, TradingArcadeProtocol.OnEnterWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynRoleOnShelfInfo", TradingArcadeProtocol.OnSSynRoleOnShelfInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynRoleConcernInfo", TradingArcadeProtocol.OnSSynRoleConcernInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryMarketItemRes", TradingArcadeProtocol.OnSQueryMarketItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryMarketPublicItemRes", TradingArcadeProtocol.OnSQueryMarketPublicItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryMarketPetRes", TradingArcadeProtocol.OnSQueryMarketPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryMarketPublicPetRes", TradingArcadeProtocol.OnSQueryMarketPublicPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryItemInfoRes", TradingArcadeProtocol.OnSQueryItemInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryPetInfoRes", TradingArcadeProtocol.OnSQueryPetInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SBuyItemRes", TradingArcadeProtocol.OnSBuyItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SBuyPetRes", TradingArcadeProtocol.OnSBuyPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSellItemRes", TradingArcadeProtocol.OnSSellItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSellPetRes", TradingArcadeProtocol.OnSSellPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetSellItemRes", TradingArcadeProtocol.OnSGetSellItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetSellPetRes", TradingArcadeProtocol.OnSGetSellPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSyncSellItemNotify", TradingArcadeProtocol.OnSSyncSellItemNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSyncSellPetNotify", TradingArcadeProtocol.OnSSyncSellPetNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSyncItemExpire", TradingArcadeProtocol.OnSSyncItemExpire)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSyncPetExpire", TradingArcadeProtocol.OnSSyncPetExpire)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SConcernItemRes", TradingArcadeProtocol.OnSConcernItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SConcernPetRes", TradingArcadeProtocol.OnSConcernPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SUnConcernItemRes", TradingArcadeProtocol.OnSUnConcernItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SUnConcernPetRes", TradingArcadeProtocol.OnSUnConcernPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSyConcernItemTipRes", TradingArcadeProtocol.OnSSyConcernItemTipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSyConcernPetTipRes", TradingArcadeProtocol.OnSSyConcernPetTipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetMoneyItemRes", TradingArcadeProtocol.OnSGetMoneyItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetMoneyPetRes", TradingArcadeProtocol.OnSGetMoneyPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryMarketItemWithLevelRes", TradingArcadeProtocol.OnSQueryMarketItemWithLevelRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryItemPricRes", TradingArcadeProtocol.OnSQueryItemPricRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryPetPricRes", TradingArcadeProtocol.OnSQueryPetPricRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynItemPriceRes", TradingArcadeProtocol.OnSSynItemPriceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynPetPriceRes", TradingArcadeProtocol.OnSSynPetPriceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SCommonResultRes", TradingArcadeProtocol.OnSCommonResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSearchEquipRes", TradingArcadeProtocol.OnSSearchEquipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSearchPetEquipRes", TradingArcadeProtocol.OnSSearchPetEquipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSearchPetRes", TradingArcadeProtocol.OnSSearchPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSearchRestTimeRes", TradingArcadeProtocol.OnSSearchRestTimeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SAllCustomizedConditionsRes", TradingArcadeProtocol.OnSAllCustomizedConditionsRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynHasCustomizedRes", TradingArcadeProtocol.OnSSynHasCustomizedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SAddEquipConditionRes", TradingArcadeProtocol.OnSAddEquipConditionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SAddPetEquipConditionRes", TradingArcadeProtocol.OnSAddPetEquipConditionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SAddPetConditionRes", TradingArcadeProtocol.OnSAddPetConditionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SDeleteConditionRes", TradingArcadeProtocol.OnSDeleteConditionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SConditionTimeOutRes", TradingArcadeProtocol.OnSConditionTimeOutRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynRoleAuctionInfo", TradingArcadeProtocol.OnSSynRoleAuctionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SItemAuctionRes", TradingArcadeProtocol.OnSItemAuctionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SPetAuctionRes", TradingArcadeProtocol.OnSPetAuctionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SDeleteItemAuctionRes", TradingArcadeProtocol.OnSDeleteItemAuctionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SDeletePetAuctionRes", TradingArcadeProtocol.OnSDeletePetAuctionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SItemAuctionBePassedRes", TradingArcadeProtocol.OnSItemAuctionBePassedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SPetAuctionBePassedRes", TradingArcadeProtocol.OnSPetAuctionBePassedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetAuctionItemRes", TradingArcadeProtocol.OnSGetAuctionItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetAuctionPetRes", TradingArcadeProtocol.OnSGetAuctionPetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SItemAuctionSuccessRes", TradingArcadeProtocol.OnSItemAuctionSuccessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SPetAuctionSuccessRes", TradingArcadeProtocol.OnSPetAuctionSuccessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetSellLogRes", TradingArcadeProtocol.OnSGetSellLogRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SGetBuyLogRes", TradingArcadeProtocol.OnSGetBuyLogRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SMarketItemPetBulletinRes", TradingArcadeProtocol.OnSMarketItemPetBulletinRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryPubOrSellNumberRes", TradingArcadeProtocol.OnSQueryPubOrSellNumberRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SQueryAuctionConcernNumRes", TradingArcadeProtocol.OnSQueryAuctionConcernNumRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SPetMaxPriceRes", TradingArcadeProtocol.OnSPetMaxPriceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynMarketItemBanTradeRes", TradingArcadeProtocol.OnSSynMarketItemBanTradeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SSynMarketPetBanTradeRes", TradingArcadeProtocol.OnSSynMarketPetBanTradeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SItemBanTradeRes", TradingArcadeProtocol.OnSItemBanTradeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.market.SPetBanTradeRes", TradingArcadeProtocol.OnSPetBanTradeRes)
end
def.static("table", "table").OnEnterWorld = function()
  if TradingArcadeUtils.CheckOpenEx(true) then
    TradingArcadeProtocol.CQueryAllAuctionReq()
  end
end
def.static("table", "table").OnLeaveWorld = function()
  _itemInfoReqList = {}
  _petInfoReqList = {}
  _itemPriceReqList = {}
  _petPriceReqList = {}
  _customizing = false
  _queryAllAuctionReq = 0
  _queryBuyLogReqList = nil
  _querySellLogReqList = nil
  _queryPubOrSellNumberReqList = nil
  _queryAuctionConcernNumReqList = nil
  BidMgr.Reset()
end
def.static("table").OnSCommonResultRes = function(p)
  if p.class.AUCTION_PRICE_ERROR == p.res then
    TradingArcadeProtocol.OnAuctionPriceError(p)
    return
  end
  local text = textRes.TradingArcade.SCommonResultRes[p.res]
  if text then
    Toast(text)
  else
    warn(string.format("OnSCommonResultRes %d not handle", p.res))
  end
end
def.static("table").OnAuctionPriceError = function(p)
  local percent = BidMgr.Instance():GetBidAddPriceMinPercent()
  local text = string.format(textRes.TradingArcade[85], percent)
  Toast(text)
end
def.static("table").OnSQueryAuctionConcernNumRes = function(p)
  print("OnSQueryAuctionConcernNumRes p.concernNum, p.auctionNum", p.concernNum, p.auctionNum)
  if _queryAuctionConcernNumReqList then
    for i, func in ipairs(_queryAuctionConcernNumReqList) do
      func(p)
    end
    _queryAuctionConcernNumReqList = nil
  end
end
def.static("table").OnSQueryPubOrSellNumberRes = function(p)
  print("OnSQueryPubOrSellNumberRes", p.pubOrsell)
  if _queryPubOrSellNumberReqList then
    for i, func in ipairs(_queryPubOrSellNumberReqList) do
      func(p)
    end
    _queryPubOrSellNumberReqList = nil
  end
end
def.static("table").OnSMarketItemPetBulletinRes = function(p)
  print("OnSMarketItemPetBulletinRes p.itemIdOrpetCfgId", p.itemIdOrpetCfgId)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local id = p.itemIdOrpetCfgId
  local goodsInfo = HtmlHelper.ConvertMarketGoodsLink({
    marketId = p.marketId,
    refId = id,
    price = p.price
  })
  local gotoInfo = HtmlHelper.ConvertMarketGotoLink({
    marketId = p.marketId,
    refId = id,
    price = p.price,
    gotoText = textRes.TradingArcade[79],
    gotoTextColor = HtmlHelper.NameColor[2]
  })
  local sellerName = p.roleName
  local color = TradingArcadeUtils.GetTradingPriceColor(p.price)
  local priceText = string.format("<font color=#%s>%s</font>", color, tostring(p.price))
  local content = string.format(textRes.TradingArcade[78], sellerName, priceText, goodsInfo, gotoInfo)
  ChatModule.Instance():SendNoteMsg(content, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table").OnSGetBuyLogRes = function(p)
  print("OnSGetBuyLogRes #p.buyLogs", #p.buyLogs)
  if _queryBuyLogReqList then
    for i, func in ipairs(_queryBuyLogReqList) do
      func(p.buyLogs)
    end
    _queryBuyLogReqList = nil
  end
end
def.static("table").OnSGetSellLogRes = function(p)
  print("OnSGetSellLogRes #p.sellLogs", #p.sellLogs)
  if _querySellLogReqList then
    for i, func in ipairs(_querySellLogReqList) do
      func(p.sellLogs)
    end
    _querySellLogReqList = nil
  end
end
def.static("table").OnSItemAuctionSuccessRes = function(p)
  print("OnSItemAuctionSuccessRes p.marketId, p.itemId", p.marketId, p.itemId)
  local bidGoods = BidMgr.Instance():GetBidItemGoods(p.marketId)
  if bidGoods then
    bidGoods.state = MarketState.STATE_SELLED
    bidGoods.isMaxPrice = true
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {bidGoods})
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSPetAuctionSuccessRes = function(p)
  print("OnSPetAuctionSuccessRes p.marketId, p.petCfgId", p.marketId, p.petCfgId)
  local bidGoods = BidMgr.Instance():GetBidPetGoods(p.marketId)
  if bidGoods then
    bidGoods.state = MarketState.STATE_SELLED
    bidGoods.isMaxPrice = true
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {bidGoods})
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSGetAuctionItemRes = function(p)
  print("OnSGetAuctionItemRes p.marketId, p.itemId", p.marketId, p.itemId)
  local goods = BidMgr.Instance():RemoveItemGoods(p.marketId)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.BID_GOODS_LIST_UPDATE, {})
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(p.itemId)
  local itemName = itemBase.name
  local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
  local coloredName = string.format("<font color=#%s>%s</font>", color, itemName)
  local text = string.format(textRes.TradingArcade[68], coloredName)
  Toast(text)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSGetAuctionPetRes = function(p)
  print("OnSGetAuctionPetRes p.marketId, p.petCfgId", p.marketId, p.petCfgId)
  local goods = BidMgr.Instance():RemovePetGoods(p.marketId)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.BID_GOODS_LIST_UPDATE, {})
  local PetUtility = require("Main.Pet.PetUtility")
  local petCfg = PetUtility.Instance():GetPetCfg(p.petCfgId)
  local petName = petCfg.templateName
  local text = string.format(textRes.TradingArcade[69], petName)
  Toast(text)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSItemAuctionBePassedRes = function(p)
  print("OnSItemAuctionBePassedRes p.marketId, p.newprice", p.marketId, p.newprice)
  local onSellGoods = BuyServiceMgr.Instance():GetItemGoods(p.marketId)
  if onSellGoods then
    onSellGoods.price = p.newprice
  end
  local bidGoods = BidMgr.Instance():GetBidItemGoods(p.marketId)
  if bidGoods then
    bidGoods.price = p.newprice
    bidGoods.isMaxPrice = false
  end
  BidMgr.Instance():RecordBeExceeded(p.marketId, p.itemId)
  local goods = onSellGoods or bidGoods
  if goods then
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(p.itemId)
  local itemName = itemBase.name
  local text = string.format(textRes.TradingArcade[66], itemName)
  Toast(text)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSPetAuctionBePassedRes = function(p)
  print("OnSPetAuctionBePassedRes p.marketId, p.newprice", p.marketId, p.newprice)
  local onSellGoods = BuyServiceMgr.Instance():GetPetGoods(p.marketId)
  if onSellGoods then
    onSellGoods.price = p.newprice
  end
  local bidGoods = BidMgr.Instance():GetBidPetGoods(p.marketId)
  if bidGoods then
    bidGoods.price = p.newprice
    bidGoods.isMaxPrice = false
  end
  BidMgr.Instance():RecordBeExceeded(p.marketId, p.petCfgId)
  local goods = onSellGoods or bidGoods
  if goods then
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  end
  local PetUtility = require("Main.Pet.PetUtility")
  local petCfg = PetUtility.Instance():GetPetCfg(p.petCfgId)
  local petName = petCfg.templateName
  local text = string.format(textRes.TradingArcade[67], petName)
  Toast(text)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSDeleteItemAuctionRes = function(p)
  print("OnSDeleteItemAuctionRes p.marketId", p.marketId)
  local goods = BidMgr.Instance():RemoveItemGoods(p.marketId)
  if goods then
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  end
  Toast(textRes.TradingArcade[62])
end
def.static("table").OnSDeletePetAuctionRes = function(p)
  print("OnSDeletePetAuctionRes p.marketId", p.marketId)
  local goods = BidMgr.Instance():RemovePetGoods(p.marketId)
  if goods then
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  end
  Toast(textRes.TradingArcade[62])
end
def.static("table").OnSSynRoleAuctionInfo = function(p)
  _queryAllAuctionReq = 0
  print("OnSSynRoleAuctionInfo #(p.marketItemList), #(p.marketPetList)", #p.marketItemList, #p.marketPetList)
  BidMgr.Instance():SyncBidGoods(p)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.BID_GOODS_LIST_UPDATE, {})
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSItemAuctionRes = function(p)
  print("OnSItemAuctionRes p.marketId, p.itemId, p.price", p.marketId, p.itemId, p.price)
  local goods = BuyServiceMgr.Instance():GetItemGoods(p.marketId)
  if goods then
    goods.price = p.price
    goods.publicEndTime = p.endTime
    goods.bidRoleNum = goods.bidRoleNum + 1
  end
  local goods = BidMgr.Instance():GetBidItemGoods(p.marketId)
  if goods == nil then
    goods = BidMgr.Instance():SNewBidedItemGoods(p)
  else
    goods:AddState(MarketState.STATE_AUCTION)
    goods.isMaxPrice = true
    goods.price = p.price
    goods.publicEndTime = p.endTime
    goods.bidRoleNum = goods.bidRoleNum + 1
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  Toast(textRes.TradingArcade[61])
end
def.static("table").OnSPetAuctionRes = function(p)
  print("OnSPetAuctionRes p.marketId, p.petCfgId, p.price", p.marketId, p.petCfgId, p.price)
  local goods = BuyServiceMgr.Instance():GetPetGoods(p.marketId)
  if goods then
    goods.price = p.price
    goods.publicEndTime = p.endTime
    goods.bidRoleNum = goods.bidRoleNum + 1
  end
  local goods = BidMgr.Instance():GetBidPetGoods(p.marketId)
  if goods == nil then
    goods = BidMgr.Instance():SNewBidedPetGoods(p)
  else
    goods:AddState(MarketState.STATE_AUCTION)
    goods.isMaxPrice = true
    goods.price = p.price
    goods.publicEndTime = p.endTime
    goods.bidRoleNum = goods.bidRoleNum + 1
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  Toast(textRes.TradingArcade[61])
end
def.static("table").OnSAllCustomizedConditionsRes = function(p)
  print("OnSAllCustomizedConditionsRes subid2EquipCons subid2PetEquipCons subid2PetCons")
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():SetAllCustomize(p)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
end
def.static("table").OnSSynHasCustomizedRes = function(p)
  warn("OnSSynHasCustomizedRes p.subid, p.index, p.pubOrsell", p.subid, ",", p.index, ",", p.pubOrsell)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():SyncCustomizedSearchPeriodState(p)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSDeleteConditionRes = function(p)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():DeleteCustomizedSearch(p.subid, p.index)
  Toast(textRes.TradingArcade[226])
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSConditionTimeOutRes = function(p)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():DeleteCustomizedSearch(p.subid, p.index)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
end
def.static("table").OnSAddEquipConditionRes = function(p)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():AddEquipCustomize(p.index, p.condition)
  _customizing = false
  Toast(textRes.TradingArcade[225])
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
end
def.static("table").OnSAddPetEquipConditionRes = function(p)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():AddPetEquipCustomize(p.index, p.condition)
  _customizing = false
  Toast(textRes.TradingArcade[225])
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
end
def.static("table").OnSAddPetConditionRes = function(p)
  local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
  CustomizedSearchMgr.Instance():AddPetCustomize(p.index, p.condition)
  _customizing = false
  Toast(textRes.TradingArcade[225])
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.MY_CUSTOMIZE_LIST_UPDATE, nil)
end
def.static("table").OnSSearchRestTimeRes = function(p)
  local text = string.format(textRes.TradingArcade[213], p.restTime)
  Toast(text)
end
def.static("table").OnSSearchEquipRes = function(p)
  print("OnSSearchEquipRes", p.condition.subid, p.condition.level, p.pubOrsell, p.pageResult.pageIndex)
  if not BuyServiceMgr.Instance():IsInMode(p.pubOrsell) then
    return
  end
  local searchMgr = SearchMgrDelegate.Instance():GetCurSearchMgr()
  if searchMgr == nil then
    return
  end
  if p.pageResult.pageIndex == 0 then
    p.pageResult.pageIndex = 1
  end
  BuyServiceMgr.Instance():AddPageItemInfo(p.pageResult)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SYNC_SEARCH_RESULT, {p})
end
def.static("table").OnSSearchPetEquipRes = function(p)
  print("OnSSearchPetEquipRes", p.condition.subid, p.condition.property, p.pubOrsell, p.pageResult.pageIndex)
  if not BuyServiceMgr.Instance():IsInMode(p.pubOrsell) then
    return
  end
  local searchMgr = SearchMgrDelegate.Instance():GetCurSearchMgr()
  if searchMgr == nil then
    return
  end
  if p.pageResult.pageIndex == 0 then
    p.pageResult.pageIndex = 1
  end
  BuyServiceMgr.Instance():AddPageItemInfo(p.pageResult)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SYNC_SEARCH_RESULT, {p})
end
def.static("table").OnSSearchPetRes = function(p)
  print("OnSSearchPetRes", p.condition.subid, p.condition.skillNum, p.pubOrsell, p.pageResult.pageIndex)
  if not BuyServiceMgr.Instance():IsInMode(p.pubOrsell) then
    return
  end
  local searchMgr = SearchMgrDelegate.Instance():GetCurSearchMgr()
  if searchMgr == nil then
    return
  end
  if p.pageResult.pageIndex == 0 then
    p.pageResult.pageIndex = 1
  end
  BuyServiceMgr.Instance():AddPagePetInfo(p.pageResult)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SYNC_SEARCH_RESULT, {p})
end
def.static("table").OnSQueryItemPricRes = function(p)
  print("OnSQueryItemPricRes", p.itemId, " ", #p.prices)
  if _itemPriceReqList[p.itemId] then
    for i, callback in ipairs(_itemPriceReqList[p.itemId]) do
      callback(p)
    end
    _itemPriceReqList[p.itemId] = nil
  end
end
def.static("table").OnSQueryPetPricRes = function(p)
  print("OnSQueryPetPricRes", p.petCfgId, " ", #p.prices)
  if _petPriceReqList[p.petCfgId] then
    for i, callback in ipairs(_petPriceReqList[p.petCfgId]) do
      callback(p)
    end
    _petPriceReqList[p.petCfgId] = nil
  end
end
def.static("table").OnSSynItemPriceRes = function(p)
  SellServiceMgr.Instance():SAddMarketItem(p.marketitem)
end
def.static("table").OnSSynPetPriceRes = function(p)
  SellServiceMgr.Instance():SAddMarketPet(p.marketpet)
end
def.static("table").OnSGetMoneyItemRes = function(p)
  print("OnSGetMoneyItemRes", p.marketId, " ", p.itemId, " ", p.money)
  local goods = SellServiceMgr.Instance():GetItemGoods(p.marketId)
  if goods then
    goods.sellNum = 0
    if 0 >= goods.num then
      SellServiceMgr.Instance():UnshelveGoods(goods.type, goods.marketId)
    else
      Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
    end
    SellServiceMgr.Instance():CheckNotify()
  end
  PersonalHelper.GetMoneyMsg(ItemModule.MONEY_TYPE_GOLD, tostring(p.money))
end
def.static("table").OnSGetMoneyPetRes = function(p)
  print("OnSGetMoneyPetRes", p.marketId, " ", p.petCfgId, " ", p.money)
  local goods = SellServiceMgr.Instance():GetPetGoods(p.marketId)
  if goods then
    SellServiceMgr.Instance():UnshelveGoods(goods.type, goods.marketId)
    SellServiceMgr.Instance():CheckNotify()
  end
  PersonalHelper.GetMoneyMsg(ItemModule.MONEY_TYPE_GOLD, tostring(p.money))
end
local showGoodsWillOnSellMessage = function(goods)
  if goods then
    local typeName = goods:GetTypeName()
    local name = goods:GetName()
    local remainSeconds = goods:GetPublicRemainTime()
    local t = _G.Seconds2HMSTime(remainSeconds)
    local text = string.format(textRes.TradingArcade[23], typeName, name, t.m)
    Toast(text)
  else
    warn("showGoodsWillOnSellMessage failed!: goods is nil")
  end
end
def.static("table").OnSSyConcernItemTipRes = function(p)
  local goods = BuyServiceMgr.Instance():GetConcernItemGoods(p.marketItem.marketId)
  print("OnSSyConcernItemTipRes", goods)
  showGoodsWillOnSellMessage(goods)
end
def.static("table").OnSSyConcernPetTipRes = function(p)
  local goods = BuyServiceMgr.Instance():GetConcernPetGoods(p.marketPet.marketId)
  print("OnSSyConcernPetTipRes", goods)
  showGoodsWillOnSellMessage(goods)
end
def.static("table").OnSUnConcernItemRes = function(p)
  local goods = BuyServiceMgr.Instance():RemoveItemGoodsFromConcernList(p.marketId)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  Toast(textRes.TradingArcade[22])
end
def.static("table").OnSUnConcernPetRes = function(p)
  local goods = BuyServiceMgr.Instance():RemovePetGoodsFromConcernList(p.marketId)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  Toast(textRes.TradingArcade[22])
end
def.static("table").OnSQueryItemInfoRes = function(p)
  print("OnSQueryItemInfoRes", p.marketId, p.itemId)
  local key = tostring(p.marketId)
  if _itemInfoReqList[key] then
    for i, callback in ipairs(_itemInfoReqList[key]) do
      callback(p)
    end
    _itemInfoReqList[key] = nil
  end
end
def.static("table").OnSQueryPetInfoRes = function(p)
  print("OnSQueryPetInfoRes", p.marketId, p.petCfgId)
  local key = tostring(p.marketId)
  if _petInfoReqList[key] then
    for i, callback in ipairs(_petInfoReqList[key]) do
      callback(p)
    end
    _petInfoReqList[key] = nil
  end
end
def.static("table").OnSSyncItemExpire = function(p)
  print("OnSSyncItemExpire", p.marketId, p.itemId)
  local MarketState = require("netio.protocol.mzm.gsp.market.MarketState")
  local goods = SellServiceMgr.Instance():GetItemGoods(p.marketId)
  if goods then
    goods:AddState(MarketState.STATE_EXPIRE)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
    SellServiceMgr.Instance():CheckNotify()
  end
end
def.static("table").OnSSyncPetExpire = function(p)
  print("OnSSyncPetExpire", p.marketId, p.petCfgId)
  local MarketState = require("netio.protocol.mzm.gsp.market.MarketState")
  local goods = SellServiceMgr.Instance():GetPetGoods(p.marketId)
  if goods then
    goods:AddState(MarketState.STATE_EXPIRE)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
    SellServiceMgr.Instance():CheckNotify()
  end
end
def.static("table").OnSConcernItemRes = function(p)
  local goods = BuyServiceMgr.Instance():AddMarketItemToConcernList(p.concernMarketItem)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  Toast(textRes.TradingArcade[21])
end
def.static("table").OnSConcernPetRes = function(p)
  local goods = BuyServiceMgr.Instance():AddMarketPetToConcernList(p.concernMarketPet)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  Toast(textRes.TradingArcade[21])
end
def.static("table").OnSSynRoleConcernInfo = function(p)
  print("OnSSynRoleConcernInfo", #p.marketItemList, #p.marketPetList)
  BuyServiceMgr.Instance():SSynRoleConcernInfo(p)
end
local function showUnshelveGoodsPrompt(goods, cutgold)
  if goods == nil or cutgold == nil then
    return
  end
  local goodsName = goods:GetName()
  goodsName = HtmlHelper.ConvertBBCodeColorToHtml(goodsName)
  if cutgold == 0 then
    Toast(textRes.TradingArcade[89]:format(goodsName))
  else
    Toast(textRes.TradingArcade[90]:format(goodsName, tostring(cutgold)))
  end
end
def.static("table").OnSGetSellItemRes = function(p)
  print("OnSGetSellItemRes", p.marketId)
  local goods = SellServiceMgr.Instance():UnshelveItemGoods(p.marketId)
  SellServiceMgr.Instance():CheckNotify()
  showUnshelveGoodsPrompt(goods, p.cutgold)
end
def.static("table").OnSGetSellPetRes = function(p)
  print("OnSGetSellPetRes", p.marketId)
  local goods = SellServiceMgr.Instance():UnshelvePetGoods(p.marketId)
  SellServiceMgr.Instance():CheckNotify()
  showUnshelveGoodsPrompt(goods, p.cutgold)
end
def.static("table").OnSSellItemRes = function(p)
  print("OnSSellItemRes", p.marketItem)
  local goods = SellServiceMgr.Instance():GetItemGoods(p.oldMarketId)
  if goods then
    goods.marketId = p.marketItem.marketId
  end
  SellServiceMgr.Instance():SAddMarketItem(p.marketItem)
  SellServiceMgr.Instance():CheckNotify()
  Toast(textRes.TradingArcade[27])
end
def.static("table").OnSSellPetRes = function(p)
  print("SSellPetRes", p.marketPet)
  local goods = SellServiceMgr.Instance():GetPetGoods(p.oldMarketId)
  if goods then
    goods.marketId = p.marketPet.marketId
  end
  SellServiceMgr.Instance():SAddMarketPet(p.marketPet)
  SellServiceMgr.Instance():CheckNotify()
  Toast(textRes.TradingArcade[27])
end
def.static("table").OnSSynRoleOnShelfInfo = function(p)
  print("OnSSynRoleOnShelfInfo", #p.marketItemList, #p.marketPetList)
  SellServiceMgr.Instance():SSynRoleOnShelfInfo(p)
end
def.static("table").OnSSyncSellItemNotify = function(p)
  print("OnSSyncSellItemNotify", p.marketId, p.itemId, p.restNum, p.sellNum)
  local goods = SellServiceMgr.Instance():GetItemGoods(p.marketId)
  if goods == nil then
    warn("OnSSyncSellItemNotify goods is nil", p.marketId, p.itemId, p.restNum, p.sellNum)
    return
  end
  goods:SetNum(p.restNum)
  goods:AddSellNum(p.sellNum)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
  SellServiceMgr.Instance():CheckNotify()
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemBase = ItemUtils.GetItemBase(p.itemId)
  if itemBase == nil then
    return
  end
  local sellMoney = p.sellNum * goods.price
  sellMoney = SellServiceMgr.Instance():GetAftexTaxValue(sellMoney)
  local itemText = itemBase.name
  itemText = string.format("<font color=#%s>%s</font>", HtmlHelper.NameColor[itemBase.namecolor], itemText)
  local text = string.format(textRes.TradingArcade[9], itemText, sellMoney)
  Toast(text)
end
def.static("table").OnSSyncSellPetNotify = function(p)
  print("OnSSyncSellPetNotify", p.marketId, p.petCfgId)
  local goods = SellServiceMgr.Instance():GetPetGoods(p.marketId)
  if goods == nil then
    warn("OnSSyncSellPetNotify goods is nil", p.marketId, p.petCfgId)
    return
  end
  goods:SetNum(0)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
  SellServiceMgr.Instance():CheckNotify()
  local PetUtility = require("Main.Pet.PetUtility")
  local petCfg = PetUtility.Instance():GetPetCfg(p.petCfgId)
  if petCfg == nil then
    return
  end
  local sellMoney = SellServiceMgr.Instance():GetAftexTaxValue(goods.price)
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("<font color=#%s>%s</font>", color, petCfg.templateName)
  local text = string.format(textRes.TradingArcade[9], coloredPetName, sellMoney)
  Toast(text)
end
def.static("table").OnSQueryMarketItemRes = function(p)
  if BuyServiceMgr.Instance():IsInMode(BuyServiceMgr.Mode.OnSell) then
    BuyServiceMgr.Instance():AddPageItemInfo(p.pageResult)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, {
      p.pageResult.subid,
      p.pageResult.pageIndex,
      p.pricesort
    })
  end
end
def.static("table").OnSQueryMarketItemWithLevelRes = function(p)
  print("OnSQueryMarketItemWithLevelRes", p.pricesort, p.level, p.pubOrsell)
  if BuyServiceMgr.Instance():IsInMode(p.pubOrsell) then
    BuyServiceMgr.Instance():AddPageItemInfo(p.pageResult)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, {
      p.pageResult.subid,
      p.pageResult.pageIndex,
      p.pricesort,
      p.level
    })
  end
end
def.static("table").OnSQueryMarketPetRes = function(p)
  if BuyServiceMgr.Instance():IsInMode(BuyServiceMgr.Mode.OnSell) then
    BuyServiceMgr.Instance():AddPagePetInfo(p.pageResult)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, {
      p.pageResult.subid,
      p.pageResult.pageIndex,
      p.pricesort
    })
  end
end
def.static("table").OnSQueryMarketPublicItemRes = function(p)
  if BuyServiceMgr.Instance():IsInMode(BuyServiceMgr.Mode.Public) then
    BuyServiceMgr.Instance():AddPageItemInfo(p.pageResult)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, {
      p.pageResult.subid,
      p.pageResult.pageIndex,
      p.pricesort
    })
  end
end
def.static("table").OnSQueryMarketPublicPetRes = function(p)
  if BuyServiceMgr.Instance():IsInMode(BuyServiceMgr.Mode.Public) then
    BuyServiceMgr.Instance():AddPagePetInfo(p.pageResult)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, {
      p.pageResult.subid,
      p.pageResult.pageIndex,
      p.pricesort
    })
  end
end
def.static("table").OnSBuyItemRes = function(p)
  local goods = BuyServiceMgr.Instance():GetItemGoods(p.marketId)
  if goods then
    goods:SetNum(p.restNum)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  end
  local concernGoods = BuyServiceMgr.Instance():GetConcernItemGoods(p.marketId)
  if concernGoods then
    if p.restNum == 0 then
      BuyServiceMgr.Instance():RemoveItemGoodsFromConcernList(p.marketId)
    else
      concernGoods:SetNum(p.restNum)
    end
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.CONCERN_GOODS_LIST_UPDATE, {nil})
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemBase = ItemUtils.GetItemBase(p.itemId)
  if itemBase == nil then
    return
  end
  local buyNum = p.buyNum
  local itemText = string.format(textRes.TradingArcade[8], itemBase.name, buyNum)
  itemText = string.format("<font color=#%s>%s</font>", HtmlHelper.NameColor[itemBase.namecolor], itemText)
  local text = string.format(textRes.TradingArcade[7], tostring(p.useMoney), itemText)
  Toast(text)
end
def.static("table").OnSBuyPetRes = function(p)
  local goods = BuyServiceMgr.Instance():GetPetGoods(p.marketId)
  if goods then
    goods:SetNum(0)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, {goods})
  end
  local concernGoods = BuyServiceMgr.Instance():GetConcernPetGoods(p.marketId)
  if concernGoods then
    BuyServiceMgr.Instance():RemovePetGoodsFromConcernList(p.marketId)
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.CONCERN_GOODS_LIST_UPDATE, {nil})
  end
  local PetUtility = require("Main.Pet.PetUtility")
  local petCfg = PetUtility.Instance():GetPetCfg(p.petCfgId)
  if petCfg == nil then
    return
  end
  local color = PetUtility.GetPetTypeColor(petCfg.type)
  local coloredPetName = string.format("<font color=#%s>%s</font>", color, petCfg.templateName)
  local text = string.format(textRes.TradingArcade[7], tostring(p.useMoney), coloredPetName)
  Toast(text)
end
def.static("table").OnSPetMaxPriceRes = function(p)
  local maxprice = p.maxprice
  local text = string.format(textRes.TradingArcade[84], maxprice)
  Toast(text)
end
def.static("table").OnSSynMarketItemBanTradeRes = function(p)
  local tradingArcadeModule = TradingArcadeModule.Instance()
  for itemId, v in pairs(p.itemids) do
    tradingArcadeModule:SetItemBanState(itemId, TradingArcadeModule.BanState.Banned)
  end
end
def.static("table").OnSSynMarketPetBanTradeRes = function(p)
  local tradingArcadeModule = TradingArcadeModule.Instance()
  for petCfgId, v in pairs(p.petCfgIds) do
    tradingArcadeModule:SetPetBanState(petCfgId, TradingArcadeModule.BanState.Banned)
  end
end
def.static("table").OnSItemBanTradeRes = function(p)
  local tradingArcadeModule = TradingArcadeModule.Instance()
  tradingArcadeModule:SetItemBanState(p.itemid, p.state)
end
def.static("table").OnSPetBanTradeRes = function(p)
  local tradingArcadeModule = TradingArcadeModule.Instance()
  tradingArcadeModule:SetPetBanState(p.petCfgId, p.state)
end
def.static("table").OnSTemp = function(p)
end
def.static("number", "number", "number").CQueryMarketItem = function(subType, priceSort, pageIndex)
  print("CQueryMarketItem", subType, priceSort, pageIndex)
  local p = require("netio.protocol.mzm.gsp.market.CQueryMarketItem").new(subType, priceSort, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").CQueryMarketPublicItem = function(subType, priceSort, pageIndex)
  print("CQueryMarketPublicItem", subType, priceSort, pageIndex)
  local p = require("netio.protocol.mzm.gsp.market.CQueryMarketPublicItem").new(subType, priceSort, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").CQueryMarketPet = function(subType, priceSort, pageIndex)
  print("CQueryMarketPet", subType, priceSort, pageIndex)
  local p = require("netio.protocol.mzm.gsp.market.CQueryMarketPet").new(subType, priceSort, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").CQueryMarketPublicPet = function(subType, priceSort, pageIndex)
  print("CQueryMarketPublicPet", subType, priceSort, pageIndex)
  local p = require("netio.protocol.mzm.gsp.market.CQueryMarketPublicPet").new(subType, priceSort, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "number", "function").CQueryItemInfoReq = function(marketId, itemId, price, callback)
  print("CQueryItemInfoReq", marketId, itemId, price)
  local key = tostring(marketId)
  if _itemInfoReqList[key] == nil or math.abs(_itemInfoReqList[key].timestamp - os.time()) > REQ_TIMEOUT_TIME then
    _itemInfoReqList[key] = {
      callback,
      timestamp = os.time()
    }
    local p = require("netio.protocol.mzm.gsp.market.CQueryItemInfoReq").new(marketId, itemId, price)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_itemInfoReqList[key], callback)
  end
end
def.static("userdata", "number", "number", "function").CQueryPetInfoReq = function(marketId, petCfgId, price, callback)
  print("CQueryPetInfoReq", marketId, petCfgId, price)
  local key = tostring(marketId)
  if _petInfoReqList[key] == nil or math.abs(_petInfoReqList[key].timestamp - os.time()) > REQ_TIMEOUT_TIME then
    _petInfoReqList[key] = {
      callback,
      timestamp = os.time()
    }
    local p = require("netio.protocol.mzm.gsp.market.CQueryPetInfoReq").new(marketId, petCfgId, price)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_petInfoReqList[key], callback)
  end
end
def.static("userdata", "number", "number", "number").CBuyItemReq = function(marketId, itemId, price, buyNum)
  print("CBuyItemReq", marketId, itemId, price, buyNum)
  local p = require("netio.protocol.mzm.gsp.market.CBuyItemReq").new(marketId, itemId, price, buyNum)
  gmodule.network.sendProtocol(p)
  GameUtil.AddGlobalTimer(0, true, function(...)
    TradingArcadeProtocol.OnSBuyItemRes({
      marketId = marketId,
      itemId = itemId,
      price = price,
      restNum = 0,
      useMoney = 233,
      buyNum = buyNum
    })
  end)
end
def.static("userdata", "number", "number").CBuyPetReq = function(marketId, petCfgId, price)
  print("CBuyPetReq", marketId, petCfgId, price)
  local p = require("netio.protocol.mzm.gsp.market.CBuyPetReq").new(marketId, petCfgId, price)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number").CSellItemReq = function(itemKey, itemId, price, num)
  print("CSellItemReq", itemKey, itemId, price, num)
  local p = require("netio.protocol.mzm.gsp.market.CSellItemReq").new(itemKey, itemId, price, num)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "number", "number").CReSellItemReq = function(marketId, itemId, price, num)
  print("CReSellItemReq", marketId, itemId, price, num)
  local p = require("netio.protocol.mzm.gsp.market.CReSellItemReq").new(marketId, itemId, price, num)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CSellPetReq = function(petId, price)
  print("CSellPetReq", petId, price)
  local p = require("netio.protocol.mzm.gsp.market.CSellPetReq").new(petId, price)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CReSellPetReq = function(marketId, price)
  print("CReSellPetReq", marketId, price)
  local p = require("netio.protocol.mzm.gsp.market.CReSellPetReq").new(marketId, price)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CGetSellItemReq = function(marketId, itemId)
  print("CGetSellItemReq", marketId, itemId)
  local p = require("netio.protocol.mzm.gsp.market.CGetSellItemReq").new(marketId, itemId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CGetSellPetReq = function(marketId, petCfgId)
  print("CGetSellPetReq", marketId, petCfgId)
  local p = require("netio.protocol.mzm.gsp.market.CGetSellPetReq").new(marketId, petCfgId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CConcernItemReq = function(marketId, itemId)
  print("CConcernItemReq", marketId, itemId)
  local p = require("netio.protocol.mzm.gsp.market.CConcernItemReq").new(marketId, itemId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CUnConcernItemReq = function(marketId)
  print("CUnConcernItemReq", marketId)
  local p = require("netio.protocol.mzm.gsp.market.CUnConcernItemReq").new(marketId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CConcernPetReq = function(marketId, petCfgId)
  print("CConcernPetReq", marketId, petCfgId)
  local p = require("netio.protocol.mzm.gsp.market.CConcernPetReq").new(marketId, petCfgId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CUnConcernPetReq = function(marketId)
  print("CUnConcernPetReq", marketId)
  local p = require("netio.protocol.mzm.gsp.market.CUnConcernPetReq").new(marketId)
  gmodule.network.sendProtocol(p)
end
def.static().CAutoGetMoneyReq = function()
  print("CAutoGetMoneyReq")
  local p = require("netio.protocol.mzm.gsp.market.CAutoGetMoneyReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CGetMoneyItemReq = function(marketId)
  print("CGetMoneyItemReq", marketId)
  local p = require("netio.protocol.mzm.gsp.market.CGetMoneyItemReq").new(marketId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CGetMoneyPetReq = function(marketId)
  print("CGetMoneyPetReq", marketId)
  local p = require("netio.protocol.mzm.gsp.market.CGetMoneyPetReq").new(marketId)
  gmodule.network.sendProtocol(p)
end
def.static().CQueryAllConcernReq = function()
  print("CQueryAllConcernReq")
  local p = require("netio.protocol.mzm.gsp.market.CQueryAllConcernReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "function").CQueryItemPrice = function(itemId, callback)
  print("CQueryItemPrice")
  if _itemPriceReqList[itemId] == nil then
    _itemPriceReqList[itemId] = {callback}
    local p = require("netio.protocol.mzm.gsp.market.CQueryItemPrice").new(itemId)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_itemPriceReqList, callback)
  end
end
def.static("number", "function").CQueryPetPrice = function(petCfgId, callback)
  print("CQueryPetPrice")
  if _petPriceReqList[petCfgId] == nil then
    _petPriceReqList[petCfgId] = {callback}
    local p = require("netio.protocol.mzm.gsp.market.CQueryPetPrice").new(petCfgId)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_petPriceReqList, callback)
  end
end
def.static("number", "number", "number", "number", "number").CQueryMarketItemWithLevel = function(subid, pricesort, level, pubOrsell, pageIndex)
  print("CQueryMarketItemWithLevel subid, pricesort, level, pubOrsell, pageIndex", subid, pricesort, level, pubOrsell, pageIndex)
  local p = require("netio.protocol.mzm.gsp.market.CQueryMarketItemWithLevel").new(subid, pricesort, level, pubOrsell, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number", "number").CQueryMarketPetWithLevel = function(subid, pricesort, level, pubOrsell, pageIndex)
  print("CQueryMarketPetWithLevel subid, pricesort, level, pubOrsell, pageIndex", subid, pricesort, level, pubOrsell, pageIndex)
  local p = require("netio.protocol.mzm.gsp.market.CQueryMarketPetWithLevel").new(subid, pricesort, level, pubOrsell, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("table", "number", "number", "number").CSearchPetReq = function(condition, pubOrsell, pricesort, pageIndex)
  print("CSearchPetReq condition, pubOrsell, pricesort, pageIndex", condition.subid, condition.skillNum, pubOrsell, pricesort, pageIndex)
  condition.custtime = Int64.new(0)
  local p = require("netio.protocol.mzm.gsp.market.CSearchPetReq").new(condition, pubOrsell, pricesort, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("table", "number", "number", "number").CSearchPetEquipReq = function(condition, pubOrsell, pricesort, pageIndex)
  print("CSearchPetEquipReq condition, pubOrsell, pricesort, pageIndex", condition.subid, condition.property, pubOrsell, pricesort, pageIndex)
  condition.custtime = Int64.new(0)
  local p = require("netio.protocol.mzm.gsp.market.CSearchPetEquipReq").new(condition, pubOrsell, pricesort, pageIndex)
  gmodule.network.sendProtocol(p)
end
def.static("table", "number", "number", "number").CSearchEquipReq = function(condition, pubOrsell, pricesort, pageIndex)
  print("CSearchEquipReq condition, pubOrsell, pricesort, pageIndex", condition.subid, condition.level, pubOrsell, pricesort, pageIndex)
  condition.custtime = Int64.new(0)
  local p = require("netio.protocol.mzm.gsp.market.CSearchEquipReq").new(condition, pubOrsell, pricesort, pageIndex)
  gmodule.network.sendProtocol(p)
end
local checkCustomizeReq = function()
  return true
end
def.static("table").CAddPetConditionReq = function(condition)
  if checkCustomizeReq() == false then
    return
  end
  print("CAddPetConditionReq condition", condition.subid, condition.skillNum)
  condition.custtime = Int64.new(0)
  local p = require("netio.protocol.mzm.gsp.market.CAddPetConditionReq").new(condition)
  gmodule.network.sendProtocol(p)
  _customizing = true
end
def.static("table").CAddPetEquipConditionReq = function(condition)
  if checkCustomizeReq() == false then
    return
  end
  print("CAddPetEquipConditionReq condition", condition.subid, condition.propertyl)
  condition.custtime = Int64.new(0)
  local p = require("netio.protocol.mzm.gsp.market.CAddPetEquipConditionReq").new(condition)
  gmodule.network.sendProtocol(p)
  _customizing = true
end
def.static("table").CAddEquipConditionReq = function(condition)
  if checkCustomizeReq() == false then
    return
  end
  print("CAddEquipConditionReq condition", condition.subid, condition.level)
  condition.custtime = Int64.new(0)
  local p = require("netio.protocol.mzm.gsp.market.CAddEquipConditionReq").new(condition)
  gmodule.network.sendProtocol(p)
  _customizing = true
end
def.static("number", "number").CDeleteConditionReq = function(subid, index)
  print("CDeleteConditionReq subid, index", subid, index)
  local p = require("netio.protocol.mzm.gsp.market.CDeleteConditionReq").new(subid, index)
  gmodule.network.sendProtocol(p)
end
def.static().CGetCustomizedConditionsReq = function()
  print("CGetCustomizedConditionsReq")
  local p = require("netio.protocol.mzm.gsp.market.CGetCustomizedConditionsReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "number").CItemAuctionReq = function(marketId, itemId, price)
  print("CItemAuctionReq marketId, itemId, price", marketId, itemId, price)
  local p = require("netio.protocol.mzm.gsp.market.CItemAuctionReq").new(marketId, itemId, price)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "number").CPetAuctionReq = function(marketId, petCfgId, price)
  print("CPetAuctionReq marketId, petCfgId, price", marketId, petCfgId, price)
  local p = require("netio.protocol.mzm.gsp.market.CPetAuctionReq").new(marketId, petCfgId, price)
  gmodule.network.sendProtocol(p)
end
def.static().CQueryAllAuctionReq = function()
  local curTime = _G.GetServerTime()
  if math.abs(curTime - _queryAllAuctionReq) < 5 then
    return
  end
  _queryAllAuctionReq = curTime
  local p = require("netio.protocol.mzm.gsp.market.CQueryAllAuctionReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CDeleteItemAuctionReq = function(marketId)
  print("CDeleteItemAuctionReq marketId", marketId)
  local p = require("netio.protocol.mzm.gsp.market.CDeleteItemAuctionReq").new(marketId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").CDeletePetAuctionReq = function(marketId)
  print("CDeletePetAuctionReq marketId", marketId)
  local p = require("netio.protocol.mzm.gsp.market.CDeletePetAuctionReq").new(marketId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CGetAuctionItemReq = function(marketId, itemId)
  print("CGetAuctionItemReq marketId, itemId", marketId, itemId)
  local p = require("netio.protocol.mzm.gsp.market.CGetAuctionItemReq").new(marketId, itemId)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CGetAuctionPetReq = function(marketId, petCfgId)
  print("CGetAuctionPetReq marketId, petCfgId", marketId, petCfgId)
  local p = require("netio.protocol.mzm.gsp.market.CGetAuctionPetReq").new(marketId, petCfgId)
  gmodule.network.sendProtocol(p)
end
def.static("function").CGetBuyLogReq = function(callback)
  print("CGetBuyLogReq")
  if _queryBuyLogReqList == nil then
    _queryBuyLogReqList = {callback}
    local p = require("netio.protocol.mzm.gsp.market.CGetBuyLogReq").new()
    gmodule.network.sendProtocol(p)
  else
    table.insert(_queryBuyLogReqList, callback)
  end
end
def.static("function").CGetSellLogReq = function(callback)
  print("CGetSellLogReq")
  if _querySellLogReqList == nil then
    _querySellLogReqList = {callback}
    local p = require("netio.protocol.mzm.gsp.market.CGetSellLogReq").new()
    gmodule.network.sendProtocol(p)
  else
    table.insert(_querySellLogReqList, callback)
  end
end
def.static("number", "table", "function").CQueryPubOrSellNumberReq = function(pubOrsell, subIds, callback)
  print("CQueryPubOrSellNumberReq pubOrsell, subIds", pubOrsell, subIds)
  if _queryPubOrSellNumberReqList == nil then
    _queryPubOrSellNumberReqList = {callback}
    local p = require("netio.protocol.mzm.gsp.market.CQueryPubOrSellNumberReq").new(subIds, pubOrsell)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_queryPubOrSellNumberReqList, callback)
  end
end
def.static("userdata", "number", "function").CQueryAuctionConcernNumReq = function(marketId, pubOrsell, callback)
  print("CQueryAuctionConcernNumReq marketId, pubOrsell", tostring(marketId), pubOrsell)
  if _queryAuctionConcernNumReqList == nil then
    _queryAuctionConcernNumReqList = {callback}
    local p = require("netio.protocol.mzm.gsp.market.CQueryAuctionConcernNumReq").new(marketId, pubOrsell)
    gmodule.network.sendProtocol(p)
  else
    table.insert(_queryAuctionConcernNumReqList, callback)
  end
end
return TradingArcadeProtocol.Commit()
