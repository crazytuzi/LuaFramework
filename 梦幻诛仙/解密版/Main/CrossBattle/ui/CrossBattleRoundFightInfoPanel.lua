local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleRoundFightInfoPanel = Lplus.Extend(ECPanelBase, "CrossBattleRoundFightInfoPanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CrossBattleRoundFightInfoPanel.define
def.field("table").uiObjs = nil
def.field("table").timePoint = nil
def.field("number").round = 0
local instance
def.static("=>", CrossBattleRoundFightInfoPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleRoundFightInfoPanel()
  end
  return instance
end
def.method("table", "number").ShowPanel = function(self, timePoint, round)
  if self:IsShow() then
    return
  end
  self.timePoint = timePoint
  self.round = round
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_ROUND_FIGHT_INFO, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:QueryFightInfo()
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, CrossBattleRoundFightInfoPanel.OnRoundInfoChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.timePoint = nil
  self.round = 0
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, CrossBattleRoundFightInfoPanel.OnRoundInfoChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Type01 = self.uiObjs.Img_Bg0:FindDirect("Group_Type01")
  self.uiObjs.Label_Time = self.uiObjs.Group_Type01:FindDirect("Label_Time")
  self.uiObjs.Label_Game = self.uiObjs.Group_Type01:FindDirect("Label_Game")
  local ScrollView = self.uiObjs.Group_Type01:FindDirect("Group_List/Scroll View")
  local List = ScrollView:FindDirect("List_Member")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
  local roundStr = string.format(textRes.CrossBattle[107], self.round)
  local serverTime = _G.GetServerTime()
  local gameTime = AbsoluteTimer.GetServerTimeByDate(self.timePoint.year, self.timePoint.month, self.timePoint.day, self.timePoint.hour, self.timePoint.min, self.timePoint.sec)
  local timeStr = ""
  if serverTime > gameTime then
    timeStr = string.format(textRes.CrossBattle[105], self.timePoint.year, self.timePoint.month, self.timePoint.day)
  else
    timeStr = string.format(textRes.CrossBattle[104], self.timePoint.year, self.timePoint.month, self.timePoint.day, self.timePoint.hour, self.timePoint.min)
  end
  GUIUtils.SetText(self.uiObjs.Label_Time, timeStr)
  GUIUtils.SetText(self.uiObjs.Label_Game, roundStr)
end
def.method().QueryFightInfo = function(self)
  local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinRoundInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, self.round)
  gmodule.network.sendProtocol(p)
end
def.method().FillFightInfo = function(self)
  local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(self.round)
  if fightInfos == nil then
    fightInfos = {}
  else
    fightInfos = fightInfos.fightInfos
  end
  local List_Member = self.uiObjs.Group_Type01:FindDirect("Group_List/Scroll View/List_Member")
  local uiList = List_Member:GetComponent("UIList")
  uiList.itemCount = #fightInfos
  uiList:Resize()
  local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
  for i, v in ipairs(fightInfos) do
    local item = List_Member:FindDirect("item_" .. i)
    local Group_Team1 = item:FindDirect("Group_Team1")
    local Label_Team1_Name = Group_Team1:FindDirect("Label_Team1_Name")
    local Img_Badge1 = Group_Team1:FindDirect("Img_Badge")
    local Group_Result1 = Group_Team1:FindDirect("Group_Result")
    local corps1 = v.corps_a_brief_info
    Label_Team1_Name:GetComponent("UILabel"):set_text(GetStringFromOcts(corps1.name))
    local badgeCfg1 = CorpsUtils.GetCorpsBadgeCfg(corps1.corpsBadgeId)
    if badgeCfg1 then
      local badge_texture1 = Img_Badge1:GetComponent("UITexture")
      GUIUtils.FillIcon(badge_texture1, badgeCfg1.iconId)
    end
    local Group_Team2 = item:FindDirect("Group_Team2")
    local Label_Team2_Name = Group_Team2:FindDirect("Label_Team1_Name")
    local Img_Badge2 = Group_Team2:FindDirect("Img_Badge")
    local Group_Result2 = Group_Team2:FindDirect("Group_Result")
    local corps2 = v.corps_b_brief_info
    Label_Team2_Name:GetComponent("UILabel"):set_text(GetStringFromOcts(corps2.name))
    local badgeCfg2 = CorpsUtils.GetCorpsBadgeCfg(corps2.corpsBadgeId)
    if badgeCfg2 then
      local badge_texture2 = Img_Badge2:GetComponent("UITexture")
      GUIUtils.FillIcon(badge_texture2, badgeCfg2.iconId)
    end
    local Img_Win1 = Group_Result1:FindDirect("Img_Win")
    local Img_Lose1 = Group_Result1:FindDirect("Img_Lose")
    local Img_Quit1 = Group_Result1:FindDirect("Img_Quit")
    local Img_Fight1 = Group_Result1:FindDirect("Img_Fight")
    local Img_Prepare1 = Group_Result1:FindDirect("Img_Prepare")
    local Img_Win2 = Group_Result2:FindDirect("Img_Win")
    local Img_Lose2 = Group_Result2:FindDirect("Img_Lose")
    local Img_Quit2 = Group_Result2:FindDirect("Img_Quit")
    local Img_Fight2 = Group_Result2:FindDirect("Img_Fight")
    local Img_Prepare2 = Group_Result2:FindDirect("Img_Prepare")
    local state = v.state
    if state == RoundRobinFightInfo.STATE_NOT_START then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(true)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(true)
    elseif state == RoundRobinFightInfo.STATE_FIGHTING then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(true)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(true)
      Img_Prepare2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_A_WIN then
      Img_Win1:SetActive(true)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(true)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_B_WIN then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(true)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(true)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_A_ABSTAIN then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(true)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(true)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_B_ABSTAIN then
      Img_Win1:SetActive(true)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(true)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(false)
    elseif state == RoundRobinFightInfo.STATE_ALL_ABSTAIN then
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(true)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(true)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(false)
    else
      Img_Win1:SetActive(false)
      Img_Lose1:SetActive(false)
      Img_Quit1:SetActive(false)
      Img_Fight1:SetActive(false)
      Img_Prepare1:SetActive(false)
      Img_Win2:SetActive(false)
      Img_Lose2:SetActive(false)
      Img_Quit2:SetActive(false)
      Img_Fight2:SetActive(false)
      Img_Prepare2:SetActive(false)
    end
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_Info" then
    self:OnCorpsDetailClick(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("userdata").OnCorpsDetailClick = function(self, obj)
  local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(self.round)
  if fightInfos == nil then
    return
  else
    fightInfos = fightInfos.fightInfos
  end
  local corpsItem = obj.parent
  if corpsItem == nil then
    return
  end
  local fightItem = corpsItem.parent
  if fightItem == nil then
    return
  end
  local fightIdx = tonumber(string.sub(fightItem.name, #"item_" + 1))
  local battle = fightInfos[fightIdx]
  if battle == nil then
    return
  end
  local corpsId
  local corpsIdx = tonumber(string.sub(corpsItem.name, #"Group_Team" + 1))
  if corpsIdx == 1 then
    corpsId = battle.corps_a_brief_info.corpsId
  else
    corpsId = battle.corps_b_brief_info.corpsId
  end
  if corpsId ~= nil then
    local CorpsInterface = require("Main.Corps.CorpsInterface")
    CorpsInterface.CheckCorpsInfo(corpsId)
  end
end
def.static("table", "table").OnRoundInfoChange = function(p1, p2)
  local self = instance
  if self.round == p1[1] then
    self:FillFightInfo()
  end
end
CrossBattleRoundFightInfoPanel.Commit()
return CrossBattleRoundFightInfoPanel
