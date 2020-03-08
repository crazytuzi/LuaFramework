local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationFuhun = Lplus.Extend(OperationBase, "OperationFuhun")
local def = OperationFuhun.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.EQUIP_TRAN_HUN and false == PlayerIsInFight() then
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
  EquipPanel.ShowSocialPanel(EquipPanel.StateConst.EquipTrans)
  return true
end
OperationFuhun.Commit()
return OperationFuhun
