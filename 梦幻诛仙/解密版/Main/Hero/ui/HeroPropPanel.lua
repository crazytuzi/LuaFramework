local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroPropPanel = Lplus.Extend(ECPanelBase, "HeroPropPanel")
local def = HeroPropPanel.define
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr")
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local heroPropNode = require("Main.Hero.ui.HeroPropNode")
local heroPropInfoNode = require("Main.Hero.ui.HeroPropInfoNode")
local TurnedCardNode = require("Main.Hero.UI.TurnedCardNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local NodeId = {
  Prop = 1,
  Info = 2,
  AssignProp = 3,
  TurnedCard = 4
}
def.const("table").NodeId = NodeId
def.field("table").tabToggles = nil
def.field("table").tabPos = nil
def.field("table").nodes = nil
def.field("table").showedNodeList = nil
def.field("number").curNode = 0
def.field("table").TapEnum = nil
def.field("table").model = nil
def.field("boolean").isDrag = false
def.field("number").waitToOpenTab = 0
def.field("userdata").ui_Img_Bg0 = nil
local NodeDefines = {
  [NodeId.Prop] = {
    tabName = "Tap_SX",
    rootName = "Img_SX",
    node = heroPropNode
  },
  [NodeId.Info] = {
    tabName = "Tap_XX",
    rootName = "Img_XX",
    node = heroPropInfoNode
  },
  [NodeId.AssignProp] = {
    tabName = "none",
    rootName = "none",
    node = false
  },
  [NodeId.TurnedCard] = {
    tabName = "Tap_BSK",
    rootName = "Img_BSK",
    node = TurnedCardNode
  }
}
local instance
def.static("=>", HeroPropPanel).Instance = function()
  if instance == nil then
    instance = HeroPropPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
  self.m_HideOnDestroy = true
end
def.method().ShowPanel = function(self)
  self:CreatePanel(RESPATH.HERO_PROP_PANEL_RES, 1)
  self:SetModal(true)
end
def.method("number").OpenPanelToTab = function(self, tabIdx)
  self.waitToOpenTab = tabIdx
  self:ShowPanel()
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, HeroPropPanel.OnSyncHeroProp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_NOTIFY_UPDATE, HeroPropPanel.OnPropNotifyUpdate)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, HeroPropPanel.OnTurnedCardNotifyUpdate)
end
def.method().InitUI = function(self)
  self.ui_Img_Bg0 = self.m_panel:FindDirect("Img _Bg0")
  self:InitTabToggles()
  self:ArrangeTabPos()
  if self.waitToOpenTab ~= 0 then
    self.curNode = self.waitToOpenTab
  else
    self.curNode = HeroPropPanel.NodeId.Prop
  end
  GameUtil.AddGlobalTimer(0, true, function()
    if self.m_panel then
      self.tabToggles[self.curNode].value = true
    end
  end)
  self:UpdateTencentVIPInfo()
  self:UpdateTabBadges()
end
def.method().InitTabToggles = function(self)
  self.tabToggles = {}
  for nodeId, v in ipairs(NodeDefines) do
    v.nodeId = nodeId
    local toggleObj = self.ui_Img_Bg0:FindDirect(v.tabName)
    if toggleObj then
      self.tabToggles[nodeId] = toggleObj:GetComponent("UIToggle")
    end
  end
  local templateTab = self.tabToggles[NodeId.Prop].gameObject
  local localPosition = templateTab.transform.localPosition
  local height = templateTab:GetComponent("UIWidget").height
  local templateTab2 = self.tabToggles[NodeId.Info].gameObject
  local localPosition2 = templateTab2.transform.localPosition
  local step = localPosition.y - localPosition2.y
  self.tabPos = {}
  self.tabPos.x = localPosition.x
  self.tabPos.baseY = localPosition.y + step
  self.tabPos.spaceY = step
  self.nodes = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = self.ui_Img_Bg0:FindDirect(v.rootName)
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
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    self.nodes[self.curNode]:Hide()
    return
  end
  self.nodes[self.curNode]:Show()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, HeroPropPanel.OnSyncHeroProp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_NOTIFY_UPDATE, HeroPropPanel.OnPropNotifyUpdate)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, HeroPropPanel.OnTurnedCardNotifyUpdate)
  self.waitToOpenTab = 0
  self.nodes[self.curNode]:Hide()
  self.tabToggles = nil
  self.showedNodeList = nil
  self.tabPos = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Tap_SX" then
    self:SwitchToNode(HeroPropPanel.NodeId.Prop)
  elseif id == "Tap_JD" then
    self:SwitchToNode(HeroPropPanel.NodeId.AssignProp)
  elseif id == "Tap_XX" then
    self:SwitchToNode(HeroPropPanel.NodeId.Info)
  elseif id == "Tap_YY" then
  elseif id == "Tap_BSK" then
    local oldNode = self.curNode
    self:SwitchToNode(HeroPropPanel.NodeId.TurnedCard)
    if _G.CheckCrossServerAndToast(tip) then
      local curNode = NodeDefines[oldNode]
      if curNode then
        local Tab = self.m_panel:FindDirect("Img _Bg0/" .. curNode.tabName)
        Tab:GetComponent("UIToggle").value = true
        self:onClick(curNode.tabName)
      end
    end
  elseif id == "Btn_WechatRight" then
    local VIPRightPanel = require("Main.MainUI.ui.VIPRightPanel")
    VIPRightPanel.Instance():ShowPanel(2)
  elseif id == "Btn_FromGameCenter" then
    local VIPRightPanel = require("Main.MainUI.ui.VIPRightPanel")
    VIPRightPanel.Instance():ShowPanel(1)
  elseif id == "Btn_YingyongbaotRight" then
    local VIPRightPanel = require("Main.MainUI.ui.VIPRightPanel")
    VIPRightPanel.Instance():ShowPanel(3)
  elseif id == "Btn_BecomeVip" then
    local QQVIPWellFarePanel = require("Main.MainUI.ui.QQVIPWellFarePanel")
    QQVIPWellFarePanel.Instance():ShowPanel(1)
  elseif id == "Btn_BecomeSVip" then
    local QQVIPWellFarePanel = require("Main.MainUI.ui.QQVIPWellFarePanel")
    QQVIPWellFarePanel.Instance():ShowPanel(2)
  elseif id == "Btn_RenewSVip" then
    local QQVIPWellFarePanel = require("Main.MainUI.ui.QQVIPWellFarePanel")
    QQVIPWellFarePanel.Instance():ShowPanel(2)
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("number").SwitchToNode = function(self, node)
  if self.curNode == node then
    return
  end
  self.nodes[self.curNode]:Hide()
  self.curNode = node
  self.nodes[self.curNode]:Show()
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.nodes[self.curNode]:onPress(id, state)
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
end
def.method("number", "=>", "boolean").HasNotify = function(self, nodeId)
  if self.nodes[nodeId] then
    return self.nodes[nodeId]:HasNotify()
  end
  return false
