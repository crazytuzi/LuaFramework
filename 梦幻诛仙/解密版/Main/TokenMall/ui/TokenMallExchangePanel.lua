local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TokenMallExchangePanel = Lplus.Extend(ECPanelBase, "TokenMallExchangePanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = TokenMallExchangePanel.define
def.const("number").MAX_BUY_NUM = 999
local instance
def.field("table").uiObjs = nil
def.field("number").awardItemId = 0
def.field("number").awardItemNum = 0
def.field("number").currencyType = 0
def.field("number").awardPrice = 0
def.field("number").availableCount = 0
def.field("function").callback = nil
def.field("number").chooseBuyNum = 1
def.static("=>", TokenMallExchangePanel).Instance = function()
  if instance == nil then
    instance = TokenMallExchangePanel()
  end
  return instance
end
def.method("number", "number", "number", "number", "number", "function").ShowBuyConfirmPanel = function(self, awardItemId, awardItemNum, currencyType, awardPrice, availableCount, callback)
  if self.m_panel ~= nil then
    return
  end
  self.awardItemId = awardItemId
  self.awardItemNum = awardItemNum
  self.currencyType = currencyType
  self.awardPrice = awardPrice
  self.availableCount = availableCount > 0 and availableCount or TokenMallExchangePanel.MAX_BUY_NUM
  self.callback = callback
  self:CreatePanel(RESPATH.PREFAB_TOKEN_MALL_EXCHANGE_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:SetBuyItemInfo()
  self:SetChooseNumAndNeedMoney()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.awardItemId = 0
  self.awardItemNum = 0
  self.currencyType = 0
  self.awardPrice = 0
  self.availableCount = 0
  self.callback = nil
  self.chooseBuyNum = 1
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
end
def.method().SetBuyItemInfo = function(self)
  local Img_BgRightItem = self.uiObjs.Group_Right:FindDirect("Img_BgRightItem")
  local Texture_RightIcon = Img_BgRightItem:FindDirect("Texture_RightIcon")
  local Label_Num = Img_BgRightItem:FindDirect("Label_Num")
  local Label_RightName = self.uiObjs.Group_Right:FindDirect("Label_RightName")
  local Label_LvTitle = self.uiObjs.Group_Right:FindDirect("Label_LvTitle")
  local Label_Lv = self.uiObjs.Group_Right:FindDirect("Label_Lv")
  local Label_Type = self.uiObjs.Group_Right:FindDirect("Label_Type")
  local Label_Describe = self.uiObjs.Group_Right:FindDirect("Img_BgDescribe/Scroll View/Label_Describe")
  local itemInfo = ItemUtils.GetItemBase(self.awardItemId)
  if itemInfo == nil then
    return
  end
  GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemInfo.icon)
  GUIUtils.SetText(Label_Num, self.awardItemNum)
  GUIUtils.SetText(Label_RightName, itemInfo.name)
  GUIUtils.SetText(Label_Type, itemInfo.itemTypeName)
  Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.TokenMall[19], string.gsub(itemInfo.desc, "\\n", "<br/>")))
  GUIUtils.SetActive(Label_LvTitle, false)
  GUIUtils.SetActive(Label_Lv, false)
  local tokenCfg = ItemUtils.GetTokenCfg(self.currencyType)
  local Group_Price = self.uiObjs.Group_Right:FindDirect("Group_Price")
  local Img_Money = Group_Price:FindDirect("Img_Money")
  local Label_Price = Group_Price:FindDirect("Label_Price")
  GUIUtils.SetSprite(Img_Money, tokenCfg.icon)
  if self.awardPrice == 0 then
    GUIUtils.SetText(Label_Price, textRes.TokenMall[20])
  else
    GUIUtils.SetText(Label_Price, self.awardPrice)
  end
  local Btn_Buy = self.uiObjs.Group_Right:FindDirect("Btn_Buy")
  local Img_BgNum = Btn_Buy:FindDirect("Img_BgNum")
  GUIUtils.SetSprite(Img_BgNum, tokenCfg.icon)
end
def.method().SetChooseNumAndNeedMoney = function(self)
  local Group_Num = self.uiObjs.Group_Right:FindDirect("Group_Num")
  local Label_Num = Group_Num:FindDirect("Img_BgNum/Label_Num")
  GUIUtils.SetText(Label_Num, string.format("%d/%d", self.chooseBuyNum, self.availableCount))
  local totalNeedNum = self.awardPrice * self.chooseBuyNum
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
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.awardItemId, source, 0, false)
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
  self.chooseBuyNum = math.max(1, self.chooseBuyNum - 1)
  self:SetChooseNumAndNeedMoney()
end
def.method().OnClickBtnAdd = function(self)
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
      self.chooseBuyNum = 1
    elseif num > self.availableCount then
      self.chooseBuyNum = self.availableCount
    else
      self.chooseBuyNum = num
    end
    self:SetChooseNumAndNeedMoney()
  end, nil)
  NumberPad.Instance():SetPos(275, 0)
end
TokenMallExchangePanel.Commit()
return TokenMallExchangePanel
