local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationGodWeaponLevelUp = Lplus.Extend(OperationBase, "OperationGodWeaponLevelUp")
local def = OperationGodWeaponLevelUp.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.SUPER_EQUIPMENT_IMPROVE_LEVEL_ITEM then
    if _G.IsCrossingServer() then
      return false
    elseif not require("Main.GodWeapon.GodWeaponModule").Instance():IsOpen(false) then
      return false
    else
      return true
    end
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  require("Main.Item.ui.InventoryDlg").Instance():DestroyPanel()
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.USE_ITEM_LEVEL_UP, {bagId = bagId, itemKey = itemKey})
  return true
end
OperationGodWeaponLevelUp.Commit()
return OperationGodWeaponLevelUp
