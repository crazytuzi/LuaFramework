local Lplus = require("Lplus")
local CrossBattleSelectionMgr = Lplus.Class("CrossBattleSelectionMgr")
local CrossBattleSelectionData = require("Main.CrossBattle.Selection.data.CrossBattleSelectionData")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local def = CrossBattleSelectionMgr.define
local instance
def.static("=>", CrossBattleSelectionMgr).Instance = function()
  if instance == nil then
    instance = CrossBattleSelectionMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleSelectionPanelInfo", CrossBattleSelectionMgr.OnSCrossBattleSelectionPanelInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifySelectionBegin", CrossBattleSelectionMgr.OnSNotifySelectionBegin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SEnterCrossBattleSelectionMapSuccess", CrossBattleSelectionMgr.OnSEnterCrossBattleSelectionMapSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleSelectionFightSuccess", CrossBattleSelectionMgr.OnSGetCrossBattleSelectionFightSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleSelectionNormalRes", CrossBattleSelectionMgr.OnSCrossBattleSelectionNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SCrossBattleSelectionMatchRoleInfo", CrossBattleSelectionMgr.OnSCrossBattleSelectionMatchRoleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SUpdateCrossBattleSelectionProcessInfo", CrossBattleSelectionMgr.OnSUpdateCrossBattleSelectionProcessInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SLoginNotifySelectionFightRes", CrossBattleSelectionMgr.OnSLoginNotifySelectionFightRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetCrossBattleSelectionFightStageSuccess", CrossBattleSelectionMgr.OnSGetCrossBattleSelectionFightStageSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetSelectionStageOwnServerFightSuccess", CrossBattleSelectionMgr.OnSGetSelectionStageOwnServerFightSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifyCrossBattleKnockOutRestart", CrossBattleSelectionMgr.OnSNotifyCrossBattleKnockOutRestart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SNotifyKnockOutCorpsQualification", CrossBattleSelectionMgr.OnSNotifyKnockOutCorpsQualification)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, CrossBattleSelectionMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, CrossBattleSelectionMgr.OnMapChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, CrossBattleSelectionMgr.OnLeaveWorldStage)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, CrossBattleSelectionMgr.OnEnterFight)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, CrossBattleSelectionMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Stage_Click, CrossBattleSelectionMgr.OnCrossBattleStageClick)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Receive_Selection_Fight_Info, CrossBattleSelectionMgr.OnReceiveSelectionFightInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method().Reset = function(self)
  CrossBattleSelectionData.Instance():Clear()
end
def.static("table").OnSCrossBattleSelectionPanelInfo = function(p)
  CrossBattleSelectionData.Instance():SetJoinConditionStatus(p)
  local conditionStatus = CrossBattleSelectionData.Instance():GetJoinConditionStatus()
  local status = {
    conditionStatus.is_five_role_team,
    conditionStatus.is_in_one_corps,
    conditionStatus.is_can_take_part_in_selection,
    conditionStatus.is_role_same_with_sign_up
  }
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  CrossBattleConditionCheckPanel.Instance():SetConditionCheckStatus(status)
end
def.static("table").OnSNotifySelectionBegin = function(p)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.CrossBattle.CrossBattleSelection[6], textRes.CrossBattle.CrossBattleSelection[5], function(result)
    if result == 0 then
      return
    end
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      crossBattleCfg.npc_id
    })
  end, {})
end
def.static("table").OnSEnterCrossBattleSelectionMapSuccess = function(p)
  CrossBattleSelectionData.Instance():SetWaitingSeconds(p.left_seconds)
  CrossBattleSelectionMgr.Instance():UpdateWatingTime()
  local CrossBattleConditionCheckPanel = require("Main.CrossBattle.ui.CrossBattleConditionCheckPanel")
  CrossBattleConditionCheckPanel.Instance():HidePanel()
  local CrossBattlePanel = require("Main.CrossBattle.ui.CrossBattlePanel")
  CrossBattlePanel.Instance():Hide()
