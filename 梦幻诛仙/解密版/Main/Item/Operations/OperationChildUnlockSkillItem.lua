local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationChildUnlockSkillItem = Lplus.Extend(OperationBase, "OperationChildUnlockSkillItem")
local def = OperationChildUnlockSkillItem.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CHILDREN_SKILL_UN_LOCK then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  require("Main.Children.ui.ChildrenBagPanel").ShowChildrenBag(nil)
  Toast(textRes.Children[3078])
  return true
end
OperationChildUnlockSkillItem.Commit()
return OperationChildUnlockSkillItem
