local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CrossBattleModule = Lplus.Extend(ModuleBase, "CrossBattleModule")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local crossBattleInterface = CrossBattleInterface.Instance()
local ActivityInterface = require("Main.activity.ActivityInterface")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local RoundRobinRoundStage = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinRoundStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local PointsRaceMgr = require("Main.CrossBattle.PointsRace.PointsRaceMgr")
local def = CrossBattleModule.define
local instance
def.field("table").applyNoticeTimerId = nil
def.field("boolean").isReadyDone = false
def.static("=>", CrossBattleModule).Instance = function()
  if instance == nil then
    instance = CrossBattleModule()
    instance.m_moduleId = ModuleId.CROSS_BATTLE
  end
  return instance
end
def.override().Init = function(self)
  PointsRaceMgr.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynCrossBattleCurrentActivityCfgid", CrossBattleModule.OnSSynCrossBattleCurrentActivityCfgid)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynRoleCrossBattleOwnInfo", CrossBattleModule.OnSSynRoleCrossBattleOwnInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynCrossBattleRoundRobinIdipRestartInfo", CrossBattleModule.OnSSynCrossBattleRoundRobinIdipRestartInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleOwnLoginProcessDone", CrossBattleModule.OnSCrossBattleOwnLoginProcessDone)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SRegisterInCrossBattleSuccess", CrossBattleModule.OnSRegisterInCrossBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SRegisterInCrossBattleFail", CrossBattleModule.OnSRegisterInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SUnregisterInCrossBattleSuccess", CrossBattleModule.OnSUnregisterInCrossBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SUnregisterInCrossBattleFail", CrossBattleModule.OnSUnregisterInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRegisterInfoInCrossBattleSuccess", CrossBattleModule.OnSGetRegisterInfoInCrossBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRegisterInfoInCrossBattleFail", CrossBattleModule.OnSGetRegisterInfoInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleVoteRankSuccess", CrossBattleModule.OnSGetCrossBattleVoteRankSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleVoteRankFail", CrossBattleModule.OnSGetCrossBattleVoteRankFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SVoteInCrossBattleSuccess", CrossBattleModule.OnSVoteInCrossBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SVoteInCrossBattleFail", CrossBattleModule.OnSVoteInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCanvassInCrossBattleFail", CrossBattleModule.OnSCanvassInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynVoteStageResultInCrossBattle", CrossBattleModule.OnSSynVoteStageResultInCrossBattle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynRoundRobinRoundInfoInCrossBattle", CrossBattleModule.OnSSynRoundRobinRoundInfoInCrossBattle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SEnterRoundRobinMapFail", CrossBattleModule.OnSEnterRoundRobinMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SLeaveRoundRobinMapFail", CrossBattleModule.OnSLeaveRoundRobinMapFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRegisterRoleListSuccess", CrossBattleModule.OnSGetRegisterRoleListSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRegisterRoleListFail", CrossBattleModule.OnSGetRegisterRoleListFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoundRobinRoundInfoInCrossBattleSuccess", CrossBattleModule.OnSGetRoundRobinRoundInfoInCrossBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoundRobinRoundInfoInCrossBattleFail", CrossBattleModule.OnSGetRoundRobinRoundInfoInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoundRobinPointInfoInCrossBattleSuccess", CrossBattleModule.OnSGetRoundRobinPointInfoInCrossBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoundRobinPointInfoInCrossBattleFail", CrossBattleModule.OnSGetRoundRobinPointInfoInCrossBattleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynRoundRobinRoundFightResultInCrossBattle", CrossBattleModule.OnSSynRoundRobinRoundFightResultInCrossBattle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynRoundRobinResultInCrossBattle", CrossBattleModule.OnSSynRoundRobinResultInCrossBattle)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SWatchRoundRobinFightFail", CrossBattleModule.OnSWatchRoundRobinFightFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SWatchRoundRobinFightRecordFail", CrossBattleModule.OnSWatchRoundRobinFightRecordFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SRoundRobinTitle", CrossBattleModule.OnSRoundRobinTitle)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, CrossBattleModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, CrossBattleModule.OnNewDay)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, CrossBattleModule.OnActivityToDo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CrossBattleModule.OnNpcNomalServer)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Stage_Click, CrossBattleModule.OnCrossBattleStageClick)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Vote_Link, CrossBattleModule.OnCrossBattleVoteLink)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, CrossBattleModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, CrossBattleModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, CrossBattleModule.OnMapChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CrossBattleModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CrossBattleModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, CrossBattleModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsChange, CrossBattleModule.OnCorpsChang)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, CrossBattleModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Refresh_Red_Point, CrossBattleModule.OnRefrshRedPoint)
  require("Main.CrossBattle.Selection.mgr.CrossBattleSelectionMgr").Instance():Init()
  require("Main.CrossBattle.Bet.CrossBattleBetMgr").Instance():Init()
  require("Main.CrossBattle.WatchGameMgr").Instance():Init()
  require("Main.CrossBattle.History.HistoryMgr").Instance():Init()
  require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr").Instance():Init()
  ModuleBase.Init(self)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_REGISTER, CrossBattleModule.OnCrossBattleRegisterIsOpend)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_VOTE, CrossBattleModule.OnCrossBattleVoteIsOpend)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_ROUND_ROBIN, CrossBattleModule.OnCrossBattleRoundRobinIsOpend)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_ZONE_DIVIDE, CrossBattleModule.OnCrossBattleDrawIsOpend)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_ZONE_POINT, CrossBattleModule.OnCrossBattlePointsRaceIsOpend)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_SELECTION, CrossBattleModule.OnCrossBattleSelectionIsOpend)
  crossBattleInterface:registerCrossBattleStageOpenFn(CrossBattleActivityStage.STAGE_FINAL, CrossBattleModule.OnCrossBattleFinalIsOpend)
  CorpsInterface.RegisterKickHandler(CrossBattleModule.OnKickHandler)
  CorpsInterface.RegisterQuitHandler(CrossBattleModule.OnQuitHandler)
  CorpsInterface.RegisterInviteHandler(CrossBattleModule.OnInviteHandler)
