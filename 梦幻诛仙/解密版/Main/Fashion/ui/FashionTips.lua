local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FashionTips = Lplus.Extend(ECPanelBase, "FashionTips")
local FashionData = require("Main.Fashion.FashionData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local GUIUtils = require("GUI.GUIUtils")
local FashionData = require("Main.Fashion.FashionData")
local FittingRoomPanel = require("Main.Item.ui.FittingRoomPanel")
local def = FashionTips.define
local instance
def.field("table")._uiObjs = nil
def.field("number")._showFashionType = -1
def.field("table")._fashionInfo = nil
def.static("=>", FashionTips).Instance = function()
  if instance == nil then
    instance = FashionTips()
  end
  return instance
end
def.method("number").ShowFashionTips = function(self, fashionType)
  if self.m_panel == nil then
    self._showFashionType = fashionType
    self:CreatePanel(RESPATH.ITEMTIPS, 2)
    self:SetOutTouchDisappear()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowFashionInfo()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_Direction = self.m_panel:FindDirect("Group_Btn")
  self._uiObjs.Table_Tips = self.m_panel:FindDirect("Table_Tips")
  self._uiObjs.Title = self._uiObjs.Table_Tips:FindDirect("Title")
  self._uiObjs.Label_Describe = self._uiObjs.Table_Tips:FindDirect("Label_Describe")
  self._uiObjs.Container_Btn = self._uiObjs.Table_Tips:FindDirect("Container_Btn")
  self._uiObjs.Btn_Info = self._uiObjs.Title:FindDirect("Btn_Info")
  self._uiObjs.FashionName = self._uiObjs.Title:FindDirect("Label_Name")
  self._uiObjs.FashionType = self._uiObjs.Title:FindDirect("Label_Type")
  self._uiObjs.Label_LvTitle = self._uiObjs.Title:FindDirect("Label_LvTitle")
  self._uiObjs.Label_Lv = self._uiObjs.Title:FindDirect("Label_Lv")
  self._uiObjs.Img_Zhuan = self._uiObjs.Title:FindDirect("Img_Zhuan")
  self._uiObjs.Img_Bang = self._uiObjs.Title:FindDirect("Img_Bang")
  self._uiObjs.ImgEquiped = self._uiObjs.Title:FindDirect("Img_Present")
  self._uiObjs.FashionIcon = self._uiObjs.Title:FindDirect("Img_Item/Img_Icon")
  self._uiObjs.Group_Direction:SetActive(false)
  self._uiObjs.Container_Btn:SetActive(false)
  self._uiObjs.Btn_Info:SetActive(false)
  self._uiObjs.Label_LvTitle:SetActive(false)
  self._uiObjs.Label_Lv:SetActive(false)
  self._uiObjs.Img_Zhuan:SetActive(false)
  self._uiObjs.Img_Bang:SetActive(false)
  self._uiObjs.ImgEquiped:SetActive(false)
end
def.method().ShowFashionInfo = function(self)
  local fashionItem = FashionUtils.GetFashionItemByFashionType(self._showFashionType)
  if fashionItem == nil then
    self:DestroyPanel()
  else
    self._uiObjs.FashionName:GetComponent("UILabel"):set_text(fashionItem.fashionDressName)
    self._uiObjs.FashionType:GetComponent("UILabel"):set_text(textRes.Fashion[29])
    local uiTexture = self._uiObjs.FashionIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, fashionItem.iconId)
    if FashionData.Instance().currentFashionId == fashionItem.id then
      self._uiObjs.ImgEquiped:SetActive(true)
    else
      self._uiObjs.ImgEquiped:SetActive(false)
    end
    self._uiObjs.Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText("<p><font size=22>" .. fashionItem.fashionDressDesc .. "</font></p>")
    self._fashionInfo = fashionItem
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Try" then
    self:TryOnFashionView()
  end
end
def.method().TryOnFashionView = function(self)
  if self._fashionInfo ~= nil then
    FittingRoomPanel.Instance():ShowFashionPanel(self._fashionInfo.id)
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._showFashionType = -1
end
FashionTips.Commit()
return FashionTips
