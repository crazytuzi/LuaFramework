local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AuctionData = require("Main.Auction.data.AuctionData")
local AuctionUtils = require("Main.Auction.AuctionUtils")
local AuctionProtocols = require("Main.Auction.AuctionProtocols")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local ItemUtils = require("Main.Item.ItemUtils")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local AuctionModule = require("Main.Auction.AuctionModule")
local ItemModule = require("Main.Item.ItemModule")
local AuctionNode = Lplus.Extend(TabNode, "AuctionNode")
local def = AuctionNode.define
local instance
def.static("=>", AuctionNode).Instance = function(self)
  if instance == nil then
    instance = AuctionNode()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("number")._curAuctionId = 0
def.field("number")._curAuctionPeriodIdx = 0
def.field("number")._showRoundIdx = 0
def.field("table")._roundInfoList = nil
def.field("table")._itemInfoList = nil
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.field("table")._ybCurrencyData = nil
def.field("table")._goldCurrencyData = nil
def.field("boolean")._bReddot = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self._bReddot = AuctionModule.Instance():NeedReddot()
  AuctionModule.Instance():SetReddot(false, false)
  self:UpdateTabNotify()
  self:InitUI()
  self._ybCurrencyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  self._goldCurrencyData = CurrencyFactory.Create(CurrencyType.GOLD)
  self:UpdateUI()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_OnTimerUpdate()
  end)
  self:HandleEventListeners(true)
end
def.method().InitUI = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self._uiObjs = {}
  self._uiObjs.Group_Close = self.m_node:FindDirect("Group_Close")
  self._uiObjs.Close_Label = self._uiObjs.Group_Close:FindDirect("Img_Talk/Label")
  self._uiObjs.Group_Open = self.m_node:FindDirect("Group_Open")
  self._uiObjs.Group_CurTurn = self._uiObjs.Group_Open:FindDirect("Group_CurTurn")
  self._uiObjs.LabelCurRoundTitle = self._uiObjs.Group_CurTurn:FindDirect("Label_Name")
  self._uiObjs.LabelCurRoundTime = self._uiObjs.Group_CurTurn:FindDirect("Label_CurTurnTime")
  self._uiObjs.Group_NextTurn = self._uiObjs.Group_Open:FindDirect("Group_NextTurn")
  self._uiObjs.LabelNextRoundTitle = self._uiObjs.Group_NextTurn:FindDirect("Label_Name")
  self._uiObjs.LabelNextRoundTime = self._uiObjs.Group_NextTurn:FindDirect("Label_NextTurnTime")
  self._uiObjs.Group_CurMiddleTurn = self._uiObjs.Group_Open:FindDirect("Group_CurMiddleTurn")
  self._uiObjs.LabelLastRoundTitle = self._uiObjs.Group_CurMiddleTurn:FindDirect("Label_Name")
  self._uiObjs.LabelLastRoundTime = self._uiObjs.Group_CurMiddleTurn:FindDirect("Label_CurTurnTime")
  self._uiObjs.Img_End = self._uiObjs.Group_CurMiddleTurn:FindDirect("Img_End")
  self._uiObjs.Scrollview_Item = self._uiObjs.Group_Open:FindDirect("Group_Item/Scrollview_Item")
  self._uiObjs.uiScrollView = self._uiObjs.Scrollview_Item:GetComponent("UIScrollView")
  self._uiObjs.List = self._uiObjs.Scrollview_Item:FindDirect("List_Item")
  self._uiObjs.uiList = self._uiObjs.List:GetComponent("UIList")
  self._uiObjs.Label_HaveMoneyNum = self._uiObjs.Group_Open:FindDirect("Group_Bottom/Img_BgHaveMoney/Label_HaveMoneyNum")
  self._uiObjs.Label_HaveGoldNum = self._uiObjs.Group_Open:FindDirect("Group_Bottom/Img_BgHaveGold/Label_HaveGoldNum")
  self._uiObjs.Btn_NextTurn = self._uiObjs.Group_Open:FindDirect("Group_Bottom/Btn_NextTurn")
  self._uiObjs.Label_ChangeRound = self._uiObjs.Btn_NextTurn:FindDirect("Label")
