local Lplus = require("Lplus")
local TeamRoleOperateBase = require("Main.Gang.GangTeam.operations.TeamRoleOperateBase")
local TeamRoleInvite = Lplus.Extend(TeamRoleOperateBase, "TeamRoleInvite")
local def = TeamRoleInvite.define
def.override("table", "table", "=>", "boolean").CanDisplay = function(self, roleInfo, teamInfo)
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Gang.GangTeam[12]
end
def.override("table", "table", "=>", "boolean").Operate = function(self, roleInfo, teamInfo)
  gmodule.moduleMgr:GetModule(ModuleId.TEAM):TeamInvite(roleInfo.roleId)
  return true
end
return TeamRoleInvite.Commit()
