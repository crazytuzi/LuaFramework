local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIWelcomeParty = Lplus.Extend(ECPanelBase, MODULE_NAME)
local instance
local def = UIWelcomeParty.define
local NewServerCarnivalNode = require("Main.WelcomeParty.ui.NewServerCarnivalNode")
local CarnivalSignNode = require("Main.WelcomeParty.ui.CarnivalSignNode")
local TescoMallNode = require("Main.WelcomeParty.ui.TescoMallNode")
local DouDouGiftNode = require("Main.WelcomeParty.ui.DouDouGiftNode")
local NodeId = {
  None = 0,
  Carnival = 1,
  CarnivalSign = 2,
  TescoMall = 3,
  DoudouGift = 4
}
def.const("table").NodeId = NodeId
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._nodes = nil
def.field("boolean")._isSpecNode = false
def.field("number")._curNodeId = NodeId.CarnivalSign
def.field("table").showedNodeList = nil
def.field("table").tabPos = nil
def.field("table")._tabName2NodeId = nil
def.field("table")._tabToggles = nil
local NodeDefines = {
  [NodeId.Carnival] = {
    tabName = "Tab_Service",
    rootName = "",
    node = NewServerCarnivalNode()
  },
  [NodeId.CarnivalSign] = {
    tabName = "Tab_Qiandao",
    rootName = "",
    node = CarnivalSignNode()
  },
  [NodeId.TescoMall] = {
    tabName = "Tab_Mall",
    rootName = "",
    node = TescoMallNode()
  },
  [NodeId.DoudouGift] = {
    tabName = "Tab_Gift",
    rootName = "",
    node = DouDouGiftNode()
  }
}
def.static("=>", UIWelcomeParty).Instance = function()
  if instance == nil then
    instance = UIWelcomeParty()
    instance:_init()
  end
  return instance
end
def.method()._init = function(self)
  self.m_TrigGC = true
  self._tabName2NodeId = {}
  for nodeId, v in pairs(NodeDefines) do
    self._tabName2NodeId[v.tabName] = nodeId
    require("Main.WelcomeParty.WelcomePartyModule").RegistNode(v.node)
  end
end
def.override().OnCreate = function(self)
  self:_initUI()
  self._nodes = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = self._uiGOs.Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    self._nodes[nodeId] = v.node
    self._nodes[nodeId]:Init(self, nodeRoot)
    self._nodes[nodeId].nodeId = nodeId
  end
  self:ArrangeTabPos()
  for i, node in pairs(self.showedNodeList) do
    node:UpdateNotifyState()
  end
  self:SelectProperNode()
  Event.RegisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, UIWelcomeParty.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, UIWelcomeParty.OnNodesOpenChange)
end
def.method().SelectProperNode = function(self)
  local isLastNodeExist = false
  for i, node in ipairs(self.showedNodeList) do
    if node.nodeId == self._curNodeId then
      isLastNodeExist = true
      break
    end
    if not self._isSpecNode and node:IsHaveNotifyMessage() then
      self._curNodeId = node.nodeId
      isLastNodeExist = true
      break
    end
  end
  if not isLastNodeExist and self.showedNodeList[1] then
    self._curNodeId = self.showedNodeList[1].nodeId
  end
end
def.override().OnDestroy = function(self)
  if self._nodes == nil then
    return
  end
  Event.UnregisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, UIWelcomeParty.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, UIWelcomeParty.OnNodesOpenChange)
  if self._curNodeId ~= UIWelcomeParty.NodeId.None then
    self._nodes[self._curNodeId]:Hide()
  end
  self:_clear()
end
def.method()._initUI = function(self)
  self._uiStatus = {}
  self._uiGOs = {}
  self._uiGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self._uiGOs.scrollView = self.m_panel:FindDirect("Img_Bg0/Group_Left/Scroll View")
  self._uiGOs.Grid = self._uiGOs.scrollView:FindDirect("Grid")
  self._tabToggles = {}
  local comGrid = self._uiGOs.Grid:GetComponent("UIGrid")
  local childCount = self._uiGOs.Grid.childCount
  for i = 0, childCount - 1 do
    local child = self._uiGOs.Grid:GetChild(i)
    local nodeId = self._tabName2NodeId[child.name]
    if nodeId then
      self._tabToggles[nodeId] = child:GetComponent("UIToggle")
      local nodeDef = NodeDefines[nodeId]
      if nodeDef and nodeDef.dynamicName then
        local tabName = nodeDef.dynamicName()
        if tabName and tabName ~= "" then
          local lblTab = child:FindDirect("Label_Tab")
          lblTab:GetComponent("UILabel"):set_text(tabName)
        end
      end
    else
      child:SetActive(false)
      warn(string.format("[ERROR %s is not handle, hide it]", child.name))
    end
  end
  for k, v in pairs(self._tabToggles) do
    v:set_startsActive(false)
  end
end
def.method()._clear = function(self)
  self._uiGOs = nil
  self._uiStatus = nil
  self._isSpecNode = false
  self.showedNodeList = nil
  self.tabPos = nil
