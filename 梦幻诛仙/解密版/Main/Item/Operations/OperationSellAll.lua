local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local OperationSellAll = Lplus.Extend(OperationBase, "OperationSellAll")
local def = OperationSellAll.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and itemBase.canSellAndThrow and itemBase.isProprietary == false and not CommercePitchUtils.CanItemCommerceToSell(itemBase.itemid, item) and ItemUtils.CallSellAll(itemBase.itemid) and item.number > 1 then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8127]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  local color = require("Main.Equip.EquipUtils").GetEquipDynamicColor(item, nil, itemBase)
  CommonConfirmDlg.ShowConfirm(textRes.Item[8358], string.format(textRes.Item[8359], ItemTipsMgr.Color[color], itemBase.name), function(selection, tag)
    if selection == 1 then
      local sellAllItem = require("netio.protocol.mzm.gsp.item.CSellAllItemReq").new(bagId, item.uuid[1])
      gmodule.network.sendProtocol(sellAllItem)
    end
  end, nil)
  return true
end
OperationSellAll.Commit()
return OperationSellAll