end
def.static("table").OnSGetCrossBattleSelectionFightSuccess = function(p)
  local corpsMap = {}
  local CrossBattleFightCorpsInfo = require("Main.CrossBattle.data.CrossBattleFightCorpsInfo")
  for corpsId, corpsInfo in pairs(p.selection_fight_corps_map) do
    local corps = CrossBattleFightCorpsInfo()
    corps:RawSet(corpsInfo)
    corpsMap[corpsId:tostring()] = corps
  end
  CrossBattleSelectionData.Instance():SetSelectionFightCorpsInfo(corpsMap)
  local CrossBattleFightInfo = require("Main.CrossBattle.data.CrossBattleFightInfo")
  local fightInfo = {}
  for stage, fightList in pairs(p.selection_stage_fight_info_map) do
    local stageFightInfo = {}
    for i = 1, #fightList.fight_info_list do
      local fight = CrossBattleFightInfo()
      fight:RawSet(fightList.fight_info_list[i])
      table.insert(stageFightInfo, fight)
    end
    fightInfo[stage] = stageFightInfo
  end
  CrossBattleSelectionData.Instance():SetSelectionFightInfo(fightInfo)
  CrossBattleSelectionData.Instance():SetCurFightStage(p.selection_stage)
  CrossBattleSelectionMgr.Instance():ShowBattleInfoPanel()
end
def.static("table").OnSCrossBattleSelectionNormalRes = function(p)
  if textRes.CrossBattle.CrossBattleSelection.CrossBattleSelectionNormalRes[p.ret] then
    Toast(textRes.CrossBattle.CrossBattleSelection.CrossBattleSelectionNormalRes[p.ret])
  else
    warn("OnSCrossBattleSelectionNormalRes:" .. p.ret)
  end
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  CrossBattleFightLoadingPanel.Instance():Hide()
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  CrossBattleWaitingHallPanel.Instance():RemoveWaitTips()
end
def.static("table").OnSCrossBattleSelectionMatchRoleInfo = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.SELECTION then
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
  CrossBattleSelectionData.Instance():SetSelectionMatchInfo(matchInfo)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local mainEffectId = 0
  local subEffectId = 0
  mainEffectId = crossBattleCfg and (crossBattleCfg.selection_match_special_effect_id or 0)
  subEffectId = crossBattleCfg and crossBattleCfg.special_effect_list and (crossBattleCfg.special_effect_list[p.fight_stage] or 0)
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  if not _G.PlayerIsInFight() then
    CrossBattleFightLoadingPanel.Instance():ShowPanel(matchInfo, crossBattleCfg and crossBattleCfg.selection_match_countdown or 0, mainEffectId, subEffectId)
    local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
    CrossBattleWaitingHallPanel.Instance():RemoveWaitTips()
  end
end
def.static("table").OnSUpdateCrossBattleSelectionProcessInfo = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.SELECTION then
    return
  end
  for i = 1, #p.process_infos do
    local info = p.process_infos[i]
    CrossBattleSelectionData.Instance():SetSelectionMatchRoleProgress(info.roleid, info.process)
  end
  local CrossBattleFightLoadingPanel = require("Main.CrossBattle.ui.CrossBattleFightLoadingPanel")
  CrossBattleFightLoadingPanel.Instance():UpdateProgress(CrossBattleSelectionData.Instance():GetSelectionMatchInfo())
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  CrossBattleWaitingHallPanel.Instance():RemoveWaitTips()
end
def.static("table").OnSLoginNotifySelectionFightRes = function(p)
  GameUtil.AddGlobalTimer(2, true, function()
    if not _G.IsEnteredWorld() then
      return
    end
    if textRes.CrossBattle.CrossBattleSelection.BattleResult[p.ret] and textRes.CrossBattle.CrossBattleSelection.BattleResult[p.ret][p.reason] then
      local tips = textRes.CrossBattle.CrossBattleSelection.BattleResult[p.ret][p.reason]
      local ChatModule = require("Main.Chat.ChatModule")
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = tips})
      Toast(tips)
    end
    if p.is_rank_up == 1 then
      local effectId = 0
      if p.ret == 1 then
        effectId = constant.CrossBattleConsts.cross_battle_selection_win_effect_id
      else
        effectId = constant.CrossBattleConsts.cross_battle_selection_lose_effect_id
      end
      local effectCfg = GetEffectRes(effectId)
      if effectCfg ~= nil then
        require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "SelectionEffect", 0, 0, 10, false)
      else
        warn("no effect id:" .. effectId)
      end
    end
  end)
