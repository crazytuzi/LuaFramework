local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GangTeamPanel = Lplus.Extend(ECPanelBase, "GangTeamPanel")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangTeamSelfNode = import(".GangTeamSelfNode")
local GangTeamListNode = import(".GangTeamListNode")
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local def = GangTeamPanel.define
local instance
def.field(GangData).data = nil
local NodeId = {
  None = 0,
  SelfTeam = 1,
  TeamList = 2
}
local NodeDefines = {
  [NodeId.SelfTeam] = {
    tabName = "Tab_WD",
    rootName = "Group_WD",
    node = GangTeamSelfNode
  },
  [NodeId.TeamList] = {
    tabName = "Tab_TD",
    rootName = "Group_TD",
    node = GangTeamListNode
  }
}
def.field("table").uiTbl = nil
def.field("table").nodes = nil
def.const("table").NodeId = NodeId
def.field("number").curNode = 0
def.static("=>", GangTeamPanel).Instance = function(self)
  if nil == instance then
    instance = GangTeamPanel()
    instance:Init()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitNodes()
end
def.override().OnDestroy = function(self)
  if self.curNode ~= GangTeamPanel.NodeId.None then
    self.nodes[self.curNode]:Hide()
  end
  self.curNode = NodeId.SelfTeam
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:SwitchToNode(self.curNode)
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  else
    self:CreatePanel(RESPATH.PREFAB_GANG_TEAM_PANEL, 1)
    self:SetModal(true)
  end
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().Init = function(self)
  self.m_TrigGC = true
  self.data = GangData.Instance()
  self.curNode = NodeId.SelfTeam
end
def.method().InitNodes = function(self)
  local Img_Bg0 = self.uiTbl.Img_Bg0
  self.nodes = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.node then
      self.nodes[nodeId] = v.node.Instance()
      self.nodes[nodeId]:Init(self, nodeRoot)
      self.nodes[nodeId].nodeId = nodeId
    else
      self.nodes[nodeId] = v.node
    end
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  uiTbl.Img_Bg0 = Img_Bg0
end
def.method().UpdateUI = function(self)
  self.nodes[self.curNode]:UpdateUI()
end
def.method("number").SwitchToNode = function(self, node)
  if self.curNode ~= GangTeamPanel.NodeId.None and self.curNode ~= node then
    self.nodes[self.curNode]:Hide()
  end
  self.curNode = node
  if self.curNode == GangTeamPanel.NodeId.None then
    return
  end
  local Img_Bg0 = self.uiTbl.Img_Bg0
  local tabName = NodeDefines[self.curNode].tabName
  Img_Bg0:FindDirect(tabName):GetComponent("UIToggle"):set_value(true)
  self.nodes[self.curNode]:Show()
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in ipairs(NodeDefines) do
    if v.tabName == tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method().checkRedDot = function(self)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if not self:onClick(id) then
    self.nodes[self.curNode]:onClickObj(obj)
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local res = true
  if id == "Btn_Close" then
    self:HidePanel()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      self:SwitchToNode(nodeId)
    else
      res = false
    end
  end
  return res
end
return GangTeamPanel.Commit()
