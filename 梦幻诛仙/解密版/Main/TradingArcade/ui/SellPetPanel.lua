local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SellPetPanelBase = import(".SellPetPanelBase")
local SellPetPanel = Lplus.Extend(SellPetPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = require("Main.Pet.data.PetData")
local def = SellPetPanel.define
local instance
local function Instance()
  if instance == nil then
    instance = SellPetPanel()
  end
  return instance
end
def.static("table", "=>", SellPetPanel).ShowPanel = function(pet)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
    self = Instance()
  end
  self.m_pet = pet
  self:QueryPetPrices(pet.typeId)
  self:CreatePanel(RESPATH.PREFAB_TRADING_ARCADE_SELL_PET, 2)
  self:SetModal(true)
  return self
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  SellPetPanelBase.OnCreate(self)
  self.m_price = self.m_minPrice
  self:UpdateUI()
  self:LightingPriceLabel()
end
def.override().OnDestroy = function(self)
  instance = nil
  SellPetPanelBase.OnDestroy(self)
end
def.override().OnCancelBtnClick = function(self)
  self:DestroyPanel()
end
def.override().OnSellBtnClick = function(self)
  if TradingArcadeUtils.IsPetFrozen(self.m_pet) then
    local unfreezeTime = TradingArcadeUtils.GetPetUnfreezeTime(self.m_pet)
    local curTime = _G.GetServerTime()
    local remainSeconds = unfreezeTime - curTime
    local timeText = _G.SeondsToTimeText(remainSeconds)
    Toast(string.format(textRes.TradingArcade[34], timeText))
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
  SellServiceMgr.Instance():SellPet(self.m_pet, self.m_price)
  self:DestroyPanel()
end
return SellPetPanel.Commit()
