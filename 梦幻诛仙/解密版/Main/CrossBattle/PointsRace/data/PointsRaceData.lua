local Lplus = require("Lplus")
local PointsRaceData = Lplus.Class("PointsRaceData")
local def = PointsRaceData.define
local _instance
def.static("=>", PointsRaceData).Instance = function()
  if _instance == nil then
    _instance = PointsRaceData()
  end
  return _instance
end
def.field("table")._pointsRaceCfg = nil
def.field("table")._zoneCfg = nil
def.field("table")._drawCfg = nil
def.field("boolean")._bPromoted = false
def.field("number")._zoneId = 0
def.field("number")._stage = 0
def.field("number")._stageEndTime = 0
def.field("number")._timerID = 0
def.field("boolean")._bReturnFromCenter = false
def.field("boolean")._bReschedule = false
def.field("number")._roundIndex = 0
def.field("userdata")._crossBattleCorpsID = nil
def.field("number")._nextMatchTime = 0
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._pointsRaceCfg = nil
  self._zoneCfg = nil
  self._drawCfg = nil
  self._bPromoted = false
  self._zoneId = 0
  local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
  self._stage = PointsRaceMgr.StageEnum.CLOSED
  self._stageEndTime = 0
  self._crossBattleCorpsID = nil
  self._bReschedule = false
  self._roundIndex = 0
  self._nextMatchTime = 0
end
def.method()._LoadPointsRaceCfg = function(self)
  warn("[PointsRaceData:_LoadPointsRaceCfg] start Load PointsRaceCfg!")
  self._pointsRaceCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLE_POINTSRACE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local raceCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    raceCfg.activityId = DynamicRecord.GetIntValue(entry, "activityCfgid")
    raceCfg.durationInMinute = DynamicRecord.GetIntValue(entry, "durationInMinute")
    raceCfg.prepareDurationInMinute = DynamicRecord.GetIntValue(entry, "prepareDurationInMinute")
    raceCfg.matchDurationInMinute = DynamicRecord.GetIntValue(entry, "matchDurationInMinute")
    raceCfg.matchIntervalSecond = DynamicRecord.GetIntValue(entry, "matchIntervalSecond")
    raceCfg.raceMapId = DynamicRecord.GetIntValue(entry, "remoteMapCfgid")
    raceCfg.localMapId = DynamicRecord.GetIntValue(entry, "localMapCfgid")
    raceCfg.leaveNpcId = DynamicRecord.GetIntValue(entry, "leaveMapNpcCfgid")
    raceCfg.leaveServiceId = DynamicRecord.GetIntValue(entry, "leaveMapNpcServiceCfgid")
    raceCfg.winPoint = DynamicRecord.GetIntValue(entry, "winPoint")
    raceCfg.losePoint = DynamicRecord.GetIntValue(entry, "losePoint")
    raceCfg.tipId = DynamicRecord.GetIntValue(entry, "ruleTipCfgid")
    raceCfg.endCountDown = DynamicRecord.GetIntValue(entry, "endFightCountDown")
    raceCfg.promoteEffectId = DynamicRecord.GetIntValue(entry, "promotionEffect")
    raceCfg.promoteCount = DynamicRecord.GetIntValue(entry, "promotionCorpsNum")
    raceCfg.timePoints = {}
    raceCfg.backupTimePoints = {}
    local struct = entry:GetStructValue("timePointsStruct")
    local count = struct:GetVectorSize("timePointsList")
    for i = 1, count do
      local record = struct:GetVectorValueByIdx("timePointsList", i - 1)
      local timePoint = record:GetIntValue("timePoint")
      local backupTimePoint = record:GetIntValue("backupTimePoint")
      table.insert(raceCfg.timePoints, timePoint)
      table.insert(raceCfg.backupTimePoints, backupTimePoint)
    end
    raceCfg.endTimePoint = DynamicRecord.GetIntValue(entry, "endTimePoint")
    raceCfg.funSwitch = DynamicRecord.GetIntValue(entry, "funSwitch")
    self._pointsRaceCfg[raceCfg.activityId] = raceCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetPointsRaceCfgs = function(self)
  if nil == self._pointsRaceCfg then
    self:_LoadPointsRaceCfg()
  end
  return self._pointsRaceCfg
end
def.method("number", "=>", "table").GetPointsRaceCfg = function(self, id)
  return self:_GetPointsRaceCfgs()[id]
end
def.method()._LoadZoneCfg = function(self)
  warn("[PointsRaceData:_LoadZoneCfg] start Load zoneCfg!")
  self._zoneCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLE_ZONE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local zoneCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    zoneCfg.zoneId = DynamicRecord.GetIntValue(entry, "zoneType")
    zoneCfg.zoneName = DynamicRecord.GetStringValue(entry, "name")
    self._zoneCfg[zoneCfg.zoneId] = zoneCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetZoneCfgs = function(self)
  if nil == self._zoneCfg then
    self:_LoadZoneCfg()
  end
  return self._zoneCfg
