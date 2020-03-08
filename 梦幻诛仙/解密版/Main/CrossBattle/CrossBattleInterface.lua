local Lplus = require("Lplus")
local CrossBattleInterface = Lplus.Class("CrossBattleInterface")
local CrossBattleCostType = require("consts/mzm/gsp/crossbattle/confbean/CrossBattleCostType")
local ItemModule = require("Main.Item.ItemModule")
local ActivityInterface = require("Main.activity.ActivityInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local RoundRobinRoundStage = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinRoundStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local def = CrossBattleInterface.define
local instance
def.field("boolean").isActivityOpen = false
def.field("boolean").isApply = false
def.field("table").crossBattleRankList = nil
def.field("table").myRankInfo = nil
def.field("number").vote_times = 0
def.field("table").voteDirectPromotionCorpsList = nil
def.field("table").roundRobinPointRankList = nil
def.field("number").roundRobinRoundIdx = 0
def.field("number").roundRobinRoundStage = -1
def.field("table").roundRobinStagePromotionCorpsList = nil
def.field("table").roundRobinFightInfo = nil
def.field("table").stageOpenFnTable = nil
def.field("number").canvass_timestamp = 0
def.field("number").roundRobinMapId = 0
def.field("number").restartIndex = 0
def.field("number").restartTime = 0
def.field("function").getRegisterRoldListCallback = nil
def.static("=>", CrossBattleInterface).Instance = function()
  if instance == nil then
    instance = CrossBattleInterface()
  end
  return instance
end
def.method().Reset = function(self)
  self.isActivityOpen = false
  self.isApply = false
  self.crossBattleRankList = nil
  self.myRankInfo = nil
  self.vote_times = 0
  self.voteDirectPromotionCorpsList = nil
  self.roundRobinPointRankList = nil
  self.roundRobinRoundIdx = 0
  self.roundRobinRoundStage = -1
  self.roundRobinStagePromotionCorpsList = nil
  self.roundRobinFightInfo = nil
  self.canvass_timestamp = 0
  self.roundRobinMapId = 0
  self.restartIndex = 0
  self.restartTime = 0
  self.getRegisterRoldListCallback = nil
end
def.static("number", "=>", "table").GetCrossBattleCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_CFG, activityId)
  if record == nil then
    warn("!!!!!!!!!!!GetCrossBattleCfg is nil:", activityId)
    return nil
  end
  local cfg = {}
  cfg.activity_cfg_id = activityId
  cfg.desc = record:GetStringValue("desc")
  cfg.moduleid = record:GetIntValue("moduleid")
  cfg.serverlevel = record:GetIntValue("serverlevel")
  cfg.npc_id = record:GetIntValue("npc_id")
  cfg.npc_service_id = record:GetIntValue("npc_service_id")
  cfg.npc_controller_id = record:GetIntValue("npc_controller_id")
  cfg.register_corps_member_num_lower_limit = record:GetIntValue("register_corps_member_num_lower_limit")
  cfg.register_corps_member_num_upper_limit = record:GetIntValue("register_corps_member_num_upper_limit")
  cfg.register_cost_type = record:GetIntValue("register_cost_type")
  cfg.register_cost_num = record:GetIntValue("register_cost_num")
  cfg.register_stage_moduleid = record:GetIntValue("register_stage_moduleid")
  cfg.register_stage_remind_time_points = {}
  local rec2 = record:GetStructValue("register_stage_remind_time_points_struct")
  local count = rec2:GetVectorSize("register_stage_remind_time_points")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("register_stage_remind_time_points", i - 1)
    local hour = rec3:GetIntValue("hour")
    if hour then
      table.insert(cfg.register_stage_remind_time_points, hour)
    end
  end
  cfg.register_stage_remind_content = record:GetStringValue("register_stage_remind_content")
  cfg.vote_level_limit = record:GetIntValue("vote_level_limit")
  cfg.daily_vote_times_limit = record:GetIntValue("daily_vote_times_limit")
  cfg.vote_fix_award_id = record:GetIntValue("vote_fix_award_id")
  cfg.canvass_trumpet_cfg_id = record:GetIntValue("canvass_trumpet_cfg_id")
  cfg.vote_stage_direct_promotion_corps_num = record:GetIntValue("vote_stage_direct_promotion_corps_num")
  cfg.round_robin_stage_promotion_corps_num = record:GetIntValue("round_robin_stage_promotion_corps_num")
  cfg.round_robin_max_corps_num = record:GetIntValue("round_robin_max_corps_num")
  cfg.vote_stage_rank_page_num = record:GetIntValue("vote_stage_rank_page_num")
  cfg.vote_stage_tips_id = record:GetIntValue("vote_stage_tips_id")
  cfg.vote_stage_moduleid = record:GetIntValue("vote_stage_moduleid")
  cfg.round_robin_stage_prepare_duration_in_minute = record:GetIntValue("round_robin_stage_prepare_duration_in_minute")
  cfg.round_robin_stage_fight_max_duration_in_minute = record:GetIntValue("round_robin_stage_fight_max_duration_in_minute")
  cfg.round_robin_map_cfg_id = record:GetIntValue("round_robin_map_cfg_id")
  cfg.round_robin_map_transfer_x = record:GetIntValue("round_robin_map_transfer_x")
  cfg.round_robin_map_transfer_y = record:GetIntValue("round_robin_map_transfer_y")
  cfg.round_robin_out_map_cfg_id = record:GetIntValue("round_robin_out_map_cfg_id")
  cfg.round_robin_out_map_transfer_x = record:GetIntValue("round_robin_out_map_transfer_x")
  cfg.round_robin_out_map_transfer_y = record:GetIntValue("round_robin_out_map_transfer_y")
  cfg.round_robin_out_npc_id = record:GetIntValue("round_robin_out_npc_id")
  cfg.round_robin_out_npc_service_id = record:GetIntValue("round_robin_out_npc_service_id")
  cfg.round_robin_win_point = record:GetIntValue("round_robin_win_point")
  cfg.round_robin_lose_point = record:GetIntValue("round_robin_lose_point")
  cfg.round_robin_stage_moduleid = record:GetIntValue("round_robin_stage_moduleid")
  cfg.round_robin_time_points = {}
  local rec2 = record:GetStructValue("round_robin_time_points_struct")
  local count = rec2:GetVectorSize("round_robin_time_points")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("round_robin_time_points", i - 1)
    local timeId = rec3:GetIntValue("timeId")
    if timeId then
      table.insert(cfg.round_robin_time_points, timeId)
    end
  end
  cfg.round_robin_stage_tips_id = record:GetIntValue("round_robin_stage_tips_id")
  cfg.round_robin_backup_time_points = {}
  local rec2 = record:GetStructValue("round_robin_backup_time_points_struct")
  local count = rec2:GetVectorSize("round_robin_backup_time_points")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("round_robin_backup_time_points", i - 1)
    local timeId = rec3:GetIntValue("timeId")
    if timeId then
      table.insert(cfg.round_robin_backup_time_points, timeId)
    end
  end
  return cfg