end
def.method().UpdateUI = function(self)
  self:InitData()
  warn("[AuctionNode:UpdateUI] self._curAuctionId, self._curAuctionPeriodIdx, self._showRoundIdx:", self._curAuctionId, self._curAuctionPeriodIdx, self._showRoundIdx)
  if self._curAuctionId > 0 and self._curAuctionPeriodIdx > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_Close, false)
    GUIUtils.SetActive(self._uiObjs.Group_Open, true)
    self:ShowTimeIntervals()
    self:ShowRound(self._showRoundIdx, true, true)
    self:UpdateCurrency()
  else
    GUIUtils.SetActive(self._uiObjs.Group_Close, true)
    GUIUtils.SetActive(self._uiObjs.Group_Open, false)
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.CAuctionConsts.AUCTION_PRE_TIP_ID)
    GUIUtils.SetText(self._uiObjs.Close_Label, tipContent)
  end
end
def.method().InitData = function(self)
  self._curAuctionId = AuctionData.Instance():GetCurrentAuctionId()
  self._curAuctionPeriodIdx = AuctionData.Instance():GetCurrentAuctionPeriodIdx()
  self._roundInfoList = AuctionData.Instance():GetAuctionRounds(self._curAuctionId, self._curAuctionPeriodIdx)
  self._showRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  self._showRoundIdx = self._showRoundIdx > 0 and self._showRoundIdx or 1
end
def.override().OnHide = function(self)
  self:HandleEventListeners(false)
  self:_ClearTimer()
  if self._bReddot then
    self._bReddot = false
    AuctionModule.Instance():SetReddot(false, false)
  end
  self.itemTipHelper = nil
  self:_ClearList()
  self._uiObjs = nil
  self._curAuctionId = 0
  self._curAuctionPeriodIdx = 0
  self._showRoundIdx = 0
  self._itemInfoList = nil
  self._roundInfoList = nil
  self._ybCurrencyData = nil
  self._goldCurrencyData = nil
end
def.method("=>", "number")._GetRoundCount = function(self)
  return self._roundInfoList and #self._roundInfoList or 0
end
def.method().UpdateTabNotify = function(self)
  local bOpen = AuctionModule.Instance():IsFeatrueOpen(false)
  local Tab_AuctionHouse = self.m_node.parent:FindDirect("Tab_AuctionHouse")
  if bOpen then
    GUIUtils.SetActive(Tab_AuctionHouse, true)
    local hasNotify = gmodule.moduleMgr:GetModule(ModuleId.AUCTION):NeedReddot()
    local Img_Red = Tab_AuctionHouse:FindDirect("Img_Red")
    GUIUtils.SetActive(Img_Red, hasNotify)
  else
    GUIUtils.SetActive(Tab_AuctionHouse, false)
  end
end
def.method().UpdateRequirementsCondTbl = function(self)
end
def.method()._OnTimerUpdate = function(self)
  local itemCount = self._itemInfoList and #self._itemInfoList or 0
  if itemCount > 0 then
    for idx = 1, itemCount do
      self:UpdateAuctionItemTime(idx, nil, nil, nil)
    end
  end
  self:UpdateRoundState()
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method().ShowTimeIntervals = function(self)
  self:UpdateRoundState()
  local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  warn("[AuctionNode:ShowTimeIntervals] curRoundIdx:", curRoundIdx)
  if curRoundIdx <= 0 then
    GUIUtils.SetActive(self._uiObjs.Group_CurTurn, true)
    GUIUtils.SetActive(self._uiObjs.Group_NextTurn, true)
    GUIUtils.SetActive(self._uiObjs.Group_CurMiddleTurn, false)
    GUIUtils.SetText(self._uiObjs.LabelCurRoundTitle, textRes.Auction.AUCTION_ROUND_FIRST)
    local roundInfo1 = self._roundInfoList and self._roundInfoList[1]
    local timeText1 = AuctionUtils.GetDurationStartTimeText(roundInfo1 and roundInfo1.durationCfg)
    GUIUtils.SetText(self._uiObjs.LabelCurRoundTime, timeText1)
    GUIUtils.SetText(self._uiObjs.LabelNextRoundTitle, textRes.Auction.AUCTION_ROUND_NEXT)
    local roundInfo2 = self._roundInfoList and self._roundInfoList[2]
    local timeText2 = AuctionUtils.GetDurationStartTimeText(roundInfo2 and roundInfo2.durationCfg)
    GUIUtils.SetText(self._uiObjs.LabelNextRoundTime, timeText2)
  elseif curRoundIdx == self:_GetRoundCount() then
    GUIUtils.SetActive(self._uiObjs.Group_CurTurn, false)
    GUIUtils.SetActive(self._uiObjs.Group_NextTurn, false)
    GUIUtils.SetActive(self._uiObjs.Group_CurMiddleTurn, true)
    GUIUtils.SetText(self._uiObjs.LabelLastRoundTitle, textRes.Auction.AUCTION_ROUND_CURRENT)
    local roundInfo1 = self._roundInfoList and self._roundInfoList[curRoundIdx]
    local timeText1 = AuctionUtils.GetDurationStartTimeText(roundInfo1 and roundInfo1.durationCfg)
    GUIUtils.SetText(self._uiObjs.LabelLastRoundTime, timeText1)
  else
    GUIUtils.SetActive(self._uiObjs.Group_CurTurn, true)
    GUIUtils.SetActive(self._uiObjs.Group_NextTurn, true)
    GUIUtils.SetActive(self._uiObjs.Group_CurMiddleTurn, false)
    GUIUtils.SetText(self._uiObjs.LabelCurRoundTitle, textRes.Auction.AUCTION_ROUND_CURRENT)
    local roundInfo1 = self._roundInfoList and self._roundInfoList[curRoundIdx]
    local timeText1 = AuctionUtils.GetDurationStartTimeText(roundInfo1 and roundInfo1.durationCfg)
    GUIUtils.SetText(self._uiObjs.LabelCurRoundTime, timeText1)
    GUIUtils.SetText(self._uiObjs.LabelNextRoundTitle, textRes.Auction.AUCTION_ROUND_NEXT)
    local roundInfo2 = self._roundInfoList and self._roundInfoList[curRoundIdx + 1]
    local timeText2 = AuctionUtils.GetDurationStartTimeText(roundInfo2 and roundInfo2.durationCfg)
    GUIUtils.SetText(self._uiObjs.LabelNextRoundTime, timeText2)
  end
