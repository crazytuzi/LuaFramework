local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleGivePresent = Lplus.Extend(PubroleOperationBase, "PubroleGivePresent")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleGivePresent.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[38]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnPresent, {1, roleInfo})
  return true
end
PubroleGivePresent.Commit()
return PubroleGivePresent
