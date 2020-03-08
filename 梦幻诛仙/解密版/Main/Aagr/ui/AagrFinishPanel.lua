local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AagrData = require("Main.Aagr.data.AagrData")
local AagrFinishPanel = Lplus.Extend(ECPanelBase, "AagrFinishPanel")
local def = AagrFinishPanel.define
local instance
def.static("=>", AagrFinishPanel).Instance = function()
  if instance == nil then
    instance = AagrFinishPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._arenaInfo = nil
def.field("table")._playerRankList = nil
def.field("number")._countdown = 0
local WAIT_DURATION = 10
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.static().ShowPanel = function()
  if not AagrData.Instance():IsInArena() then
    warn("[ERROR][AagrFinishPanel:ShowPanel] show fail! not in arena.")
    if AagrFinishPanel.Instance():IsShow() then
      AagrFinishPanel.Instance():DestroyPanel()
    end
    return
  end
  AagrFinishPanel.Instance():_InitData()
  if AagrFinishPanel.Instance():IsShow() then
    AagrFinishPanel.Instance():UpdateUI()
    return
  end
  AagrFinishPanel.Instance():CreatePanel(RESPATH.PREFAB_AAGR_FINISH_PANEL, 1)
end
def.method()._InitData = function(self)
  self._countdown = AagrData.Instance():GetWaitLeaveDuration()
  self._arenaInfo = AagrData.Instance():GetArenaInfo()
  self._playerRankList = self._arenaInfo and self._arenaInfo:GetPlayerRankList()
  if self._playerRankList and #self._playerRankList > 0 then
    table.sort(self._playerRankList, function(a, b)
      if nil == a then
        return true
      elseif nil == b then
        return false
      elseif a.score ~= b.score then
        return a.score > b.score
      elseif a.kill ~= b.kill then
        return a.kill > b.kill
      elseif a.death ~= b.death then
        return a.death < b.death
      else
        return Int64.lt(a.roleId, b.roleId)
      end
    end)
  end
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
  self:UpdateUI()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Scrollview_List = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List/Scrolllist")
  self._uiObjs.uiScrollView = self._uiObjs.Scrollview_List:GetComponent("UIScrollView")
  self._uiObjs.List = self._uiObjs.Scrollview_List:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.List:GetComponent("UIList")
  self._uiObjs.LabelCountdown = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Btn_Conform/Label")
end
def.method().UpdateUI = function(self)
  self:UpdateRank()
  self:UpdateCountdown()
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
  else
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._arenaInfo = nil
  self._playerRankList = nil
  self._countdown = 0
end
def.method("=>", "number").GetPlayerCount = function(self)
  return self._playerRankList and #self._playerRankList or 0
end
def.method().UpdateRank = function(self)
  self:_ClearList()
  local playerCount = self:GetPlayerCount()
  if playerCount > 0 then
    self._uiObjs.uiList.itemCount = playerCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, playerInfo in ipairs(self._playerRankList) do
      self:ShowPlayerInfo(idx, playerInfo)
    end
  end
end
def.method("number", "table").ShowPlayerInfo = function(self, idx, playerInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][AagrFinishPanel:ShowPlayerInfo] listItem nil at idx:", idx)
    return
  end
  if nil == playerInfo then
    warn("[ERROR][AagrFinishPanel:ShowPlayerInfo] playerInfo nil at idx:", idx)
    return
  end
  local Img_MingCi = listItem:FindDirect("Img_MingCi")
  local Label_Ranking = listItem:FindDirect("Label_Ranking")
  if idx < 4 then
    GUIUtils.SetActive(Img_MingCi, true)
    GUIUtils.SetActive(Label_Ranking, false)
    local spriteName = "Img_Num" .. idx
    GUIUtils.SetSprite(Img_MingCi, spriteName)
  else
    GUIUtils.SetActive(Img_MingCi, false)
    GUIUtils.SetActive(Label_Ranking, true)
    GUIUtils.SetText(Label_Ranking, idx)
  end
  local Label_Name = listItem:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, self._arenaInfo:GetPlayerName(playerInfo.roleId))
  local Label_Kill = listItem:FindDirect("Label_Kill")
  GUIUtils.SetText(Label_Kill, playerInfo.kill)
  local Label_Death = listItem:FindDirect("Label_Death")
  GUIUtils.SetText(Label_Death, playerInfo.death)
  local Label_Points = listItem:FindDirect("Label_Points")
  GUIUtils.SetText(Label_Points, playerInfo.score)
end
def.method()._ClearList = function(self)
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method()._Update = function(self)
  if self._countdown < 0 then
    self:_ClearTimer()
    self:Leave()
  else
    self:UpdateCountdown()
  end
end
def.method().UpdateCountdown = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.LabelCountdown) then
    GUIUtils.SetText(self._uiObjs.LabelCountdown, string.format(textRes.Aagr.ARENA_FINISH_COUNTDOWN, self._countdown))
    self._countdown = self._countdown - 1
  end
end
def.method().Leave = function(self)
  local AagrProtocols = require("Main.Aagr.AagrProtocols")
  AagrProtocols.SendCLeaveGameMapReq()
  self:DestroyPanel()
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Conform" then
    self:OnBtn_Conform()
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Conform = function(self)
  self:Leave()
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
AagrFinishPanel.Commit()
return AagrFinishPanel
