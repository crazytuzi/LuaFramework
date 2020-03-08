local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local OperationEquipEffectReset = Lplus.Extend(OperationBase, "OperationEquipEffectReset")
local def = OperationEquipEffectReset.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.Equip) and itemBase.itemType == ItemType.EQUIP then
    if item.extraMap and IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_SKILL_REFRESH) then
      local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
      local equipSkill = item.extraMap[ItemXStoreType.EQUIP_SKILL]
      if equipSkill and equipSkill > 0 then
        return true
      end
    end
    return false
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Equip[210]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return false
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local EquipEffectResetPanel = require("Main.Equip.ui.EquipEffectResetPanel")
  EquipEffectResetPanel.Instance():ShowPanelToEquip(bagId, itemKey)
  return true
end
OperationEquipEffectReset.Commit()
return OperationEquipEffectReset
