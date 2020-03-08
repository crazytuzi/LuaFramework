local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationUseWuShi = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationUseWuShi.define
local ItemModule = require("Main.Item.ItemModule")
local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
local DecorationProtocols = require("Main.GodWeapon.Decoration.DecorationProtocols")
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = DecorationMgr.IsFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.WU_SHI_ITEM and bFeatureOpen then
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
  local WSItemCfg = DecorationUtils.GetCfgIdByItemId(item.id)
  local WSCfgId = WSItemCfg and WSItemCfg.cfgId or 0
  local owndWSInfo = DecorationMgr.GetData():GetOwndWSInfoByCfgId(WSCfgId)
  warn("owndWSInfo", owndWSInfo)
  if DecorationMgr.GetData():GetSameTypeWSInfo(WSCfgId) ~= nil then
    local UIGodWeaponBasic = require("Main.GodWeapon.ui.UIGodWeaponBasic")
    UIGodWeaponBasic.Instance():ShowWithParams(UIGodWeaponBasic.NodeId.Decoration, {cfgId = WSCfgId})
  else
    DecorationProtocols.CSendUseWSItemReq(bagId, itemKey)
  end
  return true
end
return OperationUseWuShi.Commit()
