local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local HistoryMgr = require("Main.CrossBattle.History.HistoryMgr")
local HistoryData = require("Main.CrossBattle.History.data.HistoryData")
local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
local HistoryMainPanel = Lplus.Extend(ECPanelBase, "HistoryMainPanel")
local def = HistoryMainPanel.define
local instance
def.static("=>", HistoryMainPanel).Instance = function()
  if instance == nil then
    instance = HistoryMainPanel()
  end
  return instance
end
def.const("number").SHOW_NUM = 3
def.field("table")._uiObjs = nil
def.field("number")._curSeason = 0
def.field("number")._selectSeason = 0
def.field("table")._top3Info = nil
def.static().ShowPanel = function()
  if not HistoryMgr.Instance():IsOpen(true) then
    if HistoryMainPanel.Instance():IsShow() then
      HistoryMainPanel.Instance():DestroyPanel()
    end
    return
  end
  if HistoryMainPanel.Instance():IsShow() then
    HistoryMainPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_CROSSBATTLE_HISTORY_MAIN_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_TeamList = self.m_panel:FindDirect("Img_Bg/Group_TeamList")
  self._uiObjs.Group_Mate = self.m_panel:FindDirect("Img_Bg/Group_Mate")
  self._uiObjs.Group_NoData = self.m_panel:FindDirect("Img_Bg/Group_NoData")
  self._uiObjs.Btn_History = self.m_panel:FindDirect("Img_Bg/Btn_History")
  self._uiObjs.ScrollView_TeamList = self._uiObjs.Group_TeamList:FindDirect("ScrollView_TeamList")
  self._uiObjs.uiScrollView = self._uiObjs.ScrollView_TeamList:GetComponent("UIScrollView")
  self._uiObjs.List_TeamList = self._uiObjs.ScrollView_TeamList:FindDirect("List_TeamList")
  self._uiObjs.uiList = self._uiObjs.List_TeamList:GetComponent("UIList")
  self._uiObjs.Label_Time = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_Time/Label_Time")
  self._uiObjs.TeamGroups1 = {}
  local TeamGroup = {}
  TeamGroup.group = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_1st")
  TeamGroup.Btn_Detail = TeamGroup.group:FindDirect("Img_Bg/Btn_Edit1st")
  TeamGroup.Img_Badge = TeamGroup.group:FindDirect("Img_Bg/Img_Badge")
  TeamGroup.Label_TeamServer = TeamGroup.group:FindDirect("Img_Bg/Label_TeamServer")
  TeamGroup.Label_TeamName = TeamGroup.group:FindDirect("Img_Bg/Label_TeamName")
  table.insert(self._uiObjs.TeamGroups1, TeamGroup)
  TeamGroup = {}
  TeamGroup.group = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_2nd")
  TeamGroup.Btn_Detail = TeamGroup.group:FindDirect("Img_Bg/Btn_Edit2nd")
  TeamGroup.Img_Badge = TeamGroup.group:FindDirect("Img_Bg/Img_Badge")
  TeamGroup.Label_TeamServer = TeamGroup.group:FindDirect("Img_Bg/Label_TeamServer")
  TeamGroup.Label_TeamName = TeamGroup.group:FindDirect("Img_Bg/Label_TeamName")
  table.insert(self._uiObjs.TeamGroups1, TeamGroup)
  TeamGroup = {}
  TeamGroup.group = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_3rd")
  TeamGroup.Btn_Detail = TeamGroup.group:FindDirect("Img_Bg/Btn_Edit3rd")
  TeamGroup.Img_Badge = TeamGroup.group:FindDirect("Img_Bg/Img_Badge")
  TeamGroup.Label_TeamServer = TeamGroup.group:FindDirect("Img_Bg/Label_TeamServer")
  TeamGroup.Label_TeamName = TeamGroup.group:FindDirect("Img_Bg/Label_TeamName")
  table.insert(self._uiObjs.TeamGroups1, TeamGroup)
  self._uiObjs.TeamGroups2 = {}
  local TeamGroup = {}
  TeamGroup.group = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_Draw_2nd_1")
  TeamGroup.Btn_Detail = TeamGroup.group:FindDirect("Img_Bg/Btn_Draw_Edit2nd_1")
  TeamGroup.Img_Badge = TeamGroup.group:FindDirect("Img_Bg/Img_Badge")
  TeamGroup.Label_TeamServer = TeamGroup.group:FindDirect("Img_Bg/Label_TeamServer")
  TeamGroup.Label_TeamName = TeamGroup.group:FindDirect("Img_Bg/Label_TeamName")
  table.insert(self._uiObjs.TeamGroups2, TeamGroup)
  TeamGroup = {}
  TeamGroup.group = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_Draw_2nd_2")
  TeamGroup.Btn_Detail = TeamGroup.group:FindDirect("Img_Bg/Btn_Draw_Edit2nd_2")
  TeamGroup.Img_Badge = TeamGroup.group:FindDirect("Img_Bg/Img_Badge")
  TeamGroup.Label_TeamServer = TeamGroup.group:FindDirect("Img_Bg/Label_TeamServer")
  TeamGroup.Label_TeamName = TeamGroup.group:FindDirect("Img_Bg/Label_TeamName")
  table.insert(self._uiObjs.TeamGroups2, TeamGroup)
  TeamGroup = {}
  TeamGroup.group = self.m_panel:FindDirect("Img_Bg/Group_Mate/Group_Draw_3rd")
  TeamGroup.Btn_Detail = TeamGroup.group:FindDirect("Img_Bg/Btn_Draw_Edit3rd")
  TeamGroup.Img_Badge = TeamGroup.group:FindDirect("Img_Bg/Img_Badge")
  TeamGroup.Label_TeamServer = TeamGroup.group:FindDirect("Img_Bg/Label_TeamServer")
  TeamGroup.Label_TeamName = TeamGroup.group:FindDirect("Img_Bg/Label_TeamName")
  table.insert(self._uiObjs.TeamGroups2, TeamGroup)
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self._curSeason = HistoryData.Instance():GetCurSeason()
  self:ShowSeasonList(self._curSeason)
  self:SelectSeason(self._curSeason)
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._curSeason = 0
  self._selectSeason = 0
  self._top3Info = nil
  self._uiObjs = nil
