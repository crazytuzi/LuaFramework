local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationJewelMount = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationJewelMount.define
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local JewelProtocols = require("Main.GodWeapon.Jewel.JewelProtocols")
local txtConst = textRes.GodWeapon.Jewel
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM and bFeatureOpen then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return txtConst[13]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  if not bFeatureOpen then
    Toast(txtConst[11])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    Toast(txtConst[14])
    return
  end
  local slotIdx = require("Main.GodWeapon.ui.JewelNode").Instance():GetCurSelSlot() or 0
  if slotIdx < 1 then
    Toast(txtConst[15])
    return true
  end
  JewelProtocols.CSendUnMountJewelReq(bagId, itemKey, slotIdx, item.id)
  return true
end
return OperationJewelMount.Commit()
