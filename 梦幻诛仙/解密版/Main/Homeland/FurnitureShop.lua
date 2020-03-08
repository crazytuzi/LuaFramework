local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FurnitureShop = Lplus.Class(MODULE_NAME)
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = FurnitureShop.define
def.field("number").m_todayRefreshCount = 0
def.field("table").m_sellIds = nil
def.field("boolean").m_reqingSellList = false
def.field("boolean").m_needRenew = true
local instance
def.static("=>", FurnitureShop).Instance = function(self)
  if instance == nil then
    instance = FurnitureShop()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSynRefreshFurnitureRes", FurnitureShop.OnSSynRefreshFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SBuyFurnitureRes", FurnitureShop.OnSBuyFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SBuyFurnitureFailedRes", FurnitureShop.OnSBuyFurnitureFailedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SSellFurnitureRes", FurnitureShop.OnSSellFurnitureRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SRecycleFurnitureReqRes", FurnitureShop.OnSRecycleFurnitureReqRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FurnitureShop.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, FurnitureShop.OnNewDay)
end
def.method("=>", "table").GetSellList = function(self)
  if self.m_needRenew then
    self:ReqSellList()
  end
  if self.m_sellIds == nil then
    return nil
  end
  local sellList = {}
  for id, num in pairs(self.m_sellIds) do
    local buyCountCfg = HomelandUtils.GetFurnitureBuyCountCfg(id)
    if buyCountCfg then
      local itemInfo = {}
      itemInfo.id = id
      itemInfo.num = num
      itemInfo.moneyType = buyCountCfg.buyMoneyType
      itemInfo.moneyNum = buyCountCfg.buyMoneyNum
      itemInfo.maxBuyNum = buyCountCfg.maxBuyNum
      sellList[#sellList + 1] = itemInfo
    end
  end
  return sellList
end
def.method("=>", "number").GetRefreshTimesPerDay = function(self)
  return _G.constant.CHomelandCfgConsts.FRESH_FURNITURE_MAX_COUNT
end
def.method("=>", "table").GetRefreshNeeds = function(self)
  local needs = {}
  needs.moneyType = _G.constant.CHomelandCfgConsts.FRESH_FURNITURE_NEED_MONEY_TYPE
  needs.moneyNum = _G.constant.CHomelandCfgConsts.FRESH_FURNITURE_NEED_MONEY_NUM
  return needs
end
def.method("=>", "number").GetRefreshRemainTimes = function(self)
  local remainTimes = _G.constant.CHomelandCfgConsts.FRESH_FURNITURE_MAX_COUNT - self.m_todayRefreshCount
  return math.max(0, remainTimes)
end
def.method().ReqSellList = function(self)
  if self.m_reqingSellList then
    return
  end
  self.m_reqingSellList = true
  local p = require("netio.protocol.mzm.gsp.homeland.CQueryFurnitureReq").new()
  gmodule.network.sendProtocol(p)
end
def.method().RefreshSellList = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CRefreshFurnitureReq").new()
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").BuyFurnitureReq = function(self, furnitureId, number)
  local p = require("netio.protocol.mzm.gsp.homeland.CBuyFurnitureReq").new(furnitureId, number)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").SellFurnitureReq = function(self, furnitureUuId, furnitureId)
  local p = require("netio.protocol.mzm.gsp.homeland.CSellFurnitureReq").new(furnitureUuId, furnitureId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").RecycleFurnitureReq = function(self, furnitureUuId, furnitureId)
  local p = require("netio.protocol.mzm.gsp.homeland.CRecycleFurnitureReq").new(furnitureUuId, furnitureId)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnLeaveWorld = function()
  instance.m_sellIds = nil
  instance.m_todayRefreshCount = 0
  instance.m_reqingSellList = false
  instance.m_needRenew = true
end
def.static("table", "table").OnNewDay = function(p)
  instance.m_todayRefreshCount = 0
  instance.m_needRenew = true
end
def.static("table").OnSSynRefreshFurnitureRes = function(p)
  print("OnSSynRefreshFurnitureRes ", p.dayRefreshCount, table.nums(p.canBuyItems))
  instance.m_todayRefreshCount = p.dayRefreshCount
  instance.m_sellIds = p.canBuyItems
  instance.m_needRenew = false
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Shop_Info, nil)
  if not instance.m_reqingSellList then
    Toast(textRes.Homeland[36])
  end
  instance.m_reqingSellList = false
end
def.static("table").OnSBuyFurnitureRes = function(p)
  print("OnSBuyFurnitureRes ", p.furnitureId, p.restCanBuyNum)
  if p.furnitureUuId then
    p.furnitureUuIds = {
      [p.furnitureUuId] = p.furnitureUuId
    }
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local furnitureCfg = ItemUtils.GetFurnitureCfg(p.furnitureId)
  local FurnitureBag = require("Main.Homeland.FurnitureBag")
  local buyNum = 0
  for k, v in pairs(p.furnitureUuIds) do
    local furnitureInfo = {
      id = p.furnitureId,
      uuid = v,
      area = furnitureCfg.area
    }
    FurnitureBag.Instance():AddFurniture(furnitureInfo)
    buyNum = buyNum + 1
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
  if instance.m_sellIds and instance.m_sellIds[p.furnitureId] then
    instance.m_sellIds[p.furnitureId] = p.restFreshNum
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Shop_Info, nil)
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemName = HtmlHelper.GetColoredItemName(p.furnitureId)
  if itemName == "" then
    return
  end
  local text = string.format(textRes.Homeland[37], itemName, buyNum, p.restCanBuyNum)
  Toast(text)
end
def.static("table").OnSBuyFurnitureFailedRes = function(p)
  print("OnSBuyFurnitureFailedRes ", p.furnitureId, p.restCanBuyNum)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemName = HtmlHelper.GetColoredItemName(p.furnitureId)
  if itemName == "" then
    return
  end
  local text = string.format(textRes.Homeland[66], itemName, p.restCanBuyNum)
  Toast(text)
end
def.static("table").OnSRecycleFurnitureReqRes = function(p)
  print("OnSRecycleFurnitureReqRes ", p.furnitureId, tostring(p.furnitureUuId), p.moneyNum)
  local self = instance
  self:SellFurnitureSuccessfully(p)
end
def.static("table").OnSSellFurnitureRes = function(p)
  print("OnSSellFurnitureRes ", p.furnitureId, tostring(p.furnitureUuId), p.moneyNum)
  local self = instance
  self:SellFurnitureSuccessfully(p)
end
def.method("table").SellFurnitureSuccessfully = function(self, p)
  local FurnitureBag = require("Main.Homeland.FurnitureBag")
  FurnitureBag.Instance():RemoveFurniture(p.furnitureUuId)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, nil)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local itemName = HtmlHelper.GetColoredItemName(p.furnitureId)
  if itemName == "" then
    return
  end
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local currency = CurrencyFactory.Create(p.moneyType)
  local moneyNum = p.moneyNum
  local moneyName = currency:GetName()
  local text = string.format(textRes.Homeland[47], itemName, 1, moneyNum, moneyName)
  Toast(text)
end
return FurnitureShop.Commit()
