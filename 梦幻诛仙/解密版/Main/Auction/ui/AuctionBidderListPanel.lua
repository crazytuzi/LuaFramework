local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local AuctionData = require("Main.Auction.data.AuctionData")
local AuctionUtils = require("Main.Auction.AuctionUtils")
local AuctionBidderListPanel = Lplus.Extend(ECPanelBase, "AuctionBidderListPanel")
local def = AuctionBidderListPanel.define
local instance
def.static("=>", AuctionBidderListPanel).Instance = function()
  if instance == nil then
    instance = AuctionBidderListPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table")._bidderList = nil
def.static().ShowPanel = function()
  if not require("Main.Auction.AuctionModule").Instance():IsOpen(true) then
    if AuctionBidderListPanel.Instance():IsShow() then
      AuctionBidderListPanel.Instance():DestroyPanel()
    end
    return
  end
  if AuctionBidderListPanel.Instance():IsShow() then
    require("Main.Auction.AuctionProtocols").SendCGetBidRankReq(AuctionData.Instance():GetCurrentAuctionId())
    AuctionBidderListPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AUCTION_BIDDER_LIST_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self._uiObjs = {}
  self._uiObjs.Group_Date = self.m_panel:FindDirect("Img_Bg0/Group_Date")
  self._uiObjs.Label_Name = self._uiObjs.Group_Date:FindDirect("Label_Name")
  self._uiObjs.Label_Date = self._uiObjs.Group_Date:FindDirect("Label_Date")
  self._uiObjs.Group_List = self.m_panel:FindDirect("Img_Bg0/Group_List")
  self._uiObjs.Scroll_View = self.m_panel:FindDirect("Img_Bg0/Group_List/Group_Item/Scrollview_Item")
  self._uiObjs.uiScrollView = self._uiObjs.Scroll_View:GetComponent("UIScrollView")
  self._uiObjs.List_Item = self._uiObjs.Scroll_View:FindDirect("List_Item")
  self._uiObjs.uiList = self._uiObjs.List_Item:GetComponent("UIList")
  self._uiObjs.Group_NoData = self.m_panel:FindDirect("Img_Bg0/Group_NoData")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    require("Main.Auction.AuctionProtocols").SendCGetBidRankReq(AuctionData.Instance():GetCurrentAuctionId())
    GUIUtils.SetActive(self._uiObjs.Group_List, false)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    GUIUtils.SetActive(self._uiObjs.Group_Date, false)
  else
  end
end
def.method().UpdateUI = function(self)
  self:ShowAuctionDate()
  self:ShowItemBidderList()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self.itemTipHelper = nil
  self:_ClearList()
  self._bidderList = nil
  self._uiObjs = nil
end
def.method().ShowAuctionDate = function(self)
  local auctionItemInfo = self._bidderList and self._bidderList[1]
  if auctionItemInfo then
    GUIUtils.SetActive(self._uiObjs.Group_Date, true)
    local bidTime = Int64.ToNumber(auctionItemInfo.bidEndTimeStamp)
    GUIUtils.SetText(self._uiObjs.Label_Date, os.date(textRes.Auction.AUCTION_BID_DATE, bidTime))
  else
    GUIUtils.SetActive(self._uiObjs.Group_Date, false)
  end
end
def.method("table").SetItemList = function(self, itemInfoList)
  self._bidderList = {}
  if itemInfoList and #itemInfoList > 0 then
    for _, itemInfo in ipairs(itemInfoList) do
      if itemInfo.bidderRoleId and Int64.gt(itemInfo.bidderRoleId, 0) then
        table.insert(self._bidderList, 1, itemInfo)
      else
        table.insert(self._bidderList, itemInfo)
      end
    end
  end
end
def.method("=>", "number").GetItemBidderCount = function(self)
  return self._bidderList and #self._bidderList or 0
end
def.method().ShowItemBidderList = function(self)
  self:_ClearList()
  local bidderCount = self:GetItemBidderCount()
  if bidderCount > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_List, true)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    self._uiObjs.uiList.itemCount = bidderCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, auctionItemInfo in ipairs(self._bidderList) do
      self:ShowAuctionItemInfo(idx, auctionItemInfo)
    end
  else
    GUIUtils.SetActive(self._uiObjs.Group_List, false)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
  end
