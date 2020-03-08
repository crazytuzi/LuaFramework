local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BetInfoNodeBase = import(".BetInfoNodeBase")
local BetRoundRobinNode = Lplus.Extend(BetInfoNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local CrossBattleBetMgr = import("..CrossBattleBetMgr")
local CrossBattleBetUtils = import("..CrossBattleBetUtils")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local BetPanel = import(".BetPanel")
local BetInfo = import("..data.BetInfo")
local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local def = BetRoundRobinNode.define
local TODAY_ROUND_INDEX = -1
def.field("number").m_selRoundIndex = 0
def.override().OnShow = function(self)
  BetInfoNodeBase.OnShow(self)
  self:InitData()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_ROUND_ROBIN_SUCCESS, BetRoundRobinNode.OnBetSuccess, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_ROUND_ROBIN_SUCCESS, BetRoundRobinNode.OnBetSuccess)
  BetInfoNodeBase.OnHide(self)
end
def.method().InitData = function(self)
  self.m_selRoundIndex = TODAY_ROUND_INDEX
end
def.method().UpdateUI = function(self)
  if CrossBattleBetMgr.Instance():IsTodayHaveRoundRobinBet() then
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
  CrossBattleBetMgr.Instance():QueryTodaysRoundRobinBetInfo(function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetRoundRobinBetInfos(data.betInfos)
  end)
end
def.override("number").OnClickBetABtn = function(self, index)
  local betInfo = self.m_betInfos[index]
  if self:CheckBetConditions(betInfo, {toast = true}) == false then
    return
  end
  local fightInfo = betInfo:GetFightInfo()
  local corpsInfo = fightInfo.corps_a_brief_info
  local roundIndex = betInfo:GetRoundIndex()
  self:BetOnCorps(roundIndex, corpsInfo)
end
def.override("number").OnClickBetBBtn = function(self, index)
  local betInfo = self.m_betInfos[index]
  if self:CheckBetConditions(betInfo, {toast = true}) == false then
    return
  end
  local fightInfo = betInfo:GetFightInfo()
  local corpsInfo = fightInfo.corps_b_brief_info
  local roundIndex = betInfo:GetRoundIndex()
  self:BetOnCorps(roundIndex, corpsInfo)
end
def.method("table", "table", "=>", "boolean").CheckBetConditions = function(self, betInfo, params)
  return CrossBattleBetMgr.Instance():CheckRoundRobinBetConditions(betInfo, params)
end
def.method("number", "table").BetOnCorps = function(self, roundIndex, corpsInfo)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local roundRobinBetCfg = CrossBattleBetUtils.GetRoundRobinBetCfg(activityId)
  local stakes = {}
  for i, v in ipairs(roundRobinBetCfg.stakes) do
    stakes[i] = {
      type = v.type,
      num = v.num,
      sortId = v.sortId
    }
  end
  local MathHelper = require("Common.MathHelper")
  local title = textRes.CrossBattle.Bet[4]:format(GetStringFromOcts(corpsInfo.name))
  BetPanel.Instance():ShowPanel({
    title = title,
    stakes = stakes,
    stakeDescGenerator = function(index, stake)
      local gainNum = MathHelper.Floor(stake.num * roundRobinBetCfg.win_rate_of_return)
      local returnNum = MathHelper.Floor(stake.num * roundRobinBetCfg.lose_rate_of_return)
      local currency = require("Main.Currency.CurrencyFactory").GetInstance(stake.type)
      local currencyName = currency:GetName()
      local gainText = string.format("%s%s", gainNum, currencyName)
      local returnText = string.format("%s%s", returnNum, currencyName)
      local desc = textRes.CrossBattle.Bet[5]:format(gainText, returnText)
      return desc
    end,
    onBet = function(index, stake)
      CrossBattleBetMgr.Instance():BetInRoundRobin(roundIndex, corpsInfo.corpsId, stake.sortId)
      if self.m_node == nil or self.m_node.isnil then
        return
      end
      if not self.isShow then
        return
      end
      self:UpdateBetInfosInner()
    end
  })
end
def.override().OnClickRuleBtn = function(self)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local roundRobinBetCfg = CrossBattleBetUtils.GetRoundRobinBetCfg(activityId)
  GUIUtils.ShowHoverTip(roundRobinBetCfg.tips_id, 0, 0)
end
def.override().OnClickHistoryBtn = function(self)
  local histories = CrossBattleBetMgr.Instance():GetRoundRobinHistories()
  for i, v in ipairs(histories) do
    if v.isToday then
      v.name = textRes.CrossBattle.Bet[18]
    else
      v.name = textRes.CrossBattle.Bet[10]:format(v.roundIndex)
    end
    if v.roundIndex == self.m_selRoundIndex then
      v.selected = true
    end
  end
  self:ShowHistorySelectPanel(histories)
end
def.override("number", "table").OnSelectHistory = function(self, index, history)
  if history.isToday then
    self.m_selRoundIndex = TODAY_ROUND_INDEX
    self:UpdateBetInfosInner()
    return
  end
  self.m_selRoundIndex = history.roundIndex
  CrossBattleBetMgr.Instance():QueryRoundRobinBetInfo(history.roundIndex, function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetRoundRobinBetInfos(data.betInfos)
  end)
