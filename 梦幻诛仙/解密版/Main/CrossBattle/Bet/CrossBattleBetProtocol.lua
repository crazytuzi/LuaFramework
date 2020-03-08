local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CrossBattleBetProtocol = Lplus.Class(MODULE_NAME)
local BetInfo = import(".data.BetInfo")
local RoundRobinBetInfo = import(".data.RoundRobinBetInfo")
local SelectionBetInfo = import(".data.SelectionBetInfo")
local FinalBetInfo = import(".data.FinalBetInfo")
local CorpsData = require("Main.Corps.CorpsData")
local def = CrossBattleBetProtocol.define
local robinRoundBetInfoReqs, selectionBetInfoReqs, finalBetInfoReqs
def.static().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CrossBattleBetProtocol.OnLeaveWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SBetInRoundRobinSuccess", CrossBattleBetProtocol.OnSBetInRoundRobinSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SBetInRoundRobinFail", CrossBattleBetProtocol.OnSBetInRoundRobinFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoundRobinRoundBetInfoSuccess", CrossBattleBetProtocol.OnSGetRoundRobinRoundBetInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetRoundRobinRoundBetInfoFail", CrossBattleBetProtocol.OnSGetRoundRobinRoundBetInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SBetInSelectionSuccess", CrossBattleBetProtocol.OnSBetInSelectionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SRefreshSelectionFightBetInfo", CrossBattleBetProtocol.OnSRefreshSelectionFightBetInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SBetInSelectionFail", CrossBattleBetProtocol.OnSBetInSelectionFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetSelectionStageBetInfoSuccess", CrossBattleBetProtocol.OnSGetSelectionStageBetInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetSelectionStageBetInfoFail", CrossBattleBetProtocol.OnSGetSelectionStageBetInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SBetInFinalSuccess", CrossBattleBetProtocol.OnSBetInFinalSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SRefreshFinalFightBetInfo", CrossBattleBetProtocol.OnSRefreshFinalFightBetInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SBetInFinalFail", CrossBattleBetProtocol.OnSBetInFinalFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetFinalStageBetInfoSuccess", CrossBattleBetProtocol.OnSGetFinalStageBetInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SGetFinalStageBetInfoFail", CrossBattleBetProtocol.OnSGetFinalStageBetInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.crossbattle.SSynBetTimes", CrossBattleBetProtocol.OnSSynBetTimes)
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  robinRoundBetInfoReqs = nil
  selectionBetInfoReqs = nil
  finalBetInfoReqs = nil
end
local debug = false
local function sendProtocol(p)
  if debug then
    printInfo("[DEBUG] sendProtocol " .. p.class.__cname)
  else
    gmodule.network.sendProtocol(p)
  end
end
def.static("number", "number", "function").CGetRoundRobinRoundBetInfoReq = function(activity_cfg_id, round_index, callback)
  if robinRoundBetInfoReqs == nil then
    robinRoundBetInfoReqs = {
      [activity_cfg_id] = {
        [round_index] = {callback}
      }
    }
  elseif robinRoundBetInfoReqs[activity_cfg_id] == nil then
    robinRoundBetInfoReqs[activity_cfg_id] = {
      [round_index] = {callback}
    }
  elseif robinRoundBetInfoReqs[activity_cfg_id][round_index] == nil then
    robinRoundBetInfoReqs[activity_cfg_id][round_index] = {callback}
  else
    table.insert(robinRoundBetInfoReqs[activity_cfg_id][round_index], callback)
  end
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinRoundBetInfoReq").new(activity_cfg_id, round_index)
  sendProtocol(p)
end
def.static("number", "number", "userdata", "number").CBetInRoundRobinReq = function(activity_cfg_id, round_index, target_corps_id, sortid)
  local p = require("netio.protocol.mzm.gsp.crossbattle.CBetInRoundRobinReq").new(activity_cfg_id, round_index, target_corps_id, sortid)
  sendProtocol(p)
