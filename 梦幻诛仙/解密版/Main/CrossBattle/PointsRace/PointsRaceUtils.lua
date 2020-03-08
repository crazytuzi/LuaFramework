local Lplus = require("Lplus")
local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleActivityStage")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local PointsRaceUtils = Lplus.Class("PointsRaceUtils")
local def = PointsRaceUtils.define
def.static("=>", "table").GetCurrentRaceCfg = function()
  return PointsRaceData.Instance():GetPointsRaceCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
end
def.static("=>", "table").GetCurrentDrawCfg = function()
  return PointsRaceData.Instance():GetDrawCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
end
def.static("=>", "number").GetEntranceNPCId = function()
  local crossbattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if crossbattleCfg then
    return crossbattleCfg.npc_id
  else
    warn("[ERROR][PointsRaceUtils:GetEntranceNPCId] crossbattleCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetQuitNPCId = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.leaveNpcId
  else
    warn("[ERROR][PointsRaceUtils:GetEntranceNPCId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetQuitServiceId = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.leaveServiceId
  else
    warn("[ERROR][PointsRaceUtils:GetQuitServiceId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetTipId = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.tipId
  else
    warn("[ERROR][PointsRaceUtils:GetTipId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetPromoteEffectId = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.promoteEffectId
  else
    warn("[ERROR][PointsRaceUtils:GetPromoteEffectId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetPromoteCount = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.promoteCount
  else
    warn("[ERROR][PointsRaceUtils:GetPromoteCount] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetPointsRaceMapId = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.raceMapId
  else
    warn("[ERROR][PointsRaceUtils:GetPointsRaceMapId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "boolean").IsInPointsRaceMap = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.raceMapId == gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  else
    warn("[ERROR][PointsRaceUtils:IsInPointsRaceMap] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return false
  end
end
def.static("=>", "number").GetRaceDurationInMin = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.matchDurationInMinute
  else
    warn("[ERROR][PointsRaceUtils:GetRaceDurationInMin] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return 0
  end
end
def.static("=>", "number").GetPrepareDurationInMin = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.prepareDurationInMinute
  else
    warn("[ERROR][PointsRaceUtils:GetPrepareDurationInMin] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return 0
  end
end
def.static("number", "=>", "string").GetFormatTime = function(timeInSeconds)
  if timeInSeconds > 0 then
    local hour = math.floor(timeInSeconds / 3600)
    local min = math.floor(timeInSeconds % 3600 / 60)
    local sec = math.floor(timeInSeconds % 60)
    return string.format("%02d:%02d:%02d", hour, min, sec)
  else
    return "00:00:00"
  end
end
def.static("=>", "boolean").IsCrossBattlePointsRaceStage = function()
  return CrossBattleInterface.Instance():getCurCrossBattleStage() == CrossBattleActivityStage.STAGE_ZONE_POINT
end
def.static("=>", "boolean").IsCrossBattleDrawZoneStage = function()
  return CrossBattleInterface.Instance():getCurCrossBattleStage() == CrossBattleActivityStage.STAGE_ZONE_DIVIDE
end
def.static("number", "=>", "string").GetZoneName = function(zoneId)
  local zoneCfg = PointsRaceData.Instance():GetZoneCfg(zoneId)
  if zoneCfg then
    return zoneCfg.zoneName
  else
    warn("[ERROR][PointsRaceUtils:GetZoneName] zoneCfg nil for zoneid:", zoneId)
    return false
  end
end
def.static("=>", "number").GetPointsRaceSwitchId = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.funSwitch
  else
    warn("[ERROR][PointsRaceUtils:GetPointsRaceSwitchId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetDrawSwitchId = function()
  local drawCfg = PointsRaceUtils.GetCurrentDrawCfg()
  if drawCfg then
    return drawCfg.funSwitch
  else
    warn("[ERROR][PointsRaceUtils:GetDrawSwitchId] drawCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("=>", "number").GetWinPoint = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.winPoint
  else
    warn("[ERROR][PointsRaceUtils:GetWinPoint] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return -1
  end
end
def.static("boolean", "=>", "boolean").HasDraw = function(bToast)
  local result = PointsRaceData.Instance():GetZoneId() > 0
  if bToast and result then
    local errString = textRes.PointsRace.DRAW_FAIL_ALREADY_DRAW
    Toast(errString)
  end
  return result
end
def.static("boolean", "=>", "boolean").CanDraw = function(bToast)
  local result = true
  if not require("Main.CrossBattle.PointsRace.PointsRaceMgr").Instance():IsDrawOpen(bToast) then
    result = false
  elseif not PointsRaceUtils.IsInDrawTime(bToast) then
    result = false
  elseif PointsRaceUtils.HasDraw(bToast) then
    result = false
  end
  return result
end
def.static("boolean", "=>", "boolean").IsInDrawTime = function(bToast)
  local result = false
  local drawCfg = PointsRaceUtils.GetCurrentDrawCfg()
  if drawCfg then
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(drawCfg.drawLotsTimePoint)
    local compareResult = PointsRaceUtils.IsInDuration(timePoint, drawCfg.durationInMinute)
    result = compareResult == 0
    if bToast and false == result then
      local errString
      if compareResult > 0 then
        errString = string.format(textRes.PointsRace.DRAW_FAIL_WRONG_TIME, timePoint.year, timePoint.month, timePoint.day, timePoint.hour, timePoint.min)
      else
        errString = textRes.PointsRace.DRAW_FAIL_OVER_TIME
      end
      if errString then
        Toast(errString)
      end
    end
  else
    warn("[ERROR][PointsRaceUtils:IsInDrawTime] drawCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  end
  return result
end
def.static("boolean", "=>", "boolean").CanRace = function(bToast)
  local result = true
  local toastStr
  if not require("Main.CrossBattle.PointsRace.PointsRaceMgr").Instance():IsRaceOpen(bToast) then
    result = false
  elseif not PointsRaceUtils.IsCrossBattlePointsRaceStage() then
    result = false
    local stage = CrossBattleInterface.Instance():getCurCrossBattleStage()
    if stage > CrossBattleActivityStage.STAGE_ZONE_POINT then
      toastStr = textRes.PointsRace.POINTS_RACE_OVER
    else
      local roundStartMatchTime = PointsRaceUtils.GetRoundStartMatchTimeTable(1, false)
      if roundStartMatchTime then
        roundStartMatchTime = PointsRaceUtils.GetPrepareStartTime(roundStartMatchTime)
        toastStr = string.format(textRes.PointsRace.RACE_ENTER_STAGE_NOT_OPEN, roundStartMatchTime.year, roundStartMatchTime.month, roundStartMatchTime.day, roundStartMatchTime.hour, roundStartMatchTime.min)
      else
        warn("[ERROR][PointsRaceUtils:CanRace] timeCfg nil for roundIdx [1] & bReschedule [false].")
      end
    end
  elseif not PointsRaceData.Instance():GetPromoted() then
    toastStr = textRes.PointsRace.ENTER_FAIL_NOT_PROMOTED
    result = false
  elseif not PointsRaceUtils.IsInRaceTime(bToast) then
    result = false
  end
  if bToast and toastStr then
    Toast(toastStr)
  end
  return result
end
def.static("boolean", "=>", "boolean").IsInRaceTime = function(bToast)
  local result = false
  local errString
  local roundIdx = PointsRaceData.Instance():GetRoundIndex()
  if roundIdx > 0 then
    local bReschedule = PointsRaceData.Instance():IsReschedule()
    local startMatchTimeTable = PointsRaceUtils.GetRoundStartMatchTimeTable(roundIdx, bReschedule)
    if startMatchTimeTable then
      local raceDurationInMin = PointsRaceUtils.GetRaceDurationInMin()
      local prepareDurationInMin = PointsRaceUtils.GetPrepareDurationInMin()
      startMatchTimeTable = PointsRaceUtils.GetPrepareStartTime(startMatchTimeTable)
      local compareResult = PointsRaceUtils.IsInDuration(startMatchTimeTable, raceDurationInMin + prepareDurationInMin)
      result = compareResult == 0
      if false == result then
        if compareResult > 0 then
          errString = string.format(textRes.PointsRace.RACE_ENTER_ROUND_NOT_OPEN, roundIdx, startMatchTimeTable.year, startMatchTimeTable.month, startMatchTimeTable.day, startMatchTimeTable.hour, startMatchTimeTable.min)
        else
          errString = textRes.PointsRace.RACE_ENTER_ROUND_OVER
        end
      end
    else
      warn(string.format("[ERROR][PointsRaceUtils:IsInRaceTime] timeCfg nil for roundIdx [%d] & bReschedule [%s].", roundIdx, tostring(bReschedule)))
    end
  else
    errString = textRes.PointsRace.POINTS_RACE_OVER
  end
  if bToast and errString then
    Toast(errString)
  end
  return result
end
def.static("table", "=>", "table").GetPrepareStartTime = function(matchStartTime)
  if matchStartTime then
    local matchStartTimeInSec = AbsoluteTimer.GetServerTimeByDate(matchStartTime.year, matchStartTime.month, matchStartTime.day, matchStartTime.hour, matchStartTime.min, matchStartTime.sec)
    local prepareDurationInMin = PointsRaceUtils.GetPrepareDurationInMin()
    local prepareStartTimeInSec = matchStartTimeInSec - prepareDurationInMin * 60
    return AbsoluteTimer.GetServerTimeTable(prepareStartTimeInSec)
  else
    warn("[ERROR][PointsRaceUtils:GetPrepareStartTime] matchStartTime nil.")
    return nil
  end
end
def.static("number", "boolean", "=>", "table").GetRoundStartMatchTimeTable = function(idx, bReschedule)
  local timePoint = PointsRaceUtils.GetRoundStartMatchTimePointId(idx, bReschedule)
  if timePoint > 0 then
    return TimeCfgUtils.GetCommonTimePointCfg(timePoint)
  else
    return nil
  end
end
def.static("number", "boolean", "=>", "number").GetRoundStartMatchTime = function(idx, bReschedule)
  local result = 0
  local startTimeTable = PointsRaceUtils.GetRoundStartMatchTimeTable(idx, bReschedule)
  if startTimeTable then
    result = AbsoluteTimer.GetServerTimeByDate(startTimeTable.year, startTimeTable.month, startTimeTable.day, startTimeTable.hour, startTimeTable.min, startTimeTable.sec)
  else
    warn("[ERROR][PointsRaceUtils:GetRoundStartMatchTime] startTimeTable nil for roundIdx & bReschedule:", idx, bReschedule)
  end
  return result
end
def.static("number", "boolean", "=>", "number").GetRoundStartMatchTimePointId = function(idx, bReschedule)
  local result = 0
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    if bReschedule then
      result = raceCfg.backupTimePoints and raceCfg.backupTimePoints[idx] or 0
    else
      result = raceCfg.timePoints and raceCfg.timePoints[idx] or 0
    end
  else
    warn("[ERROR][PointsRaceUtils:GetRoundStartMatchTimePointId] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  end
  return result
end
def.static("table", "number", "=>", "number").IsInDuration = function(dateTime, durInMin)
  local result = -1
  if dateTime then
    local startTime = AbsoluteTimer.GetServerTimeByDate(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.min, dateTime.sec)
    local serverTime = _G.GetServerTime()
    if startTime <= serverTime and serverTime <= startTime + durInMin * 60 then
      result = 0
    elseif startTime > serverTime then
      result = 1
    else
      result = -1
    end
  else
    warn("[ERROR][PointsRaceUtils:IsInDuration] dateTime nil!")
    result = -1
  end
  return result
end
def.static("=>", "number").CalcNextMatchTime = function()
  local nextMatchTime = 0
  local roundIdx = PointsRaceData.Instance():GetRoundIndex()
  local curStage = PointsRaceData.Instance():GetCurStage()
  if curStage == require("Main.CrossBattle.PointsRace.PointsRaceMgr").StageEnum.MATCHING and roundIdx > 0 then
    local startMatchTime = PointsRaceUtils.GetRoundStartMatchTime(roundIdx, PointsRaceData.Instance():IsReschedule())
    local matchingDuration = PointsRaceUtils.GetRaceDurationInMin() * 60
    local curTime = _G.GetServerTime()
    local matchingPastTime = curTime - startMatchTime
    if matchingPastTime >= 0 and matchingDuration > matchingPastTime then
      local matchingInterval = PointsRaceUtils.GetMatchIntervalInSec()
      if matchingInterval > 0 then
        local matchCountdown = matchingInterval - matchingPastTime % matchingInterval
        nextMatchTime = matchCountdown + _G.GetServerTime()
      else
        warn("[PointsRaceUtils:CalcNextMatchTime] wrong matchingInterval:", matchingInterval)
      end
    else
      warn("[PointsRaceUtils:CalcNextMatchTime] already past match time! matchingPastTime > matchingDuration:", matchingPastTime, matchingDuration)
    end
  else
    warn("[PointsRaceUtils:CalcNextMatchTime] wrong stage or roundIdx:", curStage, roundIdx)
  end
  return nextMatchTime
end
def.static("=>", "number").GetMatchIntervalInSec = function()
  local raceCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if raceCfg then
    return raceCfg.matchIntervalSecond
  else
    warn("[ERROR][PointsRaceUtils:GetMatchIntervalInSec] raceCfg nil for constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID:", constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return 0
  end
end
PointsRaceUtils.Commit()
return PointsRaceUtils
