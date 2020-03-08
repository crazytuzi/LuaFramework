local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleAddShield = Lplus.Extend(PubroleOperationBase, "PubroleAddShield")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleAddShield.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if nil == FriendModule.Instance():GetFriendInfo(roleInfo.roleId) and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL and false == FriendModule.Instance():IsInShieldList(roleInfo.roleId) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[18]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  FriendModule.AddShield(roleInfo.roleId, roleInfo.name)
  return true
end
PubroleAddShield.Commit()
return PubroleAddShield