end
def.static("number", "=>", "table").GetCrossBattleStageDurationCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_STAGE_DURATION_CFG, activityId)
  if record == nil then
    warn("GetCrossBattleStageDurationCfg is nil:", activityId)
    return nil
  end
  local cfg = {}
  cfg.activity_cfg_id = activityId
  cfg.registerStageDurationInDay = record:GetIntValue("registerStageDurationInDay")
  cfg.voteStageDurationInDay = record:GetIntValue("voteStageDurationInDay")
  cfg.roundRobinStageDurationInDay = record:GetIntValue("roundRobinStageDurationInDay")
  cfg.zoneDivideStageDurationInDay = record:GetIntValue("zoneDivideStageDurationInDay")
  cfg.zonePointStageDurationInDay = record:GetIntValue("zonePointStageDurationInDay")
  cfg.roundSelectionStageDurationInDay = record:GetIntValue("roundSelectionStageDurationInDay")
  cfg.roundFinalStageDurationInDay = record:GetIntValue("roundFinalStageDurationInDay")
  return cfg
end
def.static("number", "=>", "table").GetCrossBattleSelectionCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_SELECTION_CFG, activityId)
  if record == nil then
    warn("GetCrossBattleSelectionCfg is nil:", activityId)
    return nil
  end
  local cfg = {}
  cfg.activity_cfg_id = activityId
  cfg.moduleid = record:GetIntValue("module_id")
  cfg.selection_map_cfg_id = record:GetIntValue("selection_map_cfg_id")
  cfg.selection_map_transfer_x = record:GetIntValue("selection_map_transfer_x")
  cfg.selection_map_transfer_y = record:GetIntValue("selection_map_transfer_y")
  cfg.selection_out_map_cfg_id = record:GetIntValue("selection_out_map_cfg_id")
  cfg.selection_out_map_transfer_x = record:GetIntValue("selection_out_map_transfer_x")
  cfg.selection_out_map_transfer_y = record:GetIntValue("selection_out_map_transfer_y")
  cfg.selection_out_npc_id = record:GetIntValue("selection_out_npc_id")
  cfg.selection_out_npc_service_id = record:GetIntValue("selection_out_npc_service_id")
  cfg.selection_match_tips_id = record:GetIntValue("selection_match_tips_id")
  cfg.selection_match_cfg_id = record:GetIntValue("selection_match_cfg_id")
  cfg.selection_countdown = record:GetIntValue("selection_countdown")
  cfg.selection_match_countdown = record:GetIntValue("selection_match_countdown")
  cfg.selection_stage_time = {}
  local struct = record:GetStructValue("selection_stage_time_struct")
  local count = struct:GetVectorSize("selection_stage_time_list")
  for i = 1, count do
    local record = struct:GetVectorValueByIdx("selection_stage_time_list", i - 1)
    local selection_stage = record:GetIntValue("selection_stage")
    local selection_time = record:GetIntValue("selection_time")
    cfg.selection_stage_time[selection_stage] = selection_time
  end
  cfg.selection_match_special_effect_id = record:GetIntValue("selection_match_special_effect_id")
  cfg.special_effect_list = {}
  local effectStruct = record:GetStructValue("special_effect_struct")
  local effectCount = effectStruct:GetVectorSize("special_effect_list")
  for i = 1, effectCount do
    local record = effectStruct:GetVectorValueByIdx("special_effect_list", i - 1)
    local stage_effect_id = record:GetIntValue("stage_effect_id")
    table.insert(cfg.special_effect_list, stage_effect_id)
  end
  cfg.selection_fight_last_time = record:GetIntValue("selection_fight_last_time")
  return cfg
