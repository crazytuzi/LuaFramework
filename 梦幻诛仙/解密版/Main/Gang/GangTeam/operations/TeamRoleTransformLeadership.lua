local Lplus = require("Lplus")
local TeamRoleOperateBase = require("Main.Gang.GangTeam.operations.TeamRoleOperateBase")
local TeamRoleTransformLeadership = Lplus.Extend(TeamRoleOperateBase, "TeamRoleTransformLeadership")
local def = TeamRoleTransformLeadership.define
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.Gang.GangTeam
def.override("table", "table", "=>", "boolean").CanDisplay = function(self, roleInfo, teamInfo)
  if teamInfo.leaderid:eq(_G.GetHeroProp().id) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Gang.GangTeam[15]
end
def.override("table", "table", "=>", "boolean").Operate = function(self, roleInfo, teamInfo)
  if _G.CheckCrossServerAndToast() then
    return true
  end
  CommonConfirmDlg.ShowConfirm(txtConst[10], txtConst[41]:format(roleInfo.name), function(select)
    if select == 1 then
      GangTeamMgr.GetProtocol().sendChgTeamLeadership(roleInfo.roleId)
    end
  end, nil)
  return true
end
return TeamRoleTransformLeadership.Commit()
