local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local HistoryMgr = require("Main.CrossBattle.History.HistoryMgr")
local MatchData = require("Main.CrossBattle.History.data.MatchData")
local CorpsMatchNode = require("Main.CrossBattle.History.data.CorpsMatchNode")
local HistoryData = require("Main.CrossBattle.History.data.HistoryData")
local HistoryMatchPanel = Lplus.Extend(ECPanelBase, "HistoryMatchPanel")
local def = HistoryMatchPanel.define
local instance
def.static("=>", HistoryMatchPanel).Instance = function()
  if instance == nil then
    instance = HistoryMatchPanel()
  end
  return instance
end
def.const("string").NODE_PREFIX = "node_"
def.field("table")._uiObjs = nil
def.field("number")._season = 0
def.field(MatchData)._matchData = nil
def.static("number").ShowPanel = function(season)
  if not HistoryMgr.Instance():IsOpen(true) then
    if HistoryMatchPanel.Instance():IsShow() then
      HistoryMatchPanel.Instance():DestroyPanel()
    end
    return
  end
  HistoryMatchPanel.Instance():InitData(season)
  if HistoryMatchPanel.Instance():IsShow() then
    HistoryMatchPanel.Instance():ShowMatches()
    return
  end
  HistoryMatchPanel.Instance():CreatePanel(RESPATH.PREFAB_CROSSBATTLE_HISTORY_RACE_PANEL, 2)
end
def.method("number").InitData = function(self, season)
  self._season = season
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_Bg0/Group_Title/Label_Game")
  self._uiObjs.Group16 = self.m_panel:FindDirect("Img_Bg0/Group_Type01")
  self._uiObjs.Group32 = self.m_panel:FindDirect("Img_Bg0/Group_Type02")
  self:_Init16Version()
  self:_Init32Version()
end
def.method()._Init16Version = function(self)
  local Group_Left = self._uiObjs.Group16:FindDirect("Group_Left")
  local Group_Right = self._uiObjs.Group16:FindDirect("Group_Right")
  local Group_1st = self._uiObjs.Group16:FindDirect("Group_1st")
  local Group_3rd = self._uiObjs.Group16:FindDirect("Group_3rd")
  local StageEnum = MatchData.StageEnum16
  self._uiObjs.StageGroups16 = {}
  local nodesGroup = {}
  self._uiObjs.StageGroups16[MatchData.GetLeafStage(true)] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_01/Position01")
  nodesGroup[2] = Group_Left:FindDirect("Group_01/Position02")
  nodesGroup[3] = Group_Left:FindDirect("Group_02/Position01")
  nodesGroup[4] = Group_Left:FindDirect("Group_02/Position02")
  nodesGroup[5] = Group_Left:FindDirect("Group_03/Position01")
  nodesGroup[6] = Group_Left:FindDirect("Group_03/Position02")
  nodesGroup[7] = Group_Left:FindDirect("Group_04/Position01")
  nodesGroup[8] = Group_Left:FindDirect("Group_04/Position02")
  nodesGroup[9] = Group_Right:FindDirect("Group_01/Position01")
  nodesGroup[10] = Group_Right:FindDirect("Group_01/Position02")
  nodesGroup[11] = Group_Right:FindDirect("Group_02/Position01")
  nodesGroup[12] = Group_Right:FindDirect("Group_02/Position02")
  nodesGroup[13] = Group_Right:FindDirect("Group_03/Position01")
  nodesGroup[14] = Group_Right:FindDirect("Group_03/Position02")
  nodesGroup[15] = Group_Right:FindDirect("Group_04/Position01")
  nodesGroup[16] = Group_Right:FindDirect("Group_04/Position02")
  nodesGroup = {}
  self._uiObjs.StageGroups16[StageEnum.ELIM16_8] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_01/Position03")
  nodesGroup[2] = Group_Left:FindDirect("Group_02/Position03")
  nodesGroup[3] = Group_Left:FindDirect("Group_03/Position03")
  nodesGroup[4] = Group_Left:FindDirect("Group_04/Position03")
  nodesGroup[5] = Group_Right:FindDirect("Group_01/Position03")
  nodesGroup[6] = Group_Right:FindDirect("Group_02/Position03")
  nodesGroup[7] = Group_Right:FindDirect("Group_03/Position03")
  nodesGroup[8] = Group_Right:FindDirect("Group_04/Position03")
  nodesGroup = {}
  self._uiObjs.StageGroups16[StageEnum.ELIM8_4] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_05/Position01")
  nodesGroup[2] = Group_Left:FindDirect("Group_06/Position01")
  nodesGroup[3] = Group_Right:FindDirect("Group_05/Position01")
  nodesGroup[4] = Group_Right:FindDirect("Group_06/Position01")
  nodesGroup = {}
  self._uiObjs.StageGroups16[StageEnum.SEMI] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_07/Position01")
  nodesGroup[2] = Group_Right:FindDirect("Group_07/Position01")
  nodesGroup = {}
  self._uiObjs.StageGroups16[StageEnum.BRONZE] = nodesGroup
  nodesGroup[1] = Group_3rd
  nodesGroup = {}
  self._uiObjs.StageGroups16[StageEnum.FINAL] = nodesGroup
  nodesGroup[1] = Group_1st
  nodesGroup = {}
  self._uiObjs.StageGroups16[MatchData.GetSemiLoserStage(true)] = nodesGroup
  nodesGroup[1] = Group_3rd:FindDirect("Position01")
  nodesGroup[2] = Group_3rd:FindDirect("Position02")
