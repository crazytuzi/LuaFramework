local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationRefreshPetEquipment = Lplus.Extend(OperationBase, "OperationRefreshPetEquipment")
local def = OperationRefreshPetEquipment.define
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  self.itemType = itemBase.itemType
  self.source = source
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.PET_EQUIP_REFRESH then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_EQUIPMENT_XILIAN_PANEL_REQ, nil)
  return true
end
OperationRefreshPetEquipment.Commit()
return OperationRefreshPetEquipment
