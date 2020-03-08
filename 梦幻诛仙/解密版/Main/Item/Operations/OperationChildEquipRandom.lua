local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationChildEquipRandom = Lplus.Extend(OperationBase, "OperationChildEquipRandom")
local def = OperationChildEquipRandom.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CHILDREN_EQUIP_RANDOM_PROP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self.source == ItemTipsMgr.Source.Bag then
    require("Main.Children.ui.ChildrenBagPanel").ShowChildrenBag(nil)
    Toast(textRes.Children[3078])
  end
  return true
end
OperationChildEquipRandom.Commit()
return OperationChildEquipRandom
