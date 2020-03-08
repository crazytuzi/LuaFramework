local Lplus = require("Lplus")
local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
local HistoryData = require("Main.CrossBattle.History.data.HistoryData")
local HistoryProtocols = Lplus.Class("HistoryProtocols")
local def = HistoryProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifyFinalResultOut", HistoryProtocols.OnSNotifyFinalResultOut)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SChangeCrossBattleHistoryActivity", HistoryProtocols.OnSChangeCrossBattleHistoryActivity)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SChangeCrossBattleCurrentSession", HistoryProtocols.OnSChangeCrossBattleCurrentSession)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleTopThreeInfo", HistoryProtocols.OnSGetSeasonTop3Info)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleHistoryNormalRes", HistoryProtocols.OnSGetSeasonTop3InfoFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleFinalHistoryInfo", HistoryProtocols.OnSGetSeasonMatchInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleFinalHistoryCorpsInfo", HistoryProtocols.OnSGetTeamInfo)
end
def.static("table").OnSNotifyFinalResultOut = function(p)
  warn("[HistoryProtocols:OnSNotifyFinalResultOut] On SNotifyFinalResultOut!")
  HistoryData.Instance():SetResultOut(true)
  local HistoryMainPanel = require("Main.CrossBattle.History.ui.HistoryMainPanel")
  if HistoryMainPanel.Instance():IsShow() then
    HistoryMainPanel.Instance():OnSNotifyFinalResultOut(p)
  end
end
def.static("table").OnSChangeCrossBattleHistoryActivity = function(p)
  warn("[HistoryProtocols:OnSChangeCrossBattleHistoryActivity] p.session, p.activity_cfg_id:", p.session, p.activity_cfg_id)
  HistoryData.Instance():SetSeasonActivityId(p.session, p.activity_cfg_id)
end
def.static("table").OnSChangeCrossBattleCurrentSession = function(p)
  warn("[HistoryProtocols:OnSChangeCrossBattleCurrentSession] p.session:", p.session)
  HistoryData.Instance():SetCurSeason(p.session)
end
def.static("number").SendCGetSeasonTop3Info = function(season)
  warn("[HistoryProtocols:SendCGetSeasonTop3Info] Send CGetCrossBattleTopThreeInfo!")
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleTopThreeInfo").new(season)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetSeasonTop3Info = function(p)
  warn("[HistoryProtocols:OnSGetSeasonTop3Info] On SGetCrossBattleTopThreeInfo!")
  local Top3Info = require("Main.CrossBattle.History.data.Top3Info")
  local top3info = Top3Info.New(p)
  HistoryData.Instance():SetSeasonTop3Info(p.session, top3info)
  local HistoryMainPanel = require("Main.CrossBattle.History.ui.HistoryMainPanel")
  if HistoryMainPanel.Instance():IsShow() then
    HistoryMainPanel.Instance():OnSGetSeasonTop3Info(top3info)
  end
