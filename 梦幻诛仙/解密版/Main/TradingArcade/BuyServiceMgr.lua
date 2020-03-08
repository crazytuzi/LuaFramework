local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BuyServiceMgr = Lplus.Class(MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local GoodsDataFactory = require("Main.TradingArcade.GoodsDataFactory")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local def = BuyServiceMgr.define
def.const("table").Mode = {Public = 0, OnSell = 1}
def.field("table").m_items = nil
def.field("table").m_concernGoodsList = nil
def.field("number").m_mode = 0
local instance
def.static("=>", BuyServiceMgr).Instance = function()
  if instance == nil then
    instance = BuyServiceMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_items = {}
  self.m_concernGoodsList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BuyServiceMgr.OnLeaveWorld)
end
def.static("table", "table").OnLeaveWorld = function()
  instance.m_items = {}
  instance.m_concernGoodsList = {}
end
def.method("number").SetMode = function(self, mode)
  self.m_mode = mode
end
def.method("number", "=>", "boolean").IsInMode = function(self, mode)
  return self.m_mode == mode
end
def.method("number", "=>", "number").GetSubTypeTotalPage = function(self, subType)
  local subTypeItem = self.m_items[subType]
  if subTypeItem == nil then
    return 0
  end
  return subTypeItem.totalPage
end
def.method("number", "number", "=>", "table").GetItemsBuyPage = function(self, subType, pageIndex)
  local subTypeItem = self.m_items[subType]
  if subTypeItem == nil then
    return nil
  end
  return subTypeItem.pages[pageIndex]
end
def.method().ClearAllGoods = function(self)
  self.m_items = {}
end
def.method("=>", "table").GetConcernGoodsList = function(self)
  return self.m_concernGoodsList
end
def.method("userdata", "=>", GoodsData).GetItemGoods = function(self, marketId)
  return self:GetGoods(GoodsData.Type.Item, marketId)
end
def.method("userdata", "=>", GoodsData).GetPetGoods = function(self, marketId)
  return self:GetGoods(GoodsData.Type.Pet, marketId)
end
def.method("number", "userdata", "=>", GoodsData).GetGoods = function(self, goodsType, marketId)
  for k, subTypeItem in pairs(self.m_items) do
    for pageIndex, page in pairs(subTypeItem.pages) do
      for i, v in ipairs(page) do
        if marketId == v.marketId and goodsType == v.type then
          return v
        end
      end
    end
  end
  return nil
end
def.method(GoodsData, "=>", "boolean").HasConcern = function(self, goods)
  if goods == nil then
    return false
  end
  local goods = self:GetConcernGoods(goods.type, goods.marketId)
  if goods then
    return true
  else
    return false
  end
end
def.method("userdata", "=>", GoodsData).GetConcernItemGoods = function(self, marketId)
  return self:GetConcernGoods(GoodsData.Type.Item, marketId)
end
def.method("userdata", "=>", GoodsData).GetConcernPetGoods = function(self, marketId)
  return self:GetConcernGoods(GoodsData.Type.Pet, marketId)
end
def.method("number", "userdata", "=>", GoodsData).GetConcernGoods = function(self, goodsType, marketId)
  for i, v in ipairs(self.m_concernGoodsList) do
    if v.marketId == marketId and v.type == goodsType then
      return v
    end
  end
  return nil
end
def.method(GoodsData, "=>", "boolean").IsSelfSell = function(self, goods)
  local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
  return SellServiceMgr.Instance():GetGoods(goods.type, goods.marketId) ~= nil
end
def.method("table").SSynRoleConcernInfo = function(self, p)
  self.m_concernGoodsList = {}
  for i, v in ipairs(p.marketItemList) do
    self:AddMarketItemToConcernList(v)
  end
  for i, v in ipairs(p.marketPetList) do
    self:AddMarketPetToConcernList(v)
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.CONCERN_GOODS_LIST_UPDATE, {nil})
end
def.method("table", "=>", GoodsData).AddMarketItemToConcernList = function(self, v)
  local preGoods = self:GetConcernItemGoods(v.marketId)
  local goods
  if preGoods then
    goods = preGoods
  else
    goods = GoodsDataFactory.Create(GoodsData.Type.Item)
    table.insert(self.m_concernGoodsList, goods)
  end
  goods:MarshalMarketBean(v)
  local sellGoods = self:GetGoods(GoodsData.Type.Item, v.marketId)
  if sellGoods then
    sellGoods:IncConcernRoleNum()
  end
  return goods
end
def.method("table", "=>", GoodsData).AddMarketPetToConcernList = function(self, v)
  local preGoods = self:GetConcernPetGoods(v.marketId)
  local goods
  if preGoods then
    goods = preGoods
  else
    goods = GoodsDataFactory.Create(GoodsData.Type.Pet)
    table.insert(self.m_concernGoodsList, goods)
  end
  goods:MarshalMarketBean(v)
  local sellGoods = self:GetGoods(GoodsData.Type.Pet, v.marketId)
  if sellGoods then
    sellGoods:IncConcernRoleNum()
  end
  return goods
end
def.method("userdata", "=>", GoodsData).RemoveItemGoodsFromConcernList = function(self, marketId)
  return self:RemoveGoodsFromConcernList(marketId, GoodsData.Type.Item)
end
def.method("userdata", "=>", GoodsData).RemovePetGoodsFromConcernList = function(self, marketId)
  return self:RemoveGoodsFromConcernList(marketId, GoodsData.Type.Pet)
