local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUILeftButtonGroup = Lplus.Extend(ComponentBase, "MainUILeftButtonGroup")
local PayNode = require("Main.Pay.ui.PayNode")
local EC = require("Types.Vector3")
local def = MainUILeftButtonGroup.define
local instance
def.field("boolean").m_open = true
def.field("boolean").m_isMenuHided = false
def.field("dynamic").m_tlBtnNotifyState = nil
def.static("=>", MainUILeftButtonGroup).Instance = function()
  if instance == nil then
    instance = MainUILeftButtonGroup()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NOTIFY_MESSAGE_COUNT_UPDATE, MainUILeftButtonGroup.OnAwardNotifyMessageCountUpdate)
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, MainUILeftButtonGroup.OnCommerceNotifyMessageCountUpdate)
  Event.RegisterEvent(ModuleId.PAY, gmodule.notifyId.Pay.RECHARTE_RETURN_STATUS, MainUILeftButtonGroup.OnPayReturnStatus)
  Event.RegisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, MainUILeftButtonGroup.OnTradingSellNotifyUpdate)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, MainUILeftButtonGroup.OnUpdateDailyPurchaseRedPoint)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TOP_LEFT_BTNS_NOTIFY_UPDATE, MainUILeftButtonGroup.OnTopLeftNotifyUpdate)
  Event.RegisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_REDDOT_CHANGE, MainUILeftButtonGroup.OnAuctionNotifyUpdate)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TOP_LEFT_BTNS_NOTIFY_UPDATE, MainUILeftButtonGroup.OnTopLeftNotifyUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NOTIFY_MESSAGE_COUNT_UPDATE, MainUILeftButtonGroup.OnAwardNotifyMessageCountUpdate)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, MainUILeftButtonGroup.OnCommerceNotifyMessageCountUpdate)
  Event.UnregisterEvent(ModuleId.PAY, gmodule.notifyId.Pay.RECHARTE_RETURN_STATUS, MainUILeftButtonGroup.OnPayReturnStatus)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, MainUILeftButtonGroup.OnTradingSellNotifyUpdate)
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, MainUILeftButtonGroup.OnUpdateDailyPurchaseRedPoint)
  Event.UnregisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_REDDOT_CHANGE, MainUILeftButtonGroup.OnAuctionNotifyUpdate)
  self.m_tlBtnNotifyState = nil
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().UpdateUI = function(self)
  self:UpdateAwardNotifyMessageNum()
  self:UpdateCommerceAndPitchMessageNum()
  self:UpdateMallMessageNum()
  self:UpdateOpenBtnNotify()
end
def.method().UpdateAwardNotifyMessageNum = function(self)
  local count = gmodule.moduleMgr:GetModule(ModuleId.AWARD):GetNotifyMessageCount()
  self:SetAwardNotifyMessageNum(count)
end
def.method("number").SetAwardNotifyMessageNum = function(self, num)
  self:SetNotifyMessageNum("Btn_Reward/Img_RewardRed", "Label_RewardRedNum", num)
  local btn = self.m_node:FindDirect("Btn_Reward")
  self:SetNotifyCount(btn, num)
end
def.method().UpdateCommerceAndPitchMessageNum = function(self)
  local count = require("Main.CommerceAndPitch.data.PitchData").Instance():GetChangedSelledItemNum() or 0
  if gmodule.moduleMgr:GetModule(ModuleId.TRADING_ARCADE):HasNotify() then
    count = count + 1
  end
  if gmodule.moduleMgr:GetModule(ModuleId.AUCTION):NeedReddot() then
    count = count + 1
  end
  self:SetCommerceAndPitchMessageNum(count)
