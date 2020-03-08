local Lplus = require("Lplus")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local PokemonProtocols = Lplus.Class("PokemonProtocols")
local def = PokemonProtocols.define
def.static().RegisterEvents = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SyncAnimalInfos", PokemonProtocols.OnSyncAnimalInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseEmbryoItemSuccess", PokemonProtocols.OnSUseEmbryoItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SCommonErrorInfo", PokemonProtocols.OnSCommonErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SEmbryoAddDaySuccess", PokemonProtocols.OnSFondleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SEmbryoAddDayFailed", PokemonProtocols.OnSFondleFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SEmbryoToAnimalSuccess", PokemonProtocols.OnSHatchSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SEmbryoToAnimalFailed", PokemonProtocols.OnSHatchFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SAnimalMateSuccess", PokemonProtocols.OnSAnimalMateSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SAnimalMateFailed", PokemonProtocols.OnSAnimalMateFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SGetAwardSuccess", PokemonProtocols.OnSGetAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SGetAwardFailed", PokemonProtocols.OnSGetAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SAnimalFreeSuccess", PokemonProtocols.OnSAnimalFreeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SAnimalFreeFailed", PokemonProtocols.OnSAnimalFreeFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SAnimalRenameSuccess", PokemonProtocols.OnSAnimalRenameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SAnimalRenameFailed", PokemonProtocols.OnSAnimalRenameFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SyncRemoveAnimal", PokemonProtocols.OnSyncRemoveAnimal)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zoo.SGetAnimalMatesSuccess", PokemonProtocols.OnSGetAnimalMatesSuccess)
end
def.static("table").OnSyncAnimalInfos = function(p)
  warn("[PokemonProtocols:OnSyncAnimalInfos] On SyncAnimalInfos.")
  PokemonData.Instance():SyncInfo(p.animals)
end
def.static("table").OnSyncRemoveAnimal = function(p)
  warn(string.format("[PokemonProtocols:OnSyncRemoveAnimal] remove pokemon [%s] at [%d].", tostring(p.animalid), _G.GetServerTime()))
  PokemonData.Instance():OnSyncRemoveAnimal(p.animalid)
  local HomelandModule = require("Main.Homeland.HomelandModule")
  if HomelandModule.Instance():IsInSelfHomeland() then
    local MyPokemonPanel = require("Main.Pokemon.ui.MyPokemonPanel")
    if MyPokemonPanel.Instance():IsShow() then
      MyPokemonPanel.Instance():OnSyncRemoveAnimal()
    end
  end
