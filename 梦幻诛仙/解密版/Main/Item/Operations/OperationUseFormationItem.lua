local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUseFormationItem = Lplus.Extend(OperationBase, "OperationUseFormationItem")
local def = OperationUseFormationItem.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local result = false
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.PET_FIGHT_FORMATION_ITEM then
    result = require("Main.PetTeam.PetTeamModule").Instance():IsOpen(false)
  end
  return result
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_USE_FORMATION_ITEM, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationUseFormationItem.Commit()
return OperationUseFormationItem