end
def.static("=>", "number").GetTodayCrossBattleSelectionStage = function()
  local serverTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local date = AbsoluteTimer.GetServerTimeTable(serverTime)
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local selectionCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(activityId)
  if selectionCfg == nil then
    return 0
  end
  for stage, timeId in pairs(selectionCfg.selection_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint == nil then
      return 0
    end
    if date.year == timePoint.year and date.month == timePoint.month and date.day == timePoint.day then
      return stage
    end
  end
  return 0
end
def.static("number", "=>", "number").GetCrossBattleSelectionTimeByStage = function(stage)
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local selectionCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(activityId)
  if selectionCfg == nil then
    return 0
  end
  local timePointCfgId = selectionCfg.selection_stage_time[stage]
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
def.static("=>", "table").GetReachedCrossBattleSelectionStage = function()
  local serverTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local selectionCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(activityId)
  if selectionCfg == nil then
    return {}
  end
  local stages = {}
  for stage, timeId in pairs(selectionCfg.selection_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint ~= nil then
      local t = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, 0, 0, 0)
      if serverTime > t then
        table.insert(stages, stage)
      end
    end
  end
  return stages
end
def.method("=>", "boolean").isCrossBattleOpen = function(self)
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local activityInterface = ActivityInterface.Instance()
  if not activityInterface:isAchieveActivityLevel(activityId) then
    return false
  end
  if not activityInterface:isActivityOpend2(activityId) then
    return false
  end
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(activityId)
  if not _G.IsFeatureOpen(crossBattleCfg.moduleid) then
    return false
  end
  return true
end
def.static("number", "=>", "table").GetCrossBattleSelectionMatchCfg = function(cfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_SELECTION_MATCH_CFG, cfgId)
  if record == nil then
    warn("GetCrossBattleSelectionMatchCfg is nil:", cfgId)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.selection_match_list = {}
  local struct = record:GetStructValue("selection_match_struct")
  local count = struct:GetVectorSize("selection_match_list")
  for i = 1, count do
    local record = struct:GetVectorValueByIdx("selection_match_list", i - 1)
    local corps_a_rank = record:GetIntValue("corps_a_rank")
    local corps_b_rank = record:GetIntValue("corps_b_rank")
    local match = {}
    match.corps_a_rank = corps_a_rank
    match.corps_b_rank = corps_b_rank
    table.insert(cfg.selection_match_list, match)
  end
  return cfg
end
def.method("number", "=>", "number", "number").getCrossBattleStageTime = function(self, stage)
  local crossConst = constant.CrossBattleConsts
  local openTime, _, closedTime = ActivityInterface.Instance():getActivityStatusChangeTime(crossConst.CURRENT_ACTIVITY_CFG_ID)
  local applyEndTime = openTime + crossConst.REGISTER_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_REGISTER then
    return openTime, applyEndTime
  end
  local voteEndTime = applyEndTime + crossConst.VOTE_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_VOTE then
    return applyEndTime, voteEndTime
  end
  local roundRobinEndTime = voteEndTime + crossConst.ROUND_ROBIN_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    return voteEndTime, roundRobinEndTime
  end
  local divideStageEndTime = roundRobinEndTime + crossConst.ZONE_DIVIDE_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_ZONE_DIVIDE then
    return roundRobinEndTime, divideStageEndTime
  end
  local pointStageEndTime = divideStageEndTime + crossConst.ZONE_POINT_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_ZONE_POINT then
    return divideStageEndTime, pointStageEndTime
  end
  local selectionStageEndTime = pointStageEndTime + crossConst.ROUND_SELECTION_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_SELECTION then
    return pointStageEndTime, selectionStageEndTime
  end
  local finalStageEndTime = selectionStageEndTime + crossConst.ROUND_FINAL_STAGE_DURATION_IN_DAY * 86400
  if stage == CrossBattleActivityStage.STAGE_FINAL then
    return selectionStageEndTime, finalStageEndTime
  end
  return 0, 0
end
def.method("=>", "number").getCurCrossBattleStage = function(self)
  local curTime = _G.GetServerTime()
  for i = 0, CrossBattleActivityStage.STAGE_FINAL do
    local startTime, endTime = self:getCrossBattleStageTime(i)
    if curTime >= startTime and curTime < endTime then
      return i
    end
  end
  return -1
end
def.method("=>", "number", "number", "userdata").getCrossBattleApplyCostInfo = function(self)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local costType = 0
  local ownNum = 0
  local costNum = 0
  if crossBattleCfg then
    costType = crossBattleCfg.register_cost_type
    costNum = crossBattleCfg.register_cost_num
    if costType == CrossBattleCostType.YUANBAO then
      ownNum = ItemModule.Instance():GetAllYuanBao()
    elseif costType == CrossBattleCostType.GOLD then
      ownNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    elseif costType == CrossBattleCostType.SILVER then
      ownNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    end
  end
  return costType, costNum, ownNum
end
def.method("=>", "boolean").isApplyCrossBattle = function(self)
  return self.isApply
end
def.method("=>", "number").getLeftVoteTimes = function(self)
  if self:isAchieveVoteLevel() then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return crossBattleCfg.daily_vote_times_limit - self.vote_times
  end
  return 0
end
def.method("userdata", "=>", "table").getRankInfoByCorpsId = function(self, corpsId)
  if self.crossBattleRankList then
    for i, v in ipairs(self.crossBattleRankList) do
      if v.corps_brief_info.corpsId:eq(corpsId) then
        return v
      end
    end
  end
  return nil
end
def.method("number", "number", "table").addRoundRobinFightInfo = function(self, index, stage, fightInfos)
  local curRoundRobinInfo = self.roundRobinFightInfo or {}
  curRoundRobinInfo[index] = {stage = stage, fightInfos = fightInfos}
  self.roundRobinFightInfo = curRoundRobinInfo
end
def.method("number", "=>", "table").getRoundRobinFightInfo = function(self, index)
  if self.roundRobinFightInfo then
    return self.roundRobinFightInfo[index]
  end
  return nil
end
def.method("number", "=>", "number", "number").getRoundRobinTimeByIndex = function(self, idx)
  local curTime = _G.GetServerTime()
  if self.restartIndex > 0 then
    local readyTime, startTime = self:getRestartRoundRobindTime()
    if readyTime > 0 and startTime > 0 and curTime >= readyTime and curTime < startTime then
      return readyTime, startTime
    end
  end
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local id = crossBattleCfg.round_robin_time_points[idx]
  if id == nil then
    return 0, 0
  end
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(id)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local serverTime = AbsoluteTimer.GetServerTimeByDate(timePointCfg.year, timePointCfg.month, timePointCfg.day, timePointCfg.hour, timePointCfg.min, timePointCfg.sec)
  if curTime > serverTime and idx == self.roundRobinRoundIdx and self.roundRobinRoundStage < RoundRobinRoundStage.STAGE_FIGHT then
    local backId = crossBattleCfg.round_robin_backup_time_points[idx]
    local backTimePointCfg = TimeCfgUtils.GetCommonTimePointCfg(backId)
    serverTime = AbsoluteTimer.GetServerTimeByDate(backTimePointCfg.year, backTimePointCfg.month, backTimePointCfg.day, backTimePointCfg.hour, backTimePointCfg.min, backTimePointCfg.sec)
  end
  return serverTime - crossBattleCfg.round_robin_stage_prepare_duration_in_minute * 60, serverTime
end
def.method("=>", "table").getTodayRoundRobinIndexList = function(self)
  local list = {}
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local curTime = _G.GetServerTime()
  local nYear = tonumber(os.date("%Y", curTime))
  local nMonth = tonumber(os.date("%m", curTime))
  local nDay = tonumber(os.date("%d", curTime))
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  for i, v in ipairs(crossBattleCfg.round_robin_time_points) do
    local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(v)
    if nYear == timePointCfg.year and nMonth == timePointCfg.month and nDay == timePointCfg.day then
      table.insert(list, i)
    end
  end
  return list
end
def.method("=>", "number", "number").getRestartRoundRobindTime = function(self)
  if self.restartIndex > 0 and 0 < self.restartTime then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    return self.restartTime - crossBattleCfg.round_robin_stage_prepare_duration_in_minute * 60, self.restartTime
  end
  return 0, 0
end
def.method("=>", "boolean").canEnterRoundRobinMap = function(self)
  warn("-------canEnterRoundRobinMap:", self.roundRobinRoundStage, RoundRobinRoundStage.STAGE_PREPARE)
  if self.restartIndex > 0 and 0 < self.restartTime then
    local restartReadTime, restartTime = self:getRestartRoundRobindTime()
    local curTime = _G.GetServerTime()
    if restartReadTime > 0 and restartTime > 0 and restartReadTime <= curTime and restartTime > curTime then
      return true
    end
  end
  return self.roundRobinRoundStage == RoundRobinRoundStage.STAGE_PREPARE
end
def.method("number", "function").registerCrossBattleStageOpenFn = function(self, stage, fn)
  self.stageOpenFnTable = self.stageOpenFnTable or {}
  self.stageOpenFnTable[stage] = fn
end
def.method("number", "=>", "function").getCrossBattleStageFn = function(self, stage)
  if self.stageOpenFnTable and self.stageOpenFnTable[stage] then
    return self.stageOpenFnTable[stage]
  end
  return nil
end
def.method("number", "=>", "boolean", "number").isOpenCrossBattleStage = function(self, stage)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local openId = crossBattleCfg.moduleid
  if not _G.IsFeatureOpen(crossBattleCfg.moduleid) then
    return false, openId
  end
  local stageModuleId
  if stage == CrossBattleActivityStage.STAGE_REGISTER then
    openId = crossBattleCfg.register_stage_moduleid
    stageModuleId = crossBattleCfg.register_stage_moduleid
  elseif stage == CrossBattleActivityStage.STAGE_VOTE then
    openId = crossBattleCfg.vote_stage_moduleid
    stageModuleId = crossBattleCfg.vote_stage_moduleid
  elseif stage == CrossBattleActivityStage.STAGE_ROUND_ROBIN then
    openId = crossBattleCfg.round_robin_stage_moduleid
    stageModuleId = crossBattleCfg.round_robin_stage_moduleid
  elseif stage == CrossBattleActivityStage.STAGE_ZONE_POINT then
    local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
    local pointsCfg = PointsRaceUtils.GetCurrentRaceCfg()
    if pointsCfg == nil then
      return false, openId
    end
    openId = pointsCfg.funSwitch
    stageModuleId = pointsCfg.funSwitch
  elseif stage == CrossBattleActivityStage.STAGE_SELECTION then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    if crossBattleCfg == nil then
      return false, openId
    end
    openId = crossBattleCfg.moduleid
    stageModuleId = crossBattleCfg.moduleid
  elseif stage == CrossBattleActivityStage.STAGE_FINAL then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
    if crossBattleCfg == nil then
      return false, openId
    end
    openId = crossBattleCfg.moduleid
    stageModuleId = crossBattleCfg.moduleid
  end
  if stageModuleId and not _G.IsFeatureOpen(stageModuleId) then
    return false, openId
  end
  return true, 0
end
def.method("=>", "boolean").isAchieveVoteLevel = function(self)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  if heroProp then
    local myLevel = heroProp.level
    if myLevel < crossBattleCfg.vote_level_limit then
      return false
    end
  end
  return true
end
def.method().setCrossBattleVoteRedPoint = function(self)
  self:setCrossBattleActivityRedPoint()
end
def.method("=>", "boolean").isDisplayVoteRedPoint = function(self)
  if not self.isActivityOpen then
    return false
  end
  local curStage = self:getCurCrossBattleStage()
  local isShowRedPoint = false
  if self:isCrossBattleOpen() and self:isAchieveVoteLevel() and curStage == CrossBattleActivityStage.STAGE_VOTE and self:isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_VOTE) then
    local leftVoteNum = self:getLeftVoteTimes()
    isShowRedPoint = leftVoteNum > 0
  end
  return isShowRedPoint
