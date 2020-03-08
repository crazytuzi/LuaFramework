local Lplus = require("Lplus")
local TradingArcadeTabGroup = require("Main.TradingArcade.ui.TradingArcadeTabGroup")
local ECPanelBase = require("GUI.ECPanelBase")
local INotify = import(".INotify")
local BuyAndPublicCommon = Lplus.Extend(TradingArcadeTabGroup, "BuyAndPublicCommon").Implement(INotify)
local GUIUtils = require("GUI.GUIUtils")
local BuyViewdata = require("Main.TradingArcade.viewdata.BuyViewdata")
local ItemUtils = require("Main.Item.ItemUtils")
local PetUtility = require("Main.Pet.PetUtility")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local SearchMgr = require("Main.TradingArcade.SearchMgr")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local Vector = require("Types.Vector")
local TradingArcadeNode = Lplus.ForwardDeclare("TradingArcadeNode")
local SearchBase = require("Main.TradingArcade.SearchBase")
local GoodsData = require("Main.TradingArcade.data.GoodsData")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local BidMgr = require("Main.TradingArcade.BidMgr")
local ItemModule = require("Main.Item.ItemModule")
local def = BuyAndPublicCommon.define
local CONCERN_SIDE_INDEX = -1
local BID_SIDE_INDEX = 0
local CONCERN_SUBTYPE = 1
local BID_SUBTYPE = 2
def.const("number").PAGE_MAX_ITEM_COUNT = constant.MarketConsts.PAGE_SIZE
def.const("number").GOLD_INGOT_TIPS_ID = 701600500
def.const("table").PriceSort = {Asc = 0, Dsc = 1}
def.const("number").SUBTYPE_GOODS_NUM_DURATION = 30
def.field("boolean").m_isUIInited = false
def.field("table").uiObjs = nil
def.field("number").lastSideIndex = -1
def.field("number").lastSubType = 0
def.field("table").lastPageItems = nil
def.field("table").mainTypes = nil
def.field("number").selItemIndex = 0
def.field("number").curPage = 0
def.field("number").nextPage = 0
def.field("table").itemTip = nil
def.field("boolean").nextShowGoodsDetail = false
def.field("number").priceSort = 0
def.field("number").lastSiftLevel = 0
def.field("table").levelConditions = nil
def.field("table").pageHistorys = nil
def.field("table").searchWrapper = nil
def.field("table").subtypeGoodsNums = nil
BuyAndPublicCommon._lastSideIndex = -1
BuyAndPublicCommon._lastSubType = 0
BuyAndPublicCommon._curPage = 0
BuyAndPublicCommon._lastSiftLevel = 0
BuyAndPublicCommon._pageHistorys = {}
BuyAndPublicCommon._subtypeGoodsNums = {}
def.static().Clear = function()
  BuyAndPublicCommon._subtypeGoodsNums = {}
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TradingArcadeTabGroup.Init(self, base, node)
end
def.method().SaveState = function(self)
  BuyAndPublicCommon._lastSideIndex = self.lastSideIndex
  BuyAndPublicCommon._lastSubType = self.lastSubType
  BuyAndPublicCommon._curPage = self.curPage
  BuyAndPublicCommon._lastSiftLevel = self.lastSiftLevel
  BuyAndPublicCommon._pageHistorys = self.pageHistorys
end
def.method().LoadState = function(self)
  self.lastSideIndex = BuyAndPublicCommon._lastSideIndex
  self.lastSubType = BuyAndPublicCommon._lastSubType
  self.curPage = BuyAndPublicCommon._curPage
  self.lastSiftLevel = BuyAndPublicCommon._lastSiftLevel
  self.pageHistorys = BuyAndPublicCommon._pageHistorys
  self.subtypeGoodsNums = BuyAndPublicCommon._subtypeGoodsNums[BuyServiceMgr.Instance().m_mode]
  if self.subtypeGoodsNums == nil then
    self.subtypeGoodsNums = {}
  end
  BuyAndPublicCommon._subtypeGoodsNums[BuyServiceMgr.Instance().m_mode] = self.subtypeGoodsNums
end
def.virtual("=>", "boolean").HasNotify = function(self)
  return false
end
def.virtual("=>", "boolean").HasSearchNotify = function(self)
  return false
end
def.method("=>", "boolean").InitUI = function(self)
  if self.m_isUIInited then
    return false
  end
  self.uiObjs = {}
  self.uiObjs.Group_BuyList = self.m_node:FindDirect("Group_BuyList01")
  self.uiObjs.ScrollView_BuyList = self.uiObjs.Group_BuyList:FindDirect("Scroll View_BugList")
  self.uiObjs.Table_BuyList = self.uiObjs.ScrollView_BuyList:FindDirect("Table_BugList")
  self.uiObjs.Template_BgBuyList = self.uiObjs.Table_BuyList:FindDirect("Img_BgBuyList")
  self.uiObjs.Template_BgBuyList:SetActive(false)
  self.uiObjs.Img_BgBuyItem = self.m_node:FindDirect("Img_BgBuyItem")
  self.uiObjs.ScrollView_BuyItem = self.uiObjs.Img_BgBuyItem:FindDirect("Scroll View_BuyItem")
  self.uiObjs.Group_NoTings = self.uiObjs.Img_BgBuyItem:FindDirect("Group_NoTings")
  self.uiObjs.Grid_Page = self.uiObjs.ScrollView_BuyItem:FindDirect("Grid_Page")
  self.uiObjs.Template_Group_BuyItem = self.uiObjs.Grid_Page:FindDirect("Group_BuyItem")
  self.uiObjs.Template_Group_BuyItem:SetActive(false)
  local Label_CollectNum = self.uiObjs.Template_Group_BuyItem:FindDirect("Group_DetailItemInfo/Label_CollectNum")
  local boxCollider = Label_CollectNum:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = Label_CollectNum:AddComponent("BoxCollider")
    local uiWidget = Label_CollectNum:GetComponent("UIWidget")
    uiWidget.autoResizeBoxCollider = true
    uiWidget:ResizeCollider()
    self.m_base.m_msgHandler:Touch(Label_CollectNum)
  end
  self.uiObjs.Group_BtnBottom = self.m_node:FindDirect("Group_BtnBottom")
  self.uiObjs.Img_BgMoney = self.uiObjs.Group_BtnBottom:FindDirect("Img_BgMoney")
  self.uiObjs.Btn_Buy = self.uiObjs.Group_BtnBottom:FindDirect("Btn_Buy")
  self.uiObjs.Btn_Collect = self.uiObjs.Group_BtnBottom:FindDirect("Btn_Collect")
  self.uiObjs.Btn_Jingjia = self.uiObjs.Group_BtnBottom:FindDirect("Btn_Jingjia")
  self.uiObjs.Label_Page = self.uiObjs.Group_BtnBottom:FindDirect("Img_BgPage/Label_Page")
  local boxCollider = self.uiObjs.Label_Page:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = self.uiObjs.Label_Page:AddComponent("BoxCollider")
    local uiWidget = self.uiObjs.Label_Page:GetComponent("UIWidget")
    uiWidget.autoResizeBoxCollider = true
    uiWidget:ResizeCollider()
    self.m_base.m_msgHandler:Touch(self.uiObjs.Label_Page)
  end
  self.uiObjs.Label_CantBuy = self.uiObjs.Group_BtnBottom:FindDirect("Label_CantBuy")
  self.uiObjs.Label_Btn_Collect = self.uiObjs.Group_BtnBottom:FindDirect("Btn_Collect/Label")
  self.uiObjs.Group_DetailBtn = self.m_node:FindDirect("Group_DetailBtn")
  self.uiObjs.Btn_Level = self.uiObjs.Group_DetailBtn:FindDirect("Btn_Level")
  self.uiObjs.Table_LvBtn = self.uiObjs.Group_DetailBtn:FindDirect("Panel/Table_LvBtn")
  self.uiObjs.Btn_Search = self.m_node.parent:FindDirect("Btn_Search")
  self.uiObjs.Btn_Search:SetActive(true)
  self:UpdateBtnSearchNotify()
  self.uiObjs.Img_Bid = self.m_node:FindDirect("Img_Bid")
  GUIUtils.SetActive(self.uiObjs.Img_Bid, false)
  if self.uiObjs.Img_Bid then
    self.uiObjs.Img_Bid.localPosition = Vector.Vector3.zero
  end
  self.m_isUIInited = true
  return true
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, BuyAndPublicCommon.OnSellGoodsPageUpdate, self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, BuyAndPublicCommon.OnSellGoodsUpdate, self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.CONCERN_GOODS_LIST_UPDATE, BuyAndPublicCommon.OnConcernGoodsListUpdate, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, BuyAndPublicCommon.OnMoneyGoldIngotChanged, self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SYNC_SEARCH_RESULT, BuyAndPublicCommon.OnSynSearchResult, self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, BuyAndPublicCommon.OnSearchNotifyUpdate, self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.BID_GOODS_LIST_UPDATE, BuyAndPublicCommon.OnBidGoodsUpdate, self)
  Event.RegisterEventWithContext(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, BuyAndPublicCommon.OnTradingNotifyUpdate, self)
  self:LoadState()
  BidMgr.Instance():QueryAllBidGoodsReq()
  if self:InitUI() then
    self:UpdateMoneyNum()
    self:UpdateLeftSideMenu()
    self:ValidateLastIndexes()
    self:SelectSideMenu(self.lastSideIndex)
  end
