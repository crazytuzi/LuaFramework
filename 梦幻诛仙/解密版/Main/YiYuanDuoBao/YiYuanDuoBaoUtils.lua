local Lplus = require("Lplus")
local YiYuanDuoBaoUtils = Lplus.Class("YiYuanDuoBaoUtils")
local def = YiYuanDuoBaoUtils.define
def.static("=>", "number").GetCurActivityId = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_YIYUANDUOBAO_CFG)
  if entries == nil then
    warn("GetCurActivityId 0")
    return 0
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local activityId = entry:GetIntValue("activity_cfg_id")
    local open = ActivityInterface.Instance():IsInTime(activityId)
    if open then
      return activityId
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return 0
end
def.static("number", "=>", "boolean").IsYiYuanDuoBaoActivity = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_YIYUANDUOBAO_CFG, activityId)
  if record == nil then
    return false
  else
    return true
  end
end
def.static("number", "=>", "table").GetActivityCfg = function(activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_YIYUANDUOBAO_CFG, activityId)
  if record == nil then
    warn("GetActivityCfg nil", activityId)
    return nil
  end
  local cfg = {}
  cfg.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  cfg.lottery_item_cfg_id = record:GetIntValue("lottery_item_cfg_id")
  cfg.turns = {}
  local turnStruct = record:GetStructValue("turnStruct")
  local turnSize = DynamicRecord.GetVectorSize(turnStruct, "turnList")
  for i = 0, turnSize - 1 do
    local entry = DynamicRecord.GetVectorValueByIdx(turnStruct, "turnList", i)
    local turn = {}
    turn.turn = entry:GetIntValue("turn")
    turn.diaplay_turn = entry:GetIntValue("diaplay_turn")
    turn.begin_timestamp = entry:GetIntValue("begin_timestamp")
    turn.end_timestamp = entry:GetIntValue("end_timestamp")
    turn.awards = {}
    local awardStruct = entry:GetStructValue("awardStruct")
    local awardSize = DynamicRecord.GetVectorSize(awardStruct, "awardList")
    for i = 0, awardSize - 1 do
      local ety = DynamicRecord.GetVectorValueByIdx(awardStruct, "awardList", i)
      local award = {}
      award.sortid = ety:GetIntValue("sortid")
      award.cost_money_type = ety:GetIntValue("cost_money_type")
      award.cost_money_num = ety:GetIntValue("cost_money_num")
      award.attend_fix_award_id = ety:GetIntValue("attend_fix_award_id")
      award.fix_award_id = ety:GetIntValue("fix_award_id")
      award.init_award_num = ety:GetIntValue("init_award_num")
      award.extra_award_need_num = ety:GetIntValue("extra_award_need_num")
      award.ratio = ety:GetIntValue("expansion_factor_percentage") / 100
      table.insert(turn.awards, award)
    end
    table.insert(cfg.turns, turn)
  end
  return cfg
end
def.static("number", "number", "=>", "table").GetTurnCfg = function(activityId, turnId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_YIYUANDUOBAO_CFG, activityId)
  if record == nil then
    warn("GetTurnCfg nil", activityId, turnId)
    return nil
  end
  local turnStruct = record:GetStructValue("turnStruct")
  local entry = DynamicRecord.GetVectorValueByIdx(turnStruct, "turnList", turnId - 1)
  if entry == nil then
    warn("GetTurnCfg nil", activityId, turnId)
    return nil
  end
  local turn = {}
  turn.turn = entry:GetIntValue("turn")
  turn.diaplay_turn = entry:GetIntValue("diaplay_turn")
  turn.begin_timestamp = entry:GetIntValue("begin_timestamp")
  turn.end_timestamp = entry:GetIntValue("end_timestamp")
  turn.awards = {}
  local awardStruct = entry:GetStructValue("awardStruct")
  local awardSize = DynamicRecord.GetVectorSize(awardStruct, "awardList")
  for i = 0, awardSize - 1 do
    local ety = DynamicRecord.GetVectorValueByIdx(awardStruct, "awardList", i)
    local award = {}
    award.sortid = ety:GetIntValue("sortid")
    award.cost_money_type = ety:GetIntValue("cost_money_type")
    award.cost_money_num = ety:GetIntValue("cost_money_num")
    award.attend_fix_award_id = ety:GetIntValue("attend_fix_award_id")
    award.fix_award_id = ety:GetIntValue("fix_award_id")
    award.init_award_num = ety:GetIntValue("init_award_num")
    award.extra_award_need_num = ety:GetIntValue("extra_award_need_num")
    award.ratio = ety:GetIntValue("expansion_factor_percentage") / 100
    table.insert(turn.awards, award)
  end
  return turn