end
def.static("string", "=>", "string").OnKickHandler = function(str)
  if crossBattleInterface:isCrossBattleOpen() and crossBattleInterface:isApplyCrossBattle() then
    local curStage = crossBattleInterface:getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_REGISTER then
      return textRes.CrossBattle[59]
    elseif curStage == CrossBattleActivityStage.STAGE_VOTE then
      return textRes.CrossBattle[61]
    elseif curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
      if crossBattleInterface:canAttendRoundRobin() then
        return textRes.CrossBattle[61]
      end
    elseif curStage == CrossBattleActivityStage.STAGE_ZONE_DIVIDE then
      return textRes.CrossBattle[61]
    elseif curStage == CrossBattleActivityStage.STAGE_ZONE_POINT then
      local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
      if PointsRaceData.Instance():GetPromoted() then
        return textRes.CrossBattle[61]
      end
    end
    local CrossBattleSelectionData = require("Main.CrossBattle.Selection.data.CrossBattleSelectionData")
    local CrossBattleFinalData = require("Main.CrossBattle.Final.data.CrossBattleFinalData")
    if CrossBattleSelectionData.Instance():CanAttendSelection() then
      return textRes.CrossBattle[61]
    elseif CrossBattleFinalData.Instance():CanAttendFinal() then
      return textRes.CrossBattle[61]
    end
  end
  return str
end
def.static("string", "=>", "string").OnQuitHandler = function(str)
  if crossBattleInterface:isCrossBattleOpen() and crossBattleInterface:isApplyCrossBattle() then
    local curStage = crossBattleInterface:getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_REGISTER then
      return textRes.CrossBattle[60]
    elseif curStage == CrossBattleActivityStage.STAGE_VOTE then
      return textRes.CrossBattle[62]
    elseif curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
      if crossBattleInterface:canAttendRoundRobin() then
        return textRes.CrossBattle[62]
      end
    elseif curStage == CrossBattleActivityStage.STAGE_ZONE_DIVIDE then
      return textRes.CrossBattle[62]
    elseif curStage == CrossBattleActivityStage.STAGE_ZONE_POINT then
      local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
      if PointsRaceData.Instance():GetPromoted() then
        return textRes.CrossBattle[62]
      end
    end
    local CrossBattleSelectionData = require("Main.CrossBattle.Selection.data.CrossBattleSelectionData")
    local CrossBattleFinalData = require("Main.CrossBattle.Final.data.CrossBattleFinalData")
    if CrossBattleSelectionData.Instance():CanAttendSelection() then
      return textRes.CrossBattle[62]
    elseif CrossBattleFinalData.Instance():CanAttendFinal() then
      return textRes.CrossBattle[62]
    end
  end
  return str
end
def.static("userdata", "function").OnInviteHandler = function(roldId, handle)
  if crossBattleInterface:isCrossBattleOpen() and crossBattleInterface:isApplyCrossBattle() then
    local function registerRoleListRq()
      local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
      if myCorpsInfo and myCorpsInfo.corpsId then
        local myCorpsId = myCorpsInfo.corpsId
        local function callback(roleList)
          for i, v in ipairs(roleList) do
            if roldId:eq(v) then
              handle(true)
              return
            end
          end
          local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
          local function confirmCallback(id)
            if id == 1 then
              handle(true)
            else
              handle(false)
            end
          end
          CommonConfirmDlg.ShowConfirm("", textRes.CrossBattle[63], confirmCallback, nil)
        end
        crossBattleInterface:getCorpsRegisterRoleList(myCorpsId, callback)
      else
        handle(true)
      end
    end
    local curStage = crossBattleInterface:getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_REGISTER then
      handle(true)
      return
    elseif curStage == CrossBattleActivityStage.STAGE_VOTE then
      registerRoleListRq()
      return
    elseif curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
      if crossBattleInterface:canAttendRoundRobin() then
        registerRoleListRq()
        return
      end
    elseif curStage == CrossBattleActivityStage.STAGE_ZONE_DIVIDE then
      registerRoleListRq()
      return
    elseif curStage == CrossBattleActivityStage.STAGE_ZONE_POINT then
      local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
      if PointsRaceData.Instance():GetPromoted() then
        registerRoleListRq()
        return
      end
    end
    local CrossBattleSelectionData = require("Main.CrossBattle.Selection.data.CrossBattleSelectionData")
    local CrossBattleFinalData = require("Main.CrossBattle.Final.data.CrossBattleFinalData")
    if CrossBattleSelectionData.Instance():CanAttendSelection() then
      registerRoleListRq()
      return
    elseif CrossBattleFinalData.Instance():CanAttendFinal() then
      registerRoleListRq()
      return
    end
  end
  handle(true)
end
def.override().OnReset = function(self)
  if self.applyNoticeTimerId then
    for i, v in ipairs(instance.applyNoticeTimerId) do
      AbsoluteTimer.RemoveListener(v)
    end
    instance.applyNoticeTimerId = nil
  end
  self.isReadyDone = false
  crossBattleInterface:Reset()
