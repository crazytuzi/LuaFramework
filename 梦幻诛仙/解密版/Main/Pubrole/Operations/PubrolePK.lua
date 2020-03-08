local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubrolePK = Lplus.Extend(PubroleOperationBase, "PubrolePK")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubrolePK.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local canPvp = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):isPvpEnable(roleInfo.roleId)
  if canPvp and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Leitai[4]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local role = pubMgr:GetRole(roleInfo.roleId)
  if role == nil then
    return false
  end
  if pubMgr:IsInFollowState(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
    Toast(textRes.Hero[46])
    return false
  end
  if not pubMgr:isPvpEnable(roleInfo.roleId) then
    Toast(textRes.Leitai[6])
    return false
  end
  if role:IsInState(RoleState.BATTLE) then
    Toast(textRes.PubRole[4])
    return false
  end
  if require("Main.Team.TeamData").Instance():IsTeamMember(roleInfo.roleId) then
    Toast(textRes.Leitai[5])
    return false
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CPVPOtherReq").new(roleInfo.roleId))
  return true
end
PubrolePK.Commit()
return PubrolePK
