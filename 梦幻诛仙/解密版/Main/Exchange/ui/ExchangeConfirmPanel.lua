local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ExchangeConfirmPanel = Lplus.Extend(ECPanelBase, "ExchangeConfirmPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = ExchangeConfirmPanel.define
def.const("number").MAX_BUY_NUM = 999
local instance
def.field("table").uiObjs = nil
def.field("number").exchangeItemId = 0
def.field("number").exchangeItemNum = 0
def.field("number").currencyIconId = 0
def.field("string").currencySprite = ""
def.field("number").exchangePrice = 0
def.field("number").availableCount = 0
def.field("function").callback = nil
def.field("number").chooseBuyNum = 1
def.static("=>", ExchangeConfirmPanel).Instance = function()
  if instance == nil then
    instance = ExchangeConfirmPanel()
  end
  return instance
end
def.method("number", "number", "number", "number", "number", "function").ShowPanelWithCurrenyIconId = function(self, exchangeItemId, exchangeItemNum, currencyIconId, exchangePrice, availableCount, callback)
  if self.m_panel ~= nil then
    return
  end
  self.exchangeItemId = exchangeItemId
  self.exchangeItemNum = exchangeItemNum
  self.currencyIconId = currencyIconId
  self.exchangePrice = exchangePrice
  self.availableCount = availableCount > 0 and math.min(availableCount, ExchangeConfirmPanel.MAX_BUY_NUM) or ExchangeConfirmPanel.MAX_BUY_NUM
  self.callback = callback
  self:CreatePanel(RESPATH.PREFAB_COMMON_EXCHANGE_CONFIRM_PANEL, 2)
  self:SetModal(true)
end
def.method("number", "number", "string", "number", "number", "function").ShowPanelWithCurrenySprite = function(self, exchangeItemId, exchangeItemNum, currencySprite, exchangePrice, availableCount, callback)
  if self.m_panel ~= nil then
    return
  end
  self.exchangeItemId = exchangeItemId
  self.exchangeItemNum = exchangeItemNum
  self.currencySprite = currencySprite
  self.exchangePrice = exchangePrice
  self.availableCount = availableCount > 0 and math.min(availableCount, ExchangeConfirmPanel.MAX_BUY_NUM) or ExchangeConfirmPanel.MAX_BUY_NUM
  self.callback = callback
  self:CreatePanel(RESPATH.PREFAB_COMMON_EXCHANGE_CONFIRM_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitBasicExchangeInfo()
  self:SetChooseNumAndNeedMoney()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.exchangeItemId = 0
  self.exchangeItemNum = 0
  self.currencyIconId = 0
  self.currencySprite = ""
  self.exchangePrice = 0
  self.availableCount = 0
  self.callback = nil
  self.chooseBuyNum = 1
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
end
def.method().InitBasicExchangeInfo = function(self)
  local Img_BgRightItem = self.uiObjs.Group_Right:FindDirect("Img_BgRightItem")
  local Texture_RightIcon = Img_BgRightItem:FindDirect("Texture_RightIcon")
  local Label_Num = Img_BgRightItem:FindDirect("Label_Num")
  local Label_RightName = self.uiObjs.Group_Right:FindDirect("Label_RightName")
  local Label_LvTitle = self.uiObjs.Group_Right:FindDirect("Label_LvTitle")
  local Label_Lv = self.uiObjs.Group_Right:FindDirect("Label_Lv")
  local Label_Type = self.uiObjs.Group_Right:FindDirect("Label_Type")
  local Label_Describe = self.uiObjs.Group_Right:FindDirect("Img_BgDescribe/Scroll View/Label_Describe")
  local Label_Buy = self.uiObjs.Group_Right:FindDirect("Btn_Buy/Label")
  if self.currencyIconId == require("Main.activity.JiuZhouFuDai.data.FuDaiData").Instance():GetCreditIconId() then
    GUIUtils.SetText(Label_Buy, textRes.JiuZhouFuDai[12])
  end
  local itemInfo = ItemUtils.GetItemBase(self.exchangeItemId)
  if itemInfo == nil then
    return
  end
  GUIUtils.SetActive(Label_LvTitle, true)
  GUIUtils.SetActive(Label_Lv, true)
  GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemInfo.icon)
  GUIUtils.SetText(Label_Num, self.exchangeItemNum)
  GUIUtils.SetText(Label_RightName, itemInfo.name)
  GUIUtils.SetText(Label_Type, itemInfo.itemTypeName)
  GUIUtils.SetText(Label_Lv, itemInfo.useLevel)
  Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.TokenMall[19], string.gsub(itemInfo.desc, "\\n", "<br/>")))
  local Group_Price = self.uiObjs.Group_Right:FindDirect("Group_Price")
  local Label_Price = Group_Price:FindDirect("Label_Price")
  if self.exchangePrice == 0 then
    GUIUtils.SetText(Label_Price, textRes.TokenMall[20])
  else
    GUIUtils.SetText(Label_Price, self.exchangePrice)
  end
  local Img_Money = Group_Price:FindDirect("Img_Money")
  local Texture_Money = Group_Price:FindDirect("Texture_Money")
  local Btn_Buy = self.uiObjs.Group_Right:FindDirect("Btn_Buy")
  local Img_BgNum = Btn_Buy:FindDirect("Img_BgNum")
  local Texture_BgNum = Btn_Buy:FindDirect("Texture_BgNum")
  if self.currencyIconId ~= 0 then
    GUIUtils.SetActive(Img_Money, false)
    GUIUtils.SetActive(Texture_Money, true)
    GUIUtils.SetActive(Img_BgNum, false)
    GUIUtils.SetActive(Texture_BgNum, true)
    GUIUtils.SetTexture(Texture_Money, self.currencyIconId)
    GUIUtils.SetTexture(Texture_BgNum, self.currencyIconId)
  else
    GUIUtils.SetActive(Img_Money, true)
    GUIUtils.SetActive(Texture_Money, false)
    GUIUtils.SetActive(Img_BgNum, true)
    GUIUtils.SetActive(Texture_BgNum, false)
    GUIUtils.SetSprite(Img_Money, self.currencySprite)
    GUIUtils.SetSprite(Img_BgNum, self.currencySprite)
  end
  local Group_Num = self.uiObjs.Group_Right:FindDirect("Group_Num")
  local Btn_Max = Group_Num:FindDirect("Btn_Max")
  if self.availableCount >= ExchangeConfirmPanel.MAX_BUY_NUM then
    GUIUtils.SetActive(Btn_Max, false)
  else
    GUIUtils.SetActive(Btn_Max, true)
  end