end
def.method("number", "userdata", "userdata", "userdata").watchRoundRobinFight = function(self, idx, corpsIdA, corpsIdB, watchCorpsId)
  local p = require("netio.protocol.mzm.gsp.crossbattle.CWatchRoundRobinFightReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, idx, corpsIdA, corpsIdB, watchCorpsId)
  gmodule.network.sendProtocol(p)
  warn("------send CWatchRoundRobinFightReq", idx, corpsIdA, corpsIdB, watchCorpsId)
end
def.method("number", "userdata", "userdata").watchRoundRobinFightRecord = function(self, idx, corpsIdA, corpsIdB)
  local p = require("netio.protocol.mzm.gsp.crossbattle.CWatchRoundRobinFightRecordReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, idx, corpsIdA, corpsIdB)
  gmodule.network.sendProtocol(p)
  warn("------send CWatchRoundRobinFightRecordReq", idx, corpsIdA, corpsIdB)
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  if ActivityInterface.Instance():isActivityOpend2(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID) then
    CrossBattleModule.SetCrossBattleApplyTimer()
  end
  crossBattleInterface:setCrossBattleActivityRedPoint()
end
def.static("table", "table").OnRefrshRedPoint = function(p1, p2)
  crossBattleInterface:setCrossBattleActivityRedPoint()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  local CrossBattleRoundRobinReadyPanel = require("Main.CrossBattle.ui.CrossBattleRoundRobinReadyPanel")
  if CrossBattleRoundRobinReadyPanel.Instance():IsShow() then
    CrossBattleRoundRobinReadyPanel.Instance():Hide()
  end
end
def.static("table", "table").OnNewDay = function()
  CrossBattleModule.SetCrossBattleApplyTimer()
  crossBattleInterface.vote_times = 0
  crossBattleInterface:setCrossBattleVoteRedPoint()
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID then
    local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
    local serverLevel = serverLevelData.level
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    crossBattleInterface.isActivityOpen = serverLevel >= crossBattleCfg.serverlevel
    warn("-----crobattle start:", crossBattleInterface.isActivityOpen)
    if crossBattleInterface.isActivityOpen then
      CrossBattleModule.SetCrossBattleApplyTimer()
    end
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
end
def.static("table", "table").OnCorpsChang = function(p1, p2)
  warn("------OnCorpsChang-----")
  if not ActivityInterface.Instance():isActivityOpend2(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID) then
    return
  end
  if CorpsInterface.HasCorps() then
    local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
    if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
      crossBattleInterface.isApply = false
      return
    end
    local myCorpsId = myCorpsInfo.corpsId
    local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRegisterInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, myCorpsId)
    gmodule.network.sendProtocol(p)
    warn("-------CGetRegisterInfoInCrossBattleReq:", myCorpsId)
  else
    crossBattleInterface.isApply = false
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(activityId)
  if _G.IsFeatureOpen(crossBattleCfg.moduleid) then
    ActivityInterface.Instance():removeCustomCloseActivity(activityId)
  else
    ActivityInterface.Instance():addCustomCloseActivity(activityId)
  end
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  if curStage == CrossBattleActivityStage.STAGE_VOTE then
    crossBattleInterface:setCrossBattleVoteRedPoint()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(activityId)
  if p1.feature == crossBattleCfg.moduleid then
    if _G.IsFeatureOpen(crossBattleCfg.moduleid) then
      ActivityInterface.Instance():removeCustomCloseActivity(activityId)
    else
      ActivityInterface.Instance():addCustomCloseActivity(activityId)
    end
    crossBattleInterface:setCrossBattleActivityRedPoint()
  elseif p1.feature == crossBattleCfg.vote_stage_moduleid then
    crossBattleInterface:setCrossBattleVoteRedPoint()
  end
end
def.static("number", "=>", "boolean").OnCrossBattleRegisterIsOpend = function(stage)
  return crossBattleInterface.isActivityOpen and not crossBattleInterface:isApplyCrossBattle()
end
def.static("number", "=>", "boolean").OnCrossBattleVoteIsOpend = function(stage)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local leftVoteTimes = crossBattleInterface:getLeftVoteTimes()
  return crossBattleInterface.isActivityOpen and crossBattleInterface:isAchieveVoteLevel() and leftVoteTimes > 0
end
def.static("number", "=>", "boolean").OnCrossBattleRoundRobinIsOpend = function(stage)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  return crossBattleInterface.isActivityOpen and curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN and crossBattleInterface:canEnterRoundRobinMap()
end
def.static("number", "=>", "boolean").OnCrossBattleDrawIsOpend = function(stage)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  return crossBattleInterface.isActivityOpen and curStage == CrossBattleActivityStage.STAGE_ZONE_DIVIDE and require("Main.CrossBattle.PointsRace.PointsRaceUtils").CanDraw(false)
end
def.static("number", "=>", "boolean").OnCrossBattlePointsRaceIsOpend = function(stage)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  return crossBattleInterface.isActivityOpen and curStage == CrossBattleActivityStage.STAGE_ZONE_POINT and require("Main.CrossBattle.PointsRace.PointsRaceUtils").CanRace(false)
end
def.static("number", "=>", "boolean").OnCrossBattleSelectionIsOpend = function(stage)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local CrossBattleSelectionMgr = require("Main.CrossBattle.Selection.mgr.CrossBattleSelectionMgr")
  return crossBattleInterface.isActivityOpen and curStage == CrossBattleActivityStage.STAGE_SELECTION and CrossBattleSelectionMgr.Instance():IsCrossBattleSelectionPrepareTime()
end
def.static("number", "=>", "boolean").OnCrossBattleFinalIsOpend = function(stage)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
  return crossBattleInterface.isActivityOpen and curStage == CrossBattleActivityStage.STAGE_FINAL and CrossBattleFinalMgr.Instance():IsCrossBattleFinalPrepareTime()
end
def.static("table", "table").OnCrossBattleStageClick = function(p1, p2)
  local stage = p1[1]
  local isOpen, openId = crossBattleInterface:isOpenCrossBattleStage(stage)
  if not isOpen then
    local str = textRes.CrossBattle.openStr[openId]
    if str then
      Toast(str)
    else
      Toast(textRes.CrossBattle[39])
    end
    return
  end
  if stage == CrossBattleActivityStage.STAGE_REGISTER then
    local curStage = crossBattleInterface:getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_REGISTER then
      if crossBattleInterface:isApplyCrossBattle() then
        if not CorpsInterface.IsCorpsLeader() then
          Toast(textRes.CrossBattle[22])
          return
        end
        local callback = function(id)
          if id == 1 then
            local p = require("netio.protocol.mzm.gsp.crossbattle.CUnregisterInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
            gmodule.network.sendProtocol(p)
            warn("--------CUnregisterInCrossBattleReq:")
          end
        end
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm("", textRes.CrossBattle[21], callback, nil)
      else
        local CrossBattleApplyPanel = require("Main.CrossBattle.ui.CrossBattleApplyPanel")
        CrossBattleApplyPanel.Instance():ShowPanel()
      end
    else
      Toast(textRes.CrossBattle[17])
    end
  elseif stage == CrossBattleActivityStage.STAGE_VOTE then
    local curStage = crossBattleInterface:getCurCrossBattleStage()
    if curStage >= CrossBattleActivityStage.STAGE_VOTE then
      local CrossBattleVotePanel = require("Main.CrossBattle.ui.CrossBattleVotePanel")
      CrossBattleVotePanel.Instance():ShowPanel()
    else
      local openTime, _ = CrossBattleInterface.Instance():getCrossBattleStageTime(stage)
      if openTime > 0 then
        local nYear = tonumber(os.date("%Y", openTime))
        local nMonth = tonumber(os.date("%m", openTime))
        local nDay = tonumber(os.date("%d", openTime))
        local nHour = tonumber(os.date("%H", openTime))
        local nMin = tonumber(os.date("%M", openTime))
        local nSec = tonumber(os.date("%S", openTime))
        Toast(string.format(textRes.CrossBattle[4], textRes.CrossBattle.stageStr[stage], nYear, nMonth, nDay, nHour, nMin))
      end
    end
  elseif stage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    local curStage = crossBattleInterface:getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN and (crossBattleInterface.roundRobinPointRankList == nil or #crossBattleInterface.roundRobinPointRankList == 0) then
      Toast(textRes.CrossBattle[50])
      return
    end
    if CrossBattleModule.OnCrossBattleRoundRobinIsOpend(stage) then
      local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
      if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
        warn("-----roundRobin click myCorpsId is nil")
        local CrossBattleRoundRobinPanel = require("Main.CrossBattle.ui.CrossBattleRoundRobinPanel")
        CrossBattleRoundRobinPanel.Instance():ShowPanel({})
        return
      end
      local myCorpsId = myCorpsInfo.corpsId
      local callback = function(roleList)
        local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
        if CrossBattlePanel.Instance():IsShow() then
          CrossBattlePanel.Instance():Hide()
        end
        local CrossBattleRoundRobinPanel = require("Main.CrossBattle.ui.CrossBattleRoundRobinPanel")
        CrossBattleRoundRobinPanel.Instance():ShowPanel(roleList)
      end
      crossBattleInterface:getCorpsRegisterRoleList(myCorpsId, callback)
      return
    end
    local idx = crossBattleInterface.roundRobinRoundIdx
    if idx <= 0 then
      idx = 1
    end
    local readyTime, startTime = crossBattleInterface:getRoundRobinTimeByIndex(idx)
    local curTime = _G.GetServerTime()
    if startTime <= curTime then
      local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
      if idx < #crossBattleCfg.round_robin_time_points then
        idx = idx + 1
        readyTime, startTime = crossBattleInterface:getRoundRobinTimeByIndex(idx)
      end
    end
    if readyTime > curTime then
      local nYear = tonumber(os.date("%Y", readyTime))
      local nMonth = tonumber(os.date("%m", readyTime))
      local nDay = tonumber(os.date("%d", readyTime))
      local nHour = tonumber(os.date("%H", readyTime))
      local nMin = tonumber(os.date("%M", readyTime))
      local nSec = tonumber(os.date("%S", readyTime))
      Toast(string.format(textRes.CrossBattle[47], textRes.CrossBattle.roundRobinTabName[idx], nYear, nMonth, nDay, nHour, nMin))
      return
    elseif curTime >= startTime then
      Toast(textRes.CrossBattle[41])
      return
    else
      Toast(textRes.CrossBattle[50])
    end
  end
end
def.static().SetCrossBattleApplyTimer = function()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  if curStage == CrossBattleActivityStage.STAGE_REGISTER and crossBattleInterface.isActivityOpen then
    local nowTime = _G.GetServerTime()
    local nYear = tonumber(os.date("%Y", nowTime))
    local nMonth = tonumber(os.date("%m", nowTime))
    local nDay = tonumber(os.date("%d", nowTime))
    local nHour = tonumber(os.date("%H", nowTime))
    local nMin = tonumber(os.date("%M", nowTime))
    if instance.applyNoticeTimerId then
      for i, v in ipairs(instance.applyNoticeTimerId) do
        AbsoluteTimer.RemoveListener(v)
      end
      instance.applyNoticeTimerId = nil
    end
    local timerIds = {}
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    for i, v in ipairs(crossBattleCfg.register_stage_remind_time_points) do
      if nHour < v then
        local timerId = AbsoluteTimer.AddServerTimeEvent(nYear, nMonth, nDay, v, 0, 1, 0, CrossBattleModule.OnApplyNotice, {})
        table.insert(timerIds, timerId)
      end
    end
    instance.applyNoticeTimerId = timerIds
  end
end
def.method("boolean").SetCrossBattleSelectionState = function(self, set)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
    if set then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.CROSS_BATTLE)
    else
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.CROSS_BATTLE)
    end
  end
end
def.static("table").OnApplyNotice = function(p)
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  warn("---------OnApplyNotice:", curStage)
  if curStage == CrossBattleActivityStage.STAGE_REGISTER then
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(activityId)
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    local content = string.format(crossBattleCfg.register_stage_remind_content, activityCfg.activityName)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
    local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
    InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(content, 0, "Group_3")
  end
end
def.static("table", "table").OnActivityToDo = function(p1, p2)
  local activityId = p1[1]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(activityId)
  if activityId == constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID then
    if crossBattleInterface:isCrossBattleOpen() then
      local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
      CrossBattlePanel.Instance():ShowPanel()
    else
      Toast(textRes.CrossBattle[14])
    end
  end
end
def.static("table", "table").OnNpcNomalServer = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if crossBattleCfg then
    if npcId == crossBattleCfg.npc_id and serviceId == crossBattleCfg.npc_service_id then
      local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
      CrossBattlePanel.Instance():ShowPanel()
    elseif npcId == crossBattleCfg.round_robin_out_npc_id and serviceId == crossBattleCfg.round_robin_out_npc_service_id then
      local callback = function(id)
        if id == 1 then
          local p = require("netio.protocol.mzm.gsp.crossbattle.CLeaveRoundRobinMapReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
          gmodule.network.sendProtocol(p)
          warn("--------CUnregisterInCrossBattleReq:")
        end
      end
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", textRes.CrossBattle[32], callback, nil)
    end
  end
end
def.static("table", "table").OnCrossBattleVoteLink = function(p1, p2)
  local corpsId = p1[1]
  if corpsId then
    warn("-------OnCrossBattleVoteLink:", corpsId)
    if ActivityInterface.Instance():isActivityOpend2(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID) then
      local CrossBattleVotePanel = require("Main.CrossBattle.ui.CrossBattleVotePanel")
      CrossBattleVotePanel.Instance():ShowPanelByCorpsId(corpsId)
    else
      Toast(textRes.CrossBattle[14])
    end
  end
end
def.static("table", "table").OnMapChange = function(p1, p2)
  local mapId = p1[1]
  local oldMapId = p1[2]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  warn("---------mapId:", mapId == crossBattleCfg.round_robin_map_cfg_id, crossBattleCfg.round_robin_map_cfg_id)
  if mapId == crossBattleCfg.round_robin_map_cfg_id then
    if not instance.isReadyDone then
      warn("!!!!!!!!!!CrossBattle not ready done")
      return
    end
    if _G.PlayerIsInFight() then
      warn("------------crossBattle is in fight")
      return
    end
    local curIndex = crossBattleInterface:getCurRoundRobinIndex()
    local fightInfo = crossBattleInterface:getRoundRobinFightInfo(curIndex)
    if fightInfo then
    else
      local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinRoundInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, curIndex)
      gmodule.network.sendProtocol(p)
      warn("--------CGetRoundRobinRoundInfoInCrossBattleReq:", curIndex)
    end
    local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
    if CrossBattlePanel.Instance():IsShow() then
      CrossBattlePanel.Instance():Hide()
    end
    local CrossBattleRoundRobinReadyPanel = require("Main.CrossBattle.ui.CrossBattleRoundRobinReadyPanel")
    CrossBattleRoundRobinReadyPanel.Instance():ShowPanel()
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Enter_Game_Scene, nil)
    instance:SetCrossBattleSelectionState(true)
  elseif oldMapId == crossBattleCfg.round_robin_map_cfg_id then
    local CrossBattleRoundRobinReadyPanel = require("Main.CrossBattle.ui.CrossBattleRoundRobinReadyPanel")
    if CrossBattleRoundRobinReadyPanel.Instance():IsShow() then
      CrossBattleRoundRobinReadyPanel.Instance():Hide()
      instance:SetCrossBattleSelectionState(false)
    end
  end