end
def.method().UpdateRoundState = function(self)
  local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  if curRoundIdx <= 0 then
  else
    if curRoundIdx == self:_GetRoundCount() then
      local itemMap = AuctionData.Instance():GetRoundItems(self._curAuctionId, curRoundIdx)
      local bAllOver = true
      if itemMap then
        for _, auctionItemInfo in pairs(itemMap) do
          if 0 < auctionItemInfo:GetCountDown() then
            bAllOver = false
            break
          end
        end
      end
      GUIUtils.SetActive(self._uiObjs.Img_End, bAllOver)
    else
    end
  end
end
def.method().UpdateCurrency = function(self)
  self:UpdateBuyYB()
  self:UpdateGold()
end
def.method().UpdateBuyYB = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.Label_HaveMoneyNum) then
    local haveCurrencyNum = ItemModule.Instance():getCashYuanBao()
    GUIUtils.SetText(self._uiObjs.Label_HaveMoneyNum, Int64.tostring(haveCurrencyNum))
  end
end
def.method().UpdateGold = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.Label_HaveGoldNum) then
    local haveCurrencyNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    GUIUtils.SetText(self._uiObjs.Label_HaveGoldNum, Int64.tostring(haveCurrencyNum))
  end
end
def.method("number", "boolean", "boolean").ShowRound = function(self, roundIdx, bNeedReq, bForce)
  if not bForce and roundIdx == self._showRoundIdx then
    return
  end
  if roundIdx <= 0 or roundIdx > self:_GetRoundCount() then
    warn("[ERROR][AuctionNode:ShowRound] invalid roundIdx:", roundIdx, self:_GetRoundCount())
    return
  end
  if bNeedReq and nil == AuctionData.Instance():GetRoundItems(self._curAuctionId, roundIdx) then
    AuctionProtocols.SendCGetAuctionInfoReq(self._curAuctionId, roundIdx)
  end
  self._showRoundIdx = roundIdx
  self:ShowItemList()
  self:UpdatePageButton()
end
def.method().ShowItemList = function(self)
  self:_ClearList()
  local itemMap = AuctionData.Instance():GetRoundItems(self._curAuctionId, self._showRoundIdx)
  self._itemInfoList = {}
  if itemMap then
    for cfgId, info in pairs(itemMap) do
      table.insert(self._itemInfoList, info)
    end
    table.sort(self._itemInfoList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local itemA = AuctionData.Instance():GetAuctionItemCfg(a.auctionItemId)
        local itemB = AuctionData.Instance():GetAuctionItemCfg(b.auctionItemId)
        if itemA and itemB and itemA.itemTypeId ~= itemB.itemTypeId then
          return itemA.itemTypeId < itemB.itemTypeId
        else
          return a.auctionItemId < b.auctionItemId
        end
      end
    end)
  end
  local itemCount = self._itemInfoList and #self._itemInfoList or 0
  self._uiObjs.uiList.itemCount = itemCount
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
  for idx = 1, itemCount do
    self:ShowAuctionItem(idx)
  end
