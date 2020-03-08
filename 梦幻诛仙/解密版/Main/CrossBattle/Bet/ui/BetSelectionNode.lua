local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BetInfoNodeBase = import(".BetInfoNodeBase")
local BetSelectionNode = Lplus.Extend(BetInfoNodeBase, MODULE_NAME)
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
local def = BetSelectionNode.define
local NOT_SET = 0
def.field("number").m_selZone = NOT_SET
def.field("number").m_selStage = NOT_SET
def.field("table").m_zones = nil
def.override().OnShow = function(self)
  BetInfoNodeBase.OnShow(self)
  self:InitData()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_SELECTION_SUCCESS, BetSelectionNode.OnBetSuccess, self)
  Event.RegisterEventWithContext(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.REFRESH_SELECTION_BET_SUCCESS, BetSelectionNode.OnRefreshBetInfo, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.BET_IN_SELECTION_SUCCESS, BetSelectionNode.OnBetSuccess)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.REFRESH_SELECTION_BET_SUCCESS, BetSelectionNode.OnRefreshBetInfo)
  BetInfoNodeBase.OnHide(self)
end
def.method().InitData = function(self)
  if self.m_selZone == NOT_SET then
    self.m_selZone = 1
  end
  if self.m_selStage == NOT_SET then
    self.m_selStage = CrossBattleInterface.GetTodayCrossBattleSelectionStage()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateZoneBtn()
  if CrossBattleBetMgr.Instance():IsTodayHaveSelectionBet() then
    self:UpdateBetInfos()
  else
    self:UpdateNoBetsInfo()
  end
end
def.method().UpdateZoneBtn = function(self)
  local Btn_Field = self.m_node:FindDirect("Btn_Field")
  local Panel_Field = self.m_node:FindDirect("Panel_Field")
  GUIUtils.SetActive(Btn_Field, true)
  local zoneName = self:GetFightZoneName(self.m_selZone)
  local Label_Field = Btn_Field:FindDirect("Label_Field")
  GUIUtils.SetText(Label_Field, zoneName)
end
def.method().UpdateBetInfos = function(self)
  local Group_Item = self.m_node:FindDirect("Group_Item")
  GUIUtils.SetActive(Group_Item, false)
  self:UpdateBetInfosInner()
end
def.method().UpdateBetInfosInner = function(self)
  CrossBattleBetMgr.Instance():QuerySelectionBetInfo(self.m_selZone, self.m_selStage, function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetSelectionBetInfos(data.betInfos)
  end)
end
def.method("table").SetSelectionBetInfos = function(self, betInfos)
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
  local selectionBetCfg = CrossBattleBetUtils.GetSelectionBetCfg(activityId)
  local multiples = self:CalcMultiples(betInfo, selectionBetCfg.win_multiple)
  local viewData = self:ConvertKnockOutBetInfoToViewData(betInfo)
  viewData.betMoneyType = selectionBetCfg.bet_cost_type
  viewData.aCorpsInfo.multiple = multiples[1]
  viewData.bCorpsInfo.multiple = multiples[2]
  local selectionStage = betInfo:GetStage()
  local beginTime = CrossBattleInterface.GetCrossBattleSelectionTimeByStage(selectionStage)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  local tips
  if crossBattleCfg and beginTime ~= 0 then
    local prepareTime = beginTime - crossBattleCfg.selection_countdown * 60
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
  return CrossBattleBetMgr.Instance():CheckSelectionBetConditions(betInfo, params)
end
def.method("table", "=>", "table").FightInfoToStateImgs = function(self, fightInfo)
  return self:KnockOutFightInfoToStateImgs(fightInfo)
end
def.override().OnClickZoneBtn = function(self)
  local zones = {}
  local zoneNum = constant.CCrossBattlePointConst.ZONE_NUM
  for i = 1, zoneNum do
    local zone = {}
    zone.id = i
    zone.name = self:GetFightZoneName(zone.id)
    if zone.id == self.m_selZone then
      zone.selected = true
    end
    table.insert(zones, zone)
  end
  self.m_zones = zones
  self:ShowZoneSelectPanel(zones)