end
def.static("table").OnSGetCrossBattleSelectionFightStageSuccess = function(p)
  local corpsMap = {}
  local CrossBattleFightCorpsInfo = require("Main.CrossBattle.data.CrossBattleFightCorpsInfo")
  for corpsId, corpsInfo in pairs(p.selection_fight_corps_map) do
    local corps = CrossBattleFightCorpsInfo()
    corps:RawSet(corpsInfo)
    corpsMap[corpsId:tostring()] = corps
  end
  local CrossBattleFightInfo = require("Main.CrossBattle.data.CrossBattleFightInfo")
  local fightInfo = {}
  for i = 1, #p.selection_stage_fight_info.fight_info_list do
    local fight = CrossBattleFightInfo()
    fight:RawSet(p.selection_stage_fight_info.fight_info_list[i])
    table.insert(fightInfo, fight)
  end
  local params = {}
  params.zoneId = p.fight_zone_id
  params.stage = p.selection_stage
  params.corpsMap = corpsMap
  params.fightInfo = fightInfo
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Receive_Selection_Fight_Info, params)
end
def.static("table").OnSGetSelectionStageOwnServerFightSuccess = function(p)
  local corpsMap = {}
  local CrossBattleFightCorpsInfo = require("Main.CrossBattle.data.CrossBattleFightCorpsInfo")
  for corpsId, corpsInfo in pairs(p.selection_fight_corps_map) do
    local corps = CrossBattleFightCorpsInfo()
    corps:RawSet(corpsInfo)
    corpsMap[corpsId:tostring()] = corps
  end
  local CrossBattleFightInfo = require("Main.CrossBattle.data.CrossBattleFightInfo")
  local fightInfo = {}
  for i = 1, #p.selection_stage_fight_info.fight_info_list do
    local fight = CrossBattleFightInfo()
    fight:RawSet(p.selection_stage_fight_info.fight_info_list[i])
    table.insert(fightInfo, fight)
  end
  local params = {}
  params.stage = p.selection_stage
  params.corpsMap = corpsMap
  params.fightInfo = fightInfo
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Receive_Own_Server_Selection_Fight_Info, params)
end
def.static("table").OnSNotifyCrossBattleKnockOutRestart = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.SELECTION then
    return
  end
  CrossBattleSelectionData.Instance():SetReschedulePrepareTime(p.prepare_world_begin_time, p.prepare_world_end_time)
end
def.static("table").OnSNotifyKnockOutCorpsQualification = function(p)
  local CrossBattleFightType = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleFightType")
  if p.fight_type ~= CrossBattleFightType.SELECTION then
    return
  end
  CrossBattleSelectionData.Instance():SetCanAttendSelection(p.is_has_qualification == 1)
end
def.static("table", "table").OnNpcService = function(params, context)
  local serviceId = params[1]
  local npcId = params[2]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if crossBattleCfg and npcId == crossBattleCfg.selection_out_npc_id and serviceId == crossBattleCfg.selection_out_npc_service_id then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.CrossBattle.CrossBattleSelection[16], function(result)
      if result == 1 then
        CrossBattleSelectionMgr.Instance():LeaveCrossBattleSelectionWatingMap()
      end
    end, nil)
  end