end
def.method("number").ShowAuctionItem = function(self, idx)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][AuctionNode:ShowAuctionItem] listItem nil at idx:", idx)
    return
  end
  local auctionItemInfo = self._itemInfoList and self._itemInfoList[idx]
  if nil == auctionItemInfo then
    warn("[ERROR][AuctionNode:ShowAuctionItem] auctionItemInfo nil at idx:", idx)
    return
  end
  local auctionItemCfg = AuctionData.Instance():GetAuctionItemCfg(auctionItemInfo.auctionItemId)
  if nil == auctionItemCfg then
    warn("[ERROR][AuctionNode:ShowAuctionItem] auctionItemCfg nil for auctionItemInfo.auctionItemId:", auctionItemInfo.auctionItemId)
    return
  end
  local itemBase = ItemUtils.GetItemBase(auctionItemCfg.itemCfgId)
  if nil == itemBase then
    warn("[ERROR][AuctionNode:ShowAuctionItem] itemBase nil for auctionItemCfg.itemCfgId:", auctionItemCfg.itemCfgId)
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
  self:UpdateAuctionItemState(idx, listItem, auctionItemInfo, auctionItemCfg)
end
def.method("number", "userdata", "table", "table").UpdateAuctionItemState = function(self, idx, listItem, auctionItemInfo, auctionItemCfg)
  if nil == listItem then
    listItem = self._uiObjs.uiList.children[idx]
  end
  if nil == listItem then
    warn("[ERROR][AuctionNode:UpdateAuctionItemState] listItem nil at idx:", idx)
    return
  end
  if nil == auctionItemInfo then
    auctionItemInfo = self._itemInfoList and self._itemInfoList[idx]
  end
  if nil == auctionItemInfo then
    warn("[ERROR][AuctionNode:UpdateAuctionItemState] auctionItemInfo nil at idx:", idx)
    return
  end
  if nil == auctionItemCfg then
    auctionItemCfg = AuctionData.Instance():GetAuctionItemCfg(auctionItemInfo.auctionItemId)
  end
  if nil == auctionItemCfg then
    warn("[ERROR][AuctionNode:UpdateAuctionItemState] auctionItemCfg nil for auctionItemInfo.auctionItemId:", auctionItemInfo.auctionItemId)
    return
  end
  local bRoundBegin = self:HasRoundBegin(self._showRoundIdx)
  local Label_CurPeople = listItem:FindDirect("Label_CurPeople_" .. idx)
  local peopleText = bRoundBegin and string.format(textRes.Auction.AUCTION_ITEM_BIT_COUNT, auctionItemInfo.bidderCount) or textRes.Auction.AUCTION_ITEM_BIT_NA
  GUIUtils.SetText(Label_CurPeople, peopleText)
  local Label_CurPriceNum = listItem:FindDirect("Group_CurPrice_" .. idx .. "/Label_CurPriceNum_" .. idx)
  local bitText = bRoundBegin and Int64.tostring(auctionItemInfo.maxBidPrice) or textRes.Auction.AUCTION_ITEM_BIT_NA
  GUIUtils.SetText(Label_CurPriceNum, bitText)
  self:UpdateAuctionItemTime(idx, listItem, auctionItemInfo, auctionItemCfg)
end
def.method("number", "=>", "boolean").HasRoundBegin = function(self, roundIdx)
  local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  return roundIdx <= curRoundIdx
