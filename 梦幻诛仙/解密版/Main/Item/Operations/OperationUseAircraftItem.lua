local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseAircraftItem = Lplus.Extend(OperationBase, "OperationUseAircraftItem")
local def = OperationUseAircraftItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.AIR_CRAFT_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.USE_AIRCRAFT_ITEM, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationUseAircraftItem.Commit()
return OperationUseAircraftItem
