local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleApplyToJoinTeam = Lplus.Extend(PubroleOperationBase, "PubroleApplyToJoinTeam")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleApplyToJoinTeam.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local selfHasNotTeam = not require("Main.Team.TeamData").Instance():HasTeam()
  local targetHasTeam = Int64.gt(roleInfo.teamId, 0)
  if selfHasNotTeam and targetHasTeam and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[21]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.moduleMgr:GetModule(ModuleId.TEAM):ApplyTeam(roleInfo.teamId)
  return true
end
def.override("table", "=>", "boolean").ExecuteOperation = function(self, roleInfo)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not role:IsInState(RoleState.GANGCROSS_BATTLE) and _G.CheckCrossServerAndToast() then
    return true
  end
  return self:Operate(roleInfo)
end
PubroleApplyToJoinTeam.Commit()
return PubroleApplyToJoinTeam
