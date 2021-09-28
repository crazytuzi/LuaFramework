CMarketShopping = class("CMarketShopping", CcsSubView)
function CMarketShopping:ctor(initItemId, mainIndex, subIndex, initMid)
  CMarketShopping.super.ctor(self, "views/market_shopping.json", {isAutoCenter = true, opacityBg = 100})
  self.m_initItemId = initItemId
  self.m_initMid = initMid
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_close),
      variName = "btn_close"
    },
    btn_flushtime = {
      listener = handler(self, self.Btn_frush),
      variName = "btn_flushtime"
    },
    btn_addCoin = {
      listener = handler(self, self.Btn_AddCoin),
      variName = "btn_addCoin"
    },
    btn_shopping = {
      listener = handler(self, self.Btn_Shopping),
      variName = "btn_shopping"
    },
    btn_baitan = {
      listener = handler(self, self.Btn_baitan),
      variName = "btn_baitan"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_shopping,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    },
    {
      self.btn_baitan,
      nil,
      ccc3(251, 248, 145),
      ccp(0, -2)
    }
  })
  self.txt_free = self:getNode("txt_free")
  self.menul_list = self:getNode("menul_list")
  self.txt_flushpay = self:getNode("txt_flushpay")
  self.txt_freeflush = self:getNode("txt_freeflush")
  self:getNode("txt_flushpay"):setVisible(false)
  self:getNode("txt_free"):setVisible(false)
  self:getNode("bg_freeflush"):setVisible(false)
  self.curMainSelect = -1
  self.curSecondSelect = -1
  self:InitShoppingMainType(mainIndex, subIndex)
  self:setCoinIcon()
  self:setSilverIcon()
  self:SetAttrTips()
  self.m_UpdateHandler = scheduler.scheduleGlobal(handler(self, self.updateFreshTime), 1)
  self:ListenMessage(MsgID_Stall)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CMarketShopping:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("bg_flushpay"), "ressilver")
  self:attrclick_check_withWidgetObj(self:getNode("coinbg"), "rescoin")
