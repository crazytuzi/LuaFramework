local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local OperationExtendBag = Lplus.Extend(OperationBase, "OperationExtendBag")
local def = OperationExtendBag.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.ROLE_EXPAND_BAG then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.ROLE_EXPAND_BAG then
    local uuid = item.uuid[#item.uuid]
    ItemModule.Instance():TryExtendBag(ItemModule.BAG, uuid)
  end
  return true
end
OperationExtendBag.Commit()
return OperationExtendBag