end
def.static("table", "table").OnMapChange = function(params, context)
  local mapId = params[1]
  local oldMapId = params[2]
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if not crossBattleCfg then
    return
  end
  if mapId == crossBattleCfg.selection_map_cfg_id then
    CrossBattleSelectionMgr.Instance():SetCrossBattleSelectionState(true)
    CrossBattleSelectionMgr.Instance():SetWaitingTimeVisible(true)
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Enter_Game_Scene, nil)
  elseif oldMapId == crossBattleCfg.selection_map_cfg_id and mapId ~= crossBattleCfg.selection_map_cfg_id then
    CrossBattleSelectionMgr.Instance():SetCrossBattleSelectionState(false)
    CrossBattleSelectionMgr.Instance():SetWaitingTimeVisible(false)
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Leave_Game_Scene, nil)
  end
end
def.static("table", "table").OnCrossBattleStageClick = function(params, context)
  local stage = params[1]
  if stage ~= CrossBattleActivityStage.STAGE_SELECTION then
    return
  end
  local isOpen = CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_SELECTION)
  if not isOpen then
    return
  end
  if not CrossBattleSelectionMgr.Instance():IsCrossBattleSelectionPrepareTime() then
    Toast(textRes.CrossBattle.CrossBattleSelection[18])
    return
  end
  local conditionDesc = {
    textRes.CrossBattle.CrossBattleSelection[1],
    textRes.CrossBattle.CrossBattleSelection[2],
    textRes.CrossBattle.CrossBattleSelection[3],
    textRes.CrossBattle.CrossBattleSelection[4]
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
    CrossBattleSelectionMgr.Instance():EnterCrossBattleSelectionWatingMap()
  end, false)
  local CrossBattleSelectionMgr = require("Main.CrossBattle.Selection.mgr.CrossBattleSelectionMgr")
  CrossBattleSelectionMgr.Instance():GetCrossBattleSelectionPanelInfo()
end
def.static("table", "table").OnReceiveSelectionFightInfo = function(params, context)
  local CrossBattleSelectionAndFinalHistoryPanel = require("Main.CrossBattle.ui.CrossBattleSelectionAndFinalHistoryPanel")
  if CrossBattleSelectionAndFinalHistoryPanel.Instance():IsCreated() then
    CrossBattleSelectionMgr.Instance():ShowZoneSelectionFightHistory(params.zoneId, params.stage, params.corpsMap, params.fightInfo)
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
def.method("boolean").SetCrossBattleSelectionState = function(self, set)
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
    local leftTime = CrossBattleSelectionData.Instance():GetWatingSeconds() or Int64.new(0)
    CrossBattleWaitingHallPanel.Instance():ShowPanel(Int64.ToNumber(leftTime), textRes.CrossBattle.CrossBattleSelection[17])
    CrossBattleWaitingHallPanel.Instance():SetBattleInfoHandler(function()
      self:QueryToShowCrossBattleSelectionInfo()
    end)
  else
    CrossBattleWaitingHallPanel.Instance():HidePanel()
  end
end
def.method().UpdateWatingTime = function(self)
  local CrossBattleWaitingHallPanel = require("Main.CrossBattle.ui.CrossBattleWaitingHallPanel")
  if CrossBattleWaitingHallPanel.Instance():IsCreated() then
    local leftTime = CrossBattleSelectionData.Instance():GetWatingSeconds() or Int64.new(0)
    CrossBattleWaitingHallPanel.Instance():SetLeftTime(Int64.ToNumber(leftTime))
  end
end
def.method().GetCrossBattleSelectionPanelInfo = function(self)
  CrossBattleSelectionData.Instance():ClearJoinConditionStatus()
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleSelectionPanelInfo").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method().EnterCrossBattleSelectionWatingMap = function(self)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CEnterCrossBattleSelectionMapReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method().LeaveCrossBattleSelectionWatingMap = function(self)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CLeaveCrossBattleSelectionMapReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method().QueryToShowCrossBattleSelectionInfo = function(self)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleSelectionFightReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").QueryZoneSelectionFightInfo = function(self, zoneId, stage)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleSelectionFightStageReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, zoneId, stage)
  gmodule.network.sendProtocol(req)
