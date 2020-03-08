local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SellServiceMgr = Lplus.Class(MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local GoodsDataFactory = require("Main.TradingArcade.GoodsDataFactory")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local MathHelper = require("Common.MathHelper")
local def = SellServiceMgr.define
def.field("table").m_sellList = nil
def.field("boolean").m_hasNotify = false
def.field("boolean").m_hasNotifyInit = false
local instance
def.static("=>", SellServiceMgr).Instance = function()
  if instance == nil then
    instance = SellServiceMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_sellList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, SellServiceMgr.OnLeaveWorld)
end
def.static("table", "table").OnLeaveWorld = function()
  instance.m_sellList = {}
  instance.m_hasNotify = false
end
def.method("=>", "boolean").HasNotify = function(self)
  return self.m_hasNotify
end
def.method().CheckNotify = function(self)
  local hasNotify = false
  for i, v in ipairs(self.m_sellList) do
    if v:IsInState(GoodsData.State.STATE_SELLED) then
      hasNotify = true
      break
    end
    if v:IsInState(GoodsData.State.STATE_EXPIRE) then
      hasNotify = true
      break
    end
    if v:GetGainMoney() > 0 then
      hasNotify = true
      break
    end
  end
  if hasNotify ~= self.m_hasNotify then
    self.m_hasNotify = hasNotify
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {hasNotify})
  end
end
def.method("table").SSynRoleOnShelfInfo = function(self, p)
  self.m_sellList = {}
  for i, v in ipairs(p.marketItemList) do
    self:SAddMarketItem(v)
  end
  for i, v in ipairs(p.marketPetList) do
    self:SAddMarketPet(v)
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, nil)
  self:CheckNotify()
end
def.method("table", "=>", GoodsData).SAddMarketItem = function(self, marketItem)
  local preGoods = self:GetItemGoods(marketItem.marketId)
  local goods
  if preGoods then
    goods = preGoods
  else
    goods = GoodsDataFactory.Create(GoodsData.Type.Item)
    table.insert(self.m_sellList, goods)
  end
  goods:MarshalMarketBean(marketItem)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
  return goods
end
def.method("table", "=>", GoodsData).SAddMarketPet = function(self, marketPet)
  local preGoods = self:GetPetGoods(marketPet.marketId)
  local goods
  if preGoods then
    goods = preGoods
  else
    goods = GoodsDataFactory.Create(GoodsData.Type.Pet)
    table.insert(self.m_sellList, goods)
  end
  goods:MarshalMarketBean(marketPet)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
  return goods
end
def.method("=>", "table").GetSellList = function(self)
  return self.m_sellList
end
def.method("=>", "number").GetSellGoodsNum = function(self)
  return #self.m_sellList
end
def.method("=>", "number").GetMaxSellGoodsNum = function(self)
  return _G.constant.MarketConsts.AUCTION_GRID_NUM
end
def.method("=>", "boolean").IsSellGridFull = function(self)
  return self:GetSellGoodsNum() >= self:GetMaxSellGoodsNum()
end
def.method("userdata", "=>", GoodsData).GetItemGoods = function(self, marketId)
  return self:GetGoods(GoodsData.Type.Item, marketId)
end
def.method("userdata", "=>", GoodsData).GetPetGoods = function(self, marketId)
  return self:GetGoods(GoodsData.Type.Pet, marketId)
end
def.method("number", "userdata", "=>", GoodsData).GetGoods = function(self, goodsType, marketId)
  for i, v in ipairs(self.m_sellList) do
    if marketId == v.marketId and goodsType == v.type then
      return v
    end
  end
  return nil
end
def.method("userdata", "=>", GoodsData).UnshelveItemGoods = function(self, marketId)
  return self:UnshelveGoods(GoodsData.Type.Item, marketId)
end
def.method("userdata", "=>", GoodsData).UnshelvePetGoods = function(self, marketId)
  return self:UnshelveGoods(GoodsData.Type.Pet, marketId)
end
def.method("number", "userdata", "=>", GoodsData).UnshelveGoods = function(self, goodsType, marketId)
  local goods
  for i, v in ipairs(self.m_sellList) do
    if marketId == v.marketId and goodsType == v.type then
      table.remove(self.m_sellList, i)
      goods = v
      break
    end
  end
  if goods then
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELF_SELL_GOODS_UPDATE, {goods})
  end
  return goods
