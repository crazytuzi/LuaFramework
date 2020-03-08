local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SearchPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local CustomizedSearch = require("Main.TradingArcade.data.CustomizedSearch")
local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
local def = SearchPanel.define
local NodeId = {
  None = 0,
  Normal = 1,
  Equipment = 2,
  Pet = 3,
  PetEquipment = 4,
  MyCustomize = 5
}
def.const("table").NodeId = NodeId
local NodeDefines = {
  [NodeId.Normal] = {
    tabName = "Tab_NormalSearch",
    rootName = "Group_NormalSearch",
    nodeFileName = "Main.TradingArcade.ui.NormalSearchNode"
  },
  [NodeId.Equipment] = {
    customizeType = CustomizedSearch.CustomizeType.Equip,
    tabName = "Tab_EquipSearch",
    rootName = "Group_EquipSearch",
    nodeFileName = "Main.TradingArcade.ui.SearchEquipNode"
  },
  [NodeId.Pet] = {
    customizeType = CustomizedSearch.CustomizeType.Pet,
    tabName = "Tab_PetSearch",
    rootName = "Group_PetSearch",
    nodeFileName = "Main.TradingArcade.ui.SearchPetNode"
  },
  [NodeId.PetEquipment] = {
    customizeType = CustomizedSearch.CustomizeType.PetEquip,
    tabName = "Tab_PetEquipSearch",
    rootName = "Group_PetEquipSearch",
    nodeFileName = "Main.TradingArcade.ui.SearchPetEquipNode"
  },
  [NodeId.MyCustomize] = {
    tabName = nil,
    rootName = "Group_MyOrder",
    nodeFileName = "Main.TradingArcade.ui.MyCustomizeNode"
  }
}
def.field("table").nodes = nil
def.field("number").curNode = NodeId.None
def.field("number").nextNode = NodeId.Normal
def.field("table").params = nil
def.field("table").m_UIGOs = nil
local instance
local function Instance()
  if instance == nil then
    instance = SearchPanel()
  end
  return instance
end
def.static("table", "=>", SearchPanel).ShowPanel = function(params)
  local self = Instance()
  self.params = params
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_SEARCH, 2)
  self:SetModal(true)
  return self
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:CalcNextNode()
  self:SwitchToNode(self.nextNode)
end
def.override().OnDestroy = function(self)
  if self.curNode == NodeId.None then
    return
  end
  self:GetNode(self.curNode):Hide()
  self.curNode = NodeId.None
  self:Clear()
