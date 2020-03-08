local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RoomManagerPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local HouseMgr = require("Main.Homeland.HouseMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = RoomManagerPanel.define
local NodeId = {
  None = "",
  PetRoom = "Tab_PetRoom",
  Bedroom = "Tab_BedRoom",
  MakeDrugRoom = "Tab_DrugRoom",
  Kitchen = "Tab_Kitchen",
  ServantRoom = "Tab_ServiceRoom"
}
def.const("table").NodeId = NodeId
def.field("table").m_UIGOs = nil
def.field("string").m_curNodeId = NodeId.None
def.field("string").m_nextNodeId = NodeId.Bedroom
def.field("table").m_nodes = nil
local NodeDefines = {
  [NodeId.PetRoom] = {
    tabName = "Tab_PetRoom",
    rootName = "Group_PetRoom",
    nodeFName = "Main.Homeland.ui.PetRoom",
    tipsId = 701605018
  },
  [NodeId.Bedroom] = {
    tabName = "Tab_BedRoom",
    rootName = "Group_BedRoom",
    nodeFName = "Main.Homeland.ui.Bedroom",
    tipsId = 701605017
  },
  [NodeId.MakeDrugRoom] = {
    tabName = "Tab_DrugRoom",
    rootName = "Group_DrugRoom",
    nodeFName = "Main.Homeland.ui.MakeDrugRoom",
    tipsId = 701605019
  },
  [NodeId.Kitchen] = {
    tabName = "Tab_Kitchen",
    rootName = "Group_Kitchen",
    nodeFName = "Main.Homeland.ui.Kitchen",
    tipsId = 701605020
  },
  [NodeId.ServantRoom] = {
    tabName = "Tab_ServiceRoom",
    rootName = "Group_ServiceRoom",
    nodeFName = "Main.Homeland.ui.ServantRoom",
    tipsId = 701605021
  }
}
local instance
def.static("=>", RoomManagerPanel).Instance = function()
  if instance == nil then
    instance = RoomManagerPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  self:ShowPanelEx(nil)
end
def.method("string").ShowPanelWithNodeId = function(self, nodeId)
  self:ShowPanelEx({nodeId = nodeId})
end
def.method("table").ShowPanelEx = function(self, params)
  if params and params.nodeId then
    self.m_nextNodeId = params.nodeId
  end
  self:CreatePanel(RESPATH.PREFAB_ROOM_MANAGER_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self:SwitchToNode(self.m_nextNodeId)
  self:SetModal(true)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, RoomManagerPanel.OnLeaveHomeland)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, RoomManagerPanel.OnLoseHomelandControl)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, RoomManagerPanel.OnGeomancyChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeCleannessChange, RoomManagerPanel.OnCleannessChange)
  self:CheckCleanPrompt()
  self:UpdateCleanNotify()
end
def.override().OnDestroy = function(self)
  if self.m_nodes == nil then
    return
  end
  if self.m_curNodeId ~= NodeId.None then
    self:GetNode(self.m_curNodeId):Hide()
  end
  self.m_curNodeId = NodeId.None
  self.m_UIGOs = nil
  self.m_nodes = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, RoomManagerPanel.OnLeaveHomeland)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, RoomManagerPanel.OnLoseHomelandControl)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeGeomancyChange, RoomManagerPanel.OnGeomancyChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeCleannessChange, RoomManagerPanel.OnCleannessChange)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Tab = self.m_UIGOs.Img_Bg:FindDirect("Group_Tab")
  self.m_UIGOs.Btn_Clean = self.m_UIGOs.Img_Bg:FindDirect("Btn_Clean")
  local btnWidget = self.m_UIGOs.Btn_Clean:GetComponent("UIWidget")
  btnWidget.autoResizeBoxCollider = false
  local boxCollider = self.m_UIGOs.Btn_Clean:GetComponent("BoxCollider")
  local sprite = self.m_UIGOs.Btn_Clean:FindDirect("Sprite")
  local spriteWidget = sprite:GetComponent("UIWidget")
  boxCollider.size = Vector.Vector3.new(spriteWidget.width, spriteWidget.height, 0)
  self.m_UIGOs.tabToggles = {}
  for nodeId, v in pairs(NodeDefines) do
    local toggleObj = self.m_UIGOs.Group_Tab:FindDirect(v.tabName)
    if toggleObj then
      self.m_UIGOs.tabToggles[nodeId] = toggleObj:GetComponent("UIToggle")
      self.m_UIGOs.tabToggles[nodeId]:set_startsActive(false)
    end
    local nodeRoot = self.m_UIGOs.Img_Bg:FindDirect(v.rootName)
    GUIUtils.SetActive(nodeRoot, false)
  end
  self.m_nodes = {}