end
def.method("table").SetRoundRobinBetInfos = function(self, betInfos)
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
  local fightInfo = betInfo:GetFightInfo()
  local corps_a_brief_info = fightInfo.corps_a_brief_info
  local corps_b_brief_info = fightInfo.corps_b_brief_info
  local moneyNumOnA = betInfo:GetMoneyNumOnA()
  local moneyNumOnB = betInfo:GetMoneyNumOnB()
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local roundRobinBetCfg = CrossBattleBetUtils.GetRoundRobinBetCfg(activityId)
  local stake = {
    num = betInfo:GetSelfBetMoneyNum()
  }
  local betCorpsId = betInfo:GetSelfBetCorpsId()
  local stateImgs = self:FightStateToStateImgs(fightInfo.state)
  local viewData = {}
  viewData.betCorpsId = betCorpsId
  viewData.betMoneyNum = stake and stake.num or 0
  viewData.betMoneyType = roundRobinBetCfg.bet_cost_type
  viewData.aCorpsInfo = {
    corpsId = corps_a_brief_info.corpsId,
    name = GetStringFromOcts(corps_a_brief_info.name),
    corpsBadgeId = corps_a_brief_info.corpsBadgeId,
    avgFightValue = corps_a_brief_info.average_fight_value,
    stakeNum = moneyNumOnA,
    stateImg = stateImgs[1]
  }
  viewData.bCorpsInfo = {
    corpsId = corps_b_brief_info.corpsId,
    name = GetStringFromOcts(corps_b_brief_info.name),
    corpsBadgeId = corps_b_brief_info.corpsBadgeId,
    avgFightValue = corps_b_brief_info.average_fight_value,
    stakeNum = moneyNumOnB,
    stateImg = stateImgs[2]
  }
  local roundIndx = betInfo:GetRoundIndex()
  local prepareTime, beginTime = CrossBattleBetMgr.Instance():GetBetRoundRobinTimeByIndex(roundIndx)
  local tips
  if prepareTime ~= 0 then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local pt = AbsoluteTimer.GetServerTimeTable(prepareTime)
    local bt = AbsoluteTimer.GetServerTimeTable(beginTime)
    tips = textRes.CrossBattle.Bet[2]:format(pt.year, pt.month, pt.day, pt.hour, pt.min, bt.hour, bt.min)
  else
    tips = ""
  end
  viewData.tips = tips
  viewData.raw = betInfo
  viewData.canBet = self:CheckBetConditions(betInfo, {})
  return viewData
end
def.method("number", "=>", "table").FightStateToStateImgs = function(self, fightState)
  local img1, img2
  if fightState == RoundRobinFightInfo.STATE_FIGHTING then
    img1 = BetInfoNodeBase.StateImg.Fighting
    img2 = img1
  elseif fightState == RoundRobinFightInfo.STATE_A_WIN then
    img1 = BetInfoNodeBase.StateImg.Win
    img2 = BetInfoNodeBase.StateImg.Lose
  elseif fightState == RoundRobinFightInfo.STATE_B_WIN then
    img1 = BetInfoNodeBase.StateImg.Lose
    img2 = BetInfoNodeBase.StateImg.Win
  elseif fightState == RoundRobinFightInfo.STATE_A_ABSTAIN then
    img1 = BetInfoNodeBase.StateImg.Abort
    img2 = BetInfoNodeBase.StateImg.Win
  elseif fightState == RoundRobinFightInfo.STATE_B_ABSTAIN then
    img1 = BetInfoNodeBase.StateImg.Win
    img2 = BetInfoNodeBase.StateImg.Abort
  elseif fightState == RoundRobinFightInfo.STATE_ALL_ABSTAIN then
    img1 = BetInfoNodeBase.StateImg.Abort
    img2 = img1
  else
    img1 = BetInfoNodeBase.StateImg.Nil
    img2 = img1
  end
  return {img1, img2}
end
def.method("table").OnBetSuccess = function(self, params)
  local p = params[1]
  if self.m_betInfos == nil then
    return
  end
  for i, v in ipairs(self.m_betInfos) do
    if v:GetRoundIndex() == p.round_index then
      local fightInfo = v:GetFightInfo()
      if fightInfo.corps_a_brief_info.corpsId == p.target_corps_id or fightInfo.corps_b_brief_info.corpsId == p.target_corps_id then
        self:AccumulateBetInfo(v, p)
        break
      end
    end
  end
  self:SetRoundRobinBetInfos(self.m_betInfos)
end
def.method("table", "table").AccumulateBetInfo = function(self, betInfo, p)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local roundRobinBetCfg = CrossBattleBetUtils.GetRoundRobinBetCfg(activityId)
  local betSortId = p.sortid
  local stake
  if betSortId ~= 0 then
    for i, v in ipairs(roundRobinBetCfg.stakes) do
      if v.sortId == betSortId then
        stake = v
        break
      end
    end
  end
  local betMoneyNum = stake and stake.num or 0
  betInfo:SetSelfBetCorpsId(p.target_corps_id)
  betInfo:AddSelfBetMoneyNum(betMoneyNum)
  betInfo:SetMoneyNumOnA(p.corps_a_bet_money_sum)
  betInfo:SetMoneyNumOnB(p.corps_b_bet_money_sum)
end
return BetRoundRobinNode.Commit()