end
def.override().OnHide = function(self)
  self:SaveState()
  self.m_isUIInited = false
  self.uiObjs = nil
  self.itemTip = nil
  self.nextShowGoodsDetail = false
  self.searchWrapper = nil
  BuyServiceMgr.Instance():ClearAllGoods()
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, BuyAndPublicCommon.OnSellGoodsPageUpdate)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_UPDATE, BuyAndPublicCommon.OnSellGoodsUpdate)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.CONCERN_GOODS_LIST_UPDATE, BuyAndPublicCommon.OnConcernGoodsListUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, BuyAndPublicCommon.OnMoneyGoldIngotChanged)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SYNC_SEARCH_RESULT, BuyAndPublicCommon.OnSynSearchResult)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, BuyAndPublicCommon.OnSearchNotifyUpdate)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.BID_GOODS_LIST_UPDATE, BuyAndPublicCommon.OnBidGoodsUpdate)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, BuyAndPublicCommon.OnTradingNotifyUpdate)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  local out = {}
  if self:GetObjIndex(id, "Btn_Lv_", out) then
    self:SelectSiftLevel(out.index)
    return
  end
  if id == "Btn_Level" then
    self:OnLevelBtnClick()
    return
  end
  self:OpenLevelSiftList(false)
  self:ShowBidTip(false)
  if self:GetObjIndex(id, "Img_BgBuyList_", out) then
    self:OnSideMenuItemClicked(out.index)
  elseif self:GetObjIndex(id, "Group_BuyItem_", out) then
    self:OnItemGroupClicked(out.index)
  elseif id == "Img_BgItem" then
    self:OnItemIconObjClicked(clickobj)
  elseif id == "Btn_Buy" then
    self:OnBtnBuyClicked()
  elseif id == "Btn_Collect" then
    self:OnBtnCollectClicked()
  elseif id == "Btn_Back" then
    self:OnBackPageClicked()
  elseif id == "Btn_Next" then
    self:OnNextPageClicked()
  elseif id == "Label_Page" then
    self:OnLabelPageClicked()
  elseif id == "Btn_Price" then
    self:OnPriceSortBtnClick()
  elseif id == "Btn_Tips" then
    self:OnQuestionGoldIngotBtnClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif id == "Btn_Search" then
    self:OnSearchBtnClick()
  elseif id == "Label_CollectNum" then
    self:OnCollectNumObjClick(clickobj)
  elseif id == "Btn_Add" then
    _G.GoToBuyGoldIngot()
  elseif id == "Btn_Jingjia" then
    self:OnBidBtnClick()
  elseif id == "Btn_GetItem" then
    self:OnGetBidGoodsBtnClick()
  end
end
def.override("string").onDragStart = function(self, id)
end
def.override("string").onDragEnd = function(self, id)
  if string.find(id, "Group_BuyItem_") or string.find(id, "Img_BgItem") then
    self:DragScrollView()
  end
end
def.method().DragScrollView = function(self)
  local dragAmount = self.uiObjs.ScrollView_BuyItem:GetComponent("UIScrollView"):GetDragAmount()
  if dragAmount.y > 1.1 then
    self:OnNextPageClicked()
  elseif dragAmount.y < -0.1 then
    self:OnBackPageClicked()
  end
end
def.virtual().UpdateStateBtn = function(self)
end
def.method("boolean").ShowBuyBtn = function(self, isShow)
  GUIUtils.SetActive(self.uiObjs.Btn_Buy, isShow)
  GUIUtils.SetActive(self.uiObjs.Label_CantBuy, false)
  GUIUtils.SetActive(self.uiObjs.Btn_Jingjia, not isShow)
end
def.method("boolean").ShowDeleteBidBtn = function(self, isShow)
  local Label = self.uiObjs.Btn_Collect:FindDirect("Label")
  local text
  if isShow then
    text = textRes.TradingArcade[59]
  else
    text = textRes.TradingArcade[58]
  end
  GUIUtils.SetText(Label, text)
