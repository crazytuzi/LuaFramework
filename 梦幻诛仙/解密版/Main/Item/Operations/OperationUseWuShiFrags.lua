local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationUseWuShiFrags = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationUseWuShiFrags.define
local ItemModule = require("Main.Item.ItemModule")
local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
local DecorationProtocols = require("Main.GodWeapon.Decoration.DecorationProtocols")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = DecorationMgr.IsFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.WU_SHI_FRAGMENT_ITEM and bFeatureOpen then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if not DecorationMgr.IsOwndGodWeapon() then
    Toast(textRes.GodWeapon.Decoration[20])
    return true
  end
  if not DecorationMgr.IsEquipGodWeapon() then
    Toast(textRes.GodWeapon.Decoration[19])
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local UIGodWeaponBasic = require("Main.GodWeapon.ui.UIGodWeaponBasic")
  UIGodWeaponBasic.Instance():ShowWithParams(UIGodWeaponBasic.NodeId.Decoration, {cfgId = 0})
  return true
end
return OperationUseWuShiFrags.Commit()
