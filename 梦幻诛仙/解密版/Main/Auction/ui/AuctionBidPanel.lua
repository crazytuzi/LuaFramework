local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local AuctionProtocols = require("Main.Auction.AuctionProtocols")
local AuctionUtils = require("Main.Auction.AuctionUtils")
local AuctionData = require("Main.Auction.data.AuctionData")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local ItemModule = require("Main.Item.ItemModule")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local AuctionBidPanel = Lplus.Extend(ECPanelBase, "AuctionBidPanel")
local def = AuctionBidPanel.define
local instance
def.static("=>", AuctionBidPanel).Instance = function()
  if instance == nil then
    instance = AuctionBidPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._auctionItemInfo = nil
def.field("table")._auctionItemCfg = nil
def.field("table")._itemBase = nil
def.field("userdata")._selfBidPrice = nil
def.field("userdata")._curFloorPrice = nil
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.field("table")._currencyData = nil
def.static("table").ShowPanel = function(auctionItemInfo)
  if not require("Main.Auction.AuctionModule").Instance():IsOpen(true) then
    if AuctionBidPanel.Instance():IsShow() then
      AuctionBidPanel.Instance():DestroyPanel()
    end
    return
  end
  if not AuctionBidPanel.Instance():_InitData(auctionItemInfo) then
    if AuctionBidPanel.Instance():IsShow() then
      AuctionBidPanel.Instance():DestroyPanel()
    end
    return
  end
  if AuctionBidPanel.Instance():IsShow() then
    AuctionBidPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AUCTION_BID_PANEL, 1)
end
def.method("table", "=>", "boolean")._InitData = function(self, auctionItemInfo)
  self._auctionItemInfo = auctionItemInfo
  if self._auctionItemInfo then
    self._auctionItemCfg = AuctionData.Instance():GetAuctionItemCfg(auctionItemInfo.auctionItemId)
    if nil == self._auctionItemCfg then
      warn("[ERROR][AuctionBidPanel:_InitData] auctionItemCfg nil for auctionItemInfo.auctionItemId:", auctionItemInfo.auctionItemId)
      return false
    end
    self._itemBase = ItemUtils.GetItemBase(self._auctionItemCfg.itemCfgId)
    if nil == self._itemBase then
      warn("[ERROR][AuctionBidPanel:_InitData] itemBase nil for self._auctionItemCfg.itemCfgId:", self._auctionItemCfg.itemCfgId)
      return false
    end
    return true
  else
    return false
  end
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
  self._currencyData = CurrencyFactory.Create(self._auctionItemCfg.moneyType)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_CurTurnTime = self.m_panel:FindDirect("Img_Bg/Group_CurTurn/Label_CurTurnTime")
  self._uiObjs.Img_Item = self.m_panel:FindDirect("Img_Bg/Group_Info/Img_Item")
  self._uiObjs.Texture_RightIcon = self._uiObjs.Img_Item:FindDirect("Texture_RightIcon")
  self._uiObjs.Label_ItemNum = self._uiObjs.Img_Item:FindDirect("Label_ItemNum")
  self._uiObjs.Label_Name = self.m_panel:FindDirect("Img_Bg/Group_Info/Label_Name")
  self._uiObjs.Label_CurPriceNum = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_CurPrice/Label_CurPriceNum")
  self._uiObjs.Img_Money1 = self.m_panel:FindDirect("Img_Bg/Group_Info/Group_CurPrice/Img_Money")
  self._uiObjs.Label_LowPriceNum = self.m_panel:FindDirect("Img_Bg/Group_LowPrice/Label_LowPriceNum")
  self._uiObjs.Img_Money2 = self.m_panel:FindDirect("Img_Bg/Group_LowPrice/Img_Money")
  self._uiObjs.Label_Own_YB_Num = self.m_panel:FindDirect("Img_Bg/Group_Own/Label_Num")
  self._uiObjs.Img_Money4 = self.m_panel:FindDirect("Img_Bg/Group_Own/Img_Money")
  self._uiObjs.Label_Bid_YB_Num = self.m_panel:FindDirect("Img_Bg/Group_BuyNum/Label_Num")
  self._uiObjs.Img_Money3 = self.m_panel:FindDirect("Img_Bg/Group_BuyNum/Img_Money")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self._selfBidPrice = Int64.new(0)
    self._curFloorPrice = Int64.new(0)
    self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
      self:_OnTimerUpdate()
    end)
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:UpdateCountdown()
  GUIUtils.SetText(self._uiObjs.Label_Name, self._itemBase.name)
  GUIUtils.SetSprite(self._uiObjs.Img_Item, string.format("Cell_%02d", self._itemBase.namecolor))
  GUIUtils.SetTexture(self._uiObjs.Texture_RightIcon, self._itemBase.icon)
  GUIUtils.SetText(self._uiObjs.Label_ItemNum, "")
  local spriteName = self._currencyData:GetSpriteName()
  GUIUtils.SetSprite(self._uiObjs.Img_Money1, spriteName)
  GUIUtils.SetSprite(self._uiObjs.Img_Money2, spriteName)
  GUIUtils.SetSprite(self._uiObjs.Img_Money3, spriteName)
  GUIUtils.SetSprite(self._uiObjs.Img_Money4, spriteName)
  self:UpdateCurPrice()
  self:UpdateOwnYB()
  self:UpdateBidYB(self._curFloorPrice)
