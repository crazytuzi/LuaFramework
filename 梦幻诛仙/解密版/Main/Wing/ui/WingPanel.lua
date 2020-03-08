local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WingPanel = Lplus.Extend(ECPanelBase, "WingPanel")
local GUIUtils = require("GUI.GUIUtils")
local BasicInfoNode = require("Main.Wing.ui.BasicInfoNode")
local DetailInfoNode = require("Main.Wing.ui.DetailInfoNode")
local def = WingPanel.define
local instance
def.const("table").NodeId = {BasicInfo = 1, DetailInfo = 2}
def.const("table").Tabs = {
  [1] = "Tab_YY",
  ["Tab_YY"] = 1,
  [2] = "Tab_WG",
  ["Tab_WG"] = 2
}
def.field("table").nodes = nil
def.field("number").curNode = 1
def.static("=>", WingPanel).Instance = function()
  if instance == nil then
    instance = WingPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.static("number").ShowWingPanel = function(node)
  local dlg = WingPanel.Instance()
  if node > 0 then
    dlg.curNode = node
  end
  if dlg:IsShow() then
    dlg:UpdatePanel()
  else
    dlg:CreatePanel(RESPATH.PANEL_WING, 1)
    dlg:SetModal(true)
  end
end
def.static().CloseWingPanel = function()
  WingPanel.Instance():DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_RED_POINT_REFRESH, WingPanel.OnWingRedPointRefresh)
  self.nodes = {}
  local basicNode = self.m_panel:FindDirect("Img_Bg0/Img_YY")
  self.nodes[WingPanel.NodeId.BasicInfo] = BasicInfoNode()
  self.nodes[WingPanel.NodeId.BasicInfo]:Init(self, basicNode)
  local detailNode = self.m_panel:FindDirect("Img_Bg0/Img_WG")
  self.nodes[WingPanel.NodeId.DetailInfo] = DetailInfoNode()
  self.nodes[WingPanel.NodeId.DetailInfo]:Init(self, detailNode)
  self:UpdatePanel()
  self:UpdateWingRedPoint()
end
def.override("boolean").OnShow = function(self, s)
  local curNode = self.nodes[self.curNode]
  if s then
    if not curNode.isShow then
      curNode:Show()
    end
  elseif curNode.isShow then
    curNode:Hide()
  end
end
def.override().OnDestroy = function(self)
  self.nodes[self.curNode]:Hide()
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_RED_POINT_REFRESH, WingPanel.OnWingRedPointRefresh)
end
def.static("table", "table").OnWingRedPointRefresh = function(p1, p2)
  if instance and not _G.IsNil(instance.m_panel) then
    instance:UpdateWingRedPoint()
  end
end
def.method().UpdatePanel = function(self)
  self:SwitchTo(self.curNode)
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      v:Show()
      self.curNode = nodeId
    else
      v:Hide()
    end
  end
  self:UpdateTab()
end
def.method().UpdateTab = function(self)
  local tabName = WingPanel.Tabs[self.curNode]
  if tabName then
    local tabUI = self.m_panel:FindDirect("Img_Bg0/" .. tabName)
    local tabToggle = tabUI:GetComponent("UIToggle")
    tabToggle:set_value(true)
  end
end
def.method().UpdateWingRedPoint = function(self)
  local tabName = WingPanel.Tabs[WingPanel.NodeId.BasicInfo]
  if tabName then
    local tabUI = self.m_panel:FindDirect("Img_Bg0/" .. tabName)
    local Img_Red = tabUI:FindDirect("Img_Red")
    if require("Main.Wing.WingInterface").HasWingNotify() then
      Img_Red:SetActive(true)
    else
      Img_Red:SetActive(false)
    end
  end
end
def.method("string").onClick = function(self, id)
  print("WingPanel onClick", id)
  if id == "Btn_Close" or id == "modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 4) == "Tab_" then
    local nodeId = WingPanel.Tabs[id]
    if nodeId and nodeId ~= self.curNode then
      self:SwitchTo(nodeId)
    end
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
def.method("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
WingPanel.Commit()
return WingPanel
