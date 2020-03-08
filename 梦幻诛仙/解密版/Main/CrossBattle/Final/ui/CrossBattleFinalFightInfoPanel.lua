local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleFinalFightInfoPanel = Lplus.Extend(ECPanelBase, "CrossBattleFinalFightInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local CrossBattleFinalStageEnum = require("consts.mzm.gsp.crossbattle.confbean.CrossBattleFinalStageEnum")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
local def = CrossBattleFinalFightInfoPanel.define
def.field("table").uiObjs = nil
def.field("number").curStage = 0
def.field("table").stageInfo = nil
def.field("table").corpsData = nil
def.field("table").fightInfo = nil
def.field("number").ruleTipsId = 0
def.field("number").selectedTab = 0
def.field("number").selectedRound = 0
def.field("table").stageFightInfo = nil
local instance
def.static("=>", CrossBattleFinalFightInfoPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleFinalFightInfoPanel()
  end
  return instance
end
def.method("number", "table", "table", "table", "number").ShowPanel = function(self, curStage, stageInfo, corpsData, fightInfo, ruleTipsId)
  if self:IsShow() then
    return
  end
  self.curStage = curStage
  self.stageInfo = stageInfo
  self.corpsData = corpsData
  self.fightInfo = fightInfo
  self.ruleTipsId = ruleTipsId
  self.selectedTab = math.floor((self.curStage - 1) / CrossBattleFinalMgr.STAGE_BATTLE_COUNT) + 1
  self.selectedRound = (self.curStage - 1) % CrossBattleFinalMgr.STAGE_BATTLE_COUNT + 1
  self.stageFightInfo = {}
  for i = 1, #fightInfo, 3 do
    local stageInfo = {}
    for j = 1, CrossBattleFinalMgr.STAGE_BATTLE_COUNT do
      table.insert(stageInfo, fightInfo[i + j - 1])
    end
    table.insert(self.stageFightInfo, stageInfo)
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_FINAL_FIGHT_INFO, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitTabGroup()
  self:ChooseTab(self.selectedTab, self.selectedRound)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.curStage = 0
  self.stageInfo = nil
  self.corpsData = nil
  self.fightInfo = nil
  self.ruleTipsId = 0
  self.selectedTab = 0
  self.selectedRound = 0
  self.stageFightInfo = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Tab = self.uiObjs.Img_Bg0:FindDirect("Group_Tab")
  self.uiObjs.Group_TabBtn = self.uiObjs.Group_Tab:FindDirect("Group_TabBtn")
  self.uiObjs.TabList = self.uiObjs.Group_TabBtn:FindDirect("List")
  self.uiObjs.Group_Type01 = self.uiObjs.Img_Bg0:FindDirect("Group_Type01")
  self.uiObjs.Group_Type02 = self.uiObjs.Img_Bg0:FindDirect("Group_Type02")
  self.uiObjs.Group_Graph = self.uiObjs.Group_Type02:FindDirect("Scrollview/DragBox")
  self.uiObjs.Group_GameBtn = self.uiObjs.Img_Bg0:FindDirect("Group_GameBtn")
end
def.method().InitTabGroup = function(self)
  local uiList = self.uiObjs.TabList:GetComponent("UIList")
  uiList.itemCount = #self.stageInfo
  uiList:Resize()
  local tabs = uiList.children
  for i = 1, #tabs do
    local tab = tabs[i]
    local label = tab:FindDirect("Label_1_" .. i)
    GUIUtils.SetText(label, self.stageInfo[i])
  end
end
def.method("number", "number").ChooseTab = function(self, tabId, round)
  local uiList = self.uiObjs.TabList:GetComponent("UIList")
  local tabs = uiList.children
  if tabs[tabId] ~= nil then
    tabs[tabId]:GetComponent("UIToggle").value = true
  end
  local btnRound = self.uiObjs.Group_GameBtn:FindDirect("Btn_Game" .. round)
  btnRound:GetComponent("UIToggle").value = true
  self:ShowSelectBattleStageInfo()
end
def.method().ShowSelectBattleStageInfo = function(self)
  local stage = self:GetSelectedStage()
  if stage <= self.curStage then
    GUIUtils.SetActive(self.uiObjs.Group_Type01, true)
    GUIUtils.SetActive(self.uiObjs.Group_Graph, false)
    self:FillBattleListInfo(stage)
  else
    GUIUtils.SetActive(self.uiObjs.Group_Type01, false)
    GUIUtils.SetActive(self.uiObjs.Group_Type02, true)
    GUIUtils.SetActive(self.uiObjs.Group_Graph, true)
    self:FillSelectedBattleGraph()
  end
end
def.method("=>", "number").GetSelectedStage = function(self)
  local stage = (self.selectedTab - 1) * CrossBattleFinalMgr.STAGE_BATTLE_COUNT + self.selectedRound
  return stage
end
def.method("number").FillBattleListInfo = function(self, stage)
  local battleList, battleVisible = self:GetBattleInfoListByStage(stage)
  local battleCount = #battleList
  local ScrollView = self.uiObjs.Group_Type01:FindDirect("Group_List/Scroll View")
  local List = ScrollView:FindDirect("List_Member")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = battleCount
  uiList:Resize()
  local battles = uiList.children
  for i = 1, #battles do
    local battle = battles[i]
    self:FillBattleInfo(battle, battleList[i])
  end
  GameUtil.AddGlobalTimer(0, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    for i = 1, #battles do
      local battle = battles[i]
      local visible = battleVisible[i]
      GUIUtils.SetActive(battle, visible)
    end
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method("number", "=>", "table", "table").GetBattleInfoListByStage = function(self, stage)
  local originalList = self.fightInfo[stage] and self.fightInfo[stage] or {}
  local ret = originalList
  local visible = {}
  for i = 1, #ret do
    visible[i] = true
  end
  local battleStage = math.floor((stage - 1) / CrossBattleFinalMgr.STAGE_BATTLE_COUNT) + 1
  local battleRound = (stage - 1) % CrossBattleFinalMgr.STAGE_BATTLE_COUNT + 1
  if battleRound == CrossBattleFinalMgr.STAGE_BATTLE_COUNT then
    local stageFightResult = self:GetStageFightResult(self.stageFightInfo[battleStage])
    for i = 1, #originalList do
      local corpsAInfo = stageFightResult[2 * i - 1]
      local corpsBInfo = stageFightResult[2 * i]
      if corpsAInfo.isWin or corpsBInfo.isWin then
        visible[i] = false
      end
    end
  end
  return ret, visible
end
def.method("userdata", "table").FillBattleInfo = function(self, battle, data)
  local Group_Team1 = battle:FindDirect("Group_Team1")
  local Group_Team2 = battle:FindDirect("Group_Team2")
  self:FillCorpsInfo(Group_Team1, data:GetCorpsAId(), data:GetCorpsAState())
  self:FillCorpsInfo(Group_Team2, data:GetCorpsBId(), data:GetCorpsBState())
end
def.method("userdata", "userdata", "number").FillCorpsInfo = function(self, corps, corpsId, result)
  local Label_Team1_Name = corps:FindDirect("Label_Team1_Name")
  local Label_Server1_Name = corps:FindDirect("Label_Server1_Name")
  local Img_Badge = corps:FindDirect("Img_Badge")
  local Group_Result = corps:FindDirect("Group_Result")
  local Img_Win = Group_Result:FindDirect("Img_Win")
  local Img_Lose = Group_Result:FindDirect("Img_Lose")
  local Img_Unknown = Group_Result:FindDirect("Img_Prepare")
  local Img_Quit = Group_Result:FindDirect("Img_Quit")
  local Img_Info = corps:FindDirect("Img_Info")
  local CorpsUtils = require("Main.Corps.CorpsUtils")
  local corpsInfo = self.corpsData[corpsId:tostring()]
  if corpsInfo == nil then
    GUIUtils.SetText(Label_Team1_Name, textRes.CrossBattle.CrossBattleFinal[9])
    GUIUtils.SetText(Label_Server1_Name, "")
    GUIUtils.SetActive(Img_Badge, false)
    GUIUtils.SetActive(Img_Win, false)
    GUIUtils.SetActive(Img_Lose, false)
    GUIUtils.SetActive(Img_Unknown, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Img_Info, false)
  else
    local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(corpsInfo:GetZoneId())
    GUIUtils.SetText(Label_Team1_Name, corpsInfo:GetCorpsName())
    GUIUtils.SetText(Label_Server1_Name, serverCfg and serverCfg.name or textRes.CrossBattle.CrossBattleSelection[8])
    local cfg = CorpsUtils.GetCorpsBadgeCfg(corpsInfo:GetCorpsIcon())
    if cfg ~= nil then
      GUIUtils.SetActive(Img_Badge, true)
      GUIUtils.FillIcon(Img_Badge:GetComponent("UITexture"), cfg.iconId)
    else
      GUIUtils.SetActive(Img_Badge, false)
    end
    local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
    if result == SingleFightResult.FIGHT_WIN or result == SingleFightResult.ABSTAIN_WIN or result == SingleFightResult.BYE_WIN then
      GUIUtils.SetActive(Img_Win, true)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Unknown, false)
      GUIUtils.SetActive(Img_Quit, false)
    elseif result == SingleFightResult.FIGHT_LOSE then
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, true)
      GUIUtils.SetActive(Img_Unknown, false)
      GUIUtils.SetActive(Img_Quit, false)
    elseif result == SingleFightResult.ABSTAIN_LOSE then
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Unknown, false)
      GUIUtils.SetActive(Img_Quit, true)
    else
      GUIUtils.SetActive(Img_Win, false)
      GUIUtils.SetActive(Img_Lose, false)
      GUIUtils.SetActive(Img_Unknown, true)
      GUIUtils.SetActive(Img_Quit, false)
    end
    GUIUtils.SetActive(Img_Info, true)
  end