end
def.static("number", "number", "number", "=>", "table").GetAwardCfg = function(activityId, turnId, sortId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_YIYUANDUOBAO_CFG, activityId)
  if record == nil then
    warn("GetAwardCfg nil", activityId, turnId, sortId)
    return nil
  end
  local turnStruct = record:GetStructValue("turnStruct")
  local entry = DynamicRecord.GetVectorValueByIdx(turnStruct, "turnList", turnId - 1)
  if entry == nil then
    warn("GetAwardCfg nil", activityId, turnId, sortId)
    return nil
  end
  local awardStruct = entry:GetStructValue("awardStruct")
  local ety = DynamicRecord.GetVectorValueByIdx(awardStruct, "awardList", sortId - 1)
  if entry == nil then
    warn("GetAwardCfg nil", activityId, turnId, sortId)
    return nil
  end
  local award = {}
  award.sortid = ety:GetIntValue("sortid")
  award.cost_money_type = ety:GetIntValue("cost_money_type")
  award.cost_money_num = ety:GetIntValue("cost_money_num")
  award.attend_fix_award_id = ety:GetIntValue("attend_fix_award_id")
  award.fix_award_id = ety:GetIntValue("fix_award_id")
  award.init_award_num = ety:GetIntValue("init_award_num")
  award.extra_award_need_num = ety:GetIntValue("extra_award_need_num")
  award.ratio = ety:GetIntValue("expansion_factor_percentage") / 100
  return award
end
def.static("number", "number", "=>", "number", "number", "number").GetTurn = function(activityId, curTime)
  local actCfg = YiYuanDuoBaoUtils.GetActivityCfg(activityId)
  if actCfg == nil then
    return -1, 0, 0
  end
  for k, v in ipairs(actCfg.turns) do
    if curTime < v.begin_timestamp then
      return 0, k, v.begin_timestamp
    elseif curTime >= v.begin_timestamp and curTime < v.end_timestamp then
      return 1, k, v.end_timestamp
    end
  end
  return 2, 0, 0
end
def.static("number", "number", "=>", "number", "number").GetTurnToday = function(activityId, turn)
  local activityCfg = YiYuanDuoBaoUtils.GetActivityCfg(activityId)
  if activityCfg then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local turnCfg = activityCfg.turns[turn]
    if turnCfg then
      local startTime, endTime = turnCfg.begin_timestamp, turnCfg.end_timestamp
      local timeTbl = AbsoluteTimer.GetServerTimeTable(turnCfg.begin_timestamp)
      local year, yday = timeTbl.year, timeTbl.yday
      for k, v in ipairs(activityCfg.turns) do
        if k ~= turn then
          local timeTbl = AbsoluteTimer.GetServerTimeTable(v.begin_timestamp)
          local vyear, vyday = timeTbl.year, timeTbl.yday
          if year == vyday and yday == vyday then
            if startTime > v.begin_timestamp then
              startTime = v.begin_timestamp
            end
            if endTime < v.end_timestamp then
              endTime = v.end_timestamp
            end
          end
        end
      end
      return startTime, endTime
    else
      return 0, 0
    end
  else
    return 0, 0
  end
end
def.static("number", "=>", "table").GetActivityCfgByDay = function(activityId)
  local activityCfg = YiYuanDuoBaoUtils.GetActivityCfg(activityId)
  if activityCfg == nil then
    return nil
  end
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local days = {}
  local curDay
  for k, v in ipairs(activityCfg.turns) do
    local vTimeTbl = AbsoluteTimer.GetServerTimeTable(v.begin_timestamp)
    if curDay == nil or curDay.day ~= vTimeTbl.day then
      if curDay then
        table.insert(days, curDay)
      end
      curDay = {
        day = vTimeTbl.day,
        turns = {}
      }
    end
    table.insert(curDay.turns, v)
  end
  if curDay then
    table.insert(days, curDay)
  end
  return days
end
def.static("number", "number", "=>", "number").ConvertToDisplayNumber = function(realNum, offset)
  local TOPBIT = 28
  local switchHighPos = TOPBIT
  if offset <= 26 then
    switchHighPos = TOPBIT - offset
  end
  local displayNum = 0
  for i = 0, math.ceil(switchHighPos / 2) - 1 do
    local lowBitPos = i
    local highBitPos = switchHighPos - i
    displayNum = bit.bor(displayNum, bit.lshift(bit.band(realNum, bit.lshift(1, lowBitPos)), highBitPos - lowBitPos))
    displayNum = bit.bor(displayNum, bit.rshift(bit.band(realNum, bit.lshift(1, highBitPos)), highBitPos - lowBitPos))
  end
  local notBit = 0
  for i = TOPBIT, TOPBIT - offset + 1, -1 do
    notBit = bit.bor(notBit, bit.lshift(1, i))
  end
  displayNum = bit.bxor(displayNum, notBit)
  return displayNum
end
def.static("number", "number", "=>", "number").CalcOffset = function(turn, sortId)
  return (turn - 1) % 3 * 3 + sortId
end
YiYuanDuoBaoUtils.Commit()
return YiYuanDuoBaoUtils
