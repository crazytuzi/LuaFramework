local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SellItemPanelBase = require("Main.TradingArcade.ui.SellItemPanelBase")
local SellItemPanel = Lplus.Extend(SellItemPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local def = SellItemPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = SellItemPanel()
  end
  return instance
end
def.field("table").m_item = nil
def.static("table", "function", "=>", SellItemPanel).ShowPanel = function(item, arrowCallback)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
    self = Instance()
  end
  self.m_item = item
  self.m_arrowCallback = arrowCallback
  local marketItemCfg = TradingArcadeUtils.GetMarketItemCfg(item.id)
  self.m_minPrice = marketItemCfg.minprice
  self.m_maxPrice = self:GetMaxSellPrice(item, marketItemCfg)
  self:QueryItemPrices(item.id)
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_SELL_ITEM, 2)
  self:SetModal(true)
  return self
end
def.override().OnCreate = function(self)
  SellItemPanelBase.OnCreate(self)
  self:UpdateUI()
  self:LightingPriceLabel()
end
def.override().OnDestroy = function(self)
  self.m_item = nil
  instance = nil
  SellItemPanelBase.OnDestroy(self)
end
def.method().UpdateUI = function(self)
  local item = self.m_item
  self.m_num = item.number
  self.m_maxNum = SellServiceMgr.Instance():GetItemMaxOnSellNum(item)
  self.m_price = self.m_minPrice
  self:SetItemInfo(item.id)
  self:UpdatePublicTime()
  self:UpdatePrices()
  self:UpdateOnSellPriceRange()
  self:UpdatePos()
end
def.method().UpdatePublicTime = function(self)
  local remainMinute = TradingArcadeUtils.GetCurrentPublicTime()
  local hour = require("Common.MathHelper").Floor(remainMinute / 60)
  local minute = remainMinute % 60
  self:SetPublicTime(hour, minute)
end
def.method("table", "table", "=>", "number").GetMaxSellPrice = function(self, item, itemCfg)
  return TradingArcadeUtils.GetItemOnSellMaxPrice(item)
end
def.method().UpdatePrices = function(self)
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, self.m_price)
  GUIUtils.SetText(self.m_uiGOs.Label_Num, self.m_num)
  local totalPrice = self:GetTotalPrice()
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_AllPrice, totalPrice)
  local serviceCharge = self:GetServiceCharge()
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Tax, serviceCharge)
end
def.override().OnCancelBtnClick = function(self)
  self:DestroyPanel()
end
def.override().OnSellBtnClick = function(self)
  if TradingArcadeUtils.IsItemFrozen(self.m_item) then
    Toast(textRes.TradingArcade[33])
    return
  end
  if self.m_price < self.m_minPrice then
    self:FocusOnPriceLabel()
    Toast(string.format(textRes.TradingArcade[12], self.m_minPrice))
    return
  end
  if self.m_price > self.m_maxPrice then
    self:FocusOnPriceLabel()
    Toast(string.format(textRes.TradingArcade[13], self.m_maxPrice))
    return
  end
  local serviceCharge = self:GetServiceCharge()
  serviceCharge = Int64.new(serviceCharge)
  local ItemModule = require("Main.Item.ItemModule")
  local money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  if serviceCharge > money then
    _G.GoToBuyGold(true)
    return
  end
  SellServiceMgr.Instance():SellItem(self.m_item, self.m_price, self.m_num)
  self:DestroyPanel()
end
def.override("boolean").ShowItemTips = function(self)
  local ItemTips = require("Main.Item.ui.ItemTips")
  local obj = self.m_uiGOs.Img_Bg0
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  screenPos.x = screenPos.x + 60
  local widget = obj:GetComponent("UIWidget")
  local item = self.m_item
  local itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, item.itemKey, 0, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  itemTip.arrowState = ItemTips.ArrowState.Both
  function itemTip.arrowCallback(dir)
    if self.m_uiGOs == nil then
      return
    end
    if self.m_arrowCallback then
      self.m_arrowCallback(dir)
    end
  end
  itemTip:UpdateInfo()
end
return SellItemPanel.Commit()
