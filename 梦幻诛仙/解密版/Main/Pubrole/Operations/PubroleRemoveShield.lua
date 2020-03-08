local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleRemoveShield = Lplus.Extend(PubroleOperationBase, "PubroleRemoveShield")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleRemoveShield.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if nil == FriendModule.Instance():GetFriendInfo(roleInfo.roleId) and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL and true == FriendModule.Instance():IsInShieldList(roleInfo.roleId) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[8]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  FriendModule.RemoveShield(roleInfo.name)
  return true
end
PubroleRemoveShield.Commit()
return PubroleRemoveShield
