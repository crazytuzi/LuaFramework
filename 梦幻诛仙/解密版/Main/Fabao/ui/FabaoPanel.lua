local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local CombineFabaoNode = require("Main.Fabao.ui.CombineFabaoNode")
local RefreshFabaoNode = require("Main.Fabao.ui.RefreshFabaoNode")
local GrowFabaoNode = require("Main.Fabao.ui.GrowFabaoNode")
local MosaicFabaoNode = require("Main.Fabao.ui.MosaicFabaoNode")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoPanel = Lplus.Extend(ECPanelBase, "FabaoPanel")
local def = FabaoPanel.define
def.const("table").SUBNODEINFO = {
  {
    ID = 1,
    Instance = CombineFabaoNode.Instance(),
    GroupName = "Img_Bg1/HC",
    TabName = "Img_Bg1/Group_Tab/Tab_HC"
  },
  {
    ID = 2,
    Instance = RefreshFabaoNode.Instance(),
    GroupName = "Img_Bg1/XL",
    TabName = "Img_Bg1/Group_Tab/Tab_XL"
  },
  {
    ID = 3,
    Instance = GrowFabaoNode.Instance(),
    GroupName = "Img_Bg1/CZ",
    TabName = "Img_Bg1/Group_Tab/Tab_CZ"
  },
  {
    ID = 4,
    Instance = MosaicFabaoNode.Instance(),
    GroupName = "Img_Bg1/XQ",
    TabName = "Img_Bg1/Group_Tab/Tab_XQ"
  }
}
def.field("number").m_CurIndex = 1
def.field("number").m_CurNode = 0
def.field("number").m_ListNum = 0
def.field("table").m_ListData = nil
def.field("table").m_Nodes = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", FabaoPanel).Instance = function()
  if not instance then
    instance = FabaoPanel()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method("number").ShowPanel = function(self, curNode)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_CurNode = curNode
  self:CreatePanel(RESPATH.PREFAB_FABAO_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.m_Nodes = {}
  for k, v in ipairs(FabaoPanel.SUBNODEINFO) do
    local instance = v.Instance
    local groupGO = self.m_panel:FindDirect(v.GroupName)
    local tabGO = self.m_panel:FindDirect(v.TabName)
    self.m_Nodes[k] = instance
    self.m_Nodes[k]:Init(self, groupGO)
    tabGO:SetActive(instance:IsUnlock())
  end
  self:TweenAlphaSelectItem(self.m_CurIndex, 1)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoPanel.OnBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, FabaoPanel.OnMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, FabaoPanel.OnMoneyChanged)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.PanelClose, FabaoPanel.OnMallPanelClose)
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.CLOSET_PANEL_CLOSE, FabaoPanel.OnCommercePitchPanel)
end
local function UpdatePanel()
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance:Update()
  end
end
def.override("boolean").OnShow = function(self, flag)
  if flag then
    UpdatePanel()
  end
end
def.override().OnDestroy = function(self)
  self.m_Nodes[self.m_CurNode]:Clear()
  self.m_CurIndex = 1
  self.m_ListNum = 0
  self.m_Nodes = nil
  self.m_ListData = nil
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoPanel.OnBagInfoSyncronized)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, FabaoPanel.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, FabaoPanel.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.PanelClose, FabaoPanel.OnMallPanelClose)
  Event.UnregisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.CLOSET_PANEL_CLOSE, FabaoPanel.OnCommercePitchPanel)
end
def.static("table", "table").OnBagInfoSyncronized = function(params)
  UpdatePanel()
end
def.static("table", "table").OnMoneyChanged = function(param)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance.m_Nodes[instance.m_CurNode]:UpdateMoney()
  end
end
def.static("table", "table").OnMallPanelClose = function(params)
  UpdatePanel()
end
def.static("table", "table").OnCommercePitchPanel = function(params)
  UpdatePanel()
