local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
local OperationQiling = Lplus.Extend(OperationBase, "OperationQiling")
local def = OperationQiling.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local b1 = source == ItemTipsMgr.Source.Equip or source == ItemTipsMgr.Source.Bag
  local b2 = itemBase.itemType == ItemType.EQUIP
  local b = b1 and b2
  return b
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8024]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local EquipUtils = require("Main.Equip.EquipUtils")
  if require("Main.Guide.GuideModule").Instance():CheckFunction(FunType.EQUIP) == false then
    Toast(string.format(textRes.Equip[62], EquipUtils.GetEquipOpenMinLevel()))
    return false
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local EquipUtils = require("Main.Equip.EquipUtils")
  local strenMinLv = EquipUtils.GetQiLingMinLv()
  local itemBase = ItemUtils.GetItemBase(item.id)
  if strenMinLv > itemBase.useLevel then
    Toast(string.format(textRes.Equip[61], EquipUtils.GetQiLingMinLv()))
    return true
  end
  local EquipModule = require("Main.Equip.EquipModule")
  local canShow = EquipModule.IsEquipDlgShow()
  if canShow == false then
    Toast(textRes.Item[138])
    return true
  end
  local EquipPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipPanel.Instance():SetEquipStrenKeyAndPos(itemKey, bagId)
  EquipPanel.ShowSocialPanel(EquipPanel.StateConst.EquipStren)
  return true
end
OperationQiling.Commit()
return OperationQiling
