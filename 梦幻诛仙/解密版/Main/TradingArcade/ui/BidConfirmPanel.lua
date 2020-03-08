local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BidConfirmPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local BidMgr = require("Main.TradingArcade.BidMgr")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local Vector = require("Types.Vector")
local def = BidConfirmPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = BidConfirmPanel()
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
def.field("number").m_minPrice = 0
def.field("number").m_maxPrice = 0
def.field("number").m_num = 0
def.field("number").m_minNum = 1
def.field("number").m_maxNum = 0
def.field("table").itemTip = nil
def.field("boolean").m_firstCall = false
def.static("table", "number", "=>", BidConfirmPanel).ShowPanel = function(goods, expectedNum)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
    self = Instance()
  end
  self.m_goods = goods
  self.m_maxNum = goods.num
  self.m_minNum = self.m_maxNum
  self.m_num = math.min(expectedNum, self.m_maxNum)
  self.m_num = math.max(self.m_num, self.m_minNum)
  self.m_minPrice = BidMgr.Instance():CalcMinBidPrice(goods.price)
  local priceBound = goods:GetSellPriceBoundCfg()
  self.m_maxPrice = priceBound.max
  self.m_minPrice = math.min(self.m_minPrice, self.m_maxPrice)
  self.m_price = self.m_minPrice
  BuyServiceMgr.Instance():QueryGoodsDetail(goods, BidConfirmPanel.OnPreQueryGoodsDetail)
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_BID_CONFIRM, 2)
  self:SetModal(true)
  return self
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Sprite" and obj.parent.name == "Label_BidNumber" then
    self:OnPriceLabelClick()
  else
    self:onClick(id)
  end
end
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
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnBuyBtnClick()
  elseif id == "Label_BidNumber" then
    self:OnPriceLabelClick()
  elseif id == "Img_Kuang" then
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
  self.m_uiGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiGOs.Img_ItemBg = self.m_uiGOs.Img_Bg:FindDirect("Img_ItemBg")
  self.m_uiGOs.Img_Item = self.m_uiGOs.Img_ItemBg:FindDirect("Img_Kuang")
  self.m_uiGOs.Texture_RightIcon = self.m_uiGOs.Img_Item:FindDirect("Texture")
  self.m_uiGOs.Label_Name = self.m_uiGOs.Img_ItemBg:FindDirect("Label_ItemName")
  self.m_uiGOs.Label_Price = self.m_uiGOs.Img_Bg:FindDirect("Label_BidNumber")
  self.m_uiGOs.Label_AllPrice = self.m_uiGOs.Img_Bg:FindDirect("Label_TotaNumber")
  self.m_uiGOs.Label_Num = self.m_uiGOs.Img_Bg:FindDirect("Label_Number")
  local uiLabel = self.m_uiGOs.Label_Price:GetComponent("UILabel")
  if uiLabel then
    GameUtil.AddGlobalTimer(0, true, function(...)
      GameUtil.AddGlobalTimer(0, true, function(...)
        if uiLabel.isnil then
          return
        end
        uiLabel:set_supportEncoding(true)
      end)
    end)
  end
  self:AdjustLabelDepth(self.m_uiGOs.Label_Price)
  self:AdjustLabelDepth(self.m_uiGOs.Label_AllPrice)
  self:AddBoxCollider(self.m_uiGOs.Img_Bg)
  self:AddBoxCollider(self.m_uiGOs.Img_Item)
  self:AddBoxCollider(self.m_uiGOs.Label_Price)
end
def.method("userdata").AdjustLabelDepth = function(self, obj)
  local childSprite = obj:FindDirect("Sprite")
  if childSprite then
    local uiWidget = childSprite:GetComponent("UIWidget")
    if uiWidget then
      obj:GetComponent("UIWidget").depth = uiWidget.depth + 1
    end
  end
end
def.method("userdata").AddBoxCollider = function(self, obj)
  local boxCollider = obj:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = obj:AddComponent("BoxCollider")
    local uiWidget = obj:GetComponent("UIWidget")
    uiWidget.autoResizeBoxCollider = true
    uiWidget:ResizeCollider()
    self.m_msgHandler:Touch(obj)
  end
end
def.method().UpdateUI = function(self)
  local goods = self.m_goods
  local name = goods:GetName()
  local icon = goods:GetIcon()
  local iconId = icon.iconId
  local bgSpriteName = icon.bgSprite
  GUIUtils.SetText(self.m_uiGOs.Label_Name, name)
  GUIUtils.SetTexture(self.m_uiGOs.Texture_RightIcon, iconId)
  self:UpdatePrices()
