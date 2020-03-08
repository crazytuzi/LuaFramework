local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CrossBattleBetMgr = Lplus.Class(MODULE_NAME)
local CrossBattleBetProtocol = import(".CrossBattleBetProtocol")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local BetInfo = import(".data.BetInfo")
local CrossBattleBetUtils = import(".CrossBattleBetUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = CrossBattleBetMgr.define
def.const("string").BET_NOTIFY_KEY = "CROSS_BATTLE_BET_NOTIFY_KEY"
def.field("number").m_betEndTimerId = 0
def.field("number").m_betTimesToday = 0
local instance
def.static("=>", CrossBattleBetMgr).Instance = function()
  if instance == nil then
    instance = CrossBattleBetMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CrossBattleBetMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CrossBattleBetMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, CrossBattleBetMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, CrossBattleBetMgr.OnNewDay)
  CrossBattleBetProtocol.Init()
end
def.method("=>", "boolean").ShowBetInfo = function(self)
  if self:CheckBetOpenConditions({toast = true}) == false then
    return false
  end
  require("Main.CrossBattle.Bet.ui.BetInfoPanel").Instance():ShowPanel()
  return true
end
def.method("table", "=>", "boolean").CheckBetOpenConditions = function(self, params)
  params = params or {}
  local _Toast = Toast
  local function Toast(...)
    if params.toast then
      _Toast(...)
    end
  end
  if not CrossBattleInterface.Instance():isCrossBattleOpen() then
    Toast(textRes.CrossBattle[15])
    return false
  end
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  if curStage ~= CrossBattleActivityStage.STAGE_ROUND_ROBIN and curStage ~= CrossBattleActivityStage.STAGE_SELECTION and curStage ~= CrossBattleActivityStage.STAGE_FINAL then
    Toast(textRes.CrossBattle.Bet[1])
    return false
  end
  local activityId = self:GetActivityId()
  local stageName = textRes.CrossBattle.stageStr[curStage]
  local function common_check(moduleid, bet_level_limit)
    if not IsFeatureOpen(moduleid) then
      Toast(textRes.CrossBattle.Bet[16]:format(stageName))
      return false
    end
    local heroProp = GetHeroProp()
    if bet_level_limit > heroProp.level then
      Toast(textRes.CrossBattle.Bet[11]:format(bet_level_limit))
      return false
    end
    return true
  end
  if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    if not crossBattleInterface.isActivityOpen then
      Toast(textRes.CrossBattle[46])
      return false
    end
    local roundRobinBetCfg = CrossBattleBetUtils.GetRoundRobinBetCfg(activityId)
    if common_check(roundRobinBetCfg.moduleid, roundRobinBetCfg.bet_level_limit) == false then
      return false
    end
  elseif curStage == CrossBattleActivityStage.STAGE_SELECTION then
    local selectionBetCfg = CrossBattleBetUtils.GetSelectionBetCfg(activityId)
    if common_check(selectionBetCfg.moduleid, selectionBetCfg.bet_level_limit) == false then
      return false
    end
  elseif curStage == CrossBattleActivityStage.STAGE_FINAL then
    local finalBetCfg = CrossBattleBetUtils.GetFinalBetCfg(activityId)
    if common_check(finalBetCfg.moduleid, finalBetCfg.bet_level_limit) == false then
      return false
    end
  end
  return true
end
def.method("number").SetTodaysBetTimes = function(self, betTimes)
  self.m_betTimesToday = betTimes
