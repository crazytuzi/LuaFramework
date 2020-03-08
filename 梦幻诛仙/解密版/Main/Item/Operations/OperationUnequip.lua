local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationUnequip = Lplus.Extend(OperationBase, "OperationUnequip")
local def = OperationUnequip.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Equip and itemBase.itemType == ItemType.EQUIP then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8104]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local heroProp = _G.GetHeroProp()
  if heroProp == nil then
    return true
  end
  local heroOcp = heroProp.occupation
  local ocp = context and context.ocp or heroOcp
  local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
  if ocp == heroOcp then
    local pUnEquip = require("netio.protocol.mzm.gsp.item.CUnEquip").new(itemKey)
    gmodule.network.sendProtocol(pUnEquip)
    if PlayerIsInFight() then
      Toast(textRes.Item[9701])
    end
  else
    local OcpEquipmentMgr = require("Main.Equip.OcpEquipmentMgr")
    OcpEquipmentMgr.Instance():CPutOffOcpEquipReq(ocp, itemKey)
  end
  return true
end
OperationUnequip.Commit()
return OperationUnequip
