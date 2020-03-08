local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleLookOverEquip = Lplus.Extend(PubroleOperationBase, "PubroleLookOverEquip")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleLookOverEquip.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PubRole[1001]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.item.CQueryRoleEquipInfoReq").new(roleInfo.roleId))
  return true
end
PubroleLookOverEquip.Commit()
return PubroleLookOverEquip