end
function CMarketShopping:InitShoppingMainType(mainIndex, subIndex)
  mainIndex = mainIndex or 1
  subIndex = subIndex or 1
  self.mainTypeItem = {}
  self.m_mianItemList = {}
  self.menul_list:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  for id, val in pairs(data_getStallMenuData()) do
    local mainItemData = val
    mainItemData.TypeIndex = id
    self.mainTypeItem[id] = mainItemData
  end
  if #self.mainTypeItem > 0 then
    for k, mainItem in ipairs(self.mainTypeItem) do
      local tempItem = CMainTypeListItem.new(k, mainItem.MainCategoryName)
      tempItem.TypeIndex = mainItem.TypeIndex
      self.m_mianItemList[#self.m_mianItemList + 1] = tempItem
      self.menul_list:pushBackCustomItem(tempItem)
    end
  end
  if self.m_mianItemList ~= nil and #self.m_mianItemList > 0 then
    self:setSecondListItem(self.m_mianItemList[mainIndex], subIndex)
  end
end
function CMarketShopping:setSecondListItem(item, subIndex)
  subIndex = subIndex or 1
  self.showItemList = {}
  self.secondItemList = self.mainTypeItem[item.TypeIndex].secondList
  if iskindof(item, "CMainTypeListItem") then
    for k, val in pairs(self.secondItemList) do
      self.showItemList[#self.showItemList + 1] = {
        val.MinorCategoryID,
        val
      }
    end
  end
  local count = 0
  for _, secondItemData in pairs(self.showItemList) do
    local k = secondItemData[1]
    local val = secondItemData[2]
    local tempItem = CSubTypeListItem.new(nil, k, val.MinorCategoryName)
    tempItem.TypeIndex = k
    tempItem.ParentIndex = item.TypeIndex
    self.menul_list:insertCustomItem(tempItem, item.TypeIndex + count)
    count = count + 1
  end
  self.curMainSelect = item.TypeIndex
  self.curSecondSelect = subIndex or 1
  self:setSecondMenuState(subIndex)
  self.showSecondMenu = count > 0
  local selectitem = self.menul_list:getItem(item.TypeIndex)
  if self.showSecondMenu and selectitem ~= nil then
    self:CreateScrollBoard()
  end
  self.menul_list:ListViewScrollToIndex_Vertical(item.TypeIndex, 0.3)
end
function CMarketShopping:ChooseTypeItem(item, index)
  if iskindof(item, "CMainTypeListItem") then
    if not self.showSecondMenu then
      self:clearSecondItem()
      self:setSecondListItem(item, 1)
    elseif self.showSecondMenu and self.curMainSelect ~= item.TypeIndex then
      self:clearSecondItem()
      self:setSecondListItem(item, 1)
    elseif self.showSecondMenu and self.curMainSelect == item.TypeIndex then
      self:clearSecondItem()
    end
  elseif iskindof(item, "CSubTypeListItem") then
    self:setSecondMenuState(item.TypeIndex)
    if item.ParentIndex and item.TypeIndex then
      self.curSecondSelect = item.TypeIndex
      self.curMainSelect = item.ParentIndex
      self:CreateScrollBoard()
    end
  end
end
function CMarketShopping:clearSecondItem()
  for i = self.menul_list:getCount() - 1, 0, -1 do
    local item = self.menul_list:getItem(i)
    if iskindof(item, "CSubTypeListItem") then
      self.menul_list:removeItem(i)
      self.showItemList = nil
    end
  end
  self.showSecondMenu = false
end
function CMarketShopping:setSecondMenuState(index)
  for i = self.menul_list:getCount() - 1, 0, -1 do
    local item = self.menul_list:getItem(i)
    if iskindof(item, "CSubTypeListItem") then
      item:setItemChoosed(index == item.TypeIndex)
    end
  end
end
function CMarketShopping:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function CMarketShopping:CreateScrollBoard()
  local bgNode = self:getNode("bg")
  local dirKey = self.curMainSelect * 100 + self.curSecondSelect
  print("CMarketShopping:CreateScrollBoard", dirKey)
  if self.marketBoard then
    self.marketBoard:removeFromParent()
    self.marketBoard = nil
  end
  self.marketBoard = marketShoppingBoard.new(MARKET_SCROLL_BUY_VIEW, dirKey, {bgNode = bgNode}, self.m_initMid)
  local parent = self:getNode("goodItemList"):getParent()
  local x, y = self:getNode("goodItemList"):getPosition()
  local zOrder = self:getNode("goodItemList"):getZOrder()
  local parent = self:getNode("goodItemList"):getParent()
  parent:addChild(self.marketBoard, zOrder)
  self.marketBoard:setPosition(ccp(x, y))
  local force = false
  local tempData = g_BaitanDataMgr:GetGoodsData(dirKey)
  if #tempData <= 0 then
    force = true
  end
  netsend.netstall.openStallDir(dirKey, force)
end
function CMarketShopping:updateFreshTime(dt)
  local timeData = g_BaitanDataMgr:GetBaitanTime()
  local leftTimePoint = timeData.leftTime or 0
  local curTimePoint = timeData.curTime or 0
  local restTime = curTimePoint + leftTimePoint - g_DataMgr:getServerTime()
  if restTime <= 0 then
    restTime = 0
  end
  if restTime <= 0 then
    self.m_SilverImg:setVisible(false)
    self:getNode("txt_flushpay"):setText("免费")
    self:getNode("txt_flushpay"):setVisible(true)
    self:getNode("txt_free"):setVisible(false)
    self:getNode("bg_freeflush"):setVisible(false)
  else
    self.m_SilverImg:setVisible(true)
    self:getNode("txt_flushpay"):setText("100")
    self:getNode("txt_flushpay"):setVisible(true)
    self:getNode("txt_free"):setVisible(true)
    self:getNode("bg_freeflush"):setVisible(true)
    local h, m, s = getHMSWithSeconds(restTime)
    local text = string.format("%02d:%02d:%02d", h, m, s)
    self.txt_freeflush:setText(text)
  end
end
function CMarketShopping:setCoinIcon()
  local bgSize = self:getNode("box_coin"):getContentSize()
  local parent = self:getNode("box_coin"):getParent()
  local x, y = self:getNode("box_coin"):getPosition()
  local z = parent:getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  parent:addNode(tempImg, z + 1)
  self:setPlayerTotalCoin()
end
function CMarketShopping:setSilverIcon()
  local x, y = self:getNode("icon_paytype"):getPosition()
  local z = self:getNode("icon_paytype"):getZOrder()
  local size = self:getNode("icon_paytype"):getSize()
  self:getNode("icon_paytype"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_SILVER))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:getNode("txt_flushpay"):setText("100")
  self.m_SilverImg = tempImg
end
function CMarketShopping:setPlayerTotalCoin()
  local totalCoin = g_LocalPlayer:getCoin()
  local text_coin = self:getNode("text_coin")
  text_coin:setText(tostring(totalCoin))
  AutoLimitObjSize(text_coin, 92)
end
function CMarketShopping:SetBtnSelect(baitanBtnType)
  if baitanBtnType == BaitanShow_InitShow_ShoppingView then
    self:setGroupBtnSelected(self.btn_shopping)
  else
    self:setGroupBtnSelected(self.btn_baitan)
  end
end
function CMarketShopping:Btn_Shopping(obj, objType)
end
function CMarketShopping:Btn_baitan(obj, objType)
  if g_Market then
    g_Market:ShowCoinMarket(BaitanShow_InitShow_StallView)
  end
end
function CMarketShopping:Btn_close(obj, objType)
  if g_Market ~= nil then
    g_Market:CloseSelf()
    netsend.netstall.colseView()
  end
end
function CMarketShopping:Btn_frush(obj, objType)
  netsend.netstall.frushStallData()
end
function CMarketShopping:Btn_AddCoin(obj, objType)
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CMarketShopping:OnMessage(msgSID, ...)
  if msgSID == MsgID_Stall_UpdateBaitanTimeData then
    self:updateFreshTime()
  elseif msgSID == MsgID_MoneyUpdate then
    self:setPlayerTotalCoin()
  end
end
function CMarketShopping:Clear()
  if self.m_UpdateHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_UpdateHandler)
  end
end