end
def.method("string", "string", "table", "=>", "boolean").GetObjIndex = function(self, id, name, out)
  if string.sub(id, 1, #name) == name then
    out.index = tonumber(string.sub(id, #name + 1, -1))
    return true
  end
  return false
end
def.method("userdata").SetGoldBullionNum = function(self, num)
  local Label_MoneyNum = self.uiObjs.Img_BgMoney:FindDirect("Label_MoneyNum")
  GUIUtils.SetText(Label_MoneyNum, tostring(num))
end
def.method("table").SetLeftSideMenu = function(self, viewdata)
  local iconId = _G.constant.MarketConsts.CONCERN_ICON_ID
  self:SetLeftSideMenuItem(CONCERN_SIDE_INDEX, {iconId = iconId})
  local iconId = _G.constant.MarketConsts.AUCTIOn_ICON_ID or 0
  self:SetLeftSideMenuItem(BID_SIDE_INDEX, {iconId = iconId})
  for i, v in ipairs(viewdata) do
    self:SetLeftSideMenuItem(i, v)
  end
  local childCount = self.uiObjs.Table_BuyList.childCount
  for i = 3 + #viewdata, childCount - 1 do
    local child = self.uiObjs.Table_BuyList:GetChild(i)
    GameObject.Destroy(child)
  end
  self.uiObjs.Table_BuyList:GetComponent("UITable"):Reposition()
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    if self.uiObjs and self.uiObjs.Table_BuyList.isnil == false then
      self.uiObjs.Table_BuyList:GetComponent("UITable"):Reposition()
    end
  end)
  self.m_base.m_msgHandler:Touch(self.uiObjs.Table_BuyList)
end
def.method("number", "table").SetLeftSideMenuItem = function(self, index, viewdata)
  local itemObjName = "Img_BgBuyList_" .. index
  local itemObj = self.uiObjs.Table_BuyList:FindDirect(itemObjName)
  if itemObj == nil then
    itemObj = GameObject.Instantiate(self.uiObjs.Template_BgBuyList)
    itemObj:SetActive(true)
    itemObj.name = itemObjName
    itemObj.transform.parent = self.uiObjs.Table_BuyList.transform
    itemObj.transform.localScale = Vector.Vector3.one
  end
  local Texture_Icon = itemObj:FindDirect("Texture_Icon")
  GUIUtils.SetTexture(Texture_Icon, viewdata.iconId)
  local Img_Red = itemObj:FindDirect("Img_Red")
  local hasNotify = false
  if index == BID_SIDE_INDEX and index ~= CONCERN_SIDE_INDEX then
    hasNotify = BidMgr.Instance():HasNotify()
  end
  GUIUtils.SetActive(Img_Red, hasNotify)
end
def.method().UpdateMoneyNum = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
  self:SetGoldBullionNum(haveNum)
end
def.method().UpdateLeftSideMenu = function(self)
  local viewdata = BuyViewdata.Instance():GetAllTypes()
  self.mainTypes = viewdata
  self:SetLeftSideMenu(viewdata)
end
def.method("number").OnSideMenuItemClicked = function(self, index)
  self.searchWrapper = nil
  self.lastSubType = 0
  BuyServiceMgr.Instance():ClearAllGoods()
  self:SelectSideMenu(index)
end
def.method().ValidateLastIndexes = function(self)
  if self.lastSideIndex >= 1 and self.mainTypes[self.lastSideIndex] == nil then
    self.lastSideIndex = CONCERN_SIDE_INDEX
    self.lastSubType = 0
  elseif self.lastSideIndex >= 1 then
    local subIds = self.mainTypes[self.lastSideIndex].subIds
    local list = BuyViewdata.Instance():GetSubTypesViewdatas(subIds)
    local hasFound = true
    for i, v in ipairs(list) do
      if v.subId == self.lastSubType then
        hasFound = true
        break
      end
    end
    if not hasFound then
      self.lastSubType = 0
    end
  end
end
def.method("number").SelectSideMenu = function(self, index)
  self.lastSideIndex = index
  local historyPage = self.pageHistorys[index] or 1
  if self.searchWrapper then
    historyPage = 1
  end
  self.curPage = historyPage
  self.nextPage = historyPage
  self.selItemIndex = 0
  self.priceSort = BuyAndPublicCommon.PriceSort.Asc
  self:OpenLevelSiftList(false)
  local Img_BgBuyList = self.uiObjs.Table_BuyList:FindDirect("Img_BgBuyList_" .. index)
  GUIUtils.Toggle(Img_BgBuyList, true)
  if index == CONCERN_SIDE_INDEX then
    BuyServiceMgr.Instance():CQueryAllConcernReq()
    self.lastSubType = 1
    self:ShowBuyItemScrollView(false)
    self:UpdateConernItemList()
  elseif index == BID_SIDE_INDEX then
    self:OpenMyBidGoodsList()
  else
    local subIdList = self.mainTypes[index].subIds
    local list = BuyViewdata.Instance():GetSubTypesViewdatas(subIdList)
    local count = #list
    if self.lastSubType == 0 then
      list.isSubType = true
      self.lastPageItems = list
      self:UpdateSubTypeItemList()
    else
      self.curPage = 1
      self.nextPage = self.curPage
      local isAsc = true
      for i, v in ipairs(list) do
        if v.subId == self.lastSubType then
          isAsc = v.isAsc
          break
        end
      end
      if not isAsc then
        self.priceSort = BuyAndPublicCommon.PriceSort.Dsc
      end
      self:UpdateLevelSiftConditions()
      self.lastPageItems = {isSubType = false}
      self:ShowBuyItemScrollView(false)
      self:UpdateGoodsPageInfo()
    end
    self:UpdateStateBtn()
  end
  local num = 0
  local totalNum = 0
  if 0 < #self.lastPageItems then
    num = self.curPage
    totalNum = self:GetTotalPage()
  end
  self:SetPageNums(num, totalNum)
end
def.method().OpenMyBidGoodsList = function(self)
  self.lastSubType = BID_SUBTYPE
  self:ShowBuyItemScrollView(false)
  BidMgr.Instance():QueryAllBidGoodsReq()
  self:UpdateMyBidGoodsList()
end
def.method().UpdateMyBidGoodsList = function(self)
  self.lastPageItems = {}
  local list = BidMgr.Instance():GetBidGoodsList()
  for i, v in ipairs(list) do
    self.lastPageItems[i] = v
  end
  self.lastPageItems.isSubType = false
  self:SetItemList(self.lastPageItems)
  self:UpdatePageNums()
  self:ShowBuyBtn(false)
  self:ShowDeleteBidBtn(true)
end
def.method().UpdateConernItemList = function(self)
  self.lastPageItems = {}
  local list = BuyServiceMgr.Instance():GetConcernGoodsList()
  for i, v in ipairs(list) do
    self.lastPageItems[i] = v
  end
  self.lastPageItems.isSubType = false
  self:SetItemList(self.lastPageItems)
  self:UpdatePageNums()
  self:ShowBuyBtn(true)
end
def.method().UpdateSubTypeItemList = function(self)
  local startIndex = (self.curPage - 1) * BuyAndPublicCommon.PAGE_MAX_ITEM_COUNT + 1
  local endIndex = math.min(startIndex + BuyAndPublicCommon.PAGE_MAX_ITEM_COUNT - 1, #self.lastPageItems)
  local count = endIndex - startIndex + 1
  local list = {isSubType = true}
  for i = startIndex, endIndex do
    table.insert(list, self.lastPageItems[i])
  end
  self:SetItemList(list)
  self:UpdatePageNums()
  self.pageHistorys[self.lastSideIndex] = self.curPage
  local needQueryGoodsNums = false
  local subTypeInfo = list[1]
  if subTypeInfo then
    local subId = subTypeInfo.subId
    local goodNumInfo = self.subtypeGoodsNums[subId]
    local curTime = _G.GetServerTime()
    if goodNumInfo == nil or curTime > goodNumInfo.expireTime then
      needQueryGoodsNums = true
    end
  end
  if needQueryGoodsNums then
    do
      local curTime = _G.GetServerTime()
      local subIds = {}
      for i, v in ipairs(list) do
        local subId = v.subId
        local goodNumInfo = {}
        goodNumInfo.expireTime = curTime + BuyAndPublicCommon.SUBTYPE_GOODS_NUM_DURATION
        goodNumInfo.num = 0
        self.subtypeGoodsNums[subId] = goodNumInfo
        subIds[subId] = subId
      end
      local pubOrSell = BuyServiceMgr.Instance().m_mode
      local lastSideIndex = self.lastSideIndex
      local lastPage = self.curPage
      TradingArcadeProtocol.CQueryPubOrSellNumberReq(pubOrSell, subIds, function(p)
        if self.uiObjs == nil then
          return
        end
        if p.pubOrsell ~= BuyServiceMgr.Instance().m_mode then
          return
        end
        for subId, num in pairs(p.subid2num) do
          self.subtypeGoodsNums[subId].num = num
        end
        if lastSideIndex == self.lastSideIndex and lastPage == self.curPage then
          self:UpdateSubTypeItemList()
        end
      end)
    end
  end
end
def.method().UpdatePageNums = function(self)
  local num = self.curPage
  local totalNum = self:GetTotalPage()
  self:SetPageNums(num, totalNum)
end
def.method("boolean").ShowBuyItemScrollView = function(self, isShow)
  GUIUtils.SetActive(self.uiObjs.ScrollView_BuyItem, isShow)
  GUIUtils.SetActive(self.uiObjs.Group_NoTings, not isShow)
  local label = self.uiObjs.Group_NoTings:FindDirect("Img_Pao/Label")
  local text
  if self.lastSideIndex == CONCERN_SIDE_INDEX then
    text = textRes.TradingArcade[41]
  elseif self.lastSideIndex == BID_SIDE_INDEX then
    text = textRes.TradingArcade[51]
  else
    text = textRes.TradingArcade[42]
  end
  GUIUtils.SetText(label, text or "")
end
def.method("table").SetItemList = function(self, viewdata)
  local count = #viewdata
  if count > 0 then
    self:ShowBuyItemScrollView(true)
  else
    self:ShowBuyItemScrollView(false)
  end
  self:ResizeGridList(count)
  for i, v in ipairs(viewdata) do
    self:SetItemInfo(i, v)
  end
  self:UpdateItemListUI(viewdata)
  self.uiObjs.ScrollView_BuyItem:GetComponent("UIScrollView"):ResetPosition()
  self.uiObjs.ScrollView_BuyItem:GetComponent("UIScrollView"):UpdatePosition()
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    GameUtil.AddGlobalLateTimer(0, true, function(...)
      if self.uiObjs and self.uiObjs.ScrollView_BuyItem.isnil == false then
        self.uiObjs.ScrollView_BuyItem:GetComponent("UIScrollView"):ResetPosition()
        self.uiObjs.ScrollView_BuyItem:GetComponent("UIScrollView"):UpdatePosition()
      end
    end)
  end)
end
def.method("number").ResizeGridList = function(self, size)
  local childCount = self.uiObjs.Grid_Page.childCount - 1
  if size > childCount then
    for i = childCount + 1, size do
      local Group_BuyItem = GameObject.Instantiate(self.uiObjs.Template_Group_BuyItem)
      Group_BuyItem:SetActive(true)
      Group_BuyItem.name = "Group_BuyItem_" .. i
      Group_BuyItem.transform.parent = self.uiObjs.Grid_Page.transform
      Group_BuyItem.transform.localScale = Vector.Vector3.one
      self.m_base.m_msgHandler:Touch(Group_BuyItem)
    end
  elseif size < childCount then
    for j = childCount, size + 1, -1 do
      local Group_BuyItem = self.uiObjs.Grid_Page:GetChild(j)
      GameObject.Destroy(Group_BuyItem)
    end
  end
  GameUtil.AddGlobalTimer(0, true, function(...)
    if self.uiObjs and self.uiObjs.Grid_Page.isnil == false then
      self.uiObjs.Grid_Page:GetComponent("UIGrid"):Reposition()
    end
  end)
end
def.method("number", "table").SetItemInfo = function(self, index, itemInfo)
  local isSubType = self.lastSubType == 0 and true or false
  local itemObj = self.uiObjs.Grid_Page:GetChild(index)
  local Group_DetailItemInfo = itemObj:FindDirect("Group_DetailItemInfo")
  GUIUtils.SetActive(Group_DetailItemInfo, not isSubType)
  local Label_ItemClassName = itemObj:FindDirect("Label_ItemClassName")
  local Label_ItemClassNumber = itemObj:FindDirect("Label_ItemClassNumber")
  GUIUtils.SetActive(Label_ItemClassName, isSubType)
  GUIUtils.SetActive(Label_ItemClassNumber, isSubType)
  local Img_BgItem = itemObj:FindDirect("Img_BgItem")
  local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon")
  local Img_SignNeed = Group_DetailItemInfo:FindDirect("Img_SignNeed")
  local Img_Red = itemObj:FindDirect("Img_Red")
  if isSubType then
    GUIUtils.Toggle(itemObj, false)
    GUIUtils.SetText(Label_ItemClassName, itemInfo.name)
    GUIUtils.SetTexture(Texture_Icon, itemInfo.icon)
    GUIUtils.SetSprite(Img_BgItem, string.format("Cell_%02d", 0))
    GUIUtils.SetTextureEffect(Texture_Icon:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    GUIUtils.SetActive(Img_SignNeed, false)
    GUIUtils.SetActive(Img_Red, false)
    local goodNumInfo = self.subtypeGoodsNums[itemInfo.subId]
    if goodNumInfo then
      GUIUtils.SetText(Label_ItemClassNumber, goodNumInfo.num)
    else
      GUIUtils.SetText(Label_ItemClassNumber, "")
    end
  else
    local isSelected = index == self.selItemIndex
    GUIUtils.Toggle(itemObj, isSelected)
    local Label_CollectNum = Group_DetailItemInfo:FindDirect("Label_CollectNum")
    local Label_Price = Group_DetailItemInfo:FindDirect("Label_Price")
    local Label_Num = Group_DetailItemInfo:FindDirect("Label_Num")
    local Label_ItemName = Group_DetailItemInfo:FindDirect("Label_ItemName")
    local Label_PublicTime = Group_DetailItemInfo:FindDirect("Label_PublicTime")
    local Img_SignCollected = Group_DetailItemInfo:FindDirect("Img_SignCollected")
    local Img_Bidded = Group_DetailItemInfo:FindDirect("Img_Bidded")
    local hasBid = BidMgr.Instance():HasBidOnGoods(itemInfo)
    GUIUtils.SetActive(Img_Bidded, hasBid)
    local stateRoleNum = itemInfo:GetStateRoleNum()
    local beCollect = stateRoleNum > 0
    local hasConcern = BuyServiceMgr.Instance():HasConcern(itemInfo)
    Label_CollectNum:SetActive(beCollect)
    Img_SignCollected:SetActive(hasConcern)
    GUIUtils.SetText(Label_CollectNum, stateRoleNum)
    TradingArcadeUtils.SetPriceLabel(Label_Price, itemInfo.price)
    local itemName = itemInfo:GetName()
    local icon = itemInfo:GetIcon()
    local bgSprite = icon.bgSprite
    local iconId = icon.iconId
    local rdText = icon.rdText
    local publicTimeText = self:GetPublicRemainTimeText(itemInfo)
    GUIUtils.SetText(Label_ItemName, itemName)
    GUIUtils.SetSprite(Img_BgItem, bgSprite)
    GUIUtils.SetTexture(Texture_Icon, iconId)
    GUIUtils.SetText(Label_Num, rdText)
    GUIUtils.SetText(Label_PublicTime, publicTimeText)
    if 0 >= itemInfo.num then
      GUIUtils.SetActive(Img_SignNeed, true)
      GUIUtils.SetSprite(Img_SignNeed, TradingArcadeNode.SpriteName.Selled)
      GUIUtils.SetTextureEffect(Texture_Icon:GetComponent("UITexture"), GUIUtils.Effect.Gray)
    else
      GUIUtils.SetActive(Img_SignNeed, false)
      GUIUtils.SetTextureEffect(Texture_Icon:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    end
    if self.lastSideIndex == BID_SIDE_INDEX then
      local hasNotify = BidMgr.Instance():BidGoodsHasNotify(itemInfo)
      GUIUtils.SetActive(Img_Red, hasNotify)
    else
      GUIUtils.SetActive(Img_Red, false)
    end
  end
end
def.method("table").UpdateItemListUI = function(self, viewdata)
  local showDetailBtnGroup = true
  local isSubType = self.lastSubType == 0 and true or false
  if self.lastSideIndex == CONCERN_SIDE_INDEX or self.lastSideIndex == BID_SIDE_INDEX or isSubType then
    showDetailBtnGroup = false
  end
  if self.searchWrapper then
    showDetailBtnGroup = true
  end
  GUIUtils.SetActive(self.uiObjs.Group_DetailBtn, showDetailBtnGroup)
  if showDetailBtnGroup and self.lastSubType ~= 1 then
    local islevelsift = false
    local ispricesort = false
    if self.searchWrapper then
      ispricesort = true
    else
      local viewdata = BuyViewdata.Instance():GetSubTypeViewdata(self.lastSubType)
      islevelsift = viewdata.islevelsift
      ispricesort = viewdata.ispricesort
    end
    local Btn_Price = self.uiObjs.Group_DetailBtn:FindDirect("Btn_Price")
    local Btn_Level = self.uiObjs.Group_DetailBtn:FindDirect("Btn_Level")
    GUIUtils.SetActive(Btn_Price, ispricesort)
    GUIUtils.SetActive(Btn_Level, islevelsift)
    self:UpdatePriceSortUI()
    self:UpdateLevelSiftUI()
  end
  self:UpdateConcernBtnState()
end
def.method().UpdatePriceSortUI = function(self)
  local Btn_Price = self.uiObjs.Group_DetailBtn:FindDirect("Btn_Price")
  local uiToggleEx = Btn_Price:GetComponent("UIToggleEx")
  if self.priceSort == BuyAndPublicCommon.PriceSort.Asc then
    uiToggleEx.value = true
  else
    uiToggleEx.value = false
  end
end
def.method().UpdateLevelSiftConditions = function(self)
  local conditions = self:GetLevelSiftConditions()
  local condition, defaultCondition
  for i, v in ipairs(conditions) do
    if v.param == self.lastSiftLevel then
      condition = v
      break
    end
    if v.default then
      defaultCondition = v
    end
  end
  if condition == nil and defaultCondition then
    self.lastSiftLevel = defaultCondition.param
  end
  self.levelConditions = conditions
end
def.method("=>", "table").GetSelLevelCondition = function(self)
  if self.levelConditions == nil then
    return nil
  end
  for i, v in ipairs(self.levelConditions) do
    if v.param == self.lastSiftLevel then
      return v
    end
  end
  return nil
end
def.method().UpdateLevelSiftUI = function(self)
  local Btn_Level = self.uiObjs.Btn_Level
  local uiToggleEx = Btn_Level:GetComponent("UIToggleEx")
  uiToggleEx.value = false
  local condition = self:GetSelLevelCondition()
  local label = Btn_Level:FindDirect("Label")
  local name = condition and condition.name or ""
  GUIUtils.SetText(label, name)
end
def.method("boolean").OpenLevelSiftList = function(self, isOpen)
  local Btn_Level = self.uiObjs.Btn_Level
  local uiToggleEx = Btn_Level:GetComponent("UIToggleEx")
  uiToggleEx.value = isOpen
  self.uiObjs.Table_LvBtn:SetActive(isOpen)
  if isOpen then
    self:SetLevelBtnList()
  end
end
def.method().SetLevelBtnList = function(self)
  local conditions = self.levelConditions
  local count = #conditions
  self:ResizeLevelBtnList(count)
  for i = 1, count do
    local condition = conditions[i]
    self:SetBtnLevelInfo(i, condition)
  end
end
def.method("number").ResizeLevelBtnList = function(self, size)
  local Table_LvBtn = self.uiObjs.Table_LvBtn
  local Btn_LvTemplate = Table_LvBtn:FindDirect("Btn_Lv")
  Btn_LvTemplate:SetActive(false)
  local childCount = Table_LvBtn.childCount - 2
  if size > childCount then
    for i = childCount + 1, size do
      local Btn_Lv = GameObject.Instantiate(Btn_LvTemplate)
      Btn_Lv:SetActive(true)
      Btn_Lv.name = "Btn_Lv_" .. i
      Btn_Lv.transform.parent = Table_LvBtn.transform
      Btn_Lv.transform.localScale = Vector.Vector3.one
      self.m_base.m_msgHandler:Touch(Btn_Lv)
    end
  elseif size < childCount then
    for j = childCount, size + 1, -1 do
      local Btn_Lv = Table_LvBtn:FindDirect("Btn_Lv_" .. j)
      GameObject.DestroyImmediate(Btn_Lv)
    end
  end
  GameUtil.AddGlobalTimer(0, true, function(...)
    if self.uiObjs and Table_LvBtn.isnil == false then
      Table_LvBtn:GetComponent("UITableResizeBackground"):Reposition()
    end
  end)
end
def.method("=>", "table").GetLevelSiftConditions = function(self)
  return TradingArcadeUtils.GetLevelSiftConditions(self.lastSubType)
end
def.method("number", "table").SetBtnLevelInfo = function(self, index, condition)
  local Btn_Lv = self.uiObjs.Table_LvBtn:GetChild(index + 1)
  local label = Btn_Lv:FindDirect("Label")
  GUIUtils.SetText(label, condition.name)
end
def.method("number").OnItemGroupClicked = function(self, index)
  local itemObj = self.uiObjs.Grid_Page:GetChild(index)
  if self.lastPageItems.isSubType then
    local index = BuyAndPublicCommon.PAGE_MAX_ITEM_COUNT * (self.curPage - 1) + index
    local itemInfo = self.lastPageItems[index]
    if itemInfo == nil then
      return
    end
    self.curPage = 0
    self.nextPage = 1
    self.lastSubType = itemInfo.subId
    self.selItemIndex = 0
    self.priceSort = BuyAndPublicCommon.PriceSort.Asc
    if not itemInfo.isAsc then
      self.priceSort = BuyAndPublicCommon.PriceSort.Dsc
    end
    GUIUtils.Toggle(itemObj, false)
    self:ShowBuyItemScrollView(false)
    self:UpdateLevelSiftConditions()
    self:UpdateGoodsPageInfo()
  else
    self:SelectItem(index)
  end
end
def.method("userdata").OnItemIconObjClicked = function(self, obj)
  local out = {}
  if not self:GetObjIndex(obj.parent.name, "Group_BuyItem_", out) then
    return
  end
  if self.lastPageItems.isSubType then
    self:OnItemGroupClicked(out.index)
    return
  end
  local index = out.index
  local goods = self.lastPageItems[index]
  if goods == nil then
    return
  end
  self:SelectItem(index)
  if goods.type == GoodsData.Type.Item then
    self:ShowItemTip(goods, obj, true)
  elseif goods.type == GoodsData.Type.Pet then
    self:ShowPetInfo(goods, true)
  end
end
def.method("number").SelectItem = function(self, index)
  self.selItemIndex = index
  local obj = self.uiObjs.Grid_Page:GetChild(index)
  local toggleOn = not self.lastPageItems.isSubType
  GUIUtils.Toggle(obj, toggleOn)
  self:UpdateConcernBtnState()
  self:UpdateBidBtnState()
  self:UpdateBuyBtnState()
  if self.lastSideIndex == BID_SIDE_INDEX then
    self:CheckToShowBidTip(index, obj)
  end
end
def.method("number", "userdata").CheckToShowBidTip = function(self, index, obj)
  local goods = self.lastPageItems[index]
  local bidGoods = BidMgr.Instance():GetBidGoods(goods.type, goods.marketId)
  if bidGoods == nil then
    return
  end
  BidMgr.Instance():UnRecordBeExceededGoods(bidGoods)
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {})
  self:ShowBidTip(true)
  local isMaxPrice = BidMgr.Instance():IsMaxPriceForGoods(goods)
  local Label_Sucuess = GUIUtils.FindDirect(self.uiObjs.Img_Bid, "Label_Sucuess")
  local Label_Failed = GUIUtils.FindDirect(self.uiObjs.Img_Bid, "Label_Failed")
  local failedText = textRes.TradingArcade[71]
  GUIUtils.SetText(Label_Failed, failedText)
  GUIUtils.SetActive(Label_Sucuess, isMaxPrice)
  GUIUtils.SetActive(Label_Failed, not isMaxPrice)
  local Btn_GetItem = GUIUtils.FindDirect(self.uiObjs.Img_Bid, "Btn_GetItem")
  local canGet = goods:IsInState(GoodsData.State.STATE_SELLED) and isMaxPrice
  warn("goodsstate", goods.state)
  GUIUtils.EnableButton(Btn_GetItem, canGet)
end
def.method("boolean").ShowBidTip = function(self, isShow)
  GUIUtils.SetActive(self.uiObjs.Img_Bid, isShow)
end
def.method().UpdateConcernBtnState = function(self)
  local text = textRes.TradingArcade[19]
  if self.lastSideIndex == BID_SIDE_INDEX then
    text = textRes.TradingArcade[59]
  elseif not self.lastPageItems.isSubType then
    local goods = self.lastPageItems[self.selItemIndex]
    local hasConcern = BuyServiceMgr.Instance():HasConcern(goods)
    if hasConcern then
      text = textRes.TradingArcade[20]
    end
  end
  GUIUtils.SetText(self.uiObjs.Label_Btn_Collect, text)
end
def.method().UpdateBuyBtnState = function(self)
  local goods = self.lastPageItems[self.selItemIndex]
  if goods == nil then
    return
  end
  local showBuyBtn = true
  if goods:IsInState(GoodsData.State.STATE_PUBLIC) then
    showBuyBtn = false
  end
  self:ShowBuyBtn(showBuyBtn)
end
def.method().UpdateBidBtnState = function(self)
  local goods = self.lastPageItems[self.selItemIndex]
  if goods == nil then
    return
  end
  local text = textRes.TradingArcade[56]
  if goods:IsInState(GoodsData.State.STATE_AUCTION) then
    text = textRes.TradingArcade[57]
  end
  local Label = self.uiObjs.Btn_Jingjia:FindDirect("Label")
  GUIUtils.SetText(Label, text)
end
def.method(GoodsData, "userdata", "boolean").ShowItemTip = function(self, goods, obj, autoQuery)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemTips = require("Main.Item.ui.ItemTips")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = obj:GetComponent("UIWidget")
  local item = goods.itemInfo
  local itemId = goods.itemId
  self.itemTip = nil
  if item == nil then
    if TradingArcadeUtils.NeedQueryItemDetail(itemId) and autoQuery then
      self.itemTip = {goods = goods, obj = obj}
      BuyServiceMgr.Instance():QueryGoodsDetail(goods, function(params)
        if goods == nil then
          return
        end
        if self.uiObjs == nil then
          return
        end
        self:OnSellItemDetailUpdate(params)
      end)
    else
      local item = {
        id = itemId,
        flag = 0,
        extraMap = {},
        extraInfoMap = {},
        extraProps = {}
      }
      local itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.TradingArcade, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
      local context = {
        marketId = goods.marketId,
        refId = goods:GetRefId(),
        price = goods.price,
        sellerRoleId = goods.sellerRoleId,
        goods = goods
      }
      itemTip:SetOperateContext(context)
    end
  else
    local itemTip = ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.TradingArcade, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    local context = {
      marketId = goods.marketId,
      refId = goods:GetRefId(),
      price = goods.price,
      sellerRoleId = goods.sellerRoleId
    }
    itemTip:SetOperateContext(context)
    if self.lastSideIndex ~= CONCERN_SIDE_INDEX and self.lastSideIndex ~= BID_SIDE_INDEX and TradingArcadeUtils.NeedQueryItemDetail(itemId) then
      itemTip.arrowState = ItemTips.ArrowState.Both
      function itemTip.arrowCallback(dir)
        if self.uiObjs == nil then
          return
        end
        if dir > 0 then
          self:MoveToNextItem()
        else
          self:MoveToLastItem()
        end
        return false
      end
      itemTip:UpdateInfo()
    end
  end
end
def.method().MoveToLastItem = function(self)
  local nextIndex = self.selItemIndex - 1
  if nextIndex < 1 then
    self.nextShowGoodsDetail = true
    self:OnBackPageClicked()
  else
    self:SelectGoodsAndShowDetail(nextIndex)
  end
end
def.method().MoveToNextItem = function(self)
  local itemCount = #self.lastPageItems
  local nextIndex = self.selItemIndex + 1
  if itemCount < nextIndex then
    self.nextShowGoodsDetail = true
    self:OnNextPageClicked()
  else
    self:SelectGoodsAndShowDetail(nextIndex)
  end
end
def.method(GoodsData, "boolean").ShowPetInfo = function(self, goods, autoQuery)
  local PetInfoPanel = require("Main.Pet.ui.PetInfoPanel")
  if goods.petInfo then
    PetInfoPanel.Instance().level = 2
    if self.lastSideIndex ~= CONCERN_SIDE_INDEX and self.lastSideIndex ~= BID_SIDE_INDEX then
      PetInfoPanel.Instance().arrowState = PetInfoPanel.ArrowState.Both
      PetInfoPanel.Instance().arrowCallback = function(dir)
        if self.uiObjs == nil then
          return
        end
        if dir > 0 then
          self:MoveToNextItem()
        else
          self:MoveToLastItem()
        end
      end
    end
    PetInfoPanel.Instance():ShowPanelByPetInfo(goods.petInfo)
    do
      local context = {
        marketId = goods.marketId,
        refId = goods:GetRefId(),
        price = goods.price,
        sellerRoleId = goods.sellerRoleId
      }
      PetInfoPanel.Instance():SetShareCallback(function(pos)
        TradingArcadeUtils.ShowShareOptionsPanel(context, pos)
      end)
    end
  elseif autoQuery then
    BuyServiceMgr.Instance():QueryGoodsDetail(goods, function(params)
      if goods == nil then
        return
      end
      if self.uiObjs == nil then
        return
      end
      self:OnSellPetDetailUpdate(params)
    end)
  end
end
def.method("number").SelectGoodsAndShowDetail = function(self, index)
  local itemObj = self.uiObjs.Grid_Page:GetChild(index)
  if itemObj == nil then
    return
  end
  local Img_BgItem = itemObj:FindDirect("Img_BgItem")
  self:OnItemIconObjClicked(Img_BgItem)
  self.nextShowGoodsDetail = false
end
def.method("number", "number").SetPageNums = function(self, cur, total)
  if total < cur then
    cur = total
  end
  local text = string.format("%d/%d", cur, total)
  GUIUtils.SetText(self.uiObjs.Label_Page, text)
end
def.method().OnBtnBuyClicked = function(self)
  if self.lastPageItems.isSubType then
    Toast(textRes.TradingArcade[4])
    return
  end
  if self.selItemIndex == 0 then
    Toast(textRes.TradingArcade[6])
    return
  end
  local goods = self.lastPageItems[self.selItemIndex]
  if goods:IsInState(GoodsData.State.STATE_SELLED) and goods.isMaxPrice then
    BidMgr.Instance():GetBidGoodsReq(goods)
    return
  end
  if 0 >= goods.num then
    Toast(string.format(textRes.TradingArcade[14], textRes.TradingArcade.GoodsTypeName[goods.type]))
    return
  end
  if BuyServiceMgr.Instance():IsSelfSell(goods) then
    Toast(textRes.TradingArcade[39])
    return
  end
  if 0 < goods:GetPublicRemainTime() then
    Toast(string.format(textRes.TradingArcade[24], goods:GetTypeName()))
    return
  end
  require("Main.TradingArcade.ui.BuyGoodsConfirmPanel").ShowPanel(goods, 1)
end
def.method().OnBtnCollectClicked = function(self)
  if self.lastSideIndex == BID_SIDE_INDEX then
    self:OnDeleteBidBtnClick()
    return
  end
  if self.lastPageItems.isSubType then
    Toast(textRes.TradingArcade[3])
    return
  end
  if self.selItemIndex == 0 then
    Toast(textRes.TradingArcade[5])
    return
  end
  local goods = self.lastPageItems[self.selItemIndex]
  if BuyServiceMgr.Instance():IsSelfSell(goods) then
    Toast(textRes.TradingArcade[39])
    return
  end
  if BuyServiceMgr.Instance():HasConcern(goods) then
    BuyServiceMgr.Instance():UnConcernGoods(goods)
  elseif BidMgr.Instance():HasBidOnGoods(goods) then
    Toast(textRes.TradingArcade[72])
    return
  else
    BuyServiceMgr.Instance():ConcernGoods(goods)
  end
end
def.method().OnBidBtnClick = function(self)
  if self.lastPageItems.isSubType then
    Toast(textRes.TradingArcade[54])
    return
  end
  if self.selItemIndex == 0 then
    Toast(textRes.TradingArcade[55])
    return
  end
  local goods = self.lastPageItems[self.selItemIndex]
  if BidMgr.Instance():IsMaxPriceForGoods(goods) then
    Toast(textRes.TradingArcade[64])
    return
  end
  require("Main.TradingArcade.ui.BidConfirmPanel").ShowPanel(goods, goods.num)
end
def.method().OnDeleteBidBtnClick = function(self)
  if self.selItemIndex == 0 then
    Toast(textRes.TradingArcade[60])
    return
  end
  local goods = self.lastPageItems[self.selItemIndex]
  if BidMgr.Instance():GetBidGoods(goods.type, goods.marketId) == nil then
    Toast(textRes.TradingArcade[65])
    return
  end
  if BidMgr.Instance():IsMaxPriceForGoods(goods) then
    Toast(textRes.TradingArcade[63])
    return
  end
  BidMgr.Instance():UnBidOnGoods(goods)
end
def.method().OnGetBidGoodsBtnClick = function(self)
  if self.lastPageItems == nil then
    return
  end
  local goods = self.lastPageItems[self.selItemIndex]
  if goods == nil then
    return
  end
  if ItemModule.Instance():IsBagFull(ItemModule.BAG) then
    Toast(textRes.TradingArcade[75])
    return
  end
  BidMgr.Instance():GetBidGoodsReq(goods)
end
def.method().OnBackPageClicked = function(self)
  if self.curPage > 1 then
    local nextPage = self.curPage - 1
    self:GoToPage(nextPage)
  else
    Toast(textRes.TradingArcade[1])
  end
end
def.method().OnNextPageClicked = function(self)
  local pageCount = self:GetTotalPage()
  if pageCount >= self.curPage + 1 then
    local nextPage = self.curPage + 1
    self:GoToPage(nextPage)
  else
    Toast(textRes.TradingArcade[2])
  end
end
def.method("number").GoToPage = function(self, page)
  self.nextPage = page
  if self.lastPageItems.isSubType then
    self.curPage = self.nextPage
    self:UpdateSubTypeItemList()
  else
    self:UpdateGoodsPageInfo()
  end
end
def.method().OnLabelPageClicked = function(self)
  local totalPage = self:GetTotalPage()
  if totalPage == 0 then
    return
  end
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  local val = 0
  CommonDigitalKeyboard.Instance():ShowPanel(function(key, tag)
    if self.uiObjs == nil then
      return
    end
    local getDisplayVal = function(val)
      local displayVal = val
      if displayVal <= 0 then
        displayVal = 1
      end
      return displayVal
    end
    local digital = tonumber(key)
    if digital then
      val = val * 10 + digital
      if val > totalPage then
        val = totalPage
        Toast(textRes.TradingArcade[2])
      end
      if val <= 0 then
        val = 1
      end
    elseif key == "DEL" then
      val = math.floor(val / 10)
    else
      local displayVal = getDisplayVal(val)
      self:GoToPage(displayVal)
    end
    local displayVal = getDisplayVal(val)
    self:SetPageNums(displayVal, totalPage)
  end, nil)
  CommonDigitalKeyboard.Instance():SetPos(0, 0)
end
def.method("=>", "number").GetTotalPage = function(self)
  local totalNum = 0
  if self.lastPageItems.isSubType then
    totalNum = math.floor((#self.lastPageItems - 1) / BuyAndPublicCommon.PAGE_MAX_ITEM_COUNT) + 1
  elseif self.lastSideIndex == CONCERN_SIDE_INDEX or self.lastSideIndex == BID_SIDE_INDEX then
    totalNum = 0 < #self.lastPageItems and 1 or 0
  else
    totalNum = BuyServiceMgr.Instance():GetSubTypeTotalPage(self.lastSubType)
  end
  return totalNum
end
def.method().UpdateGoodsPageInfo = function(self)
  print("UpdateGoodsPageInfo", self.lastSubType)
  local items = BuyServiceMgr.Instance():GetItemsBuyPage(self.lastSubType, self.nextPage)
  if items == nil then
    self:QueryGoodsPage()
    return
  end
  self.curPage = self.nextPage
  self.lastPageItems = items
  self:SetItemList(items)
  self:UpdatePageNums()
end
def.method().UpdateSearchResultItemList = function(self)
  print("UpdateSearchResultItemList")
  local searchMgr = SearchMgr.Instance():GetCurSearchMgr()
  local results = searchMgr:GetResultsByPage(self.nextPage)
  if results == nil then
    self.searchWrapper.Search()
    return
  end
  self.curPage = self.nextPage
  self.lastPageItems = results
  self.lastPageItems.isSubType = false
  self:SetItemList(self.lastPageItems)
  self:UpdatePageNums()
end
def.method("table").OnSellGoodsPageUpdate = function(self, params)
  local subType = params[1]
  local pageIndex = params[2]
  local priceSort = params[3]
  local siftLevel = params[4]
  if subType ~= self.lastSubType then
    return
  end
  if pageIndex ~= self.nextPage then
    return
  end
  if priceSort and priceSort ~= self.priceSort then
    print("ignore: priceSort ~= self.priceSort", priceSort, self.priceSort)
    return
  end
  if siftLevel and siftLevel ~= self.lastSiftLevel then
    print("ignore: siftLevel ~= self.lastSiftLevel", siftLevel, self.lastSiftLevel)
    return
  end
  local lastPage = self.curPage
  self:UpdateGoodsPageInfo()
  if self.nextShowGoodsDetail then
    if lastPage < self.curPage then
      self:SelectGoodsAndShowDetail(1)
    else
      self:SelectGoodsAndShowDetail(#self.lastPageItems)
    end
  end
  self:CheckAndSelectItem()
end
def.method("table").OnSellGoodsUpdate = function(self, params)
  local goods = params[1]
  if goods == nil then
    return
  end
  if self.lastSubType == 0 then
    return
  end
  print("goods.marketId, goods.type", goods.marketId, goods.type)
  for i, v in ipairs(self.lastPageItems) do
    if v.type == goods.type and v.marketId == goods.marketId then
      if self.lastSideIndex == CONCERN_SIDE_INDEX then
        local newV = BuyServiceMgr.Instance():GetConcernGoods(goods.type, goods.marketId)
        if newV and newV ~= v then
          v = newV
          self.lastPageItems[i] = v
        end
      elseif self.lastSideIndex == BID_SIDE_INDEX then
        local newV = BidMgr.Instance():GetBidGoods(goods.type, goods.marketId)
        if newV and newV ~= v then
          v = newV
          self.lastPageItems[i] = v
        end
      end
      self:SetItemInfo(i, v)
      self:UpdateConcernBtnState()
      break
    end
  end
end
def.method("table").OnBidGoodsUpdate = function(self, params)
  local goods = params[1]
  if self.lastSideIndex ~= BID_SIDE_INDEX then
    return
  end
  self:UpdateMyBidGoodsList()
end
def.method("table").OnTradingNotifyUpdate = function(self, params)
  self:SetLeftSideMenu(self.mainTypes)
end
def.method("table").OnConcernGoodsListUpdate = function(self, params)
  local goods = params[1]
  if self.lastSideIndex ~= CONCERN_SIDE_INDEX then
    return
  end
  self:UpdateConernItemList()
end
def.method("table").OnSynSearchResult = function(self, params)
  local p = params[1]
  if self.searchWrapper == nil then
    return
  end
  if self.searchWrapper.IsConditionEqual(p.condition) == false then
    return
  end
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.ON_SELL_GOODS_PAGE_UPDATE, {
    p.pageResult.subid,
    p.pageResult.pageIndex,
    p.pricesort
  })
end
def.method("table").OnSearchNotifyUpdate = function(self, params)
  self:UpdateBtnSearchNotify()
end
def.method("table").OnMoneyGoldIngotChanged = function(self, params)
  self:UpdateMoneyNum()
end
def.method(GoodsData).OnSellItemDetailUpdate = function(self, goods)
  if self.itemTip == nil then
    return
  end
  if self.itemTip.goods ~= goods then
    return
  end
  local obj = self.itemTip.obj
  if obj.isnil then
    return
  end
  local autoQuery = false
  self:ShowItemTip(goods, obj, autoQuery)
end
def.method(GoodsData).OnSellPetDetailUpdate = function(self, goods)
  if self.uiObjs == nil then
    return
  end
  local autoQuery = false
  self:ShowPetInfo(goods, autoQuery)
end
def.method().CheckAndSelectItem = function(self)
  if self.lastPageItems.isSubType then
    self.selItemIndex = 0
  else
    local wrapIndex = math.min(self.selItemIndex, #self.lastPageItems)
    self:SelectItem(wrapIndex)
  end
end
def.method().OnPriceSortBtnClick = function(self)
  if self.priceSort == BuyAndPublicCommon.PriceSort.Asc then
    self.priceSort = BuyAndPublicCommon.PriceSort.Dsc
  else
    self.priceSort = BuyAndPublicCommon.PriceSort.Asc
  end
  self.nextPage = 1
  self:QueryGoodsPage()
  self:UpdatePriceSortUI()
end
def.method().OnLevelBtnClick = function(self)
  local Btn_Level = self.uiObjs.Btn_Level
  local uiToggleEx = Btn_Level:GetComponent("UIToggleEx")
  local isOpen = uiToggleEx.value
  self:OpenLevelSiftList(isOpen)
end
def.method("number").SelectSiftLevel = function(self, index)
  local conditions = self.levelConditions
  local condition = conditions[index]
  if condition == nil then
    return
  end
  self.lastSiftLevel = condition.param
  self:OpenLevelSiftList(false)
  local label = self.uiObjs.Btn_Level:FindDirect("Label")
  GUIUtils.SetText(label, condition.name)
  self.nextPage = 1
  self:QueryGoodsPage()
end
def.method().QueryGoodsPage = function(self)
  if self.searchWrapper then
    self.searchWrapper.Search()
    return
  end
  if self.lastSubType > 1 then
    local viewdata = BuyViewdata.Instance():GetSubTypeViewdata(self.lastSubType)
    if viewdata.islevelsift then
      local condition = self:GetSelLevelCondition()
      local level = condition and condition.param or 0
      BuyServiceMgr.Instance():QueryGoodsPageWithLevel(self.lastSubType, self.priceSort, self.nextPage, level)
    else
      BuyServiceMgr.Instance():QueryGoodsPage(self.lastSubType, self.priceSort, self.nextPage)
    end
  end
end
def.method().OnQuestionGoldIngotBtnClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(BuyAndPublicCommon.GOLD_INGOT_TIPS_ID) or ""
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnSearchBtnClick = function(self)
  local params = {
    nodeId = self.nodeId
  }
  params.lastSideIndex = self.lastSideIndex
  params.lastSubType = self.lastSubType
  params.lastSiftLevel = self.lastSiftLevel
  require("Main.TradingArcade.ui.SearchPanel").ShowPanel(params)
end
def.method("userdata").OnCollectNumObjClick = function(self, obj)
  local out = {}
  local id = obj.parent.parent.name
  if self:GetObjIndex(id, "Group_BuyItem_", out) == false then
    return
  end
  local index = out.index
  local goods = self.lastPageItems[index]
  if goods == nil then
    return
  end
  local text = ""
  if goods:IsInState(GoodsData.State.STATE_AUCTION) then
    local goodsType = goods.type
    local marketId = goods.marketId
    TradingArcadeProtocol.CQueryAuctionConcernNumReq(marketId, goodsType, function(p)
      goods.concernRoleNum = p.concernNum
      goods.bidRoleNum = p.auctionNum
      TradingArcadeUtils.ShowGoodsStateRoleNum(goods)
      if self.uiObjs == nil then
        return
      end
      self:OnSellGoodsUpdate({goods})
    end)
  else
    text = string.format(textRes.TradingArcade[45], goods:GetConcernRoleNum())
    Toast(text)
  end
end
def.method().OnTimer = function(self)
  self:UpdatePublicTime()
end
def.method().UpdatePublicTime = function(self)
  if self.lastSubType == 0 then
    return
  end
  if self.lastPageItems == nil then
    return
  end
  if self.lastPageItems.isSubType then
    return
  end
  local childCount = self.uiObjs.Grid_Page.childCount
  for i, v in ipairs(self.lastPageItems) do
    if i == childCount then
      break
    end
    local itemObj = self.uiObjs.Grid_Page:GetChild(i)
    if itemObj then
      local Group_DetailItemInfo = itemObj:FindDirect("Group_DetailItemInfo")
      local Label_PublicTime = Group_DetailItemInfo:FindDirect("Label_PublicTime")
      local publicTimeText = self:GetPublicRemainTimeText(v)
      GUIUtils.SetText(Label_PublicTime, publicTimeText)
    end
  end
end
def.method("table", "=>", "string").GetPublicRemainTimeText = function(self, goods)
  local remainSeconds = goods:GetPublicRemainTime()
  local publicTimeText = ""
  if remainSeconds > 0 then
    local t = _G.Seconds2HMSTime(remainSeconds)
    publicTimeText = string.format(textRes.TradingArcade[16], t.h, t.m)
  end
  return publicTimeText
end
def.static("number", "number").LocateAndSetSubTypePage = function(subId, siftLevel)
  local viewdata = BuyViewdata.Instance():GetAllTypes()
  local cfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
  for index, v in ipairs(viewdata) do
    if v.id == cfg.marketCfgId then
      BuyAndPublicCommon._lastSideIndex = index
      break
    end
  end
  BuyAndPublicCommon._lastSubType = subId
  if cfg.islevelsift then
    BuyAndPublicCommon._lastSiftLevel = siftLevel
  end
end
def.method("number", "number").OpenSubTypePage = function(self, subId, siftLevel)
  if self.mainTypes == nil then
    return
  end
  local cfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
  for index, v in ipairs(self.mainTypes) do
    if v.id == cfg.marketCfgId then
      self.lastSideIndex = index
      break
    end
  end
  self.lastSubType = subId
  if cfg.islevelsift then
    self.lastSiftLevel = siftLevel
  end
  self:SelectSideMenu(self.lastSideIndex)
end
def.method("table").SetSearchWrapper = function(self, searchMgr)
  local wrapper = {}
  function wrapper.Search()
    local state
    if self.nodeId == TradingArcadeNode.NodeId.PUBLIC then
      state = SearchBase.State.Public
    else
      state = SearchBase.State.OnSell
    end
    local params = {
      state = state,
      pricesort = self.priceSort,
      page = self.nextPage
    }
    searchMgr:Search(params)
  end
  function wrapper.IsConditionEqual(condition)
    return searchMgr:IsConditionEqual(condition)
  end
  self.searchWrapper = wrapper
end
def.method().UpdateBtnSearchNotify = function(self)
  local hasNotify = self:HasSearchNotify()
  local Img_Red = self.uiObjs.Btn_Search:FindDirect("Img_Red")
  GUIUtils.SetActive(Img_Red, hasNotify)
end
BuyAndPublicCommon.Commit()
return BuyAndPublicCommon
