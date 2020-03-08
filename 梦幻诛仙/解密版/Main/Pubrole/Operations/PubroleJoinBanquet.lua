local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleJoinBanquet = Lplus.Extend(PubroleOperationBase, "PubroleJoinBanquet")
local def = PubroleJoinBanquet.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  return roleInfo.holdBanquest == 1
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PubRole[1007]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.moduleMgr:GetModule(ModuleId.BANQUET):JoinBanquet(roleInfo.roleId)
  return true
end
PubroleJoinBanquet.Commit()
return PubroleJoinBanquet