end
def.method("=>", "boolean").isDisplayBetRedPoint = function(self)
  return require("Main.CrossBattle.Bet.CrossBattleBetMgr").Instance():HasBetNotify()
end
def.method().setCrossBattleActivityRedPoint = function(self)
  local voteRedPoint = self:isDisplayVoteRedPoint()
  local isShowRedPoint = voteRedPoint
  isShowRedPoint = isShowRedPoint or self:isDisplayBetRedPoint()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
    activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID,
    isShowRedPoint = isShowRedPoint
  })
end
def.method("=>", "boolean").isInCrossBattleRoundRobinMap = function(self)
  local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
  if self.roundRobinMapId == 0 then
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    self.roundRobinMapId = crossBattleCfg.round_robin_map_cfg_id
  end
  if curMapId == self.roundRobinMapId then
    return true
  end
  return false
end
def.method("=>", "number").getCurRoundRobinIndex = function(self)
  if self.restartIndex > 0 then
    local curTime = _G.GetServerTime()
    local readyTime, startTime = self:getRestartRoundRobindTime()
    if readyTime > 0 and startTime > 0 and curTime >= readyTime and curTime < startTime then
      return self.restartIndex
    end
  end
  return self.roundRobinRoundIdx
end
def.method("userdata", "function").getCorpsRegisterRoleList = function(self, corpsId, callback)
  if self:isCrossBattleOpen() then
    if not self:isApplyCrossBattle() then
      callback({})
      return
    end
    self.getRegisterRoldListCallback = callback
    local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRegisterRoleListReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, corpsId)
    gmodule.network.sendProtocol(p)
    warn("-----------CGetRegisterRoleListReq:", corpsId)
  else
    callback({})
  end
