local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DragonBoatRaceProtocol = Lplus.Class(MODULE_NAME)
local DragonBoatRaceModule = Lplus.ForwardDeclare("Main.DragonBoatRace.DragonBoatRaceModule")
local DragonBoatRaceData = require("Main.DragonBoatRace.DragonBoatRaceData")
local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
local def = DragonBoatRaceProtocol.define
def.static().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SRejectJoin", DragonBoatRaceProtocol.OnSRejectJoin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SPreview", DragonBoatRaceProtocol.OnSPreview)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SCancelPreview", DragonBoatRaceProtocol.OnSCancelPreview)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SSyncRaceInfo", DragonBoatRaceProtocol.OnSSyncRaceInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SEntry", DragonBoatRaceProtocol.OnSEntry)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SPhasePrepare", DragonBoatRaceProtocol.OnSPhasePrepare)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SSendCommand", DragonBoatRaceProtocol.OnSSendCommand)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SCommandResults", DragonBoatRaceProtocol.OnSCommandResults)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.SEvent", DragonBoatRaceProtocol.OnSEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lonngboatrace.STeamFinish", DragonBoatRaceProtocol.OnSTeamFinish)
end
def.static("number", "number").CJoinLonngBoatRaceReq = function(activityId, raceId)
  local p = require("netio.protocol.mzm.gsp.lonngboatrace.CJoinLonngBoatRaceReq").new(activityId, raceId)
  gmodule.network.sendProtocol(p)
end
def.static().CCancelPreview = function()
  local p = require("netio.protocol.mzm.gsp.lonngboatrace.CCancelPreview").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").CEntry = function(activityId, raceId)
  local p = require("netio.protocol.mzm.gsp.lonngboatrace.CEntry").new(activityId, raceId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number", "table").CSendCommand = function(raceId, phaseNo, round, times, commandList)
  local p = require("netio.protocol.mzm.gsp.lonngboatrace.CSendCommand").new(raceId, phaseNo, round, times, commandList)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSRejectJoin = function(p)
  local text = textRes.DragonBoatRace.SRejectJoin[p.rejCode]
  if text then
    text = string.format(text, unpack(p.params))
  else
    text = string.format("Error: OnSRejectJoin(%d)", p.rejCode)
  end
  Toast(text)
end
def.static("table").OnSPreview = function(p)
  DragonBoatRaceModule.Instance():SetPreviewInfo(p.activityId, p.raceId)
  DragonBoatRaceModule.Instance():ShowRuleUI()
end
def.static("table").OnSCancelPreview = function(p)
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.CancelRace, nil)
end
def.static("table").OnSSyncRaceInfo = function(p)
  local myTeamId = require("Main.Team.TeamData").Instance().teamId
  DragonBoatRaceModule.Instance():InitRace(myTeamId)
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  race:SetRaceCfgId(p.raceId)
  race:SetStartTime(p.matchBeginTimeStamp)
  local DragonBoatData = require("Main.DragonBoatRace.DragonBoatData")
  local competitors = {}
  for teamId, teamState in pairs(p.teamid2teamStat) do
    local competitor = DragonBoatData()
    competitor:SetId(teamId)
    competitor:SetStageSpeed(teamState.speed)
    competitor:SetStageStartPos(teamState.location)
    race:AddCompetitor(competitor)
  end
  if _G.IsEnteredWorld() then
    require("Main.DragonBoatRace.ui.DragonBoatRaceMainPanel").Instance():ShowPanel()
  end
end
def.static("table").OnSEntry = function(p)
  local myTeamId = require("Main.Team.TeamData").Instance().teamId
  if myTeamId == nil then
    warn("OnSEntry: myTeamId is nil")
    return
  end
  DragonBoatRaceModule.Instance():InitRace(myTeamId)
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  race:SetRaceCfgId(p.raceId)
  race:SetStartTime(p.matchBeginTimeStamp)
  race:SetStageEndTime(Int64.new(0))
  local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
  local DragonBoatData = require("Main.DragonBoatRace.DragonBoatData")
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(p.raceId)
  local competitors = {}
  for i = 1, raceCfg.trackCount do
    local competitor = DragonBoatData()
    local id
    if i == raceCfg.trackCount then
      id = myTeamId
    else
      id = DragonBoatRaceUtils.GenAITeamId(i)
    end
    competitor:SetId(id)
    competitor:SetStageSpeed(0)
    competitor:SetStageStartPos(0)
    race:AddCompetitor(competitor)
  end
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.StartRace, nil)
  require("Main.DragonBoatRace.ui.DragonBoatRaceMainPanel").Instance():ShowPanel()
