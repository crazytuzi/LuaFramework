local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local WingFabaoDetailDlg = require("Main.Equip.ui.WingFabaoDetailDlg")
local ItemModule = require("Main.Item.ItemModule")
local OperationOpenWingUI = Lplus.Extend(OperationBase, "OperationOpenWingUI")
local def = OperationOpenWingUI.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.WING_FAKE_ITEM and source == ItemTipsMgr.Source.Equip then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8128]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  require("Main.Wing.WingInterface").OpenWingPanel(1)
  return true
end
OperationOpenWingUI.Commit()
return OperationOpenWingUI
