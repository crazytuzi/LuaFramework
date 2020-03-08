local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SellItemPanelBase = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local def = SellItemPanelBase.define
def.const("table").Pos = {
  Left = {x = -180, y = 0},
  Center = {x = 0, y = 0}
}
def.const("number").GOLD_TIPS_ID = 701600501
def.field("table").m_uiGOs = nil
def.field("function").m_arrowCallback = nil
def.field("number").m_price = 0
def.field("number").m_num = 0
def.field("number").m_maxNum = 0
def.field("number").m_minPrice = 0
def.field("number").m_maxPrice = 0
def.field("number").m_onSellMinPrice = 0
def.field("number").m_onSellMaxPrice = 0
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Add" then
    self:OnAddNumBtnClick()
  elseif id == "Btn_Minus" then
    self:OnMinNumBtnClick()
  elseif id == "Btn_Cancel" then
    self:OnCancelBtnClick()
  elseif id == "Btn_Sell" then
    self:OnSellBtnClick()
  elseif id == "Img_BgPrice" then
    self:OnPriceLabelClick()
  elseif id == "Texture_RightIcon" then
    self:ShowItemTips(true)
  elseif id == "Btn_Tips" then
    self:OnGoldTipsBtnClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  end
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
end
def.override().AfterCreate = function(self)
  self:ShowItemTips(true)
end
def.override().OnDestroy = function(self)
  self.m_uiGOs = nil
end
def.method().InitUI = function(self)
  self.m_uiGOs = {}
  self.m_uiGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiGOs.Group_Info = self.m_uiGOs.Img_Bg0:FindDirect("Group_Info")
  self.m_uiGOs.Img_BgRightItem = self.m_uiGOs.Group_Info:FindDirect("Img_BgRightItem")
  self.m_uiGOs.Texture_RightIcon = self.m_uiGOs.Img_BgRightItem:FindDirect("Texture_RightIcon")
  self.m_uiGOs.Label_Name = self.m_uiGOs.Group_Info:FindDirect("Label_Name")
  self.m_uiGOs.Img_BgPrice = self.m_uiGOs.Group_Info:FindDirect("Group_Price/Img_BgPrice")
  self.m_uiGOs.Label_Price = self.m_uiGOs.Img_BgPrice:FindDirect("Label_Price")
  self.m_uiGOs.Label_AllPrice = self.m_uiGOs.Group_Info:FindDirect("Group_AllPrice/Img_BgPrice/Label_Price")
  self.m_uiGOs.Label_Num = self.m_uiGOs.Group_Info:FindDirect("Group_Num/Img_BgNum/Label_Num")
  self.m_uiGOs.Label_Tax = self.m_uiGOs.Group_Info:FindDirect("Group_Tax/Img_BgTax/Label_Tax")
  self.m_uiGOs.Group_PriceLimt = self.m_uiGOs.Group_Info:FindDirect("Group_PriceLimt")
  self.m_uiGOs.Label_LowLimit = self.m_uiGOs.Group_PriceLimt:FindDirect("Label_LowLimit")
  self.m_uiGOs.Label_UpLimit = self.m_uiGOs.Group_PriceLimt:FindDirect("Label_UpLimit")
  self.m_uiGOs.Label_Time = self.m_uiGOs.Group_Info:FindDirect("Group_ShowTime/Img_Bg/Label_Time")
  local boxCollider = self.m_uiGOs.Img_BgPrice:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = self.m_uiGOs.Img_BgPrice:AddComponent("BoxCollider")
    local uiWidget = self.m_uiGOs.Img_BgPrice:GetComponent("UIWidget")
    uiWidget.autoResizeBoxCollider = true
    uiWidget:ResizeCollider()
    self.m_msgHandler:Touch(self.m_uiGOs.Img_BgPrice)
  end