end
def.override("number").OnSelectZone = function(self, index)
  local zone = self.m_zones[index]
  self.m_selZone = zone.id
  self:UpdateZoneBtn()
  CrossBattleBetMgr.Instance():QuerySelectionBetInfo(self.m_selZone, self.m_selStage, function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetSelectionBetInfos(data.betInfos)
  end)
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
  local fightZoneId = betInfo:GetFightZoneId()
  local stage = betInfo:GetStage()
  local fightIndex = betInfo:GetFightIndex()
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local selectionBetCfg = CrossBattleBetUtils.GetSelectionBetCfg(activityId)
  local stakes = {}
  for i, v in ipairs(selectionBetCfg.stakes) do
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
        win_multiple = selectionBetCfg.win_multiple,
        max_win_money = selectionBetCfg.max_win_money
      }
      return self:GenKnockOutBetStakeDesc(params)
    end,
    onBet = function(index, stake)
      CrossBattleBetMgr.Instance():BetInSelection(fightZoneId, stage, fightIndex, corpsInfo.corps_id, stake.sortId)
      if self.m_node == nil or self.m_node.isnil then
        return
      end
      if not self.isShow then
        return
      end
    end
  })
end
def.method("number", "=>", "string").GetFightZoneName = function(self, fightZoneId)
  return PointsRaceUtils.GetZoneName(fightZoneId) or "fight_zone_" .. fightZoneId
end
def.override().OnClickRuleBtn = function(self)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local selectionBetCfg = CrossBattleBetUtils.GetSelectionBetCfg(activityId)
  GUIUtils.ShowHoverTip(selectionBetCfg.tips_id, 0, 0)
end
def.override().OnClickHistoryBtn = function(self)
  local histories = CrossBattleBetMgr.Instance():GetSelectionHistories()
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
  self.m_selStage = history.stage
  if history.isToday then
    self:UpdateBetInfosInner()
    return
  end
  CrossBattleBetMgr.Instance():QuerySelectionBetInfo(self.m_selZone, self.m_selStage, function(data)
    if self.m_node == nil or self.m_node.isnil then
      return
    end
    if not self.isShow then
      return
    end
    self:SetSelectionBetInfos(data.betInfos)
  end)
end
def.method("number", "=>", "string").GetStageName = function(self, stage)
  return textRes.CrossBattle.CrossBattleSelection.BattleType[stage] or "stage_" .. stage
end
def.method("table").OnBetSuccess = function(self, params)
  local p = params[1]
  if self.m_betInfos == nil then
    return
  end
  for i, v in ipairs(self.m_betInfos) do
    local fightZoneId = v:GetFightZoneId()
    local stage = v:GetStage()
    local fightIndex = v:GetFightIndex()
    if fightZoneId == p.fight_zone_id and stage == p.selection_stage and fightIndex == p.fight_index then
      self:AccumulateBetInfo(v, p)
      break
    end
  end
  self:SetSelectionBetInfos(self.m_betInfos)
end
def.method("table").OnRefreshBetInfo = function(self, params)
  local p = params[1]
  if self.m_betInfos == nil then
    return
  end
  for i, v in ipairs(self.m_betInfos) do
    local fightZoneId = v:GetFightZoneId()
    local stage = v:GetStage()
    local fightIndex = v:GetFightIndex()
    if fightZoneId == p.fight_zone_id and stage == p.selection_stage and fightIndex == p.fight_index then
      v:SetMoneyNumOnA(p.corps_a_bet_money_sum)
      v:SetMoneyNumOnB(p.corps_b_bet_money_sum)
      break
    end
  end
  self:SetSelectionBetInfos(self.m_betInfos)
end
def.method("table", "table").AccumulateBetInfo = function(self, betInfo, p)
  local activityId = CrossBattleBetMgr.Instance():GetActivityId()
  local selectionBetCfg = CrossBattleBetUtils.GetSelectionBetCfg(activityId)
  local betSortId = p.sortid
  local stake
  if betSortId ~= 0 then
    for i, v in ipairs(selectionBetCfg.stakes) do
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
return BetSelectionNode.Commit()