end
def.static("number", "number", "number", "number", "userdata", "number").CBetInSelectionReq = function(activity_cfg_id, fight_zone_id, selection_stage, fight_index, target_corps_id, sortid)
  local p = require("netio.protocol.mzm.gsp.crossbattle.CBetInSelectionReq").new(activity_cfg_id, fight_zone_id, selection_stage, fight_index, target_corps_id, sortid)
  sendProtocol(p)
end
def.static("number", "number", "number", "function").CGetSelectionStageBetInfoReq = function(activity_cfg_id, fight_zone_id, selection_stage, callback)
  local selectionId = CrossBattleBetProtocol.GenSelectionId(fight_zone_id, selection_stage)
  if selectionBetInfoReqs == nil then
    selectionBetInfoReqs = {
      [activity_cfg_id] = {
        [selectionId] = {callback}
      }
    }
  elseif selectionBetInfoReqs[activity_cfg_id] == nil then
    selectionBetInfoReqs[activity_cfg_id] = {
      [selectionId] = {callback}
    }
  elseif selectionBetInfoReqs[activity_cfg_id][selectionId] == nil then
    selectionBetInfoReqs[activity_cfg_id][selectionId] = {callback}
  else
    table.insert(selectionBetInfoReqs[activity_cfg_id][selectionId], callback)
  end
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetSelectionStageBetInfoReq").new(activity_cfg_id, fight_zone_id, selection_stage)
  sendProtocol(p)
end
def.static("number", "number", "number", "userdata", "number").CBetInFinalReq = function(activity_cfg_id, final_stage, fight_index, target_corps_id, sortid)
  local p = require("netio.protocol.mzm.gsp.crossbattle.CBetInFinalReq").new(activity_cfg_id, final_stage, fight_index, target_corps_id, sortid)
  sendProtocol(p)
end
def.static("number", "number", "function").CGetFinalStageBetInfoReq = function(activity_cfg_id, final_stage, callback)
  if finalBetInfoReqs == nil then
    finalBetInfoReqs = {
      [activity_cfg_id] = {
        [final_stage] = {callback}
      }
    }
  elseif finalBetInfoReqs[activity_cfg_id] == nil then
    finalBetInfoReqs[activity_cfg_id] = {
      [final_stage] = {callback}
    }
  elseif finalBetInfoReqs[activity_cfg_id][final_stage] == nil then
    finalBetInfoReqs[activity_cfg_id][final_stage] = {callback}
  else
    table.insert(finalBetInfoReqs[activity_cfg_id][final_stage], callback)
  end
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetFinalStageBetInfoReq").new(activity_cfg_id, final_stage)
  sendProtocol(p)
end
def.static("table").OnSBetInRoundRobinSuccess = function(p)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_ROUND_ROBIN_SUCCESS, {p})
  local text = textRes.CrossBattle.Bet[6]
  Toast(text)
end
def.static("table").OnSBetInRoundRobinFail = function(p)
  local text = textRes.CrossBattle.Bet.SBetInRoundRobinFail[p.res]
  if text == nil then
    text = string.format("OnSBetInRoundRobinFail(%d)", p.res)
  end
  Toast(text)
end
def.static("table").OnSGetRoundRobinRoundBetInfoSuccess = function(p)
  CrossBattleBetProtocol._CallbackRobinRoundBetInfoReqs(p)
end
def.static("table").OnSGetRoundRobinRoundBetInfoFail = function(p)
  if robinRoundBetInfoReqs == nil then
    return
  end
  for k, v in pairs(robinRoundBetInfoReqs) do
    for k, vv in pairs(v) do
      for i, callback in ipairs(vv) do
        _G.SafeCallback(callback, {
          ret = p.res,
          p = nil
        })
      end
    end
  end
  robinRoundBetInfoReqs = nil
  local text = textRes.CrossBattle.Bet.SGetRoundRobinRoundBetInfoFail[p.res]
  if text == nil then
    text = string.format("OnSGetRoundRobinRoundBetInfoFail(%d)", p.res)
  end
  Toast(text)
end
def.static("table").OnSBetInSelectionSuccess = function(p)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_SELECTION_SUCCESS, {p})
  local text = textRes.CrossBattle.Bet[6]
  Toast(text)
