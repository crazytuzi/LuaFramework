local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleInviteCoupleFly = Lplus.Extend(PubroleOperationBase, "PubroleInviteCoupleFly")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local FlyModule = require("Main.Fly.FlyModule")
local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local def = PubroleInviteCoupleFly.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if GameUtil.IsEvaluation() then
    return false
  end
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Fly[5]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local mapId = require("Main.Map.MapModule").Instance():GetMapId()
  local mapCfg = require("Main.Map.Interface").GetMapCfg(mapId)
  if mapCfg then
    if not mapCfg.canFly then
      Toast(textRes.Hero[51])
      return true
    end
  else
    return true
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole == nil then
    return
  end
  local isCouplyFly = FlyModule.Instance().isInCoupleFly
  if isCouplyFly then
    Toast(textRes.Fly[6])
    return true
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasTeam() then
    Toast(textRes.Fly[7])
    return true
  end
  local basicProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if basicProp == nil then
    return true
  end
  local myLevel = basicProp.level
  if myLevel < constant.CCoupleFlyConsts.needLevel then
    Toast(string.format(textRes.Fly[8], constant.CCoupleFlyConsts.needLevel))
    return true
  end
  local hasAirCraft, canTransform = require("Main.Fly.FlyModule").Instance():HasAirCraft()
  if not hasAirCraft then
    Toast(textRes.Fly[9])
    return false
  end
  if not canTransform and (basicProp.gender ~= SGenderEnum.MALE or roleInfo.gender ~= SGenderEnum.FEMALE) then
    Toast(textRes.Fly[11])
    return true
  end
  FlyModule.Instance():InviteCoupleFly(roleInfo.roleId)
  return true
end
PubroleInviteCoupleFly.Commit()
return PubroleInviteCoupleFly