end
def.override("boolean").OnShow = function(self, s)
  if s then
    if _G.GameUtil.IsEvaluation() then
      do
        local comUIGrid = self.m_panel:FindDirect("Img_Bg0/Group_Left/Scroll View/Grid"):GetComponent("UIGrid")
        if comUIGrid then
          _G.GameUtil.AddGlobalLateTimer(0, true, function()
            if comUIGrid and self.m_panel and self.m_panel.isnil == false then
              comUIGrid:Reposition()
            end
          end)
        end
      end
    end
    self:SwitchToNode(self._curNodeId)
  elseif self.m_panel and not self.m_panel.isnil then
    self:OnHide()
  end
end
def.method().OnHide = function(self)
  if self._curNodeId ~= UIWelcomeParty.NodeId.None then
    self._nodes[self._curNodeId]:Hide()
  end
end
def.method().ShowPanel = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_NEW_CARVINAL, 1)
  self:SetModal(true)
end
def.method("number").ShowPanelEx = function(self, nodeId)
  if _G.CheckCrossServerAndToast() then
    return
  end
  self._isSpecNode = true
  self._curNodeId = nodeId
  self:ShowPanel()
end
def.method("string", "=>", "number").GetNodeIdByTabName = function(self, tabName)
  return self._tabName2NodeId[tabName] or 0
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in pairs(NodeDefines) do
    if v.tabName == tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method("number", "=>", "boolean").CheckNodeAvaliable = function(self, nodeId)
  local nodeInfo = NodeDefines[nodeId]
  if nodeInfo then
    local tmpObj = nodeInfo.node
    return tmpObj:IsOpen()
  else
    return false
  end
end
def.method("number").SwitchToNode = function(self, nodeId)
  if self._curNodeId ~= UIWelcomeParty.NodeId.None and self._curNodeId ~= nodeId then
    self._nodes[self._curNodeId]:Hide()
  end
  self._curNodeId = nodeId
  self._tabToggles[self._curNodeId]:set_value(true)
  self._nodes[self._curNodeId]:Show()
end
def.method("number", "boolean").SetTabNotify = function(self, nodeId, state)
  if self._tabToggles[nodeId] == nil then
    return
  end
  local tab = self._tabToggles[nodeId].gameObject
  local imgRed = tab:FindDirect("Img_Red")
  if imgRed then
    imgRed:SetActive(state)
  end
end
def.method().ArrangeTabPos = function(self)
  local unlockedNodeList = {}
  for nodeId, node in pairs(self._nodes) do
    if node:IsOpen() then
      table.insert(unlockedNodeList, node)
    elseif self._tabToggles[nodeId] then
      self._tabToggles[nodeId]:set_value(false)
      self._tabToggles[nodeId].gameObject:SetActive(false)
    end
  end
  _G.GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self._uiGOs == nil then
      return
    end
    self._uiGOs.Grid:GetComponent("UIGrid"):Reposition()
  end)
  self.showedNodeList = unlockedNodeList
end
def.method().Reset = function(self)
  self._curNodeId = NodeId.CarnivalSign
end
def.method("number").UpdateTabName = function(self, nodeId)
  if self.m_panel and self._uiGOs and self._uiGOs.Grid then
    local nodeDef = NodeDefines[nodeId]
    if nodeDef then
      local tab = self._uiGOs.Grid:FindDirect(nodeDef.tabName)
      if tab then
        local tabName = nodeDef.dynamicName()
        if tabName and tabName ~= "" then
          local lblTab = tab:FindDirect("Label_Tab")
          lblTab:GetComponent("UILabel"):set_text(tabName)
        end
      end
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if self:onClick(id) then
  else
    self._nodes[self._curNodeId]:onClickObj(clickObj)
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local rs = true
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      self:SwitchToNode(nodeId)
    else
      rs = false
    end
  end
  return rs
end
def.static("table", "table").OnTabNotifyMessageUpdate = function(p1, p2)
  local self = instance
  local nodeId = p1 and p1[1] or 0
  if nodeId ~= 0 then
    local node = self._nodes[nodeId]
    if node then
      node:UpdateNotifyState()
    end
  else
    for nodeId, node in pairs(self._nodes) do
      node:UpdateNotifyState()
    end
  end
end
def.static("table", "table").OnNodesOpenChange = function(p, c)
  local nodeId = p.nodeId
  if nodeId == nil then
    return
  end
  if NodeDefines[nodeId] == nil then
    return
  end
  if not require("Main.WelcomeParty.WelcomePartyModule").Instance():IsOpen() then
    instance:DestroyPanel()
    return
  end
  if instance then
    local bNodeAvaliable = instance:CheckNodeAvaliable(nodeId)
    if instance._tabToggles[nodeId] ~= nil then
      instance._tabToggles[nodeId].gameObject:SetActive(bNodeAvaliable)
    end
    instance:ArrangeTabPos()
    if instance._curNodeId == nodeId then
      if not bNodeAvaliable then
        for nodeId, v in pairs(instance._nodes) do
          if v:IsOpen() then
            instance:SwitchToNode(nodeId)
            break
          end
        end
      else
        instance:SwitchToNode(nodeId)
      end
    end
  end
end
return UIWelcomeParty.Commit()