end
def.method("number", "table").ShowAuctionItemInfo = function(self, idx, auctionItemInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][AuctionBidderListPanel:ShowAuctionItemInfo] listItem nil at idx:", idx)
    return
  end
  if nil == auctionItemInfo then
    warn("[ERROR][AuctionBidderListPanel:ShowAuctionItemInfo] auctionItemInfo nil at idx:", idx)
    return
  end
  local auctionItemCfg = AuctionData.Instance():GetAuctionItemCfg(auctionItemInfo.itemCfgId)
  if nil == auctionItemCfg then
    warn("[ERROR][AuctionBidderListPanel:ShowAuctionItemInfo] auctionItemCfg nil for auctionItemInfo.itemCfgId:", auctionItemInfo.itemCfgId)
    return
  end
  local itemBase = ItemUtils.GetItemBase(auctionItemCfg.itemCfgId)
  if nil == itemBase then
    warn("[ERROR][AuctionBidderListPanel:ShowAuctionItemInfo] itemBase nil for auctionItemCfg.itemCfgId:", auctionItemCfg.itemCfgId)
    return
  end
  local Img_Bg01 = listItem:FindDirect("Img_Bg01_" .. idx)
  local Img_Bg02 = listItem:FindDirect("Img_Bg02_" .. idx)
  local bgFlag = idx % 2 == 0
  GUIUtils.SetActive(Img_Bg01, bgFlag)
  GUIUtils.SetActive(Img_Bg02, not bgFlag)
  local Label_Name = listItem:FindDirect("Label_Name_" .. idx)
  GUIUtils.SetText(Label_Name, itemBase.name)
  local Img_BgIcon = listItem:FindDirect("Img_BgIcon_" .. idx)
  GUIUtils.SetSprite(Img_BgIcon, string.format("Cell_%02d", itemBase.namecolor))
  self.itemTipHelper:RegisterItem2ShowTip(itemBase.itemid, Img_BgIcon)
  local Img_Icon = Img_BgIcon:FindDirect("Img_Icon_" .. idx)
  GUIUtils.SetTexture(Img_Icon, itemBase.icon)
  local Label_PrizeNum = listItem:FindDirect("Group_Price_" .. idx .. "/Label_PrizeNum_" .. idx)
  GUIUtils.SetText(Label_PrizeNum, auctionItemCfg.basePrice)
  local Img_Money1 = listItem:FindDirect("Group_Price_" .. idx .. "/Img_Money_" .. idx)
  local Img_Money2 = listItem:FindDirect("Group_CurPrice_" .. idx .. "/Img_Money_" .. idx)
  local spriteName = AuctionData.Instance():GetCurrencySpriteName(auctionItemCfg.moneyType)
  GUIUtils.SetSprite(Img_Money1, spriteName)
  GUIUtils.SetSprite(Img_Money2, spriteName)
  local Label_CurPeople = listItem:FindDirect("Label_CurPeople_" .. idx)
  local Label_CurPriceNum = listItem:FindDirect("Group_CurPrice_" .. idx .. "/Label_CurPriceNum_" .. idx)
  local Label_PlayerName = listItem:FindDirect("Group_Buy_" .. idx .. "/Label_PlayerName_" .. idx)
  if auctionItemInfo.bidderRoleId and Int64.gt(auctionItemInfo.bidderRoleId, 0) then
    GUIUtils.SetText(Label_CurPeople, auctionItemInfo.bidderCount)
    GUIUtils.SetText(Label_CurPriceNum, Int64.tostring(auctionItemInfo.maxBidPrice))
    GUIUtils.SetText(Label_PlayerName, auctionItemInfo.bidderName and _G.GetStringFromOcts(auctionItemInfo.bidderName) or "")
  else
    GUIUtils.SetText(Label_CurPeople, textRes.Auction.AUCTION_ITEM_BIT_NA)
    GUIUtils.SetText(Label_CurPriceNum, textRes.Auction.AUCTION_ITEM_BIT_NA)
    GUIUtils.SetText(Label_PlayerName, textRes.Auction.AUCTION_ITEM_BIT_NO_ONE)
  end
end
def.method()._ClearList = function(self)
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif string.find(id, "Img_BgIcon") then
    self.itemTipHelper:CheckItem2ShowTip(id, -1, true)
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
def.static("table").OnSGetBidRankRsp = function(p)
  warn("[AuctionBidderListPanel:OnSGetBidRankRsp] On SGetBidRankRsp.")
  local self = AuctionBidderListPanel.Instance()
  if self and self:IsShow() then
    self:SetItemList(p.itemInfoList)
    self:UpdateUI()
  end
end
AuctionBidderListPanel.Commit()
return AuctionBidderListPanel
