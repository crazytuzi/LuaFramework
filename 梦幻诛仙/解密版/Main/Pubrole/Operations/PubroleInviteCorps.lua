local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleInviteCorps = Lplus.Extend(PubroleOperationBase, "PubroleInviteCorps")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local def = PubroleInviteCorps.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if CorpsInterface.HasCorps() and roleInfo.level >= constant.CorpsConsts.MIN_LEVEL and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Corps[65]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  CorpsInterface.InviteToCorps(roleInfo.roleId, roleInfo.level)
  return true
end
PubroleInviteCorps.Commit()
return PubroleInviteCorps
