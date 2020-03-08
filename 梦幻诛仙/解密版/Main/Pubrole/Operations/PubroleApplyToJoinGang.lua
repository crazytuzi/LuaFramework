local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleApplyToJoinGang = Lplus.Extend(PubroleOperationBase, "PubroleApplyToJoinGang")
local GangUtility = require("Main.Gang.GangUtility")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleApplyToJoinGang.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local selfHasNotGang = not require("Main.Gang.GangModule").Instance():HasGang()
  local targetHasGang = not Int64.eq(-1, roleInfo.gangId)
  local minLevel = GangUtility.GetGangConsts("JOIN_MIN_LEVEL")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local selfLevelSatisfied = minLevel <= heroProp.level
  if selfHasNotGang and targetHasGang and selfLevelSatisfied and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[36]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.moduleMgr:GetModule(ModuleId.GANG):ApplyGang(roleInfo.gangId)
  return true
end
PubroleApplyToJoinGang.Commit()
return PubroleApplyToJoinGang