end
def.static("table").OnSSynCrossBattleCurrentActivityCfgid = function(p)
  warn("-------OnSSynCrossBattleCurrentActivityCfgid:", p.activity_cfg_id)
  constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID = p.activity_cfg_id
  local durationCfg = CrossBattleInterface.GetCrossBattleStageDurationCfg(p.activity_cfg_id)
  if durationCfg == nil then
    return
  end
  constant.CrossBattleConsts.REGISTER_STAGE_DURATION_IN_DAY = durationCfg.registerStageDurationInDay
  constant.CrossBattleConsts.VOTE_STAGE_DURATION_IN_DAY = durationCfg.voteStageDurationInDay
  constant.CrossBattleConsts.ROUND_ROBIN_STAGE_DURATION_IN_DAY = durationCfg.roundRobinStageDurationInDay
  constant.CrossBattleConsts.ZONE_DIVIDE_STAGE_DURATION_IN_DAY = durationCfg.zoneDivideStageDurationInDay
  constant.CrossBattleConsts.ZONE_POINT_STAGE_DURATION_IN_DAY = durationCfg.zonePointStageDurationInDay
  constant.CrossBattleConsts.ROUND_SELECTION_STAGE_DURATION_IN_DAY = durationCfg.roundSelectionStageDurationInDay
  constant.CrossBattleConsts.ROUND_FINAL_STAGE_DURATION_IN_DAY = durationCfg.roundFinalStageDurationInDay
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return
  end
  if finalCfg.final_need_team_num == 16 then
    textRes.CrossBattle.CrossBattleFinal.BattleType = {}
    for k, v in pairs(textRes.CrossBattle.CrossBattleFinal.BattleType16) do
      textRes.CrossBattle.CrossBattleFinal.BattleType[k] = v
    end
  elseif finalCfg.final_need_team_num == 32 then
    textRes.CrossBattle.CrossBattleFinal.BattleType = {}
    for k, v in pairs(textRes.CrossBattle.CrossBattleFinal.BattleType32) do
      textRes.CrossBattle.CrossBattleFinal.BattleType[k] = v
    end
  end