end
def.method("number").QueryOwnServerSelectionFightInfo = function(self, stage)
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetSelectionStageOwnServerFightReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, stage)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").QueryToShowZoneSelectionFightHistory = function(self, zoneId, stage)
  self:ShowZoneSelectionFightHistory(zoneId, stage, {}, {})
  local req = require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleSelectionFightStageReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, zoneId, stage)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number", "table", "table").ShowZoneSelectionFightHistory = function(self, zoneId, stage, corpsMap, fightInfo)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local timeCfgId = crossBattleCfg.selection_stage_time[stage]
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeCfgId)
  local timeStr = string.format(textRes.CrossBattle.CrossBattleSelection[13], timePointCfg.year, timePointCfg.month, timePointCfg.day)
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  local titleStr = string.format(textRes.CrossBattle.CrossBattleSelection[14], PointsRaceUtils.GetZoneName(zoneId), textRes.CrossBattle.CrossBattleSelection.BattleType[stage])
  local CrossBattleSelectionAndFinalHistoryPanel = require("Main.CrossBattle.ui.CrossBattleSelectionAndFinalHistoryPanel")
  CrossBattleSelectionAndFinalHistoryPanel.Instance():ShowPanel(timeStr, titleStr, corpsMap, fightInfo, function(chooseZoneId)
    CrossBattleSelectionMgr.Instance():QueryToShowZoneSelectionFightHistory(chooseZoneId, stage)
  end)
  CrossBattleSelectionAndFinalHistoryPanel.Instance():SetCurrentZoneId(zoneId)
end
def.method().ShowBattleInfoPanel = function(self)
  local CrossBattleSelectionStageEnum = require("consts.mzm.gsp.crossbattle.confbean.CrossBattleSelectionStageEnum")
  local curStage = CrossBattleSelectionData.Instance():GetCurFightStage()
  local stageInfo = {
    {
      stage = CrossBattleSelectionStageEnum._32_TO_16,
      stageName = textRes.CrossBattle.CrossBattleSelection.BattleType[1]
    },
    {
      stage = CrossBattleSelectionStageEnum._16_TO_8,
      stageName = textRes.CrossBattle.CrossBattleSelection.BattleType[2]
    },
    {
      stage = CrossBattleSelectionStageEnum._8_TO_4,
      stageName = textRes.CrossBattle.CrossBattleSelection.BattleType[3]
    },
    {
      stage = CrossBattleSelectionStageEnum._4_TO_2,
      stageName = textRes.CrossBattle.CrossBattleSelection.BattleType[4]
    },
    {
      stage = CrossBattleSelectionStageEnum.THIRD,
      stageName = textRes.CrossBattle.CrossBattleSelection.BattleType[5]
    },
    {
      stage = CrossBattleSelectionStageEnum.CHAMPION,
      stageName = textRes.CrossBattle.CrossBattleSelection.BattleType[6]
    }
  }
  local corpsData = CrossBattleSelectionData.Instance():GetSelectionFightCorpsInfo()
  local fightInfo = CrossBattleSelectionData.Instance():GetSelectionFightInfo()
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  require("Main.CrossBattle.Selection.ui.CrossBattleSelectionFightInfoPanel").Instance():ShowPanel(curStage, stageInfo, corpsData, fightInfo, crossBattleCfg and crossBattleCfg.selection_match_tips_id or 0)
end
def.method("=>", "boolean").IsCrossBattleSelectionPrepareTime = function(self)
  if CrossBattleSelectionData.Instance():IsDuringRescheduleSelection() then
    return true
  end
  local stage = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  if stage == 0 then
    return false
  end
  local selectionCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if selectionCfg == nil then
    return false
  end
  local timePointCfgId = selectionCfg.selection_stage_time[stage]
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
  local prepareTime = startTime - selectionCfg.selection_countdown * 60
  local serverTime = _G.GetServerTime()
  return prepareTime <= serverTime and startTime >= serverTime
end
CrossBattleSelectionMgr.Commit()
return CrossBattleSelectionMgr
