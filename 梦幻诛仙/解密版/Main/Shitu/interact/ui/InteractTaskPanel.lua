local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local InteractMgr = require("Main.Shitu.interact.InteractMgr")
local MasterNode = require("Main.Shitu.interact.ui.MasterNode")
local PrenticeNode = require("Main.Shitu.interact.ui.PrenticeNode")
local InteractTaskPanel = Lplus.Extend(ECPanelBase, "InteractTaskPanel")
local def = InteractTaskPanel.define
local instance
def.static("=>", InteractTaskPanel).Instance = function()
  if instance == nil then
    instance = InteractTaskPanel()
  end
  return instance
end
def.const("table").NodeId = {Master = 1, Prentice = 2}
def.const("number").MAX_TASK_COUNT = 3
def.const("number").MAX_ACTIVE_AWARD_COUNT = 2
def.field("number")._curNodeId = 0
def.field("table")._nodes = nil
def.field("table")._tabs = nil
def.field("table")._tab2NodeIdMap = nil
def.field("table")._reddotCheckFuncMap = nil
def.field("table")._uiObjs = nil
def.method("number").ShowPanel = function(self, nodeId)
  if not InteractMgr.Instance():IsFeatrueTaskOpen(true) then
    if self:IsShow() then
      self:DestroyPanel()
    end
    return
  end
  if self:IsLoaded() then
    return
  end
  if self:IsShow() then
    self:SwitchTo(nodeId)
    return
  end
  self._curNodeId = nodeId
  self:CreatePanel(RESPATH.PREFAB_INTERACT_TASK_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  if self._nodes == nil then
    self._nodes = {}
  end
  if self._tabs == nil then
    self._tabs = {}
  end
  if self._tab2NodeIdMap == nil then
    self._tab2NodeIdMap = {}
  end
  if self._reddotCheckFuncMap == nil then
    self._reddotCheckFuncMap = {}
  end
  local nodeId = InteractTaskPanel.NodeId.Master
  local nodeRoot = self.m_panel:FindDirect("Img_Bg/ToggleObject_Teacher")
  self._tabs[nodeId] = self.m_panel:FindDirect("Img_Bg/Tab_Teacher")
  self._tab2NodeIdMap[self._tabs[nodeId].name] = nodeId
  self._reddotCheckFuncMap[nodeId] = nil
  self._nodes[nodeId] = MasterNode.Instance()
  self._nodes[nodeId]:Init(self, nodeRoot)
  nodeId = InteractTaskPanel.NodeId.Prentice
  nodeRoot = self.m_panel:FindDirect("Img_Bg/ToggleObject_Student")
  self._tabs[nodeId] = self.m_panel:FindDirect("Img_Bg/Tab_Student")
  self._reddotCheckFuncMap[nodeId] = nil
  self._tab2NodeIdMap[self._tabs[nodeId].name] = nodeId
  self._nodes[nodeId] = PrenticeNode.Instance()
  self._nodes[nodeId]:Init(self, nodeRoot)
end
def.override("boolean").OnShow = function(self, bShow)
  self:HandleEventListeners(bShow)
  if bShow then
    if self._curNodeId <= 0 then
      self._curNodeId = InteractTaskPanel.NodeId.Master
    end
    self:SwitchTo(self._curNodeId)
  else
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  if nil == self._tabs[nodeId] then
    warn("[ERROR][InteractTaskPanel:SwitchTo] nodeId invalid:", nodeId)
    return
  end
  warn("[InteractTaskPanel:SwitchTo] Switch To nodeId:", nodeId)
  self._curNodeId = nodeId
  for k, node in pairs(self._nodes) do
    local tabNode = self._tabs[nodeId]
    tabNode:GetComponent("UIToggle").value = true
    if k == nodeId then
      local tabNode = self._tabs[self._curNodeId]
      tabNode:GetComponent("UIToggle").value = true
      if not node.isShow then
        node:Show()
      end
    else
      local tabNode = self._tabs[k]
      tabNode:GetComponent("UIToggle").value = false
      if node.isShow then
        node:Hide()
      end
    end
  end
end
def.override().OnDestroy = function(self)
  if self._nodes then
    for _, node in pairs(self._nodes) do
      if node.isShow then
        node:Hide()
      end
    end
  end
  self._uiObjs = nil
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Tab_") then
    self:OnTabClicked(id)
  else
    self._nodes[self._curNodeId]:onClickObj(clickObj)
  end
end
def.method("string").OnTabClicked = function(self, id)
  warn("[InteractTaskPanel:OnTabClicked] tab clicked:", id)
  local nodeId = id and self._tab2NodeIdMap[id] or 0
  self:SwitchTo(nodeId)
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
def.static("table", "table").OnTaskInfoChange = function(param, context)
  local self = instance
  if self:IsShow() then
    self:UpdateUI()
  end
end
InteractTaskPanel.Commit()
return InteractTaskPanel
