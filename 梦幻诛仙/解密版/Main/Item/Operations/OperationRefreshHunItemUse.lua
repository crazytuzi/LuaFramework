local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationRefreshHunItemUse = Lplus.Extend(OperationBase, "OperationRefreshHunItemUse")
local def = OperationRefreshHunItemUse.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.REFRESH_EQUIP_HUN_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local EquipUtils = require("Main.Equip.EquipUtils")
  local EquipModule = require("Main.Equip.EquipModule")
  local canShow = EquipModule.IsEquipDlgShow()
  if canShow == false then
    return true
  end
  local EquipPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipPanel.ShowSocialPanel(EquipPanel.StateConst.EquipXihun)
  return true
end
OperationRefreshHunItemUse.Commit()
return OperationRefreshHunItemUse