end
def.static("table").OnSBetInSelectionFail = function(p)
  local text = textRes.CrossBattle.Bet.SBetInSelectionFail[p.res]
  if text == nil then
    text = string.format("OnSBetInSelectionFail(%d)", p.res)
  end
  Toast(text)
end
def.static("table").OnSGetSelectionStageBetInfoSuccess = function(p)
  CrossBattleBetProtocol._CallbackSelectionBetInfoReqs(p)
end
def.static("table").OnSGetSelectionStageBetInfoFail = function(p)
  if selectionBetInfoReqs == nil then
    return
  end
  for k, v in pairs(selectionBetInfoReqs) do
    for k, vv in pairs(v) do
      for i, callback in ipairs(vv) do
        _G.SafeCallback(callback, {
          ret = p.res,
          p = nil
        })
      end
    end
  end
  selectionBetInfoReqs = nil
  local text = textRes.CrossBattle.Bet.SGetSelectionStageBetInfoFail[p.res]
  if text == nil then
    text = string.format("OnSGetSelectionStageBetInfoFail(%d)", p.res)
  end
  Toast(text)
end
def.static("table").OnSRefreshSelectionFightBetInfo = function(p)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.REFRESH_SELECTION_BET_SUCCESS, {p})
end
def.static("table").OnSBetInFinalSuccess = function(p)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_FINAL_SUCCESS, {p})
  local text = textRes.CrossBattle.Bet[6]
  Toast(text)
end
def.static("table").OnSBetInFinalFail = function(p)
  local text = textRes.CrossBattle.Bet.SBetInFinalFail[p.res]
  if text == nil then
    text = string.format("OnSBetInFinalFail(%d)", p.res)
  end
  Toast(text)
end
def.static("table").OnSGetFinalStageBetInfoSuccess = function(p)
  CrossBattleBetProtocol._CallbackFinalBetInfoReqs(p)
end
def.static("table").OnSGetFinalStageBetInfoFail = function(p)
  if finalBetInfoReqs == nil then
    return
  end
  for k, v in pairs(finalBetInfoReqs) do
    for k, vv in pairs(v) do
      for i, callback in ipairs(vv) do
        _G.SafeCallback(callback, {
          ret = p.res,
          p = nil
        })
      end
    end
  end
  finalBetInfoReqs = nil
  local text = textRes.CrossBattle.Bet.SGetFinalStageBetInfoFail[p.res]
  if text == nil then
    text = string.format("OnSGetFinalStageBetInfoFail(%d)", p.res)
  end
  Toast(text)
end
def.static("table").OnSRefreshFinalFightBetInfo = function(p)
  Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.REFRESH_FINAL_BET_SUCCESS, {p})
end
def.static("table").OnSSynBetTimes = function(p)
  require("Main.CrossBattle.Bet.CrossBattleBetMgr").Instance():SetTodaysBetTimes(p.times)
end
def.static("table")._CallbackRobinRoundBetInfoReqs = function(p)
  if robinRoundBetInfoReqs == nil then
    return
  end
  if robinRoundBetInfoReqs[p.activity_cfg_id] == nil then
    return
  end
  local callbacks = robinRoundBetInfoReqs[p.activity_cfg_id][p.round_index]
  if callbacks == nil then
    return
  end
  robinRoundBetInfoReqs[p.activity_cfg_id][p.round_index] = nil
  for i, callback in ipairs(callbacks) do
    _G.SafeCallback(callback, {
      ret = 0,
      p = CrossBattleBetProtocol.ConvertRobinRoundBetInfos(p)
    })
  end
end
def.static("table", "=>", "table").ConvertRobinRoundBetInfos = function(p)
  local betInfos = {}
  for i, v in ipairs(p.fight_bet_infos) do
    local betInfo = RoundRobinBetInfo.new({})
    betInfo:SetSelfBetMoneyNum(v.role_bet_money_num)
    betInfo:SetMoneyNumOnA(v.corps_a_bet_money_sum)
    betInfo:SetMoneyNumOnB(v.corps_b_bet_money_sum)
    betInfo:SetFightInfo(v.fight_info)
    betInfo:SetRoundIndex(p.round_index)
    betInfo:SetSelfBetCorpsId(v.bet_corps_id)
    table.insert(betInfos, betInfo)
  end
  p.betInfos = betInfos
  return p
