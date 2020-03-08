local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LuckyStarConfirmPanel = Lplus.Extend(ECPanelBase, "LuckyStarConfirmPanel")
local GUIUtils = require("GUI.GUIUtils")
local LuckyStarMgr = require("Main.LuckyStar.mgr.LuckyStarMgr")
local LuckyStarUtils = require("Main.LuckyStar.LuckyStarUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = LuckyStarConfirmPanel.define
local instance
def.field("table").uiObjs = nil
def.field("number").awardItemId = 0
def.field("number").awardItemNum = 0
def.field("number").currencyType = 0
def.field("number").awardPrice = 0
def.field("number").availableCount = 0
def.field("function").callback = nil
def.field("number").chooseBuyNum = 1
def.static("=>", LuckyStarConfirmPanel).Instance = function()
  if instance == nil then
    instance = LuckyStarConfirmPanel()
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
  self.availableCount = availableCount
  self.callback = callback
  self:CreatePanel(RESPATH.PREFAB_LUCKY_STAR_CONFIRM_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:SetLuckyStarAward()
  self:SetChooseNumAndNeedMoney()
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.BUY_LUCKYSTAR_SUCCESS, LuckyStarConfirmPanel.OnBuyLuckyStarSuccess)
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_STATUS_CHANGE, LuckyStarConfirmPanel.OnLuckyStarStatusChange)
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
  Event.UnregisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.BUY_LUCKYSTAR_SUCCESS, LuckyStarConfirmPanel.OnBuyLuckyStarSuccess)
  Event.UnregisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_STATUS_CHANGE, LuckyStarConfirmPanel.OnLuckyStarStatusChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
end
def.method().SetLuckyStarAward = function(self)
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
  Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.LuckyStar[11], itemInfo.desc))
  GUIUtils.SetActive(Label_LvTitle, false)
  GUIUtils.SetActive(Label_Lv, false)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local moneyData = CurrencyFactory.Create(self.currencyType)
  local Group_Price = self.uiObjs.Group_Right:FindDirect("Group_Price")
  local Img_Money = Group_Price:FindDirect("Img_Money")
  local Label_Price = Group_Price:FindDirect("Label_Price")
  GUIUtils.SetSprite(Img_Money, moneyData:GetSpriteName())
  if self.awardPrice == 0 then
    GUIUtils.SetText(Label_Price, textRes.LuckyStar[3])
  else
    GUIUtils.SetText(Label_Price, self.awardPrice)
  end
  local Btn_Buy = self.uiObjs.Group_Right:FindDirect("Btn_Buy")
  local Img_BgNum = Btn_Buy:FindDirect("Img_BgNum")
  GUIUtils.SetSprite(Img_BgNum, moneyData:GetSpriteName())
end
def.method().SetChooseNumAndNeedMoney = function(self)
  local Group_Num = self.uiObjs.Group_Right:FindDirect("Group_Num")
  local Label_Num = Group_Num:FindDirect("Img_BgNum/Label_Num")
  GUIUtils.SetText(Label_Num, string.format("%d/%d", self.chooseBuyNum, self.availableCount))
  local totalNeedNum = self.awardPrice * self.chooseBuyNum
  local Btn_Buy = self.uiObjs.Group_Right:FindDirect("Btn_Buy")
  local Label_MoneyNum = Btn_Buy:FindDirect("Label_MoneyNum")
  if totalNeedNum == 0 then
    GUIUtils.SetText(Label_MoneyNum, textRes.LuckyStar[3])
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
def.method().OnClickBtnDrawLuckyStar = function(self)
  LuckyStarMgr.Instance():DrawLuckyStar()
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
    self.callback(self.chooseBuyNum)
  end
end
def.static("table", "table").OnBuyLuckyStarSuccess = function(params, context)
  local self = instance
  if self ~= nil then
    self:DestroyPanel()
  end
end
def.static("table", "table").OnLuckyStarStatusChange = function(params, context)
  local self = instance
  if self ~= nil then
    local LuckyStarModule = require("Main.LuckyStar.LuckyStarModule")
    if not LuckyStarModule.Instance():IsLuckyStarOpened() then
      self:DestroyPanel()
    end
  end
end
LuckyStarConfirmPanel.Commit()
return LuckyStarConfirmPanel