end
def.method().UpdateMallMessageNum = function(self)
  self.m_node:FindDirect("Btn_Mall/Img_MallRed/Label_MallRedNum"):SetActive(false)
  local bShowPayRedPt = PayNode.Instance():canGetSaveAmtAward()
  local bMysteryStoreRedPt = require("Main.Mall.ui.PromotionNode").IsActiveRedPt()
  local dailyPurchaseRedPoint = require("Main.Mall.data.MallData").Instance():isShowDailyPurchaseRedPoint()
  local showRedPoint = bShowPayRedPt == true or bMysteryStoreRedPt or dailyPurchaseRedPoint
  if showRedPoint then
    self.m_node:FindDirect("Btn_Mall/Img_MallRed"):SetActive(true)
  else
    self.m_node:FindDirect("Btn_Mall/Img_MallRed"):SetActive(false)
  end
  local btn = self.m_node:FindDirect("Btn_Mall")
  self:SetNotifyCount(btn, showRedPoint and 1 or 0)
end
def.method("number").SetCommerceAndPitchMessageNum = function(self, num)
  self:SetNotifyMessageNum("Btn_Shop/Img_ShopRed", "Label_ShopRedNum", num)
  local btn = self.m_node:FindDirect("Btn_Shop")
  self:SetNotifyCount(btn, num)
end
def.method("string", "string", "number").SetNotifyMessageNum = function(self, imgName, labelName, num)
  if num <= 0 then
    self.m_node:FindDirect(imgName):SetActive(false)
  else
    local img = self.m_node:FindDirect(imgName)
    img:SetActive(true)
    img:FindDirect(labelName):GetComponent("UILabel"):set_text("")
  end
end
def.method("userdata", "number").SetNotifyCount = function(self, btnGO, count)
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopLeftBtnsNotifyCount(btnGO, count)
end
def.method().UpdateOpenBtnNotify = function(self)
  local btn = self.m_container.uiObjs.Btn_MainInfoOpen
  if btn == nil then
    return
  end
  local hasNotify = gmodule.moduleMgr:GetModule(ModuleId.MAINUI):IsTopLeftBtnsHasNotify()
  if self.m_tlBtnNotifyState == hasNotify then
    return
  end
  local Img_Red = btn:FindDirect("Img_Red")
  Img_Red:SetActive(hasNotify)
  self.m_tlBtnNotifyState = hasNotify
end
def.static("table", "table").OnAwardNotifyMessageCountUpdate = function(params)
  local self = instance
  if self.m_node == nil then
    return
  end
  local count = unpack(params)
  self:SetAwardNotifyMessageNum(count)
end
def.static("table", "table").OnCommerceNotifyMessageCountUpdate = function()
  local self = instance
  if self.m_node == nil then
    return
  end
  self:UpdateCommerceAndPitchMessageNum()
end
def.static("table", "table").OnTradingSellNotifyUpdate = function()
  local self = instance
  if self.m_node == nil then
    return
  end
  self:UpdateCommerceAndPitchMessageNum()
end
def.static("table", "table").OnAuctionNotifyUpdate = function()
  local self = instance
  if self.m_node == nil then
    return
  end
  self:UpdateCommerceAndPitchMessageNum()
end
def.static("table", "table").OnUpdateDailyPurchaseRedPoint = function(p1, p2)
  if instance and instance.m_node then
    instance:UpdateMallMessageNum()
  end
end
def.static("table", "table").OnPayReturnStatus = function()
  local self = instance
  if self.m_node == nil then
    return
  end
  self:UpdateMallMessageNum()
end
def.static("table", "table").OnTopLeftNotifyUpdate = function(params, context)
  local self = instance
  if self.m_node == nil then
    return
  end
  self:UpdateOpenBtnNotify()
end
def.static().OnShowPVP3 = function()
  local self = instance
  if self.m_node == nil then
    return
  end
  local img = self.m_node:FindDirect("Btn_PVP3")
  img:SetActive(true)
end
def.static().OnHidePVP3 = function()
  local self = instance
  if self.m_node == nil then
    return
  end
  local img = self.m_node:FindDirect("Btn_PVP3")
  img:SetActive(false)
end
MainUILeftButtonGroup.Commit()
return MainUILeftButtonGroup