end
def.method().UpdateNum = function(self)
  local num = self.m_num
  GUIUtils.SetText(self.m_uiGOs.Label_Num, num)
end
def.method().UpdatePrices = function(self)
  self:UpdateNum()
  local price = self.m_price
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, price)
  local totalPrice = self:GetTotalPrice()
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_AllPrice, totalPrice)
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
  if nextNum < self.m_minNum then
    Toast(textRes.TradingArcade[11])
    return
  end
  self.m_num = nextNum
  self:UpdatePrices()
end
def.method().OnBuyBtnClick = function(self)
  if self.m_goods.price == self.m_maxPrice then
    Toast(textRes.TradingArcade[86])
    return
  end
  if self.m_price < self.m_minPrice then
    Toast(string.format(textRes.TradingArcade[76], self.m_minPrice))
    return
  end
  if self.m_price > self.m_maxPrice then
    Toast(string.format(textRes.TradingArcade[77], self.m_minPrice))
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local totalPrice = self:GetTotalPrice()
  totalPrice = Int64.new(totalPrice)
  local haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
  if totalPrice > haveNum then
    _G.GoToBuyGoldIngot(true)
    return
  end
  BidMgr.Instance():BidOnGoods(self.m_goods, self.m_price)
  self:DestroyPanel()
end
def.method().OnPriceLabelClick = function(self)
  CommonDigitalKeyboard.Instance():SetEnteredValue(self.m_price)
  CommonDigitalKeyboard.Instance():ShowPanelEx(self.m_maxPrice, function(val, tag)
    if self.m_panel and not self.m_panel.isnil then
      if val == self.m_maxPrice then
        Toast(string.format(textRes.TradingArcade[77], self.m_maxPrice))
      elseif val < 0 then
        val = 0
        CommonDigitalKeyboard.Instance():SetEnteredValue(val)
      end
      self.m_price = val
      self:UpdatePrices()
    end
  end, nil)
  CommonDigitalKeyboard.Instance():SetPos(250, 0)
end
def.method().UpdatePos = function(self)
  local goods = self.m_goods
  local pos
  if goods.type == GoodsData.Type.Item then
    pos = BidConfirmPanel.Pos.Left
  elseif goods.type == GoodsData.Type.Pet then
    pos = BidConfirmPanel.Pos.Center
  else
    pos = BidConfirmPanel.Pos.Center
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
      BuyServiceMgr.Instance():QueryGoodsDetail(goods, BidConfirmPanel.OnSellGoodsDetailUpdate)
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
    BuyServiceMgr.Instance():QueryGoodsDetail(goods, BidConfirmPanel.OnSellGoodsDetailUpdate)
  end
end
def.method("table").OnPreQueryPetDetail = function(self, goods)
  if goods.petInfo == nil then
    return
  end
  local PetData = require("Main.Pet.data.PetData")
  local petData = PetData()
  petData:RawSet(goods.petInfo)
  local onSellMaxPrice = TradingArcadeUtils.GetPetOnSellMaxPrice(petData)
  self.m_minPrice = math.min(self.m_minPrice, onSellMaxPrice)
  self.m_maxPrice = onSellMaxPrice
  if self.m_price > self.m_maxPrice then
    self.m_price = self.m_maxPrice
    if self:IsShow() then
      self:UpdatePrices()
    end
  end
end
def.method("table").OnPreQueryItemDetail = function(self, goods)
  local itemInfo = goods.itemInfo
  if itemInfo == nil then
    return
  end
  local maxprice = TradingArcadeUtils.GetItemOnSellMaxPrice(itemInfo)
  if maxprice ~= self.m_maxPrice then
    local minprice = BidMgr.Instance():CalcMinBidPrice(goods.price)
    self.m_minPrice = math.min(minprice, maxprice)
    self.m_maxPrice = maxprice
    self.m_price = require("Common.MathHelper").Clamp(self.m_price, self.m_minPrice, self.m_maxPrice)
    if self:IsShow() then
      self:UpdatePrices()
    end
  end
end
def.static("table").OnPreQueryGoodsDetail = function(goods)
  if goods == nil or instance == nil then
    return
  end
  local self = instance
  if self.m_goods == nil then
    return
  end
  if goods.type == GoodsData.Type.Pet then
    self:OnPreQueryPetDetail(goods)
  elseif goods.type == GoodsData.Type.Item then
    self:OnPreQueryItemDetail(goods)
  end
end
return BidConfirmPanel.Commit()
