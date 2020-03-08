local Lplus = require("Lplus")
local TeamRoleOperateBase = require("Main.Gang.GangTeam.operations.TeamRoleOperateBase")
local TeamRoleMore = Lplus.Extend(TeamRoleOperateBase, "TeamRoleMore")
local def = TeamRoleMore.define
def.override("table", "table", "=>", "boolean").CanDisplay = function(self, roleInfo, teamInfo)
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Gang.GangTeam[16]
end
def.override("table", "table", "=>", "boolean").Operate = function(self, roleInfo, teamInfo)
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleInfo.roleId, function(roleinfo)
    roleinfo.gangId = Int64.new(0)
    require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTipXY(roleinfo, 154, 304, nil)
  end)
  return true
end
return TeamRoleMore.Commit()
