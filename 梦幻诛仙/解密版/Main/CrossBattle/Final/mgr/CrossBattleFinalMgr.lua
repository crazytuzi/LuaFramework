local Lplus = require("Lplus")
local CrossBattleFinalMgr = Lplus.Class("CrossBattleFinalMgr")
local CrossBattleFinalData = require("Main.CrossBattle.Final.data.CrossBattleFinalData")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local def = CrossBattleFinalMgr.define
def.const("number").STAGE_BATTLE_COUNT = 3
local instance
def.static("=>", CrossBattleFinalMgr).Instance = function()
  if instance == nil then
    instance = CrossBattleFinalMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleFinalPanelInfo", CrossBattleFinalMgr.OnSCrossBattleFinalPanelInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifyFinalBegin", CrossBattleFinalMgr.OnSNotifyFinalBegin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SEnterCrossBattleFinalMapSuccess", CrossBattleFinalMgr.OnSEnterCrossBattleFinalMapSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleFinalFightSuccess", CrossBattleFinalMgr.OnSGetCrossBattleFinalFightSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleFinalNormalRes", CrossBattleFinalMgr.OnSCrossBattleFinalNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SLoginNotifyFinalFightRes", CrossBattleFinalMgr.OnSLoginNotifyFinalFightRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleSelectionMatchRoleInfo", CrossBattleFinalMgr.OnSCrossBattleFinalMatchRoleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SUpdateCrossBattleSelectionProcessInfo", CrossBattleFinalMgr.OnSUpdateCrossBattleFinalProcessInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleFinalFightStageSuccess", CrossBattleFinalMgr.OnSGetCrossBattleFinalFightStageSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifyCrossBattleKnockOutRestart", CrossBattleFinalMgr.OnSNotifyCrossBattleKnockOutRestart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifyKnockOutCorpsQualification", CrossBattleFinalMgr.OnSNotifyKnockOutCorpsQualification)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Stage_Click, CrossBattleFinalMgr.OnCrossBattleStageClick)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, CrossBattleFinalMgr.OnMapChange)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CrossBattleFinalMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleFinal.Receive_Final_Fight_Info, CrossBattleFinalMgr.OnReceiveFinalFightInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, CrossBattleFinalMgr.OnLeaveWorldStage)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, CrossBattleFinalMgr.OnEnterFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, CrossBattleFinalMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method().Reset = function(self)
  CrossBattleFinalData.Instance():Clear()
end
def.static("table").OnSCrossBattleFinalPanelInfo = function(p)
  CrossBattleFinalData.Instance():SetJoinConditionStatus(p)
  local conditionStatus = CrossBattleFinalData.Instance():GetJoinConditionStatus()
  local status = {
    conditionStatus.is_five_role_team,
    conditionStatus.is_in_one_corps,
    conditionStatus.is_can_take_part_in_Final,
    conditionStatus.is_role_same_with_sign_up
  }
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  CrossBattleConditionCheckPanel.Instance():SetConditionCheckStatus(status)
end
def.static("table").OnSNotifyFinalBegin = function(p)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.CrossBattle.CrossBattleFinal[6], textRes.CrossBattle.CrossBattleFinal[5], function(result)
    if result == 0 then
      return
    end
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      crossBattleCfg.npc_id
    })
  end, {})
end
def.static("table").OnSEnterCrossBattleFinalMapSuccess = function(p)
  CrossBattleFinalData.Instance():SetWaitingSeconds(p.left_seconds)
  CrossBattleFinalMgr.Instance():UpdateWatingTime()
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  CrossBattleConditionCheckPanel.Instance():HidePanel()
  local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
  CrossBattlePanel.Instance():Hide()
end
def.static("table").OnSGetCrossBattleFinalFightSuccess = function(p)
  local corpsMap = {}
  local CrossBattleFightCorpsInfo = require("Main.CrossBattle.data.CrossBattleFightCorpsInfo")
  for corpsId, corpsInfo in pairs(p.final_fight_corps_map) do
    local corps = CrossBattleFightCorpsInfo()
    corps:RawSet(corpsInfo)
    corpsMap[corpsId:tostring()] = corps
  end
  CrossBattleFinalData.Instance():SetFinalFightCorpsInfo(corpsMap)
  local CrossBattleFightInfo = require("Main.CrossBattle.data.CrossBattleFightInfo")
  local fightInfo = {}
  for stage, fightList in pairs(p.final_stage_fight_info_map) do
    local stageFightInfo = {}
    for i = 1, #fightList.fight_info_list do
      local fight = CrossBattleFightInfo()
      fight:RawSet(fightList.fight_info_list[i])
      table.insert(stageFightInfo, fight)
    end
    fightInfo[stage] = stageFightInfo
  end
  CrossBattleFinalData.Instance():SetFinalFightInfo(fightInfo)
  CrossBattleFinalData.Instance():SetCurFightStage(p.final_stage)
  CrossBattleFinalMgr.Instance():ShowBattleInfoPanel()