end
def.static("table", "table").OnSyncHeroProp = function(params, context)
  local self = instance
  self.nodes[self.curNode]:OnSyncHeroProp(params, context)
end
def.static("table", "table").OnPropNotifyUpdate = function(params, context)
  instance:UpdateTabBadges()
end
def.static("table", "table").OnTurnedCardNotifyUpdate = function(p1, p2)
  if instance then
    instance:UpdateTabBadges()
  end
end
def.method().ArrangeTabPos = function(self)
  local unlockedNodeList = {}
  for nodeId, node in pairs(self.nodes) do
    if node and node:IsUnlock() then
      table.insert(unlockedNodeList, node)
    elseif self.tabToggles[nodeId] then
      self.tabToggles[nodeId]:set_value(false)
      self.tabToggles[nodeId].gameObject:SetActive(false)
    end
  end
  table.sort(unlockedNodeList, function(left, right)
    return left.nodeId < right.nodeId
  end)
  for i, node in ipairs(unlockedNodeList) do
    local tabObj = self.tabToggles[node.nodeId].gameObject
    tabObj:SetActive(true)
    local x, y, z = self.tabPos.x, self.tabPos.baseY - i * self.tabPos.spaceY, 0
    tabObj.transform.localPosition = Vector.Vector3.new(x, y, z)
  end
  self.showedNodeList = unlockedNodeList
end
def.method().UpdateTabBadges = function(self)
  for i, node in ipairs(self.showedNodeList) do
    local nodeId = node.nodeId
    local tabObj = self.tabToggles[nodeId].gameObject
    local Img_Red = tabObj:FindDirect("Img_Red")
    GUIUtils.SetActive(Img_Red, node:HasNotify())
  end
end
def.method().UpdateTencentVIPInfo = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local vipLevel = RelationShipChainMgr.GetSepicalVIPLevel()
  local groupQQ = self.ui_Img_Bg0:FindDirect("Img_SX/Group_QQ")
  local groupWX = self.ui_Img_Bg0:FindDirect("Img_SX/Group_Wechat")
  local groupYYB = self.ui_Img_Bg0:FindDirect("Img_SX/Group_YingYongBao")
  GUIUtils.SetActive(groupQQ, _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(groupWX, _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(groupWX:FindDirect("Img_WeichatIcon"), ECMSDK.IsWXGameCenter())
  GUIUtils.SetActive(groupWX:FindDirect("Btn_WechatRight"), true)
  GUIUtils.SetActive(groupYYB, ECMSDK.IsFromYYB())
  warn("UpdateTencentVIPInfo------------------------------------------------------------------------------------------------", vipLevel)
  GUIUtils.SetActive(groupQQ:FindDirect("Img_QQviptIcon"), vipLevel == 1)
  GUIUtils.SetActive(groupQQ:FindDirect("Img_QQSviptIcon"), vipLevel == 2)
  GUIUtils.SetActive(groupQQ:FindDirect("Img_FromGameCenter"), ECMSDK.IsQQGameCenter())
  GUIUtils.SetActive(groupQQ:FindDirect("Btn_BecomeVip"), vipLevel == 0 and platform == 2)
  GUIUtils.SetActive(groupQQ:FindDirect("Btn_BecomeSVip"), vipLevel == 1 and platform == 2)
  GUIUtils.SetActive(groupQQ:FindDirect("Btn_RenewSVip"), vipLevel == 2 and platform == 2)
  GUIUtils.SetActive(groupQQ:FindDirect("Btn_RenewVip"), false)
  GUIUtils.SetActive(groupQQ:FindDirect("Btn_FromGameCenter"), true)
  GUIUtils.SetColor(groupQQ:FindDirect("Btn_FromGameCenter"), ECMSDK.IsQQGameCenter() and Color.Color(1, 1, 1, 1) or Color.Color(0.5, 0.5, 0.5, 1), "UISprite")
end
return HeroPropPanel.Commit()
