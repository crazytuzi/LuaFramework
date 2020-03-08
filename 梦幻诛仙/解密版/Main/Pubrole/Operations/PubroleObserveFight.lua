local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleObserveFight = Lplus.Extend(PubroleOperationBase, "PubroleObserveFight")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleObserveFight.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if self.tag == nil or not self.tag.inMap then
    return false
  end
  local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(roleInfo.roleId)
  if role == nil then
    return false
  end
  return role:IsInState(RoleState.BATTLE) or role:IsInState(RoleState.WATCH)
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Fight[32]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
    Toast(textRes.Hero[46])
    return false
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CObserveFightReq").new(roleInfo.roleId))
  return true
end
def.override("table", "=>", "boolean").ExecuteOperation = function(self, roleInfo)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not role:IsInState(RoleState.GANGCROSS_BATTLE) and _G.CheckCrossServerAndToast() then
    return true
  end
  return self:Operate(roleInfo)
end
PubroleObserveFight.Commit()
return PubroleObserveFight
