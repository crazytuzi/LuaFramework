local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DragonBoatData = Lplus.Class(MODULE_NAME)
local DragonBoatRaceData = Lplus.ForwardDeclare("Main.DragonBoatRace.DragonBoatRaceData")
local RaceEvent = require("Main.DragonBoatRace.data.RaceEvent")
local RaceCommandResult = require("Main.DragonBoatRace.data.RaceCommandResult")
local def = DragonBoatData.define
def.field("userdata").m_id = nil
def.field("number").m_stageSpeed = 0
def.field("number").m_stageStartPos = 0
def.field(DragonBoatRaceData).m_belongRace = nil
def.field(RaceEvent).m_lastEvent = nil
def.field(RaceCommandResult).m_lastCommandResult = nil
def.field("boolean").m_arrived = false
def.method("=>", "userdata").GetId = function(self)
  return self.m_id
end
def.method("=>", "number").GetStageSpeed = function(self)
  return self.m_stageSpeed
end
def.method("=>", "number").GetStageStartPos = function(self)
  return self.m_stageStartPos
end
def.method("=>", "userdata").GetStageEndTime = function(self)
  if self.m_belongRace then
    return self.m_belongRace:GetStageEndTime()
  end
  return nil
end
def.method("=>", "number").GetStageDuration = function(self)
  if self.m_belongRace then
    return self.m_belongRace:GetStageDuration()
  end
  return 0
end
def.method("=>", "number").GetCurPos = function(self)
  local stageEndTime = self:GetStageEndTime()
  if stageEndTime == nil then
    return self.m_stageStartPos
  end
  local curTime = gmodule.moduleMgr:GetModule(ModuleId.DRAGON_BOAT_RACE):GetMilliServerTime()
  local duration = self:GetStageDuration() + math.min(0, (curTime - stageEndTime):ToNumber() / 1000)
  duration = math.max(0, duration)
  local curPos = self.m_stageStartPos + duration * self.m_stageSpeed
  return curPos
end
def.method("=>", "number").GetStageEndPos = function(self)
  local duration = self:GetStageDuration()
  local endPos = self.m_stageStartPos + duration * self.m_stageSpeed
  return endPos
end
def.method("=>", "number").GetTimelinePos = function(self)
  local stageEndTime = self:GetStageEndTime()
  if stageEndTime == nil then
    return self.m_stageStartPos
  end
  local curTime = gmodule.moduleMgr:GetModule(ModuleId.DRAGON_BOAT_RACE):GetMilliServerTime()
  local duration = self:GetStageDuration() + (curTime - stageEndTime):ToNumber() / 1000
  duration = math.max(0, duration)
  local curPos = self.m_stageStartPos + duration * self.m_stageSpeed
  return curPos
end
def.method("=>", "boolean").IsArrived = function(self)
  return self.m_arrived
end
def.method().MarkAsArrived = function(self)
  self.m_arrived = true
end
def.method().SetStartToEndPos = function(self)
  local endPos = self:GetStageEndPos()
  local curPos = self:GetCurPos()
  warn("curPos endPos", curPos, endPos)
  self:SetStageStartPos(endPos)
end
def.method("=>", DragonBoatRaceData).GetBelongRace = function(self)
  return self.m_belongRace
end
def.method("=>", RaceEvent).GetLastEvent = function(self)
  return self.m_lastEvent
end
def.method("=>", RaceCommandResult).GetLastCommandResult = function(self)
  return self.m_lastCommandResult
end
def.method("userdata").SetId = function(self, value)
  self.m_id = value
end
def.method("number").SetStageSpeed = function(self, value)
  self.m_stageSpeed = value
end
def.method("number").SetStageStartPos = function(self, value)
  self.m_stageStartPos = value
end
def.method(DragonBoatRaceData).SetBelongRace = function(self, value)
  self.m_belongRace = value
end
def.method(RaceEvent).SetLastEvent = function(self, value)
  self.m_lastEvent = value
end
def.method(RaceCommandResult).SetLastCommandResult = function(self, value)
  self.m_lastCommandResult = value
end
def.method("=>", "boolean").IsReachMaxSpeed = function(self)
  return self.m_belongRace:IsReachMaxSpeed(self)
end
def.method("=>", "boolean").IsReachMinSpeed = function(self)
  return self.m_belongRace:IsReachMinSpeed(self)
end
return DragonBoatData.Commit()
