local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
local OperationMatrial = Lplus.Extend(OperationBase, "OperationMatrial")
local def = OperationMatrial.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.MADE_MATERIAL then
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
  local ItemModule = require("Main.Item.ItemModule")
  local EquipModule = require("Main.Equip.EquipModule")
  local canShow = EquipModule.IsEquipDlgShow()
  if canShow == false then
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local materialInfo = require("Main.Equip.EquipUtils").GetEquipMakeMaterialInfo(item.id)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local materialLevel = materialInfo.materialLevel
  local maxUpLevel = EquipUtils.GetEquipMakeDelta()
  if maxUpLevel < materialLevel - heroLevel then
    Toast(textRes.Equip[109])
    return true
  end
  local EquipMakeData = require("Main.Equip.EquipMakeData")
  local limitLv = EquipMakeData.Instance():GetMakeEquipMaxLevel()
  if materialLevel >= limitLv then
    Toast(string.format(textRes.Equip[218], materialLevel))
    return true
  end
  local EquipPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipPanel.Instance():SetEquipMakeInfo(materialInfo.materialWearPos, materialInfo.materialLevel)
  EquipPanel.ShowSocialPanel(EquipPanel.StateConst.EquipMake)
  return true
end
OperationMatrial.Commit()
return OperationMatrial
