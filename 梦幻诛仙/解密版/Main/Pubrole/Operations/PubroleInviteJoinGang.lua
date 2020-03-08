local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleInviteJoinGang = Lplus.Extend(PubroleOperationBase, "PubroleInviteJoinGang")
local GangUtility = require("Main.Gang.GangUtility")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleInviteJoinGang.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local selfHasGang = require("Main.Gang.GangModule").Instance():HasGang()
  local targetNotHasGang = Int64.eq(-1, roleInfo.gangId)
  local minLevel = GangUtility.GetGangConsts("JOIN_MIN_LEVEL")
  local targetLevelSatisfied = minLevel <= roleInfo.level
  if selfHasGang and targetNotHasGang and targetLevelSatisfied and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Friend[35]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  gmodule.moduleMgr:GetModule(ModuleId.GANG):GangInvite(roleInfo.roleId)
  return true
end
PubroleInviteJoinGang.Commit()
return PubroleInviteJoinGang
