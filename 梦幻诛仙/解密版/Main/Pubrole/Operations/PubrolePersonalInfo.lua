local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubrolePersonalInfo = Lplus.Extend(PubroleOperationBase, "PubrolePersonalInfo")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubrolePersonalInfo.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PubRole[1005]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local roleId = roleInfo.roleId
  local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
  PersonalInfoInterface.Instance():CheckPersonalInfo(roleId, "")
  return true
end
PubrolePersonalInfo.Commit()
return PubrolePersonalInfo