end
def.method("=>", "boolean").IsTodayHaveRoundRobinBet = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local roundIndexs = crossBattleInterface:getTodayRoundRobinIndexList()
  print("IsTodayHaveRoundRobinBet #roundIndexs=" .. #roundIndexs)
  return #roundIndexs > 0
end
def.method("number", "function").QueryRoundRobinBetInfo = function(self, roundIndex, callback)
  if roundIndex <= 0 then
    warn(string.format("roundIndex(%d) invalid!", roundIndex))
    _G.SafeCallback(callback, {roundIndex = roundIndex})
  end
  local activityId = self:GetActivityId()
  CrossBattleBetProtocol.CGetRoundRobinRoundBetInfoReq(activityId, roundIndex, function(data)
    if data.ret == 0 then
      _G.SafeCallback(callback, {
        roundIndex = roundIndex,
        betInfos = data.p.betInfos
      })
    else
      warn(string.format("QueryRoundRobinBetInfoError: activityId=%d, roundIndex=%d, ret=%d", activityId, roundIndex, data.ret))
      _G.SafeCallback(callback, {roundIndex = roundIndex})
    end
  end)
end
def.method("function").QueryTodaysRoundRobinBetInfo = function(self, callback)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local roundIndexs = crossBattleInterface:getTodayRoundRobinIndexList()
  if #roundIndexs == 0 then
    warn("no round ongoing")
    _G.SafeCallback(callback, {betInfos = nil})
    return
  end
  local betInfos = {}
  local recived = 0
  local total = #roundIndexs
  for i, roundIndex in ipairs(roundIndexs) do
    self:QueryRoundRobinBetInfo(roundIndex, function(data)
      recived = recived + 1
      if data.betInfos then
        for i, v in ipairs(data.betInfos) do
          table.insert(betInfos, v)
        end
      end
      if recived >= total then
        _G.SafeCallback(callback, {betInfos = betInfos})
      end
    end)
  end
end
def.method("number", "userdata", "number").BetInRoundRobin = function(self, roundIndex, corpsId, sortId)
  local activityId = self:GetActivityId()
  CrossBattleBetProtocol.CBetInRoundRobinReq(activityId, roundIndex, corpsId, sortId)
end
def.method("=>", "number").GetActivityId = function(self)
  return _G.constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
end
def.method("=>", "table").GetRoundRobinHistories = function(self)
  local curTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local todayStartTimestamp = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, 0, 0, 0)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local histories = {}
  for i, v in ipairs(crossBattleCfg.round_robin_time_points) do
    local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(v)
    if timePointCfg then
      local timestamp = AbsoluteTimer.GetServerTimeByDate(timePointCfg.year, timePointCfg.month, timePointCfg.day, timePointCfg.hour, timePointCfg.min, timePointCfg.sec)
      if todayStartTimestamp > timestamp then
        table.insert(histories, {roundIndex = i})
      end
    end
  end
  table.sort(histories, function(l, r)
    return l.roundIndex > r.roundIndex
  end)
  if self:IsTodayHaveRoundRobinBet() then
    local todayHistory = {isToday = true, roundIndex = -1}
    table.insert(histories, 1, todayHistory)
  end
  return histories
end
def.method("number", "=>", "number", "number").GetBetRoundRobinTimeByIndex = function(self, idx)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local id = crossBattleCfg.round_robin_time_points[idx]
  if id == nil then
    return 0, 0
  end
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(id)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local serverTime = AbsoluteTimer.GetServerTimeByDate(timePointCfg.year, timePointCfg.month, timePointCfg.day, timePointCfg.hour, timePointCfg.min, timePointCfg.sec)
  return serverTime - crossBattleCfg.round_robin_stage_prepare_duration_in_minute * 60, serverTime
end
def.method("table", "table", "=>", "boolean").CheckRoundRobinBetConditions = function(self, betInfo, params)
  local _Toast = Toast
  local function Toast(...)
    if params.toast then
      _Toast(...)
    end
  end
  local betMoneyNum = betInfo:GetSelfBetMoneyNum()
  if betMoneyNum ~= -1 then
    Toast(textRes.CrossBattle.Bet.SBetInRoundRobinFail[7])
    return false
  end
  local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
  local fightInfo = betInfo:GetFightInfo()
  local fightState = fightInfo.state
  if fightState == RoundRobinFightInfo.STATE_FIGHTING then
    Toast(textRes.CrossBattle.Bet[13])
    return false
  end
  if fightState ~= RoundRobinFightInfo.STATE_NOT_START then
    Toast(textRes.CrossBattle.Bet.SBetInRoundRobinFail[4])
    return false
  end
  local roundIndx = betInfo:GetRoundIndex()
  local prepareTime, beginTime = self:GetBetRoundRobinTimeByIndex(roundIndx)
  local prepareTimeReal, beginTimeReal = CrossBattleInterface.Instance():getRoundRobinTimeByIndex(roundIndx)
  local curTime = GetServerTime()
  if beginTime < curTime then
    warn(beginTime, beginTimeReal)
    if beginTime == beginTimeReal then
      Toast(textRes.CrossBattle.Bet[13])
    else
      Toast(textRes.CrossBattle.Bet[14])
    end
    return false
  end
  return true
end
def.method("number", "number", "function").QuerySelectionBetInfo = function(self, fightZoneId, stage, callback)
  local activityId = self:GetActivityId()
  CrossBattleBetProtocol.CGetSelectionStageBetInfoReq(activityId, fightZoneId, stage, function(data)
    if data.ret == 0 then
      _G.SafeCallback(callback, {
        fightZoneId = fightZoneId,
        stage = stage,
        betInfos = data.p.betInfos
      })
    else
      warn(string.format("QuerySelectionBetInfoError: activityId=%d, fightZoneId=%d, stage=%d, ret=%d", activityId, fightZoneId, stage, data.ret))
      _G.SafeCallback(callback, {fightZoneId = fightZoneId, stage = stage})
    end
  end)
