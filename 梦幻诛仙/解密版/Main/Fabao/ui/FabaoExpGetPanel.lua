local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoExpGetPanel = Lplus.Extend(ECPanelBase, "FabaoExpGetPanel")
local def = FabaoExpGetPanel.define
def.field("table").m_ItemListData = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", FabaoExpGetPanel).Instance = function()
  if not instance then
    instance = FabaoExpGetPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_FABAO_EXP_GET_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_ItemListData = nil
  self.m_UIGO = nil
end
def.method("number").ShowItemTip = function(self, index)
  local id = self.m_ItemListData[index]
  local btnGO = self.m_UIGO[("Img_Icon_%d"):format(index)]
  if btnGO then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(id, btnGO, -1, true)
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id:find("Img_Item_") == 1 then
    local _, lastIndex = id:find("Img_Item_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self:ShowItemTip(index)
  elseif id:find("Btn_Add_") == 1 then
    local _, lastIndex = id:find("Btn_Add_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self:ShowItemTip(index)
  end
end
def.method().UpdateData = function(self)
  self.m_ItemListData = FabaoMgr.GetFabaoExpIDs()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.List = self.m_panel:FindDirect("Img_Bg0/Scroll_View/List_Item")
end
def.method().UpdateListView = function(self)
  local uiListGO = self.m_UIGO.List
  local itemLists = GUIUtils.InitUIList(uiListGO, #self.m_ItemListData)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, #self.m_ItemListData do
    local itemList = itemLists[i]
    local id = self.m_ItemListData[i]
    local itemBase = ItemUtils.GetItemBase(id)
    local iconGO = itemList:FindDirect(("Img_BgIcon_%d/Img_Icon_%d"):format(i, i))
    local nameGO = itemList:FindDirect(("Label_Name_%d"):format(i))
    GUIUtils.SetText(nameGO, itemBase.name)
    GUIUtils.SetTexture(iconGO, itemBase.icon)
    self.m_UIGO[("Img_Icon_%d"):format(i)] = iconGO
    self.m_UIGO[("Label_Name_%d"):format(i)] = nameGO
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().Update = function(self)
  self:UpdateData()
  self:UpdateListView()
end
return FabaoExpGetPanel.Commit()
