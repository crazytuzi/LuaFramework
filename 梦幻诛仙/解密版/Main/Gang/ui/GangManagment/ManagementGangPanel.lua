local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SetDutyNameNode = require("Main.Gang.ui.GangManagment.SetDutyNameNode")
local SetXueTuLevelNode = require("Main.Gang.ui.GangManagment.SetXueTuLevelNode")
local SetTanheNode = require("Main.Gang.ui.GangManagment.SetTanheNode")
local DismissGangNode = require("Main.Gang.ui.GangManagment.DismissGangNode")
local MergeGangNode = require("Main.Gang.ui.GangManagment.MergeGangNode")
local GangData = require("Main.Gang.data.GangData")
local ManagementGangPanel = Lplus.Extend(ECPanelBase, "ManagementGangPanel")
local def = ManagementGangPanel.define
local instance
def.field("function").callback = nil
def.field("table").tag = nil
local NodeId = {
  XUETULEVEL = 1,
  DUTYNAME = 2,
  TANHE = 3,
  DISMISS = 4,
  MERGE = 5
}
local NodeDefines = {
  [NodeId.XUETULEVEL] = {
    tabName = "Tab_SetPositiveLv",
    rootName = "Group_SetPositiveLv",
    node = SetXueTuLevelNode
  },
  [NodeId.DUTYNAME] = {
    tabName = "Tab_SetJobName",
    rootName = "Group_SetJobName",
    node = SetDutyNameNode
  },
  [NodeId.TANHE] = {
    tabName = "Tab_Delate",
    rootName = "Group_Delate",
    node = SetTanheNode
  },
  [NodeId.DISMISS] = {
    tabName = "Tab_Dismiss",
    rootName = "Group_Dismiss",
    node = DismissGangNode
  },
  [NodeId.MERGE] = {
    tabName = "Tab_Combine",
    rootName = "Group_Combine",
    node = MergeGangNode
  }
}
def.const("table").NodeId = NodeId
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("table").tabToggles = nil
def.field("userdata").Img_Bg = nil
def.static("=>", ManagementGangPanel).Instance = function(self)
  if nil == instance then
    instance = ManagementGangPanel()
  end
  return instance
end
def.static("function", "number").ShowManagementGangPanel = function(callback, tab)
  ManagementGangPanel.Instance().callback = callback
  ManagementGangPanel.Instance().curNode = tab
  ManagementGangPanel.Instance():SetModal(true)
  ManagementGangPanel.Instance():CreatePanel(RESPATH.PREFAB_MANGEMENT_GANG_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_TanheBangzhu, ManagementGangPanel.OnTanheChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, ManagementGangPanel.OnMergeCombineGangStageChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_VitalityChanged, ManagementGangPanel.OnVitalityChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, ManagementGangPanel.OnGangNoticeStatesChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_TanheBangzhu, ManagementGangPanel.OnTanheChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, ManagementGangPanel.OnMergeCombineGangStageChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_VitalityChanged, ManagementGangPanel.OnVitalityChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, ManagementGangPanel.OnGangNoticeStatesChange)
end
def.method().InitUI = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  self.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self:InitNodes()
  self:InitTabs()
  self.Img_Bg:FindDirect("Tab_Combine"):SetActive(true)
  self.Img_Bg:FindDirect("Tab_Combine/Img_RedPoint"):SetActive(GangData.Instance():IsHaveGangMergeApply())
end
def.method().InitNodes = function(self)
  if not self.Img_Bg or self.Img_Bg.isnil then
    return
  end
  self.nodes = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = self.Img_Bg:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.node then
      self.nodes[nodeId] = v.node()
      self.nodes[nodeId]:Init(self, nodeRoot)
    else
      self.nodes[nodeId] = v.node
    end
  end
end
def.method().InitTabs = function(self)
  if not self.Img_Bg or self.Img_Bg.isnil then
    return
  end
  self.tabToggles = {}
  if 0 == self.curNode then
    self.curNode = NodeId.XUETULEVEL
  end
  for nodeId, v in ipairs(NodeDefines) do
    v.nodeId = nodeId
    local toggleObj = self.Img_Bg:FindDirect(v.tabName)
    if toggleObj then
      self.tabToggles[nodeId] = toggleObj:GetComponent("UIToggle")
    end
  end
  if self.m_panel and not self.m_panel.isnil then
    self.tabToggles[self.curNode].value = true
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    self.nodes[self.curNode]:Hide()
    return
  end
  self.nodes[self.curNode]:Show()
end
def.method("number").SwitchTo = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  self.nodes[self.curNode]:Hide()
  self.curNode = nodeId
  self.nodes[self.curNode]:Show()
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if ManagementGangPanel.Instance().curNode == ManagementGangPanel.NodeId.DUTYNAME then
    self.nodes[self.curNode]:onSelect(id, selected, index)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  elseif "Tab_SetPositiveLv" == id then
    self:SwitchTo(ManagementGangPanel.NodeId.XUETULEVEL)
  elseif "Tab_SetJobName" == id then
    self:SwitchTo(ManagementGangPanel.NodeId.DUTYNAME)
  elseif "Tab_Delate" == id then
    self:SwitchTo(ManagementGangPanel.NodeId.TANHE)
  elseif "Tab_Dismiss" == id then
    self:SwitchTo(ManagementGangPanel.NodeId.DISMISS)
  elseif "Tab_Combine" == id then
    self:SwitchTo(ManagementGangPanel.NodeId.MERGE)
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.static("table", "table").OnTanheChange = function(params, tbl)
  if ManagementGangPanel.Instance().curNode == ManagementGangPanel.NodeId.TANHE then
    ManagementGangPanel.Instance().nodes[ManagementGangPanel.Instance().curNode]:FillTips()
  end
end
def.static("table", "table").OnMergeCombineGangStageChange = function(params, context)
  local curNode = ManagementGangPanel.Instance().curNode
  if curNode == ManagementGangPanel.NodeId.MERGE then
    ManagementGangPanel.Instance().nodes[curNode]:OnMergeStateChange()
  end
end
def.static("table", "table").OnVitalityChange = function(params, context)
  local curNode = ManagementGangPanel.Instance().curNode
  if curNode == ManagementGangPanel.NodeId.MERGE then
    ManagementGangPanel.Instance().nodes[curNode]:OnVitalityChange()
  end
end
def.static("table", "table").OnGangNoticeStatesChange = function(params, context)
  local self = ManagementGangPanel.Instance()
  if not self.Img_Bg or self.Img_Bg.isnil then
    return
  end
  self.Img_Bg:FindDirect("Tab_Combine/Img_RedPoint"):SetActive(GangData.Instance():IsHaveGangMergeApply())
  local node = self.nodes[ManagementGangPanel.NodeId.MERGE]
  if node then
    node:OnGangNoticeStatesChange()
  end
end
def.method("=>", "boolean").IsPanelShow = function(self)
  if self.m_panel then
    return self.m_panel:get_activeInHierarchy()
  else
    return false
  end
end
def.method().Update = function(self)
  if ManagementGangPanel.Instance().curNode == ManagementGangPanel.NodeId.TANHE then
    self.nodes[self.curNode]:UpdateInfo()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
return ManagementGangPanel.Commit()