end
def.method("number", "=>", "table").GetZoneCfg = function(self, id)
  return self:_GetZoneCfgs()[id]
end
def.method()._LoadDrawCfg = function(self)
  warn("[PointsRaceData:_LoadDrawCfg] start Load drawCfg!")
  self._drawCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLE_DRAW_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local drawCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    drawCfg.activityId = DynamicRecord.GetIntValue(entry, "activityCfgid")
    drawCfg.zoneDivideTimePoint = DynamicRecord.GetIntValue(entry, "zoneDivideTimePoint")
    drawCfg.drawLotsTimePoint = DynamicRecord.GetIntValue(entry, "drawLotsTimePoint")
    drawCfg.durationInMinute = DynamicRecord.GetIntValue(entry, "durationInMinute")
    drawCfg.funSwitch = DynamicRecord.GetIntValue(entry, "funSwitch")
    self._drawCfg[drawCfg.activityId] = drawCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetDrawCfgs = function(self)
  if nil == self._drawCfg then
    self:_LoadDrawCfg()
  end
  return self._drawCfg
end
def.method("number", "=>", "table").GetDrawCfg = function(self, id)
  return self:_GetDrawCfgs()[id]
end
def.method("boolean").SetPromoted = function(self, value)
  warn(string.format("[PointsRaceData:SetPromoted] set _bPromoted=[%s].", tostring(value)))
  self._bPromoted = value
end
def.method("=>", "boolean").GetPromoted = function(self)
  return self._bPromoted
end
def.method("number").SetZoneId = function(self, id)
  self._zoneId = id
end
def.method("=>", "number").GetZoneId = function(self)
  return self._zoneId
end
def.method("number", "number").SetCurStage = function(self, stage, countdown)
  warn(string.format("[PointsRaceData:SetCurStage] set stage=[%d], countdown=[%d].", stage, countdown))
  self._stage = stage
  self._stageEndTime = _G.GetServerTime() + countdown
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattlePointsRace.POINTS_RACE_STAGE_CHANGE, {stage = stage})
end
def.method("=>", "number").GetCurStage = function(self)
  return self._stage
end
def.method("=>", "number").GetStageCountdown = function(self)
  return math.max(self._stageEndTime - _G.GetServerTime(), 0)
end
def.method("number", "boolean").SetRoundInfo = function(self, idx, bReschedule)
  self._bReschedule = bReschedule
  self._roundIndex = idx
end
def.method("=>", "number").GetRoundIndex = function(self)
  return self._roundIndex
end
def.method("=>", "boolean").IsReschedule = function(self)
  return self._bReschedule
end
def.method("=>", "boolean").IsReturnFromCenter = function(self)
  return self._bReturnFromCenter
end
def.method("boolean").SetReturnFromCenter = function(self, value)
  warn(string.format("[PointsRaceData:SetReturnFromCenter] set self._bReturnFromCenter=[%s].", tostring(value)))
  self._bReturnFromCenter = value
end
def.method("userdata").SetCrossBattleCorpsID = function(self, value)
  self._crossBattleCorpsID = value
end
def.method("=>", "userdata").GetCrossBattleCorpsID = function(self)
  return self._crossBattleCorpsID
end
def.method().UpdateNextMatchTime = function(self)
  local matchTime = 0
  if self._stage == require("Main.CrossBattle.PointsRace.PointsRaceMgr").StageEnum.MATCHING then
    matchTime = require("Main.CrossBattle.PointsRace.PointsRaceUtils").CalcNextMatchTime()
  else
    matchTime = 0
  end
  self:_SetNextMatchTime(matchTime)
end
def.method("=>", "number").GetNextMatchCountdown = function(self)
  return math.max(self._nextMatchTime - _G.GetServerTime(), 0)
end
def.method("number")._SetNextMatchTime = function(self, matchTime)
  warn("[PointsRaceData:_SetNextMatchTime] set self._nextMatchTime=", matchTime)
  self._nextMatchTime = matchTime
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattlePointsRace.POINTS_RACE_MATCH_CD_CHANGE, {matchTime = matchTime})
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("number").OnMatchFailed = function(self, countdown)
  local matchTime = 0
  if self._stage == require("Main.CrossBattle.PointsRace.PointsRaceMgr").StageEnum.MATCHING then
    matchTime = _G.GetServerTime() + countdown
  else
    matchTime = 0
  end
  self:_SetNextMatchTime(matchTime)
end
PointsRaceData.Commit()
return PointsRaceData