end
def.method("number", "userdata", "table", "table").UpdateAuctionItemTime = function(self, idx, listItem, auctionItemInfo, auctionItemCfg)
  if nil == listItem then
    listItem = self._uiObjs.uiList.children[idx]
  end
  if nil == listItem then
    warn("[ERROR][AuctionNode:UpdateAuctionItemTime] listItem nil at idx:", idx)
    return
  end
  if nil == auctionItemInfo then
    auctionItemInfo = self._itemInfoList and self._itemInfoList[idx]
  end
  if nil == auctionItemInfo then
    warn("[ERROR][AuctionNode:UpdateAuctionItemTime] auctionItemInfo nil at idx:", idx)
    return
  end
  if nil == auctionItemCfg then
    auctionItemCfg = AuctionData.Instance():GetAuctionItemCfg(auctionItemInfo.auctionItemId)
  end
  if nil == auctionItemCfg then
    warn("[ERROR][AuctionNode:UpdateAuctionItemTime] auctionItemCfg nil for auctionItemInfo.auctionItemId:", auctionItemInfo.auctionItemId)
    return
  end
  local Label_RestTime = listItem:FindDirect("Label_RestTime_" .. idx)
  local Group_Buy = listItem:FindDirect("Group_Buy_" .. idx)
  local Btn_Join = Group_Buy:FindDirect("Btn_Join_" .. idx)
  local Group_CloseTime = Group_Buy:FindDirect("Group_CloseTime_" .. idx)
  local Label_CloseTime = Group_CloseTime:FindDirect("Label_CloseTime_" .. idx)
  local Img_Sold = listItem:FindDirect("Img_Sold_" .. idx)
  local Img_Passin = listItem:FindDirect("Img_Passin_" .. idx)
  if self:HasRoundBegin(self._showRoundIdx) then
    GUIUtils.SetActive(Btn_Join, true)
    GUIUtils.SetActive(Group_CloseTime, false)
    local countdown = auctionItemInfo:GetCountDown()
    GUIUtils.SetText(Label_RestTime, AuctionUtils.GetCountdownText(countdown))
    if countdown > 0 then
      GUIUtils.EnableButton(Btn_Join, true)
      GUIUtils.SetActive(Img_Sold, false)
      GUIUtils.SetActive(Img_Passin, false)
    else
      GUIUtils.EnableButton(Btn_Join, false)
      GUIUtils.SetActive(Img_Sold, auctionItemInfo:IsBidded())
      GUIUtils.SetActive(Img_Passin, not auctionItemInfo:IsBidded())
    end
  else
    GUIUtils.SetActive(Btn_Join, false)
    GUIUtils.SetActive(Group_CloseTime, true)
    GUIUtils.SetActive(Img_Sold, false)
    GUIUtils.SetActive(Img_Passin, false)
    GUIUtils.SetText(Label_RestTime, textRes.Auction.AUCTION_ITEM_BIT_NOT_START)
    local countdown = self:GetRoundCountDown(self._showRoundIdx)
    GUIUtils.SetText(Label_CloseTime, AuctionUtils.GetCountdownText(countdown))
  end
end
def.method("number", "=>", "number").GetRoundCountDown = function(self, roundIdx)
  local curTime = _G.GetServerTime()
  local roundInfo = self._roundInfoList and self._roundInfoList[roundIdx]
  local startTime, endTime = AuctionUtils.GetDurationStartEndTime(roundInfo and roundInfo.durationCfg)
  return math.max(startTime - curTime, 0)
end
def.method()._ClearList = function(self)
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiList) then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method().UpdatePageButton = function(self)
  if self._showRoundIdx > 0 and AuctionData.Instance():GetCurrentAuctionRoundIdx() <= 1 then
    GUIUtils.SetActive(self._uiObjs.Btn_NextTurn, true)
    if self._showRoundIdx == 1 then
      GUIUtils.SetText(self._uiObjs.Label_ChangeRound, textRes.Auction.AUCTION_SHOW_NEXT_ROUND)
    else
      GUIUtils.SetText(self._uiObjs.Label_ChangeRound, textRes.Auction.AUCTION_SHOW_PRE_ROUND)
    end
  else
    GUIUtils.SetActive(self._uiObjs.Btn_NextTurn, false)
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Tips" then
    self:OnBtn_Help()
  elseif id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Refresh" then
    self:OnBtn_Refresh()
  elseif id == "Btn_Add" then
    self:OnBtn_Add(clickObj)
  elseif id == "Btn_NextTurn" then
    self:OnBtn_NextTurn()
  elseif id == "Btn_RankList" then
    self:OnBtn_RankList()
  elseif string.find(id, "Btn_Join") then
    self:OnBtn_Join(clickObj)
  elseif string.find(id, "Img_BgIcon") then
    self.itemTipHelper:CheckItem2ShowTip(id, -1, true)
  end
end
def.method().OnBtn_Help = function(self)
  GUIUtils.ShowHoverTip(constant.CAuctionConsts.AUCTION_FUN_TIP_ID, 0, 0)
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Refresh = function(self)
  AuctionProtocols.SendCGetAuctionInfoReq(self._curAuctionId, self._showRoundIdx)
