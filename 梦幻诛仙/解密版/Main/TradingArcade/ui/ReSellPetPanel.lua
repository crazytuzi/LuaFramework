local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SellPetPanelBase = import(".SellPetPanelBase")
local ReSellPetPanel = Lplus.Extend(SellPetPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = require("Main.Pet.data.PetData")
local def = ReSellPetPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = ReSellPetPanel()
  end
  return instance
end
def.field("table").m_goods = nil
def.field("number").m_originalPrice = 0
def.static("table", "table").ShowPanel = function(goods, context)
  local function show()
    local self = Instance()
    if self.m_panel and not self.m_panel.isnil then
      self:DestroyPanel()
      self = Instance()
    end
    self.m_goods = goods
    self.m_pet = PetData()
    self.m_pet:RawSet(goods.petInfo)
    self.m_price = goods.price
    self.m_originalPrice = self.m_price
    self:QueryPetPrices(goods.petCfgId)
    self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_SELL_PET, 2)
    self:SetModal(true)
  end
  if goods.petInfo == nil then
    SellServiceMgr.Instance():QueryGoodsDetail(goods, function(params)
      if goods == nil then
        return
      end
      if context.uiObjs == nil then
        return
      end
      if goods.petInfo == nil then
        return
      end
      show()
    end)
  else
    show()
  end
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  SellPetPanelBase.OnCreate(self)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_goods = nil
  instance = nil
  SellPetPanelBase.OnDestroy(self)
end
def.override().InitUI = function(self)
  SellPetPanelBase.InitUI(self)
  local Btn_Cancel = self.m_uiGOs.Group_Info:FindDirect("Btn_Cancel")
  GUIUtils.SetText(Btn_Cancel:FindDirect("Label"), textRes.TradingArcade[37])
  local Btn_Sell = self.m_uiGOs.Group_Info:FindDirect("Btn_Sell")
  GUIUtils.SetText(Btn_Sell:FindDirect("Label"), textRes.TradingArcade[36])
end
def.override().UpdatePublicTime = function(self)
  local hour, minute = 0, 0
  local text = ""
  if self.m_price == self.m_originalPrice then
    hour = 0
    text = string.format(textRes.TradingArcade[16], hour, minute)
  else
    local remainMinute = TradingArcadeUtils.GetCurrentPublicTime()
    hour = require("Common.MathHelper").Floor(remainMinute / 60)
    minute = remainMinute % 60
    text = string.format(textRes.TradingArcade[16], hour, minute)
    text = string.format("[ff0000]%s[-]", text)
  end
  GUIUtils.SetText(self.m_uiGOs.Label_Time, text)
end
def.override().UpdatePrices = function(self)
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, self.m_price)
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
  SellServiceMgr.Instance():ReSellPet(self.m_goods, self.m_price)
  self:DestroyPanel()
end
return ReSellPetPanel.Commit()
