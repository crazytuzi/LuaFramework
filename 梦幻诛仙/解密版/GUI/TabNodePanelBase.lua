local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNodePanelBase = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = TabNodePanelBase
local def = Cls.define
local GUIUtils = require("GUI.GUIUtils")
local EMPTY_NODE = 0
def.const("number").EMPTY_NODE = EMPTY_NODE
def.field("table").m_nodes = nil
def.field("table").m_nodeDefines = nil
def.field("number").m_curNodeId = EMPTY_NODE
def.field("number").m_nextNodeId = EMPTY_NODE
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:ShowNextNode()
  elseif self.m_panel then
    self:HideCurNode(false)
  end
end
def.override().OnDestroy = function(self)
  self:HideCurNode(true)
  self.m_nodes = nil
  self.m_nodeDefines = nil
  self.m_curNodeId = EMPTY_NODE
  self.m_nextNodeId = EMPTY_NODE
end
def.method().ShowNextNode = function(self)
  self:ShowNode(self.m_nextNodeId)
end
def.method("number").ShowNode = function(self, nodeId)
  if nodeId == EMPTY_NODE then
    return
  end
  local curNode = self:GetCurNode()
  if nodeId == self.m_curNodeId then
    if curNode and curNode.isShow then
      return
    end
  elseif curNode then
    curNode:Hold(false)
    curNode:Hide()
  end
  local tab = self:GetNodeTabGameObject(nodeId)
  if tab then
    GUIUtils.Toggle(tab, true)
  end
  curNode = self:GetNode(nodeId)
  if curNode == nil then
    return
  end
  local lastNodeId = self.m_curNodeId
  self.m_curNodeId = nodeId
  self.m_nextNodeId = nodeId
  curNode:Show()
  if lastNodeId ~= nodeId then
    curNode:Hold(true)
    self:OnNodeChanged(lastNodeId, nodeId)
  end
end
def.method("boolean").HideCurNode = function(self, isCurNodeChange)
  local curNode = self:GetCurNode()
  if curNode then
    self.m_nextNodeId = self.m_curNodeId
    if isCurNodeChange then
      curNode:Hold(false)
      curNode:Hide()
      self.m_curNodeId = EMPTY_NODE
      self:OnNodeChanged(self.m_nextNodeId, self.m_curNodeId)
    else
      curNode:Hide()
    end
  end
end
def.method("=>", "table").GetCurNode = function(self)
  return self:GetNode(self.m_curNodeId)
end
def.method("number", "=>", "table").GetNode = function(self, nodeId)
  if nodeId == EMPTY_NODE then
    return nil
  end
  self.m_nodes = self.m_nodes or {}
  local node = self.m_nodes[nodeId]
  if node == nil then
    node = self:CreateAndInitNode(nodeId)
    self.m_nodes[nodeId] = node
  end
  return node
end
def.method("table").SetNodeDefines = function(self, nodeDefines)
  self.m_nodeDefines = nodeDefines
end
def.method("number", "=>", "table").GetNodeDefine = function(self, nodeId)
  local nodeDefine
  if self.m_nodeDefines then
    nodeDefine = self.m_nodeDefines[nodeId]
  end
  if nodeDefine == nil then
    warn("Need node define for nodeId = " .. nodeId)
  end
  return nodeDefine
end
def.virtual("userdata").onClickObj = function(self, obj)
  local curNode = self:GetCurNode()
  if curNode then
    curNode:onClickObj(obj)
  end
end
def.virtual("number", "=>", "table").CreateAndInitNode = function(self, nodeId)
  local nodeDefine = self:GetNodeDefine(nodeId)
  if nodeDefine == nil then
    return nil
  end
  local moduleName = self:GetModuleName()
  local nodeClass = import(nodeDefine.classPath, moduleName)
  local node = nodeClass()
  local nodeRoot = self.m_panel:FindDirect(nodeDefine.rootPath)
  node:Init(self, nodeRoot)
  return node
end
def.virtual("number", "=>", "userdata").GetNodeTabGameObject = function(self, nodeId)
  local nodeDefine = self:GetNodeDefine(nodeId)
  if nodeDefine == nil then
    return nil
  end
  local tab = self.m_panel:FindDirect(nodeDefine.tabPath)
  return tab
end
def.virtual("=>", "string").GetModuleName = function(self)
  return ""
end
def.virtual("number", "number").OnNodeChanged = function(self, lastNodeId, curNodeId)
end
return Cls.Commit()
