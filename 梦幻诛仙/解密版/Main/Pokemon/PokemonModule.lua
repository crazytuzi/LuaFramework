local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonMgr = require("Main.Pokemon.PokemonMgr")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local NPCInterface = require("Main.npc.NPCInterface")
local PokemonEntity = require("Main.Map.entity.PokemonEntity")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local PokemonModule = Lplus.Extend(ModuleBase, "PokemonModule")
local def = PokemonModule.define
local instance
def.static("=>", PokemonModule).Instance = function()
  if instance == nil then
    instance = PokemonModule()
    instance.m_moduleId = ModuleId.POKEMON
  end
  return instance
end
def.override().Init = function(self)
  PokemonData.Instance():Init()
  PokemonMgr.Instance():Init()
  require("Main.Pokemon.PokemonProtocols").RegisterEvents()
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CAnimalConst.CHANGE_NAME_NPC_SERVICE_CFG_ID, PokemonModule.CheckRenameServiceOpen)
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CAnimalConst.FREE_NPC_SERVICE_CFG_ID, PokemonModule.CheckFreeServiceOpen)
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CAnimalConst.GET_AWARD_NPC_SERVICE_CFG_ID, PokemonModule.CheckAwardServiceOpen)
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CAnimalConst.MATE_NPC_SERVICE_CFG_ID, PokemonModule.CheckMateServiceOpen)
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CAnimalConst.GET_MATE_INFO_SERVICE_CFG_ID, PokemonModule.CheckDetailServiceOpen)
  NPCInterface.Instance():RegisterNPCServiceCustomCondition(constant.CAnimalConst.GET_REST_NPC_SERVICE_CFG_ID, PokemonModule.CheckRestTimeServiceOpen)
  ModuleBase.Init(self)
end
def.method("boolean", "=>", "boolean").IsOpen = function(self, bToast)
  local result = true
  if not self:IsFeatureOpen(bToast) then
    result = false
  elseif not self:IsConditionSatisfied(bToast) then
    result = false
  end
  return result
end
def.method("boolean", "=>", "boolean").IsFeatureOpen = function(self, bToast)
  local open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_ZOO)
  if bToast and false == open then
    Toast(textRes.Pokemon.FEATRUE_IDIP_NOT_OPEN)
  end
  return open
end
def.method("boolean", "=>", "boolean").IsConditionSatisfied = function(self, bToast)
  local result = true
  local rolelevel = require("Main.Hero.Interface").GetHeroProp().level
  result = rolelevel >= constant.CAnimalConst.OPEN_LEVEL
  if bToast and false == result then
    Toast(string.format(textRes.Pokemon.FEATRUE_NOT_OPEN_LOW_LEVEL, constant.CAnimalConst.OPEN_LEVEL))
  end
  return result
end
def.method("=>", "boolean").NeedReddot = function(self)
  return not self:IsOpen(false) or PokemonData.Instance():CanAnyFondle() or PokemonData.Instance():HaveNewEgg() or PokemonData.Instance():CanAnyMate() or PokemonData.Instance():HaveAnyAward()
end
def.static("number", "=>", "boolean").CheckRenameServiceOpen = function(serviceId)
  local result = false
  if PokemonModule.Instance():IsOpen(false) then
    local targetPokemonEntity = PokemonModule._GetNPCDlgTargetEntity()
    if targetPokemonEntity then
      local pokemonInfo = PokemonData.Instance():GetPokemonInfo(targetPokemonEntity.instanceid)
      if pokemonInfo and pokemonInfo.stage == 1 then
        result = true
      else
        result = false
      end
    else
      result = false
    end
  end
  return result
end
def.static("number", "=>", "boolean").CheckFreeServiceOpen = function(serviceId)
  local result = false
  if PokemonModule.Instance():IsOpen(false) then
    local targetPokemonEntity = PokemonModule._GetNPCDlgTargetEntity()
    if targetPokemonEntity then
      local pokemonInfo = PokemonData.Instance():GetPokemonInfo(targetPokemonEntity.instanceid)
      if pokemonInfo and pokemonInfo.stage == 1 then
        result = true
      else
        result = false
      end
    else
      result = false
    end
  end
  return result
end
def.static("number", "=>", "boolean").CheckAwardServiceOpen = function(serviceId)
  local result = false
  if PokemonModule.Instance():IsOpen(false) then
    local targetPokemonEntity = PokemonModule._GetNPCDlgTargetEntity()
    if targetPokemonEntity then
      local pokemonInfo = PokemonData.Instance():GetPokemonInfo(targetPokemonEntity.instanceid)
      if pokemonInfo and pokemonInfo.stage == 1 and pokemonInfo.awardId and pokemonInfo.awardId > 0 then
        result = true
      else
        result = false
      end
    else
      result = false
    end
  end
  return result
end
def.static("number", "=>", "boolean").CheckMateServiceOpen = function(serviceId)
  local result = false
  if PokemonModule.Instance():IsOpen(false) then
    local targetPokemonEntity = PokemonModule._GetNPCDlgTargetEntity()
    if targetPokemonEntity and nil == PokemonData.Instance():GetPokemonInfo(targetPokemonEntity.instanceid) and targetPokemonEntity:CanMate() then
      result = true
    else
      result = false
    end
  end
  return result
end
def.static("number", "=>", "boolean").CheckDetailServiceOpen = function(serviceId)
  local result = false
  if PokemonModule.Instance():IsOpen(false) then
    local targetPokemonEntity = PokemonModule._GetNPCDlgTargetEntity()
    if targetPokemonEntity then
      local pokemonInfo = PokemonData.Instance():GetPokemonInfo(targetPokemonEntity.instanceid)
      if pokemonInfo and pokemonInfo.stage == 1 then
        result = true
      else
        result = false
      end
    else
      result = false
    end
  end
  return result
end
def.static("number", "=>", "boolean").CheckRestTimeServiceOpen = function(serviceId)
  local result = false
  if PokemonModule.Instance():IsOpen(false) then
    local targetPokemonEntity = PokemonModule._GetNPCDlgTargetEntity()
    if targetPokemonEntity then
      local pokemonInfo = PokemonData.Instance():GetPokemonInfo(targetPokemonEntity.instanceid)
      if pokemonInfo and pokemonInfo.stage == 1 then
        result = targetPokemonEntity:GetLifeStage() == PokemonEntity.LifeStageEnum.COOLDOWN
      else
        result = false
      end
    else
      result = false
    end
  end
  return result
end
def.static("=>", "table")._GetNPCDlgTargetEntity = function()
  local targetPokemonEntity
  local NPCDlg = require("Main.npc.ui.NPCDlg")
  local extraInfo = NPCDlg.Instance():GetTargetExtraInfo()
  local entityType = extraInfo and extraInfo.entityType
  if entityType and entityType == MapEntityType.MET_ANIMAL then
    local instanceId = extraInfo.instanceId
    targetPokemonEntity = instanceId and gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, instanceId)
  end
  return targetPokemonEntity
end
PokemonModule.Commit()
return PokemonModule
