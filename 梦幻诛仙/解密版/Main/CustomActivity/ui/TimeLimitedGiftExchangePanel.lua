local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TimeLimitedGiftExchangePanel = Lplus.Extend(ECPanelBase, "TimeLimitedGiftExchangePanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = TimeLimitedGiftExchangePanel.define
def.const("number").MAX_BUY_NUM = 999
local instance
def.field("table").uiObjs = nil
def.field("table").giftBag = nil
def.field("number").exchangePrice = 0
def.field("number").availableCount = 0
def.field("function").callback = nil
def.field("number").chooseBuyNum = 1
def.field("table").currencyData = nil
def.static("=>", TimeLimitedGiftExchangePanel).Instance = function()
  if instance == nil then
    instance = TimeLimitedGiftExchangePanel()
  end
  return instance
end
def.method("table", "function").ShowGiftBuyPanel = function(self, giftBag, callback)
  if giftBag == nil then
    return
  end
  self.giftBag = giftBag
  self.callback = callback
  self.availableCount = giftBag.remainPurchaseTimes
  self.exchangePrice = giftBag.currentPrice
  self:CreatePanel(RESPATH.PREFAB_PRIZE_LIMIT_GIFT_BAG_EXCHANGE, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  self.currencyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  self.currencyData:RegisterCurrencyChangedEvent(TimeLimitedGiftExchangePanel.OnMoneyUpdate)
  self:InitUI()
  self:InitBasicExchangeInfo()
  self:SetChooseNumAndNeedMoney()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.giftBag = nil
  self.exchangePrice = 0
  self.availableCount = 0
  self.callback = nil
  self.chooseBuyNum = 1
  if self.currencyData then
    self.currencyData:UnregisterCurrencyChangedEvent(TimeLimitedGiftExchangePanel.OnMoneyUpdate)
  end
  self.currencyData = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_0 = self.m_panel:FindDirect("Img_0")
  self.uiObjs.Label_Name = self.uiObjs.Img_0:FindDirect("Group_Name/Label_Name")
  self.uiObjs.Group_Icon = self.uiObjs.Img_0:FindDirect("Group_Icon")
  self.uiObjs.Group_Money = self.uiObjs.Img_0:FindDirect("Group_Money")
  self.uiObjs.Group_Info = self.uiObjs.Img_0:FindDirect("Group_Info")
end
def.method().InitBasicExchangeInfo = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Name, self.giftBag.name)
  local Label_Pre = self.uiObjs.Group_Money:FindDirect("Group_Ori/Label_Num")
  local Label_Cur = self.uiObjs.Group_Money:FindDirect("Group_Cur/Label_Num")
  GUIUtils.SetText(Label_Pre, self.giftBag.originalPrice)
  GUIUtils.SetText(Label_Cur, self.giftBag.currentPrice)
  local MAX_ICON_NUM = 4
  for i = 1, MAX_ICON_NUM do
    local giftObj = self.uiObjs.Group_Icon:FindDirect("Img_BgIcon" .. i)
    local giftInfo = self.giftBag.gifts[i]
    self:SetGiftInfo(giftObj, giftInfo, nil)
  end
end
def.method("userdata", "table", "table").SetGiftInfo = function(self, giftObj, giftInfo, params)
  if giftInfo == nil then
    GUIUtils.SetActive(giftObj, false)
    return
  end
  GUIUtils.SetActive(giftObj, true)
  local Texture_Icon = giftObj:FindDirect("Texture_Icon")
  local Label_Num = giftObj:FindDirect("Label_Num")
  GUIUtils.SetTexture(Texture_Icon, giftInfo.iconId)
  GUIUtils.SetText(Label_Num, giftInfo.num)
  local namecolor = 0
  local itemBase = ItemUtils.GetItemBase(giftInfo.itemId)
  if itemBase then
    namecolor = itemBase.namecolor
  end
  GUIUtils.SetItemCellSprite(giftObj, namecolor)
end
def.method().SetChooseNumAndNeedMoney = function(self)
  local Group_BuyNum = self.uiObjs.Group_Info:FindDirect("Group_BuyNum")
  local Label_Num = Group_BuyNum:FindDirect("Label_Num")
  GUIUtils.SetText(Label_Num, string.format("%d/%d", self.chooseBuyNum, self.availableCount))
  local totalNeedNum = self.exchangePrice * self.chooseBuyNum
  local Group_CostNum = self.uiObjs.Group_Info:FindDirect("Group_CostNum")
  local Label_MoneyNum = Group_CostNum:FindDirect("Label_Num")
  if totalNeedNum == 0 then
    GUIUtils.SetText(Label_MoneyNum, textRes.TokenMall[20])
  else
    GUIUtils.SetText(Label_MoneyNum, totalNeedNum)
  end
  local Group_CurNum = self.uiObjs.Group_Info:FindDirect("Group_CurNum")
  local haveMoney = Group_CurNum:FindDirect("Label_Num")
  local moneyData = self.currencyData
  if Int64.lt(moneyData:GetHaveNum(), totalNeedNum) then
    GUIUtils.SetText(haveMoney, string.format("[ff0000]%s[-]", moneyData:GetHaveNum():tostring()))
  else
    GUIUtils.SetText(haveMoney, moneyData:GetHaveNum():tostring())
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "Img_BgIcon") then
    self:OnImgBgIconClick(obj)
  else
    self:onClick(id)
  end