end
def.static("userdata", "=>", "boolean").SendCUseEmbryoItem = function(uuid)
  warn("[PokemonProtocols:SendCUseEmbryoItem] Send CUseEmbryoItem!")
  local p = require("netio.protocol.mzm.gsp.item.CUseEmbryoItem").new(uuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSUseEmbryoItemSuccess = function(p)
  warn("[PokemonProtocols:OnSUseEmbryoItemSuccess] On SUseEmbryoItemSuccess! p.item_cfgid:", p.item_cfgid)
  PokemonData.Instance():OnSUseItemSuccess(p.animal_info)
  Toast(textRes.Pokemon.USE_EGG_ITEM_SUCC)
end
def.static("table").OnSCommonErrorInfo = function(p)
  warn("[PokemonProtocols:OnSCommonErrorInfo] On SCommonErrorInfo! p.retcode:", p.errorCode)
  local errString
  local SCommonErrorInfo = require("netio.protocol.mzm.gsp.item.SCommonErrorInfo")
  if p.errorCode == SCommonErrorInfo.EMBRY0_ITEM_ANIMAL_MAX then
    errString = textRes.Pokemon.EMBRY0_ITEM_ANIMAL_MAX
    local myCourtyard = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetMyCourtyard()
    local curBeauty = myCourtyard and myCourtyard:GetBeauty() or 0
    local maxCount = PokemonUtils.GetYardMaxPokemonCount(curBeauty)
    errString = string.format(errString, curBeauty, maxCount)
  end
  if errString then
    warn("[PokemonProtocols:OnSCommonErrorInfo] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "=>", "boolean").SendCFondle = function(uuid)
  warn("[PokemonProtocols:SendCFondle] Send CEmbryoAddDay!")
  local p = require("netio.protocol.mzm.gsp.zoo.CEmbryoAddDay").new(uuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSFondleSuccess = function(p)
  warn("[PokemonProtocols:OnSFondleSuccess] On SEmbryoAddDaySuccess! p.animalid:", tostring(p.animalid))
  PokemonData.Instance():OnSFondleSuccess(p.animalid, p.last_time)
  Toast(textRes.Pokemon.FONDLE_EGG_SUCC)
end
def.static("table").OnSFondleFailed = function(p)
  warn("[PokemonProtocols:OnSFondleFailed] On SEmbryoAddDayFailed! p.retcode:", p.retcode)
  local SEmbryoAddDayFailed = require("netio.protocol.mzm.gsp.zoo.SEmbryoAddDayFailed")
  local errString
  if SEmbryoAddDayFailed.ERROR_ADDED == p.retcode then
    errString = textRes.Pokemon.EGG_ALREADY_HATCHED
  else
    warn("[PokemonProtocols:OnSFondleFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PokemonProtocols:OnSFondleFailed] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "=>", "boolean").SendCHatch = function(uuid)
  warn("[PokemonProtocols:SendCHatch] Send CEmbryoToAnimal!")
  local p = require("netio.protocol.mzm.gsp.zoo.CEmbryoToAnimal").new(uuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSHatchSuccess = function(p)
  warn("[PokemonProtocols:OnSHatchSuccess] On SEmbryoToAnimalSuccess! p.animal.animalid:", tostring(p.animal.animalid))
  PokemonData.Instance():OnSHatchSuccess(p.animal)
  Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE, nil)
  local pokemonCfg = PokemonData.Instance():GetPokemonCfgByInst(p.animal.animalid)
  if pokemonCfg then
    local toastStr = string.format(textRes.Pokemon.HATCH_EGG_SUCC, pokemonCfg.starType, pokemonCfg.name)
    Toast(toastStr)
  end
  local GainPokemonPanel = require("Main.Pokemon.ui.GainPokemonPanel")
  GainPokemonPanel.ShowPanel(pokemonCfg)
end
def.static("table").OnSHatchFailed = function(p)
  warn("[PokemonProtocols:OnSHatchFailed] On SEmbryoToAnimalFailed! p.retcode:", p.retcode)
  local SEmbryoToAnimalFailed = require("netio.protocol.mzm.gsp.zoo.SEmbryoToAnimalFailed")
  local errString
  if SEmbryoToAnimalFailed.ERROR_DAY_NOT_ENOUGH == p.retcode then
    errString = textRes.Pokemon.ERROR_DAY_NOT_ENOUGH
  else
    warn("[PokemonProtocols:OnSHatchFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PokemonProtocols:OnSHatchFailed] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "userdata", "=>", "boolean").SendCAnimalMate = function(ownUuid, targetUuid)
  warn("[PokemonProtocols:SendCAnimalMate] Send CAnimalMate!")
  local p = require("netio.protocol.mzm.gsp.zoo.CAnimalMate").new(ownUuid, targetUuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSAnimalMateSuccess = function(p)
  warn(string.format("[PokemonProtocols:OnSAnimalMateSuccess] On SAnimalMateSuccess! uuid=[%s], award=[%d].", tostring(p.animalid), p.award_cfgid))
  PokemonData.Instance():OnMateSuccess(p.animalid, p.last_time, p.award_cfgid)
  Toast(textRes.Pokemon.POKEMON_MATE_SUCC)
  local PokemonMgr = require("Main.Pokemon.PokemonMgr")
  PokemonMgr.Instance():PlayMateEffect()
  Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE, nil)
  Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_AWARD_INFO_CHANGE, {true})
end
def.static("table").OnSAnimalMateFailed = function(p)
  warn("[PokemonProtocols:OnSAnimalMateFailed] On SAnimalMateFailed! p.retcode:", p.retcode)
  local SAnimalMateFailed = require("netio.protocol.mzm.gsp.zoo.SAnimalMateFailed")
  local errString
  if SAnimalMateFailed.ERROR_MATE_CD == p.retcode then
    errString = textRes.Pokemon.POKEMON_MATE_FAIL_CD
  elseif SAnimalMateFailed.ERROR_ANIMAL_MYSELF == p.retcode then
    errString = textRes.Pokemon.POKEMON_MATE_FAIL_OWN
  elseif SAnimalMateFailed.ERROR_ANIMAL_MARRIAGE == p.retcode then
    errString = textRes.Pokemon.POKEMON_MATE_FAIL_SPOUSE
  else
    warn("[PokemonProtocols:OnSAnimalMateFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PokemonProtocols:OnSAnimalMateFailed] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "=>", "boolean").SendCGetAward = function(uuid)
  warn("[PokemonProtocols:SendCGetAward] Send CGetAward!")
  local p = require("netio.protocol.mzm.gsp.zoo.CGetAward").new(uuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSGetAwardSuccess = function(p)
  warn("[PokemonProtocols:OnSGetAwardSuccess] On SGetAwardSuccess! p.animalid=", tostring(p.animalid))
  PokemonData.Instance():OnSGetAwardSuccess(p.animalid)
  Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_AWARD_INFO_CHANGE, {false})
end
def.static("table").OnSGetAwardFailed = function(p)
  warn("[PokemonProtocols:OnSGetAwardFailed] On SGetAwardFailed! p.retcode:", p.retcode)
  local SGetAwardFailed = require("netio.protocol.mzm.gsp.zoo.SGetAwardFailed")
  local errString
  if SGetAwardFailed.ERROR_AWARD_NOT_EXIST == p.retcode then
    errString = textRes.Pokemon.ERROR_AWARD_NOT_EXIST
  elseif SGetAwardFailed.ERROR_BAG_FULL == p.retcode then
    errString = textRes.Pokemon.ERROR_AWARD_BAG_FULL
  else
    warn("[PokemonProtocols:OnSGetAwardFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PokemonProtocols:OnSGetAwardFailed] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "=>", "boolean").SendCAnimalFree = function(uuid)
  warn("[PokemonProtocols:SendCAnimalFree] Send CAnimalFree!")
  local p = require("netio.protocol.mzm.gsp.zoo.CAnimalFree").new(uuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSAnimalFreeSuccess = function(p)
  warn("[PokemonProtocols:OnSAnimalFreeSuccess] On SAnimalFreeSuccess! p.animalid=", tostring(p.animalid))
  PokemonData.Instance():OnSAnimalFreeSuccess(p.animalid)
  Toast(textRes.Pokemon.FREE_SUCC)
end
def.static("table").OnSAnimalFreeFailed = function(p)
  warn("[PokemonProtocols:OnSAnimalFreeFailed] On SAnimalFreeFailed! p.retcode:", p.retcode)
  local SAnimalFreeFailed = require("netio.protocol.mzm.gsp.zoo.SAnimalFreeFailed")
  local errString
  if SAnimalFreeFailed.ERROR_STAGE == p.retcode then
    errString = textRes.Pokemon.ERROR_FREE_STAGE
  else
    warn("[PokemonProtocols:OnSAnimalFreeFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PokemonProtocols:OnSAnimalFreeFailed] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "string", "=>", "boolean").SendCAnimalRename = function(uuid, newName)
  warn("[PokemonProtocols:SendCAnimalRename] Send CAnimalRename!")
  local Octets = require("netio.Octets")
  local p = require("netio.protocol.mzm.gsp.zoo.CAnimalRename").new(uuid, Octets.rawFromString(newName))
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSAnimalRenameSuccess = function(p)
  warn("[PokemonProtocols:OnSAnimalRenameSuccess] On SAnimalRenameSuccess! p.animalid=", tostring(p.animalid))
  PokemonData.Instance():OnSAnimalRenameSuccess(p.animalid, p.name)
  Toast(textRes.Pokemon.RENAME_SUCC)
end
def.static("table").OnSAnimalRenameFailed = function(p)
  warn("[PokemonProtocols:OnSAnimalRenameFailed] On SAnimalRenameFailed! p.retcode:", p.retcode)
  local SAnimalRenameFailed = require("netio.protocol.mzm.gsp.zoo.SAnimalRenameFailed")
  local errString
  if SAnimalRenameFailed.ERROR_MIN_LEN == p.retcode then
    errString = textRes.Pokemon.ERROR_RENAME_MIN_LEN
  elseif SAnimalRenameFailed.ERROR_MAX_LEN == p.retcode then
    errString = textRes.Pokemon.ERROR_RENAME_MAX_LEN
  elseif SAnimalRenameFailed.ERROR_INVALID == p.retcode then
    errString = textRes.Pokemon.ERROR_RENAME_INVALID
    warn("[PokemonProtocols:OnSAnimalRenameFailed] unhandled p.retcode:", p.retcode)
  end
  if errString then
    warn("[PokemonProtocols:OnSAnimalRenameFailed] err:", errString)
    Toast(errString)
  end
end
def.static("userdata", "=>", "boolean").SendCGetAnimalMates = function(uuid)
  warn("[PokemonProtocols:SendCGetAnimalMates] Send CGetAnimalMates!")
  local p = require("netio.protocol.mzm.gsp.zoo.CGetAnimalMates").new(uuid)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnSGetAnimalMatesSuccess = function(p)
  warn("[PokemonProtocols:OnSGetAnimalMatesSuccess] On SGetAnimalMatesSuccess! p.animalid=", tostring(p.animalid))
  local PokemonDetailPanel = require("Main.Pokemon.ui.PokemonDetailPanel")
  PokemonDetailPanel.ShowPanel(p)
end
PokemonProtocols.Commit()
return PokemonProtocols
