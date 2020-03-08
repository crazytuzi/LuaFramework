local Lplus = require("Lplus")
local TeamUtils = Lplus.Class("TeamUtils")
local TeamData = Lplus.ForwardDeclare("TeamData")
local TeamModule = Lplus.ForwardDeclare("TeamModule")
local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
local def = TeamUtils.define
def.static("string", "=>", "number").GetTeamConsts = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.TEAM_CONSTS, key)
  if record == nil then
    warn("GetTeamConsts(" .. key .. ") return nil")
    return 0
  end
  return record:GetIntValue("value")
end
def.static().JoinTeam = function()
  local teamData = TeamData.Instance()
  if teamData:HasTeam() and not teamData:MeIsCaptain() then
    Toast(textRes.Team[61])
  elseif teamData:HasTeam() then
    TeamModule.Instance():FindMembersInActivity()
  else
    TeamModule.Instance():FindTeamInActivity()
  end
end
def.static("=>", "boolean").IsSelfRestrictedInTeam = function()
  local teamData = TeamData.Instance()
  local isNotTmpLeave = teamData:GetStatus() ~= TeamMember.ST_TMP_LEAVE
  if teamData:HasTeam() and not teamData:MeIsCaptain() and isNotTmpLeave then
    return true
  end
  return false
end
def.static("=>", "boolean").CheckIfSelfRestrictedInTeam = function()
  if TeamUtils.IsSelfRestrictedInTeam() then
    Toast(textRes.Hero[46])
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE_IN_TEAM_FOLLOW, nil)
    return true
  end
  return false
end
return TeamUtils.Commit()