end
def.static("table")._CallbackSelectionBetInfoReqs = function(p)
  if selectionBetInfoReqs == nil then
    return
  end
  if selectionBetInfoReqs[p.activity_cfg_id] == nil then
    return
  end
  local selectionId = CrossBattleBetProtocol.GenSelectionId(p.fight_zone_id, p.selection_stage)
  local callbacks = selectionBetInfoReqs[p.activity_cfg_id][selectionId]
  if callbacks == nil then
    return
  end
  selectionBetInfoReqs[p.activity_cfg_id][selectionId] = nil
  for i, callback in ipairs(callbacks) do
    _G.SafeCallback(callback, {
      ret = 0,
      p = CrossBattleBetProtocol.ConvertSelectionBetInfos(p)
    })
  end
end
def.static("table", "=>", "table").ConvertSelectionBetInfos = function(p)
  local strkey_corps_infos = {}
  for k, v in pairs(p.corps_infos) do
    strkey_corps_infos[tostring(k)] = v
  end
  local betInfos = {}
  for i, v in ipairs(p.fight_bet_infos) do
    local betInfo = SelectionBetInfo.new({})
    betInfo:SetFromBean_KnockoutFightBetInfo(v)
    betInfo:SetFightZoneId(p.fight_zone_id)
    betInfo:SetStage(p.selection_stage)
    betInfo:SetFightIndex(i)
    local fightInfo = p.fight_infos.fight_info_list[i]
    fightInfo.corps_a_brief_info = strkey_corps_infos[tostring(fightInfo.corps_a_id)]
    fightInfo.corps_b_brief_info = strkey_corps_infos[tostring(fightInfo.corps_b_id)]
    if fightInfo.corps_a_brief_info and fightInfo.corps_b_brief_info then
      betInfo:SetFightInfo(fightInfo)
      table.insert(betInfos, betInfo)
    end
  end
  p.betInfos = betInfos
  return p
end
def.static("number", "number", "=>", "number").GenSelectionId = function(fightZoneId, stage)
  return bit.lshift(fightZoneId, 16) + stage
end
def.static("table")._CallbackFinalBetInfoReqs = function(p)
  if finalBetInfoReqs == nil then
    return
  end
  if finalBetInfoReqs[p.activity_cfg_id] == nil then
    return
  end
  local finalId = p.stage
  local callbacks = finalBetInfoReqs[p.activity_cfg_id][finalId]
  if callbacks == nil then
    return
  end
  finalBetInfoReqs[p.activity_cfg_id][finalId] = nil
  for i, callback in ipairs(callbacks) do
    _G.SafeCallback(callback, {
      ret = 0,
      p = CrossBattleBetProtocol.ConvertFinalBetInfos(p)
    })
  end
end
def.static("table", "=>", "table").ConvertFinalBetInfos = function(p)
  local strkey_corps_infos = {}
  for k, v in pairs(p.corps_infos) do
    strkey_corps_infos[tostring(k)] = v
  end
  local betInfos = {}
  for i, v in ipairs(p.fight_bet_infos) do
    local betInfo = FinalBetInfo.new({})
    betInfo:SetFromBean_KnockoutFightBetInfo(v)
    betInfo:SetStage(p.stage)
    betInfo:SetFightIndex(i)
    local fightInfo = p.fight_infos.fight_info_list[i]
    fightInfo.corps_a_brief_info = strkey_corps_infos[tostring(fightInfo.corps_a_id)]
    fightInfo.corps_b_brief_info = strkey_corps_infos[tostring(fightInfo.corps_b_id)]
    if fightInfo.corps_a_brief_info and fightInfo.corps_b_brief_info then
      betInfo:SetFightInfo(fightInfo)
      table.insert(betInfos, betInfo)
    end
  end
  p.betInfos = betInfos
  return p
end
return CrossBattleBetProtocol.Commit()
