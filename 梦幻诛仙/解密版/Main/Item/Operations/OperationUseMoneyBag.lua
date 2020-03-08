local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseMoneyBag = Lplus.Extend(OperationBase, "OperationUseMoneyBag")
local def = OperationUseMoneyBag.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.MONEYBAG_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemId = item.id
  local uuid = item.uuid
  ItemModule.UseMoneyBagItem(uuid[1])
  return true
end
OperationUseMoneyBag.Commit()
return OperationUseMoneyBag
