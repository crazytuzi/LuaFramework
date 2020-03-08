local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GrowGuidePanel = Lplus.Extend(ECPanelBase, CUR_CLASS_NAME)
local DailyGoalNode = import(".DailyGoalNode")
local GrowAchievementNode = import(".GrowAchievementNode")
local BaodianNode = import(".BaodianNode")
local BianqiangNode = import(".BianqiangNode")
local AchievementNode = import(".AchievementNode")
local Vector = require("Types.Vector")
local def = GrowGuidePanel.define
local GUIUtils = require("GUI.GUIUtils")
local NodeId = {
  None = 0,
  DailyGoal = 1,
  Achievement = 2,
  GrowAchievement = 3,
  Encyclopedia = 4,
  AdvanceGuide = 5
}
def.const("table").NodeId = NodeId
local NodeDefines = {
  [NodeId.DailyGoal] = {
    tabName = "Tab_RC",
    rootName = "Group_RC",
    node = false,
    titleSpriteName = "Label_MRMB"
  },
  [NodeId.Achievement] = {
    tabName = "Tab_CJ",
    rootName = "Group_CJ",
    node = AchievementNode,
    titleSpriteName = "Label_CZMB"
  },
  [NodeId.GrowAchievement] = {
    tabName = "Tab_CZ",
    rootName = "Group_CZ",
    node = GrowAchievementNode,
    titleSpriteName = "Label_CZMB"
  },
  [NodeId.Encyclopedia] = {
    tabName = "Tab_BD",
    rootName = "Group_BD",
    node = BaodianNode,
    titleSpriteName = "Label_MZMJ"
  },
  [NodeId.AdvanceGuide] = {
    tabName = "Tab_TS",
    rootName = "Group_BQ",
    node = BianqiangNode,
    titleSpriteName = "Label_WYBQ"
  }
}
def.field("number").curNode = 0
def.field("table").nodes = nil
def.field("table").uiObjs = nil
def.field("boolean").haveSpecNode = false
def.field("table").nodeParams = nil
local instance
def.static("=>", GrowGuidePanel).Instance = function()
  if instance == nil then
    instance = GrowGuidePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
  self.m_TryIncLoadSpeed = true
  if AchievementNode.IsAchievementFeatureOpen() then
    self.curNode = NodeId.Achievement
  else
    self.curNode = NodeId.AdvanceGuide
  end
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  if self.curNode == NodeId.Achievement and not AchievementNode.IsAchievementFeatureOpen() then
    self.curNode = NodeId.AdvanceGuide
  end
  self:CreatePanel(RESPATH.PREFAB_COMPREHENSIVE_GUIDE_PANEL, 1)
  self:SetModal(true)
end
def.method("number").SetCurNode = function(self, nodeId)
  self.curNode = nodeId
  self.haveSpecNode = true
end
def.method("varlist").ShowDlgEx = function(self, nodeId, nodeParams)
  self.nodeParams = nodeParams
  if tonumber(nodeId) then
    self:SetCurNode(nodeId)
  end
  self:ShowDlg()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.nodes = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = self.uiObjs.Img_Bg:FindDirect(v.rootName)
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
  self:UpdateTabGroup()
  self:LocateFocusNode()
  self:UpdateNotifyBadges()
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_GROW_ACHIEVEMENT, GrowGuidePanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_DAILY_GOAL, GrowGuidePanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, GrowGuidePanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GrowGuidePanel.OnFeatureOpenChange)
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    return
  end
  self:SwitchToNode(self.curNode)
