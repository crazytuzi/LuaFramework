local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BetInfoNodeBase = import(".BetInfoNodeBase")
local BetFinalNode = Lplus.Extend(BetInfoNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
local CrossBattleBetMgr = import("..CrossBattleBetMgr")
local CrossBattleBetUtils = import("..CrossBattleBetUtils")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
local CalFightResult = require("netio.protocol.mzm.gsp.crossbattle.CalFightResult")
local BetPanel = import(".BetPanel")
local def = BetFinalNode.define
local NOT_SET = 0
local TODAY_STAGE = -1
def.field("number").m_selStage = NOT_SET
def.override().OnShow = function(self)
  BetInfoNodeBase.OnShow(self)
  self:InitData()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_FINAL_SUCCESS, BetFinalNode.OnBetSuccess, self)
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.REFRESH_FINAL_BET_SUCCESS, BetFinalNode.OnRefreshBetInfo, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_FINAL_SUCCESS, BetFinalNode.OnBetSuccess)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.REFRESH_FINAL_BET_SUCCESS, BetFinalNode.OnRefreshBetInfo)
  BetInfoNodeBase.OnHide(self)
end
def.method().InitData = function(self)
  self.m_selStage = TODAY_STAGE
end
def.method().UpdateUI = function(self)
  if CrossBattleBetMgr.Instance():IsTodayHaveFinalBet() then
    self:UpdateBetInfos()
  else
    self:UpdateNoBetsInfo()
  end
end
def.method().UpdateBetInfos = function(self)
  local Group_Item = self.m_node:FindDirect("Group_Item")
  GUIUtils.SetActive(Group_Item, false)
  self:UpdateBetInfosInner()
end
def.method().UpdateBetInfosInner = function(self)
  CrossBattleBetMgr.Instance():QueryTodaysFinalBetInfo(function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetFinalBetInfos(data.betInfos)
  end)
end
def.method("table").SetFinalBetInfos = function(self, betInfos)
  self.m_betInfos = betInfos
  local betInfoViewDatas = {}
  if betInfos then
    for i, v in ipairs(betInfos) do
      local viewData = self:ConvertBetInfoToViewData(v)
      table.insert(betInfoViewDatas, viewData)
    end
  end
  self:SetBetInfos(betInfoViewDatas)
end
def.method("table", "=>", "table").ConvertBetInfoToViewData = function(self, betInfo)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local finalBetCfg = CrossBattleBetUtils.GetFinalBetCfg(activityId)
  local multiples = self:CalcMultiples(betInfo, finalBetCfg.win_multiple)
  local viewData = self:ConvertKnockOutBetInfoToViewData(betInfo)
  viewData.betMoneyType = finalBetCfg.bet_cost_type
  viewData.aCorpsInfo.multiple = multiples[1]
  viewData.bCorpsInfo.multiple = multiples[2]
  local finalStage = betInfo:GetStage()
  local beginTime = CrossBattleBetMgr.Instance():GetFinalTimeByStage(finalStage)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  local tips
  if crossBattleCfg and beginTime ~= 0 then
    local prepareTime = beginTime - crossBattleCfg.final_countdown * 60
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local pt = AbsoluteTimer.GetServerTimeTable(prepareTime)
    local bt = AbsoluteTimer.GetServerTimeTable(beginTime)
    tips = textRes.CrossBattle.Bet[2]:format(pt.year, pt.month, pt.day, pt.hour, pt.min, bt.hour, bt.min)
  else
    tips = ""
  end
  viewData.tips = tips
  viewData.canBet = self:CheckBetConditions(betInfo, {})
  return viewData
end
def.method("table", "number", "=>", "table").CalcMultiples = function(self, betInfo, coefficient)
  local moneyNumOnA = betInfo:GetMoneyNumOnA():ToNumber()
  local moneyNumOnB = betInfo:GetMoneyNumOnB():ToNumber()
  return {nil, nil}
end
def.method("table", "table", "=>", "boolean").CheckBetConditions = function(self, betInfo, params)
  return CrossBattleBetMgr.Instance():CheckFinalBetConditions(betInfo, params)
end
def.method("table", "=>", "table").FightInfoToStateImgs = function(self, fightInfo)
  return self:KnockOutFightInfoToStateImgs(fightInfo)
end
def.override("number").OnClickBetABtn = function(self, index)
  local betInfo = self.m_betInfos[index]
  if self:CheckBetConditions(betInfo, {toast = true}) == false then
    return
  end
  local fightInfo = betInfo:GetFightInfo()
  local corpsInfo = fightInfo.corps_a_brief_info
  self:BetOnCorps(betInfo, corpsInfo)
end
def.override("number").OnClickBetBBtn = function(self, index)
  local betInfo = self.m_betInfos[index]
  if self:CheckBetConditions(betInfo, {toast = true}) == false then
    return
  end
  local fightInfo = betInfo:GetFightInfo()
  local corpsInfo = fightInfo.corps_b_brief_info
  self:BetOnCorps(betInfo, corpsInfo)