end
def.method()._Init32Version = function(self)
  local Group_Left = self._uiObjs.Group32:FindDirect("Scrollview/DragBox/Group_Left")
  local Group_Right = self._uiObjs.Group32:FindDirect("Scrollview/DragBox/Group_Right")
  local Group_1st = self._uiObjs.Group32:FindDirect("Scrollview/DragBox/Group_1st")
  local Group_3rd = self._uiObjs.Group32:FindDirect("Scrollview/DragBox/Group_3rd")
  local StageEnum = MatchData.StageEnum32
  self._uiObjs.StageGroups32 = {}
  local nodesGroup = {}
  self._uiObjs.StageGroups32[MatchData.GetLeafStage(false)] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_Up/Group_01/Position01")
  nodesGroup[2] = Group_Left:FindDirect("Group_Up/Group_01/Position02")
  nodesGroup[3] = Group_Left:FindDirect("Group_Up/Group_02/Position01")
  nodesGroup[4] = Group_Left:FindDirect("Group_Up/Group_02/Position02")
  nodesGroup[5] = Group_Left:FindDirect("Group_Up/Group_03/Position01")
  nodesGroup[6] = Group_Left:FindDirect("Group_Up/Group_03/Position02")
  nodesGroup[7] = Group_Left:FindDirect("Group_Up/Group_04/Position01")
  nodesGroup[8] = Group_Left:FindDirect("Group_Up/Group_04/Position02")
  nodesGroup[9] = Group_Left:FindDirect("Group_Down/Group_01/Position01")
  nodesGroup[10] = Group_Left:FindDirect("Group_Down/Group_01/Position02")
  nodesGroup[11] = Group_Left:FindDirect("Group_Down/Group_02/Position01")
  nodesGroup[12] = Group_Left:FindDirect("Group_Down/Group_02/Position02")
  nodesGroup[13] = Group_Left:FindDirect("Group_Down/Group_03/Position01")
  nodesGroup[14] = Group_Left:FindDirect("Group_Down/Group_03/Position02")
  nodesGroup[15] = Group_Left:FindDirect("Group_Down/Group_04/Position01")
  nodesGroup[16] = Group_Left:FindDirect("Group_Down/Group_04/Position02")
  nodesGroup[17] = Group_Right:FindDirect("Group_Up/Group_01/Position01")
  nodesGroup[18] = Group_Right:FindDirect("Group_Up/Group_01/Position02")
  nodesGroup[19] = Group_Right:FindDirect("Group_Up/Group_02/Position01")
  nodesGroup[20] = Group_Right:FindDirect("Group_Up/Group_02/Position02")
  nodesGroup[21] = Group_Right:FindDirect("Group_Up/Group_03/Position01")
  nodesGroup[22] = Group_Right:FindDirect("Group_Up/Group_03/Position02")
  nodesGroup[23] = Group_Right:FindDirect("Group_Up/Group_04/Position01")
  nodesGroup[24] = Group_Right:FindDirect("Group_Up/Group_04/Position02")
  nodesGroup[25] = Group_Right:FindDirect("Group_Down/Group_01/Position01")
  nodesGroup[26] = Group_Right:FindDirect("Group_Down/Group_01/Position02")
  nodesGroup[27] = Group_Right:FindDirect("Group_Down/Group_02/Position01")
  nodesGroup[28] = Group_Right:FindDirect("Group_Down/Group_02/Position02")
  nodesGroup[29] = Group_Right:FindDirect("Group_Down/Group_03/Position01")
  nodesGroup[30] = Group_Right:FindDirect("Group_Down/Group_03/Position02")
  nodesGroup[31] = Group_Right:FindDirect("Group_Down/Group_04/Position01")
  nodesGroup[32] = Group_Right:FindDirect("Group_Down/Group_04/Position02")
  nodesGroup = {}
  self._uiObjs.StageGroups32[StageEnum.ELIM32_16] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_Up/Group_01/Position03")
  nodesGroup[2] = Group_Left:FindDirect("Group_Up/Group_02/Position03")
  nodesGroup[3] = Group_Left:FindDirect("Group_Up/Group_03/Position03")
  nodesGroup[4] = Group_Left:FindDirect("Group_Up/Group_04/Position03")
  nodesGroup[5] = Group_Left:FindDirect("Group_Down/Group_01/Position03")
  nodesGroup[6] = Group_Left:FindDirect("Group_Down/Group_02/Position03")
  nodesGroup[7] = Group_Left:FindDirect("Group_Down/Group_03/Position03")
  nodesGroup[8] = Group_Left:FindDirect("Group_Down/Group_04/Position03")
  nodesGroup[9] = Group_Right:FindDirect("Group_Up/Group_01/Position03")
  nodesGroup[10] = Group_Right:FindDirect("Group_Up/Group_02/Position03")
  nodesGroup[11] = Group_Right:FindDirect("Group_Up/Group_03/Position03")
  nodesGroup[12] = Group_Right:FindDirect("Group_Up/Group_04/Position03")
  nodesGroup[13] = Group_Right:FindDirect("Group_Down/Group_01/Position03")
  nodesGroup[14] = Group_Right:FindDirect("Group_Down/Group_02/Position03")
  nodesGroup[15] = Group_Right:FindDirect("Group_Down/Group_03/Position03")
  nodesGroup[16] = Group_Right:FindDirect("Group_Down/Group_04/Position03")
  nodesGroup = {}
  self._uiObjs.StageGroups32[StageEnum.ELIM16_8] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_Up/Group_05/Position01")
  nodesGroup[2] = Group_Left:FindDirect("Group_Up/Group_06/Position01")
  nodesGroup[3] = Group_Left:FindDirect("Group_Down/Group_05/Position01")
  nodesGroup[4] = Group_Left:FindDirect("Group_Down/Group_06/Position01")
  nodesGroup[5] = Group_Right:FindDirect("Group_Up/Group_05/Position01")
  nodesGroup[6] = Group_Right:FindDirect("Group_Up/Group_06/Position01")
  nodesGroup[7] = Group_Right:FindDirect("Group_Down/Group_05/Position01")
  nodesGroup[8] = Group_Right:FindDirect("Group_Down/Group_06/Position01")
  nodesGroup = {}
  self._uiObjs.StageGroups32[StageEnum.ELIM8_4] = nodesGroup
  nodesGroup[1] = Group_Left:FindDirect("Group_Up/Group_07/Position01")
  nodesGroup[2] = Group_Left:FindDirect("Group_Down/Group_07/Position01")
  nodesGroup[3] = Group_Right:FindDirect("Group_Up/Group_07/Position01")
  nodesGroup[4] = Group_Right:FindDirect("Group_Down/Group_07/Position01")
  nodesGroup = {}
  self._uiObjs.StageGroups32[StageEnum.SEMI] = nodesGroup
  nodesGroup[1] = Group_1st:FindDirect("Group_FinalLeft/Position01")
  nodesGroup[2] = Group_1st:FindDirect("Group_FinalRight/Position01")
  nodesGroup = {}
  self._uiObjs.StageGroups32[StageEnum.BRONZE] = nodesGroup
  nodesGroup[1] = Group_3rd
  nodesGroup = {}
  self._uiObjs.StageGroups32[StageEnum.FINAL] = nodesGroup
  nodesGroup[1] = Group_1st
  nodesGroup = {}
  self._uiObjs.StageGroups32[MatchData.GetSemiLoserStage(false)] = nodesGroup
  nodesGroup[1] = Group_3rd:FindDirect("Position01")
  nodesGroup[2] = Group_3rd:FindDirect("Position02")
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_ClearMatches()
  self:ShowTitle()
  GUIUtils.SetActive(self._uiObjs.Group16, false)
  GUIUtils.SetActive(self._uiObjs.Group32, false)
  local matchData = HistoryData.Instance():GetSeasonMatchInfo(self._season)
  if matchData then
    self:ShowMatches(matchData)
  else
    require("Main.CrossBattle.History.HistoryProtocols").SendCGetSeasonMatchInfo(self._season)
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._season = 0
end
def.method().ShowTitle = function(self)
  local title = string.format(textRes.CrossBattle.History.FINAL_TITLE, self._season)
  GUIUtils.SetText(self._uiObjs.Label_Title, title)
