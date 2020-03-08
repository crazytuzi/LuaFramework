local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UnsheleveGoodsPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local def = UnsheleveGoodsPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = UnsheleveGoodsPanel()
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
def.field("table").itemTip = nil
def.field("boolean").m_firstCall = false
def.static("table", "=>", UnsheleveGoodsPanel).ShowPanel = function(goods)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
    self = Instance()
  end
  self.m_goods = goods
  self.m_price = goods.price
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_UNSHELEVE_CONFIRM, 2)
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
  elseif id == "Btn_Sell" then
    self:OnUnsheleveClick()
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
end
def.override().AfterCreate = function(self)
  self.m_firstCall = true
  self:ShowGoodsTips()
end
def.override().OnDestroy = function(self)
  self.m_uiGOs = nil
  self.m_goods = nil
  instance = nil
end
def.method().InitUI = function(self)
  self.m_uiGOs = {}
  self.m_uiGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiGOs.Group_Info = self.m_uiGOs.Img_Bg0:FindDirect("Group_Info")
  self.m_uiGOs.Img_BgRightItem = self.m_uiGOs.Group_Info:FindDirect("Img_BgRightItem")
  self.m_uiGOs.Texture_RightIcon = self.m_uiGOs.Img_BgRightItem:FindDirect("Texture_RightIcon")
  self.m_uiGOs.Label_ItemName = self.m_uiGOs.Group_Info:FindDirect("Label_ItemName")
  self.m_uiGOs.Img_BgPrice = self.m_uiGOs.Group_Info:FindDirect("Group_Price/Img_BgPrice")
  self.m_uiGOs.Label_Price = self.m_uiGOs.Img_BgPrice:FindDirect("Label_Price")
  self.m_uiGOs.Label_TimeTypeName = self.m_uiGOs.Group_Info:FindDirect("Group_ShowTime/Label")
  self.m_uiGOs.Label_PublicTime = self.m_uiGOs.Group_Info:FindDirect("Group_ShowTime/Img_Bg/Label_Time")
  self.m_uiGOs.Group_PetInfo = self.m_uiGOs.Group_Info:FindDirect("Group_PetInfo")
  self.m_uiGOs.Label_PetName = self.m_uiGOs.Group_PetInfo:FindDirect("Label_PetName")
  self.m_uiGOs.Label_PetLevel = self.m_uiGOs.Group_PetInfo:FindDirect("Label_PetLevel")
  GUIUtils.SetActive(self.m_uiGOs.Label_PetName, false)
  GUIUtils.SetActive(self.m_uiGOs.Label_PetLevel, false)
end
def.method().UpdateUI = function(self)
  local goods = self.m_goods
  local name = goods:GetName()
  local icon = goods:GetIcon()
  local iconId = icon.iconId
  local bgSpriteName = icon.bgSprite
  local price = self.m_price
  GUIUtils.SetTexture(self.m_uiGOs.Texture_RightIcon, iconId)
  GUIUtils.SetSprite(self.m_uiGOs.Img_BgRightItem, bgSpriteName)
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, price)
  if goods.type == GoodsData.Type.Item then
    GUIUtils.SetActive(self.m_uiGOs.Label_PetName, false)
    GUIUtils.SetActive(self.m_uiGOs.Label_PetLevel, false)
    GUIUtils.SetActive(self.m_uiGOs.Label_ItemName, true)
    GUIUtils.SetText(self.m_uiGOs.Label_ItemName, name)
  elseif goods.type == GoodsData.Type.Pet then
    GUIUtils.SetActive(self.m_uiGOs.Label_PetName, true)
    GUIUtils.SetActive(self.m_uiGOs.Label_PetLevel, true)
    GUIUtils.SetActive(self.m_uiGOs.Label_ItemName, false)
    GUIUtils.SetText(self.m_uiGOs.Label_PetName, name)
    GUIUtils.SetText(self.m_uiGOs.Label_PetLevel, icon.rdText)
  end
  self:UpdatePublicTime()
