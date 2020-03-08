local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleRemoveFriend = Lplus.Extend(PubroleOperationBase, "PubroleRemoveFriend")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleRemoveFriend.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if nil ~= FriendModule.Instance():GetFriendInfo(roleInfo.roleId) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[2]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  FriendModule.AddFriendOrDeleteFriend(roleInfo.roleId, roleInfo.name)
  return true
end
PubroleRemoveFriend.Commit()
return PubroleRemoveFriend
