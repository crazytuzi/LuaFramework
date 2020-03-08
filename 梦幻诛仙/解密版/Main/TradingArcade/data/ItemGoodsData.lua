local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GoodsData = import(".GoodsData")
local ItemGoodsData = Lplus.Extend(GoodsData, MODULE_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = ItemGoodsData.define
def.field("number").itemId = 0
def.field("number").restNum = 0
def.field("number").sellNum = 0
def.field("table").itemInfo = nil
def.override("=>", "string").GetName = function(self)
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  if itemBase == nil then
    return ""
  end
  local color = HtmlHelper.NameColor[itemBase.namecolor] or "-"
  local coloredName = string.format("[%s]%s[-]", color, itemBase.name)
  return coloredName
end
def.override("=>", "table").GetIcon = function(self)
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local icon = {iconId = 0, bgSprite = ""}
  if itemBase == nil then
    return icon
  end
  icon.iconId = itemBase.icon
  icon.bgSprite = string.format("Cell_%02d", itemBase.namecolor)
  icon.rdText = self.num
  return icon
end
def.override("table").MarshalMarketBean = function(self, bean)
  self.num = bean.restNum
  GoodsData.MarshalMarketBean(self, bean)
  self.itemId = bean.itemId
  self.restNum = bean.restNum
  self.sellNum = bean.sellNum
end
def.override("number").SetNum = function(self, num)
  GoodsData.SetNum(self, num)
  self.restNum = self.num
end
def.method("number").AddSellNum = function(self, num)
  self.sellNum = self.sellNum + num
end
def.override("=>", "number").GetGainMoney = function(self)
  return self.sellNum * self.price
end
def.override("=>", "table").GetSellPriceBoundCfg = function(self)
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  local marketItemCfg = TradingArcadeUtils.GetMarketItemCfg(self.itemId)
  return {
    min = marketItemCfg.minprice,
    max = marketItemCfg.maxprice
  }
end
def.override("=>", "number").GetRefId = function(self)
  return self.itemId
end
return ItemGoodsData.Commit()