end
def.method("userdata", "number", "=>", GoodsData).RemoveGoodsFromConcernList = function(self, marketId, goodsType)
  local sellGoods = self:GetGoods(goodsType, marketId)
  if sellGoods then
    sellGoods:DecConcernRoleNum()
  end
  for i, v in ipairs(self.m_concernGoodsList) do
    if v.marketId == marketId and v.type == goodsType then
      v:DecConcernRoleNum()
      table.remove(self.m_concernGoodsList, i)
      return v
    end
  end
  return nil
end
def.method("=>", "boolean").IsConcernListFull = function(self)
  return #self.m_concernGoodsList >= _G.constant.MarketConsts.COLLECTION_NUM
end
def.method("number", "=>", "table").CreateSubTypeItem = function(self, subType)
  self.m_items = {}
  if self.m_items[subType] == nil then
    self.m_items[subType] = {
      subType = subType,
      totalPage = 0,
      pages = {}
    }
  end
  return self.m_items[subType]
end
def.method("table").AddPageItemInfo = function(self, pageItemInfo)
  local subType = pageItemInfo.subid
  local subTypeItem = self:CreateSubTypeItem(subType)
  subTypeItem.totalPage = pageItemInfo.totalPageNum
  warn("AddPageItemInfo #pageItemInfo.marketItemList", #pageItemInfo.marketItemList)
  local datas = {}
  for i, v in ipairs(pageItemInfo.marketItemList) do
    local data = GoodsDataFactory.Create(GoodsData.Type.Item)
    data:MarshalMarketBean(v)
    datas[#datas + 1] = data
  end
  subTypeItem.pages = {}
  subTypeItem.pages[pageItemInfo.pageIndex] = datas
end
def.method("table").AddPagePetInfo = function(self, pagePetInfo)
  local subType = pagePetInfo.subid
  local subTypeItem = self:CreateSubTypeItem(subType)
  subTypeItem.totalPage = pagePetInfo.totalPageNum
  local datas = {}
  warn("AddPagePetInfo", #pagePetInfo.marketPetList)
  for i, v in ipairs(pagePetInfo.marketPetList) do
    local data = GoodsDataFactory.Create(GoodsData.Type.Pet)
    data:MarshalMarketBean(v)
    datas[#datas + 1] = data
  end
  subTypeItem.pages = {}
  subTypeItem.pages[pagePetInfo.pageIndex] = datas
end
def.method(GoodsData, "number").BuyGoods = function(self, goods, buyNum)
  if self:IsSelfSell(goods) then
    Toast(textRes.TradingArcade[39])
    return
  end
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CBuyItemReq(goods.marketId, goods.itemId, goods.price, buyNum)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CBuyPetReq(goods.marketId, goods.petCfgId, goods.price)
  end
end
def.method(GoodsData).ConcernGoods = function(self, goods)
  if self:IsSelfSell(goods) then
    Toast(textRes.TradingArcade[39])
    return
  end
  if self:IsConcernListFull() then
    Toast(textRes.TradingArcade[50])
    return
  end
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CConcernItemReq(goods.marketId, goods.itemId)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CConcernPetReq(goods.marketId, goods.petCfgId)
  end
end
def.method(GoodsData).UnConcernGoods = function(self, goods)
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CUnConcernItemReq(goods.marketId)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CUnConcernPetReq(goods.marketId)
  end
end
def.method("number", "number", "number").QueryGoodsPage = function(self, subType, priceSort, pageIndex)
  if self.m_mode == BuyServiceMgr.Mode.OnSell then
    if TradingArcadeUtils.IsPetSubType(subType) then
      TradingArcadeProtocol.CQueryMarketPet(subType, priceSort, pageIndex)
    else
      TradingArcadeProtocol.CQueryMarketItem(subType, priceSort, pageIndex)
    end
  else
    self:QueryPublicGoodsPage(subType, priceSort, pageIndex)
  end
end
def.method("number", "number", "number").QueryPublicGoodsPage = function(self, subType, priceSort, pageIndex)
  if TradingArcadeUtils.IsPetSubType(subType) then
    TradingArcadeProtocol.CQueryMarketPublicPet(subType, priceSort, pageIndex)
  else
    TradingArcadeProtocol.CQueryMarketPublicItem(subType, priceSort, pageIndex)
  end
end
def.method("number", "number", "number", "number").QueryGoodsPageWithLevel = function(self, subType, priceSort, pageIndex, level)
  if TradingArcadeUtils.IsPetSubType(subType) then
    TradingArcadeProtocol.CQueryMarketPetWithLevel(subType, priceSort, level, self.m_mode, pageIndex)
  else
    TradingArcadeProtocol.CQueryMarketItemWithLevel(subType, priceSort, level, self.m_mode, pageIndex)
  end
end
def.method(GoodsData, "function").QueryGoodsDetail = function(self, goods, callback)
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CQueryItemInfoReq(goods.marketId, goods.itemId, goods.price, function(p)
      goods.itemInfo = p.itemInfo
      goods.sellerRoleId = p.sellerRoleId
      if callback then
        callback(goods)
      end
    end)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CQueryPetInfoReq(goods.marketId, goods.petCfgId, goods.price, function(p)
      goods.petInfo = p.petInfo
      goods.sellerRoleId = p.sellerRoleId
      if callback then
        callback(goods)
      end
    end)
  end
end
def.method().CQueryAllConcernReq = function(self)
  TradingArcadeProtocol.CQueryAllConcernReq()
end
return BuyServiceMgr.Commit()
