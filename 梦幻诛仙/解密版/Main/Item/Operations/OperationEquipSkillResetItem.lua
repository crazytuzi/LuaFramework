local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local OperationEquipSkillResetItem = Lplus.Extend(OperationBase, "OperationEquipSkillResetItem")
local def = OperationEquipSkillResetItem.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.EQUIP_SKILL_REFRESH_ITEM then
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_SKILL_REFRESH) then
      return true
    end
    return false
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return false
  end
  local EquipEffectResetPanel = require("Main.Equip.ui.EquipEffectResetPanel")
  EquipEffectResetPanel.Instance():ShowPanel()
  return true
end
OperationEquipSkillResetItem.Commit()
return OperationEquipSkillResetItem
