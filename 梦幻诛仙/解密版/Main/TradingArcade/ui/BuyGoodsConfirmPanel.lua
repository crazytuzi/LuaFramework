local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BuyGoodsConfirmPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local Vector = require("Types.Vector")
local def = BuyGoodsConfirmPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = BuyGoodsConfirmPanel()
  end
  return instance
end
def.const("table").Pos = {
  Left = {x = -180, y = 0},
  Center = {x = 0, y = 0}
}
def.field("table").m_goods = nil
def.field("table").m_uiGOs = nil
def.field("number").m_price = 0
def.field("number").m_num = 0
def.field("number").m_minNum = 1
def.field("number").m_maxNum = 0
def.field("table").itemTip = nil
def.field("boolean").m_firstCall = false
def.static("table", "number", "=>", BuyGoodsConfirmPanel).ShowPanel = function(goods, expectedNum)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
    self = Instance()
  end
  self.m_goods = goods
  self.m_maxNum = goods.num
  self.m_num = math.min(expectedNum, self.m_maxNum)
  self.m_num = math.max(self.m_num, self.m_minNum)
  self.m_price = goods.price
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_BUY_CONFIRM, 2)
  self:SetModal(true)
  return self
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_AddIN" then
    self:OnAddNumBtnClick()
  elseif id == "Btn_MinusIN" then
    self:OnMinNumBtnClick()
  elseif id == "Btn_Cancel" then
    self:DestroyPanel()
  elseif id == "Btn_Yes" then
    self:OnBuyBtnClick()
  elseif id == "Img_BgNum" then
    self:OnNumLabelClick()
  elseif id == "Texture_RightIcon" then
    self:ShowGoodsTips()
  end
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
  self:UpdatePos()
  self.m_firstCall = true
  GameUtil.AddGlobalTimer(0, true, function(...)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self:ShowGoodsTips()
  end)
end
def.override().OnDestroy = function(self)
  self.m_uiGOs = nil
  self.m_goods = nil
  self.itemTip = nil
  instance = nil
end
def.method().InitUI = function(self)
  self.m_uiGOs = {}
  self.m_uiGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_uiGOs.Group_Info = self.m_uiGOs.Img_Bg:FindDirect("Group_Info")
  self.m_uiGOs.Img_Item = self.m_uiGOs.Group_Info:FindDirect("Img_Item")
  self.m_uiGOs.Texture_RightIcon = self.m_uiGOs.Img_Item:FindDirect("Texture_RightIcon")
  self.m_uiGOs.Label_ItemNum = self.m_uiGOs.Img_Item:FindDirect("Label_ItemNum")
  self.m_uiGOs.Label_Name = self.m_uiGOs.Group_Info:FindDirect("Label_Name")
  self.m_uiGOs.Img_BgPrice = self.m_uiGOs.Img_Bg:FindDirect("Group_Price/Img_BgPrice")
  self.m_uiGOs.Label_Price = self.m_uiGOs.Img_BgPrice:FindDirect("Label_Price")
  self.m_uiGOs.Label_AllPrice = self.m_uiGOs.Img_Bg:FindDirect("Group_AllPrice/Label_AllPrice")
  self.m_uiGOs.Img_BgNum = self.m_uiGOs.Img_Bg:FindDirect("Group_Num/Img_BgNum")
  self.m_uiGOs.Label_Num = self.m_uiGOs.Img_BgNum:FindDirect("Label_Num")
  local boxCollider = self.m_uiGOs.Img_BgNum:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = self.m_uiGOs.Img_BgNum:AddComponent("BoxCollider")
    local uiWidget = self.m_uiGOs.Img_BgNum:GetComponent("UIWidget")
    uiWidget.autoResizeBoxCollider = true
    uiWidget:ResizeCollider()
    self.m_msgHandler:Touch(self.m_uiGOs.Img_BgNum)
  end
end
def.method().UpdateUI = function(self)
  local goods = self.m_goods
  local name = goods:GetName()
  local icon = goods:GetIcon()
  local iconId = icon.iconId
  local bgSpriteName = icon.bgSprite
  local price = goods.price
  GUIUtils.SetText(self.m_uiGOs.Label_Name, name)
  GUIUtils.SetTexture(self.m_uiGOs.Texture_RightIcon, iconId)
  GUIUtils.SetSprite(self.m_uiGOs.Img_Item, bgSpriteName)
  GUIUtils.SetText(self.m_uiGOs.Label_ItemNum, "")
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, price)
  self:UpdatePrices()
end
def.method().UpdateNum = function(self)
  local num = self.m_num
  GUIUtils.SetText(self.m_uiGOs.Label_Num, num)
end
def.method().UpdatePrices = function(self)
  self:UpdateNum()
  local totalPrice = self:GetTotalPrice()
  GUIUtils.SetText(self.m_uiGOs.Label_AllPrice, totalPrice)
