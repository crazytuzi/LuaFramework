local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local HistoryMgr = require("Main.CrossBattle.History.HistoryMgr")
local MatchData = require("Main.CrossBattle.History.data.MatchData")
local CorpsMatchNode = require("Main.CrossBattle.History.data.CorpsMatchNode")
local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
local SingleFightResult = require("netio.protocol.mzm.gsp.crossbattle.SingleFightResult")
local MatchListPanel = Lplus.Extend(ECPanelBase, "MatchListPanel")
local def = MatchListPanel.define
local instance
def.static("=>", MatchListPanel).Instance = function()
  if instance == nil then
    instance = MatchListPanel()
  end
  return instance
end
def.const("number").SHOW_NUM = 3
def.field("table")._uiObjs = nil
def.field(MatchData)._matchData = nil
def.field(CorpsMatchNode)._matchNode = nil
def.static(MatchData, CorpsMatchNode).ShowPanel = function(matchData, matchNode)
  if not HistoryMgr.Instance():IsOpen(true) then
    if MatchListPanel.Instance():IsShow() then
      MatchListPanel.Instance():DestroyPanel()
    end
    return
  end
  MatchListPanel.Instance():InitData(matchData, matchNode)
  if MatchListPanel.Instance():IsShow() then
    MatchListPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_CROSSBATTLE_HISTORY_WATCH_PANEL, 2)
end
def.method(MatchData, CorpsMatchNode).InitData = function(self, matchData, matchNode)
  self._matchData = matchData
  self._matchNode = matchNode
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_Bg0/Group_Title/Label_Game")
  self._uiObjs.ScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Type01/Group_List/Scroll View")
  self._uiObjs.uiScrollView = self._uiObjs.ScrollView:GetComponent("UIScrollView")
  self._uiObjs.List_Member = self._uiObjs.ScrollView:FindDirect("List_Member")
  self._uiObjs.uiList = self._uiObjs.List_Member:GetComponent("UIList")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:ShowTitle()
  self:ShowMatchList()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._matchData = nil
  self._matchNode = nil
  self._uiObjs = nil
end
def.method().ShowTitle = function(self)
  local stage = self._matchNode and self._matchNode:GetStage() or -1
  local title = self:GetStageTitle(stage)
  GUIUtils.SetText(self._uiObjs.Label_Title, title)
end
def.method("number", "=>", "string").GetStageTitle = function(self, stage)
  local stageTitle = textRes.CrossBattle.History.STAGE_TITLE[stage]
  return stageTitle and stageTitle or ""
end
def.method().ShowMatchList = function(self)
  self:ClearMatchList()
  local matchList = self._matchNode and self._matchNode:GetMatchList()
  if matchList and #matchList > 0 then
    local validMatchCount = self._matchNode:GetRealMatchCount()
    if validMatchCount <= 0 then
      validMatchCount = #matchList
    end
    self._uiObjs.uiList.itemCount = validMatchCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for i = 1, validMatchCount do
      local listItem = self._uiObjs.uiList.children[i]
      local matchInfo = matchList[i]
      self:ShowMatch(i, listItem, matchInfo)
    end
  end
end
def.method("number", "userdata", "table").ShowMatch = function(self, idx, listItem, matchInfo)
  if nil == listItem then
    warn("[ERROR][MatchListPanel:ShowMatch] listItem nil at idx:", idx)
    return
  end
  if nil == matchInfo then
    warn("[ERROR][MatchListPanel:ShowMatch] matchInfo nil at idx:", idx)
    return
  end
  local corpsGroupA = listItem:FindDirect("Group_Team1")
  self:ShowCorpsInfo(corpsGroupA, matchInfo.corps_a_id, matchInfo.corps_a_state)
  local corpsGroupB = listItem:FindDirect("Group_Team2")
  self:ShowCorpsInfo(corpsGroupB, matchInfo.corps_b_id, matchInfo.corps_b_state)
  local Btn_Video = listItem:FindDirect("Btn_Video")
  if matchInfo.corps_a_state == SingleFightResult.FIGHT_WIN or matchInfo.corps_a_state == SingleFightResult.FIGHT_LOSE or matchInfo.corps_b_state == SingleFightResult.FIGHT_WIN or matchInfo.corps_b_state == SingleFightResult.FIGHT_LOSE then
    GUIUtils.SetActive(Btn_Video, true)
  else
    GUIUtils.SetActive(Btn_Video, false)
  end