end
def.static("table").OnSSynRoleCrossBattleOwnInfo = function(p)
  warn("--------OnSSynRoleCrossBattleOwnInfo:", p.round_robin_round_index, p.round_robin_round_stage, p.stage)
  crossBattleInterface.isActivityOpen = p.stage ~= CrossBattleActivityStage.STAGE_CLOSE
  crossBattleInterface.isApply = p.register_info ~= 0
  crossBattleInterface.vote_times = p.vote_times
  crossBattleInterface.voteDirectPromotionCorpsList = p.vote_stage_direct_promotion_corps_list
  crossBattleInterface.roundRobinPointRankList = p.round_robin_point_rank_list
  crossBattleInterface.roundRobinRoundIdx = p.round_robin_round_index
  crossBattleInterface.roundRobinRoundStage = p.round_robin_round_stage
  crossBattleInterface.roundRobinStagePromotionCorpsList = p.round_robin_stage_promotion_corps_list
  crossBattleInterface.canvass_timestamp = p.canvass_timestamp
  crossBattleInterface:setCrossBattleActivityRedPoint()
end
def.static("table").OnSSynCrossBattleRoundRobinIdipRestartInfo = function(p)
  warn("--------OnSSynCrossBattleRoundRobinIdipRestartInfo:", p.round_index, p.timestamp)
  crossBattleInterface.restartIndex = p.round_index
  crossBattleInterface.restartTime = p.timestamp