end
def.method("table", "table").BetOnCorps = function(self, betInfo, corpsInfo)
  local fightInfo = betInfo:GetFightInfo()
  local stage = betInfo:GetStage()
  local fightIndex = betInfo:GetFightIndex()
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local finalBetCfg = CrossBattleBetUtils.GetFinalBetCfg(activityId)
  local stakes = {}
  for i, v in ipairs(finalBetCfg.stakes) do
    stakes[i] = {
      type = v.type,
      num = v.num,
      sortId = v.sortId
    }
  end
  local MathHelper = require("Common.MathHelper")
  local ServerListMgr = require("Main.Login.ServerListMgr")
  local serverCfg = ServerListMgr.Instance():GetServerCfg(corpsInfo.zone_id)
  local serverName = serverCfg and serverCfg.name or ""
  local corpsName = GetStringFromOcts(corpsInfo.corps_name)
  local serverCorpsName = string.format("%s-%s", serverName, corpsName)
  local title = textRes.CrossBattle.Bet[4]:format(serverCorpsName)
  BetPanel.Instance():ShowPanel({
    title = title,
    stakes = stakes,
    stakeDescGenerator = function(index, stake)
      local params = {
        betInfo = betInfo,
        corpsInfo = corpsInfo,
        index = index,
        stake = stake,
        win_multiple = finalBetCfg.win_multiple,
        max_win_money = finalBetCfg.max_win_money
      }
      return self:GenKnockOutBetStakeDesc(params)
    end,
    onBet = function(index, stake)
      CrossBattleBetMgr.Instance():BetInFinal(stage, fightIndex, corpsInfo.corps_id, stake.sortId)
      if self.m_node == nil or self.m_node.isnil then
        return
      end
      if not self.isShow then
        return
      end
    end
  })
end
def.override().OnClickRuleBtn = function(self)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local finalBetCfg = CrossBattleBetUtils.GetFinalBetCfg(activityId)
  GUIUtils.ShowHoverTip(finalBetCfg.tips_id, 0, 0)
end
def.override().OnClickHistoryBtn = function(self)
  local histories = CrossBattleBetMgr.Instance():GetFinalHistories()
  for i, v in ipairs(histories) do
    if v.isToday then
      v.name = textRes.CrossBattle.Bet[18]
    else
      v.name = self:GetStageName(v.stage)
    end
    if v.stage == self.m_selStage then
      v.selected = true
    end
  end
  self:ShowHistorySelectPanel(histories)
end
def.override("number", "table").OnSelectHistory = function(self, index, history)
  if history.isToday then
    self.m_selStage = TODAY_STAGE
    self:UpdateBetInfosInner()
    return
  end
  local selStage = history.stage
  self.m_selStage = selStage
  CrossBattleBetMgr.Instance():QueryFinalBetInfo(selStage, function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetFinalBetInfos(data.betInfos)
  end)
end
def.method("number", "=>", "string").GetStageName = function(self, stage)
  return CrossBattleBetUtils.GetCrossBattleFinalBetNameByStage(stage)
end
def.method("table").OnBetSuccess = function(self, params)
  local p = params[1]
  if self.m_betInfos == nil then
    return
  end
  for i, v in ipairs(self.m_betInfos) do
    local stage = v:GetStage()
    local fightIndex = v:GetFightIndex()
    if stage == p.stage and fightIndex == p.fight_index then
      self:AccumulateBetInfo(v, p)
      break
    end
  end
  self:SetFinalBetInfos(self.m_betInfos)
end
def.method("table").OnRefreshBetInfo = function(self, params)
  local p = params[1]
  if self.m_betInfos == nil then
    return
  end
  for i, v in ipairs(self.m_betInfos) do
    local stage = v:GetStage()
    local fightIndex = v:GetFightIndex()
    if stage == p.stage and fightIndex == p.fight_index then
      v:SetMoneyNumOnA(p.corps_a_bet_money_sum)
      v:SetMoneyNumOnB(p.corps_b_bet_money_sum)
      break
    end
  end
  self:SetFinalBetInfos(self.m_betInfos)
end
def.method("table", "table").AccumulateBetInfo = function(self, betInfo, p)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local finalBetCfg = CrossBattleBetUtils.GetFinalBetCfg(activityId)
  local betSortId = p.sortid
  local stake
  if betSortId ~= 0 then
    for i, v in ipairs(finalBetCfg.stakes) do
      if v.sortId == betSortId then
        stake = v
        break
      end
    end
  end
  local betMoneyNum = stake and stake.num or 0
  betInfo:SetSelfBetCorpsId(p.target_corps_id)
  betInfo:AddSelfBetMoneyNum(betMoneyNum)
  local fightInfo = betInfo:GetFightInfo()
  if p.target_corps_id == fightInfo.corps_a_brief_info.corps_id then
    local moneyNumOnA = betInfo:GetMoneyNumOnA()
    betInfo:SetMoneyNumOnA(moneyNumOnA + betMoneyNum)
  elseif p.target_corps_id == fightInfo.corps_b_brief_info.corps_id then
    local moneyNumOnB = betInfo:GetMoneyNumOnB()
    betInfo:SetMoneyNumOnB(moneyNumOnB + betMoneyNum)
  else
    warn("AccumulateBetInfo target_corps_id error!")
  end
end
return BetFinalNode.Commit()
