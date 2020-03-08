local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseChildSpecialSkillBook = Lplus.Extend(OperationBase, "OperationUseChildSpecialSkillBook")
local def = OperationUseChildSpecialSkillBook.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if (source == ItemTipsMgr.Source.ChildrenBag or source == ItemTipsMgr.Source.Bag) and itemBase.itemType == ItemType.CHILDREN_SPECIAL_SKILL_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self.source == ItemTipsMgr.Source.ChildrenBag then
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_SPECIAL_SKILL_BOOK, {itemKey})
  elseif self.source == ItemTipsMgr.Source.Bag then
    require("Main.Children.ui.ChildrenBagPanel").ShowChildrenBag(nil)
    Toast(textRes.Children[3078])
  end
  return true
end
OperationUseChildSpecialSkillBook.Commit()
return OperationUseChildSpecialSkillBook
