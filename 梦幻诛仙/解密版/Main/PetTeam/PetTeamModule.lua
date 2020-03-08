local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetTeamModule = Lplus.Extend(ModuleBase, "PetTeamModule")
local instance
local def = PetTeamModule.define
def.static("=>", PetTeamModule).Instance = function()
  if instance == nil then
    instance = PetTeamModule()
  end
  return instance
end
def.field("boolean")._bNewOpen = false
def.field("boolean")._bFormationUpgrade = false
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.PetTeam.PetTeamProtocols").RegisterProtocols()
  require("Main.PetTeam.PetTeamMgr").Instance():Init()
  PetTeamData.Instance():Init()
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if false == self:IsFeatrueOpen(bToast) then
    result = false
  elseif false == self:ReachMinLevel(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatrueOpen = function(self, bToast)
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_PET_FIGHT)
  if false == result and bToast then
    Toast(textRes.PetTeam.FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("boolean", "=>", "boolean").ReachMinLevel = function(self, bToast)
  local result = false
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local minOpenLevel = constant.CPetFightConsts.OPEN_LEVEL
  if heroProp ~= nil then
    local rolelevel = heroProp.level
    result = minOpenLevel <= rolelevel
  end
  if bToast and false == result then
    Toast(string.format(textRes.PetTeam.NOT_OPEN_LOW_LEVEL, minOpenLevel))
  end
  return result
end
def.method("boolean", "boolean").SetNewOpen = function(self, value, bForce)
  if not bForce and self._bNewOpen == value then
    return
  end
  self._bNewOpen = value
  Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_REDDOT_CHANGE, {bRed = value})
end
def.method("=>", "boolean").GetNewOpen = function(self)
  return self._bNewOpen
end
def.method("boolean", "boolean").SetCanUpgrade = function(self, value, bForce)
  if not bForce and self._bFormationUpgrade == value then
    return
  end
  self._bFormationUpgrade = value
  Event.DispatchEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_REDDOT_CHANGE, {bRed = value})
end
def.method("=>", "boolean").GetCanUpgrade = function(self)
  return self._bFormationUpgrade
end
def.method("=>", "boolean").NeedReddot = function(self)
  return self:IsOpen(false) and self:GetNewOpen() or self:GetCanUpgrade()
end
def.method("boolean", "=>", "boolean").IsPetSkillOpen = function(self, bToast)
  local result = true
  if false == self:IsOpen(bToast) then
    result = false
  elseif false == self:IsPetSkillFeatrueOpen(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsPetSkillFeatrueOpen = function(self, bToast)
  local result = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_PET_FIGHT_SKILL)
  if false == result and bToast then
    Toast(textRes.PetTeam.SKILL_FEATRUE_IDIP_NOT_OPEN)
  end
  return result
end
def.method("=>", "boolean").NeedReddotWithFrag = function(self)
  if self:IsOpen(false) then
    if self:GetNewOpen() then
      return true
    else
      return PetTeamData.Instance():CanAnyFormationUpgrade(true)
    end
  else
    return false
  end
end
return PetTeamModule.Commit()