end
def.method("number").SwitchToNode = function(self, node)
  if self.m_CurNode == node then
    return
  end
  self.m_CurNode = node
  self.m_CurIndex = 1
  self:Update()
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tab_HC" then
    self:SwitchToNode(FabaoPanel.SUBNODEINFO[1].ID)
  elseif id == "Tab_XL" then
    self:SwitchToNode(FabaoPanel.SUBNODEINFO[2].ID)
  elseif id == "Tab_CZ" then
    self:SwitchToNode(FabaoPanel.SUBNODEINFO[3].ID)
  elseif id == "Tab_XQ" then
    self:SwitchToNode(FabaoPanel.SUBNODEINFO[4].ID)
  elseif id:find("Group_ListItem1_") == 1 then
    local _, lastIndex = id:find("Group_ListItem1_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local item = self.m_ListData[index]
    if index ~= 1 then
      self:TweenAlphaSelectItem(1, 0)
    end
    if not item or not item.data then
      return
    end
    self.m_CurIndex = index
    self.m_Nodes[self.m_CurNode]:UpdateItem(item.data)
    self.m_Nodes[self.m_CurNode]:Update()
    self.m_Nodes[self.m_CurNode]:OnClickLeftFaBaoItem()
  else
    self.m_Nodes[self.m_CurNode]:onClick(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.m_Nodes[self.m_CurNode]:onDrag(id, dx, dy)
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.m_Nodes[self.m_CurNode]:onPress(id, state)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Group_Tab = self.m_panel:FindDirect("Img_Bg1/Group_Tab")
  self.m_UIGO.Label_Title = self.m_panel:FindDirect("Img_Bg1/Goup_List/Group_Title/Label_Title")
  self.m_UIGO.Grid_List = self.m_panel:FindDirect("Img_Bg1/Goup_List/Scroll View_List/Grid_List")
end
def.method().Update = function(self)
  local data = self.m_ListData
  self:UpdateData()
  if self.m_ListNum ~= 0 then
    self:UpdateLeftView()
    self:UpdateMainView()
  else
    self.m_CurNode = 1
    self.m_ListData = data
    GUIUtils.Toggle(self.m_UIGO.Group_Tab:FindDirect("Tab_HC"), true)
    Toast(textRes.Fabao[7])
  end
end
def.method().UpdateData = function(self)
  self.m_ListData = {}
  local itemCount, itemDatas = nil, {}
  if self.m_CurNode == FabaoPanel.SUBNODEINFO[1].ID then
    itemCount, itemDatas = FabaoMgr.GetFabaoItems()
    for i = 1, itemCount do
      self.m_ListData[i] = {}
      self.m_ListData[i].data = itemDatas[i]
      self.m_ListData[i].labelName = itemDatas[i].name
      self.m_ListData[i].icon = itemDatas[i].icon
      self.m_ListData[i].isEquip = false
      self.m_ListData[i].showStar = false
      self.m_ListData[i].starLevel = 0
    end
  else
    itemCount, itemDatas = FabaoMgr.GetAllFabaoItems()
    for i = 1, itemCount do
      self.m_ListData[i] = {}
      self.m_ListData[i].data = itemDatas[i]
      self.m_ListData[i].labelName = itemDatas[i].data.templateData.baseData.name
      self.m_ListData[i].icon = itemDatas[i].data.templateData.baseData.icon
      self.m_ListData[i].isEquip = itemDatas[i].bagType == ItemModule.EQUIPBAG
      self.m_ListData[i].showStar = true
      self.m_ListData[i].starLevel = itemDatas[i].data.dynamicData.extraMap[ItemXStoreType.FABAO_CUR_RANK] + 1
      self.m_ListData[i].itemid = itemDatas[i].data.templateData.baseData.itemid
      self.m_ListData[i].score = FabaoUtils.CalcFabaoScore(itemDatas[i].data.dynamicData)
    end
    table.sort(self.m_ListData, function(l, r)
      if l.isEquip ~= r.isEquip then
        return l.isEquip
      elseif l.itemid ~= r.itemid then
        return l.itemid < r.itemid
      elseif l.score ~= r.score then
        return l.score > r.score
      end
    end)
  end
  self.m_ListNum = itemCount
  local item = self.m_ListData[self.m_CurIndex] and self.m_ListData[self.m_CurIndex].data
  if not item then
    return
  end
  self.m_Nodes[self.m_CurNode]:UpdateItem(item)
end
def.method("number", "number").TweenAlphaSelectItem = function(self, index, alpha)
  local imgSelect = self.m_panel:FindDirect(("Img_Bg1/Goup_List/Scroll View_List/Grid_List/Group_ListItem1_%d/Img_Select_%d"):format(index, index))
  if imgSelect then
    TweenAlpha.Begin(imgSelect, 0.1, alpha)
  end
end
def.method().UpdateLeftTitleView = function(self)
  local titleGO = self.m_UIGO.Label_Title
  GUIUtils.SetText(titleGO, textRes.Fabao[self.m_CurNode > 1 and 2 or 1])
end
def.method().UpdateLeftView = function(self)
  self:UpdateLeftTitleView()
  local itemCount, itemDatas = self.m_ListNum, self.m_ListData
  local uiListGO = self.m_UIGO.Grid_List
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local labelGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local wereGO = itemGO:FindDirect(("Img_Wear_%d"):format(i))
    local iconGO = itemGO:FindDirect(("Group_Icon_%d/Icon_Equip01_%d"):format(i, i))
    local groupStarGO = itemGO:FindDirect(("Group_Star_%d/List_Star_%d"):format(i, i))
    local itemData = itemDatas[i]
    GUIUtils.Toggle(itemGO, i == self.m_CurIndex)
    GUIUtils.SetText(labelGO, itemData.labelName)
    GUIUtils.SetActive(wereGO, itemData.isEquip)
    GUIUtils.SetTexture(iconGO, itemData.icon)
    GUIUtils.SetActive(groupStarGO, itemData.showStar)
    GUIUtils.SetStarView(groupStarGO, itemData.starLevel)
    GUIUtils.Reposition(groupStarGO, GUIUtils.COTYPE.LIST, 0)
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateMainView = function(self)
  local node = self.m_CurNode
  for _, v in ipairs(FabaoPanel.SUBNODEINFO) do
    local instance = v.Instance
    local tabGO = self.m_panel:FindDirect(v.TabName)
    local selectGO = tabGO:FindDirect("Img_Select")
    if v.ID == node then
      instance:InitUI()
      instance:Show()
    else
      instance:Hide()
    end
    GUIUtils.Toggle(tabGO, v.ID == node)
    GUIUtils.SetActive(selectGO, v.ID == node)
  end
end
return FabaoPanel.Commit()
