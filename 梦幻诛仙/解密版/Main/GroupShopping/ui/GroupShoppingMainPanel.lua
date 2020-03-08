local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GroupShoppingMainPanel = Lplus.Extend(ECPanelBase, "GroupShoppingMainPanel")
local SmallGroupNode = require("Main.GroupShopping.ui.SmallGroupNode")
local BigGroupNode = require("Main.GroupShopping.ui.BigGroupNode")
local GUIUtils = require("GUI.GUIUtils")
local NotifyBar = require("Main.GroupShopping.ui.NotifyBar")
local def = GroupShoppingMainPanel.define
def.const("table").NodeId = {SmallNode = 1, BigNode = 2}
def.field("table").m_nodes = nil
def.field("number").m_curNode = 1
def.field("table").m_params = nil
def.field(NotifyBar).m_bar = nil
local instance
def.static("=>", GroupShoppingMainPanel).Instance = function()
  if instance == nil then
    instance = GroupShoppingMainPanel()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = GroupShoppingMainPanel.Instance()
  if self:IsShow() then
    return
  end
  local correct = self:CorrectNode(self.m_curNode)
  if correct > 0 then
    self.m_curNode = correct
    self:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING, 1)
    self:SetModal(true)
  end
end
def.static("number", "table").ShowPanelTo = function(nodeId, params)
  local self = GroupShoppingMainPanel.Instance()
  if self:IsShow() then
    self:SwitchTo(nodeId)
    self:SetSwitchParams(params)
    self:UpdateToggle()
  else
    local correct = self:CorrectNode(nodeId)
    if nodeId > 0 then
      self.m_curNode = correct
      self.m_params = params
      self:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING, 1)
      self:SetModal(true)
    end
  end
end
def.static("string").AddNotify = function(notify)
  local self = GroupShoppingMainPanel.Instance()
  if self:IsShow() and self.m_bar then
    self.m_bar:AddNotify(notify)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingMainPanel.OnFeatureChange, self)
  self.m_nodes = {}
  local node = SmallGroupNode()
  local smallNode = self.m_panel:FindDirect("Img_Bg0/Group_PeopleGroup")
  node:Init(self, smallNode)
  node:Hide()
  self.m_nodes[GroupShoppingMainPanel.NodeId.SmallNode] = node
  node = BigGroupNode()
  local bigNode = self.m_panel:FindDirect("Img_Bg0/Group_TimeGroup")
  node:Init(self, bigNode)
  node:Hide()
  self.m_nodes[GroupShoppingMainPanel.NodeId.BigNode] = node
  self:SwitchTo(self.m_curNode)
  self:UpdateToggle()
  self.m_bar = NotifyBar.Create(self.m_panel:FindDirect("Img_Bg0/Group_Message"))
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self:IsShow() and self.m_params then
      self:SetSwitchParams(self.m_params)
      self.m_params = nil
    end
  end)
  self:SetTime()
end
def.method().SetTime = function(self)
  local activityId = require("Main.GroupShopping.GroupShoppingUtils").GetCurActivityId()
  local lbl = self.m_panel:FindDirect("Img_Bg0/Group_Top/Label_Date")
  if activityId > 0 then
    lbl:SetActive(true)
    local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityId)
    local timeCfg = require("Main.Common.TimeCfgUtils").GetTimeLimitCommonCfg(activityCfg.activityLimitTimeid)
    local timeStr = string.format("%d.%02d.%02d ~ %d.%02d.%02d", timeCfg.startYear, timeCfg.startMonth, timeCfg.startDay, timeCfg.endYear, timeCfg.endMonth, timeCfg.endDay)
    lbl:GetComponent("UILabel"):set_text(timeStr)
  else
    lbl:SetActive(false)
  end
end
def.method("table").OnFeatureChange = function(self, params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING and params.open == false then
    self:DestroyPanel()
  elseif params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP or params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_GROUP then
    local correct = self:CorrectNode(self.m_curNode)
    if correct > 0 then
      if correct ~= self.m_curNode then
        self:SwitchTo(correct)
      end
      self:UpdateToggle()
    else
      self:DestroyPanel()
    end
  end
end
def.method().UpdateToggle = function(self)
  if self.m_curNode == GroupShoppingMainPanel.NodeId.SmallNode then
    local Btn_People = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_BtnList/Btn_People")
    Btn_People:GetComponent("UIToggle").value = true
    local Btn_Time = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_BtnList/Btn_Time")
    local bigOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_GROUP)
    Btn_Time:SetActive(bigOpen)
  elseif self.m_curNode == GroupShoppingMainPanel.NodeId.BigNode then
    local Btn_Time = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_BtnList/Btn_Time")
    Btn_Time:GetComponent("UIToggle").value = true
    local smallOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
    local Btn_People = self.m_panel:FindDirect("Img_Bg0/Group_Top/Group_BtnList/Btn_People")
    Btn_People:SetActive(smallOpen)
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingMainPanel.OnFeatureChange)
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
  elseif id == "Btn_MyGroup" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShowMyShoppingGroup(nil)
  elseif id == "Btn_People" then
    self:SwitchTo(GroupShoppingMainPanel.NodeId.SmallNode)
  elseif id == "Btn_Time" then
    self:SwitchTo(GroupShoppingMainPanel.NodeId.BigNode)
  elseif string.sub(id, 1, 14) == "shoppingGroup_" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShareClick(id)
  else
    self.m_nodes[self.m_curNode]:onClick(id)
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  local correct = self:CorrectNode(nodeId)
  if correct > 0 then
    nodeId = correct
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
end
def.method("table").SetSwitchParams = function(self, params)
  if params and self.m_nodes[self.m_curNode] then
    self.m_nodes[self.m_curNode]:SetSwitchParams(params)
  end
end
def.method("number", "=>", "number").CorrectNode = function(self, node)
  if node == GroupShoppingMainPanel.NodeId.SmallNode then
    local smallOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
    if smallOpen then
      return GroupShoppingMainPanel.NodeId.SmallNode
    else
      local bigOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_GROUP)
      if bigOpen then
        return GroupShoppingMainPanel.NodeId.BigNode
      else
        return 0
      end
    end
  elseif node == GroupShoppingMainPanel.NodeId.BigNode then
    local bigOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_GROUP)
    if bigOpen then
      return GroupShoppingMainPanel.NodeId.BigNode
    else
      local smallOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
      if smallOpen then
        return GroupShoppingMainPanel.NodeId.SmallNode
      else
        return 0
      end
    end
  else
    return 0
  end
end
GroupShoppingMainPanel.Commit()
return GroupShoppingMainPanel
