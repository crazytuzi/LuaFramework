local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangDungeonGoalPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local PersonalGoalNode = import(".PersonalGoalNode")
local GangGoalNode = import(".GangGoalNode")
local GangDungeonModule = require("Main.GangDungeon.GangDungeonModule")
local def = GangDungeonGoalPanel.define
local NodeId = {
  None = 0,
  Personal = 1,
  Gang = 2
}
local NodeDefines = {
  [NodeId.Personal] = {
    rootName = "Group_List",
    tabName = "Tap_GR",
    node = PersonalGoalNode
  },
  [NodeId.Gang] = {
    rootName = "Group_List",
    tabName = "Tap_BP",
    node = GangGoalNode
  }
}
local instance
def.static("=>", GangDungeonGoalPanel).Instance = function()
  if instance == nil then
    instance = GangDungeonGoalPanel()
    instance:Init()
  end
  return instance
end
def.field("table").m_UIGOs = nil
def.field("boolean").m_switch = true
def.field("table").m_nodes = nil
def.field("table").m_tabToggles = nil
def.field("table").m_tabName2NodeId = nil
def.field("number").m_curNode = NodeId.None
def.field("number").m_nextNode = NodeId.Personal
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetDepth(GUIDEPTH.BOTTOM)
  self:CreatePanel(RESPATH.PREFAB_GANG_DUNGEON_GOAL, 0)
end
def.method("=>", "boolean").CanShow = function(self)
  return GangDungeonModule.Instance():IsInActivityMap()
end
def.override().OnCreate = function(self)
  if not self:CanShow() then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:InitNodes()
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.LeaveGangDungeon, GangDungeonGoalPanel.OnLeaveGangDungeon)
  Event.RegisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ChangeGangDungeonMap, GangDungeonGoalPanel.OnChangeGangDungeonMap)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GangDungeonGoalPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, GangDungeonGoalPanel.OnLeaveFight)
  if _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.override().OnDestroy = function(self)
  self:OnHide()
  self.m_UIGOs = nil
  self.m_nodes = nil
  self.m_tabToggles = nil
  self.m_tabName2NodeId = nil
  self.m_switch = true
  self.m_curNode = NodeId.None
  self.m_nextNode = NodeId.Personal
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.LeaveGangDungeon, GangDungeonGoalPanel.OnLeaveGangDungeon)
  Event.UnregisterEvent(ModuleId.GANG_DUNGEON, gmodule.notifyId.GangDungeon.ChangeGangDungeonMap, GangDungeonGoalPanel.OnChangeGangDungeonMap)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GangDungeonGoalPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, GangDungeonGoalPanel.OnLeaveFight)
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    if self.m_panel then
      self:OnHide()
    end
    return
  end
  self:UpdateSwitch(self.m_switch)
end
def.method().OnHide = function(self)
  self:HideCurNode()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Img_Down" then
    self:UpdateSwitch(true)
  elseif id == "Img_Up" then
    self:UpdateSwitch(false)
  elseif id == "Btn_Tips" then
    self:ShowTip()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      self:SwitchToNode(nodeId)
    elseif self.m_curNode ~= NodeId.None then
      self.m_nodes[self.m_curNode]:onClickObj(obj)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg_BP = self.m_panel:FindDirect("Container/Img_Bg_BP")
  self.m_UIGOs.Group_TAb = self.m_panel:FindDirect("Container/Group_TAb")
  self.m_UIGOs.Label_Title = self.m_panel:FindDirect("Container/Label_Title")
end
def.method().InitNodes = function(self)
  self.m_nodes = {}
  self.m_tabToggles = {}
  self.m_tabName2NodeId = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = self.m_UIGOs.Img_Bg_BP:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    local tabGO = self.m_UIGOs.Group_TAb:FindDirect(v.tabName)
    if tabGO then
      local uiToggle = tabGO:GetComponent("UIToggle")
      uiToggle:set_startsActive(false)
      self.m_tabToggles[nodeId] = uiToggle
    end
    if v.node then
      self.m_nodes[nodeId] = v.node()
      self.m_nodes[nodeId]:Init(self, nodeRoot)
      self.m_nodes[nodeId].nodeId = nodeId
    end
    self.m_tabName2NodeId[v.tabName] = nodeId
  end
end
def.method().UpdateUI = function(self)
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
def.method("boolean").UpdateSwitch = function(self, switch)
  self.m_switch = switch
  local up = self.m_panel:FindDirect("Container/Img_Up")
  local down = self.m_panel:FindDirect("Container/Img_Down")
  local bg = self.m_panel:FindDirect("Container/Img_Bg_BP")
  local Group_TAb = self.m_panel:FindDirect("Container/Group_TAb")
  local Group_List = bg:FindDirect("Group_List")
  if self.m_switch then
    up:SetActive(true)
    down:SetActive(false)
    Group_List:SetActive(true)
    Group_TAb:SetActive(true)
    self:SwitchToNode(self.m_nextNode)
  else
    up:SetActive(false)
    down:SetActive(true)
    Group_List:SetActive(false)
    Group_TAb:SetActive(false)
    self:HideCurNode()
  end
  bg:GetComponent("UITableResizeBackground"):Reposition()
end
def.method("string").SetTitle = function(self, title)
  GUIUtils.SetText(self.m_UIGOs.Label_Title, title)
end
def.method().ShowTip = function(self)
  local GangDungeonUtils = require("Main.GangDungeon.GangDungeonUtils")
  local tipsId = GangDungeonUtils.GetConstant("GoalTips")
  GUIUtils.ShowHoverTip(tipsId)
end
def.static("table", "table").OnLeaveGangDungeon = function(params, context)
  instance:DestroyPanel()
end
def.static("table", "table").OnChangeGangDungeonMap = function(params, context)
  if not instance:CanShow() then
    instance:DestroyPanel()
  end
end
def.static("table", "table").OnEnterFight = function(params, context)
  instance:Show(false)
end
def.static("table", "table").OnLeaveFight = function(params, context)
  instance:Show(true)
end
return GangDungeonGoalPanel.Commit()
