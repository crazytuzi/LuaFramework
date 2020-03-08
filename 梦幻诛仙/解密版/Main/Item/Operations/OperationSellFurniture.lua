local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationSellFurniture = Lplus.Extend(OperationBase, "OperationSellFurniture")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local FurnitureBag = require("Main.Homeland.FurnitureBag")
local ItemUtils = require("Main.Item.ItemUtils")
local def = OperationSellFurniture.define
def.field("table").m_item = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  self.m_item = item
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.FURNITURE_ITEM and source == ItemTipsMgr.Source.FurnitureBag then
    local haveNum = FurnitureBag.Instance():GetFurnitureNumbersById(item.id)
    return haveNum > 0
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8133]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = self.m_item
  if item == nil then
    return true
  end
  local FurnitureBag = require("Main.Homeland.FurnitureBag")
  local furnitures = FurnitureBag.Instance():GetFurnituresById(item.id)
  local _, furniture = next(furnitures)
  if furniture == nil then
    warn("no more furniture to sell")
    return true
  end
  local HomelandUtils = require("Main.Homeland.HomelandUtils")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local buyCountCfg = HomelandUtils.GetFurnitureBuyCountCfg(furniture.id)
  local isInCountCfg = HomelandUtils.GetFurnitureBuyCountCfg(furniture.id)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  if buyCountCfg == nil then
    buyCountCfg = {}
    local cfg = ItemUtils.GetItemBase(furniture.id)
    local goldCfg = ItemUtils.GetItemRecycleGold(furniture.id)
    if goldCfg ~= -1 then
      buyCountCfg.sellMoneyNum = goldCfg
      buyCountCfg.sellMoneyType = MoneyType.GOLD
    else
      buyCountCfg.sellMoneyNum = cfg.sellSilver
      buyCountCfg.sellMoneyType = MoneyType.SILVER
    end
  end
  local title = textRes.Homeland[62]
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local currency = CurrencyFactory.Create(buyCountCfg.sellMoneyType)
  local moneyName = currency:GetName()
  local coloredItemName = HtmlHelper.GetColoredItemName(furniture.id)
  local coloredItemName = string.gsub(coloredItemName, "<font color=#([0-9a-fA-F]+)>(.-)</font>", "%[%1%]%2%[-%]")
  local desc = string.format(textRes.Homeland[61], tostring(buyCountCfg.sellMoneyNum), moneyName, coloredItemName)
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      local FurnitureShop = require("Main.Homeland.FurnitureShop")
      if isInCountCfg ~= nil then
        FurnitureShop.Instance():SellFurnitureReq(furniture.uuid, furniture.id)
      else
        FurnitureShop.Instance():RecycleFurnitureReq(furniture.uuid, furniture.id)
      end
    end
  end, nil)
  return true
end
OperationSellFurniture.Commit()
return OperationSellFurniture