end
def.static("=>", "table").GetCrossBattleCalendarData = function()
  local calendar = {}
  local activityId = constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID
  local activityInterface = ActivityInterface.Instance()
  local starTime = activityInterface:getActivityStatusChangeTime(activityId)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  calendar.signUpDate = {}
  for i = 1, constant.CrossBattleConsts.REGISTER_STAGE_DURATION_IN_DAY do
    local time = starTime + (i - 1) * 86400
    local t = AbsoluteTimer.GetServerTimeTable(time)
    table.insert(calendar.signUpDate, t)
  end
  calendar.voteDate = {}
  for i = 1, constant.CrossBattleConsts.VOTE_STAGE_DURATION_IN_DAY do
    local time = starTime + (constant.CrossBattleConsts.REGISTER_STAGE_DURATION_IN_DAY + i - 1) * 86400
    local t = AbsoluteTimer.GetServerTimeTable(time)
    table.insert(calendar.voteDate, t)
  end
  calendar.roundDate = {}
  local roundCfg = CrossBattleInterface.GetCrossBattleCfg(activityId)
  if roundCfg ~= nil then
    local timePoints = roundCfg.round_robin_time_points
    for i = 1, #timePoints do
      local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timePoints[i])
      table.insert(calendar.roundDate, timePoint)
    end
  end
  calendar.drawLotsDate = {}
  calendar.pointDate = {}
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  local pointsCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if pointsCfg ~= nil then
    for i = 1, #pointsCfg.timePoints do
      local timePoint = TimeCfgUtils.GetCommonTimePointCfg(pointsCfg.timePoints[i])
      table.insert(calendar.pointDate, timePoint)
    end
  end
  calendar.selectionDate = {}
  local selectionCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(activityId)
  if selectionCfg ~= nil then
    for k, v in pairs(selectionCfg.selection_stage_time) do
      local timePoint = TimeCfgUtils.GetCommonTimePointCfg(v)
      table.insert(calendar.selectionDate, timePoint)
    end
  end
  calendar.finalDate = {}
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg ~= nil then
    for k, v in pairs(finalCfg.final_stage_time) do
      local timePoint = TimeCfgUtils.GetCommonTimePointCfg(v)
      table.insert(calendar.finalDate, timePoint)
    end
  end
  return calendar
