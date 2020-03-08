local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FashionPanel = Lplus.Extend(ECPanelBase, "FashionPanel")
local FashionUtils = require("Main.Fashion.FashionUtils")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local FashionModule = Lplus.ForwardDeclare("FashionModule")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local FashionNode = require("Main.Fashion.ui.FashionNode")
local MagicMarkNode = require("Main.Fashion.ui.MagicMarkNode")
local ThemeFashionNode = require("Main.Fashion.ui.ThemeFashionNode")
local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
local AircraftNode = require("Main.Aircraft.ui.AircraftNode")
local AircraftModule = require("Main.Aircraft.AircraftModule")
local def = FashionPanel.define
local instance
local NodeId = {
  Fashion = 1,
  MagicMark = 2,
  ThemeFashion = 3,
  Aircraft = 4
}
def.const("table").NodeId = NodeId
local NodeDefines = {
  [NodeId.Fashion] = {
    tabName = "Tap_Fashion",
    rootName = "Group_Fashion",
    node = FashionNode,
    isOpen = function()
      return FashionPanel.ReachFashionOpenLevel()
    end
  },
  [NodeId.MagicMark] = {
    tabName = "Tap_MagicMask",
    rootName = "Group_MagicMask",
    node = MagicMarkNode,
    isOpen = function()
      return gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).enabled and FashionPanel.ReachFashionOpenLevel()
    end
  },
  [NodeId.ThemeFashion] = {
    tabName = "Tap_ThemeSuit",
    rootName = "Group_ThemeSuit",
    node = ThemeFashionNode,
    isOpen = function()
      return FashionModule.Instance():IsThemeFashionFunctionOpen() and FashionPanel.ReachFashionOpenLevel()
    end
  },
  [NodeId.Aircraft] = {
    tabName = "Tap_Fly",
    rootName = "Group_Fly",
    node = AircraftNode,
    isOpen = function()
      return AircraftModule.Instance():IsOpen(false)
    end
  }
}
def.field("table")._uiObjs = nil
def.field("number")._initFashionCfgId = FashionDressConst.NO_FASHION_DRESS
def.field("table").nodes = nil
def.field("table").tabToggles = nil
def.field("number").curNodeId = 0
def.field("number").initNodeId = 0
def.field("number").initCfgId = 0
def.static("=>", FashionPanel).Instance = function()
  if instance == nil then
    instance = FashionPanel()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.static("=>", "boolean").ReachFashionOpenLevel = function()
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  return myLv >= constant.FashionDressConsts.openLevel
end
def.method().ShowFashionPanel = function(self)
  if self.m_panel == nil then
    self:CreatePanel(RESPATH.PREFAB_FASHION_PANEL, 1)
    self:SetModal(true)
  end
end
def.method("number", "number").ShowPanelNodeWithCfgId = function(self, nodeId, cfgId)
  self.initCfgId = cfgId
  if self.m_panel == nil then
    self.initNodeId = nodeId
    self:ShowFashionPanel()
  elseif self.curNodeId ~= nodeId then
    self:SwitchToNode(nodeId)
  elseif self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:Hide()
    self.nodes[self.curNodeId]:Show()
  end
end
def.method("=>", "number").GetInitCfgId = function(self)
  local cfgId = self.initCfgId
  self.initCfgId = 0
  return cfgId
end
def.method("number").ShowFashionPanelWithCfgId = function(self, cfgId)
  self._initFashionCfgId = cfgId
  if self.m_panel == nil then
    self.initNodeId = NodeId.Fashion
    self:ShowFashionPanel()
  elseif self.curNodeId ~= NodeId.Fashion then
    self:SwitchToNode(NodeId.Fashion)
  elseif self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:Hide()
    self.nodes[self.curNodeId]:Show()
  end
end
def.method("=>", "number").GetInitFashionCfgId = function(self)
  local cfgId = self._initFashionCfgId
  self._initFashionCfgId = FashionDressConst.NO_FASHION_DRESS
  return cfgId
end
def.override().OnCreate = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.nodes = {}
  self.tabToggles = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = self._uiObjs.Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    self.nodes[nodeId] = v.node()
    self.nodes[nodeId]:Init(self, nodeRoot)
    local tabRoot = self._uiObjs.Img_Bg0:FindDirect(v.tabName)
    if tabRoot then
      tabRoot:GetComponent("UIToggle"):set_startsActive(false)
      tabRoot:SetActive(v.isOpen())
      self.tabToggles[nodeId] = tabRoot
    end
  end
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FashionPanel._OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_ENABLE_CHANGE, FashionPanel.OnMagicMarkEnableChanged)
  Event.RegisterEvent(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, FashionPanel.OnMagicMarkItemEnableChanged)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, FashionPanel.OnFashionNotifyChanged)
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._initFashionCfgId = FashionDressConst.NO_FASHION_DRESS
  if self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:Hide()
  end
  self.nodes = nil
  self.tabToggles = nil
  self.curNodeId = 0
  self.initNodeId = 0
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FashionPanel._OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_ENABLE_CHANGE, FashionPanel.OnMagicMarkEnableChanged)
  Event.UnregisterEvent(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, FashionPanel.OnMagicMarkItemEnableChanged)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, FashionPanel.OnFashionNotifyChanged)
