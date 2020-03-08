local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local OperationUseAllItem = Lplus.Extend(OperationBase, "OperationUseAllItem")
local def = OperationUseAllItem.define
local function UseAllMoneyItem(bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseMoneyBagItem").new(item.uuid[1], 1)
  gmodule.network.sendProtocol(p)
end
local function UseAllGiftItem(bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseGiftBagItem").new(item.uuid[1], 1)
  gmodule.network.sendProtocol(p)
end
local UseAllOracleItem = function(bagId, itemKey, m_panel, context)
  warn("[OperationUseAllItem:UseAllOracleItem] Use All Oracle Item.")
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Oracle, {
    bagId = bagId,
    itemKey = itemKey,
    bUseAll = 1
  })
end
local function UseAllLotteryItem(bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseLotteryItem").new(item.uuid[1], 1)
  gmodule.network.sendProtocol(p)
end
local allUseItemType = {
  [ItemType.MONEYBAG_ITEM] = {
    openId = Feature.TYPE_USE_MONEY_BAG_ITEM,
    func = UseAllMoneyItem
  },
  [ItemType.GIFT_BAG_ITEM] = {
    openId = Feature.TYPE_USE_GIFT_BAG_ITEM,
    func = UseAllGiftItem
  },
  [ItemType.GENIUS_STONE_ITEM] = {openId = 0, func = UseAllOracleItem},
  [ItemType.LOTTERY_ITEM] = {
    openId = Feature.TYPE_USE_ALL_LOTTERY_ITEM,
    func = UseAllLotteryItem
  }
}
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local useItemCfg = ItemUtils.GetUseAllItemCfg(itemBase.itemid)
  if source == ItemTipsMgr.Source.Bag and useItemCfg then
    local useItemInfo = allUseItemType[itemBase.itemType]
    if useItemInfo and (useItemInfo.openId <= 0 or IsFeatureOpen(useItemInfo.openId)) then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[25]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local func = allUseItemType[itemBase.itemType].func
  if func then
    local function callback(id)
      if id == 1 then
        func(bagId, itemKey, m_panel, context)
      end
    end
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[24], itemBase.name), callback, nil)
    return true
  end
  return false
end
OperationUseAllItem.Commit()
return OperationUseAllItem