end
def.method().UpdatePublicTime = function(self)
  local goods = self.m_goods
  local timeTypName = ""
  local remainSeconds = 0
  if goods:IsInState(GoodsData.State.STATE_PUBLIC) then
    remainSeconds = goods:GetPublicRemainTime()
    timeTypName = textRes.TradingArcade[46]
  else
    remainSeconds = goods:GetOnSellRemainTime()
    timeTypName = textRes.TradingArcade[47]
  end
  local t = _G.Seconds2HMSTime(remainSeconds)
  local countDownText = string.format(textRes.TradingArcade[16], t.h, t.m)
  GUIUtils.SetText(self.m_uiGOs.Label_TimeTypeName, timeTypName)
  GUIUtils.SetText(self.m_uiGOs.Label_PublicTime, countDownText)
end
def.method().OnUnsheleveClick = function(self)
  local goods = self.m_goods
  self:DestroyPanel()
  local chargeFeatureOpen = TradingArcadeUtils.IsUnshelveBidGoodsChargeFeatureOpen()
  if not chargeFeatureOpen then
    print("TYPE_MARKET_AUCTION_GOODS_CUT_GOLD not open")
  end
  if chargeFeatureOpen and goods:IsInState(GoodsData.State.STATE_AUCTION) and goods:GetBidRoleNum() > 0 then
    self:ShowChargeUnshelveConfirm(goods)
  else
    self:ShowFreeUnshelveConfirm(goods)
  end
end
def.method(GoodsData).ShowChargeUnshelveConfirm = function(self, goods)
  local totalPrice = goods.price * goods.num
  local chargeNum = SellServiceMgr.Instance():CalcUnshelveBidGoodsCharge(totalPrice)
  local title = textRes.TradingArcade[17]
  local desc = textRes.TradingArcade[87]:format(goods:GetTypeName(), chargeNum)
  require("GUI.CommonConfirmDlg").ShowConfirm(title, desc, function(s)
    if s == 1 then
      local ItemModule = require("Main.Item.ItemModule")
      local haveNum = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetMoney(ItemModule.MONEY_TYPE_GOLD)
      if haveNum:ge(chargeNum) then
        SellServiceMgr.Instance():UnshelveGoodsReq(goods)
      else
        Toast(textRes.TradingArcade[88])
      end
    end
  end, nil)
end
def.method(GoodsData).ShowFreeUnshelveConfirm = function(self, goods)
  local title = textRes.TradingArcade[17]
  local desc = textRes.TradingArcade[18]
  require("GUI.CommonConfirmDlg").ShowConfirm(title, desc, function(s)
    if s == 1 then
      SellServiceMgr.Instance():UnshelveGoodsReq(goods)
    end
  end, nil)
end
def.method().UpdatePos = function(self)
  local goods = self.m_goods
  local pos
  if goods.type == GoodsData.Type.Item then
    pos = UnsheleveGoodsPanel.Pos.Left
  elseif goods.type == GoodsData.Type.Pet then
    pos = UnsheleveGoodsPanel.Pos.Center
  else
    pos = UnsheleveGoodsPanel.Pos.Center
  end
  self.m_uiGOs.Img_Bg0.localPosition = Vector.Vector3.new(pos.x, pos.y, 0)
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
    local go = self.m_uiGOs.Img_Bg0
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
    if TradingArcadeUtils.NeedQueryItemDetail(itemId) and autoQuery then
      SellServiceMgr.Instance():QueryGoodsDetail(goods, UnsheleveGoodsPanel.OnSellGoodsDetailUpdate)
    end
  else
    local x, y, w, h = getPos()
    self.itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.Other, x, y, w, h, 0)
  end
end
def.static("table").OnSellGoodsDetailUpdate = function(goods)
  if goods == nil then
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
    SellServiceMgr.Instance():QueryGoodsDetail(goods, UnsheleveGoodsPanel.OnSellGoodsDetailUpdate)
  end
end
return UnsheleveGoodsPanel.Commit()
