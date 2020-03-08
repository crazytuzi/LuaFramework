local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CrossBattleBetUtils = Lplus.Class(MODULE_NAME)
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local def = CrossBattleBetUtils.define
def.static("number", "=>", "table").GetRoundRobinBetCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_ROUND_ROBIN_BET_CFG, id)
  if record == nil then
    warn("GetRoundRobinBetCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.moduleid = record:GetIntValue("moduleid")
  cfg.bet_level_limit = record:GetIntValue("bet_level_limit")
  cfg.tips_id = record:GetIntValue("tips_id")
  cfg.win_rate_of_return = record:GetFloatValue("win_rate_of_return")
  cfg.lose_rate_of_return = record:GetFloatValue("lose_rate_of_return")
  cfg.tie_rate_of_return = record:GetFloatValue("tie_rate_of_return")
  cfg.bet_cost_type = record:GetIntValue("bet_cost_type")
  if cfg.bet_cost_type == nil then
    cfg.bet_cost_type = MoneyType.GOLD
  end
  cfg.stakes = {}
  local bet_infosStruct = record:GetStructValue("bet_infosStruct")
  local size = bet_infosStruct:GetVectorSize("bet_infos")
  for i = 0, size - 1 do
    local vectorRow = bet_infosStruct:GetVectorValueByIdx("bet_infos", i)
    local stake = {}
    stake.sortId = vectorRow:GetIntValue("sortid")
    stake.num = vectorRow:GetIntValue("money_num")
    stake.type = cfg.bet_cost_type
    table.insert(cfg.stakes, stake)
  end
  table.sort(cfg.stakes, function(l, r)
    return l.sortId < r.sortId
  end)
  return cfg
end
def.static("number", "=>", "table").GetSelectionBetCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_SELECTION_BET_CFG, id)
  if record == nil then
    warn("GetSelectionBetCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.moduleid = record:GetIntValue("moduleid")
  cfg.bet_level_limit = record:GetIntValue("bet_level_limit")
  cfg.tips_id = record:GetIntValue("tips_id")
  cfg.win_multiple = record:GetFloatValue("win_multiple")
  cfg.bet_cost_type = record:GetIntValue("bet_cost_type")
  if cfg.bet_cost_type == nil then
    cfg.bet_cost_type = MoneyType.GOLD
  end
  cfg.max_win_money = record:GetIntValue("max_return_money_num")
  cfg.stakes = {}
  local bet_infosStruct = record:GetStructValue("bet_infosStruct")
  local size = bet_infosStruct:GetVectorSize("bet_infos")
  for i = 0, size - 1 do
    local vectorRow = bet_infosStruct:GetVectorValueByIdx("bet_infos", i)
    local stake = {}
    stake.sortId = vectorRow:GetIntValue("sortid")
    stake.num = vectorRow:GetIntValue("money_num")
    stake.type = cfg.bet_cost_type
    table.insert(cfg.stakes, stake)
  end
  table.sort(cfg.stakes, function(l, r)
    return l.sortId < r.sortId
  end)
  return cfg
end
def.static("number", "=>", "table").GetFinalBetCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CROSS_BATTLE_FINAL_BET_CFG, id)
  if record == nil then
    warn("GetFinalBetCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.moduleid = record:GetIntValue("moduleid")
  cfg.bet_level_limit = record:GetIntValue("bet_level_limit")
  cfg.tips_id = record:GetIntValue("tips_id")
  cfg.win_multiple = record:GetFloatValue("win_multiple")
  cfg.bet_cost_type = record:GetIntValue("bet_cost_type")
  if cfg.bet_cost_type == nil then
    cfg.bet_cost_type = MoneyType.GOLD
  end
  cfg.max_win_money = record:GetIntValue("max_return_money_num")
  cfg.stakes = {}
  local bet_infosStruct = record:GetStructValue("bet_infosStruct")
  local size = bet_infosStruct:GetVectorSize("bet_infos")
  for i = 0, size - 1 do
    local vectorRow = bet_infosStruct:GetVectorValueByIdx("bet_infos", i)
    local stake = {}
    stake.sortId = vectorRow:GetIntValue("sortid")
    stake.num = vectorRow:GetIntValue("money_num")
    stake.type = cfg.bet_cost_type
    table.insert(cfg.stakes, stake)
  end
  table.sort(cfg.stakes, function(l, r)
    return l.sortId < r.sortId
  end)
  return cfg
end
def.static("number", "=>", "string").GetCrossBattleFinalBetNameByStage = function(stage)
  local battleCountPerStage = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr").STAGE_BATTLE_COUNT
  local battleStage = math.floor((stage - 1) / battleCountPerStage) + 1
  local round = (stage - 1) % battleCountPerStage + 1
  if textRes.CrossBattle.CrossBattleFinal.BattleType[battleStage] == nil then
    return "stage_" .. stage
  else
    return textRes.CrossBattle.CrossBattleFinal.BattleType[battleStage] .. string.format(textRes.CrossBattle.CrossBattleFinal[18], round)
  end
end
return CrossBattleBetUtils.Commit()