end
def.method("number", "function").QueryTodaysSelectionBetInfo = function(self, fightZoneId, callback)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local selectionStage = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  if selectionStage == 0 then
    warn("no stage ongoing")
    _G.SafeCallback(callback, {betInfos = nil})
    return
  end
  local selectionStages = {selectionStage}
  local betInfos = {}
  local recived = 0
  local total = #selectionStages
  for i, selectionStage in ipairs(selectionStages) do
    self:QuerySelectionBetInfo(fightZoneId, selectionStage, function(data)
      recived = recived + 1
      if data.betInfos then
        for i, v in ipairs(data.betInfos) do
          table.insert(betInfos, v)
        end
      end
      if recived >= total then
        _G.SafeCallback(callback, {betInfos = betInfos})
      end
    end)
  end
end
def.method("=>", "boolean").IsTodayHaveSelectionBet = function(self)
  local selectionStage = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  return selectionStage ~= 0
end
def.method("number", "number", "number", "userdata", "number").BetInSelection = function(self, fightZoneId, stage, fightIndex, corpsId, sortId)
  local activityId = self:GetActivityId()
  CrossBattleBetProtocol.CBetInSelectionReq(activityId, fightZoneId, stage, fightIndex, corpsId, sortId)
end
def.method("=>", "table").GetSelectionHistories = function(self)
  local activityId = self:GetActivityId()
  local selectionCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(activityId)
  if selectionCfg == nil then
    return {}
  end
  local curTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local todayStartTimestamp = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, 0, 0, 0)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local stages = {}
  for stage, timeId in pairs(selectionCfg.selection_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint then
      local timestamp = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, timePoint.hour, timePoint.min, timePoint.sec)
      if todayStartTimestamp > timestamp then
        table.insert(stages, stage)
      end
    end
  end
  table.sort(stages, function(l, r)
    return r < l
  end)
  local histories = {}
  for i, stage in ipairs(stages) do
    local history = {stage = stage}
    table.insert(histories, history)
  end
  if self:IsTodayHaveSelectionBet() then
    local todayHistory = {
      isToday = true,
      stage = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
    }
    table.insert(histories, 1, todayHistory)
  end
  return histories
end
def.method("table", "table", "=>", "boolean").CheckSelectionBetConditions = function(self, betInfo, params)
  local _Toast = Toast
  local function Toast(...)
    if params.toast then
      _Toast(...)
    end
  end
  local betMoneyNum = betInfo:GetSelfBetMoneyNum()
  if betMoneyNum ~= -1 then
    Toast(textRes.CrossBattle.Bet.SBetInRoundRobinFail[7])
    return false
  end
  local CalFightResult = require("netio.protocol.mzm.gsp.crossbattle.CalFightResult")
  local fightInfo = betInfo:GetFightInfo()
  local cal_fight_result = fightInfo.cal_fight_result
  if cal_fight_result ~= CalFightResult.STATE_NOT_START then
    Toast(textRes.CrossBattle.Bet.SBetInRoundRobinFail[4])
    return false
  end
  local selectionStage = betInfo:GetStage()
  local beginTime = CrossBattleInterface.GetCrossBattleSelectionTimeByStage(selectionStage)
  local curTime = GetServerTime()
  if beginTime < curTime then
    Toast(textRes.CrossBattle.Bet[13])
    return false
  end
  local leftBetTimes = self:GetSelectionLeftBetTimes()
  if leftBetTimes <= 0 then
    Toast(textRes.CrossBattle.Bet[19]:format(self.m_betTimesToday))
    return false
  end
  return true
end
def.method("=>", "number").GetSelectionLeftBetTimes = function(self)
  return constant.CrossBattleConsts.DAILY_BET_TIMES_UPPER_LIMIT - self.m_betTimesToday
end
def.method("number", "function").QueryFinalBetInfo = function(self, stage, callback)
  local activityId = self:GetActivityId()
  CrossBattleBetProtocol.CGetFinalStageBetInfoReq(activityId, stage, function(data)
    if data.ret == 0 then
      _G.SafeCallback(callback, {
        stage = stage,
        betInfos = data.p.betInfos
      })
    else
      warn(string.format("QueryFinalBetInfoError: activityId=%d, stage=%d, ret=%d", activityId, stage, data.ret))
      _G.SafeCallback(callback, {stage = stage})
    end
  end)
