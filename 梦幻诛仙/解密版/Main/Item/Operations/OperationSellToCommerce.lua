local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MathHelper = require("Common.MathHelper")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationSellToCommerce = Lplus.Extend(OperationBase, "OperationSellToCommerce")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
require("Main.module.ModuleId")
local def = OperationSellToCommerce.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.Commerce or source == ItemTipsMgr.Source.FabaoBag) and itemBase.canSellAndThrow and itemBase.isProprietary == false and CommercePitchUtils.CanItemCommerceToSell(itemBase.itemid, item) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8114]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if nil == item then
    return true
  end
  local price
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemSourceEnum = require("netio.protocol.mzm.gsp.item.ItemSourceEnum")
  if item.extraMap[ItemXStoreType.ITEM_SOURCE] == ItemSourceEnum.SHANGHUI then
    price = item.extraMap[ItemXStoreType.SHANGHUI_PRICE]
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  local function doSell()
    local commerceItem = CommercePitchUtils.GetCommerceItemInfo(item.id)
    if commerceItem == nil then
      return false
    end
    local curServerLv = require("Main.Server.Interface").GetServerLevelInfo().level
    if curServerLv < commerceItem.openServerLevel then
      Toast(textRes.Item[8335])
      if item.number > 1 then
        return false
      else
        return true
      end
    end
    local tbl = {
      bagId = bagId,
      itemKey = itemKey,
      itemId = item.id,
      shPrice = price,
      priceFlow = commerceItem.isPriceFlow
    }
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Sell_To_Commerce, tbl)
  end
  doSell()
  if item.number > 1 then
    return false
  else
    return true
  end
end
OperationSellToCommerce.Commit()
return OperationSellToCommerce