end
def.static("table").OnSCrossBattleFinalNormalRes = function(p)
  if textRes.CrossBattle.CrossBattleFinal.SCrossBattleFinalNormalRes[p.ret] then
    Toast(textRes.CrossBattle.CrossBattleFinal.SCrossBattleFinalNormalRes[p.ret])
  else
    warn("OnSCrossBattleFinalNormalRes:" .. p.ret)
  end
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  CrossBattleFightLoadingPanel.Instance():Hide()
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  CrossBattleWaitingHallPanel.Instance():RemoveWaitTips()
end
def.static("table").OnSLoginNotifyFinalFightRes = function(p)
  GameUtil.AddGlobalTimer(2, true, function()
    if not _G.IsEnteredWorld() then
      return
    end
    if textRes.CrossBattle.CrossBattleFinal.BattleResult[p.ret] and textRes.CrossBattle.CrossBattleFinal.BattleResult[p.ret][p.reason] then
      local tips = textRes.CrossBattle.CrossBattleFinal.BattleResult[p.ret][p.reason]
      local ChatModule = require("Main.Chat.ChatModule")
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tips})
      Toast(tips)
    end
    if p.is_rank_up == 1 then
      local effectId = 0
      if p.ret == 1 then
        effectId = constant.CrossBattleConsts.cross_battle_final_win_effect_id
      else
        effectId = constant.CrossBattleConsts.cross_battle_final_lose_effect_id
      end
      local effectCfg = GetEffectRes(effectId)
      if effectCfg ~= nil then
        require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "FinalEffect", 0, 0, 10, false)
      else
        warn("no final id:" .. effectId)
      end
    end
  end)
end
def.static("table").OnSCrossBattleFinalMatchRoleInfo = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.FINAL then
    return
  end
  local matchInfo = {}
  local CrossBattleMatchCorpsInfo = require("Main.CrossBattle.data.CrossBattleMatchCorpsInfo")
  local matchAInfo = CrossBattleMatchCorpsInfo()
  local matchBInfo = CrossBattleMatchCorpsInfo()
  matchAInfo:RawSet(p.matchTeamAInfos)
  matchBInfo:RawSet(p.matchTeamBInfos)
  matchInfo[1] = matchAInfo
  matchInfo[2] = matchBInfo
  CrossBattleFinalData.Instance():SetFinalMatchInfo(matchInfo)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  local mainEffectId = 0
  local subEffectId = 0
  mainEffectId = crossBattleCfg and (crossBattleCfg.final_match_special_effect_id or 0)
  subEffectId = crossBattleCfg and crossBattleCfg.special_effect_list and (crossBattleCfg.special_effect_list[p.fight_stage] or 0)
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  if not _G.PlayerIsInFight() then
    CrossBattleFightLoadingPanel.Instance():ShowPanel(matchInfo, crossBattleCfg and crossBattleCfg.final_match_countdown or 0, mainEffectId, subEffectId)
    local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
    CrossBattleWaitingHallPanel.Instance():RemoveWaitTips()
  end
end
def.static("table").OnSUpdateCrossBattleFinalProcessInfo = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.FINAL then
    return
  end
  for i = 1, #p.process_infos do
    local info = p.process_infos[i]
    CrossBattleFinalData.Instance():SetFinalMatchRoleProgress(info.roleid, info.process)
  end
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  CrossBattleFightLoadingPanel.Instance():UpdateProgress(CrossBattleFinalData.Instance():GetFinalMatchInfo())
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  CrossBattleWaitingHallPanel.Instance():RemoveWaitTips()
end
def.static("table").OnSGetCrossBattleFinalFightStageSuccess = function(p)
  local corpsMap = {}
  local CrossBattleFightCorpsInfo = require("Main.CrossBattle.data.CrossBattleFightCorpsInfo")
  for corpsId, corpsInfo in pairs(p.final_fight_corps_map) do
    local corps = CrossBattleFightCorpsInfo()
    corps:RawSet(corpsInfo)
    corpsMap[corpsId:tostring()] = corps
  end
  local CrossBattleFightInfo = require("Main.CrossBattle.data.CrossBattleFightInfo")
  local fightInfo = {}
  for i = 1, #p.final_stage_fight_info.fight_info_list do
    local fight = CrossBattleFightInfo()
    fight:RawSet(p.final_stage_fight_info.fight_info_list[i])
    table.insert(fightInfo, fight)
  end
  local params = {}
  params.zoneId = p.fight_zone_id
  params.stage = p.final_stage
  params.corpsMap = corpsMap
  params.fightInfo = fightInfo
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleFinal.Receive_Final_Fight_Info, params)
end
def.static("table").OnSNotifyCrossBattleKnockOutRestart = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.FINAL then
    return
  end
  CrossBattleFinalData.Instance():SetReschedulePrepareTime(p.prepare_world_begin_time, p.prepare_world_end_time)
