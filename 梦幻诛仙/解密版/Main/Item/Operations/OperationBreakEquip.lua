local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipBreakMgr = require("Main.Equip.EquipBreakMgr")
local OperationBreakEquip = Lplus.Extend(OperationBase, "OperationBreakEquip")
local def = OperationBreakEquip.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and EquipBreakMgr.Instance():CanBreak(item) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Equip[401]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  EquipBreakMgr.Instance():BreakEquip(item)
  return true
end
OperationBreakEquip.Commit()
return OperationBreakEquip
