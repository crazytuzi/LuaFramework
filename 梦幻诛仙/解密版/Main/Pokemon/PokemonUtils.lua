local Lplus = require("Lplus")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local NPCInterface = require("Main.npc.NPCInterface")
local PokemonUtils = Lplus.Class("PokemonUtils")
local def = PokemonUtils.define
def.static("number", "=>", "number").GetPokemonNPCId = function(pokemonId)
  local result = 0
  local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonId)
  if pokemonCfg then
    result = pokemonCfg.npcCfgid
  else
    warn("[ERROR][PokemonUtils:GetPokemonNPCId] pokemonCfg nil for pokemonId:", pokemonId)
  end
  return result
end
def.static("number", "=>", "number").GetPokemonStar = function(pokemonId)
  local result = 0
  local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonId)
  if pokemonCfg then
    result = pokemonCfg.starType
  else
    warn("[ERROR][PokemonUtils:GetPokemonStar] pokemonCfg nil for pokemonId:", pokemonId)
  end
  return result
end
def.static("number", "=>", "number").GetPokemonHeadId = function(pokemonId)
  local result = 0
  local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonId)
  if pokemonCfg then
    local npcCfg = NPCInterface.GetNPCCfg(pokemonCfg.npcCfgid)
    if npcCfg then
      local modelId = npcCfg.monsterModelTableId
      local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
      if modelRecord then
        result = modelRecord:GetIntValue("headerIconId")
      else
        warn("[ERROR][PokemonUtils:GetPokemonHeadId] modelRecord nil for npcCfg.monsterModelTableId:", npcCfg.monsterModelTableId)
      end
    else
      warn("[ERROR][PokemonUtils:GetPokemonHeadId] npcCfg nil for pokemonCfg.npcCfgid:", pokemonCfg.npcCfgid)
    end
  else
    warn("[ERROR][PokemonUtils:GetPokemonHeadId] pokemonCfg nil for pokemonId:", pokemonId)
  end
  return result
end
def.static("number", "=>", "number").GetEggHeadId = function(eggId)
  local result = 0
  local eggCfg = PokemonData.Instance():GetEggCfg(eggId)
  if eggCfg then
    local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, eggCfg.modelId)
    if modelRecord then
      result = modelRecord:GetIntValue("headerIconId")
    else
      warn("[ERROR][PokemonUtils:GetEggHeadId] modelRecord nil for eggCfg.modelId:", eggCfg.modelId)
    end
  else
    warn("[ERROR][PokemonUtils:GetEggHeadId] eggCfg nil for eggId:", eggId)
  end
  return result
end
def.static("number", "=>", "number").GetEggModelId = function(eggId)
  local result = 0
  local eggCfg = PokemonData.Instance():GetEggCfg(eggId)
  if eggCfg then
    result = eggCfg.modelCfgid
  else
    warn("[ERROR][PokemonUtils:GetEggModelId] eggCfg nil for eggId:", eggId)
  end
  return result
end
def.static("number", "=>", "number").GetPokemonMateCD = function(pokemonId)
  local result = 0
  local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonId)
  if pokemonCfg and pokemonCfg.mateCd then
    result = pokemonCfg.mateCd * 60
  else
    warn("[ERROR][PokemonUtils:GetPokemonMateCD] pokemonCfg or pokemonCfg.mateCd nil for pokemonId:", pokemonId)
  end
  return result
end
def.static("userdata", "=>", "number").GetPokemonHeadByInst = function(instanceId)
  local result = 0
  local pokemonInfo = PokemonData.Instance():GetPokemonInfo(instanceId)
  if pokemonInfo then
    result = PokemonUtils.GetPokemonHeadId(pokemonInfo.adultCfgId)
  else
    warn("[ERROR][PokemonUtils:GetPokemonHeadByInst] pokemonInfo nil for instanceId:", tostring(instanceId))
  end
  return result
end
def.static("userdata", "=>", "string").GetPokemonNameByInst = function(instanceId)
  local result = ""
  local pokemonInfo = PokemonData.Instance():GetPokemonInfo(instanceId)
  if pokemonInfo then
    result = pokemonInfo.name
  else
    warn("[ERROR][PokemonUtils:GetPokemonNameByInst] pokemonInfo nil for instanceId:", tostring(instanceId))
  end
  return result
