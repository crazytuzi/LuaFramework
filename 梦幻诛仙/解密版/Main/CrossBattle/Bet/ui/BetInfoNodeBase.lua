local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local BetInfoNodeBase = Lplus.Extend(TabNode, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local CrossBattleBetUtils = import("..CrossBattleBetUtils")
local BetInfo = import("..data.BetInfo")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local MathHelper = require("Common.MathHelper")
local def = BetInfoNodeBase.define
def.const("table").StateImg = {
  Nil = "nil",
  Win = "Img_Win",
  Lose = "Img_Lose",
  Fighting = "Img_Fight",
  Abort = "Img_Quit"
}
def.field("number").m_nodeId = 0
def.field("table").m_betInfos = nil
def.field("table").m_histories = nil
def.override().OnShow = function(self)
  local Btn_Field = self.m_node:FindDirect("Btn_Field")
  local Panel_Field = self.m_node:FindDirect("Panel_Field")
  GUIUtils.SetActive(Btn_Field, false)
  GUIUtils.SetActive(Panel_Field, false)
end
def.override().OnHide = function(self)
  self:HideHistorySelectPanel()
  self:HideZoneSelectPanel()
end
def.method("=>", "number").GetNodeId = function(self)
  return self.m_nodeId
end
def.method("number").SetNodeId = function(self, nodeId)
  self.m_nodeId = nodeId
end
def.override("userdata").onClickObj = function(self, obj)
  self:HideHistorySelectPanel()
  self:HideZoneSelectPanel()
  local id = obj.name
  if id:find("Btn_Stake1_") then
    local index = tonumber(id:split("_")[3])
    if index then
      self:OnClickBetABtn(index)
    end
  elseif id:find("Btn_Stake2_") then
    local index = tonumber(id:split("_")[3])
    if index then
      self:OnClickBetBBtn(index)
    end
  elseif id == "Btn_Rule" then
    self:OnClickRuleBtn()
  elseif id == "Btn_Note" then
    self:OnClickHistoryBtn()
  elseif id:find("Btn_Item_") and obj.parent.name == "List" then
    local index = tonumber(id:split("_")[3])
    if index then
      self:OnSelectHistory(index, self.m_histories[index])
    end
  elseif id:find("Btn_Search1_") then
    local corpsId = Int64.ParseString(id:split("_")[3])
    if corpsId then
      self:OnClickCorpsDetailBtn(corpsId)
    end
  elseif id == "Btn_Field" then
    self:OnClickZoneBtn()
  elseif id:find("Btn_Field_") and obj.parent.name == "List" then
    local index = tonumber(id:split("_")[3])
    if index then
      self:OnSelectZone(index)
    end
  end
end
def.virtual("number").OnSelectZone = function(self, index)
end
def.virtual().OnClickZoneBtn = function(self)
  warn("OnClickZoneBtn")
end
def.virtual("number").OnClickBetABtn = function(self, index)
  warn("OnClickBetABtn" .. index)
end
def.virtual("number").OnClickBetBBtn = function(self, index)
  warn("OnClickBetBBtn" .. index)
end
def.virtual().OnClickRuleBtn = function(self)
  warn("OnClickRuleBtn")
end
def.virtual().OnClickHistoryBtn = function(self)
  warn("OnClickHistoryBtn")
end
def.virtual("number", "table").OnSelectHistory = function(self, index, history)
  warn("OnSelectHistory" .. index)
end
def.virtual("userdata").OnClickCorpsDetailBtn = function(self, corpsId)
  warn("OnClickCorpsDetailBtn_" .. corpsId:tostring())
  CorpsInterface.CheckCorpsInfo(corpsId)
end
def.method().UpdateNoBetsInfo = function(self)
  local Label_MatchTips = self.m_node:FindDirect("Label_MatchTips")
  local Group_Item = self.m_node:FindDirect("Group_Item")
  GUIUtils.SetActive(Label_MatchTips, true)
  GUIUtils.SetActive(Group_Item, false)
end
def.method("table").SetBetInfos = function(self, betInfos)
  local Label_MatchTips = self.m_node:FindDirect("Label_MatchTips")
  GUIUtils.SetActive(Label_MatchTips, false)
  local Group_Item = self.m_node:FindDirect("Group_Item")
  GUIUtils.SetActive(Group_Item, true)
  betInfos = betInfos or {}
  local List = self.m_node:FindDirect("Group_Item/ScrollView_Item/List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #betInfos
  uiList:Resize()
  local itemGOs = uiList.children
  for i, betInfo in ipairs(betInfos) do
    local itemGO = itemGOs[i]
    self:SetBetInfo(itemGO, betInfo)
  end
end
def.virtual("userdata", "table").SetBetInfo = function(self, group, betInfo)
  local Label_Tips1 = group:FindChildByPrefix("Label_Tips1", false)
  local Group_Team1 = group:FindChildByPrefix("Group_Team1", false)
  local Group_Team2 = group:FindChildByPrefix("Group_Team2", false)
  local Group_Stake = group:FindChildByPrefix("Group_Stake", false)
  self:SetCorpsInfo(Group_Team1, betInfo.aCorpsInfo)
  self:SetCorpsInfo(Group_Team2, betInfo.bCorpsInfo)
  self:SetStakeInfo(Group_Stake, betInfo)
  self:SetTipsInfo(Label_Tips1, betInfo.tips)
end
def.method("userdata", "table").SetCorpsInfo = function(self, group, corpsInfo)
  local Label_TeamName1 = group:FindChildByPrefix("Label_TeamName1", false)
  local Label_BattleNum1 = group:FindChildByPrefix("Label_BattleNum1", false)
  local Texture_Team1 = group:FindChildByPrefix("Texture_Team1", false)
  local Label_FWQ_Name1 = group:FindChildByPrefix("Label_FWQ_Name1", false)
  local serverName = corpsInfo.serverName or ""
  GUIUtils.SetText(Label_FWQ_Name1, serverName)
  GUIUtils.SetText(Label_TeamName1, corpsInfo.name)
  local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo.corpsBadgeId)
  local iconId = badgeCfg and badgeCfg.iconId
  GUIUtils.SetTexture(Texture_Team1, iconId)
  if corpsInfo.avgFightValue then
    local fightValue = CorpsInterface.MultiFightValueToString(corpsInfo.avgFightValue)
    local fightValueText = textRes.CrossBattle.Bet[7]:format(fightValue)
    GUIUtils.SetText(Label_BattleNum1, fightValueText)
  else
    GUIUtils.SetText(Label_BattleNum1, "")
  end
  local Img_State = group:FindChildByPrefix("Img_State", false)
  GUIUtils.SetSprite(Img_State, corpsInfo.stateImg)
  local Btn_Search1 = group:FindChildByPrefix("Btn_Search1", false)
  Btn_Search1.name = "Btn_Search1_" .. tostring(corpsInfo.corpsId)
end
def.virtual("userdata", "table").SetStakeInfo = function(self, group, betInfo)
  local Label_Num01 = group:FindChildByPrefix("Label_Num01", false)
  local Label_Num02 = group:FindChildByPrefix("Label_Num02", false)
  local Slider = group:FindChildByPrefix("Slider", false)
  local uiSlider = Slider:GetComponent("UISlider")
  local moneyNumOnA = betInfo.aCorpsInfo.stakeNum
  local moneyNumOnB = betInfo.bCorpsInfo.stakeNum
  local value
  if moneyNumOnA:eq(0) and moneyNumOnA:eq(moneyNumOnB) then
    value = 0.5
  else
    value = moneyNumOnA:ToNumber() / (moneyNumOnA:ToNumber() + moneyNumOnB:ToNumber())
  end
  uiSlider.value = value
  local currencyName = self:GetBetCurrencyName(betInfo.betMoneyType)
  local moneyText1 = string.format("%s%s", moneyNumOnA:tostring(), currencyName)
  moneyText1 = textRes.CrossBattle.Bet[17]:format(moneyText1)
  local moneyText2 = string.format("%s%s", moneyNumOnB:tostring(), currencyName)
  moneyText2 = textRes.CrossBattle.Bet[17]:format(moneyText2)
  GUIUtils.SetText(Label_Num01, moneyText1)
  GUIUtils.SetText(Label_Num02, moneyText2)
  local Btn_Stake1 = group:FindChildByPrefix("Btn_Stake1", false)
  local Btn_Stake2 = group:FindChildByPrefix("Btn_Stake2", false)
  local Label_choice_1 = Btn_Stake1:FindChildByPrefix("Label_choice", false)
  local Label_choice_2 = Btn_Stake2:FindChildByPrefix("Label_choice", false)
  GUIUtils.SetText(Label_choice_1, "")
  GUIUtils.SetText(Label_choice_2, "")
  if 0 < betInfo.betMoneyNum then
    local stakeText = textRes.CrossBattle.Bet[8]:format(string.format("%s%s", betInfo.betMoneyNum, currencyName))
    if betInfo.betCorpsId == betInfo.aCorpsInfo.corpsId then
      GUIUtils.SetText(Label_choice_1, stakeText)
    else
      GUIUtils.SetText(Label_choice_2, stakeText)
    end
  end
  local btnColor
  if betInfo.canBet then
    btnColor = Color.Color(1, 1, 1, 1)
  else
    btnColor = Color.Color(0.55, 0.55, 0.55, 1)
  end
  Btn_Stake1:GetComponent("UISprite"):set_color(btnColor)
  Btn_Stake2:GetComponent("UISprite"):set_color(btnColor)
  local Label_probability_1 = Btn_Stake1:FindChildByPrefix("Label_probability", false)
  local Label_probability_2 = Btn_Stake2:FindChildByPrefix("Label_probability", false)
  if betInfo.aCorpsInfo.multiple and betInfo.bCorpsInfo.multiple then
    local multipleTextA = textRes.CrossBattle.Bet[12]:format(betInfo.aCorpsInfo.multiple)
    local multipleTextB = textRes.CrossBattle.Bet[12]:format(betInfo.bCorpsInfo.multiple)
    GUIUtils.SetText(Label_probability_1, multipleTextA)
    GUIUtils.SetText(Label_probability_2, multipleTextB)
  else
    GUIUtils.SetText(Label_probability_1, "")
    GUIUtils.SetText(Label_probability_2, "")
  end
end
def.method("userdata", "string").SetTipsInfo = function(self, group, tips)
  GUIUtils.SetText(group, tips)
end
def.method("number", "=>", "string").GetBetCurrencyName = function(self, moneyType)
  local currency = require("Main.Currency.CurrencyFactory").GetInstance(moneyType)
  return currency:GetName()
end
def.method().HideHistorySelectPanel = function(self)
  local Panel_Note = self.m_node:FindDirect("Panel_Note")
  GUIUtils.SetActive(Panel_Note, false)
end
def.method("table").ShowHistorySelectPanel = function(self, histories)
  self.m_histories = histories
  local Panel_Note = self.m_node:FindDirect("Panel_Note")
  GUIUtils.SetActive(Panel_Note, true)
  local ScrollView_Note = Panel_Note:FindDirect("Img_BgNote/ScrollView_Note")
  local List = ScrollView_Note:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #histories
  uiList:Resize()
  local childGOs = uiList.children
  for i, history in ipairs(histories) do
    local childGO = childGOs[i]
    self:SetHistoyInfo(childGO, history)
  end
  local uiScrollView = ScrollView_Note:GetComponent("UIScrollView")
  GameUtil.AddGlobalTimer(0, true, function(...)
    GameUtil.AddGlobalTimer(0, true, function(...)
      if uiScrollView.isnil then
        return
      end
      uiScrollView:ResetPosition()
    end)
  end)
end
def.method("userdata", "table").SetHistoyInfo = function(self, group, history)
  local Label_Item = group:FindChildByPrefix("Label_Item", false)
  local name = history.name
  GUIUtils.SetText(Label_Item, name)
  local uiWidget = group:GetComponent("UIWidget")
  if uiWidget then
    if history.selected then
      local r, g, b = unpack(textRes.CrossBattle.Bet.BTN_SELECTED_COLOR)
      uiWidget:set_color(Color.Color(r / 255, g / 255, b / 255))
    else
      uiWidget:set_color(Color.white)
    end
  end
end
def.method("table").ShowZoneSelectPanel = function(self, zones)
  local Panel_Field = self.m_node:FindDirect("Panel_Field")
  GUIUtils.SetActive(Panel_Field, true)
  local ScrollView_Field = Panel_Field:FindDirect("Img_BgField/ScrollView_Field")
  local List = ScrollView_Field:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #zones
  uiList:Resize()
  local childGOs = uiList.children
  for i, zone in ipairs(zones) do
    local childGO = childGOs[i]
    self:SetZoneInfo(childGO, zone)
  end
  local uiScrollView = ScrollView_Field:GetComponent("UIScrollView")
  GameUtil.AddGlobalTimer(0, true, function(...)
    GameUtil.AddGlobalTimer(0, true, function(...)
      if uiScrollView.isnil then
        return
      end
      uiScrollView:ResetPosition()
    end)
  end)
end
def.method("userdata", "table").SetZoneInfo = function(self, group, zone)
  local Label_Field = group:FindChildByPrefix("Label_Field", false)
  local name = zone.name
  GUIUtils.SetText(Label_Field, zone.name)
  local uiWidget = group:GetComponent("UIWidget")
  if uiWidget then
    if zone.selected then
      local r, g, b = unpack(textRes.CrossBattle.Bet.BTN_SELECTED_COLOR)
      uiWidget:set_color(Color.Color(r / 255, g / 255, b / 255))
    else
      uiWidget:set_color(Color.white)
    end
  end
end
def.method().HideZoneSelectPanel = function(self)
  local Panel_Field = self.m_node:FindDirect("Panel_Field")
  GUIUtils.SetActive(Panel_Field, false)
end
def.method("table", "=>", "table").KnockOutFightInfoToStateImgs = function(self, fightInfo)
  local CalFightResult = require("netio.protocol.mzm.gsp.crossbattle.CalFightResult")
  local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
  local cal_fight_result = fightInfo.cal_fight_result
  local corps_a_state = fightInfo.corps_a_state
  local img1, img2
  if cal_fight_result == CalFightResult.A_FIGHT_WIN then
    img1 = BetInfoNodeBase.StateImg.Win
    img2 = BetInfoNodeBase.StateImg.Lose
  elseif cal_fight_result == CalFightResult.A_FIGHT_LOSE then
    img1 = BetInfoNodeBase.StateImg.Lose
    img2 = BetInfoNodeBase.StateImg.Win
  elseif cal_fight_result == CalFightResult.A_ABSTAIN_LOSE then
    img1 = BetInfoNodeBase.StateImg.Abort
    img2 = BetInfoNodeBase.StateImg.Win
  elseif cal_fight_result == CalFightResult.A_ABSTAIN_WIN then
    img1 = BetInfoNodeBase.StateImg.Win
    img2 = BetInfoNodeBase.StateImg.Abort
  elseif cal_fight_result == CalFightResult.ALL_ABSTAIN then
    img1 = BetInfoNodeBase.StateImg.Abort
    img2 = img1
  elseif cal_fight_result == CalFightResult.STATE_NOT_START then
    if corps_a_state == SingleFightResult.IN_FIGHTING then
      img1 = BetInfoNodeBase.StateImg.Fighting
      img2 = img1
    else
      img1 = BetInfoNodeBase.StateImg.Nil
      img2 = img1
    end
  else
    img1 = BetInfoNodeBase.StateImg.Nil
    img2 = img1
  end
  return {img1, img2}
end
def.method("table", "=>", "string").GenKnockOutBetStakeDesc = function(self, params)
  local index, stake = params.index, params.stake
  local betInfo, corpsInfo = params.betInfo, params.corpsInfo
  local win_multiple, max_win_money = params.win_multiple, params.max_win_money
  local moneyNumOnA = betInfo:GetMoneyNumOnA():ToNumber()
  local moneyNumOnB = betInfo:GetMoneyNumOnB():ToNumber()
  local totalMoney = moneyNumOnA + moneyNumOnB + stake.num
  local moneyNumOnBetTeam = stake.num
  local fightInfo = betInfo:GetFightInfo()
  if corpsInfo.corps_id == fightInfo.corps_a_brief_info.corps_id then
    moneyNumOnBetTeam = moneyNumOnBetTeam + moneyNumOnA
  elseif corpsInfo.corps_id == fightInfo.corps_b_brief_info.corps_id then
    moneyNumOnBetTeam = moneyNumOnBetTeam + moneyNumOnB
  else
    error("corps_id error: " .. tostring(corpsInfo.corps_id))
  end
  local currency = require("Main.Currency.CurrencyFactory").GetInstance(stake.type)
  local currencyName = currency:GetName()
  local gainText = string.format("%s%s", max_win_money, currencyName)
  local desc = textRes.CrossBattle.Bet[15]:format(gainText)
  return desc
end
def.method("table", "=>", "table").ConvertKnockOutBetInfoToViewData = function(self, betInfo)
  local fightInfo = betInfo:GetFightInfo()
  local corps_a_brief_info = fightInfo.corps_a_brief_info
  local corps_b_brief_info = fightInfo.corps_b_brief_info
  local moneyNumOnA = betInfo:GetMoneyNumOnA()
  local moneyNumOnB = betInfo:GetMoneyNumOnB()
  local stake = {
    num = betInfo:GetSelfBetMoneyNum()
  }
  local betCorpsId = betInfo:GetSelfBetCorpsId()
  local stateImgs = self:KnockOutFightInfoToStateImgs(fightInfo)
  local ServerListMgr = require("Main.Login.ServerListMgr")
  local function getServerName(zoneId)
    if zoneId == nil then
      return ""
    end
    local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneId)
    if not serverCfg or not serverCfg.name then
    end
    return "zone_" .. tostring(zoneId)
  end
  local viewData = {}
  viewData.betCorpsId = betCorpsId
  viewData.betMoneyNum = stake and stake.num or 0
  viewData.aCorpsInfo = {
    corpsId = corps_a_brief_info.corps_id,
    name = GetStringFromOcts(corps_a_brief_info.corps_name),
    corpsBadgeId = corps_a_brief_info.corps_icon,
    avgFightValue = corps_a_brief_info.average_fight_value,
    stakeNum = moneyNumOnA,
    stateImg = stateImgs[1],
    serverName = getServerName(corps_a_brief_info.zone_id)
  }
  viewData.bCorpsInfo = {
    corpsId = corps_b_brief_info.corps_id,
    name = GetStringFromOcts(corps_b_brief_info.corps_name),
    corpsBadgeId = corps_b_brief_info.corps_icon,
    avgFightValue = corps_b_brief_info.average_fight_value,
    stakeNum = moneyNumOnB,
    stateImg = stateImgs[2],
    serverName = getServerName(corps_b_brief_info.zone_id)
  }
  viewData.tips = ""
  viewData.raw = betInfo
  return viewData
end
return BetInfoNodeBase.Commit()