end
def.static("=>", "table").GetCrossBattleFinalCfg = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_FINAL_CFG, constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if record == nil then
    warn("GetCrossBattleFinalCfg is nil:", activityId)
    return nil
  end
  local cfg = {}
  cfg.activity_cfg_id = activityId
  cfg.moduleid = record:GetIntValue("module_id")
  cfg.final_map_cfg_id = record:GetIntValue("final_map_cfg_id")
  cfg.final_out_npc_id = record:GetIntValue("final_out_npc_id")
  cfg.final_out_npc_service_id = record:GetIntValue("final_out_npc_service_id")
  cfg.final_match_tips_id = record:GetIntValue("final_match_tips_id")
  cfg.final_match_cfg_id = record:GetIntValue("final_match_cfg_id")
  cfg.final_countdown = record:GetIntValue("final_countdown")
  cfg.final_match_countdown = record:GetIntValue("final_match_countdown")
  cfg.final_stage_time = {}
  local struct = record:GetStructValue("final_stage_time_struct")
  local count = struct:GetVectorSize("final_stage_time_point_list")
  for i = 1, count do
    local record = struct:GetVectorValueByIdx("final_stage_time_point_list", i - 1)
    local stage_time = record:GetIntValue("stage_time")
    table.insert(cfg.final_stage_time, stage_time)
  end
  cfg.final_match_special_effect_id = record:GetIntValue("final_match_special_effect_id")
  cfg.special_effect_list = {}
  local effectStruct = record:GetStructValue("special_effect_struct")
  local effectCount = effectStruct:GetVectorSize("final_special_effect_list")
  for i = 1, effectCount do
    local record = effectStruct:GetVectorValueByIdx("final_special_effect_list", i - 1)
    local stage_effect_id = record:GetIntValue("stage_effect_id")
    table.insert(cfg.special_effect_list, stage_effect_id)
  end
  cfg.final_fight_last_time = record:GetIntValue("final_fight_last_time")
  cfg.final_need_team_num = record:GetIntValue("final_need_team_num")
  return cfg
