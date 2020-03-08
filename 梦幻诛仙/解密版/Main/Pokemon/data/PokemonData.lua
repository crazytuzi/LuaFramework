local Lplus = require("Lplus")
local Octets = require("netio.Octets")
local PokemonData = Lplus.Class("PokemonData")
local def = PokemonData.define
local _instance
def.static("=>", PokemonData).Instance = function()
  if _instance == nil then
    _instance = PokemonData()
  end
  return _instance
end
def.const("number").UPDATE_INTERVAL = 3
def.field("table")._mapPokemonCfg = nil
def.field("table")._mapEggCfg = nil
def.field("table")._mapItemCfg = nil
def.field("table")._pokemonInfoMap = nil
def.field("table")._beautyCfgs = nil
def.field("table")._mateMap = nil
def.field("table")._fondleMap = nil
def.field("table")._typeCfgs = nil
def.field("number")._timerID = 0
def.field("table")._newEggMap = nil
def.method().Init = function(self)
  self:_Reset()
  self._timerID = GameUtil.AddGlobalTimer(PokemonData.UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.method()._Reset = function(self)
  self._mapPokemonCfg = nil
  self._mapEggCfg = nil
  self._mapItemCfg = nil
  self._pokemonInfoMap = nil
  self._beautyCfgs = nil
  self._mateMap = nil
  self._fondleMap = nil
  self._typeCfgs = nil
  self._newEggMap = nil
end
def.method()._Update = function(self)
  self:_UpdateMate()
  self:_UpdateFondle()
end
def.method()._UpdateMate = function(self)
  if nil == self._mateMap then
    self._mateMap = {}
  end
  local bChange = false
  if self._pokemonInfoMap and next(self._pokemonInfoMap) then
    for key, uuid in pairs(self._mateMap) do
      if self._pokemonInfoMap[key] == nil then
        self._mateMap[key] = nil
        bChange = true
      end
    end
    for key, info in pairs(self._pokemonInfoMap) do
      if self:CanMate(info.uuid) then
        if nil == self._mateMap[key] then
          warn("[PokemonData:_UpdateMate] add to self._mateMap:", key)
          self._mateMap[key] = info.uuid
          bChange = true
        end
      elseif nil ~= self._mateMap[key] then
        warn("[PokemonData:_UpdateMate] remove from self._mateMap:", key)
        self._mateMap[key] = nil
        bChange = true
      end
    end
  elseif next(self._mateMap) then
    bChange = true
    self._mateMap = {}
  end
  if bChange then
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE, nil)
  end
end
def.method()._UpdateFondle = function(self)
  if nil == self._fondleMap then
    self._fondleMap = {}
  end
  local bChange = false
  if self._pokemonInfoMap and next(self._pokemonInfoMap) then
    for key, uuid in pairs(self._fondleMap) do
      if self._pokemonInfoMap[key] == nil then
        self._fondleMap[key] = nil
        bChange = true
      end
    end
    for key, info in pairs(self._pokemonInfoMap) do
      if self:CanFondle(info.uuid) then
        if nil == self._fondleMap[key] then
          warn("[PokemonData:_UpdateFondle] add to self._fondleMap:", key)
          self._fondleMap[key] = info.uuid
          bChange = true
        end
      elseif nil ~= self._fondleMap[key] then
        warn("[PokemonData:_UpdateFondle] remove from self._fondleMap:", key)
        self._fondleMap[key] = nil
        bChange = true
      end
    end
  elseif next(self._fondleMap) then
    bChange = true
    self._fondleMap = {}
  end
  if bChange then
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_FONDLE_INFO_CHANGE, nil)
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method()._LoadPokemonCfg = function(self)
  warn("[PokemonData:_LoadPokemonCfg] start Load PokemonCfg!")
  self._mapPokemonCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POKEMON_CAnimalCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local pokemonCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    pokemonCfg.id = DynamicRecord.GetIntValue(entry, "id")
    pokemonCfg.name = DynamicRecord.GetStringValue(entry, "name")
    pokemonCfg.starType = DynamicRecord.GetIntValue(entry, "starType")
    pokemonCfg.animalType = DynamicRecord.GetIntValue(entry, "animalType")
    pokemonCfg.npcCfgid = DynamicRecord.GetIntValue(entry, "npcCfgid")
    pokemonCfg.awardCfgid = DynamicRecord.GetIntValue(entry, "awardCfgid")
    pokemonCfg.mateCd = DynamicRecord.GetIntValue(entry, "mateCd")
    pokemonCfg.lifeTime = DynamicRecord.GetIntValue(entry, "life")
    self._mapPokemonCfg[pokemonCfg.id] = pokemonCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetPokemonCfgs = function(self)
  if nil == self._mapPokemonCfg then
    self:_LoadPokemonCfg()
  end
  return self._mapPokemonCfg