end
def.static("table").OnSPhasePrepare = function(p)
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  if race == nil then
    warn("RaceNotExistError: OnSPhasePrepare")
    return
  end
  local phaseCfg = DragonBoatRaceUtils.GetRacePhaseCfg(p.phaseId)
  race:SetPhaseId(p.phaseId)
  race:SetStage(DragonBoatRaceData.Stage.Prepare)
  race:SetStageDuration(phaseCfg.prepareTime)
  race:SetStageEndTime(p.endTimeStamp)
  DragonBoatRaceModule.Instance():SetMilliServerTime(p.currTimeStamp)
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncPrepareStage, nil)
end
def.static("table").OnSSendCommand = function(p)
  warn("OnSSendCommand" .. gmodule.moduleMgr:GetModule(ModuleId.DRAGON_BOAT_RACE):GetMilliServerTime():tostring())
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  if race == nil then
    warn("RaceNotExistError: OnSSendCommand")
    return
  end
  local phaseCfg = DragonBoatRaceUtils.GetRacePhaseCfg(p.phaseId)
  race:SetPhaseId(p.phaseId)
  race:SetStage(DragonBoatRaceData.Stage.CommandSend)
  race:SetStageDuration(phaseCfg.commandTime)
  race:SetRound(p.round)
  race:SetTimesInRound(p.times)
  race:SetStageEndTime(p.endTimeStamp)
  race:SetCommandList(p.commandList)
  DragonBoatRaceModule.Instance():SetMilliServerTime(p.currTimeStamp)
  if phaseCfg.phaseNo == 1 and p.round == 1 and p.times == 1 then
    local raceCfgId = race:GetRaceCfgId()
    local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
    local competitors = race:GetCompetitors()
    for k, competitor in pairs(competitors) do
      competitor:SetStageSpeed(raceCfg.boatInitSpeed)
    end
  end
  local commandList = p.commandList
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncCommands, {commandList})
end
def.static("table").OnSEvent = function(p)
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  if race == nil then
    warn("RaceNotExistError: OnSEvent")
    return
  end
  local calcSpeed = p.calcSpeed == p.class.CALC_SPEED
  race:SetPhaseId(p.phaseId)
  race:SetStage(DragonBoatRaceData.Stage.Event)
  race:SetStageEndTime(p.endTimeStamp)
  for teamId, eventId in pairs(p.team2eventId) do
    local competitor = race:GetCompetitor(teamId)
    race:TriggerEvent(competitor, p.eventTriggerId, eventId, calcSpeed)
  end
  local eventTriggerCfg = DragonBoatRaceUtils.GetRaceEventTriggerCfg(p.eventTriggerId)
  local EventTimeType = require("consts.mzm.gsp.lonngboatrace.confbean.EventTimeType")
  if eventTriggerCfg.eventTimeType == EventTimeType.FIXED_TIME then
    race:SetStageDuration(eventTriggerCfg.eventTime)
  else
    local duration = race:CalcLastStageDuration()
    race:SetStageDuration(duration)
  end
  DragonBoatRaceModule.Instance():SetMilliServerTime(p.currTimeStamp)
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncEvent, nil)
end
def.static("table").OnSCommandResults = function(p)
  warn("OnSCommandResults" .. gmodule.moduleMgr:GetModule(ModuleId.DRAGON_BOAT_RACE):GetMilliServerTime():tostring())
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  if race == nil then
    warn("RaceNotExistError: OnSCommandResults")
    return
  end
  local phaseCfg = DragonBoatRaceUtils.GetRacePhaseCfg(p.phaseId)
  local calcSpeed = p.calcSpeed == p.class.CALC_SPEED
  race:SetPhaseId(p.phaseId)
  race:SetStage(DragonBoatRaceData.Stage.CommandResult)
  race:SetStageDuration(phaseCfg.tipTime)
  race:SetStageEndTime(p.endTimeStamp)
  for teamId, isAllRight in pairs(p.teamId2isAllRight) do
    local isAllRight = isAllRight == p.class.CORRECT
    local competitor = race:GetCompetitor(teamId)
    race:ApplyCommandResult(competitor, {isAllRight = isAllRight}, calcSpeed)
  end
  local myTeamId = race:GetMyTeamId()
  local myTeam = race:GetCompetitor(myTeamId)
  local commandResult = myTeam:GetLastCommandResult()
  local teamMemberStates = {}
  for roleid, v in pairs(p.roleId2isRight) do
    local state = {}
    state.right = v == p.class.CORRECT
    teamMemberStates[roleid:tostring()] = state
  end
  commandResult:SetTeamMemberStates(teamMemberStates)
  DragonBoatRaceModule.Instance():SetMilliServerTime(p.currTimeStamp)
  Event.DispatchEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.SyncCommandResults, nil)
end
def.static("table").OnSTeamFinish = function(p)
  local race = DragonBoatRaceModule.Instance():GetCurRace()
  if race == nil then
    warn("RaceNotExistError: OnSTeamFinish")
    return
  end
  local result = p
  race:EndRace()
  local rankList = race:CalcRanking()
  result.winnerId = rankList[1] and rankList[1]:GetId() or Int64.new(-1)
  local raceCfgId = race:GetRaceCfgId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  result.displayTime = raceCfg.showScoreTime
  require("Main.DragonBoatRace.ui.DragonBoatRaceResultPanel").Instance():ShowPanel(result)
end
return DragonBoatRaceProtocol.Commit()