end
def.static("=>", "number").GetTodayCrossBattleFinalStage = function()
  local serverTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local date = AbsoluteTimer.GetServerTimeTable(serverTime)
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return 0
  end
  for stage, timeId in pairs(finalCfg.final_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint == nil then
      return 0
    end
    if date.year == timePoint.year and date.month == timePoint.month and date.day == timePoint.day then
      return stage
    end
  end
  return 0
end
def.static("number", "=>", "number").GetCrossBattleFinalTimeByStage = function(stage)
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
def.method("=>", "number").GetCrossBattleFinalStageCount = function(self)
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return 0
  end
  return finalCfg.final_stage_time and #finalCfg.final_stage_time or 0
end
def.static("=>", "table").GetReachedCrossBattleFinalStage = function()
  local serverTime = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local date = AbsoluteTimer.GetServerTimeTable(serverTime)
  local finalCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if finalCfg == nil then
    return {}
  end
  local stages = {}
  for stage, timeId in pairs(finalCfg.final_stage_time or {}) do
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    if timePoint ~= nil then
      local t = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, 0, 0, 0)
      if serverTime > t then
        table.insert(stages, stage)
      end
    end
  end
  return stages
end
def.method("=>", "boolean").canAttendRoundRobin = function(self)
  local myCorpsInfo = CorpsInterface.GetCorpsBriefData()
  if myCorpsInfo and myCorpsInfo.corpsId then
    local myCorpsId = myCorpsInfo.corpsId
    if self.voteDirectPromotionCorpsList then
      for i, v in ipairs(self.voteDirectPromotionCorpsList) do
        if v:eq(myCorpsId) then
          return true
        end
      end
    end
    if self.roundRobinPointRankList then
      local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
      local promotionNum = crossBattleCfg.round_robin_stage_promotion_corps_num
      for i, v in ipairs(self.roundRobinPointRankList) do
        if i <= promotionNum then
          if v:eq(myCorpsId) then
            return true
          end
        else
          break
        end
      end
    end
  end
  return false
