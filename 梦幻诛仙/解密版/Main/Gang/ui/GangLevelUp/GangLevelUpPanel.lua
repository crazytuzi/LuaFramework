local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangLevelUpPanel = Lplus.Extend(ECPanelBase, "GangLevelUpPanel")
local GangData = require("Main.Gang.data.GangData")
local def = GangLevelUpPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangScaleNode = require("Main.Gang.ui.GangLevelUp.GangScaleNode")
local GangWingNode = require("Main.Gang.ui.GangLevelUp.GangWingNode")
local GangCoffersNode = require("Main.Gang.ui.GangLevelUp.GangCoffersNode")
local GangPharmacyNode = require("Main.Gang.ui.GangLevelUp.GangPharmacyNode")
local GangWarehouseNode = require("Main.Gang.ui.GangLevelUp.GangWarehouseNode")
local GangLibraryNode = require("Main.Gang.ui.GangLevelUp.GangLibraryNode")
def.const("table").NodeId = {
  Scale = 1,
  Wing = 2,
  Coffers = 3,
  Pharmacy = 4,
  Warehouse = 5,
  Library = 6
}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.const("table").StateConst = {
  Scale = 1,
  Wing = 2,
  Coffers = 3,
  Pharmacy = 4,
  Warehouse = 5,
  Library = 6
}
def.static("=>", GangLevelUpPanel).Instance = function(self)
  if nil == instance then
    instance = GangLevelUpPanel()
    instance.state = GangLevelUpPanel.StateConst.Scale
  end
  return instance
end
def.override().OnCreate = function(self)
  self.nodes = {}
  self.state = GangLevelUpPanel.StateConst.Scale
  local scaleNode = self.m_panel:FindDirect("Img_Bg/Group_Scale")
  self.nodes[GangLevelUpPanel.NodeId.Scale] = GangScaleNode()
  self.nodes[GangLevelUpPanel.NodeId.Scale]:Init(self, scaleNode)
  local wingNode = self.m_panel:FindDirect("Img_Bg/Group_Room")
  self.nodes[GangLevelUpPanel.NodeId.Wing] = GangWingNode()
  self.nodes[GangLevelUpPanel.NodeId.Wing]:Init(self, wingNode)
  local coffersNode = self.m_panel:FindDirect("Img_Bg/Group_Gold")
  self.nodes[GangLevelUpPanel.NodeId.Coffers] = GangCoffersNode()
  self.nodes[GangLevelUpPanel.NodeId.Coffers]:Init(self, coffersNode)
  local pharmacyNode = self.m_panel:FindDirect("Img_Bg/Group_Drug")
  self.nodes[GangLevelUpPanel.NodeId.Pharmacy] = GangPharmacyNode()
  self.nodes[GangLevelUpPanel.NodeId.Pharmacy]:Init(self, pharmacyNode)
  local warehouseNode = self.m_panel:FindDirect("Img_Bg/Group_Store")
  self.nodes[GangLevelUpPanel.NodeId.Warehouse] = GangWarehouseNode()
  self.nodes[GangLevelUpPanel.NodeId.Warehouse]:Init(self, warehouseNode)
  local libraryNode = self.m_panel:FindDirect("Img_Bg/Group_Library")
  self.nodes[GangLevelUpPanel.NodeId.Library] = GangLibraryNode()
  self.nodes[GangLevelUpPanel.NodeId.Library]:Init(self, libraryNode)
  if GangLevelUpPanel.StateConst.Scale == self.state then
    self:SwitchTo(GangLevelUpPanel.NodeId.Scale)
    local toggle = self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Scale"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif GangLevelUpPanel.StateConst.Wing == self.state then
    self:SwitchTo(GangLevelUpPanel.NodeId.Wing)
    local toggle = self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Room"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif GangLevelUpPanel.StateConst.Coffers == self.state then
    self:SwitchTo(GangLevelUpPanel.NodeId.Coffers)
    local toggle = self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Gold"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif GangLevelUpPanel.StateConst.Pharmacy == self.state then
    self:SwitchTo(GangLevelUpPanel.NodeId.Pharmacy)
    local toggle = self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Drug"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif GangLevelUpPanel.StateConst.Warehouse == self.state then
    self:SwitchTo(GangLevelUpPanel.NodeId.Warehouse)
    local toggle = self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Store"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif GangLevelUpPanel.StateConst.Library == self.state then
    self:SwitchTo(GangLevelUpPanel.NodeId.Library)
    local toggle = self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Library"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
  self:FillList()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, GangLevelUpPanel.OnStartBuildGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, GangLevelUpPanel.OnStartWingGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, GangLevelUpPanel.OnStartCoffersGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, GangLevelUpPanel.OnStartPharmacyGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, GangLevelUpPanel.OnStartWarehouseGang)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartLibraryGang, GangLevelUpPanel.OnStartLibraryGang)
