local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceBuyItemPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceBuyItemPanel.define
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local CurrencyBase = require("Main.Currency.CurrencyBase")
def.field("table").m_UIGOs = nil
def.field("table").m_params = nil
def.field("number").m_defaultNum = 1
def.field("number").m_maxNum = 99
def.field("number").m_minNum = 1
def.field("number").m_buyNum = 0
def.field(CurrencyBase).m_currency = nil
def.field("function").m_onBuyFunc = nil
def.field("table").m_context = nil
def.field("function").m_onCurrencyChanged = nil
def.static("table", "function", "table", "=>", SpaceBuyItemPanel).ShowPanel = function(params, onBuyFunc, context)
  local self = SpaceBuyItemPanel()
  self.m_params = params
  self.m_onBuyFunc = onBuyFunc
  self.m_context = context
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_BUY_CHEST_PANEL, 0)
  return self
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_currency:UnregisterCurrencyChangedEvent(self.m_onCurrencyChanged)
  self.m_UIGOs = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Plus" and obj.parent.name == "Group_CurNum" then
    self.m_currency:Acquire()
  elseif id == "Btn_Plus" then
    self:OnClickIncBtn()
  elseif id == "Btn_Reduce" then
    self:OnClickDecBtn()
  elseif id == "Btn_Buy" then
    self:OnClickBuyBtn()
  end
end
def.method().InitData = function(self)
  self.m_currency = CurrencyFactory.Create(self.m_params.moneyType)
  self.m_buyNum = self.m_params.defaultNum or self.m_defaultNum
  self.m_maxNum = self.m_params.maxNum or self.m_maxNum
  local function onCurrencyChanged()
    self:UpdatePriceInfo()
  end
  self.m_onCurrencyChanged = onCurrencyChanged
  self.m_currency:RegisterCurrencyChangedEvent(self.m_onCurrencyChanged)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_0 = self.m_panel:FindDirect("Img_0")
  self.m_UIGOs.Label_Title = self.m_UIGOs.Img_0:FindDirect("Label_Title")
  self.m_UIGOs.Img_Chest = self.m_UIGOs.Img_0:FindDirect("Img_Chest")
  self.m_UIGOs.Group_Info = self.m_UIGOs.Img_0:FindDirect("Group_Info")
end
def.method().UpdateUI = function(self)
  self:UpdateDesc()
  self:UpdateItemInfo()
  self:UpdateCurrencyType()
  self:UpdatePriceInfo()
end
def.method().UpdateDesc = function(self)
  GUIUtils.SetText(self.m_UIGOs.Label_Title, self.m_params.desc)
end
def.method().UpdateItemInfo = function(self)
  GUIUtils.SetTexture(self.m_UIGOs.Img_Chest, self.m_params.iconId)
end
def.method().UpdateCurrencyType = function(self)
  local Group_CostNum = self.m_UIGOs.Group_Info:FindDirect("Group_CostNum")
  local Group_CurNum = self.m_UIGOs.Group_Info:FindDirect("Group_CurNum")
  local Img_CostIcon = Group_CostNum:FindDirect("Img_Icon")
  local Img_HaveIcon = Group_CurNum:FindDirect("Img_Icon")
  local spriteName = self.m_currency:GetSpriteName()
  GUIUtils.SetSprite(Img_CostIcon, spriteName)
  GUIUtils.SetSprite(Img_HaveIcon, spriteName)
end
def.method().UpdatePriceInfo = function(self)
  local Group_BuyNum = self.m_UIGOs.Group_Info:FindDirect("Group_BuyNum")
  local Group_CostNum = self.m_UIGOs.Group_Info:FindDirect("Group_CostNum")
  local Group_CurNum = self.m_UIGOs.Group_Info:FindDirect("Group_CurNum")
  local Label_BuyNum = Group_BuyNum:FindDirect("Label_Num")
  local Label_CostNum = Group_CostNum:FindDirect("Label_Num")
  local Label_HaveNum = Group_CurNum:FindDirect("Label_Num")
  GUIUtils.SetText(Label_BuyNum, self.m_buyNum)
  local costNum = self.m_buyNum * self.m_params.price
  GUIUtils.SetText(Label_CostNum, costNum)
  local haveNum = self.m_currency:GetHaveNum()
  GUIUtils.SetText(Label_HaveNum, tostring(haveNum))
  if haveNum:ge(costNum) then
    GUIUtils.SetTextColor(Label_HaveNum, Color.white, GUIUtils.COTYPE.LABEL)
  else
    GUIUtils.SetTextColor(Label_HaveNum, Color.red, GUIUtils.COTYPE.LABEL)
  end
end
def.method().OnClickIncBtn = function(self)
  if self.m_buyNum < self.m_maxNum then
    self.m_buyNum = self.m_buyNum + 1
    self:UpdatePriceInfo()
  else
    Toast(textRes.TradingArcade[10])
  end
end
def.method().OnClickDecBtn = function(self)
  if self.m_buyNum > self.m_minNum then
    self.m_buyNum = self.m_buyNum - 1
    self:UpdatePriceInfo()
  else
    Toast(textRes.TradingArcade[11])
  end
end
def.method().OnClickBuyBtn = function(self)
  if self.m_onBuyFunc == nil then
    return
  end
  local costNum = self.m_buyNum * self.m_params.price
  local haveNum = self.m_currency:GetHaveNum()
  if haveNum:lt(costNum) then
    self.m_currency:AcquireWithQuery()
    return
  end
  local closePanel = self.m_onBuyFunc(self.m_context, self.m_buyNum)
  if closePanel then
    self:DestroyPanel()
  end
end
return SpaceBuyItemPanel.Commit()