end
def.method("number").ShowSeasonList = function(self, curSeason)
  self:ClearSeasonList()
  self._uiObjs.uiList.itemCount = curSeason
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
  for i = 1, curSeason do
    local listItem = self._uiObjs.uiList.children[i]
    local label = listItem and listItem:FindDirect(string.format("Label_TeamName_%d", i))
    local str = string.format(textRes.CrossBattle.History.SEASON_TITLE, self:Idx2Season(i))
    GUIUtils.SetText(label, str)
  end
end
def.method("number").SelectSeason = function(self, season)
  if season > self._curSeason then
    season = self._curSeason
  elseif season < 1 then
    season = 1
  end
  local idx = self:Season2Idx(season)
  local listItem = self._uiObjs.uiList.children[idx]
  if listItem then
    GUIUtils.Toggle(listItem, true)
  else
    warn("[ERROR][HistoryMainPanel:SelectSeason] listItem nil at idx:", idx)
  end
  if HistoryData.Instance():IsSeasonOver(season) then
    GUIUtils.SetActive(self._uiObjs.Group_Mate, true)
    GUIUtils.SetActive(self._uiObjs.Btn_History, true)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    self:DoSelectSeason(season)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Mate, false)
    GUIUtils.SetActive(self._uiObjs.Btn_History, false)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
  end
end
def.method("number").DoSelectSeason = function(self, season)
  self._selectSeason = season
  local top3Info = HistoryData.Instance():GetSeasonTop3Info(self._selectSeason)
  if top3Info then
    self:ShowSeasonTop3Info(top3Info)
  else
    for i = 1, HistoryMainPanel.SHOW_NUM do
      GUIUtils.SetActive(self._uiObjs.TeamGroups1[i].group, false)
      GUIUtils.SetActive(self._uiObjs.TeamGroups2[i].group, false)
    end
    require("Main.CrossBattle.History.HistoryProtocols").SendCGetSeasonTop3Info(self._selectSeason)
  end
  self:ShowSeasonDuration(self._selectSeason)
end
def.method("number", "=>", "number").Idx2Season = function(self, idx)
  return self._curSeason - idx + 1
end
def.method("number", "=>", "number").Season2Idx = function(self, season)
  return self._curSeason - season + 1
