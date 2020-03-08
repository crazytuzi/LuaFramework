local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationPetEquip = Lplus.Extend(OperationBase, "OperationPetEquip")
local def = OperationPetEquip.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if (source == ItemTipsMgr.Source.PetItemBag or source == ItemTipsMgr.Source.ChildrenItemBag) and itemBase.itemType == ItemType.PET_EQUIP then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8103]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self.source == ItemTipsMgr.Source.PetItemBag then
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT, {
      self.itemType,
      itemKey
    })
  elseif self.source == ItemTipsMgr.Source.ChildrenItemBag then
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.USE_PET_EQUIP, {
      self.itemType,
      itemKey
    })
  end
  return true
end
OperationPetEquip.Commit()
return OperationPetEquip
