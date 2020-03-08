local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangMembersNode = require("Main.Gang.ui.GangMembersNode")
local GangAffairsNode = require("Main.Gang.ui.GangAffairsNode")
local GangWelfareNode = require("Main.Gang.ui.GangWelfareNode")
local GangActivityNode = require("Main.Gang.ui.GangActivityNode")
local HaveGangPanel = Lplus.Extend(ECPanelBase, "HaveGangPanel")
local def = HaveGangPanel.define
local instance
local NodeId = {
  ALL = 0,
  MEMBERS = 1,
  AFFAIRS = 2,
  WELFARE = 3,
  ACTIVITY = 4
}
local NodeDefines = {
  [NodeId.MEMBERS] = {
    tabName = "Tab_CY",
    rootName = "Group_CY",
    node = GangMembersNode
  },
  [NodeId.AFFAIRS] = {
    tabName = "Tab_CY",
    rootName = "Group_NZ",
    node = GangAffairsNode
  },
  [NodeId.WELFARE] = {
    tabName = "Tab_FL",
    rootName = "Group_FL",
    node = GangWelfareNode
  },
  [NodeId.ACTIVITY] = {
    tabName = "Tab_HD",
    rootName = "Group_HD",
    node = GangActivityNode
  }
}
def.const("table").NodeId = NodeId
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").waitToOpenTab = 0
def.field("userdata").ui_Img_Bg0 = nil
def.field("table").tabToggles = nil
def.static("=>", HaveGangPanel).Instance = function(self)
  if nil == instance then
    instance = HaveGangPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method("userdata").ShowPanelAndSelectMemberWithRoleId = function(self, roleId)
  GangMembersNode.Instance():SetSelectMemberId(roleId)
  self:ShowPanelToTab(HaveGangPanel.NodeId.MEMBERS)
end
def.method("number").ShowPanelToTab = function(self, tabIdx)
  self.waitToOpenTab = tabIdx
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  self:CreatePanel(RESPATH.PREFAB_HAVE_GANG_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, HaveGangPanel.OnGangNoticeStatesChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangCombineOver, HaveGangPanel.OnGangCombineOver)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():QueryGroupInfo()
end
def.method().InitUI = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  self.ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self:InitNodes()
  self:InitTabs()
  self:UpdateNotices(HaveGangPanel.NodeId.ALL)
end
def.method().InitNodes = function(self)
  if not self.ui_Img_Bg0 or self.ui_Img_Bg0.isnil then
    return
  end
  self.nodes = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = self.ui_Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.node then
      self.nodes[nodeId] = v.node.Instance()
      self.nodes[nodeId]:Init(self, nodeRoot)
    else
      self.nodes[nodeId] = v.node
    end
  end
end
def.method().InitTabs = function(self)
  if not self.ui_Img_Bg0 or self.ui_Img_Bg0.isnil then
    return
  end
  if self.waitToOpenTab ~= 0 then
    self.curNode = self.waitToOpenTab
  else
    self.curNode = HaveGangPanel.NodeId.MEMBERS
  end
  self.tabToggles = {}
  for nodeId, v in ipairs(NodeDefines) do
    v.nodeId = nodeId
    local toggleObj = self.ui_Img_Bg0:FindDirect(v.tabName)
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
def.method("number").UpdateNotices = function(self, node)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  local redLabelFL = HaveGangPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_FL"):FindDirect("Img_BgRed")
  local redLabelNZ = HaveGangPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_NZ"):FindDirect("Img_BgRed")
  local redLabelHD = HaveGangPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_HD/Img_BgRed")
  if node == HaveGangPanel.NodeId.WELFARE then
    redLabelFL:SetActive(GangUtility.NeedShowWelfareNotice(false))
  elseif node == HaveGangPanel.NodeId.AFFAIRS then
    redLabelNZ:SetActive(GangUtility.NeedShowInternalAffairsNotice(false))
  elseif node == HaveGangPanel.NodeId.ACTIVITY then
    redLabelHD:SetActive(GangUtility.Instance():IsShowGangActivityRedPoint())
  elseif node == HaveGangPanel.NodeId.ALL then
    redLabelNZ:SetActive(GangUtility.NeedShowInternalAffairsNotice(false))
    redLabelFL:SetActive(GangUtility.NeedShowWelfareNotice(false))
    redLabelHD:SetActive(GangUtility.Instance():IsShowGangActivityRedPoint())
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, HaveGangPanel.OnGangNoticeStatesChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangCombineOver, HaveGangPanel.OnGangCombineOver)
  self.nodes[self.curNode]:Hide()
  self.waitToOpenTab = 0
  require("Main.Gang.GangBattleMgr").Instance().rivalGang = nil
end
def.method("number").SwitchTo = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  self.nodes[self.curNode]:Hide()
  self.curNode = nodeId
  self.nodes[self.curNode]:Show()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Tab_CY" == id then
    self:SwitchTo(HaveGangPanel.NodeId.MEMBERS)
  elseif "Tab_NZ" == id then
    self:SwitchTo(HaveGangPanel.NodeId.AFFAIRS)
  elseif "Tab_FL" == id then
    self:SwitchTo(HaveGangPanel.NodeId.WELFARE)
  elseif "Tab_HD" == id then
    self:SwitchTo(HaveGangPanel.NodeId.ACTIVITY)
  elseif "Modal" == id then
    self:DestroyPanel()
  else
    local node = self.nodes[self.curNode]
    if not _G.IsNil(node) then
      node:onClickObj(clickobj)
    end
  end
end
def.method("string").onDragStart = function(self, id)
  local node = self.nodes[self.curNode]
  if node then
    node:onDragStart(id)
  end
end
def.method("string").onDragEnd = function(self, id)
  local node = self.nodes[self.curNode]
  if node then
    node:onDragEnd(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  local node = self.nodes[self.curNode]
  if node then
    node:onDrag(id, dx, dy)
  end
end
def.static("table", "table").OnGangNoticeStatesChange = function(params, tbl)
  local node = params[1]
  HaveGangPanel.Instance():UpdateNotices(node)
end
def.static("table", "table").OnGangCombineOver = function(params, tbl)
  HaveGangPanel.Instance():DestroyPanel()
end
return HaveGangPanel.Commit()