end
def.method().ClearSeasonList = function(self)
  if self._uiObjs and self._uiObjs.uiList then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method("table").ShowSeasonTop3Info = function(self, top3Info)
  self._top3Info = top3Info
  if self._top3Info then
    local bTied = self._top3Info:IsTied1st()
    for i = 1, HistoryMainPanel.SHOW_NUM do
      GUIUtils.SetActive(self._uiObjs.TeamGroups1[i].group, not bTied)
      GUIUtils.SetActive(self._uiObjs.TeamGroups2[i].group, bTied)
    end
    local uiGroups
    if bTied then
      uiGroups = self._uiObjs.TeamGroups2
    else
      uiGroups = self._uiObjs.TeamGroups1
    end
    for i = 1, HistoryMainPanel.SHOW_NUM do
      self:ShowCorpsInfo(uiGroups[i], self._top3Info:GetCorpsBriefByIdx(i))
    end
  else
    for i = 1, HistoryMainPanel.SHOW_NUM do
      GUIUtils.SetActive(self._uiObjs.TeamGroups1[i].group, true)
      GUIUtils.SetActive(self._uiObjs.TeamGroups2[i].group, false)
      self:ShowCorpsInfo(self._uiObjs.TeamGroups1[i], nil)
    end
  end
end
def.method("table", "table").ShowCorpsInfo = function(self, uiGroup, corpsBrief)
  if uiGroup == nil then
    warn("[ERROR][HistoryMainPanel:ShowCorpsInfo] uiGroup nil!")
    return
  end
  GUIUtils.SetActive(uiGroup.group, true)
  GUIUtils.SetActive(uiGroup.Btn_Detail, corpsBrief)
  HistoryUtils.ShowCorpsBriefInfo(uiGroup.Img_Badge, uiGroup.Label_TeamName, uiGroup.Label_TeamServer, corpsBrief)
end
def.method("number").ShowSeasonDuration = function(self, season)
  local activityCfg = HistoryData.Instance():GetSeasonActivityCfg(season)
  if activityCfg then
    warn("[HistoryMainPanel:ShowSeasonDuration] season & activityId:", season, activityCfg.id)
    GUIUtils.SetActive(self._uiObjs.Label_Time, true)
    GUIUtils.SetText(self._uiObjs.Label_Time, activityCfg.timeDes)
  else
    GUIUtils.SetActive(self._uiObjs.Label_Time, false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_History" then
    self:OnBtn_History()
  elseif id == "Btn_Edit1st" then
    self:OnBtn_Detail(1)
  elseif id == "Btn_Edit2nd" then
    self:OnBtn_Detail(2)
  elseif id == "Btn_Edit3rd" then
    self:OnBtn_Detail(3)
  elseif id == "Btn_Draw_Edit2nd_1" then
    self:OnBtn_Detail(1)
  elseif id == "Btn_Draw_Edit2nd_2" then
    self:OnBtn_Detail(2)
  elseif id == "Btn_Draw_Edit3rd" then
    self:OnBtn_Detail(3)
  elseif string.find(id, "Img_BgTeam_") then
    self:OnBtn_Season(id)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_History = function(self)
  require("Main.CrossBattle.History.ui.HistoryMatchPanel").ShowPanel(self._selectSeason)
end
def.method("number").OnBtn_Detail = function(self, index)
  local corpsBrief = self._top3Info and self._top3Info:GetCorpsBriefByIdx(index)
  require("Main.CrossBattle.History.ui.HistoryCorpsPanel").ShowPanel(self._selectSeason, corpsBrief)
end
def.method("string").OnBtn_Season = function(self, id)
  local togglePrefix = "Img_BgTeam_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  warn("[HistoryMainPanel:OnBtn_Season] click season:", self:Idx2Season(index))
  self:SelectSeason(self:Idx2Season(index))
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
def.method("table").OnSGetSeasonTop3Info = function(self, top3Info)
  if top3Info and top3Info:GetSeason() == self._selectSeason then
    self:ShowSeasonTop3Info(top3Info)
  end
end
def.method("table").OnSNotifyFinalResultOut = function(self, p)
  self:SelectSeason(self._selectSeason)
end
HistoryMainPanel.Commit()
return HistoryMainPanel