end
def.static("table").OnSGetSeasonTop3InfoFailed = function(p)
  warn("[HistoryProtocols:OnSGetSeasonTop3InfoFailed] On SCrossBattleHistoryNormalRes! p.ret:", p.ret)
  local SCrossBattleHistoryNormalRes = require("netio.protocol.mzm.gsp.crossbattle.SCrossBattleHistoryNormalRes")
  local errString
  if SCrossBattleHistoryNormalRes.TIME_LIMIT == p.ret then
    errString = textRes.CrossBattle.History.GET_SEASON_FAIL
  elseif SCrossBattleHistoryNormalRes.FUNCTION_NOT_OPEN == p.ret then
    errString = textRes.CrossBattle.History.FEATRUE_IDIP_NOT_OPEN
  elseif SCrossBattleHistoryNormalRes.ACTIVITY_DB_DATA_NOT_EXIST == p.ret then
    errString = textRes.CrossBattle.History.ACTIVITY_DB_DATA_NOT_EXIST
  elseif SCrossBattleHistoryNormalRes.FINAL_DB_DATA_NOT_EXIST == p.ret then
    errString = textRes.CrossBattle.History.FINAL_DB_DATA_NOT_EXIST
  elseif SCrossBattleHistoryNormalRes.FIGHT_ZONE_DB_DATA_NOT_EXIST == p.ret then
    errString = textRes.CrossBattle.History.FIGHT_ZONE_DB_DATA_NOT_EXIST
  elseif SCrossBattleHistoryNormalRes.ACTIVITY_CFG_DATA_NOT_EXIST == p.ret then
    errString = textRes.CrossBattle.History.ACTIVITY_CFG_DATA_NOT_EXIST
  elseif SCrossBattleHistoryNormalRes.FINAL_CFG_DATA_NOT_EXIST == p.ret then
    errString = textRes.CrossBattle.History.FINAL_CFG_DATA_NOT_EXIST
  elseif SCrossBattleHistoryNormalRes.PARAM_SESSION_ERROR == p.ret then
    errString = textRes.CrossBattle.History.PARAM_SESSION_ERROR
  elseif SCrossBattleHistoryNormalRes.HISTORY_CFG_NOT_EXIST == p.ret then
    errString = textRes.CrossBattle.History.HISTORY_CFG_NOT_EXIST
  elseif SCrossBattleHistoryNormalRes.GET_FINAL_STAGE_ERROR == p.ret then
    errString = textRes.CrossBattle.History.GET_FINAL_STAGE_ERROR
  elseif SCrossBattleHistoryNormalRes.GRC_SEND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.GRC_SEND_ERROR
  elseif SCrossBattleHistoryNormalRes.GRC_GET_DATA_ERROR == p.ret then
    errString = textRes.CrossBattle.History.GRC_GET_DATA_ERROR
  elseif SCrossBattleHistoryNormalRes.GET_KNOCK_OUT_HANDLER_ERROR == p.ret then
    errString = textRes.CrossBattle.History.GET_KNOCK_OUT_HANDLER_ERROR
  elseif SCrossBattleHistoryNormalRes.CAN_NOT_QUERY_FINAL_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CAN_NOT_QUERY_FINAL_ERROR
  elseif SCrossBattleHistoryNormalRes.NOT_FINAL_LAST_ROUND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.NOT_FINAL_LAST_ROUND_ERROR
  elseif SCrossBattleHistoryNormalRes.CHAMPION_NOT_OUT_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CHAMPION_NOT_OUT_ERROR
  elseif SCrossBattleHistoryNormalRes.CHAMPION_STAGE_DATA_NOT_FOUND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CHAMPION_STAGE_DATA_NOT_FOUND_ERROR
  elseif SCrossBattleHistoryNormalRes.CHAMPION_FIGHT_AGAINST_DATA_NOT_FOUND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CHAMPION_FIGHT_AGAINST_DATA_NOT_FOUND_ERROR
  elseif SCrossBattleHistoryNormalRes.THIRD_PLACE_STAGE_DATA_NOT_FOUND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.THIRD_PLACE_STAGE_DATA_NOT_FOUND_ERROR
  elseif SCrossBattleHistoryNormalRes.THRID_PLACE_FIGHT_AGAINST_DATA_NOT_FOUND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.THRID_PLACE_FIGHT_AGAINST_DATA_NOT_FOUND_ERROR
  elseif SCrossBattleHistoryNormalRes.RANK_DATA_ERROR == p.ret then
    errString = textRes.CrossBattle.History.RANK_DATA_ERROR
  elseif SCrossBattleHistoryNormalRes.NO_CHAMPION_ERROR == p.ret then
    errString = textRes.CrossBattle.History.NO_CHAMPION_ERROR
  elseif SCrossBattleHistoryNormalRes.CORPS_ID_NO_CHAMPION_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CORPS_ID_NO_CHAMPION_ERROR
  elseif SCrossBattleHistoryNormalRes.CORPS_ID_NO_SECOND_PLACE_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CORPS_ID_NO_SECOND_PLACE_ERROR
  elseif SCrossBattleHistoryNormalRes.CORPS_ID_NO_THIRD_PLACE_ERROR == p.ret then
    errString = textRes.CrossBattle.History.CORPS_ID_NO_THIRD_PLACE_ERROR
  elseif SCrossBattleHistoryNormalRes.LAST_SESSION_CFG_NOT_FOUND_ERROR == p.ret then
    errString = textRes.CrossBattle.History.LAST_SESSION_CFG_NOT_FOUND_ERROR
  else
    warn("[ERROR][HistoryProtocols:OnSGetSeasonTop3InfoFailed] unhandled p.ret:", p.ret)
  end
  if errString then
    Toast(errString)
  end
end
def.static("number").SendCGetSeasonMatchInfo = function(season)
  warn("[HistoryProtocols:SendCGetSeasonMatchInfo] Send CGetCrossBattleFinalHistoryReq!")
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleFinalHistoryReq").new(season)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetSeasonMatchInfo = function(p)
  warn("[HistoryProtocols:OnSGetSeasonMatchInfo] On SGetCrossBattleFinalHistoryInfo!")
  local MatchData = require("Main.CrossBattle.History.data.MatchData")
  local matchData = MatchData.New(p.session, p.final_fight_corps_map, p.final_stage_fight_info_map)
  HistoryData.Instance():SetSeasonMatchInfo(p.session, matchData)
  local HistoryMatchPanel = require("Main.CrossBattle.History.ui.HistoryMatchPanel")
  if HistoryMatchPanel.Instance():IsShow() then
    HistoryMatchPanel.Instance():OnSGetSeasonMatchInfo(matchData)
  end
end
def.static("userdata").SendCPlayMatch = function(recordId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CGetRealtimeRecordReq").new(recordId))
end
def.static("number", "number", "userdata").SendCGetTeamInfo = function(season, rank, corpsId)
  warn("[HistoryProtocols:SendCGetTeamInfo] Send CGetCrossBattleFinalHistoryCorpsReq!")
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleFinalHistoryCorpsReq").new(season, rank, corpsId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetTeamInfo = function(p)
  warn("[HistoryProtocols:OnSGetTeamInfo] On SGetCrossBattleFinalHistoryCorpsInfo!")
  HistoryData.Instance():SetCorpsInfo(p.session, p.rank, p.corps_id, p)
  local HistoryCorpsPanel = require("Main.CrossBattle.History.ui.HistoryCorpsPanel")
  if HistoryCorpsPanel.Instance():IsShow() then
    HistoryCorpsPanel.Instance():OnSGetTeamInfo(p)
  end
end
HistoryProtocols.Commit()
return HistoryProtocols