end
def.method("number", "=>", "table").GetPokemonCfg = function(self, pokemonId)
  return self:_GetPokemonCfgs()[pokemonId]
end
def.method("userdata", "=>", "table").GetPokemonCfgByInst = function(self, pokemonInst)
  local pokemonInfo = self:GetPokemonInfo(pokemonInst)
  if pokemonInfo then
    if pokemonInfo.stage == 1 then
      return self:GetPokemonCfg(pokemonInfo.adultCfgId)
    else
      warn("[PokemonData:GetPokemonCfgByInst] return nil! pokemonInfo.stage~=1.")
      return nil
    end
  else
    warn("[ERROR][PokemonData:GetPokemonCfgByInst] pokemonInfo nil for instanceid:", tostring(pokemonInst))
    return nil
  end
end
def.method()._LoadEggCfg = function(self)
  warn("[PokemonData:_LoadEggCfg] start Load eggCfg!")
  self._mapEggCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POKEMON_CEmbryoCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local eggCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    eggCfg.id = DynamicRecord.GetIntValue(entry, "id")
    eggCfg.name = DynamicRecord.GetStringValue(entry, "name")
    eggCfg.modelId = DynamicRecord.GetIntValue(entry, "modelCfgid")
    eggCfg.days = DynamicRecord.GetIntValue(entry, "days")
    self._mapEggCfg[eggCfg.id] = eggCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetEggCfgs = function(self)
  if nil == self._mapEggCfg then
    self:_LoadEggCfg()
  end
  return self._mapEggCfg
end
def.method("number", "=>", "table").GetEggCfg = function(self, eggId)
  return self:_GetEggCfgs()[eggId]
end
def.method()._LoadItemCfg = function(self)
  warn("[PokemonData:_LoadItemCfg] start Load eggItemCfg!")
  self._mapItemCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POKEMON_CEmbryoItemCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local itemCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    itemCfg.id = DynamicRecord.GetIntValue(entry, "id")
    itemCfg.embryoCfgid = DynamicRecord.GetIntValue(entry, "embryoCfgid")
    self._mapItemCfg[itemCfg.id] = itemCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetItemMap = function(self)
  if nil == self._LoadItemCfg then
    self:_LoadOracleItemCfg()
  end
  return self._mapItemCfg
end
def.method("number", "=>", "table").GetItemCfg = function(self, itemId)
  return self:_GetItemMap()[itemId]