end
def.method().Clear = function(self)
  self.params = nil
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  self.m_UIGOs.Group_SmallSelected:SetActive(false)
  if id ~= "Img_InputBg" then
    self:HidePopupPanels()
  end
  if id == "Btn_Close" or id == "Modal" then
    self:Hide()
  elseif id == "Img_Bg1" then
  elseif id == "Btn_Item1" then
    local index = tonumber(string.sub(clickobj.parent.name, #"item_" + 1, -1))
    if index then
      self:OnBigPopupItemClick(index)
    end
  elseif id == "Btn_Item2" then
    local index = tonumber(string.sub(clickobj.parent.name, #"item_" + 1, -1))
    if index then
      self:OnSmallPopupItemClick(index)
    end
  elseif id == "Btn_Reset" then
    self:OnRestBtnClick()
  elseif id == "Btn_Search" then
    self:OnSearchBtnClick()
  elseif id == "Btn_Order" then
    self:OnCustomizeBtnClick()
  elseif id == "Btn_MyOrder" then
    self:OnMyCustomizationBtnClick()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      self:SwitchToNode(nodeId)
      self:HidePopupPanels()
    else
      self:GetNode(self.curNode):onClickObj(clickobj)
    end
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  self:GetNode(self.curNode):onSubmit(id, ctrl)
end
def.method().OnRestBtnClick = function(self)
  self:GetNode(self.curNode):OnRestBtnClick()
end
def.method().OnSearchBtnClick = function(self)
  self:GetNode(self.curNode):OnSearchBtnClick()
end
def.method().OnCustomizeBtnClick = function(self)
  self:GetNode(self.curNode):OnCustomizeBtnClick()
end
def.method().OnMyCustomizationBtnClick = function(self)
  local lastNode = self.curNode
  self:SwitchToNode(NodeId.MyCustomize)
  self.nextNode = lastNode
end
def.method().InitUI = function(self)
  self.nodes = {}
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_BigSelected = self.m_UIGOs.Img_Bg0:FindDirect("Group_BigSelected")
  self.m_UIGOs.Group_SmallSelected = self.m_UIGOs.Img_Bg0:FindDirect("Group_SmallSelected")
  self.m_UIGOs.tabToggles = {}
  for nodeId, v in ipairs(NodeDefines) do
    if v.tabName then
      local toggleObj = self.m_UIGOs.Img_Bg0:FindDirect(v.tabName)
      local uiToggle = toggleObj:GetComponent("UIToggle")
      uiToggle.startsActive = false
      self.m_UIGOs.tabToggles[nodeId] = toggleObj
      if toggleObj and v.customizeType then
        local Img_Red = toggleObj:FindDirect("Img_Red")
        local hasNotify = CustomizedSearchMgr.Instance():HasCustomizeTypeNotify(v.customizeType)
        GUIUtils.SetActive(Img_Red, hasNotify)
      end
    end
    local nodeRoot = self.m_UIGOs.Img_Bg0:FindDirect(v.rootName)
    GUIUtils.SetActive(nodeRoot, false)
  end
end
def.method("number").SwitchToNode = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  if self.curNode ~= NodeId.None then
    self:GetNode(self.curNode):Hide()
  end
  self.curNode = nodeId
  self.nextNode = self.curNode
  if self.m_UIGOs.tabToggles[nodeId] then
    GUIUtils.Toggle(self.m_UIGOs.tabToggles[nodeId], true)
  end
  self:GetNode(self.curNode):Show()
end
def.method("number", "=>", "table").GetNode = function(self, nodeId)
  local node = self.nodes[nodeId]
  if node == nil then
    local nodeFileName = NodeDefines[nodeId].nodeFileName
    if nodeFileName and nodeFileName ~= "" then
      local Node = require(nodeFileName)
      node = Node.Instance()
      local nodeRoot = self.m_UIGOs.Img_Bg0:FindDirect(NodeDefines[nodeId].rootName)
      self.nodes[nodeId] = node
      self.nodes[nodeId]:Init(self, nodeRoot)
      self.nodes[nodeId].m_customizeType = NodeDefines[nodeId].customizeType
    end
  end
  return node
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in ipairs(NodeDefines) do
    if v.tabName == tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method("number", "function").SetBigPopupItems = function(self, count, onSetItemInfo)
  self.m_UIGOs.Group_BigSelected:SetActive(true)
  local List_Item = self.m_UIGOs.Group_BigSelected:FindDirect("Img_Bg1/Scroll View/List_Item1")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  for i = 1, #itemObjs do
    local itemObj = itemObjs[i]
    local rs = onSetItemInfo(i)
    if rs then
      local Label_Name = itemObj:FindDirect("Btn_Item1/Label_Name")
      GUIUtils.SetText(Label_Name, rs.name)
    end
  end
  self.m_msgHandler:Touch(List_Item)
  GUIUtils.ResetPosition(List_Item.parent, 0)
end
def.method("number", "function").SetSmallPopupItems = function(self, count, onSetItemInfo)
  self.m_UIGOs.Group_SmallSelected:SetActive(true)
  local List_Item = self.m_UIGOs.Group_SmallSelected:FindDirect("Img_Bg2/Scroll View/List_Item2")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  uiList:Reposition()
  local itemObjs = uiList.children
  for i = 1, #itemObjs do
    local itemObj = itemObjs[i]
    local rs = onSetItemInfo(i)
    if rs then
      local Label_Name = itemObj:FindDirect("Btn_Item2/Label_Name2")
      GUIUtils.SetText(Label_Name, rs.name)
    end
  end
  self.m_msgHandler:Touch(List_Item)
  GUIUtils.ResetPosition(List_Item.parent, 0)
end
def.method().HidePopupPanels = function(self)
  self.m_UIGOs.Group_BigSelected:SetActive(false)
  self.m_UIGOs.Group_SmallSelected:SetActive(false)
end
def.method("number").OnBigPopupItemClick = function(self, index)
  self:GetNode(self.curNode):OnBigPopupItemClick(index)
end
def.method("number").OnSmallPopupItemClick = function(self, index)
  self:GetNode(self.curNode):OnSmallPopupItemClick(index)
end
def.method().CalcNextNode = function(self)
  local params = self.params
  if params == nil then
    return
  end
  if params.lastSideIndex == 1 then
    self.nextNode = NodeId.Equipment
  elseif params.lastSideIndex == 2 then
    self.nextNode = NodeId.Pet
  elseif params.lastSideIndex == 4 then
    self.nextNode = NodeId.PetEquipment
  end
end
def.method().Hide = function(self)
  if self.curNode == NodeId.MyCustomize then
    self:SwitchToNode(self.nextNode)
  else
    self:DestroyPanel()
  end
end
return SearchPanel.Commit()
