local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationSweepFloor = Lplus.Extend(OperationBase, "OperationSweepFloor")
local def = OperationSweepFloor.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.FLOOR_SWEEP_ITEM then
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
  if item then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.FLOOR_ITEM_USE, {
      item.id
    })
  end
  return true
end
OperationSweepFloor.Commit()
return OperationSweepFloor
