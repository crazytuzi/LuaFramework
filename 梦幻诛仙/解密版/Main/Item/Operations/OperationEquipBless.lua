local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationEquipBless = Lplus.Extend(OperationBase, "OperationEquipBless")
local def = OperationEquipBless.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.EQUIPMENT_BLESSING_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not require("Main.Equip.EquipBlessMgr").Instance():CheckIsOpenAndToast() then
    return true
  end
  local EquipBlessPanel = require("Main.Equip.ui.EquipBlessPanel")
  EquipBlessPanel.Instance():ShowPanel()
  return true
end
OperationEquipBless.Commit()
return OperationEquipBless