end
def.method("userdata", "userdata", "number").ShowCorpsInfo = function(self, corpsGroup, corpsId, fightResult)
  if corpsGroup == nil then
    warn("[ERROR][MatchListPanel:ShowCorpsInfo] corpsGroup nil.")
    return
  end
  local Img_Badge = corpsGroup:FindDirect("Img_Badge")
  local Label_TeamName = corpsGroup:FindDirect("Label_Team1_Name")
  local Label_ServerName = corpsGroup:FindDirect("Label_Server1_Name")
  local corpsBrief = self._matchData and self._matchData:GetCorpsInfo(corpsId)
  HistoryUtils.ShowCorpsBriefInfo(Img_Badge, Label_TeamName, Label_ServerName, corpsBrief)
  local Group_Result = corpsGroup:FindDirect("Group_Result")
  local Img_Win = Group_Result:FindDirect("Img_Win")
  local Img_Lose = Group_Result:FindDirect("Img_Lose")
  local Img_Prepare = Group_Result:FindDirect("Img_Prepare")
  local Img_Fight = Group_Result:FindDirect("Img_Fight")
  local Img_Quit = Group_Result:FindDirect("Img_Quit")
  local Label_Team1_Next = corpsGroup:FindDirect("Label_Team1_Next")
  if fightResult == SingleFightResult.FIGHT_WIN or fightResult == SingleFightResult.ABSTAIN_WIN or fightResult == SingleFightResult.BYE_WIN then
    GUIUtils.SetActive(Img_Win, true)
    GUIUtils.SetActive(Img_Lose, false)
    GUIUtils.SetActive(Img_Prepare, false)
    GUIUtils.SetActive(Img_Fight, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Label_Team1_Next, false)
  elseif fightResult == SingleFightResult.FIGHT_LOSE then
    GUIUtils.SetActive(Img_Win, false)
    GUIUtils.SetActive(Img_Lose, true)
    GUIUtils.SetActive(Img_Prepare, false)
    GUIUtils.SetActive(Img_Fight, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Label_Team1_Next, false)
  elseif fightResult == SingleFightResult.ABSTAIN_LOSE then
    GUIUtils.SetActive(Img_Win, false)
    GUIUtils.SetActive(Img_Lose, false)
    GUIUtils.SetActive(Img_Prepare, false)
    GUIUtils.SetActive(Img_Fight, false)
    GUIUtils.SetActive(Img_Quit, true)
    GUIUtils.SetActive(Label_Team1_Next, false)
  elseif fightResult == SingleFightResult.BYE then
    GUIUtils.SetActive(Img_Win, false)
    GUIUtils.SetActive(Img_Lose, false)
    GUIUtils.SetActive(Img_Prepare, false)
    GUIUtils.SetActive(Img_Fight, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Label_Team1_Next, true)
  else
    GUIUtils.SetActive(Img_Win, false)
    GUIUtils.SetActive(Img_Lose, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Img_Fight, false)
    GUIUtils.SetActive(Img_Quit, false)
    GUIUtils.SetActive(Label_Team1_Next, false)
  end
end
def.method().ClearMatchList = function(self)
  if self._uiObjs and self._uiObjs.uiList then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Video" then
    self:OnBtn_Video(clickObj)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method("userdata").OnBtn_Video = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local id = parent.name
    local index = tonumber(string.sub(id, string.len("item_") + 1))
    local matchInfo = self._matchNode and self._matchNode:GetMatchByIdx(index)
    if matchInfo then
      require("Main.CrossBattle.History.HistoryProtocols").SendCPlayMatch(matchInfo.record_id)
    else
      warn("[ERROR][MatchListPanel:OnBtn_Video] matchInfo nil for idx:", index)
    end
  else
    warn("[ERROR][MatchListPanel:OnBtn_Video] parent nil for clickObj:", clickObj and clickObj.name)
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
MatchListPanel.Commit()
return MatchListPanel
