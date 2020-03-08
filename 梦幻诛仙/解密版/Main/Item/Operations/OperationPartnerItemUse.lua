local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationPartnerItemUse = Lplus.Extend(OperationBase, "OperationPartnerItemUse")
local def = OperationPartnerItemUse.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.PARTNER_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemData = require("Main.Item.ItemData")
  local item = ItemData.Instance():GetItem(bagId, itemKey)
  if item then
    local itemId = item.id
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Partner_Use, {itemId = itemId})
  else
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Partner_Use, {})
  end
  return true
end
OperationPartnerItemUse.Commit()
return OperationPartnerItemUse