end
def.static("table").OnSNotifyKnockOutCorpsQualification = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.FINAL then
    return
  end
  CrossBattleFinalData.Instance():SetCanAttendFinal(p.is_has_qualification == 1)
end
def.static("table", "table").OnCrossBattleStageClick = function(params, context)
  local stage = params[1]
  if stage ~= CrossBattleActivityStage.STAGE_FINAL then
    return
  end
  local isOpen = CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_FINAL)
  if not isOpen then
    return
  end
  if not CrossBattleFinalMgr.Instance():IsCrossBattleFinalPrepareTime() then
    Toast(textRes.CrossBattle.CrossBattleFinal[19])
    return
  end
  local conditionDesc = {
    textRes.CrossBattle.CrossBattleFinal[1],
    textRes.CrossBattle.CrossBattleFinal[2],
    textRes.CrossBattle.CrossBattleFinal[3],
    textRes.CrossBattle.CrossBattleFinal[4]
  }
  local initStatus = {
    false,
    false,
    false,
    false
  }
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  CrossBattleConditionCheckPanel.Instance():ShowPanel(conditionDesc, initStatus)
  CrossBattleConditionCheckPanel.Instance():SetConfirmCallback(function()
    CrossBattleFinalMgr.Instance():EnterCrossBattleFinalWatingMap()
  end, false)
  local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
  CrossBattleFinalMgr.Instance():GetCrossBattleFinalPanelInfo()
end
def.static("table", "table").OnMapChange = function(params, context)
  local mapId = params[1]
  local oldMapId = params[2]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if not crossBattleCfg then
    return
  end
  if mapId == crossBattleCfg.final_map_cfg_id then
    CrossBattleFinalMgr.Instance():SetCrossBattleFinalState(true)
    CrossBattleFinalMgr.Instance():SetWaitingTimeVisible(true)
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Enter_Game_Scene, nil)
  elseif oldMapId == crossBattleCfg.final_map_cfg_id and mapId ~= crossBattleCfg.final_map_cfg_id then
    CrossBattleFinalMgr.Instance():SetCrossBattleFinalState(false)
    CrossBattleFinalMgr.Instance():SetWaitingTimeVisible(false)
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Leave_Game_Scene, nil)
  end
end
def.static("table", "table").OnNpcService = function(params, context)
  local serviceId = params[1]
  local npcId = params[2]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if crossBattleCfg and npcId == crossBattleCfg.final_out_npc_id and serviceId == crossBattleCfg.final_out_npc_service_id then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.CrossBattle.CrossBattleFinal[16], function(result)
      if result == 1 then
        CrossBattleFinalMgr.Instance():LeaveCrossBattleFinalWatingMap()
      end
    end, nil)
  end
end
def.static("table", "table").OnReceiveFinalFightInfo = function(params, context)
  local CrossBattleSelectionAndFinalHistoryPanel = require("Main.CrossBattle.ui.CrossBattleSelectionAndFinalHistoryPanel")
  if CrossBattleSelectionAndFinalHistoryPanel.Instance():IsCreated() then
    CrossBattleFinalMgr.Instance():ShowZoneFinalFightHistory(params.zoneId, params.stage, params.corpsMap, params.fightInfo)
  end
end
def.static("table", "table").OnLeaveWorldStage = function(p1, p2)
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  CrossBattleFightLoadingPanel.Instance():Hide()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if _G.IsCrossingServer() then
    local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
    CrossBattleFightLoadingPanel.Instance():Hide()
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  if not _G.IsCrossingServer() then
    local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
    CrossBattleFightLoadingPanel.Instance():Hide()
  end
end
def.method("boolean").SetCrossBattleFinalState = function(self, set)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
    if set then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.CROSS_BATTLE)
    else
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.CROSS_BATTLE)
    end
  end
end
def.method("boolean").SetWaitingTimeVisible = function(self, visible)
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  if visible then
    local leftTime = CrossBattleFinalData.Instance():GetWatingSeconds() or Int64.new(0)
    CrossBattleWaitingHallPanel.Instance():ShowPanel(Int64.ToNumber(leftTime), textRes.CrossBattle.CrossBattleFinal[17])
    CrossBattleWaitingHallPanel.Instance():SetBattleInfoHandler(function()
      self:QueryToShowCrossBattleFinalInfo()
    end)
  else
    CrossBattleWaitingHallPanel.Instance():HidePanel()
  end
end
def.method().UpdateWatingTime = function(self)
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  if CrossBattleWaitingHallPanel.Instance():IsCreated() then
    local leftTime = CrossBattleFinalData.Instance():GetWatingSeconds() or Int64.new(0)
    CrossBattleWaitingHallPanel.Instance():SetLeftTime(Int64.ToNumber(leftTime))
  end