end
def.override().OnDestroy = function(self)
  if self.curNode ~= GrowGuidePanel.NodeId.None then
    self.nodes[self.curNode]:Hide()
  end
  self.nodes[NodeId.Achievement]:OnDestroy()
  self.haveSpecNode = false
  if AchievementNode.IsAchievementFeatureOpen() then
    self.curNode = NodeId.Achievement
  else
    self.curNode = NodeId.AdvanceGuide
  end
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_GROW_ACHIEVEMENT, GrowGuidePanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.UPDATE_DAILY_GOAL, GrowGuidePanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, GrowGuidePanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GrowGuidePanel.OnFeatureOpenChange)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if self:onClick(id) then
  else
    self.nodes[self.curNode]:onClickObj(obj)
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
      if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
        local ECMSDK = require("ProxySDK.ECMSDK")
        ECMSDK.SendTLogToServer(_G.TLOGTYPE.STRONG, {2})
      end
      self:SwitchToNode(nodeId)
    else
      rs = false
    end
  end
  return rs
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
  if self.curNode ~= GrowGuidePanel.NodeId.None then
    self.nodes[self.curNode]:onToggle(id, isActive)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_BgEquip")
  self.uiObjs.Grid_Tab = self.uiObjs.Img_Bg:FindDirect("Grid_Tab")
  self.uiObjs.Img_Title = self.uiObjs.Img_Bg:FindDirect("Group_Title/Img_BgTitle/Img_LabelTitle")
end
def.method().UpdateUI = function(self)
  self.nodes[self.curNode]:UpdateUI()
end
def.method().UpdateTabGroup = function(self)
  local lastNode = self.curNode
  self.curNode = GrowGuidePanel.NodeId.None
  for i, node in ipairs(self.nodes) do
    local tab = self.uiObjs.Grid_Tab:FindDirect(NodeDefines[i].tabName)
    if node and node:IsUnlock() then
      GUIUtils.SetActive(tab, true)
      if i == lastNode or lastNode == GrowGuidePanel.NodeId.None then
        self.curNode = i
        lastNode = self.curNode
      end
    else
      if node then
        node:Hide()
      end
      GUIUtils.SetActive(tab, false)
      if i == lastNode then
        lastNode = GrowGuidePanel.NodeId.None
      end
    end
  end
  self.uiObjs.Grid_Tab:GetComponent("UIGrid"):Reposition()
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in ipairs(NodeDefines) do
    if v.tabName == tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method("number").SwitchToNode = function(self, node)
  if self.curNode ~= GrowGuidePanel.NodeId.None and self.curNode ~= node then
    self.nodes[self.curNode]:Hide()
  end
  self.curNode = node
  if self.curNode == GrowGuidePanel.NodeId.None then
    return
  end
  local tabName = NodeDefines[self.curNode].tabName
  self.uiObjs.Grid_Tab:FindDirect(tabName):GetComponent("UIToggle"):set_value(true)
  self.nodes[self.curNode]:ShowWithParams(self.nodeParams)
  self.nodeParams = nil
  self:UpdatePanelTitle()
end
def.method().UpdatePanelTitle = function(self)
  local titleSpriteName = NodeDefines[self.curNode].titleSpriteName or "nil"
  GUIUtils.SetSprite(self.uiObjs.Img_Title, titleSpriteName)
end
def.method().LocateFocusNode = function(self)
  if self.haveSpecNode then
  else
    self:LocateNotifyNode()
  end
end
def.method().LocateNotifyNode = function(self)
  for i, node in ipairs(self.nodes) do
    if node and node:HaveNotifyMessage() then
      self.curNode = i
      break
    end
  end
end
def.method().UpdateNotifyBadges = function(self)
  for i, node in ipairs(self.nodes) do
    if node then
      node:UpdateNotifyBadge()
    end
  end
end
def.method("number", "boolean").SetTabNotify = function(self, nodeId, state)
  local tab = self.uiObjs.Grid_Tab:FindDirect(NodeDefines[nodeId].tabName)
  local Img_Red = tab:FindDirect("Img_Red")
  if Img_Red then
    Img_Red:SetActive(state)
  end
end
def.static("table", "table").OnTabNotifyMessageUpdate = function()
  instance:UpdateNotifyBadges()
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local self = instance
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p.feature == Feature.TYPE_ACHIEVEMENT and instance then
    local lastNode = self.curNode
    self:UpdateTabGroup()
    if not p.open and lastNode == NodeId.Achievement then
      self:SwitchToNode(NodeId.AdvanceGuide)
    end
  end
end
return GrowGuidePanel.Commit()
