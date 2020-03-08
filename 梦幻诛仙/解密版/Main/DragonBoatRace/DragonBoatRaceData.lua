local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DragonBoatRaceData = Lplus.Class(MODULE_NAME)
local DragonBoatData = require("Main.DragonBoatRace.DragonBoatData")
local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
local RaceEvent = require("Main.DragonBoatRace.data.RaceEvent")
local RaceCommandResult = require("Main.DragonBoatRace.data.RaceCommandResult")
local def = DragonBoatRaceData.define
def.const("table").Stage = {
  None = -1,
  Prepare = 1,
  CommandSend = 2,
  CommandResult = 3,
  Event = 4
}
def.field("number").m_raceCfgId = 0
def.field("userdata").m_startTime = nil
def.field("number").m_stage = -1
def.field("number").m_stageDuration = 0
def.field("userdata").m_stageEndTime = nil
def.field("number").m_phaseId = 0
def.field("number").m_trackLength = -1
def.field("table").m_competitors = nil
def.field("number").m_round = 0
def.field("number").m_timesInRound = 0
def.field("table").m_commandList = nil
def.field("number").m_eventTriggerId = 0
def.field("userdata").m_myTeamId = nil
def.field("boolean").m_isRaceEnd = false
local instance
def.static("=>", DragonBoatRaceData).Instance = function()
  if instance == nil then
    instance = DragonBoatRaceData()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("=>", "boolean").IsReady = function(self)
  if self.m_stage == DragonBoatRaceData.Stage.None then
    return false
  end
  return true
end
def.method("=>", "number").GetRaceCfgId = function(self)
  return self.m_raceCfgId
end
def.method("=>", "userdata").GetStartTime = function(self)
  return self.m_startTime
end
def.method("=>", "number").GetStage = function(self)
  return self.m_stage
end
def.method("=>", "userdata").GetStageEndTime = function(self)
  return self.m_stageEndTime
end
def.method("=>", "table").GetCompetitors = function(self)
  return self.m_competitors
end
def.method("userdata", "=>", DragonBoatData).GetCompetitor = function(self, competitorId)
  if self.m_competitors == nil then
    return nil
  end
  return self.m_competitors[tostring(competitorId)]
end
def.method("=>", "number").GetPhaseId = function(self)
  return self.m_phaseId
end
def.method("=>", "number").GetPhaseNo = function(self)
  local phaseCfg = self:GetCurPhaseCfg()
  return phaseCfg.phaseNo
end
def.method("=>", "table").GetCurPhaseCfg = function(self)
  return DragonBoatRaceUtils.GetRacePhaseCfg(self.m_phaseId)
end
def.method("=>", "number").GetRound = function(self)
  return self.m_round
end
def.method("=>", "number").GetTimesInRound = function(self)
  return self.m_timesInRound
end
def.method("=>", "number").GetStageDuration = function(self)
  return self.m_stageDuration
end
def.method("=>", "table").GetCommandList = function(self)
  return self.m_commandList
end
def.method("=>", "number").GetEventTriggerId = function(self)
  return self.m_eventTriggerId
end
def.method("=>", "number").GetTrackLength = function(self)
  if self.m_trackLength ~= -1 then
    return self.m_trackLength
  end
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(self.m_raceCfgId)
  local trackLen = raceCfg and raceCfg.trackLen or 1
  self.m_trackLength = trackLen
  return trackLen
end
def.method("=>", "boolean").IsRaceEnd = function(self)
  return self.m_isRaceEnd
end
def.method().EndRace = function(self)
  self.m_isRaceEnd = true
end
def.method("table").SetCommandList = function(self, value)
  self.m_commandList = value
end
def.method("number").SetRaceCfgId = function(self, value)
  self.m_raceCfgId = value
end
def.method("userdata").SetStartTime = function(self, value)
  self.m_startTime = value
end
def.method("number").SetStage = function(self, value)
  self.m_stage = value
  self:CheckoutStagePos()
end
def.method().CheckoutStagePos = function(self)
  if self.m_competitors then
    for k, v in pairs(self.m_competitors) do
      v:SetStartToEndPos()
    end
  end
end
def.method("userdata").SetStageEndTime = function(self, value)
  self.m_stageEndTime = value
end
def.method("table").SetCompetitors = function(self, value)
  self.m_competitors = value
end
def.method("number").SetPhaseId = function(self, value)
  self.m_phaseId = value
end
def.method(DragonBoatData).AddCompetitor = function(self, value)
  if self.m_competitors == nil then
    self.m_competitors = {}
  end
  value:SetBelongRace(self)
  self.m_competitors[value:GetId():tostring()] = value
