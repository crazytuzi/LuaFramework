local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleVisitHomeland = Lplus.Extend(PubroleOperationBase, "PubroleVisitHomeland")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleVisitHomeland.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if roleInfo.holdBanquest == 1 then
    return false
  end
  local hasHomeland = roleInfo.hasHomeland == 1
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return hasHomeland
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PubRole[1006]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):VisitHome(roleInfo.roleId)
  return true
end
PubroleVisitHomeland.Commit()
return PubroleVisitHomeland
