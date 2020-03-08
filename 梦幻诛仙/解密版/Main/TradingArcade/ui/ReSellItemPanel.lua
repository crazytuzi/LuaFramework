local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SellItemPanelBase = require("Main.TradingArcade.ui.SellItemPanelBase")
local ReSellItemPanel = Lplus.Extend(SellItemPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local def = ReSellItemPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = ReSellItemPanel()
  end
  return instance
end
def.field("table").m_goods = nil
def.field("number").m_originalPrice = 0
def.field("table").itemTip = nil
def.static("table", "=>", ReSellItemPanel).ShowPanel = function(goods)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
    self = Instance()
  end
  self.m_goods = goods
  self.m_arrowCallback = arrowCallback
  SellServiceMgr.Instance():QueryGoodsDetail(goods, ReSellItemPanel.OnPreQueryGoodsDetail)
  self:QueryItemPrices(goods.itemId)
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_SELL_ITEM, 2)
  self:SetModal(true)
  return self
end
def.override().OnCreate = function(self)
  SellItemPanelBase.OnCreate(self)
  local Group_Num = self.m_uiGOs.Group_Info:FindDirect("Group_Num")
  local Btn_Minus = Group_Num:FindDirect("Btn_Minus")
  local Btn_Add = Group_Num:FindDirect("Btn_Add")
  GUIUtils.SetActive(Btn_Add, false)
  GUIUtils.SetActive(Btn_Minus, false)
  self.m_uiGOs.Btn_Sell = self.m_uiGOs.Group_Info:FindDirect("Btn_Sell")
  GUIUtils.SetText(self.m_uiGOs.Btn_Sell:FindDirect("Label"), textRes.TradingArcade[36])
  self.m_uiGOs.Btn_Cancel = self.m_uiGOs.Group_Info:FindDirect("Btn_Cancel")
  GUIUtils.SetText(self.m_uiGOs.Btn_Cancel:FindDirect("Label"), textRes.TradingArcade[37])
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_goods = nil
  instance = nil
  SellItemPanelBase.OnDestroy(self)
end
def.method().UpdateUI = function(self)
  local goods = self.m_goods
  self.m_num = goods.num
  self.m_maxNum = self.m_num
  self.m_originalPrice = goods.price
  self.m_price = self.m_originalPrice
  local marketItemCfg = TradingArcadeUtils.GetMarketItemCfg(goods.itemId)
  self.m_minPrice = marketItemCfg.minprice
  self.m_maxPrice = marketItemCfg.maxprice
  self:SetItemInfo(goods.itemId)
  self:UpdatePrices()
  self:UpdateOnSellPriceRange()
  self:UpdatePos()
end
def.method().UpdatePublicTime = function(self)
  local hour, minute = 0, 0
  if self.m_price == self.m_originalPrice then
    hour = 0
    self:SetPublicTime(hour, minute)
  else
    local remainMinute = TradingArcadeUtils.GetCurrentPublicTime()
    hour = require("Common.MathHelper").Floor(remainMinute / 60)
    local minute = remainMinute % 60
    local text = string.format(textRes.TradingArcade[16], hour, minute)
    text = string.format("[ff0000]%s[-]", text)
    GUIUtils.SetText(self.m_uiGOs.Label_Time, text)
  end
end
def.method().UpdatePrices = function(self)
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, self.m_price)
  GUIUtils.SetText(self.m_uiGOs.Label_Num, self.m_num)
  local totalPrice = self:GetTotalPrice()
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_AllPrice, totalPrice)
  local serviceCharge = self:GetServiceCharge()
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Tax, serviceCharge)
  self:UpdatePublicTime()
end
def.override().OnCancelBtnClick = function(self)
  SellServiceMgr.Instance():UnshelveGoodsReq(self.m_goods)
  self:DestroyPanel()
end
def.override().OnSellBtnClick = function(self)
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
  SellServiceMgr.Instance():ReSellItem(self.m_goods, self.m_price)
  self:DestroyPanel()
end
def.override("boolean").ShowItemTips = function(self, autoQuery)
  local ItemTips = require("Main.Item.ui.ItemTips")
  local goods = self.m_goods
  local itemId = goods.itemId
  local item = goods.itemInfo
  local function getPos()
    local go = self.m_uiGOs.Img_Bg0
    local position = go.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    screenPos.x = screenPos.x + 60
    local widget = go:GetComponent("UIWidget")
    return screenPos.x, screenPos.y, widget:get_width(), widget:get_height()
  end
  if item == nil then
    local x, y, w, h = getPos()
    self.itemTip = ItemTipsMgr.Instance():ShowBasicTips(itemId, x, y, w, h, 0, false)
    self.itemTip:SetOperateContext({goods = goods, go = go})
    local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
    if TradingArcadeUtils.NeedQueryItemDetail(itemId) and autoQuery then
      SellServiceMgr.Instance():QueryGoodsDetail(goods, function(...)
        self:OnGoodsDetailUpdate()
      end)
    end
  else
    if self.itemTip and self.itemTip.m_panel and self.itemTip.m_panel.isnil == false then
      self.itemTip:DestroyPanel()
    end
    local x, y, w, h = getPos()
    self.itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.Other, x, y, w, h, 0)
  end
end
def.method().OnGoodsDetailUpdate = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self:ShowItemTips(false)
end
def.static("table").OnPreQueryGoodsDetail = function(goods)
  if goods == nil or instance == nil then
    return
  end
  local self = instance
  if self.m_goods == nil then
    return
  end
  local itemInfo = goods.itemInfo
  if itemInfo == nil then
    return
  end
  local maxprice = TradingArcadeUtils.GetItemOnSellMaxPrice(itemInfo)
  if maxprice ~= self.m_maxPrice then
    self.m_maxPrice = maxprice
  end
end
return ReSellItemPanel.Commit()