end
def.method(GoodsData).UnshelveGoodsReq = function(self, goods)
  if goods == nil then
    return
  end
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CGetSellItemReq(goods.marketId, goods.itemId)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CGetSellPetReq(goods.marketId, goods.petCfgId)
  end
end
def.method("=>", "table").GetRarityItemList = function(self)
  local list = {}
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  for itemKey, item in pairs(items) do
    if ItemUtils.IsRarity(item.id) and not ItemUtils.IsItemBind(item) and not TradingArcadeUtils.IsItemFrozen(item) then
      local itemBase = ItemUtils.GetItemBase(item.id)
      if itemBase and not itemBase.isProprietary then
        list[#list + 1] = item
      end
    end
  end
  return list
end
def.method("=>", "table").GetRarityPetList = function(self)
  local list = {}
  local pets = PetMgr.Instance():GetPets()
  for petId, pet in pairs(pets) do
    local notBinded = not pet:IsBinded()
    local notSpecial = not pet:IsSpecial()
    if pet:IsRarity() and notBinded and notSpecial then
      list[#list + 1] = pet
    end
  end
  return list
end
def.method("number", "=>", "number").CalcServiceCharge = function(self, money)
  local rate = _G.constant.MarketConsts.SELL_TAX_RATE / 10000
  local val = MathHelper.Floor(money * rate)
  return math.min(val, _G.constant.MarketConsts.MAX_SELL_TAX)
end
def.method("number", "=>", "number").CalcUnshelveBidGoodsCharge = function(self, money)
  local rate = _G.constant.MarketConsts.AUCTION_GOODS_OFF_SHELF_RATE / 10000
  local val = MathHelper.Floor(money * rate)
  return val
end
def.method("table", "=>", "number").GetItemMaxOnSellNum = function(self, item)
  if item == nil then
    return 0
  end
  local marketItemCfg = TradingArcadeUtils.GetMarketItemCfg(item.id)
  if marketItemCfg == nil then
    return 0
  end
  local subId = marketItemCfg.subid
  local subTypeCfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
  if subTypeCfg == nil then
    return 0
  end
  return math.min(item.number, subTypeCfg.maxsellnum)
end
def.method("=>", "number").GetAfterTaxIncome = function(self)
  local income = 0
  for i, v in ipairs(self.m_sellList) do
    local money = v:GetGainMoney()
    income = income + self:GetAftexTaxValue(money)
  end
  return income
end
def.method("number", "=>", "number").GetAftexTaxValue = function(self, value)
  local afterTaxValue = MathHelper.Floor((_G.NUMBER_WAN - constant.MarketConsts.GET_MONEY_TAX_RATE) / _G.NUMBER_WAN * value)
  return afterTaxValue
end
def.method("table", "number", "number").SellItem = function(self, item, price, num)
  TradingArcadeProtocol.CSellItemReq(item.itemKey, item.id, price, num)
end
def.method("table", "number").SellPet = function(self, pet, price)
  TradingArcadeProtocol.CSellPetReq(pet.id, price)
end
def.method(GoodsData, "number").ReSellItem = function(self, goods, price)
  TradingArcadeProtocol.CReSellItemReq(goods.marketId, goods.itemId, price, goods.num)
end
def.method(GoodsData, "number").ReSellPet = function(self, goods, price)
  TradingArcadeProtocol.CReSellPetReq(goods.marketId, price)
end
def.method(GoodsData, "function").QueryGoodsDetail = function(self, goods, callback)
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CQueryItemInfoReq(goods.marketId, goods.itemId, goods.price, function(p)
      local goods = self:GetItemGoods(p.marketId)
      if goods then
        goods.itemInfo = p.itemInfo
      end
      if callback then
        callback(goods)
      end
    end)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CQueryPetInfoReq(goods.marketId, goods.petCfgId, goods.price, function(p)
      local goods = self:GetPetGoods(p.marketId)
      if goods then
        goods.petInfo = p.petInfo
      end
      if callback then
        callback(goods)
      end
    end)
  end
end
def.method().AutoGetMoney = function(self)
  TradingArcadeProtocol.CAutoGetMoneyReq()
end
def.method(GoodsData).GetGoodsMoney = function(self, goods)
  if goods.type == GoodsData.Type.Item then
    TradingArcadeProtocol.CGetMoneyItemReq(goods.marketId)
  elseif goods.type == GoodsData.Type.Pet then
    TradingArcadeProtocol.CGetMoneyPetReq(goods.marketId)
  end
end
return SellServiceMgr.Commit()