end
def.virtual().OnCancelBtnClick = function(self)
end
def.virtual().OnSellBtnClick = function(self)
end
def.method().UpdatePos = function(self)
  local pos = SellItemPanelBase.Pos.Left
  self.m_uiGOs.Img_Bg0.localPosition = Vector.Vector3.new(pos.x, pos.y, 0)
end
def.method("number").SetItemInfo = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  GUIUtils.SetText(self.m_uiGOs.Label_Name, itemBase.name)
  GUIUtils.SetTexture(self.m_uiGOs.Texture_RightIcon, itemBase.icon)
  GUIUtils.SetItemCellSprite(self.m_uiGOs.Img_BgRightItem, itemBase.namecolor)
end
def.method("number", "number").SetPublicTime = function(self, hour, minute)
  local text = string.format(textRes.TradingArcade[16], hour, minute)
  GUIUtils.SetText(self.m_uiGOs.Label_Time, text)
end
def.method("=>", "number").GetTotalPrice = function(self)
  return self.m_price * self.m_num
end
def.method("=>", "number").GetServiceCharge = function(self)
  local totalPrice = self:GetTotalPrice()
  return SellServiceMgr.Instance():CalcServiceCharge(totalPrice)
end
def.method().OnAddNumBtnClick = function(self)
  local nextNum = self.m_num + 1
  if nextNum > self.m_maxNum then
    Toast(textRes.TradingArcade[10])
    return
  end
  self.m_num = nextNum
  self:UpdatePrices()
end
def.method().OnMinNumBtnClick = function(self)
  local nextNum = self.m_num - 1
  if nextNum < 1 then
    Toast(textRes.TradingArcade[11])
    return
  end
  self.m_num = nextNum
  self:UpdatePrices()
end
def.method().FocusOnPriceLabel = function(self)
  self:LightingPriceLabel()
  self:ShowDigitalKeyboard()
end
def.method().LightingPriceLabel = function(self)
  local path = "panel_blackshopsellitem/Img_Bg0/Group_Info/Group_Price/Img_BgPrice"
  GUIUtils.AddLightEffectToPanel(path, GUIUtils.Light.Square)
end
def.method().OnPriceLabelClick = function(self)
  self:ShowDigitalKeyboard()
end
def.method().ShowDigitalKeyboard = function(self)
  CommonDigitalKeyboard.Instance():ShowPanelEx(self.m_maxPrice, function(val, tag)
    if self.m_panel and not self.m_panel.isnil then
      self.m_price = val
      self:UpdatePrices()
      if val == self.m_maxPrice then
        Toast(string.format(textRes.TradingArcade[13], self.m_maxPrice))
      end
    end
  end, nil)
  CommonDigitalKeyboard.Instance():SetPos(250, 0)
end
def.method().UpdateOnSellPriceRange = function(self)
  local lowText = self.m_onSellMinPrice
  if self.m_onSellMinPrice == 0 then
    lowText = ""
  end
  local highText = self.m_onSellMaxPrice
  if self.m_onSellMaxPrice == 0 then
    highText = ""
  end
  GUIUtils.SetText(self.m_uiGOs.Label_LowLimit, lowText)
  GUIUtils.SetText(self.m_uiGOs.Label_UpLimit, highText)
end
def.virtual("boolean").ShowItemTips = function(self)
end
def.method("number").QueryItemPrices = function(self, itemId)
  TradingArcadeProtocol.CQueryItemPrice(itemId, function(p)
    if p.itemId ~= itemId then
      return
    end
    self.m_onSellMinPrice = p.prices[1] or ""
    self.m_onSellMaxPrice = p.prices[2] or ""
    self.m_onSellMaxPrice = math.min(self.m_onSellMaxPrice, self.m_maxPrice)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self:UpdateOnSellPriceRange()
  end)
end
def.method().OnGoldTipsBtnClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(SellItemPanelBase.GOLD_TIPS_ID) or ""
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
return SellItemPanelBase.Commit()
