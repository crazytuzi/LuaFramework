local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleEnterSpace = Lplus.Extend(PubroleOperationBase, "PubroleEnterSpace")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local SocialSpaceModule = Lplus.ForwardDeclare("Main.SocialSpace.SocialSpaceModule")
local def = PubroleEnterSpace.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if not SocialSpaceModule.Instance():IsFeatureOpen() then
    return false
  end
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.SocialSpace[24]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
  SocialSpaceModule.Instance():EnterSpace(roleInfo.roleId)
  return true
end
PubroleEnterSpace.Commit()
return PubroleEnterSpace