end
def.method("number").SetRound = function(self, value)
  self.m_round = value
end
def.method("number").SetTimesInRound = function(self, value)
  self.m_timesInRound = value
end
def.method("number").SetStageDuration = function(self, value)
  self.m_stageDuration = value
end
def.method("number").SetEventTriggerId = function(self, value)
  self.m_eventTriggerId = value
end
def.method(DragonBoatData, "number", "=>", "number").ChangeCompetitorSpeed = function(self, competitor, dSpeed)
  local curSpeed = competitor:GetStageSpeed()
  local nextSpeed = self:SetCompetitorSpeed(competitor, curSpeed + dSpeed)
  return nextSpeed - curSpeed
end
def.method(DragonBoatData, "number", "=>", "number").SetCompetitorSpeed = function(self, competitor, speed)
  local racePhaseCfg = DragonBoatRaceUtils.GetRacePhaseCfg(self.m_phaseId)
  speed = require("Common.MathHelper").Clamp(speed, racePhaseCfg.minSpeed, racePhaseCfg.maxSpeed)
  competitor:SetStageSpeed(speed)
  return speed
end
def.method(DragonBoatData, "table", "boolean").ApplyCommandResult = function(self, competitor, result, bModifySpeed)
  local racePhaseCfg = DragonBoatRaceUtils.GetRacePhaseCfg(self.m_phaseId)
  local speedChange
  local commandResult = RaceCommandResult.new()
  commandResult:SetIsAllRight(result.isAllRight)
  if bModifySpeed then
    if result.isAllRight then
      speedChange = racePhaseCfg.speedUpUnit
    else
      speedChange = -racePhaseCfg.speedDownUnit
    end
    local actualChange = self:ChangeCompetitorSpeed(competitor, speedChange)
    commandResult:SetActualChangeSpeed(actualChange)
  end
  competitor:SetLastCommandResult(commandResult)
end
def.method(DragonBoatData, "number", "number", "boolean").TriggerEvent = function(self, competitor, eventTriggerId, eventId, bModifySpeed)
  self:SetEventTriggerId(eventTriggerId)
  local DragonBoatRaceModule = require("Main.DragonBoatRace.DragonBoatRaceModule")
  local eventInfo = RaceEvent.new(eventId)
  if bModifySpeed and eventId ~= DragonBoatRaceModule.EVENT_ID_NONE then
    local eventCfg = DragonBoatRaceUtils.GetRaceEventCfg(eventId)
    if eventCfg then
      local actualChange = self:ChangeCompetitorSpeed(competitor, eventCfg.speedChange)
      eventInfo:SetActualChangeSpeed(actualChange)
    end
  end
  competitor:SetLastEvent(eventInfo)
end
def.method(DragonBoatData, "=>", "boolean").IsReachMaxSpeed = function(self, competitor)
  local phaseCfg = self:GetCurPhaseCfg()
  return competitor:GetStageSpeed() >= phaseCfg.maxSpeed
end
def.method(DragonBoatData, "=>", "boolean").IsReachMinSpeed = function(self, competitor)
  local phaseCfg = self:GetCurPhaseCfg()
  return competitor:GetStageSpeed() <= phaseCfg.minSpeed
end
def.method("=>", "table").CalcRanking = function(self)
  if self.m_competitors == nil then
    return {}
  end
  local rankList = {}
  for _, v in pairs(self.m_competitors) do
    table.insert(rankList, v)
  end
  table.sort(rankList, function(l, r)
    local lEndPos = l:GetStageEndPos()
    local rEndPos = r:GetStageEndPos()
    if lEndPos ~= rEndPos then
      return lEndPos > rEndPos
    else
      return l:GetId() > r:GetId()
    end
  end)
  return rankList
end
def.method("=>", "number").CalcLastStageDuration = function(self)
  if self.m_competitors == nil then
    return 0
  end
  local trackLen = self:GetTrackLength()
  local min_t
  for _, v in pairs(self.m_competitors) do
    local startPos = v:GetStageStartPos()
    local leftDistance = trackLen - startPos
    local speed = v:GetStageSpeed()
    local t = leftDistance / speed
    if min_t == nil or min_t > t then
      min_t = t
    end
  end
  return min_t or 0
end
def.method("userdata").SetMyTeamId = function(self, teamId)
  self.m_myTeamId = teamId
end
def.method("=>", "userdata").GetMyTeamId = function(self)
  return self.m_myTeamId
end
return DragonBoatRaceData.Commit()