end
def.method("=>", "number").GetTotalPrice = function(self)
  return self.m_price * self.m_num
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
def.method().OnBuyBtnClick = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local totalPrice = self:GetTotalPrice()
  totalPrice = Int64.new(totalPrice)
  local haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
  if totalPrice > haveNum then
    _G.GoToBuyGoldIngot(true)
    return
  end
  local goods = self.m_goods
  if goods.type == GoodsData.Type.Item and ItemModule.Instance():IsBagFull(ItemModule.BAG) then
    Toast(textRes.TradingArcade[48])
    self:DestroyPanel()
    return
  elseif goods.type == GoodsData.Type.Pet and PetMgr.Instance():IsPetFullest() then
    Toast(textRes.TradingArcade[49])
    self:DestroyPanel()
    return
  end
  BuyServiceMgr.Instance():BuyGoods(self.m_goods, self.m_num)
  self:DestroyPanel()
end
def.method().OnNumLabelClick = function(self)
  CommonDigitalKeyboard.Instance():ShowPanelEx(self.m_maxNum, function(val, tag)
    if self.m_panel and not self.m_panel.isnil then
      if val == self.m_maxNum then
        Toast(textRes.TradingArcade[10])
      elseif val < self.m_minNum then
        Toast(textRes.TradingArcade[11])
        val = self.m_minNum
        CommonDigitalKeyboard.Instance():SetEnteredValue(val)
      end
      self.m_num = val
      self:UpdatePrices()
    end
  end, nil)
  CommonDigitalKeyboard.Instance():SetPos(250, 0)
end
def.method().UpdatePos = function(self)
  local goods = self.m_goods
  local pos
  if goods.type == GoodsData.Type.Item then
    pos = BuyGoodsConfirmPanel.Pos.Left
  elseif goods.type == GoodsData.Type.Pet then
    pos = BuyGoodsConfirmPanel.Pos.Center
  else
    pos = BuyGoodsConfirmPanel.Pos.Center
  end
  self.m_uiGOs.Img_Bg.localPosition = Vector.Vector3.new(pos.x, pos.y, 0)
end
def.method().ShowGoodsTips = function(self)
  local goods = self.m_goods
  if goods.type == GoodsData.Type.Item then
    self:ShowItemTips(goods, true)
  elseif goods.type == GoodsData.Type.Pet and not self.m_firstCall then
    self:ShowPetInfo(goods, true)
  end
  self.m_firstCall = false
end
def.method(GoodsData, "boolean").ShowItemTips = function(self, goods, autoQuery)
  if self.m_uiGOs == nil then
    return
  end
  local itemId = goods.itemId
  local item = goods.itemInfo
  local function getPos()
    local go = self.m_uiGOs.Img_Bg
    local position = go.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    screenPos.x = screenPos.x + 20
    local widget = go:GetComponent("UIWidget")
    return screenPos.x, screenPos.y, widget:get_width(), widget:get_height()
  end
  if item == nil then
    local x, y, w, h = getPos()
    self.itemTip = ItemTipsMgr.Instance():ShowBasicTips(itemId, x, y, w, h, 0, false)
    self.itemTip:SetOperateContext({goods = goods, go = go})
    local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
    if TradingArcadeUtils.NeedQueryItemDetail(itemId) and autoQuery then
      BuyServiceMgr.Instance():QueryGoodsDetail(goods, BuyGoodsConfirmPanel.OnSellGoodsDetailUpdate)
    end
  else
    local x, y, w, h = getPos()
    self.itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.Other, x, y, w, h, 0)
  end
end
def.static("table").OnSellGoodsDetailUpdate = function(goods)
  if goods == nil or instance == nil then
    return
  end
  local self = instance
  if goods.type == GoodsData.Type.Item then
    self:OnSellItemDetailUpdate(goods)
  elseif goods.type == GoodsData.Type.Pet then
    self:OnSellPetDetailUpdate(goods)
  end
end
def.method(GoodsData).OnSellItemDetailUpdate = function(self, goods)
  if goods == nil then
    return
  end
  if self.itemTip == nil or self.itemTip.m_panel == nil or self.itemTip.m_panel.isnil then
    return
  end
  if self.itemTip.context == nil then
    return
  end
  if self.itemTip.context.goods ~= goods then
    return
  end
  self.itemTip:DestroyPanel()
  local autoQuery = false
  self:ShowItemTips(goods, autoQuery)
end
def.method(GoodsData).OnSellPetDetailUpdate = function(self, goods)
  if self.m_uiGOs == nil then
    return
  end
  local autoQuery = false
  self:ShowPetInfo(goods, autoQuery)
end
def.method(GoodsData, "boolean").ShowPetInfo = function(self, goods, autoQuery)
  local PetInfoPanel = require("Main.Pet.ui.PetInfoPanel")
  if goods.petInfo then
    PetInfoPanel.Instance().level = 2
    PetInfoPanel.Instance():ShowPanelByPetInfo(goods.petInfo)
  elseif autoQuery then
    BuyServiceMgr.Instance():QueryGoodsDetail(goods, BuyGoodsConfirmPanel.OnSellGoodsDetailUpdate)
  end
end
return BuyGoodsConfirmPanel.Commit()
