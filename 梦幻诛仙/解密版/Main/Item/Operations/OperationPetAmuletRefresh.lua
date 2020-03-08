local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationPetAmuletRefresh = Lplus.Extend(OperationBase, "OperationPetAmuletRefresh")
local def = OperationPetAmuletRefresh.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local itemType = itemBase.itemType
  if (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.PetBasicNode or source == ItemTipsMgr.Source.ChildrenItemBag or source == ItemTipsMgr.Source.ChildrenBag) and itemBase.itemType == ItemType.PET_EQUIP then
    return self:IsPetAmulet(itemBase)
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8126]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_EQUIPMENT_XILIAN_PANEL_REQ, nil)
  return true
end
def.method("table", "=>", "boolean").IsPetAmulet = function(self, itemBase)
  local itemId = itemBase.itemid
  local cfg = require("Main.Pet.PetUtility").GetPetEquipmentCfg(itemId)
  if cfg == nil then
    return false
  end
  local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
  return cfg.equipType == PetEquipType.AMULET
end
OperationPetAmuletRefresh.Commit()
return OperationPetAmuletRefresh