end
def.method()._LoadBeautyCfg = function(self)
  warn("[PokemonData:_LoadBeautyCfg] start Load BeautyCfg!")
  self._beautyCfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POKEMON_CCourtYardBeautifulCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local beautyCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    beautyCfg.beautyValue = DynamicRecord.GetIntValue(entry, "min_beautiful_value")
    beautyCfg.pokemonNum = DynamicRecord.GetIntValue(entry, "every_people_feed_small_animals")
    table.insert(self._beautyCfgs, beautyCfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table").GetBeautyCfgs = function(self)
  if nil == self._beautyCfgs then
    self:_LoadBeautyCfg()
  end
  return self._beautyCfgs
end
def.method()._LoadTypeCfg = function(self)
  warn("[PokemonData:_LoadTypeCfg] start Load typeCfgs!")
  self._typeCfgs = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_POKEMON_CAnimalTypeCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local typeCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    typeCfg.id = DynamicRecord.GetIntValue(entry, "id")
    typeCfg.name = DynamicRecord.GetStringValue(entry, "name")
    self._typeCfgs[typeCfg.id] = typeCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetTypeCfgs = function(self)
  if nil == self._typeCfgs then
    self:_LoadTypeCfg()
  end
  return self._typeCfgs
end
def.method("number", "=>", "table").GetTypeCfg = function(self, type)
  return self:_GetTypeCfgs()[type]
end
def.method("table").SyncInfo = function(self, pokemonInfoMap)
  self._pokemonInfoMap = {}
  for _, info in pairs(pokemonInfoMap) do
    self:_SetPokemonInfo(info)
  end
end
def.method("table", "=>", "table")._SetPokemonInfo = function(self, info)
  if self._pokemonInfoMap == nil then
    self._pokemonInfoMap = {}
  end
  local pokemonInfo
  if info then
    pokemonInfo = self:UnmarshalPokemonInfo(info)
    self:_DoSetPokemonInfo(pokemonInfo.uuid, pokemonInfo)
  else
  end
  return pokemonInfo
end
def.method("userdata", "table")._DoSetPokemonInfo = function(self, uuid, pokemonInfo)
  if uuid then
    if self._pokemonInfoMap == nil then
      self._pokemonInfoMap = {}
    end
    local key = tostring(uuid)
    if key then
      warn("[PokemonData:_DoSetPokemonInfo] uuid, pokemonInfo:", key, pokemonInfo)
      self._pokemonInfoMap[key] = pokemonInfo
    end
  end
end
def.method("table", "=>", "table").UnmarshalPokemonInfo = function(self, info)
  local pokemonInfo = {}
  pokemonInfo.uuid = info.animalid
  pokemonInfo.stage = info.stage
  pokemonInfo.name = _G.GetStringFromOcts(info.name)
  if pokemonInfo.stage == 0 then
    local extraInfo = self:UnmarshalEggInfo(info.stage_info)
    pokemonInfo.eggCfgId = extraInfo.embryo_cfgid
    pokemonInfo.lastFondleTime = extraInfo.last_time
    pokemonInfo.fondleCount = extraInfo.hatch_days
  else
    local extraInfo = self:UnmarshalAdultInfo(info.stage_info)
    pokemonInfo.adultCfgId = extraInfo.animal_cfgid
    pokemonInfo.lastMateTime = extraInfo.last_mate_time
    pokemonInfo.awardId = extraInfo.award_cfgid
    pokemonInfo.birthTime = extraInfo.birth_time
  end
  return pokemonInfo
end
def.method("userdata", "=>", "table").UnmarshalEggInfo = function(self, octets)
  if octets == nil then
    return nil
  end
  local EmbryoStageInfo = require("netio.protocol.mzm.gsp.zoo.EmbryoStageInfo")
  local eggInfo = EmbryoStageInfo.new()
  Octets.unmarshalBean(octets, eggInfo)
  return eggInfo
end
def.method("userdata", "=>", "table").UnmarshalAdultInfo = function(self, octets)
  if octets == nil then
    return nil
  end
  local AdultStageInfo = require("netio.protocol.mzm.gsp.zoo.AdultStageInfo")
  local adultInfo = AdultStageInfo.new()
  Octets.unmarshalBean(octets, adultInfo)
  return adultInfo
end
def.method("userdata", "=>", "table").GetPokemonInfo = function(self, uuid)
  local key = tostring(uuid)
  if key then
    return self._pokemonInfoMap and self._pokemonInfoMap[key] or nil
  else
    return nil
  end
end
def.method("=>", "table").GetPokemonList = function(self)
  local pokemonList = {}
  if self._pokemonInfoMap then
    for _, info in pairs(self._pokemonInfoMap) do
      table.insert(pokemonList, info)
    end
  end
  return pokemonList
end
def.method("=>", "table").GetMateList = function(self)
  local mateList = {}
  if self._pokemonInfoMap then
    for _, info in pairs(self._pokemonInfoMap) do
      if self:CanMate(info.uuid) then
        table.insert(mateList, info)
      end
    end
  end
  return mateList
end
def.method("userdata", "=>", "boolean").CanFondle = function(self, uuid)
  local result = false
  local pokemonInfo = self:GetPokemonInfo(uuid)
  if pokemonInfo and pokemonInfo.stage == 0 then
    local eggCfg = self:GetEggCfg(pokemonInfo.eggCfgId)
    local maxFondleCount = eggCfg and eggCfg.days or 0
    local curFondleCount = pokemonInfo.fondleCount
    if maxFondleCount > curFondleCount then
      local PokemonUtils = require("Main.Pokemon.PokemonUtils")
      result = PokemonUtils.IsPastDay(pokemonInfo.lastFondleTime)
    else
      result = false
    end
  else
    if nil == pokemonInfo then
    else
    end
  end
  return result
end
def.method("userdata", "=>", "boolean").CanMate = function(self, uuid)
  local result = false
  local pokemonInfo = self:GetPokemonInfo(uuid)
  if pokemonInfo and pokemonInfo.stage == 1 and (nil == pokemonInfo.awardId or pokemonInfo.awardId <= 0) then
    local pokemonCfg = self:GetPokemonCfg(pokemonInfo.adultCfgId)
    result = _G.GetServerTime() - pokemonInfo.lastMateTime > pokemonCfg.mateCd * 60
  else
  end
  return result
end
def.method("=>", "number").GetPokemonCount = function(self)
  local result = 0
  if self._pokemonInfoMap then
    for _, info in pairs(self._pokemonInfoMap) do
      result = result + 1
    end
  end
  return result
end
def.method("=>", "boolean").CanAnyMate = function(self)
  local result = false
  if self._pokemonInfoMap then
    for _, info in pairs(self._pokemonInfoMap) do
      if self:CanMate(info.uuid) then
        result = true
        break
      end
    end
  end
  return result
end
def.method("=>", "boolean").CanAnyFondle = function(self)
  local result = false
  if self._pokemonInfoMap then
    for _, info in pairs(self._pokemonInfoMap) do
      if self:CanFondle(info.uuid) then
        result = true
        break
      end
    end
  end
  return result
end
def.method("=>", "boolean").HaveAnyAward = function(self)
  local result = false
  if self._pokemonInfoMap then
    for _, info in pairs(self._pokemonInfoMap) do
      if info.awardId and info.awardId > 0 then
        result = true
        break
      end
    end
  end
  return result
end
def.method("userdata").AddNewEgg = function(self, uuid)
  if uuid == nil then
    warn("[ERROR][PokemonData:AddNewEgg] uuid nil, add fail!")
    return
  end
  if nil == self._newEggMap then
    self._newEggMap = {}
  end
  local key = tostring(uuid)
  if key and not self._newEggMap[key] then
    warn("[PokemonData:AddNewEgg] add to self._newEggMap:", key)
    self._newEggMap[key] = uuid
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_NEW_EGG_CHANGE, {uuid})
  end
