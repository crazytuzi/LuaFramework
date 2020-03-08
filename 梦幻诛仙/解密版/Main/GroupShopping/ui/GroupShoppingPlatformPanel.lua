local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GroupShoppingPlatformPanel = Lplus.Extend(ECPanelBase, "GroupShoppingPlatformPanel")
local OtherGroupNode = require("Main.GroupShopping.ui.OtherGroupNode")
local MyGroupNode = require("Main.GroupShopping.ui.MyGroupNode")
local NotifyBar = require("Main.GroupShopping.ui.NotifyBar")
local GUIUtils = require("GUI.GUIUtils")
local def = GroupShoppingPlatformPanel.define
def.const("table").NodeId = {MyGroup = 1, OtherGroup = 2}
def.field("table").m_nodes = nil
def.field("number").m_curNode = 1
def.field("table").m_params = nil
def.field(NotifyBar).m_bar = nil
local instance
def.static("=>", GroupShoppingPlatformPanel).Instance = function()
  if instance == nil then
    instance = GroupShoppingPlatformPanel()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = GroupShoppingPlatformPanel.Instance()
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING_PLATFORM, 1)
  self:SetModal(true)
end
def.static("number", "table").ShowPanelTo = function(nodeId, params)
  local self = GroupShoppingPlatformPanel.Instance()
  if self:IsShow() then
    self:SwitchTo(nodeId)
    self:SetSwitchParams(params)
    self:UpdateToggle()
  else
    self.m_curNode = nodeId
    self.m_params = params
    self:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING_PLATFORM, 1)
    self:SetModal(true)
  end
end
def.static("string").AddNotify = function(notify)
  local self = GroupShoppingPlatformPanel.Instance()
  if self:IsShow() and self.m_bar then
    self.m_bar:AddNotify(notify)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingPlatformPanel.OnFeatureChange, self)
  self.m_nodes = {}
  local node = MyGroupNode()
  local myNode = self.m_panel:FindDirect("Img_Bg0/Group_MyGroup")
  node:Init(self, myNode)
  node:Hide()
  self.m_nodes[GroupShoppingPlatformPanel.NodeId.MyGroup] = node
  node = OtherGroupNode()
  local otherGroup = self.m_panel:FindDirect("Img_Bg0/Group_GroupPlatfrom")
  node:Init(self, otherGroup)
  node:Hide()
  self.m_nodes[GroupShoppingPlatformPanel.NodeId.OtherGroup] = node
  self:SwitchTo(self.m_curNode)
  self:UpdateToggle()
  self.m_bar = NotifyBar.Create(self.m_panel:FindDirect("Img_Bg0/Group_Message"))
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self:IsShow() and self.m_params then
      self:SetSwitchParams(self.m_params)
      self.m_params = nil
    end
  end)
end
def.method("table").OnFeatureChange = function(self, params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING and params.open == false then
    self:DestroyPanel()
  end
end
def.method().UpdateToggle = function(self)
  if self.m_curNode == GroupShoppingPlatformPanel.NodeId.MyGroup then
    local Btn_MyGroup = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_BtnList/Btn_MyGroup")
    Btn_MyGroup:GetComponent("UIToggle").value = true
  elseif self.m_curNode == GroupShoppingPlatformPanel.NodeId.OtherGroup then
    local Btn_GroupPlatfrom = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_BtnList/Btn_GroupPlatfrom")
    Btn_GroupPlatfrom:GetComponent("UIToggle").value = true
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingPlatformPanel.OnFeatureChange)
  self.m_params = nil
  self.m_nodes[self.m_curNode]:Hide()
  self.m_nodes = nil
  self.m_bar = nil
end
def.override("boolean").OnShow = function(self, show)
  if show then
    if self.m_nodes then
      self.m_nodes[self.m_curNode]:Show()
    end
  elseif self.m_nodes then
    self.m_nodes[self.m_curNode]:Hide()
  end
  if show then
    local notify = require("Main.GroupShopping.GroupShoppingModule").Instance():GetNotify()
    self.m_bar:SetNotify(notify)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    GUIUtils.ShowHoverTip(constant.CGroupShoppingConsts.DESCRIPTION_TIP_ID, 0, 0)
  elseif id == "Btn_GroupPlatfrom" then
    self:SwitchTo(GroupShoppingPlatformPanel.NodeId.OtherGroup)
  elseif id == "Btn_MyGroup" then
    self:SwitchTo(GroupShoppingPlatformPanel.NodeId.MyGroup)
  elseif string.sub(id, 1, 14) == "shoppingGroup_" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShareClick(id)
  else
    self.m_nodes[self.m_curNode]:onClick(id)
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  local oldNodeId = self.m_curNode
  for k, v in pairs(self.m_nodes) do
    if k == nodeId then
      self.m_curNode = nodeId
      v:Show()
    elseif k == oldNodeId then
      v:Hide()
    end
  end
end
def.method("table").SetSwitchParams = function(self, params)
  if params and self.m_nodes[self.m_curNode] then
    self.m_nodes[self.m_curNode]:SetSwitchParams(params)
  end
end
GroupShoppingPlatformPanel.Commit()
return GroupShoppingPlatformPanel
