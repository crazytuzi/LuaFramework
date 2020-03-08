local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationChildrenFashion = Lplus.Extend(OperationBase, "OperationChildrenFashion")
local def = OperationChildrenFashion.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CHILDREN_FASHION_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  require("Main.Children.ChildrenInterface").OpenChildrenBag(nil)
  Toast(textRes.Children[5008])
  return true
end
OperationChildrenFashion.Commit()
return OperationChildrenFashion