end
def.method().FillList = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  if gangInfo.buildEndTime <= 0 then
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Scale/Img_OnWork"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Scale/Img_OnWork"):SetActive(true)
  end
  if 0 >= gangInfo.wingEndTime then
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Room/Img_OnWork"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Room/Img_OnWork"):SetActive(true)
  end
  if 0 >= gangInfo.coffersEndTime then
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Gold/Img_OnWork"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Gold/Img_OnWork"):SetActive(true)
  end
  if 0 >= gangInfo.pharmacyEndTime then
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Drug/Img_OnWork"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Drug/Img_OnWork"):SetActive(true)
  end
  if 0 >= gangInfo.warehouseEndTime then
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Store/Img_OnWork"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Store/Img_OnWork"):SetActive(true)
  end
  if 0 >= gangInfo.bookEndTime then
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Library/Img_OnWork"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Scroll View/Tab_Library/Img_OnWork"):SetActive(true)
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      self.curNode = nodeId
      v:Show()
    else
      v:Hide()
    end
  end
end
def.static().ShowGangLevelUpPanel = function()
  GangLevelUpPanel.Instance():SetModal(true)
  GangLevelUpPanel.Instance():CreatePanel(RESPATH.PREFAB_LEVELUP_GANG_PANEL, 0)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, GangLevelUpPanel.OnStartBuildGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, GangLevelUpPanel.OnStartWingGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, GangLevelUpPanel.OnStartCoffersGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, GangLevelUpPanel.OnStartPharmacyGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, GangLevelUpPanel.OnStartWarehouseGang)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartLibraryGang, GangLevelUpPanel.OnStartLibraryGang)
  self.curNode = 0
  self.state = 0
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  elseif "Tab_Scale" == id then
    self:SwitchTo(GangLevelUpPanel.NodeId.Scale)
  elseif "Tab_Room" == id then
    self:SwitchTo(GangLevelUpPanel.NodeId.Wing)
  elseif "Tab_Gold" == id then
    self:SwitchTo(GangLevelUpPanel.NodeId.Coffers)
  elseif "Tab_Drug" == id then
    self:SwitchTo(GangLevelUpPanel.NodeId.Pharmacy)
  elseif "Tab_Store" == id then
    self:SwitchTo(GangLevelUpPanel.NodeId.Warehouse)
  elseif "Tab_Library" == id then
    self:SwitchTo(GangLevelUpPanel.NodeId.Library)
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.static("table", "table").OnStartBuildGang = function(params, tbl)
  GangLevelUpPanel.Instance():FillList()
  if GangLevelUpPanel.Instance().curNode == GangLevelUpPanel.NodeId.Scale then
    GangLevelUpPanel.Instance().nodes[GangLevelUpPanel.Instance().curNode]:FillAllInfo()
  end
end
def.static("table", "table").OnStartWingGang = function(params, tbl)
  GangLevelUpPanel.Instance():FillList()
  if GangLevelUpPanel.Instance().curNode == GangLevelUpPanel.NodeId.Wing then
    GangLevelUpPanel.Instance().nodes[GangLevelUpPanel.Instance().curNode]:FillAllInfo()
  end
end
def.static("table", "table").OnStartCoffersGang = function(params, tbl)
  GangLevelUpPanel.Instance():FillList()
  if GangLevelUpPanel.Instance().curNode == GangLevelUpPanel.NodeId.Coffers then
    GangLevelUpPanel.Instance().nodes[GangLevelUpPanel.Instance().curNode]:FillAllInfo()
  end
end
def.static("table", "table").OnStartPharmacyGang = function(params, tbl)
  GangLevelUpPanel.Instance():FillList()
  if GangLevelUpPanel.Instance().curNode == GangLevelUpPanel.NodeId.Pharmacy then
    GangLevelUpPanel.Instance().nodes[GangLevelUpPanel.Instance().curNode]:FillAllInfo()
  end
end
def.static("table", "table").OnStartWarehouseGang = function(params, tbl)
  GangLevelUpPanel.Instance():FillList()
  if GangLevelUpPanel.Instance().curNode == GangLevelUpPanel.NodeId.Warehouse then
    GangLevelUpPanel.Instance().nodes[GangLevelUpPanel.Instance().curNode]:FillAllInfo()
  end
end
def.static("table", "table").OnStartLibraryGang = function(params, tbl)
  GangLevelUpPanel.Instance():FillList()
  if GangLevelUpPanel.Instance().curNode == GangLevelUpPanel.NodeId.Library then
    GangLevelUpPanel.Instance().nodes[GangLevelUpPanel.Instance().curNode]:FillAllInfo()
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
  self.nodes[self.curNode]:UpdateInfo()
end
return GangLevelUpPanel.Commit()
