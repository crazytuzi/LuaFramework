local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonGiftBuyPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = CommonGiftBuyPanel
local def = Cls.define
local GUIUtils = require("GUI.GUIUtils")
def.field("number").MAX_BUY_NUM = 999
def.field("number").MIN_BUY_NUM = 1
def.field("table").uiObjs = nil
def.field("number").sourceItemid = 0
def.field("number").giftItemid = 0
def.field("number").itemPrice = 0
def.field("function").confirmCallBack = nil
def.field("number").buyNum = 1
local instance
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method("number", "number", "number", "function").ShowPanel = function(self, sourceItemid, giftItemid, itemPrice, confirmCallBack)
  self:ShowPanelWithMaxValue(sourceItemid, giftItemid, itemPrice, confirmCallBack, 999)
end
def.method("number", "number", "number", "function", "number").ShowPanelWithMaxValue = function(self, sourceItemid, giftItemid, itemPrice, confirmCallBack, maxValue)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self.MAX_BUY_NUM = maxValue
  self.sourceItemid = sourceItemid
  self.giftItemid = giftItemid
  self.itemPrice = itemPrice
  self.confirmCallBack = confirmCallBack
  self.buyNum = self.MIN_BUY_NUM
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_LOTTERY_TIAN_DI_BAO_KU_EXCHANGE_GIFT_PURCHASE_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, Cls.OnYuanBaoNumChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, Cls.OnYuanBaoNumChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, Cls.OnYuanBaoNumChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, Cls.OnYuanBaoNumChanged)
  self.MAX_BUY_NUM = 999
  self.MIN_BUY_NUM = 1
  self.uiObjs = nil
  self.sourceItemid = 0
  self.giftItemid = 0
  self.itemPrice = 0
  def.buyNum = 0
  self.confirmCallBack = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_Item = self.uiObjs.Img_Bg:FindDirect("Group_Item")
  self.uiObjs.Group_Buy = self.uiObjs.Img_Bg:FindDirect("Group_Buy")
  self.uiObjs.BuyNum = self.uiObjs.Group_Buy:FindDirect("Label_NumBuy/Btn_Num/Label_Num")
  self.uiObjs.CostYuanbaoNum = self.uiObjs.Group_Buy:FindDirect("Label_Cost/Img_BgCost/Label_CostNum")
  self.uiObjs.HaveYuanbaoNum = self.uiObjs.Group_Buy:FindDirect("Label_Have/Img_BgHave/Label_HaveNum")
end
def.method().UpdateUI = function(self)
  self:UpdateItemInfos()
  self:UpdatePurchaseNum()
  self:UpdateMoneyCostNum()
  self:UpdateMoneyHaveNum()
end
def.method().UpdateItemInfos = function(self)
  local sourceItemUI = self.uiObjs.Group_Item:FindDirect("Group_Item01")
  self:SetItemInfo(sourceItemUI, self.sourceItemid)
  local giftItemUI = self.uiObjs.Group_Item:FindDirect("Group_Item02")
  self:SetItemInfo(giftItemUI, self.giftItemid)
end
def.method("userdata", "number").SetItemInfo = function(self, itemObj, itemId)
  local Img_ItemCost = itemObj:FindDirect("Img_ItemCost")
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  GUIUtils.SetItemCellSprite(Img_ItemCost, itemBase.namecolor)
  local Img_ItemIcon = Img_ItemCost:FindDirect("Img_ItemIcon")
  GUIUtils.SetTexture(Img_ItemIcon, itemBase.icon)
end
def.method().UpdatePurchaseNum = function(self)
  GUIUtils.SetText(self.uiObjs.BuyNum, self.buyNum)
end
def.method().UpdateMoneyCostNum = function(self)
  local costNum = self:GetMoneyCostNum()
  GUIUtils.SetText(self.uiObjs.CostYuanbaoNum, costNum)
end
def.method().UpdateMoneyHaveNum = function(self)
  local haveNum = self:GetMoneyHaveNum()
  GUIUtils.SetText(self.uiObjs.HaveYuanbaoNum, haveNum)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_ItemCost" then
    self:OnClickItem(obj)
  elseif id == "Btn_Buy" then
    self:OnClickBtnBuy()
  elseif id == "Btn_Add" then
    self:IncPurchaseNum(1)
  elseif id == "Btn_Minus" then
    self:IncPurchaseNum(-1)
  elseif id == "Label_Num" then
    self:OnClickLabelPurchaseNum()
  end
end
def.method("userdata").OnClickItem = function(self, clickObj)
  local pName = clickObj.parent.name
  local itemId = 0
  if pName == "Group_Item01" then
    itemId = self.sourceItemid
  elseif pName == "Group_Item02" then
    itemId = self.giftItemid
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
end
def.method().OnClickBtnBuy = function(self)
  local purchaseNum = self.buyNum
  local costNum = self:GetMoneyCostNum()
  local haveNum = self:GetMoneyHaveNum()
  if costNum > haveNum then
    _G.GotoBuyYuanbao()
    return
  end
  if self.confirmCallBack ~= nil then
    _G.SafeCallback(self.confirmCallBack, self.buyNum)
  end
  self:DestroyPanel()
end
def.method().OnClickLabelPurchaseNum = function(self)
  local keypad = require("GUI.CommonDigitalKeyboard").Instance()
  keypad:ShowPanelEx(self.MAX_BUY_NUM, function(val)
    if val < self.MIN_BUY_NUM then
      val = self.MIN_BUY_NUM
      keypad:SetEnteredValue(val)
      Toast(textRes.Mibao[25])
    elseif val == self.MAX_BUY_NUM and val == self.buyNum then
      Toast(textRes.Mibao[24])
    end
    self:SetPurchaseNum(val)
  end, nil)
  keypad:SetPos(256, 0)
end
def.method("=>", "number").GetMoneyCostNum = function(self)
  return self.buyNum * self.itemPrice
end
def.method("=>", "number").GetMoneyHaveNum = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local haveNum = ItemModule.Instance():GetAllYuanBao():ToNumber()
  return haveNum
end
def.method("number").IncPurchaseNum = function(self, deltaNum)
  if deltaNum == 0 then
    return
  end
  local nextNum = self.buyNum + deltaNum
  if deltaNum > 0 then
    if nextNum > self.MAX_BUY_NUM then
      nextNum = self.MAX_BUY_NUM
      Toast(textRes.Mibao[24])
    end
  elseif nextNum < self.MIN_BUY_NUM then
    nextNum = self.MIN_BUY_NUM
    Toast(textRes.Mibao[25])
  end
  self.buyNum = nextNum
  self:UpdatePurchaseNum()
  self:UpdateMoneyCostNum()
end
def.method("number").SetPurchaseNum = function(self, num)
  local deltaNum = num - self.buyNum
  self:IncPurchaseNum(deltaNum)
end
def.static("table", "table").OnYuanBaoNumChanged = function(params, context)
  instance:UpdateMoneyHaveNum()
end
return Cls.Commit()