end
def.method(MatchData).ShowMatches = function(self, matchData)
  self:_ClearMatches()
  self._matchData = matchData
  if self._matchData then
    local b16Version = self._matchData:Is16Version()
    GUIUtils.SetActive(self._uiObjs.Group16, b16Version)
    GUIUtils.SetActive(self._uiObjs.Group32, not b16Version)
    for stage = MatchData.GetLeafStage(b16Version), MatchData.GetSemiLoserStage(b16Version) do
      local matchCount = MatchData.GetStageMatchCount(stage, b16Version)
      for matchIdx = 1, matchCount do
        self:ShowMatchNode(stage, matchIdx, b16Version)
      end
    end
  end
end
def.method("number", "number", "boolean").ShowMatchNode = function(self, stage, matchIdx, b16Version)
  local nodeGroup = self:GetNodeGroup(stage, matchIdx, b16Version)
  if nil == nodeGroup then
    warn("[ERROR][HistoryMatchPanel:ShowMatchNode] nodeGroup nil for stage, idx, b16Version:", stage, matchIdx, b16Version)
    return
  end
  local nodeName = HistoryMatchPanel.NODE_PREFIX .. CorpsMatchNode.GetKey(stage, matchIdx)
  nodeGroup:set_name(nodeName)
  local Label_ServerName = nodeGroup:FindDirect("Group_Name/Label_ServerName")
  local Label_TeamName = nodeGroup:FindDirect("Group_Name/Label_TeamName")
  local Label_RaceNum = nodeGroup:FindDirect("Label_RaceNum")
  local matchNode = self._matchData and self._matchData:GetMatchNode(stage, matchIdx)
  local corpsBrief = matchNode and matchNode:GetCorpsInfo()
  if nil == corpsBrief then
    GUIUtils.SetActive(Label_RaceNum, true)
    GUIUtils.SetActive(Label_TeamName, false)
    GUIUtils.SetActive(Label_ServerName, false)
    local abcentStr
    if stage == MatchData.GetFinalStage(b16Version) or stage == MatchData.GetBronzeStage(b16Version) then
      abcentStr = textRes.CrossBattle.History.FINAL_TIE
    else
      abcentStr = textRes.CrossBattle.History.CORPS_ABSENT
    end
    GUIUtils.SetText(Label_RaceNum, abcentStr)
  else
    GUIUtils.SetActive(Label_RaceNum, false)
    GUIUtils.SetActive(Label_TeamName, true)
    GUIUtils.SetActive(Label_ServerName, true)
    local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
    HistoryUtils.ShowCorpsBriefInfo(nil, Label_TeamName, Label_ServerName, corpsBrief)
  end