end
def.static("table").OnSCrossBattleOwnLoginProcessDone = function(p)
  warn("----------OnSCrossBattleOwnLoginProcessDone")
  instance.isReadyDone = true
  local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
  CrossBattleModule.OnMapChange({curMapId}, {})
end
def.static("table").OnSRegisterInCrossBattleSuccess = function(p)
  warn("--------------OnSRegisterInCrossBattleSuccess")
  crossBattleInterface.isApply = true
  if CorpsInterface.IsCorpsLeader() then
    local costType, costNum, ownNum = crossBattleInterface:getCrossBattleApplyCostInfo()
    Toast(string.format(textRes.CrossBattle[56], costNum, textRes.CrossBattle.costTypeStr[costType]))
  else
    Toast(textRes.CrossBattle[18])
  end
  local effectCfg = GetEffectRes(constant.CrossBattleConsts.REGISTER_SUCCESS_EFFECT_ID)
  require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "crossbattleRegisterEffect", 0, 0, -1, false)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Apply_SUCCESS, nil)
end
def.static("table").OnSRegisterInCrossBattleFail = function(p)
  warn("--------OnSRegisterInCrossBattleFail:", p.res)
end
def.static("table").OnSUnregisterInCrossBattleSuccess = function(p)
  warn("------OnSUnregisterInCrossBattleSuccess:")
  crossBattleInterface.isApply = false
  Toast(textRes.CrossBattle[19])
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Cancel_Apply_SUCCESS, nil)
end
def.static("table").OnSUnregisterInCrossBattleFail = function(p)
  warn("-----OnSUnregisterInCrossBattleFail:", p.res)
end
def.static("table").OnSGetRegisterInfoInCrossBattleSuccess = function(p)
  warn("-------OnSGetRegisterInfoInCrossBattleSuccess:", p.corps_id, p.register_info)
  local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
  if myCorpsInfo and myCorpsInfo.corpsId then
    local myCorpsId = myCorpsInfo.corpsId
    if p.corps_id:eq(myCorpsId) then
      crossBattleInterface.isApply = p.register_info ~= 0
    end
  end
end
def.static("table").OnSGetRegisterInfoInCrossBattleFail = function(p)
  warn("-----OnSGetRegisterInfoInCrossBattleFail:", p.res)
end
def.static("table").OnSGetCrossBattleVoteRankSuccess = function(p)
  warn("-------OnSGetCrossBattleVoteRankSuccess:", #p.rankList)
  if #p.rankList == 0 then
    if crossBattleInterface.crossBattleRankList == nil then
      crossBattleInterface.crossBattleRankList = p.rankList
    end
    return
  end
  crossBattleInterface.myRankInfo = p.myrank
  crossBattleInterface.crossBattleRankList = p.rankList
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Rank_Info_Change, nil)
end
def.static("table").OnSGetCrossBattleVoteRankFail = function(p)
  warn("--------OnSGetCrossBattleVoteRankFail:", p.res)
end
def.static("table").OnSVoteInCrossBattleSuccess = function(p)
  warn("-------OnSVoteInCrossBattleSuccess:", p.target_corps_id)
  local rankInfo = crossBattleInterface:getRankInfoByCorpsId(p.target_corps_id)
  if rankInfo then
    rankInfo.vote_num = rankInfo.vote_num + 1
    Toast(string.format(textRes.CrossBattle[8], GetStringFromOcts(rankInfo.corps_brief_info.name)))
  end
  crossBattleInterface.vote_times = crossBattleInterface.vote_times + 1
  crossBattleInterface:setCrossBattleVoteRedPoint()
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Vote_Success, {
    p.target_corps_id
  })
end
def.static("table").OnSVoteInCrossBattleFail = function(p)
  warn("-----OnSVoteInCrossBattleFail:", p.res)
  crossBattleInterface.canvass_timestamp = p.vote_timestamp
end
def.static("table").OnSCanvassInCrossBattleFail = function(p)
  warn("------OnSCanvassInCrossBattleFail:", p.res)
