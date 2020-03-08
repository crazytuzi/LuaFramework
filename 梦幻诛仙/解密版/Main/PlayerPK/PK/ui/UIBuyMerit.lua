local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIBuyMerit = Lplus.Extend(ECPanelBase, "UIBuyMerit")
local def = UIBuyMerit.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local PKMgr = require("Main.PlayerPK.PKMgr")
local PKInterface = require("Main.PlayerPK.PK.PKInterface")
local txtConst = textRes.PlayerPK.PK
local const = constant.CPKConsts
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.static("=>", UIBuyMerit).Instance = function()
  if instance == nil then
    instance = UIBuyMerit()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiStatus = {}
  self._uiStatus.bQueriedBoughtMerit = false
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, UIBuyMerit.OnTokenChg, self)
  Event.RegisterEventWithContext(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.BuyMeritResult, UIBuyMerit.OnBuyMeritResult, self)
  Event.RegisterEventWithContext(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.QueryBoughtMeritRes, UIBuyMerit.OnQueryBoughtMeritRes, self)
  PKMgr.GetProtocols().SendQueryBoughtMeritReq()
  self:_initUI()
end
def.method()._initUI = function(self)
  self._uiGOs.lblTitle = self.m_panel:FindDirect("Img_0/Group_Tips/Label_Title")
  self._uiGOs.groupMerit = self.m_panel:FindDirect("Img_0/Group_GongDe")
  self._uiGOs.groupBuyNum = self.m_panel:FindDirect("Img_0/Group_BuyNum")
  self._uiGOs.groupCostNum = self.m_panel:FindDirect("Img_0/Group_CostNum")
  local lblMeritName = self._uiGOs.groupMerit:FindDirect("Label_Name")
  self._uiGOs.lblMeritVal = self._uiGOs.groupMerit:FindDirect("Label_Num")
  local lblBuyName = self._uiGOs.groupBuyNum:FindDirect("Label_Name")
  self._uiGOs.lblBuyVal = self._uiGOs.groupBuyNum:FindDirect("Label_Num")
  self._uiGOs.lblCostName = self._uiGOs.groupCostNum:FindDirect("Label_Name")
  self._uiGOs.lblCostVal = self._uiGOs.groupCostNum:FindDirect("Label_Num")
  self._uiGOs.iconMoney = self._uiGOs.groupCostNum:FindDirect("Sprite")
  GUIUtils.SetText(lblMeritName, txtConst[1])
  GUIUtils.SetText(lblBuyName, txtConst[2])
  GUIUtils.SetText(self._uiGOs.lblBuyVal, txtConst[70])
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  local inputVal = self._uiStatus.inputVal or 0
  if inputVal < 1 then
    GUIUtils.SetText(self._uiGOs.lblBuyVal, txtConst[70])
  else
    GUIUtils.SetText(self._uiGOs.lblBuyVal, self._uiStatus.inputVal or 0)
  end
  local curMerit = Int64.ToNumber(ItemModule.Instance():GetCredits(TokenType.MORAL_VALUE) or Int64.new(0))
  GUIUtils.SetText(self._uiGOs.lblMeritVal, curMerit)
  local curBuyNum = self._uiStatus.inputVal or 0
  local curPrice = self:GetMeritTotalPrice(curBuyNum)
  local needMoney = curPrice
  local moneyData = CurrencyFactory.Create(const.MORAL_VALUE_MONEY_TYPE)
  GUIUtils.SetSprite(self._uiGOs.iconMoney, moneyData:GetSpriteName())
  GUIUtils.SetText(self._uiGOs.lblCostName, txtConst[52]:format(moneyData:GetName()))
  GUIUtils.SetText(self._uiGOs.lblCostVal, needMoney)
