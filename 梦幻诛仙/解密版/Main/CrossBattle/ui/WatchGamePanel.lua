local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WatchGamePanel = Lplus.Extend(ECPanelBase, "WatchGamePanel")
local GameLiveNode = require("Main.CrossBattle.ui.GameLiveNode")
local GameReviewNode = require("Main.CrossBattle.ui.GameReviewNode")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local CorpsInterface = require("Main.Corps.CorpsInterface")
local GUIUtils = require("GUI.GUIUtils")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = WatchGamePanel.define
local instance
def.field("table").nodes = nil
def.field("table").tabToggles = nil
def.field("number").curNode = 0
local NodeId = {GAME_LIVE = 1, GAME_REVIEW = 2}
local NodeDefines = {
  [NodeId.GAME_LIVE] = {
    tabName = "Tap_SSZB",
    rootName = "Group_Type01",
    node = GameLiveNode
  },
  [NodeId.GAME_REVIEW] = {
    tabName = "Tap_JSHG",
    rootName = "Group_Type02",
    node = GameReviewNode
  }
}
def.static("=>", WatchGamePanel).Instance = function()
  if instance == nil then
    warn("-----------instance----")
    instance = WatchGamePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_WATCH, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self.tabToggles[self.curNode].value = true
    self.nodes[self.curNode]:Show()
  else
    self.nodes[self.curNode]:Hide()
  end
end
def.override().OnCreate = function(self)
  warn("------------OnCreate----")
  self:InitUI()
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Change, WatchGamePanel.OnRoundRobinInfoChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, WatchGamePanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, WatchGamePanel.OnLeaveFight)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Change, WatchGamePanel.OnRoundRobinInfoChange)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, WatchGamePanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, WatchGamePanel.OnLeaveFight)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnRoundRobinInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    local curStage = CrossBattleInterface.Instance():getCurCrossBattleStage()
    if curStage == CrossBattleActivityStage.STAGE_ROUND_ROBIN and instance.nodes[NodeId.GAME_LIVE] then
      instance.nodes[NodeId.GAME_LIVE]:setRoundRobinInfo()
    end
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if instance and instance:IsShow() then
    instance:Show(false)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:Show(true)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------CrossBattleReadPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Tap_SSZB" then
    self:switchTab(NodeId.GAME_LIVE)
  elseif id == "Tap_JSHG" then
    self:switchTab(NodeId.GAME_REVIEW)
  elseif id == "Btn_Close" then
    self:Hide()
  else
    self.nodes[self.curNode]:onClickObj(clickObj)
  end
end
def.method("number").switchTab = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  self.nodes[self.curNode]:Hide()
  self.curNode = nodeId
  self.nodes[nodeId]:Show()
end
def.method().InitUI = function(self)
  if not self.m_panel and self.m_panel.isnil then
    return
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.nodes = {}
  self.tabToggles = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.node then
      self.nodes[nodeId] = v.node()
      self.nodes[nodeId]:Init(self, nodeRoot)
    end
    local tab = Img_Bg0:FindDirect(v.tabName)
    if tab then
      self.tabToggles[nodeId] = tab:GetComponent("UIToggle")
      self.tabToggles[nodeId].value = false
    end
  end
  if self.curNode == 0 then
    self.curNode = NodeId.GAME_LIVE
  end
  if self.m_panel and not self.m_panel.isnil then
    self.tabToggles[self.curNode].value = true
  end
end
WatchGamePanel.Commit()
return WatchGamePanel
