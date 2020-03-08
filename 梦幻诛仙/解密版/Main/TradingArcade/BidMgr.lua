local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BidMgr = Lplus.Class(MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local GoodsDataFactory = require("Main.TradingArcade.GoodsDataFactory")
local TradingArcadeProtocol = Lplus.ForwardDeclare("Main.TradingArcade.TradingArcadeProtocol")
local def = BidMgr.define
def.field("table").m_bidGoodsList = nil
def.field("table").m_beExceededMap = nil
local instance
def.static("=>", BidMgr).Instance = function()
  if instance == nil then
    instance = BidMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_bidGoodsList = {}
end
def.method(GoodsData, "=>", "boolean").HasBidOnGoods = function(self, goods)
  for i, v in ipairs(self.m_bidGoodsList) do
    if v.marketId == goods.marketId and v.type == goods.type then
      return true
    end
  end
  return false
end
def.method(GoodsData, "=>", "boolean").IsMaxPriceForGoods = function(self, goods)
  for i, v in ipairs(self.m_bidGoodsList) do
    if v.marketId == goods.marketId and v.type == goods.type then
      return v.isMaxPrice
    end
  end
  return false
end
def.method("=>", "table").GetBidGoodsList = function(self)
  return self.m_bidGoodsList
end
def.method(GoodsData, "number").BidOnGoods = function(self, goods, price)
  if self:IsSelfSell(goods) then
    Toast(textRes.TradingArcade[52])
    return
  end
  if self:IsBidListFull() then
    Toast(textRes.TradingArcade[53])
    return
  end
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CItemAuctionReq(goods.marketId, goods.itemId, price)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CPetAuctionReq(goods.marketId, goods.petCfgId, price)
  end
end
def.method(GoodsData).UnBidOnGoods = function(self, goods)
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CDeleteItemAuctionReq(goods.marketId)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CDeletePetAuctionReq(goods.marketId)
  end
end
def.method(GoodsData, "=>", "boolean").IsSelfSell = function(self, goods)
  local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
  return SellServiceMgr.Instance():GetGoods(goods.type, goods.marketId) ~= nil
end
def.method("=>", "boolean").IsBidListFull = function(self)
  return #self.m_bidGoodsList >= _G.constant.MarketConsts.MAX_AUCTION_NUM
end
def.method("userdata", "number").SetItemBidPrice = function(self, marketId, price)
  self:SyncGoodsBidPrice(GoodsData.Type.Item, marketId, price)
end
def.method("userdata", "number").SetPetBidPrice = function(self, marketId, price)
  self:SyncGoodsBidPrice(GoodsData.Type.Pet, marketId, price)
end
def.method("number", "userdata", "number").SetGoodsBidPrice = function(self, goodsType, marketId, price)
  local goods
  for i, v in ipairs(self.m_bidGoodsList) do
    if marketId == v.marketId and goodsType == v.type then
      goods = v
      break
    end
  end
  if goods == nil then
    goods = GoodsDataFactory.Create(goodsType)
  end
  goods.price = price
end
def.method("table").SyncBidGoods = function(self, p)
  self.m_bidGoodsList = {}
  for i, v in ipairs(p.marketItemList) do
    local goods = GoodsDataFactory.Create(GoodsData.Type.Item)
    goods:MarshalMarketBean(v.marketItem)
    goods.isMaxPrice = v.isMaxPrice == 1
    table.insert(self.m_bidGoodsList, goods)
  end
  for i, v in ipairs(p.marketPetList) do
    local goods = GoodsDataFactory.Create(GoodsData.Type.Pet)
    goods:MarshalMarketBean(v.marketPet)
    goods.isMaxPrice = v.isMaxPrice == 1
    table.insert(self.m_bidGoodsList, goods)
  end
end
def.method("table", "=>", GoodsData).AddMarketItemToBidList = function(self, v)
  local preGoods = self:GetBidItemGoods(v.marketId)
  local goods
  if preGoods then
    goods = preGoods
  else
    goods = GoodsDataFactory.Create(GoodsData.Type.Item)
    table.insert(self.m_bidGoodsList, goods)
  end
  goods:MarshalMarketBean(v)
  return goods
end
def.method("table", "=>", GoodsData).AddMarketPetToBidList = function(self, v)
  local preGoods = self:GetBidPetGoods(v.marketId)
  local goods
  if preGoods then
    goods = preGoods
  else
    goods = GoodsDataFactory.Create(GoodsData.Type.Pet)
    table.insert(self.m_bidGoodsList, goods)
  end
  goods:MarshalMarketBean(v)
  return goods
end
def.method("userdata", "=>", GoodsData).GetBidItemGoods = function(self, marketId)
  return self:GetBidGoods(GoodsData.Type.Item, marketId)
end
def.method("userdata", "=>", GoodsData).GetBidPetGoods = function(self, marketId)
  return self:GetBidGoods(GoodsData.Type.Pet, marketId)
end
def.method("number", "userdata", "=>", GoodsData).GetBidGoods = function(self, goodsType, marketId)
  for i, v in ipairs(self.m_bidGoodsList) do
    if v.marketId == marketId and v.type == goodsType then
      return v
    end
  end
  return nil
end
def.method("userdata", "=>", GoodsData).RemoveItemGoods = function(self, marketId)
  return self:RemoveGoods(GoodsData.Type.Item, marketId)
end
def.method("userdata", "=>", GoodsData).RemovePetGoods = function(self, marketId)
  return self:RemoveGoods(GoodsData.Type.Pet, marketId)
end
def.method("number", "userdata", "=>", GoodsData).RemoveGoods = function(self, goodsType, marketId)
  for i, v in ipairs(self.m_bidGoodsList) do
    if v.marketId == marketId and v.type == goodsType then
      table.remove(self.m_bidGoodsList, i)
      return v
    end
  end
  return nil
end
def.method(GoodsData).AddGoodsToBidList = function(self, goods)
  table.insert(self.m_bidGoodsList, goods)
end
def.method("table", "=>", GoodsData).SNewBidedItemGoods = function(self, p)
  local goods = GoodsDataFactory.Create(GoodsData.Type.Item)
  goods.marketId = p.marketId
  goods.itemId = p.itemId
  goods.price = p.price
  goods.isMaxPrice = true
  goods.num = 1
  goods:AddState(GoodsData.State.STATE_PUBLIC)
  self:AddGoodsToBidList(goods)
  return goods
end
def.method("table", "=>", GoodsData).SNewBidedPetGoods = function(self, p)
  local goods = GoodsDataFactory.Create(GoodsData.Type.Pet)
  goods.marketId = p.marketId
  goods.petCfgId = p.petCfgId
  goods.price = p.price
  goods.isMaxPrice = true
  goods.num = 1
  goods:AddState(GoodsData.State.STATE_PUBLIC)
  self:AddGoodsToBidList(goods)
  return goods
end
def.method().QueryAllBidGoodsReq = function(self)
  TradingArcadeProtocol.CQueryAllAuctionReq()
end
def.method(GoodsData, "=>", "boolean").GetBidGoodsReq = function(self, goods)
  local bidGoods = self:GetBidGoods(goods.type, goods.marketId)
  if bidGoods == nil then
    return false
  end
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CGetAuctionItemReq(goods.marketId, goods.itemId)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CGetAuctionPetReq(goods.marketId, goods.petCfgId)
  end
  return true
end
def.method("number", "=>", "number").CalcMinBidPrice = function(self, price)
  local rate = _G.constant.MarketConsts.AUCTION_ADD_PRICE_RATE / _G.NUMBER_WAN + 1
  return require("Common.MathHelper").Ceil(price * rate)
end
def.method("=>", "number").GetBidAddPriceMinPercent = function(self)
  local percent = _G.constant.MarketConsts.AUCTION_ADD_PRICE_RATE / 100
  return percent
end
def.method("=>", "boolean").HasNotify = function(self)
  for i, v in ipairs(self.m_bidGoodsList) do
    if self:BidGoodsHasNotify(v) then
      return true
    end
  end
  return false
end
def.method(GoodsData, "=>", "boolean").BidGoodsHasNotify = function(self, goods)
  if goods:IsInState(GoodsData.State.STATE_SELLED) and goods.isMaxPrice then
    return true
  end
  local key = ""
  if goods.type == GoodsData.Type.Item then
    key = tostring(goods.marketId) .. goods.itemId
  else
    key = tostring(goods.marketId) .. goods.petCfgId
  end
  if self.m_beExceededMap and self.m_beExceededMap[key] then
    return true
  end
  return false
end
def.method(GoodsData).UnRecordBeExceededGoods = function(self, goods)
  local refId
  if goods.type == GoodsData.Type.Item then
    refId = goods.itemId
  else
    refId = goods.petCfgId
  end
  if refId then
    self:UnRecordBeExceeded(goods.marketId, refId)
  end
end
def.method("userdata", "number").RecordBeExceeded = function(self, marketId, refId)
  self.m_beExceededMap = self.m_beExceededMap or {}
  local key = tostring(marketId) .. refId
  self.m_beExceededMap[key] = true
end
def.method("userdata", "number").UnRecordBeExceeded = function(self, marketId, refId)
  if self.m_beExceededMap == nil then
    return
  end
  local key = tostring(marketId) .. refId
  self.m_beExceededMap[key] = nil
end
def.static().Reset = function()
  if instance == nil then
    return
  end
  local self = instance
  self.m_bidGoodsList = {}
  self.m_beExceededMap = nil
end
return BidMgr.Commit()