end
def.method("userdata").OnBtn_Add = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent and parent.name == "Img_BgHaveMoney" then
    if self._ybCurrencyData then
      self._ybCurrencyData:Acquire()
    end
  elseif self._goldCurrencyData then
    self._goldCurrencyData:Acquire()
  end
end
def.method().OnBtn_NextTurn = function(self)
  if self._showRoundIdx > 0 then
    GUIUtils.SetActive(self._uiObjs.Btn_NextTurn, true)
    self._uiObjs.uiScrollView:ResetPosition()
    if self._showRoundIdx == 1 then
      self:ShowRound(self._showRoundIdx + 1, true, true)
    else
      self:ShowRound(self._showRoundIdx - 1, true, true)
    end
  end
end
def.method().OnBtn_RankList = function(self)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  require("Main.Auction.ui.AuctionBidderListPanel").ShowPanel()
end
def.method("userdata").OnBtn_Join = function(self, clickObj)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local togglePrefix = "Btn_Join_"
  local id = clickObj.name
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local auctionItemInfo = self._itemInfoList and self._itemInfoList[index]
  if auctionItemInfo then
    require("Main.Auction.ui.AuctionBidPanel").ShowPanel(auctionItemInfo)
  else
    warn("[ERROR][AuctionNode:OnBtn_Join] auctionItemInfo nil for index:", index)
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  if isRigister then
    Event.RegisterEventWithContext(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_CHANGE, AuctionNode.OnRoundChange, self)
    Event.RegisterEventWithContext(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ITEM_INFO_CHANGE, AuctionNode.OnItemInfoChange, self)
    Event.RegisterEventWithContext(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_PERIOD_CHANGE, AuctionNode.OnPeriodChange, self)
    Event.RegisterEventWithContext(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_ITEMS_CHANGE, AuctionNode.OnRoundItemsChange, self)
    Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, AuctionNode.OnBuyYBChange, self)
    Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, AuctionNode.OnGoldChange, self)
  else
    Event.UnregisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_CHANGE, AuctionNode.OnRoundChange)
    Event.UnregisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ITEM_INFO_CHANGE, AuctionNode.OnItemInfoChange)
    Event.UnregisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_PERIOD_CHANGE, AuctionNode.OnPeriodChange)
    Event.UnregisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_ITEMS_CHANGE, AuctionNode.OnRoundItemsChange)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, AuctionNode.OnBuyYBChange)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, AuctionNode.OnGoldChange)
  end
end
def.method("table").OnRoundChange = function(self, params)
  warn("[AuctionNode:OnRoundChange] On AUCTION_ROUND_CHANGE.")
  if not _G.IsNil(self.m_node) and self.isShow then
    self:UpdateUI()
  end
end
def.method("table").OnItemInfoChange = function(self, params)
  if not _G.IsNil(self.m_node) and self.isShow then
    local roundIdx = params and params.roundIdx or 0
    local auctionItemId = params and params.auctionItemId or 0
    warn("[AuctionNode:OnItemInfoChange] roundIdx, auctionItemId:", roundIdx, auctionItemId, debug.traceback())
    if roundIdx == self._showRoundIdx and auctionItemId > 0 and self._itemInfoList and 0 < #self._itemInfoList then
      for idx, auctionItemInfo in ipairs(self._itemInfoList) do
        if auctionItemInfo.auctionItemId == auctionItemId then
          self:UpdateAuctionItemState(idx, nil, auctionItemInfo, nil)
        end
      end
    end
  end
end
def.method("table").OnPeriodChange = function(self, params)
  warn("[AuctionNode:OnPeriodChange] On AUCTION_PERIOD_CHANGE.")
  if not _G.IsNil(self.m_node) and self.isShow then
    local auctionId = params and params.auctionId or 0
    local periodIdx = params and params.periodIdx or 0
    self:UpdateUI()
  end
end
def.method("table").OnRoundItemsChange = function(self, params)
  warn("[AuctionNode:OnRoundItemsChange] On AUCTION_ROUND_ITEMS_CHANGE.")
  if not _G.IsNil(self.m_node) and self.isShow then
    local roundIdx = params and params.roundIdx or 0
    local activityId = params and params.activityId or 0
    if self._curAuctionId == activityId and roundIdx == self._showRoundIdx then
      self:ShowItemList()
    end
  end
end
def.static("table", "table").OnBuyYBChange = function(params, context)
  AuctionNode.Instance():UpdateBuyYB()
end
def.static("table", "table").OnGoldChange = function(params, context)
  AuctionNode.Instance():UpdateGold()
end
AuctionNode.Commit()
return AuctionNode