end
def.method().ClearNewEggs = function(self, value)
  warn("[PokemonData:ClearNewEggs] Clear self._newEggMap!")
  if self:HaveNewEgg() then
    self._newEggMap = nil
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_NEW_EGG_CHANGE, nil)
  end
end
def.method("userdata", "=>", "boolean").IsNewEgg = function(self, uuid)
  return nil ~= self._newEggMap and nil ~= self._newEggMap[tostring(uuid)]
end
def.method("=>", "boolean").HaveNewEgg = function(self)
  return nil ~= self._newEggMap and nil ~= next(self._newEggMap)
end
def.method("table", "table").OnEnterWorld = function(self, params, context)
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table", "table").OnHeroLevelUp = function(self, p1, p2)
end
def.method("userdata", "number").OnSFondleSuccess = function(self, uuid, fondleTime)
  local pokemonInfo = self:GetPokemonInfo(uuid)
  if pokemonInfo and pokemonInfo.stage == 0 then
    pokemonInfo.lastFondleTime = fondleTime
  end
end
def.method("table").OnSHatchSuccess = function(self, info)
  self:_SetPokemonInfo(info)
end
def.method("userdata", "number", "number").OnMateSuccess = function(self, uuid, mateTime, awardId)
  local pokemonInfo = self:GetPokemonInfo(uuid)
  if pokemonInfo and pokemonInfo.stage == 1 then
    pokemonInfo.lastMateTime = mateTime
    pokemonInfo.awardId = awardId
  end
end
def.method("userdata").OnSGetAwardSuccess = function(self, uuid)
  local pokemonInfo = self:GetPokemonInfo(uuid)
  if pokemonInfo then
    pokemonInfo.awardId = 0
  end
end
def.method("userdata", "userdata").OnSAnimalRenameSuccess = function(self, uuid, name)
  local pokemonInfo = self:GetPokemonInfo(uuid)
  if pokemonInfo then
    pokemonInfo.name = _G.GetStringFromOcts(name)
  end
end
def.method("userdata").OnSAnimalFreeSuccess = function(self, uuid)
  self:_DoSetPokemonInfo(uuid, nil)
end
def.method("table").OnSUseItemSuccess = function(self, info)
  local pokemonInfo = self:_SetPokemonInfo(info)
  if pokemonInfo then
    self:AddNewEgg(pokemonInfo.uuid)
  end
end
def.method("userdata").OnSyncRemoveAnimal = function(self, uuid)
  self:_DoSetPokemonInfo(uuid, nil)
end
PokemonData.Commit()
return PokemonData