end
def.method().GetCrossBattleFinalPanelInfo = function(self)
  CrossBattleFinalData.Instance():ClearJoinConditionStatus()
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleFinalPanelInfo").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method().EnterCrossBattleFinalWatingMap = function(self)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CEnterCrossBattleFinalMapReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method().LeaveCrossBattleFinalWatingMap = function(self)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CLeaveCrossBattleFinalMapReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method().QueryToShowCrossBattleFinalInfo = function(self)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleFinalFightReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").QueryZoneFinalFightInfo = function(self, zoneId, stage)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleFinalFightStageReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, zoneId, stage)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").QueryToShowZoneFinalFightHistory = function(self, zoneId, stage)
  self:ShowZoneFinalFightHistory(zoneId, stage, {}, {})
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleFinalFightStageReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, zoneId, stage)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number", "table", "table").ShowZoneFinalFightHistory = function(self, zoneId, stage, corpsMap, fightInfo)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  local timeCfgId = crossBattleCfg.final_stage_time[stage]
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeCfgId)
  local timeStr = string.format(textRes.CrossBattle.CrossBattleFinal[13], timePointCfg.year, timePointCfg.month, timePointCfg.day)
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  local battleStage = math.floor((stage - 1) / CrossBattleFinalMgr.STAGE_BATTLE_COUNT) + 1
  local battleRound = (stage - 1) % CrossBattleFinalMgr.STAGE_BATTLE_COUNT + 1
  local titleStr = string.format(textRes.CrossBattle.CrossBattleFinal[14], textRes.CrossBattle.CrossBattleFinal.BattleType[battleStage], battleRound)
  local CrossBattleSelectionAndFinalHistoryPanel = require("Main.CrossBattle.ui.CrossBattleSelectionAndFinalHistoryPanel")
  CrossBattleSelectionAndFinalHistoryPanel.Instance():ShowPanel(timeStr, titleStr, corpsMap, fightInfo, nil)
end
def.method().ShowBattleInfoPanel = function(self)
  local curStage = CrossBattleFinalData.Instance():GetCurFightStage()
  local corpsData = CrossBattleFinalData.Instance():GetFinalFightCorpsInfo()
  local fightInfo = CrossBattleFinalData.Instance():GetFinalFightInfo()
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if crossBattleCfg.final_need_team_num == 32 then
    local stageInfo = {
      textRes.CrossBattle.CrossBattleFinal.BattleType[1],
      textRes.CrossBattle.CrossBattleFinal.BattleType[2],
      textRes.CrossBattle.CrossBattleFinal.BattleType[3],
      textRes.CrossBattle.CrossBattleFinal.BattleType[4],
      textRes.CrossBattle.CrossBattleFinal.BattleType[5],
      textRes.CrossBattle.CrossBattleFinal.BattleType[6]
    }
    require("Main.CrossBattle.Final.ui.CrossBattleFinalFightInfoPanel").Instance():ShowPanel(curStage, stageInfo, corpsData, fightInfo, crossBattleCfg and crossBattleCfg.final_match_tips_id or 0)
  elseif crossBattleCfg.final_need_team_num == 16 then
    local stageInfo = {
      textRes.CrossBattle.CrossBattleFinal.BattleType[1],
      textRes.CrossBattle.CrossBattleFinal.BattleType[2],
      textRes.CrossBattle.CrossBattleFinal.BattleType[3],
      textRes.CrossBattle.CrossBattleFinal.BattleType[4],
      textRes.CrossBattle.CrossBattleFinal.BattleType[5]
    }
    require("Main.CrossBattle.Final.ui.CrossBattleFinalFightInfoPanel16").Instance():ShowPanel(curStage, stageInfo, corpsData, fightInfo, crossBattleCfg and crossBattleCfg.final_match_tips_id or 0)
  end
end
def.method("=>", "boolean").IsCrossBattleFinalPrepareTime = function(self)
  if CrossBattleFinalData.Instance():IsDuringRescheduleFinal() then
    return true
  end
  local stage = CrossBattleInterface.GetTodayCrossBattleFinalStage()
  if stage == 0 then
    return false
  end
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return false
  end
  local timePointCfgId = finalCfg.final_stage_time[stage]
  if timePointCfgId == nil then
    return false
  end
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timePointCfgId)
  if timePoint == nil then
    return false
  end
  local startTime = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, timePoint.hour, timePoint.min, timePoint.sec)
  local prepareTime = startTime - finalCfg.final_countdown * 60
  local serverTime = _G.GetServerTime()
  return prepareTime <= serverTime and startTime >= serverTime
end
CrossBattleFinalMgr.Commit()
return CrossBattleFinalMgr
