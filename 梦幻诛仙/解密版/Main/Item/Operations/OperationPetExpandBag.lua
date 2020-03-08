local Lplus = require("Lplus")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationPetExpandBag = Lplus.Extend(OperationBase, "OperationPetExpandBag")
local def = OperationPetExpandBag.define
def.field("number").itemType = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  if source == ItemTipsMgr.Source.Bag and (itemBase.itemType == ItemType.PET_EXPAND_BAG or itemBase.itemType == ItemType.PET_EXPAND_STORAGE) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local PetModule = Lplus.ForwardDeclare("PetModule")
  if self.itemType == ItemType.PET_EXPAND_BAG then
    PetModule.Instance():TryToExpandPetBag(PetModule.PET_BAG_ID)
  elseif self.itemType == ItemType.PET_EXPAND_STORAGE then
    PetModule.Instance():TryToExpandPetBag(PetModule.PET_STORAGE_BAG_ID)
  end
  return false
end
OperationPetExpandBag.Commit()
return OperationPetExpandBag