end
def.method().SetChooseNumAndNeedMoney = function(self)
  local Group_Num = self.uiObjs.Group_Right:FindDirect("Group_Num")
  local Label_Num = Group_Num:FindDirect("Img_BgNum/Label_Num")
  if self.availableCount >= ExchangeConfirmPanel.MAX_BUY_NUM then
    GUIUtils.SetText(Label_Num, self.chooseBuyNum)
  else
    GUIUtils.SetText(Label_Num, string.format("%d/%d", self.chooseBuyNum, self.availableCount))
  end
  local totalNeedNum = self.exchangePrice * self.chooseBuyNum
  local Btn_Buy = self.uiObjs.Group_Right:FindDirect("Btn_Buy")
  local Label_MoneyNum = Btn_Buy:FindDirect("Label_MoneyNum")
  if totalNeedNum == 0 then
    GUIUtils.SetText(Label_MoneyNum, textRes.TokenMall[20])
  else
    GUIUtils.SetText(Label_MoneyNum, totalNeedNum)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Texture_RightIcon" then
    self:OnClickAwardIcon(obj)
  else
    self:onClick(id)
  end
end
def.method("userdata").OnClickAwardIcon = function(self, source)
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.exchangeItemId, source, 0, false)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Minus" then
    self:OnClickBtnMinus()
  elseif id == "Btn_Add" then
    self:OnClickBtnAdd()
  elseif id == "Btn_Max" then
    self:OnClickBtnMax()
  elseif id == "Btn_Buy" then
    self:OnClickBtnBuy()
  elseif id == "Img_BgNum" then
    self:OnClickNumberInput()
  end
end
def.method().OnClickBtnMinus = function(self)
  if self.chooseBuyNum <= 1 then
    Toast(textRes.Exchange[9])
  end
  self.chooseBuyNum = math.max(1, self.chooseBuyNum - 1)
  self:SetChooseNumAndNeedMoney()
end
def.method().OnClickBtnAdd = function(self)
  if self.chooseBuyNum >= self.availableCount then
    Toast(string.format(textRes.Exchange[8], self.availableCount))
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
      Toast(textRes.Exchange[9])
      self.chooseBuyNum = 1
    elseif num >= self.availableCount then
      Toast(string.format(textRes.Exchange[8], self.availableCount))
      self.chooseBuyNum = self.availableCount
    else
      self.chooseBuyNum = num
    end
    self:SetChooseNumAndNeedMoney()
  end, nil)
  NumberPad.Instance():SetPos(275, 0)
end
ExchangeConfirmPanel.Commit()
return ExchangeConfirmPanel