end
def.static("number", "=>", "table").GetCrossBattleAwardPreviewCfg = function(activityId)
  local awards = {}
  local KnockOutTypeEnum = require("consts.mzm.gsp.crossbattle.confbean.KnockOutTypeEnum")
  local selectionAwards = {}
  local selectionAwardIcons = {}
  local selectionAwardTitles = {}
  local selectionAwardRecord = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_AWARD_CFG, KnockOutTypeEnum.SELECTION)
  if selectionAwardRecord == nil then
    warn("GetCrossBattleAwardPreviewCfg selection award is nil")
  else
    local selectionIconStruct = selectionAwardRecord:GetStructValue("iconStruct")
    local selectionIconCount = selectionIconStruct:GetVectorSize("iconList")
    for i = selectionIconCount, 1, -1 do
      local record = selectionIconStruct:GetVectorValueByIdx("iconList", i - 1)
      local icon = record:GetIntValue("icon")
      table.insert(selectionAwardIcons, icon)
    end
    local selectionTitleStruct = selectionAwardRecord:GetStructValue("titleStruct")
    local selectionTitleCount = selectionTitleStruct:GetVectorSize("titleList")
    for i = selectionTitleCount, 1, -1 do
      local record = selectionTitleStruct:GetVectorValueByIdx("titleList", i - 1)
      local title = record:GetStringValue("title")
      table.insert(selectionAwardTitles, title)
    end
    local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_SELECTION_AWARD_CFG, activityId)
    if record == nil then
      warn("GetCrossBattleAwardPreviewCfg selection award detail is nil")
    else
      local awardList = {}
      local struct = record:GetStructValue("awardStruct")
      local count = struct:GetVectorSize("awardList")
      for i = count, 1, -1 do
        local rec = struct:GetVectorValueByIdx("awardList", i - 1)
        local awardId = rec:GetIntValue("awardId")
        table.insert(awardList, awardId)
      end
      for i = 1, #awardList do
        local award = {}
        award.icon = selectionAwardIcons[i]
        award.title = selectionAwardTitles[i]
        award.awardId = awardList[i]
        table.insert(selectionAwards, award)
      end
    end
  end
  local finalAwards = {}
  local finalAwardIcons = {}
  local finalAwardTitles = {}
  local finalAwardRecord = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_AWARD_CFG, KnockOutTypeEnum.FINAL)
  if selectionAwardRecord == nil then
    warn("GetCrossBattleAwardPreviewCfg selection award is nil")
  else
    local finalIconStruct = finalAwardRecord:GetStructValue("iconStruct")
    local finalIconCount = finalIconStruct:GetVectorSize("iconList")
    for i = finalIconCount, 1, -1 do
      local record = finalIconStruct:GetVectorValueByIdx("iconList", i - 1)
      local icon = record:GetIntValue("icon")
      table.insert(finalAwardIcons, icon)
    end
    local finalTitleStruct = finalAwardRecord:GetStructValue("titleStruct")
    local finalTitleCount = finalTitleStruct:GetVectorSize("titleList")
    for i = finalTitleCount, 1, -1 do
      local record = finalTitleStruct:GetVectorValueByIdx("titleList", i - 1)
      local title = record:GetStringValue("title")
      table.insert(finalAwardTitles, title)
    end
    local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_FIANL_AWARD_CFG, activityId)
    if record == nil then
      warn("GetCrossBattleAwardPreviewCfg final award detail is nil")
    else
      local awardList = {}
      local struct = record:GetStructValue("awardStruct")
      local count = struct:GetVectorSize("awardList")
      for i = count, 1, -1 do
        local rec = struct:GetVectorValueByIdx("awardList", i - 1)
        local awardId = rec:GetIntValue("awardId")
        table.insert(awardList, awardId)
      end
      for i = 1, #awardList do
        local award = {}
        award.icon = finalAwardIcons[i]
        award.title = finalAwardTitles[i]
        award.awardId = awardList[i]
        table.insert(finalAwards, award)
      end
    end
  end
  for i = 1, #finalAwards do
    table.insert(awards, finalAwards[i])
  end
  for i = 1, #selectionAwards do
    table.insert(awards, selectionAwards[i])
  end
  return awards
end
return CrossBattleInterface.Commit()