end
def.method("number").SwitchToNode = function(self, nodeId)
  if self.curNodeId == nodeId then
    if self.nodes[self.curNodeId] and not self.nodes[self.curNodeId].isShow then
      self.nodes[self.curNodeId]:Show()
    end
    return
  end
  if self.nodes == nil then
    return
  end
  if NodeDefines[nodeId] == nil or not NodeDefines[nodeId].isOpen() then
    nodeId = 0
    for id, v in pairs(NodeDefines) do
      if NodeDefines[id] and NodeDefines[id].isOpen() then
        nodeId = id
        break
      end
    end
    if nodeId == 0 then
      warn("[ERROR][FashionPanel:SwitchToNode] return on nodeId==0.")
      return
    end
  end
  self.curNodeId = nodeId
  for k, node in pairs(self.nodes) do
    node:Hide()
  end
  if self.nodes[nodeId] ~= nil then
    self.nodes[nodeId]:Show()
  end
  for k, tab in pairs(self.tabToggles) do
    tab:GetComponent("UIToggle").value = false
  end
  if self.tabToggles[nodeId] ~= nil then
    self.tabToggles[nodeId]:GetComponent("UIToggle").value = true
  end
end
def.method().CheckThemFashionNotify = function(self)
  if self.tabToggles and self.tabToggles[NodeId.ThemeFashion] then
    local Img_BagRed = self.tabToggles[NodeId.ThemeFashion]:FindDirect("Img_BagRed")
    GUIUtils.SetActive(Img_BagRed, FashionModule.Instance():IsThemeFashionHasNotify() or FashionModule.Instance():IsLimitedThemeFashionHasNotify())
  end
end
def.method().CheckAircraftNotify = function(self)
  if self.tabToggles and self.tabToggles[NodeId.Aircraft] then
    local Img_BagRed = self.tabToggles[NodeId.Aircraft]:FindDirect("Img_BagRed")
    GUIUtils.SetActive(Img_BagRed, require("Main.Aircraft.AircraftModule").Instance():NeedReddot())
  end
end
def.method().AjustTabs = function(self)
  local startPos = Vector3.new(410, 155, 0)
  local distance = 112
  local i = 0
  for nodeId, v in pairs(NodeDefines) do
    local tabRoot = self._uiObjs.Img_Bg0:FindDirect(v.tabName)
    if tabRoot then
      tabRoot:SetActive(v.isOpen())
      if v.isOpen() then
        local pos = Vector3.new(startPos.x, startPos.y - distance * i, startPos.z)
        tabRoot.localPosition = pos
        i = i + 1
      end
    end
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    if self.initNodeId ~= 0 and NodeDefines[self.initNodeId] ~= nil and NodeDefines[self.initNodeId].isOpen() then
      self:SwitchToNode(self.initNodeId)
    elseif self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
      self.nodes[self.curNodeId]:Show()
    else
      self:SwitchToNode(NodeId.Fashion)
    end
    self:AjustTabs()
    self:CheckThemFashionNotify()
    self:CheckAircraftNotify()
  elseif self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:Hide()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tap_Fashion" then
    self:SwitchToNode(NodeId.Fashion)
  elseif id == "Tap_MagicMask" then
    self:SwitchToNode(NodeId.MagicMark)
  elseif id == "Tap_ThemeSuit" then
    self:SwitchToNode(NodeId.ThemeFashion)
  elseif id == "Tap_Fly" then
    self:SwitchToNode(NodeId.Aircraft)
  elseif self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:onClickObj(clickobj)
  end
end
def.method("string").onDragStart = function(self, id)
  if self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:onDragStart(id)
  end
end
def.method("string").onDragEnd = function(self, id)
  if self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:onDragEnd(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.nodes ~= nil and self.nodes[self.curNodeId] ~= nil then
    self.nodes[self.curNodeId]:onDrag(id, dx, dy)
  end
end
def.static("table", "table")._OnFunctionOpenChange = function(params, context)
  local self = instance
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_DRESS and not params.open then
    Toast(textRes.Fashion[31])
    self:DestroyPanel()
  elseif params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_THEME_FASHION_DRESS then
    self:OnThemFashionOpenChanged()
  elseif params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AIRCRAFT then
    self:OnAircraftOpenChanged()
  end
end
def.method().OnThemFashionOpenChanged = function(self)
  local isOpen = FashionModule.Instance():IsThemeFashionFunctionOpen()
  self:AjustTabs()
  self:CheckThemFashionNotify()
  if not isOpen and self.curNodeId == NodeId.ThemeFashion then
    self:SwitchToNode(NodeId.Fashion)
  end
end
def.method().OnAircraftOpenChanged = function(self)
  local isOpen = AircraftModule.Instance():IsOpen(false)
  self:AjustTabs()
  self:CheckThemFashionNotify()
  if not isOpen and self.curNodeId == NodeId.Aircraft then
    self:SwitchToNode(NodeId.Fashion)
  end
end
def.static("table", "table").OnMagicMarkEnableChanged = function(params, context)
  local isOpen = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).enabled
  local self = instance
  self:AjustTabs()
  if not isOpen and self.curNodeId == NodeId.MagicMark then
    self:SwitchToNode(NodeId.Fashion)
  end
end
def.static("table", "table").OnMagicMarkItemEnableChanged = function(params, context)
  if params == nil then
    return
  end
  if params.type == ItemSwitchInfo.MAGIC_MARK then
    require("Main.MagicMark.ui.MagicMarkPropPanel").Instance():DestroyPanel()
    local self = instance
    if self.curNodeId == NodeId.MagicMark then
      self.nodes[NodeId.MagicMark]:Hide()
      self.nodes[NodeId.MagicMark]:Show()
    end
  end
end
def.static("table", "table").OnFashionNotifyChanged = function(params, context)
  local self = instance
  self:CheckThemFashionNotify()
  self:CheckAircraftNotify()
end
FashionPanel.Commit()
return FashionPanel
