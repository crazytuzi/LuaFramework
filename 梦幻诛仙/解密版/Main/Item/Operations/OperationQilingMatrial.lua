local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
local OperationQilingMatrial = Lplus.Extend(OperationBase, "OperationQilingMatrial")
local def = OperationQilingMatrial.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
  local b1 = source == ItemTipsMgr.Source.Bag
  local b2 = itemBase.itemType == ItemType.EQUIP_QILIN or itemBase.itemType == ItemType.EQUIP_QILIN_SUC or itemBase.itemType == ItemType.EQUIP_QILIN_LUCKY
  local b = b1 and b2
  return b
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local EquipUtils = require("Main.Equip.EquipUtils")
  if require("Main.Guide.GuideModule").Instance():CheckFunction(FunType.EQUIP) == false then
    Toast(string.format(textRes.Equip[62], EquipUtils.GetEquipOpenMinLevel()))
    return false
  end
  local EquipModule = require("Main.Equip.EquipModule")
  local canShow = EquipModule.IsEquipDlgShow()
  if canShow == false then
    return true
  end
  local EquipPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipPanel.ShowSocialPanel(EquipPanel.StateConst.EquipStren)
  return true
end
OperationQilingMatrial.Commit()
return OperationQilingMatrial
