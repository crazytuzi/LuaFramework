local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleAddSpaceFocus = Lplus.Extend(PubroleOperationBase, "PubroleAddSpaceFocus")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local SocialSpaceModule = Lplus.ForwardDeclare("Main.SocialSpace.SocialSpaceModule")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local def = PubroleAddSpaceFocus.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if FriendModule.Instance():GetFriendInfo(roleInfo.roleId) then
    return false
  end
  if not SocialSpaceModule.Instance():IsFocusAvailable() then
    return false
  end
  if SocialSpaceModule.Instance():HasFocusOnRole(roleInfo.roleId) then
    return false
  end
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.SocialSpace[113]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
  SocialSpaceModule.Instance():ReqAddFocusOnRole(roleInfo.roleId)
  return true
end
PubroleAddSpaceFocus.Commit()
return PubroleAddSpaceFocus