end
def.method("function").QueryTodaysFinalBetInfo = function(self, callback)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local finalStages = self:GetTodayFinalBetStages()
  if #finalStages == 0 then
    warn("QueryTodaysFinalBetInfo:no stage ongoing")
    _G.SafeCallback(callback, {betInfos = nil})
    return
  end
  local betInfos = {}
  local recived = 0
  local total = #finalStages
  for i, finalStage in ipairs(finalStages) do
    self:QueryFinalBetInfo(finalStage, function(data)
      recived = recived + 1
      if data.betInfos then
        for i, v in ipairs(data.betInfos) do
          table.insert(betInfos, v)
        end
      end
      if recived >= total then
        _G.SafeCallback(callback, {betInfos = betInfos})
      end
    end)
  end
end
def.method("=>", "boolean").IsTodayHaveFinalBet = function(self)
  local finalStages = self:GetTodayFinalBetStages()
  return #finalStages > 0
end
def.method("number", "number", "userdata", "number").BetInFinal = function(self, stage, fightIndex, corpsId, sortId)
  local activityId = self:GetActivityId()
  CrossBattleBetProtocol.CBetInFinalReq(activityId, stage, fightIndex, corpsId, sortId)
end
def.method("=>", "table").GetFinalHistories = function(self)
  local activityId = self:GetActivityId()
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return {}
  end
  local curTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local todayStartTimestamp = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, 0, 0, 0)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local stages = {}
  for stage, timeId in pairs(finalCfg.final_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint then
      local timestamp = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, timePoint.hour, timePoint.min, timePoint.sec)
      if todayStartTimestamp > timestamp then
        table.insert(stages, stage)
      end
    end
  end
  table.sort(stages, function(l, r)
    return r < l
  end)
  local histories = {}
  for i, stage in ipairs(stages) do
    local history = {stage = stage}
    table.insert(histories, history)
  end
  if self:IsTodayHaveFinalBet() then
    local todayHistory = {isToday = true, stage = -1}
    table.insert(histories, 1, todayHistory)
  end
  return histories
end
def.method("table", "table", "=>", "boolean").CheckFinalBetConditions = function(self, betInfo, params)
  local _Toast = Toast
  local function Toast(...)
    if params.toast then
      _Toast(...)
    end
  end
  local betMoneyNum = betInfo:GetSelfBetMoneyNum()
  if betMoneyNum ~= -1 then
    Toast(textRes.CrossBattle.Bet.SBetInRoundRobinFail[7])
    return false
  end
  local CalFightResult = require("netio.protocol.mzm.gsp.crossbattle.CalFightResult")
  local fightInfo = betInfo:GetFightInfo()
  local cal_fight_result = fightInfo.cal_fight_result
  if cal_fight_result ~= CalFightResult.STATE_NOT_START then
    Toast(textRes.CrossBattle.Bet.SBetInRoundRobinFail[4])
    return false
  end
  local finalStage = betInfo:GetStage()
  local beginTime = self:GetFinalTimeByStage(finalStage)
  local curTime = GetServerTime()
  if beginTime < curTime then
    Toast(textRes.CrossBattle.Bet[13])
    return false
  end
  local leftBetTimes = self:GetFinalLeftBetTimes()
  if leftBetTimes <= 0 then
    Toast(textRes.CrossBattle.Bet[19]:format(self.m_betTimesToday))
    return false
  end
  return true
end
def.method("=>", "boolean").HasBetNotify = function(self)
  if self:CheckBetOpenConditions(nil) == false then
    return false
  end
  if self:HasReadTodaysBetNotify() then
    printInfo("HasReadTodaysBetNotify")
    return false
  end
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    return self:IsRoundRobinBetActive()
  elseif curStage == CrossBattleActivityStage.STAGE_SELECTION then
    return self:IsSelectionBetActive()
  elseif curStage == CrossBattleActivityStage.STAGE_FINAL then
    return self:IsFinalBetActive()
  else
    return false
  end
end
def.method("=>", "boolean").HasReadTodaysBetNotify = function(self)
  local betNotifyKey = CrossBattleBetMgr.BET_NOTIFY_KEY
  if not LuaPlayerPrefs.HasRoleKey(betNotifyKey) then
    return false
  end
  local lastTimestamp = LuaPlayerPrefs.GetRoleNumber(betNotifyKey)
  local curTime = GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local todayStartTimestamp = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, 0, 0, 0)
  if todayStartTimestamp ~= lastTimestamp then
    return false
  end
  return true