end
def.method("number", "=>", "number").GetMeritTotalPrice = function(self, buyNum)
  local tabPriceCfg = PKInterface.LoadBuyMeritPriceCfg()
  local boughtMerit = self._uiStatus.boughtMerit or 0
  local result = 0
  local preThreshold = 0
  local stageBuyNum = 0
  local stage = 1
  for i = 1, #tabPriceCfg do
    local curPriceInfo = tabPriceCfg[i]
    local curThreshhold = curPriceInfo.threshold
    local curPrice = curPriceInfo.price
    if boughtMerit < curThreshhold and boughtMerit >= preThreshold then
      stage = i
      stageBuyNum = boughtMerit - preThreshold
      break
    end
    preThreshold = curThreshhold
  end
  for i = stage, #tabPriceCfg do
    local curPriceInfo = tabPriceCfg[i]
    local curThreshhold = curPriceInfo.threshold
    local curPrice = curPriceInfo.price
    if buyNum <= 0 then
      return result
    end
    local numCanBuy = 0
    if buyNum <= curThreshhold - preThreshold then
      numCanBuy = math.min(buyNum, curThreshhold - preThreshold - stageBuyNum)
    else
      numCanBuy = curThreshhold - preThreshold - stageBuyNum
    end
    buyNum = buyNum - numCanBuy
    result = result + curPrice * numCanBuy
    stageBuyNum = 0
    preThreshold = curThreshhold
  end
  return result
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  self._uiStatus = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, UIBuyMerit.OnTokenChg)
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.BuyMeritResult, UIBuyMerit.OnBuyMeritResult)
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.QueryBoughtMeritRes, UIBuyMerit.OnQueryBoughtMeritRes)
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    self:Show()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_BUYMERIT, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("id", id)
  if id == "Btn_Confirm" then
    self:OnClickConfirm()
  elseif id == "Label_Num" then
    local digitBoard = require("GUI.CommonDigitalKeyboard").Instance()
    digitBoard:ShowPanelEx(1000, UIBuyMerit.OnInputNumberChg, {self = self})
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    GUIUtils.ShowHoverTip(const.MORAL_VALUE_PRICE_TIP_ID, 0, 0)
  end
end
def.method().OnClickConfirm = function(self)
  if self._uiStatus.inputVal == nil then
    Toast(txtConst[32])
  elseif self._uiStatus.inputVal < 1 then
    Toast(txtConst[33])
  else
    local value = ItemModule.Instance():GetCredits(TokenType.MORAL_VALUE) or Int64.new(0)
    self._uiStatus.preMerit = Int64.ToNumber(value)
    local owndMoney = PKInterface.GetMoneyNumByType(const.MORAL_VALUE_MONEY_TYPE)
    PKMgr.GetProtocols().SendBuyMeritReq(self._uiStatus.inputVal, owndMoney)
  end
end
def.static("number", "table").OnInputNumberChg = function(p, tag)
  local self = tag.self
  self._uiStatus.inputVal = p
  if not self._uiStatus.bQueriedBoughtMerit then
    PKMgr.GetProtocols().SendQueryBoughtMeritReq()
    return
  end
  instance:UpdateUI()
end
def.method("table").OnBuyMeritResult = function(self, p)
  if p.ok then
    local diff = p.result - self._uiStatus.preMerit
    Toast(txtConst[36]:format(diff, p.result))
  end
end
def.method("table").OnTokenChg = function(self, p)
  if self._uiStatus.preMerit == nil then
    self:UpdateUI()
    return
  end
  local curMerit = Int64.ToNumber(ItemModule.Instance():GetCredits(TokenType.MORAL_VALUE) or Int64.new(0))
  local diff = curMerit - self._uiStatus.preMerit
  if diff > 0 then
    Toast(txtConst[36]:format(diff, curMerit))
    self:DestroyPanel()
  end
end
def.method("table").OnQueryBoughtMeritRes = function(self, p)
  self._uiStatus.boughtMerit = p.result
  self._uiStatus.bQueriedBoughtMerit = true
end
return UIBuyMerit.Commit()
