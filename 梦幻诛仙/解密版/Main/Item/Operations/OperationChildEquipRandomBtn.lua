local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationChildEquipRandomBtn = Lplus.Extend(OperationBase, "OperationChildEquipRandomBtn")
local def = OperationChildEquipRandomBtn.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if source == ItemTipsMgr.Source.ChildrenBag and itemBase.itemType == ItemType.CHILDREN_EQUIP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Children[3032]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.RANDOM_CHILD_EQUIP, {itemKey, context})
  return true
end
OperationChildEquipRandomBtn.Commit()
return OperationChildEquipRandomBtn