end
def.method().FillSelectedBattleGraph = function(self)
  local stage = self:GetSelectedStage()
  local Label_Tips = self.uiObjs.Group_Graph:FindDirect("Label_Tips")
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if crossBattleCfg ~= nil then
    local timeId = crossBattleCfg.final_stage_time[stage] or 0
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local timePointCfg = TimeCfgUtils.GetCommonTimePointCfg(timeId)
    local serverTime = AbsoluteTimer.GetServerTimeByDate(timePointCfg.year, timePointCfg.month, timePointCfg.day, timePointCfg.hour, timePointCfg.min, timePointCfg.sec)
    local prepare = AbsoluteTimer.GetServerTimeTable(serverTime - crossBattleCfg.final_countdown * 60)
    if timePointCfg then
      GUIUtils.SetText(Label_Tips, string.format(textRes.CrossBattle.CrossBattleFinal[10], timePointCfg.year, timePointCfg.month, timePointCfg.day, prepare.hour, prepare.min, timePointCfg.hour, timePointCfg.min))
    else
      GUIUtils.SetText(Label_Tips, "")
    end
  else
    GUIUtils.SetText(Label_Tips, "")
  end
  if self.stageFightInfo == nil then
    return
  end
  local Group32 = {
    "Group_Left/Group_Up/Group_01/Position01",
    "Group_Left/Group_Up/Group_01/Position02",
    "Group_Left/Group_Up/Group_02/Position01",
    "Group_Left/Group_Up/Group_02/Position02",
    "Group_Left/Group_Up/Group_03/Position01",
    "Group_Left/Group_Up/Group_03/Position02",
    "Group_Left/Group_Up/Group_04/Position01",
    "Group_Left/Group_Up/Group_04/Position02",
    "Group_Left/Group_Down/Group_01/Position01",
    "Group_Left/Group_Down/Group_01/Position02",
    "Group_Left/Group_Down/Group_02/Position01",
    "Group_Left/Group_Down/Group_02/Position02",
    "Group_Left/Group_Down/Group_03/Position01",
    "Group_Left/Group_Down/Group_03/Position02",
    "Group_Left/Group_Down/Group_04/Position01",
    "Group_Left/Group_Down/Group_04/Position02",
    "Group_Right/Group_Up/Group_01/Position01",
    "Group_Right/Group_Up/Group_01/Position02",
    "Group_Right/Group_Up/Group_02/Position01",
    "Group_Right/Group_Up/Group_02/Position02",
    "Group_Right/Group_Up/Group_03/Position01",
    "Group_Right/Group_Up/Group_03/Position02",
    "Group_Right/Group_Up/Group_04/Position01",
    "Group_Right/Group_Up/Group_04/Position02",
    "Group_Right/Group_Down/Group_01/Position01",
    "Group_Right/Group_Down/Group_01/Position02",
    "Group_Right/Group_Down/Group_02/Position01",
    "Group_Right/Group_Down/Group_02/Position02",
    "Group_Right/Group_Down/Group_03/Position01",
    "Group_Right/Group_Down/Group_03/Position02",
    "Group_Right/Group_Down/Group_04/Position01",
    "Group_Right/Group_Down/Group_04/Position02"
  }
  local stageFightResult32 = self:GetStageFightResult(self.stageFightInfo[1])
  for i = 1, #Group32 do
    local position = self.uiObjs.Group_Graph:FindDirect(Group32[i])
    if stageFightResult32[i] == nil or Int64.eq(stageFightResult32[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal.BattleType[1])
    elseif Int64.lt(stageFightResult32[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal[9])
    else
      self:SetCorpsInfo(position, stageFightResult32[i])
    end
  end
  local Group16 = {
    "Group_Left/Group_Up/Group_01/Position03",
    "Group_Left/Group_Up/Group_02/Position03",
    "Group_Left/Group_Up/Group_03/Position03",
    "Group_Left/Group_Up/Group_04/Position03",
    "Group_Left/Group_Down/Group_01/Position03",
    "Group_Left/Group_Down/Group_02/Position03",
    "Group_Left/Group_Down/Group_03/Position03",
    "Group_Left/Group_Down/Group_04/Position03",
    "Group_Right/Group_Up/Group_01/Position03",
    "Group_Right/Group_Up/Group_02/Position03",
    "Group_Right/Group_Up/Group_03/Position03",
    "Group_Right/Group_Up/Group_04/Position03",
    "Group_Right/Group_Down/Group_01/Position03",
    "Group_Right/Group_Down/Group_02/Position03",
    "Group_Right/Group_Down/Group_03/Position03",
    "Group_Right/Group_Down/Group_04/Position03"
  }
  local stageFightResult16 = self:GetStageFightResult(self.stageFightInfo[2])
  for i = 1, #Group16 do
    local position = self.uiObjs.Group_Graph:FindDirect(Group16[i])
    if stageFightResult16[i] == nil or Int64.eq(stageFightResult16[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal.BattleType[2])
    elseif Int64.lt(stageFightResult16[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal[9])
    else
      self:SetCorpsInfo(position, stageFightResult16[i])
    end
  end
  local Group8 = {
    "Group_Left/Group_Up/Group_05/Position01",
    "Group_Left/Group_Up/Group_06/Position01",
    "Group_Left/Group_Down/Group_05/Position01",
    "Group_Left/Group_Down/Group_06/Position01",
    "Group_Right/Group_Up/Group_05/Position01",
    "Group_Right/Group_Up/Group_06/Position01",
    "Group_Right/Group_Down/Group_05/Position01",
    "Group_Right/Group_Down/Group_06/Position01"
  }
  local stageFightResult8 = self:GetStageFightResult(self.stageFightInfo[3])
  for i = 1, #Group8 do
    local position = self.uiObjs.Group_Graph:FindDirect(Group8[i])
    if stageFightResult8[i] == nil or Int64.eq(stageFightResult8[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal.BattleType[3])
    elseif Int64.lt(stageFightResult8[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal[9])
    else
      self:SetCorpsInfo(position, stageFightResult8[i])
    end
  end
  local Group4 = {
    "Group_Left/Group_Up/Group_07/Position01",
    "Group_Left/Group_Down/Group_07/Position01",
    "Group_Right/Group_Up/Group_07/Position01",
    "Group_Right/Group_Down/Group_07/Position01"
  }
  local stageFightResult4 = self:GetStageFightResult(self.stageFightInfo[4])
  for i = 1, #Group4 do
    local position = self.uiObjs.Group_Graph:FindDirect(Group4[i])
    if stageFightResult4[i] == nil or Int64.eq(stageFightResult4[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal.BattleType[4])
    elseif Int64.lt(stageFightResult4[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal[9])
    else
      self:SetCorpsInfo(position, stageFightResult4[i])
    end
  end
  local Group3 = {
    "Group_3rd/Position01",
    "Group_3rd/Position02"
  }
  local stageFightResult3 = self:GetStageFightResult(self.stageFightInfo[5])
  for i = 1, #Group3 do
    local position = self.uiObjs.Group_Graph:FindDirect(Group3[i])
    if stageFightResult3[i] == nil or Int64.eq(stageFightResult3[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal.BattleType[5])
    elseif Int64.lt(stageFightResult3[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal[9])
    else
      self:SetCorpsInfo(position, stageFightResult3[i])
    end
  end
  local Group1 = {
    "Group_1st/Group_FinalLeft/Position01",
    "Group_1st/Group_FinalRight/Position01"
  }
  local stageFightResult1 = self:GetStageFightResult(self.stageFightInfo[6])
  for i = 1, #Group1 do
    local position = self.uiObjs.Group_Graph:FindDirect(Group1[i])
    if stageFightResult1[i] == nil or Int64.eq(stageFightResult1[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal.BattleType[6])
    elseif Int64.lt(stageFightResult1[i].corpsId, 0) then
      self:SetCorpsUnknown(position, textRes.CrossBattle.CrossBattleFinal[9])
    else
      self:SetCorpsInfo(position, stageFightResult1[i])
    end
  end
  if #stageFightResult3 ~= 2 then
    self:SetCorpsUnknown(self.uiObjs.Group_Graph:FindDirect("Group_3rd"), textRes.CrossBattle.CrossBattleFinal[11])
  else
    local resultA = stageFightResult3[1]
    local resultB = stageFightResult3[2]
    if resultA.isWin then
      self:SetCorpsInfo(self.uiObjs.Group_Graph:FindDirect("Group_3rd"), resultA)
    elseif resultB.isWin then
      self:SetCorpsInfo(self.uiObjs.Group_Graph:FindDirect("Group_3rd"), resultB)
    else
      self:SetCorpsUnknown(self.uiObjs.Group_Graph:FindDirect("Group_3rd"), textRes.CrossBattle.CrossBattleFinal[11])
    end
  end
  if #stageFightResult1 ~= 2 then
    self:SetCorpsUnknown(self.uiObjs.Group_Graph:FindDirect("Group_1st"), textRes.CrossBattle.CrossBattleFinal[12])
  else
    local resultA = stageFightResult1[1]
    local resultB = stageFightResult1[2]
    if resultA.isWin then
      self:SetCorpsInfo(self.uiObjs.Group_Graph:FindDirect("Group_1st"), resultA)
    elseif resultB.isWin then
      self:SetCorpsInfo(self.uiObjs.Group_Graph:FindDirect("Group_1st"), resultB)
    else
      self:SetCorpsUnknown(self.uiObjs.Group_Graph:FindDirect("Group_1st"), textRes.CrossBattle.CrossBattleSelection[12])
    end
  end
end
def.method("table", "=>", "table").GetStageFightResult = function(self, stageFightInfo)
  if stageFightInfo == nil then
    return {}
  end
  local CalFightResult = require("netio.protocol.mzm.gsp.crossbattle.CalFightResult")
  local result = {}
  local index = {}
  for i = 1, CrossBattleFinalMgr.STAGE_BATTLE_COUNT do
    for j = 1, #stageFightInfo[i] do
      local fightInfo = stageFightInfo[i][j]
      local corpsAId = fightInfo:GetCorpsAId()
      local corpsBId = fightInfo:GetCorpsBId()
      if index[corpsAId:tostring()] == nil then
        local corpsResult = {}
        corpsResult.corpsId = corpsAId
        corpsResult.winCount = 0
        corpsResult.isWin = false
        corpsResult.isOver = true
        index[corpsAId:tostring()] = corpsResult
      end
      if index[corpsBId:tostring()] == nil then
        local corpsResult = {}
        corpsResult.corpsId = corpsBId
        corpsResult.winCount = 0
        corpsResult.isWin = false
        corpsResult.isOver = true
        index[corpsBId:tostring()] = corpsResult
      end
      local corpsAResult = index[corpsAId:tostring()]
      local corpsBResult = index[corpsBId:tostring()]
      if i == 1 then
        table.insert(result, corpsAResult)
        table.insert(result, corpsBResult)
      end
      if fightInfo:GetCalFightState() == CalFightResult.A_FIGHT_WIN or fightInfo:GetCalFightState() == CalFightResult.A_ABSTAIN_WIN or fightInfo:GetCalFightState() == CalFightResult.A_BYE_WIN then
        corpsAResult.winCount = corpsAResult.winCount + 1
      elseif fightInfo:GetCalFightState() == CalFightResult.A_FIGHT_LOSE or fightInfo:GetCalFightState() == CalFightResult.A_ABSTAIN_LOSE or fightInfo:GetCalFightState() == CalFightResult.B_BYE_WIN then
        corpsBResult.winCount = corpsBResult.winCount + 1
      end
      if fightInfo:GetCalFightState() == CalFightResult.STATE_NOT_START then
        corpsAResult.isOver = false
        corpsBResult.isOver = false
      end
    end
  end
  for i = 1, #result - 1, 2 do
    local resultA = result[i]
    local resultB = result[i + 1]
    if resultA.isOver and resultB.isOver then
      resultA.isWin = resultA.winCount > resultB.winCount
      resultB.isWin = resultB.winCount > resultB.winCount
    elseif resultA.winCount >= math.ceil(CrossBattleFinalMgr.STAGE_BATTLE_COUNT / 2) then
      resultA.isWin = true
      resultB.isWin = false
      resultA.isOver = true
      resultB.isOver = true
    elseif resultB.winCount >= math.ceil(CrossBattleFinalMgr.STAGE_BATTLE_COUNT / 2) then
      resultA.isWin = false
      resultB.isWin = true
      resultA.isOver = true
      resultB.isOver = true
    end
  end
  return result
end
def.method("userdata", "string").SetCorpsUnknown = function(self, corps, unkown)
  local Group_Name = corps:FindDirect("Group_Name")
  local Label_RaceNum = corps:FindDirect("Label_RaceNum")
  GUIUtils.SetActive(Group_Name, false)
  GUIUtils.SetActive(Label_RaceNum, true)
  GUIUtils.SetText(Label_RaceNum, unkown)
end
def.method("userdata", "table").SetCorpsInfo = function(self, corps, corpsResult)
  local Group_Name = corps:FindDirect("Group_Name")
  local Label_RaceNum = corps:FindDirect("Label_RaceNum")
  GUIUtils.SetActive(Group_Name, true)
  GUIUtils.SetActive(Label_RaceNum, false)
  local Label_ServerName = Group_Name:FindDirect("Label_ServerName")
  local Label_TeamName = Group_Name:FindDirect("Label_TeamName")
  local corpsInfo = self.corpsData[corpsResult.corpsId:tostring()]
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(corpsInfo:GetZoneId())
  GUIUtils.SetText(Label_ServerName, serverCfg and serverCfg.name or textRes.CrossBattle.CrossBattleSelection[8])
  GUIUtils.SetText(Label_TeamName, corpsInfo:GetCorpsName())
  local Img_Lose = corps:FindDirect("Img_Lose")
  if corpsResult.isOver and not corpsResult.isWin then
    GUIUtils.SetActive(Img_Lose, true)
  else
    GUIUtils.SetActive(Img_Lose, false)
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
  if id == "Btn_Rule" then
    self:OnBtnRuleClick()
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Tab_") then
    local tabId = tonumber(string.sub(id, #"Tab_" + 1))
    self:OnTabBtnClick(tabId)
  elseif string.find(id, "Btn_Game") then
    local roundId = tonumber(string.sub(id, #"Btn_Game" + 1))
    self:OnRoundBtnClick(roundId)
  end
end
def.method("userdata").OnCorpsDetailClick = function(self, obj)
  if self.stageFightInfo == nil or self.stageFightInfo[self.selectedTab] == nil or self.stageFightInfo[self.selectedTab][self.selectedRound] == nil then
    return
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
  local battle = self.stageFightInfo[self.selectedTab][self.selectedRound][fightIdx]
  if battle == nil then
    return
  end
  local corpsId
  local corpsIdx = tonumber(string.sub(corpsItem.name, #"Group_Team" + 1))
  if corpsIdx == 1 then
    corpsId = battle:GetCorpsAId()
  else
    corpsId = battle:GetCorpsBId()
  end
  if corpsId ~= nil then
    local CorpsInterface = require("Main.Corps.CorpsInterface")
    CorpsInterface.CheckCorpsInfo(corpsId)
  end
end
def.method().OnBtnRuleClick = function(self)
  GUIUtils.ShowHoverTip(self.ruleTipsId)
end
def.method("number").OnTabBtnClick = function(self, tabId)
  self.selectedTab = tabId
  self.selectedRound = 1
  self:ChooseTab(self.selectedTab, self.selectedRound)
end
def.method("number").OnRoundBtnClick = function(self, round)
  self.selectedRound = round
  self:ChooseTab(self.selectedTab, self.selectedRound)
end
CrossBattleFinalFightInfoPanel.Commit()
return CrossBattleFinalFightInfoPanel