end
def.method().UpdateCurPrice = function(self)
  if self._auctionItemInfo.bidderRoleId and Int64.gt(self._auctionItemInfo.bidderRoleId, 0) then
    GUIUtils.SetText(self._uiObjs.Label_CurPriceNum, Int64.tostring(self._auctionItemInfo.maxBidPrice))
    local intMaxPrice = Int64.ToNumber(self._auctionItemInfo.maxBidPrice)
    self._curFloorPrice = self._auctionItemInfo.maxBidPrice + math.ceil(intMaxPrice * (self._auctionItemCfg.premiumRate / 10000))
    GUIUtils.SetText(self._uiObjs.Label_LowPriceNum, Int64.tostring(self._curFloorPrice))
  else
    GUIUtils.SetText(self._uiObjs.Label_CurPriceNum, textRes.Auction.AUCTION_ITEM_BIT_NA)
    self._curFloorPrice = Int64.new(self._auctionItemCfg.basePrice)
    GUIUtils.SetText(self._uiObjs.Label_LowPriceNum, self._auctionItemCfg.basePrice)
  end
end
def.method().UpdateOwnYB = function(self)
  local haveCurrencyNum = self:GetOwnCurrencyNum()
  GUIUtils.SetText(self._uiObjs.Label_Own_YB_Num, Int64.tostring(haveCurrencyNum))
end
def.method("=>", "userdata").GetOwnCurrencyNum = function(self)
  local haveCurrencyNum = 0
  if CurrencyType.YUAN_BAO == self._auctionItemCfg.moneyType then
    haveCurrencyNum = ItemModule.Instance():getCashYuanBao()
  else
    haveCurrencyNum = self._currencyData:GetHaveNum()
  end
  return haveCurrencyNum
end
def.method("userdata").UpdateBidYB = function(self, ybNum)
  if Int64.lt(ybNum, 0) or Int64.gt(ybNum, constant.CAuctionConsts.BID_PRICE_MAX) then
    ybNum = Int64.new(constant.CAuctionConsts.BID_PRICE_MAX)
  end
  self._selfBidPrice = ybNum
  GUIUtils.SetText(self._uiObjs.Label_Bid_YB_Num, Int64.tostring(self._selfBidPrice))
end
def.method().UpdateCountdown = function(self)
  local countdown = self._auctionItemInfo:GetCountDown()
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.Label_CurTurnTime) then
    GUIUtils.SetText(self._uiObjs.Label_CurTurnTime, AuctionUtils.GetCountdownText(countdown))
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._auctionItemInfo = nil
  self._auctionItemCfg = nil
  self._itemBase = nil
  self._selfBidPrice = nil
  self._curFloorPrice = nil
  self._currencyData = nil
end
def.method()._OnTimerUpdate = function(self)
  if self._auctionItemInfo then
    self:UpdateCountdown()
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Fresh" then
    self:OnBtn_Fresh()
  elseif id == "Btn_Edit" then
    self:OnBtn_Edit()
  elseif id == "Label_Num" then
    self:OnBtn_Edit()
  elseif id == "Btn_Buy" then
    self:OnBtn_Buy()
  elseif id == "Btn_Add" then
    self:OnBtn_Add()
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Fresh = function(self)
  if self._auctionItemInfo then
    AuctionProtocols.SendCGetAuctionItemInfoReq(self._auctionItemInfo.activityId, self._auctionItemInfo.round, self._auctionItemInfo.auctionItemId)
  end
end
def.method().OnBtn_Edit = function(self)
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, AuctionBidPanel.OnDigitalKeyboardCallback, {_self = self})
  CommonDigitalKeyboard.Instance():SetPos(284, -1)
end
def.method().OnBtn_Buy = function(self)
  if Int64.lt(self._selfBidPrice, self._curFloorPrice) then
    warn("[AuctionBidPanel:OnBtn_Buy] low bid price. self._curFloorPrice, self._selfBidPrice:", Int64.tostring(self._curFloorPrice), Int64.tostring(self._selfBidPrice))
    Toast(textRes.Auction.AUCTION_BID_LOW_PRICE)
  elseif Int64.lt(self:GetOwnCurrencyNum(), self._selfBidPrice) then
    self._currencyData:AcquireWithQuery()
  else
    AuctionProtocols.SendCBidReq(self._auctionItemInfo.activityId, self._auctionItemInfo.round, self._auctionItemInfo.auctionItemId, self._selfBidPrice)
  end
end
def.method().OnBtn_Add = function(self)
  if self._currencyData then
    self._currencyData:Acquire()
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ITEM_INFO_CHANGE, AuctionBidPanel.OnItemInfoChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, AuctionBidPanel.OnBuyYBChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, AuctionBidPanel.OnGoldChange)
  end
end
def.static("table", "table").OnItemInfoChange = function(params, context)
  warn("[AuctionBidPanel:OnItemInfoChange] On ItemInfo Change.")
  local self = AuctionBidPanel.Instance()
  if self and self:IsShow() and self._auctionItemInfo and self._auctionItemInfo.activityId == params.activityId and self._auctionItemInfo.round == params.roundIdx and self._auctionItemInfo.auctionItemId == params.auctionItemId then
    self:UpdateCurPrice()
    self:UpdateBidYB(self._curFloorPrice)
  end
end
def.static("table", "table").OnBuyYBChange = function(params, context)
  AuctionBidPanel.Instance():UpdateOwnYB()
end
def.static("table", "table").OnGoldChange = function(params, context)
  AuctionBidPanel.Instance():UpdateOwnYB()
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag._self
  if self and self:IsShow() then
    if value < 0 or value > constant.CAuctionConsts.BID_PRICE_MAX then
      value = constant.CAuctionConsts.BID_PRICE_MAX
      Toast(textRes.Auction.AUCTION_BID_HIGH_PRICE)
      if CommonDigitalKeyboard.Instance():IsShow() then
        CommonDigitalKeyboard.Instance():SetEnteredValue(value)
      end
    end
    self:UpdateBidYB(Int64.new(value))
  end
end
AuctionBidPanel.Commit()
return AuctionBidPanel