end
def.method("number", "number", "boolean", "=>", "userdata").GetNodeGroup = function(self, stage, matchIdx, b16Version)
  local nodeGroup
  if b16Version then
    nodeGroup = self._uiObjs.StageGroups16[stage] and self._uiObjs.StageGroups16[stage][matchIdx]
  else
    nodeGroup = self._uiObjs.StageGroups32[stage] and self._uiObjs.StageGroups32[stage][matchIdx]
  end
  return nodeGroup
end
def.method()._ClearMatches = function(self)
  self._matchData = nil
  for stage = MatchData.GetLeafStage(true), MatchData.GetSemiLoserStage(true) do
    local matchCount = MatchData.GetStageMatchCount(stage, true)
    for matchIdx = 1, matchCount do
      self:ShowMatchNode(stage, matchIdx, true)
    end
  end
  for stage = MatchData.GetLeafStage(false), MatchData.GetSemiLoserStage(false) do
    local matchCount = MatchData.GetStageMatchCount(stage, false)
    for matchIdx = 1, matchCount do
      self:ShowMatchNode(stage, matchIdx, false)
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Watch" then
    self:OnBtn_Watch(clickObj)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method("userdata").OnBtn_Watch = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local id = parent.name
    local key = string.sub(id, string.len(HistoryMatchPanel.NODE_PREFIX) + 1)
    local matchNode = self._matchData and self._matchData:GetMatchNodeByKey(key)
    if matchNode then
      local MatchListPanel = require("Main.CrossBattle.History.ui.MatchListPanel")
      MatchListPanel.ShowPanel(self._matchData, matchNode)
    else
      warn("[ERROR][HistoryMatchPanel:OnBtn_Watch] matchNode nil for key:", key)
    end
  else
    warn("[ERROR][HistoryMatchPanel:OnBtn_Watch] parent nil for clickObj:", clickObj and clickObj.name)
  end
end
def.method("table").OnSGetSeasonMatchInfo = function(self, matchData)
  if matchData and matchData:GetSeason() == self._season then
    self:ShowMatches(matchData)
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
HistoryMatchPanel.Commit()
return HistoryMatchPanel
