local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationChainGift = Lplus.Extend(OperationBase, "OperationChainGift")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local def = OperationChainGift.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CHAINED_GIFT_BAG_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CHAINED_GIFT_BAG) then
    Toast(textRes.Item[12005])
    return true
  end
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemId = item.id
  local uuid = item.uuid
  local endTime = item.extraMap[ItemXStoreType.CHAINED_GIFT_BAG_USE_TIME] or 0
  local curTime = _G.GetServerTime()
  local leftTime = math.max(0, endTime - curTime)
  require("Main.Item.ui.ChainGiftPanel").ShowGiftsPreview(itemId, uuid[1], leftTime)
  return true
end
OperationChainGift.Commit()
return OperationChainGift