end
def.method().MarkTodaysBetNotifyReaded = function(self)
  local betNotifyKey = CrossBattleBetMgr.BET_NOTIFY_KEY
  local curTime = GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local todayStartTimestamp = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, 0, 0, 0)
  LuaPlayerPrefs.SetRoleNumber(betNotifyKey, todayStartTimestamp)
  LuaPlayerPrefs.Save()
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
end
def.method("=>", "boolean").IsRoundRobinBetActive = function(self)
  if not self:IsTodayHaveRoundRobinBet() then
    return false
  end
  local crossBattleInterface = CrossBattleInterface.Instance()
  local roundIndexs = crossBattleInterface:getTodayRoundRobinIndexList()
  local lastRoundIndex = roundIndexs[#roundIndexs]
  local _, beginTime = self:GetBetRoundRobinTimeByIndex(lastRoundIndex)
  local curTime = GetServerTime()
  if beginTime <= curTime then
    return false
  end
  if self.m_betEndTimerId == 0 then
    local leftSeconds = beginTime - curTime
    self.m_betEndTimerId = AbsoluteTimer.AddListener(0, 0, function()
      Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
      self.m_betEndTimerId = 0
    end, nil, leftSeconds)
  end
  return true
end
def.method("=>", "boolean").IsSelectionBetActive = function(self)
  if not self:IsTodayHaveSelectionBet() then
    return false
  end
  local selectionStage = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  local beginTime = CrossBattleInterface.GetCrossBattleSelectionTimeByStage(selectionStage)
  local curTime = GetServerTime()
  if beginTime <= curTime then
    return false
  end
  if self.m_betEndTimerId == 0 then
    local leftSeconds = beginTime - curTime
    self.m_betEndTimerId = AbsoluteTimer.AddListener(0, 0, function()
      Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
      self.m_betEndTimerId = 0
    end, nil, leftSeconds)
  end
  return true
end
def.method("=>", "boolean").IsFinalBetActive = function(self)
  if not self:IsTodayHaveFinalBet() then
    return false
  end
  local finalStages = self:GetTodayFinalBetStages()
  local lastFinalStage = finalStages[#finalStages]
  local beginTime = self:GetFinalTimeByStage(lastFinalStage)
  local curTime = GetServerTime()
  if beginTime <= curTime then
    return false
  end
  if self.m_betEndTimerId == 0 then
    local leftSeconds = beginTime - curTime
    self.m_betEndTimerId = AbsoluteTimer.AddListener(0, 0, function()
      Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
      self.m_betEndTimerId = 0
    end, nil, leftSeconds)
  end
  return true
end
def.method("=>", "table").GetTodayFinalBetStages = function(self)
  local activityId = self:GetActivityId()
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return {}
  end
  local curTime = _G.GetServerTime()
  local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local stages = {}
  for stage, timeId in pairs(finalCfg.final_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint and curTimeTable.year == timePoint.year and curTimeTable.month == timePoint.month and curTimeTable.day == timePoint.day then
      table.insert(stages, stage)
    end
  end
  table.sort(stages, function(l, r)
    return l < r
  end)
  return stages
end
def.method("number", "=>", "number").GetFinalTimeByStage = function(self, stage)
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return 0
  end
  local timePointCfgId = finalCfg.final_stage_time[stage]
  if timePointCfgId == nil then
    return 0
  end
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timePointCfgId)
  if timePoint == nil then
    return 0
  end
  local t = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, timePoint.hour, timePoint.min, timePoint.sec)
  return t
end
def.method("=>", "number").GetFinalLeftBetTimes = function(self)
  return constant.CrossBattleConsts.DAILY_BET_TIMES_UPPER_LIMIT - self.m_betTimesToday
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  local self = instance
  if self.m_betEndTimerId ~= 0 then
    AbsoluteTimer.RemoveListener(self.m_betEndTimerId)
    self.m_betEndTimerId = 0
  end
  self.m_betTimesToday = 0
end
def.static("table", "table").OnNewDay = function(params, context)
  local self = instance
  self.m_betTimesToday = 0
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  if instance:CheckBetOpenConditions(nil) == false then
    return
  end
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    local roundRobinBetCfg = CrossBattleBetUtils.GetRoundRobinBetCfg(activityId)
    if p1.feature == roundRobinBetCfg.moduleid then
      Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
    end
  elseif curStage ~= CrossBattleActivityStage.STAGE_SELECTION then
    local selectionBetCfg = CrossBattleBetUtils.GetSelectionBetCfg(activityId)
    if p1.feature == selectionBetCfg.moduleid then
      Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
    end
  elseif curStage ~= CrossBattleActivityStage.STAGE_FINAL then
    local finalBetCfg = CrossBattleBetUtils.GetFinalBetCfg(activityId)
    if p1.feature == finalBetCfg.moduleid then
      Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, nil)
    end
  end
end
return CrossBattleBetMgr.Commit()