end
def.method("userdata").OnImgBgIconClick = function(self, obj)
  local id = obj.name
  local giftIndex = tonumber(string.sub(id, #"Img_BgIcon" + 1, -1))
  if giftIndex == nil then
    return
  end
  local gift = self.giftBag.gifts[giftIndex]
  local itemId = gift.itemId
  if itemId == nil then
    return
  end
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, obj, 0, false)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_NumReduce" then
    self:OnClickBtnMinus()
  elseif id == "Btn_NumPlus" then
    self:OnClickBtnAdd()
  elseif id == "Btn_Max" then
    self:OnClickBtnMax()
  elseif id == "Btn_Buy" then
    self:OnClickBtnBuy()
  elseif id == "Img_InputNum" then
    self:OnClickNumberInput()
  elseif id == "Btn_MoneyPlus" then
    self:OnClickBuyYuanBao()
  end
end
def.method().OnClickBtnMinus = function(self)
  if self.chooseBuyNum <= 1 then
    Toast(textRes.customActivity[203])
  end
  self.chooseBuyNum = math.max(1, self.chooseBuyNum - 1)
  self:SetChooseNumAndNeedMoney()
end
def.method().OnClickBtnAdd = function(self)
  if self.chooseBuyNum >= self.availableCount then
    Toast(string.format(textRes.customActivity[202], self.availableCount))
  end
  self.chooseBuyNum = math.min(self.availableCount, self.chooseBuyNum + 1)
  self:SetChooseNumAndNeedMoney()
end
def.method().OnClickBtnMax = function(self)
  self.chooseBuyNum = self.availableCount
  self:SetChooseNumAndNeedMoney()
end
def.method().OnClickBtnBuy = function(self)
  if self.callback ~= nil then
    local ret = self.callback(self.chooseBuyNum)
    if ret ~= false then
      self:DestroyPanel()
    end
  else
    self:DestroyPanel()
  end
end
def.method().OnClickNumberInput = function(self)
  local NumberPad = require("GUI.CommonDigitalKeyboard")
  NumberPad.Instance():ShowPanelEx(self.availableCount, function(num)
    if num < 1 then
      Toast(textRes.customActivity[203])
      self.chooseBuyNum = 1
    elseif num >= self.availableCount then
      Toast(string.format(textRes.customActivity[202], self.availableCount))
      self.chooseBuyNum = self.availableCount
    else
      self.chooseBuyNum = num
    end
    self:SetChooseNumAndNeedMoney()
  end, nil)
  NumberPad.Instance():SetPos(275, 0)
end
def.method().OnClickBuyYuanBao = function(self)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
end
def.static("table", "table").OnMoneyUpdate = function()
  local self = instance
  self:SetChooseNumAndNeedMoney()
end
TimeLimitedGiftExchangePanel.Commit()
return TimeLimitedGiftExchangePanel
