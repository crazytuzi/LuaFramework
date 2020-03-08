local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BetInfoPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local BetRoundRobinNode = import(".BetRoundRobinNode")
local BetSelectionNode = import(".BetSelectionNode")
local BetFinalNode = import(".BetFinalNode")
local def = BetInfoPanel.define
local NodeId = {
  None = -1,
  RoundRobin = 0,
  Selection = 1,
  Final = 2
}
local NodeDefines = {
  [NodeId.RoundRobin] = {
    rootName = "Img_BgTeam",
    tabName = "Tap_XHS",
    node = BetRoundRobinNode,
    stage = -1
  },
  [NodeId.Selection] = {
    rootName = "Img_BgTeam",
    tabName = "Tap_XBS",
    node = BetSelectionNode,
    stage = CrossBattleActivityStage.STAGE_SELECTION
  },
  [NodeId.Final] = {
    rootName = "Img_BgTeam",
    tabName = "Tap_ZJS",
    node = BetFinalNode,
    stage = CrossBattleActivityStage.STAGE_FINAL
  }
}
def.field("table").m_UIGOs = nil
def.field("table").m_nodes = nil
def.field("table").m_tabToggles = nil
def.field("table").m_tabName2NodeId = nil
def.field("number").m_curNode = NodeId.None
def.field("number").m_nextNode = NodeId.RoundRobin
local instance
def.static("=>", BetInfoPanel).Instance = function()
  if instance == nil then
    instance = BetInfoPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_BATTLE_BET_INFO_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitNodes()
  self:UpdateUI()
  require("Main.CrossBattle.Bet.CrossBattleBetMgr").Instance():MarkTodaysBetNotifyReaded()
end
def.override().OnDestroy = function(self)
  self:HideCurNode()
  self.m_UIGOs = nil
  self.m_nodes = nil
  self.m_tabToggles = nil
  self.m_tabName2NodeId = nil
  self.m_curNode = NodeId.None
  self.m_nextNode = NodeId.RoundRobin
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    if self.m_panel then
      self:HideCurNode()
    end
    return
  end
  self:SwitchToNode(self.m_nextNode)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      self:Check2SwitchToNode(nodeId)
    elseif self.m_curNode ~= NodeId.None then
      self.m_nodes[self.m_curNode]:onClickObj(obj)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
end
def.method().UpdateUI = function(self)
end
def.method().InitNodes = function(self)
  self.m_nodes = {}
  self.m_tabToggles = {}
  self.m_tabName2NodeId = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = self.m_UIGOs.Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    local tabGO = self.m_UIGOs.Img_Bg0:FindDirect(v.tabName)
    if tabGO then
      local uiToggle = tabGO:GetComponent("UIToggle")
      uiToggle:set_startsActive(false)
      self.m_tabToggles[nodeId] = uiToggle
    end
    if v.node then
      self.m_nodes[nodeId] = v.node()
      self.m_nodes[nodeId]:Init(self, nodeRoot)
      self.m_nodes[nodeId]:SetNodeId(nodeId)
    end
    self.m_tabName2NodeId[v.tabName] = nodeId
  end
  self:SelectCurActivityStageNode()
end
def.method("number").SwitchToNode = function(self, node)
  if self.m_curNode ~= NodeId.None then
    self.m_nodes[self.m_curNode]:Hide()
  end
  self.m_curNode = node
  self.m_nextNode = self.m_curNode
  if self.m_tabToggles[self.m_curNode] then
    self.m_tabToggles[self.m_curNode]:set_value(true)
  end
  warn("self.m_curNode", self.m_curNode)
  self.m_nodes[self.m_curNode]:Show()
end
def.method().HideCurNode = function(self)
  if self.m_nodes == nil then
    return
  end
  if self.m_curNode ~= NodeId.None then
    self.m_nodes[self.m_curNode]:Hide()
    self.m_curNode = NodeId.None
  end
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  return self.m_tabName2NodeId[tabName] or NodeId.None
end
def.method().SelectCurActivityStageNode = function(self)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local nodeId
  if curStage == CrossBattleActivityStage.STAGE_SELECTION then
    nodeId = NodeId.Selection
  elseif curStage == CrossBattleActivityStage.STAGE_FINAL then
    nodeId = NodeId.Final
  else
    nodeId = NodeId.RoundRobin
  end
  self.m_nextNode = nodeId
end
def.method("number").Check2SwitchToNode = function(self, nodeId)
  local crossBattleInterface = CrossBattleInterface.Instance()
  local curStage = crossBattleInterface:getCurCrossBattleStage()
  local nodeStage = NodeDefines[nodeId].stage
  if curStage < nodeStage then
    if self.m_tabToggles[self.m_curNode] then
      self.m_tabToggles[self.m_curNode]:set_value(true)
    end
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local beginTime = CrossBattleInterface.Instance():getCrossBattleStageTime(nodeStage)
    local t = AbsoluteTimer.GetServerTimeTable(beginTime)
    local text = textRes.CrossBattle.Bet[9]:format(textRes.CrossBattle.stageStr[nodeStage], t.year, t.month, t.day)
    Toast(text)
    return
  end
  self:SwitchToNode(nodeId)
end
return BetInfoPanel.Commit()
