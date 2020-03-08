local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleInviteJoinTeam = Lplus.Extend(PubroleOperationBase, "PubroleInviteJoinTeam")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleInviteJoinTeam.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local selfHasTeam = require("Main.Team.TeamData").Instance():HasTeam()
  local targetHasNotTeam = not Int64.gt(roleInfo.teamId, 0)
  if (selfHasTeam or targetHasNotTeam) and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[22]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.moduleMgr:GetModule(ModuleId.TEAM):TeamInvite(roleInfo.roleId)
  return true
end
def.override("table", "=>", "boolean").ExecuteOperation = function(self, roleInfo)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not role:IsInState(RoleState.GANGCROSS_BATTLE) and _G.CheckCrossServerAndToast() then
    return true
  end
  return self:Operate(roleInfo)
end
PubroleInviteJoinTeam.Commit()
return PubroleInviteJoinTeam