end
def.static("table").OnSSynVoteStageResultInCrossBattle = function(p)
  warn("-------OnSSynVoteStageResultInCrossBattle:", #p.vote_stage_direct_promotion_corps_list, #p.round_robin_point_rank_list)
  local directList = {}
  local corpsName1 = {}
  for i, v in ipairs(p.vote_stage_direct_promotion_corps_list) do
    local corpsInfo = v.corps_brief_info
    if corpsInfo then
      table.insert(directList, corpsInfo.corpsId)
      table.insert(corpsName1, GetStringFromOcts(corpsInfo.name))
    end
  end
  crossBattleInterface.voteDirectPromotionCorpsList = directList
  local pointList = {}
  for i, v in ipairs(p.round_robin_point_rank_list) do
    local corpsInfo = v.corps_brief_info
    warn(">>>>>>>>VoteStageResult:", corpsInfo.corpsId, GetStringFromOcts(corpsInfo.name))
    if corpsInfo then
      table.insert(pointList, corpsInfo.corpsId)
    end
  end
  crossBattleInterface.roundRobinPointRankList = pointList
  local content
  if #directList == 0 and #pointList == 0 then
    content = textRes.CrossBattle[33]
  end
  if #directList > 0 and #pointList == 0 then
    local names = table.concat(corpsName1, "\227\128\129")
    content = string.format(textRes.CrossBattle[34], names)
  end
  if #directList > 0 and #pointList > 0 then
    local names = table.concat(corpsName1, "\227\128\129")
    content = string.format(textRes.CrossBattle[35], names)
  end
  warn("-----------voteResult notice content:", content)
  if content then
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
    local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
    InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(content, 0, "Group_3")
  end
end
def.static("table").OnSSynRoundRobinRoundInfoInCrossBattle = function(p)
  warn("------OnSSynRoundRobinRoundInfoInCrossBattle:", p.index, p.stage, #p.fight_infos)
  local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
  if p.index >= crossBattleInterface.roundRobinRoundIdx then
    crossBattleInterface.roundRobinRoundIdx = p.index
    crossBattleInterface.roundRobinRoundStage = p.stage
  end
  if p.index == crossBattleInterface.restartIndex and p.stage == RoundRobinRoundStage.STAGE_END then
    crossBattleInterface.restartIndex = 0
    crossBattleInterface.restartTime = 0
  end
  crossBattleInterface:addRoundRobinFightInfo(p.index, p.stage, p.fight_infos)
  if p.stage == RoundRobinRoundStage.STAGE_PREPARE then
    if not CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_ROUND_ROBIN) then
      warn("!!!!!!!!crossbattle roundRobin stage is closed:")
      return
    end
    do
      local str = textRes.CrossBattle[45]
      local AnnouncementTip = require("GUI.AnnouncementTip")
      local ChatModule = require("Main.Chat.ChatModule")
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      AnnouncementTip.Announce(str)
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
      local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
      if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
        warn("-----OnSSynRoundRobinRoundInfoInCrossBattle-----myCorpsId is nil")
        return
      end
      local myCorpsId = myCorpsInfo.corpsId
      local canJoin = false
      local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
      for i, v in ipairs(p.fight_infos) do
        local corpsInfoA = v.corps_a_brief_info
        local corpsInfoB = v.corps_b_brief_info
        if corpsInfoA.corpsId:eq(myCorpsId) then
          if not corpsInfoB.corpsId:eq(Int64.new(0)) then
            if v.state == RoundRobinFightInfo.STATE_NOT_START then
              canJoin = true
              break
            end
            warn("------------cur corps stage:", v.state)
            break
          end
        elseif corpsInfoB.corpsId:eq(myCorpsId) and not corpsInfoA.corpsId:eq(Int64.new(0)) then
          if v.state == RoundRobinFightInfo.STATE_NOT_START then
            canJoin = true
            break
          end
          warn("------------cur corps stage:", v.state)
          break
        end
      end
      if not canJoin then
        warn("!!!!!!! round robin no fightInfo>>>>>>>> ")
        return
      end
      local function callback(id)
        if id == 1 then
          local teamData = require("Main.Team.TeamData").Instance()
          if teamData:HasTeam() then
            local members = teamData:GetAllTeamMembers()
            local m1 = members[1]
            local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
            if not m1.roleid:eq(HeroProp.id) then
              Toast(textRes.CrossBattle[44])
              return
            end
          end
          local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
          Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
            crossBattleCfg.npc_id
          })
        end
      end
      local function registerCallback(roleList)
        local heroProp = require("Main.Hero.Interface").GetHeroProp()
        local heroId = heroProp.id
        for i, v in ipairs(roleList) do
          warn("---------roleid:", heroId, v, heroId:eq(v))
          if heroId:eq(v) then
            local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
            CommonConfirmDlg.ShowConfirm("", textRes.CrossBattle[26], callback, nil)
            break
          end
        end
      end
      crossBattleInterface:getCorpsRegisterRoleList(myCorpsId, registerCallback)
    end
  end
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Change, {
    p.index
  })
end
def.static("table").OnSEnterRoundRobinMapFail = function(p)
  warn("------OnSEnterRoundRobinMapFail:", p.res)
  local str = textRes.CrossBattle.enterRoundRobinMapError[p.res]
  if str then
    Toast(str)
  end
end
def.static("table").OnSLeaveRoundRobinMapFail = function(p)
  warn("-----OnSLeaveRoundRobinMapFail")
end
def.static("table").OnSGetRegisterRoleListSuccess = function(p)
  warn("-----OnSGetRegisterRoleListSuccess:", #p.role_list)
  if crossBattleInterface.getRegisterRoldListCallback then
    crossBattleInterface.getRegisterRoldListCallback(p.role_list)
    crossBattleInterface.getRegisterRoldListCallback = nil
  end
end
def.static("table").OnSGetRegisterRoleListFail = function(p)
  warn("-------OnSGetRegisterRoleListFail:", p.res)
  if crossBattleInterface.getRegisterRoldListCallback then
    crossBattleInterface.getRegisterRoldListCallback({})
    crossBattleInterface.getRegisterRoldListCallback = nil
  end
  if p.res == p.CORPS_NOT_REGISTER then
    Toast(textRes.CrossBattle[36])
  end
end
def.static("table").OnSGetRoundRobinRoundInfoInCrossBattleSuccess = function(p)
  warn("------OnSGetRoundRobinRoundInfoInCrossBattleSuccess:", p.index, p.stage, #p.fight_infos)
  crossBattleInterface:addRoundRobinFightInfo(p.index, p.stage, p.fight_infos)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, {
    p.index
  })
end
def.static("table").OnSGetRoundRobinRoundInfoInCrossBattleFail = function(p)
  warn("-----OnSGetRoundRobinRoundInfoInCrossBattleFail:", p.res)
end
def.static("table").OnSGetRoundRobinPointInfoInCrossBattleSuccess = function(p)
  warn("-----OnSGetRoundRobinPointInfoInCrossBattleSuccess:", #p.rankList)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Point_Rank_Success, {
    p.rankList
  })