end
def.method().UpdateUI = function(self)
  self:UpdateHomelandInfo()
end
def.method("string").SwitchToNode = function(self, nodeId)
  if self.m_curNodeId == nodeId then
    return
  end
  if self.m_curNodeId ~= NodeId.None then
    self:GetNode(self.m_curNodeId):Hide()
  end
  self.m_curNodeId = nodeId
  self.m_nextNodeId = self.m_curNodeId
  if self.m_UIGOs.tabToggles[nodeId] then
    self.m_UIGOs.tabToggles[nodeId]:set_value(true)
  end
  self:GetNode(nodeId):Show()
end
def.method("string", "=>", "table").GetNode = function(self, nodeId)
  local node = self.m_nodes[nodeId]
  if node == nil and NodeDefines[nodeId].nodeFName then
    local Node = require(NodeDefines[nodeId].nodeFName)
    node = Node.Instance()
    local nodeRoot = self.m_UIGOs.Img_Bg:FindDirect(NodeDefines[nodeId].rootName)
    self.m_nodes[nodeId] = node
    self.m_nodes[nodeId]:InitEx({
      self,
      nodeRoot,
      nodeId
    })
  end
  return node
end
def.method("=>", "table").GetCurNode = function(self)
  return self:GetNode(self.m_curNodeId)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Clean" then
    self:OnCleanBtnClick()
  elseif id == "Btn_Tips" then
    self:OnBtnTipsClick()
  elseif NodeDefines[id] then
    self:SwitchToNode(id)
  else
    self:GetCurNode():onClickObj(obj)
  end
end
def.method().UpdateHomelandInfo = function(self)
  local Label_LuckyNumber = self.m_UIGOs.Img_Bg:FindDirect("Label_LuckyNumber")
  local Label_CleanNumber = self.m_UIGOs.Img_Bg:FindDirect("Label_CleanNumber")
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  local house = HouseMgr.Instance():GetMyHouse()
  local houseLevel = house:GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local fengShuiValue = house:GetGeomancy()
  local cleanliness = house:GetCleanness()
  local maxFengShui = houseCfg.maxFengShui
  local maxCleanliness = houseCfg.maxCleanliness
  local fengShuiCfg = HomelandUtils.GetHouseFengShuiCfg(fengShuiValue)
  local cleanlinessCfg = HomelandUtils.GetHouseCleanlinessCfg(cleanliness)
  local fengShuiText = string.format(textRes.Homeland[68], fengShuiCfg.showName, fengShuiValue, maxFengShui)
  local cleanlinessText = string.format(textRes.Homeland[68], cleanlinessCfg.showName, cleanliness, maxCleanliness)
  GUIUtils.SetText(Label_LuckyNumber, fengShuiText)
  GUIUtils.SetText(Label_CleanNumber, cleanlinessText)
end
def.method("=>", "boolean").CheckCleanPrompt = function(self)
  if not self:HaveCleanNotify() then
    return false
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Common[43], textRes.Homeland[86], function(s)
    if s == 1 then
      self:ShowLightOnCleanBtn(true)
    end
  end, nil)
  return true
end
def.method("boolean").ShowLightOnCleanBtn = function(self, isShow)
  if self.m_UIGOs == nil then
    return
  end
  local go = self.m_UIGOs.Btn_Clean:FindDirect("Sprite")
  local light = isShow and GUIUtils.Light.Round or GUIUtils.Light.None
  GUIUtils.SetLightEffect(go, light)
end
def.method().UpdateCleanNotify = function(self)
  local Img_Red = self.m_UIGOs.Btn_Clean:FindDirect("Img_Red")
  local haveNotify = self:HaveCleanNotify()
  GUIUtils.SetActive(Img_Red, haveNotify)
end
def.method("=>", "boolean").HaveCleanNotify = function(self)
  if HouseMgr.IsCleanTimesUseOut() then
    return false
  end
  local house = HouseMgr.Instance():GetMyHouse()
  if house:IsCleannessReachMax() then
    return false
  end
  return true
end
def.method().OnCleanBtnClick = function(self)
  self:ShowLightOnCleanBtn(false)
  HouseMgr.CleanHouseService(0)
end
def.method().OnBtnTipsClick = function(self)
  local nodeInfo = NodeDefines[self.m_curNodeId]
  if nodeInfo and nodeInfo.tipsId then
    GUIUtils.ShowHoverTip(nodeInfo.tipsId, 0, 0)
  end
end
def.static("table", "table").OnLeaveHomeland = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnLoseHomelandControl = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnGeomancyChange = function()
  instance:UpdateHomelandInfo()
end
def.static("table", "table").OnCleannessChange = function()
  instance:UpdateHomelandInfo()
  instance:UpdateCleanNotify()
end
return RoomManagerPanel.Commit()
