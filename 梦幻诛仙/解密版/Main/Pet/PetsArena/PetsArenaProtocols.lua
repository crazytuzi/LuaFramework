local FILE_NAME = (...)
local Lplus = require("Lplus")
local PetsArenaProtocols = Lplus.Class(FILE_NAME)
local Cls = PetsArenaProtocols
local def = Cls.define
local instance
local txtConst = textRes.Pet.PetsArena
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SyncOpponentInfos", Cls.OnSyncOpponentInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetPetArenaInfoSuccess", Cls.OnSGetPetArenaInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetPetArenaInfoFailed", Cls.OnSGetPetArenaInfoFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SRefreshOpponentSuccess", Cls.OnSRefreshOpponentSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SRefreshOpponentFailed", Cls.OnSRefreshOpponentFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SBuyChallengeCountSuccess", Cls.OnSBuyChallengeCountSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SBuyChallengeCountFailed", Cls.OnSBuyChallengeCountFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetDefendPetTeamSuccess", Cls.OnSGetDefendPetTeamSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetDefendPetTeamFailed", Cls.OnSGetDefendPetTeamFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SStartFightSuccess", Cls.OnSStartFightSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SStartFightFailed", Cls.OnSStartFightFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetFightRecordSuccess", Cls.OnSGetFightRecordSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SViewFightSuccess", Cls.OnSViewFightSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SViewFightFailed", Cls.OnSViewFightFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SGetFightDataSuccess", Cls.OnSGetFightDataSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SFightEndSuccess", Cls.OnSFightEndSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.petarena.SFightEndFailed", Cls.OnSFightEndFailed)
end
def.static("table").OnSyncOpponentInfos = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_OPPOENTSINFO_SUCCESS, p)
end
def.static().CSengGetPetsArenaInfoReq = function()
  local p = require("netio.protocol.mzm.gsp.petarena.CGetPetArenaInfo").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetPetArenaInfoSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_SELF_PETSARENA_INFO, p.pet_arena_info)
end
def.static("table").OnSGetPetArenaInfoFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.petarena.SGetPetArenaInfoFailed")
  if p.retcode == ERROR_CODE.ERROR_LEVEL then
    Toast(txtConst[14])
  elseif p.retcode == ERROR_CODE.ERROR_ACTIVITY_JOIN then
    Toast(txtConst[15])
  elseif p.retcode == ERROR_CODE.ERROR_IN_TEAM then
    Toast(txtConst[34])
  end
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_OPPOENTSINFO_FAILED, nil)
end
def.static().CSendRefreshOppoent = function()
  local p = require("netio.protocol.mzm.gsp.petarena.CRefreshOpponent").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSRefreshOpponentSuccess = function(p)
  Toast(txtConst[36])
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.REFRESH_OPPOENTSINFO_SUCCESS, p)
end
def.static("table").OnSRefreshOpponentFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.petarena.SRefreshOpponentFailed")
  if p.retcode == ERROR_CODE.ERROR_LEVEL then
    Toast(txtConst[14])
  elseif p.retcode == ERROR_CODE.ERROR_ACTIVITY_JOIN then
    Toast(txtConst[15])
  elseif p.retcode == ERROR_CODE.ERROR_CD then
    Toast(txtConst[16])
  end
end
def.static().CSendBuyTryTimes = function()
  local p = require("netio.protocol.mzm.gsp.petarena.CBuyChallengeCount").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSBuyChallengeCountSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.BUY_CHALLENGE_COUNT_SUCCESS, p)
end
def.static("table").OnSBuyChallengeCountFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.petarena.SBuyChallengeCountFailed")
  if p.retcode == ERROR_CODE.ERROR_LEVEL then
    Toast(txtConst[14])
  elseif p.retcode == ERROR_CODE.ERROR_ACTIVITY_JOIN then
    Toast(txtConst[15])
  elseif p.retcode == ERROR_CODE.ERROR_COST_YUAN_BAO then
    Toast(txtConst[17])
  elseif p.retcode == ERROR_CODE.ERROR_BUY_LIMIT then
    Toast(txtConst[18]:format(constant.CPetArenaConst.MAX_BUY_COUNT))
  elseif p.retcode == ERROR_CODE.ERROR_IN_TEAM then
    Toast(txtConst[34])
  end