end
def.static("table").OnSGetRoundRobinPointInfoInCrossBattleFail = function(p)
  warn("----OnSGetRoundRobinPointInfoInCrossBattleFail:", p.res)
end
def.static("table").OnSSynRoundRobinRoundFightResultInCrossBattle = function(p)
  warn("-------OnSSynRoundRobinRoundFightResultInCrossBattle:", p.index, p.index, p.stage)
  local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
  if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
    warn("-----OnSSynRoundRobinRoundFightResultInCrossBattle-----myCorpsId is nil")
    return
  end
  local myCorpsId = myCorpsInfo.corpsId
  local isWin = false
  local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
  local fightInfo = p.fight_info
  local corpsInfoA = fightInfo.corps_a_brief_info
  local corpsInfoB = fightInfo.corps_b_brief_info
  if corpsInfoA.corpsId:eq(myCorpsId) then
    isWin = fightInfo.state == RoundRobinFightInfo.STATE_A_WIN or fightInfo.state == RoundRobinFightInfo.STATE_B_ABSTAIN
  elseif corpsInfoB.corpsId:eq(myCorpsId) then
    isWin = fightInfo.state == RoundRobinFightInfo.STATE_B_WIN or fightInfo.state == RoundRobinFightInfo.STATE_A_ABSTAIN
  else
    warn("!!!!!!!!!! OnSSynRoundRobinRoundFightResultInCrossBattle not self fightInfo")
    return
  end
  if fightInfo.state == RoundRobinFightInfo.STATE_ALL_ABSTAIN then
    isWin = false
  end
  local effectId = 0
  if isWin then
    effectId = constant.CrossBattleConsts.ROUND_ROBIN_WIN_EFFECT_ID
  else
    effectId = constant.CrossBattleConsts.ROUND_ROBIN_LOSE_EFFECT_ID
  end
  instance:playRoundRobinResultEffect(effectId)
end
def.method("number").playRoundRobinResultEffect = function(self, effectId)
  warn("--------playRoundRobinResultEffect:", effectId)
  if effectId and effectId > 0 then
    local effectCfg = GetEffectRes(effectId)
    require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "roundRobinEffect", 0, 0, 10, false)
    warn("--------playRoundRobinResultEffect end:", effectId, effectCfg.path)
  end
end
def.static("table").OnSSynRoundRobinResultInCrossBattle = function(p)
  warn("@@@@@@@@@>>>>>>>>>>>>>>>-----OnSSynRoundRobinResultInCrossBattle:", #p.rankList)
  local pointCorpsIdList = {}
  local nameList = {}
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local promotionNum = crossBattleCfg.round_robin_stage_promotion_corps_num
  for i, v in ipairs(p.rankList) do
    local corpsInfo = v.corps_brief_info
    table.insert(pointCorpsIdList, corpsInfo.corpsId)
    if i <= promotionNum then
      table.insert(nameList, GetStringFromOcts(corpsInfo.name))
    end
  end
  crossBattleInterface.roundRobinPointRankList = pointCorpsIdList
  if #nameList > 0 then
    local nameStr = table.concat(nameList, "\227\128\129")
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local content = string.format(textRes.CrossBattle[40], nameStr)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
    local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
    InteractiveAnnouncementTip.InteractiveAnnounceWithPriorityAndSprite(content, 0, "Group_3")
    warn("-------roundRobin result end:", nameStr, content)
  end
end
def.static("table").OnSWatchRoundRobinFightFail = function(p)
  warn("-----OnSWatchRoundRobinFightFail:", p.res)
  local str = textRes.CrossBattle.watchRoundRobinError[p.res]
  if str then
    Toast(str)
  end
end
def.static("table").OnSWatchRoundRobinFightRecordFail = function(p)
  warn("---------OnSWatchRoundRobinFightRecordFail:", p.res)
  local str = textRes.CrossBattle.roundRobinRecordError[p.res]
  if str then
    Toast(str)
  end
end
def.static("table", "table").OnSRoundRobinTitle = function(role, p)
  if role == nil then
    warn("-------OnSRoundRobinTitle rold is nil")
    return
  end
  if p and p.corps_id then
    warn("--------OnSRoundRobinTitle:", p.corps_id, p.corps_name, p.corps_duty, p.corps_badge_id)
    local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
    if myCorpsInfo == nil or myCorpsInfo.corpsId == nil then
      warn("-----OnSRoundRobinTitle-----myCorpsId is nil")
      return
    end
    local myCorpsId = myCorpsInfo.corpsId
    local colorId = 0
    if p.corps_id:eq(myCorpsId) then
      colorId = constant.CrossBattleConsts.OWN_CORPS_TITLE_COLOR_ID
    else
      colorId = constant.CrossBattleConsts.OTHER_CORPS_TITLE_COLOR_ID
    end
    local titleColor = GetColorData(colorId)
    local corpsDutyStr = textRes.CrossBattle.CorpsDutyStr[p.corps_duty] or ""
    local title = GetStringFromOcts(p.corps_name)
    role:SetShowTitle(title, titleColor)
    local CorpsUtils = require("Main.Corps.CorpsUtils")
    local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(p.corps_badge_id)
    if badgeCfg then
      role:SetOrganizationIcon(badgeCfg.iconId)
    end
  else
    role:SetShowTitle("", nil)
    role:SetOrganizationIcon(0)
  end
end
return CrossBattleModule.Commit()
