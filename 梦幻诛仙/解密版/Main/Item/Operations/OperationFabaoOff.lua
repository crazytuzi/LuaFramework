local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationFabaoOff = Lplus.Extend(OperationBase, "OperationFabaoOff")
local def = OperationFabaoOff.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Equip and itemBase.itemType == ItemType.FABAO_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8104]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self:CannotUseInFight() then
    return false
  end
  local pUnEquip = require("netio.protocol.mzm.gsp.item.CUnEquip").new(itemKey)
  gmodule.network.sendProtocol(pUnEquip)
  return true
end
OperationFabaoOff.Commit()
return OperationFabaoOff