end
def.static("userdata", "number", "number").CGetPetDefenseTeam = function(roleId, rank, serial)
  local p = require("netio.protocol.mzm.gsp.petarena.CGetDefendPetTeam").new(roleId, rank, serial)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetDefendPetTeamSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_TARGET_PETTEAM_OK, p)
end
def.static("table").OnSGetDefendPetTeamFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.petarena.SGetDefendPetTeamFailed")
  if ERROR_CODE.ERROR_LEVEL == p.retcode then
    Toast(txtConst[14])
  elseif ERROR_CODE.ERROR_RANK_CHANGED == p.retcode then
    Toast(txtConst[39])
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PETARENA_RANK_CHANGE, nil)
  elseif ERROR_CODE.ERROR_OPPONENT_CHANGED == p.retcode then
    Toast(txtConst[40])
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPPONENTS_INFO_CHANGE, nil)
  end
end
def.static("userdata", "number", "number", "number").CSendStartPetsFight = function(roleId, rank, teamid, serial)
  local p = require("netio.protocol.mzm.gsp.petarena.CStartFight").new(roleId, rank, teamid, serial)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSStartFightSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.START_PETS_FIGHT_SUCCESS, p)
end
def.static("table").OnSStartFightFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.petarena.SStartFightFailed")
  if p.retcode == ERROR_CODE.ERROR_LEVEL then
    Toast(txtConst[14])
  elseif p.retcode == ERROR_CODE.ERROR_ACTIVITY_JOIN then
    Toast(txtConst[15])
  elseif p.retcode == ERROR_CODE.ERROR_CHALLENGE_NOT_ENOUGH then
    Toast(txtConst[19])
  elseif p.retcode == ERROR_CODE.ERROR_ATTACK_TEAM_EMPTY then
    Toast(txtConst[20])
  elseif p.retcode == ERROR_CODE.ERROR_DEFEND_TEAM_EMPTY then
    Toast(txtConst[21])
  elseif p.retcode == ERROR_CODE.ERROR_IN_TEAM then
    Toast(txtConst[34])
  elseif p.retcode == ERROR_CODE.ERROR_RANK_CHANGED then
    Toast(txtConst[39])
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PETARENA_RANK_CHANGE, nil)
  elseif ERROR_CODE.ERROR_OPPONENT_CHANGED == p.retcode then
    Toast(txtConst[40])
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPPONENTS_INFO_CHANGE, nil)
  end
end
def.static("number", "number").CSendRankListReq = function(startpos, count)
  local p = require("netio.protocol.mzm.gsp.petarena.CGetChart").new(startpos, count)
  gmodule.network.sendProtocol(p)
end
def.static().CGetFightRecordReq = function()
  local p = require("netio.protocol.mzm.gsp.petarena.CGetFightRecord").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetFightRecordSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_FIGHT_RECORD_OK, p)
end
def.static("userdata").CSendWatchVideoReq = function(recordid)
  local p = require("netio.protocol.mzm.gsp.petarena.CViewFight").new(recordid)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSViewFightSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.WATCH_PET_FIGHT_VIDEO_OK, p)
end
def.static("table").OnSViewFightFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.petarena.SViewFightFailed")
  if p.retcode == ERROR_CODE.ERROR_NOT_FOUND then
    Toast(txtConst[35])
  elseif p.retcode == ERROR_CODE.ERROR_ACTIVITY_JOIN then
    Toast(txtConst[15])
  elseif p.retcode == ERROR_CODE.ERROR_IN_TEAM then
    Toast(txtConst[34])
  end
end
def.static("userdata").CGetFightDataReq = function(recordid)
  local p = require("netio.protocol.mzm.gsp.petarena.CGetFightData").new(recordid)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetFightDataSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_PET_STASTIC_OK, p)
end
def.static().CReportFightEnd = function()
  local p = require("netio.protocol.mzm.gsp.petarena.CFightEnd").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSFightEndSuccess = function(p)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.REPORT_FIGHT_END_OK, p)
end
def.static("table").OnSFightEndFailed = function(p)
end
return Cls.Commit()