end
def.static("userdata", "=>", "number").GetPokemonStarByInst = function(instanceId)
  local result = 0
  local pokemonCfg = PokemonData.Instance():GetPokemonCfgByInst(instanceId)
  if pokemonCfg then
    result = pokemonCfg.starType
  else
    warn("[ERROR][PokemonUtils:GetPokemonStarByInst] pokemonCfg nil for instanceId:", tostring(instanceId))
  end
  return result
end
def.static("number", "=>", "number").GetEggMaxFondleCount = function(eggId)
  local result = 0
  local eggCfg = PokemonData.Instance():GetEggCfg(eggId)
  if eggCfg and eggCfg.days then
    result = eggCfg.days
  else
    warn("[ERROR][PokemonUtils:GetEggMaxFondleCount] eggCfg or eggCfg.days nil for eggId:", eggId)
  end
  return result
end
def.static("number", "=>", "string").GetEggName = function(eggId)
  local result = ""
  local eggCfg = PokemonData.Instance():GetEggCfg(eggId)
  if eggCfg then
    result = eggCfg.name
  else
    warn("[ERROR][PokemonUtils:GetEggName] eggCfg nil for eggId:", eggId)
  end
  return result
end
def.static("number", "=>", "number").GetYardMaxPokemonCount = function(curBeauty)
  local result = 0
  local beautyCfgs = PokemonData.Instance():GetBeautyCfgs()
  if beautyCfgs then
    for _, cfg in ipairs(beautyCfgs) do
      if curBeauty >= cfg.beautyValue then
        result = cfg.pokemonNum
      else
        break
      end
    end
  else
    warn("[ERROR][PokemonUtils:GetYardMaxPokemonCount] beautyCfgs nil!")
  end
  return result
end
def.static("=>", "boolean").IsHomePokemonFull = function()
  return false
end
def.static("number", "=>", "boolean").IsPastDay = function(fondleTime)
  if fondleTime > 0 then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local curTime = _G.GetServerTime()
    local fondleTimeTable = AbsoluteTimer.GetServerTimeTable(fondleTime)
    local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
    if fondleTimeTable.year == curTimeTable.year and fondleTimeTable.month == curTimeTable.month and fondleTimeTable.day == curTimeTable.day then
      return false
    else
      return true
    end
  else
    return true
  end
end
def.static("number", "=>", "string").GetTypeName = function(pokemonId)
  local result = ""
  local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonId)
  if pokemonCfg then
    local typeCfg = PokemonData.Instance():GetTypeCfg(pokemonCfg.animalType)
    if typeCfg then
      result = typeCfg.name
    else
      warn("[ERROR][PokemonUtils:GetTypeName] typeCfg nil for pokemonCfg.animalType:", pokemonCfg.animalType)
    end
  else
    warn("[ERROR][PokemonUtils:GetTypeName] pokemonCfg nil for pokemonId:", pokemonId)
  end
  return result
end
def.static("number", "number", "=>", "string").GetLifeTimeString = function(totalLifeTime, currentLiveTime)
  local result = ""
  if totalLifeTime > 0 then
    local lifeTime = totalLifeTime - currentLiveTime
    result = PokemonUtils.GetDurationString(lifeTime, true)
  else
    result = textRes.Pokemon.POKEMON_DETAIL_LIFE_TIME_FOREVER
  end
  return result
end
def.static("number", "boolean", "=>", "string").GetDurationString = function(timeDuration, bShowDay)
  local day = 0
  local hour = 0
  local min = 0
  local sec = 0
  local result = ""
  if timeDuration > 0 then
    if bShowDay then
      day = math.floor(timeDuration / 86400)
      hour = math.floor((timeDuration - day * 86400) / 3600)
      min = math.floor((timeDuration - day * 86400 - hour * 3600) / 60)
      min = math.max(1, min)
    else
      hour = math.floor(timeDuration / 3600)
      min = math.floor((timeDuration - hour * 3600) / 60)
      sec = timeDuration - hour * 3600 - min * 60
    end
  end
  if bShowDay then
    return string.format(textRes.Pokemon.POKEMON_TIME_DURATION_1, day, hour, min)
  else
    return string.format(textRes.Pokemon.POKEMON_TIME_DURATION_2, hour, min, sec)
  end
end
def.static("number", "=>", "string").GetRestTimeString = function(restTime)
  return PokemonUtils.GetDurationString(restTime, false)
end
PokemonUtils.Commit()
return PokemonUtils
