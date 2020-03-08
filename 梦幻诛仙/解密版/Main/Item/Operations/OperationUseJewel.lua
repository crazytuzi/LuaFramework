local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationUseJewel = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationUseJewel.define
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.JewelBag and itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM and bFeatureOpen then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  warn("Use Jewel...")
  return true
end
return OperationUseJewel.Commit()
