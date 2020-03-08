local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local OperationSell = Lplus.Extend(OperationBase, "OperationSell")
local def = OperationSell.define
def.field("number").itemId = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.FabaoBag) and itemBase.canSellAndThrow and itemBase.isProprietary == false and not CommercePitchUtils.CanItemCommerceToSell(itemBase.itemid, item) then
    self.itemId = itemBase.itemid
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  if self.itemId > 0 then
    local gold = ItemUtils.GetItemRecycleGold(self.itemId)
    if gold > 0 then
      return textRes.Item[8102] .. textRes.Item.Gold
    else
      return textRes.Item[8102] .. textRes.Item.Silver
    end
  else
    return textRes.Item[8102]
  end
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local color = require("Main.Equip.EquipUtils").GetEquipDynamicColor(item, nil, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local function sendSellProtocol()
    local sellItem = require("netio.protocol.mzm.gsp.item.CSellItemReq").new(bagId, item.uuid[1], item.number)
    gmodule.network.sendProtocol(sellItem)
  end
  local function sendSellItem(selection, tag)
    if selection == 1 then
      if itemBase.itemType == ItemType.EQUIP then
        local strenLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
        if strenLevel < 3 then
          sendSellProtocol()
        else
          CommonConfirmDlg.ShowConfirm(textRes.Item[8321], textRes.Equip[126], function(select, tag)
            if 1 == select then
              sendSellProtocol()
            end
          end, nil)
        end
      else
        sendSellProtocol()
      end
    end
  end
  local isEquip = itemBase.itemType == ItemType.EQUIP
  local qilingLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
  local godWeaponStage = item.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE] or 0
  if isEquip and qilingLevel >= 5 then
    Toast(textRes.Equip[129])
  elseif godWeaponStage and godWeaponStage > 0 then
    Toast(textRes.Equip[133])
  elseif color <= 1 then
    local sellItem = require("netio.protocol.mzm.gsp.item.CSellItemReq").new(bagId, item.uuid[1], item.number)
    gmodule.network.sendProtocol(sellItem)
  else
    local gold = ItemUtils.GetItemRecycleGold(item.id)
    if gold >= 0 then
      CommonConfirmDlg.ShowConfirm(textRes.Item[8321], string.format(textRes.Item[8367], ItemTipsMgr.Color[color], itemBase.name, gold), sendSellItem, nil)
    else
      CommonConfirmDlg.ShowConfirm(textRes.Item[8321], string.format(textRes.Item[8322], ItemTipsMgr.Color[color], itemBase.name, itemBase.sellSilver), sendSellItem, nil)
    end
  end
  return true
end
OperationSell.Commit()
return OperationSell
