local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleAddFriend = Lplus.Extend(PubroleOperationBase, "PubroleAddFriend")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleAddFriend.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if nil == FriendModule.Instance():GetFriendInfo(roleInfo.roleId) and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[1]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  FriendModule.AddFriendOrDeleteFriend(roleInfo.roleId, roleInfo.name)
  return true
end
PubroleAddFriend.Commit()
return PubroleAddFriend
