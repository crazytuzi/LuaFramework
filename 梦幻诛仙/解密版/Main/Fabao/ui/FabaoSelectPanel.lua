local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoSelectPanel = Lplus.Extend(ECPanelBase, "FabaoSelectPanel")
local def = FabaoSelectPanel.define
def.field("number").m_type = 0
def.field("table").m_fabao = nil
def.field("number").m_selectIndex = 0
def.field("function").m_callback = nil
def.field("string").m_title = ""
def.field("string").m_desc = ""
local instance
def.static("=>", FabaoSelectPanel).Instance = function()
  if nil == instance then
    instance = FabaoSelectPanel()
  end
  return instance
end
def.method("number", "function", "string", "string").ShowPanel = function(self, targetType, callback, title, desc)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_type = targetType
  self.m_callback = callback
  self.m_title = title
  self.m_desc = desc
  self:CreatePanel(RESPATH.PREFAB_FABAO_SELECT_PANEL, 0)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:SetSelectIndex(0)
  self:UpdateData()
  self:UpdateUI()
end
def.method().UpdateData = function(self)
  local FabaoModule = require("Main.Fabao.FabaoModule")
  self.m_fabao = FabaoModule.Instance():GetAllFabaoInBagByType(self.m_type)
end
def.method().UpdateUI = function(self)
  local titleLabel = self.m_panel:FindDirect("Img_Bg/Img_BgTitle/Label_Title")
  titleLabel:GetComponent("UILabel"):set_text(self.m_title)
  local tipLabel1 = self.m_panel:FindDirect("Img_Bg/Label_Tips")
  tipLabel1:GetComponent("UILabel"):set_text(self.m_desc)
  local listView = self.m_panel:FindDirect("Img_Bg/Img_Background/Scroll View/Grid")
  local fabaoNum = #self.m_fabao
  local listItems = GUIUtils.InitUIList(listView, fabaoNum, false)
  for i = 1, fabaoNum do
    local itemObj = listItems[i]
    itemObj.name = string.format("fabaoItem_%d", i)
    local fabaoData = self.m_fabao[i]
    local nameLabel = itemObj:FindDirect(string.format("Label_Name_%d", i))
    local levelLabel = itemObj:FindDirect(string.format("Label_Lv_%d", i))
    local bgSprite = itemObj:FindDirect(string.format("Img_BgIcon_%d", i))
    local texture = itemObj:FindDirect(string.format("Img_BgIcon_%d/Img_Icon_%d", i, i))
    nameLabel:GetComponent("UILabel"):set_text(fabaoData.name)
    levelLabel:GetComponent("UILabel"):set_text(string.format("%d%s", fabaoData.itemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV], textRes.Fabao[12]))
    bgSprite:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", fabaoData.namecolor))
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), fabaoData.iconId)
  end
  self.m_msgHandler:Touch(listView)
  GUIUtils.Reposition(listView, "UIList", 0.01)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif string.find(id, "fabaoItem_") then
    self:OnClickFabaoItem(clickObj)
  elseif "Btn_Confirm" == id then
    self:OnClickConfimBtn()
  end
end
def.method().OnClickConfimBtn = function(self)
  if 0 == self.m_selectIndex then
    Toast(textRes.Fabao[92])
    return
  end
  local fabao = self.m_fabao[self.m_selectIndex]
  if nil == fabao then
    self:DestroyPanel()
    return
  end
  if nil == self.m_callback then
    self:DestroyPanel()
  else
    self.m_callback(fabao.key)
    self:DestroyPanel()
  end
end
def.method("userdata").OnClickFabaoItem = function(self, clickObj)
  local name = clickObj.name
  local strs = string.split(name, "_")
  local index = tonumber(strs[2])
  self:SetSelectIndex(index)
end
def.method("number").SetSelectIndex = function(self, index)
  self.m_selectIndex = index
end
def.override().OnDestroy = function(self)
  self.m_type = 0
  self.m_fabao = nil
  self.m_selectIndex = 0
  self.m_callback = nil
  self.m_desc = ""
  self.m_title = ""
end
FabaoSelectPanel.Commit()
return FabaoSelectPanel
