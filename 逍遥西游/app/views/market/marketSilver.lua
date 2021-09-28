function getUselessItemListOfMarket()
  local uselessItemList = {}
  local sexraceLimit = 0
  local mainhero = g_LocalPlayer:getMainHero()
  if mainhero then
    local sex = mainhero:getProperty(PROPERTY_GENDER)
    local race = mainhero:getProperty(PROPERTY_RACE)
    sexraceLimit = sex * 10 + race
  end
  for itemType, itemData in pairs(data_Market) do
    if itemData.Limit ~= 0 and sexraceLimit ~= itemData.Limit then
      local num = g_LocalPlayer:GetItemNum(itemType)
      if num > 0 then
        uselessItemList[#uselessItemList + 1] = {itemType, num}
      end
    end
  end
  local _sortTypeFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a[1] < b[1]
  end
  table.sort(uselessItemList, _sortTypeFunc)
  return uselessItemList
end
CMarketSilver = class("CMarketSilver", CcsSubView)
function CMarketSilver:ctor(initItemType, autpbuy, mid)
  CMarketSilver.super.ctor(self, "views/market_silvermarket.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Closed),
      variName = "btn_close"
    },
    btn_addsilver = {
      listener = handler(self, self.Btn_AddSilver),
      variName = "btn_addsilver"
    },
    btn_addcoin = {
      listener = handler(self, self.Btn_AddCoin),
      variName = "btn_addcoin"
    },
    btn_tidy = {
      listener = handler(self, self.Btn_Tidy),
      variName = "btn_tidy"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_item = self:getNode("list_item")
  self.list_type = self:getNode("list_type")
  self.list_type:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  self.m_MarketItemInfoOfSvr = {}
  self.m_CurrMainType = nil
  self.m_CurrListNumber = nil
  self.m_InitItemType = initItemType
  self.m_mid = mid
  self.autpbuy = autpbuy
  self:setSilverAndCoinNum()
  self:SetItemList()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_MoveScene)
end
function CMarketSilver:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("goldsilver"), "ressilver")
  self:attrclick_check_withWidgetObj(self:getNode("coinbg"), "rescoin")
end
function CMarketSilver:onEnterEvent()
  self:InitMarketMainType(self.m_InitItemType, self.autpbuy)
  self:InitSellUselessItems()
end
function CMarketSilver:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    local d = arg[1]
    if d.newCoin ~= nil then
      self:updateCoinNum()
    end
    if d.newSilver ~= nil then
      self:updateSilverNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local tempId = arg[1]
    if self.m_ItemDetail ~= nil and self.m_ItemDetail:getItemObjId() == tempId then
      self:CloseEquipDetail()
    end
  elseif msgSID == MsgID_Connect_SendFinished then
    if self.m_CurrListNumber ~= nil then
      self.m_MarketItemInfoOfSvr = {}
      self:ShowMarketInfoOfNumber(self.m_CurrListNumber)
    end
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseEquipDetail()
  end
end
function CMarketSilver:InitSellUselessItems()
  local uselessItemList = getUselessItemListOfMarket()
  if #uselessItemList > 0 then
    CMarketSell.new(uselessItemList)
  end
end
function CMarketSilver:InitMarketMainType(initItemType, autobuy)
  self.m_MarketType = {}
  local temp = {}
  local firstMainType, firstSubType, firstMainTypeIndex
  for itemType, itemData in pairs(data_Market) do
    local mType = itemData.MainCategory
    local sType = itemData.MinorCategory
    local sTypeList = self.m_MarketType[mType]
    if sTypeList == nil then
      sTypeList = {}
      self.m_MarketType[mType] = sTypeList
      temp[#temp + 1] = {
        mType,
        itemData.MainCategoryName
      }
    end
    if sTypeList[sType] == nil then
      sTypeList[sType] = itemData.MinorCategoryName
    end
    if itemType == initItemType then
      firstMainType = mType
      firstSubType = sType
    end
  end
  local _sortFuncMain = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a[1] < b[1]
  end
  table.sort(temp, _sortFuncMain)
  for index, d in pairs(temp) do
    local mainTypeItem = CMainTypeListItem.new(d[1], d[2])
    self.list_type:pushBackCustomItem(mainTypeItem)
    if d[1] == firstMainType then
      firstMainTypeIndex = index - 1
    end
  end
  if firstMainType ~= nil and firstSubType ~= nil and firstMainTypeIndex ~= nil then
    self:ShowMarketInfo(firstMainType, firstSubType)
    self:ShowMarketSubType(firstMainTypeIndex, firstMainType)
    if autobuy ~= false then
      self:OnBuyMarketItem(initItemType, nil)
    end
  elseif #temp > 0 then
    local firstMainType = temp[1][1]
    local subTypes = self.m_MarketType[firstMainType]
    local tempList = {}
    for subType, _ in pairs(subTypes) do
      tempList[#tempList + 1] = subType
    end
    local _sortFuncSub = function(a, b)
      if a == nil or b == nil then
        return false
      end
      return a < b
    end
    if #tempList > 0 then
      table.sort(tempList, _sortFuncSub)
      firstSubType = tempList[1]
      self:ShowMarketInfo(firstMainType, firstSubType)
    end
  end
end
function CMarketSilver:ShowMarketSubType(index, mainType)
  local subTypes = self.m_MarketType[mainType]
  if subTypes == nil then
    return
  end
  local temp = {}
  for subType, subTypeName in pairs(subTypes) do
    temp[#temp + 1] = {subType, subTypeName}
  end
  local _sortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a[1] > b[1]
  end
  table.sort(temp, _sortFunc)
  local firstSubType, firstSubTypeItem
  for _, d in pairs(temp) do
    local subTypeItem = CSubTypeListItem.new(mainType, d[1], d[2])
    self.list_type:insertCustomItem(subTypeItem, index + 1)
    if self:GetNumber(mainType, d[1]) == self.m_CurrListNumber then
      subTypeItem:setItemChoosed(true)
    end
    firstSubType = d[1]
    firstSubTypeItem = subTypeItem
  end
  self.list_type:ListViewScrollToIndex_Vertical(index, 0.3)
  self.m_SubTypeIsShow = true
  return firstSubType, firstSubTypeItem
end
function CMarketSilver:HideAllSubType()
  for index = self.list_type:getCount() - 1, 0, -1 do
    local item = self.list_type:getItem(index)
    if iskindof(item, "CSubTypeListItem") then
      self.list_type:removeItem(index)
    end
  end
  self.m_SubTypeIsShow = false
end
function CMarketSilver:ChooseTypeItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  if iskindof(item, "CMainTypeListItem") then
    local mainType = item:getMainType()
    if self.m_CurrMainType == mainType then
      if self.m_SubTypeIsShow then
        self:HideAllSubType()
      else
        self:ShowMarketSubType(index, mainType)
      end
    else
      self:HideAllSubType()
      local insertIndex
      for i = 0, self.list_type:getCount() - 1 do
        local tempItem = self.list_type:getItem(i)
        if iskindof(tempItem, "CMainTypeListItem") and tempItem:getMainType() == mainType then
          insertIndex = i
          break
        end
      end
      if insertIndex ~= nil then
        local firstSubType, firstSubTypeItem = self:ShowMarketSubType(insertIndex, mainType)
        self.m_CurrMainType = mainType
        if firstSubType ~= nil then
          firstSubTypeItem:setItemChoosed(true)
          self:ShowMarketInfo(mainType, firstSubType)
        end
      end
    end
  elseif iskindof(item, "CSubTypeListItem") then
    for index = self.list_type:getCount() - 1, 0, -1 do
      local tempItem = self.list_type:getItem(index)
      if iskindof(tempItem, "CSubTypeListItem") then
        if tempItem ~= item then
          tempItem:setItemChoosed(false)
        else
          tempItem:setItemChoosed(true)
        end
      end
    end
    local mainType = item:getMainType()
    local subType = item:getSubType()
    self:ShowMarketInfo(mainType, subType)
  end
end
function CMarketSilver:ListEventListener(item, index, listObj, status)
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
function CMarketSilver:ShowMarketInfo(mainType, subType)
  local number = self:GetNumber(mainType, subType)
  if number == self.m_CurrListNumber then
    return
  end
  self:ShowMarketInfoOfNumber(number)
end
function CMarketSilver:GetNumber(mainType, subType)
  return mainType * 100 + subType
end
function CMarketSilver:ShowMarketInfoOfNumber(number)
  print("准备显示市场分类信息:", number)
  self.m_CurrListNumber = number
  local dataCache = self.m_MarketItemInfoOfSvr[number]
  if dataCache == nil then
    self:setMarketItemList({})
    netsend.netmarket.requestMarketInfo(self.m_CurrListNumber)
  else
    self:setMarketItemList(dataCache)
  end
end
function CMarketSilver:setMarketItemList(goods)
  self.list_item:removeAllItems()
  self.list_item:setInnerContainerSize(CCSize(0, 0))
  for _, data in pairs(goods) do
    local itemTypeId = data.itemid
    local price = data.price
    local markup = data.markup
    local item = CMarketItem.new(itemTypeId, price, markup, self)
    self.list_item:pushBackCustomItem(item.m_UINode)
  end
end
function CMarketSilver:onSetItemInfo(typeNumber, goods)
  if self.m_CurrListNumber ~= typeNumber then
    return
  end
  self:setMarketItemList(goods)
end
function CMarketSilver:onUppateItemInfo(typeNumber, itemTypeId, price, markup)
  if self.m_CurrListNumber ~= typeNumber then
    return
  end
  for index = 0, self.list_item:getCount() - 1 do
    local item = self.list_item:getItem(index).m_UIViewParent
    if item:getItemTypeId() == itemTypeId then
      item:setPriceNum(price)
      item:setMarkUp(markup)
      break
    end
  end
end
function CMarketSilver:OnBuyMarketItem(itemTypeId, priceNum)
  if JudgeIsInWar() and GetItemTypeByItemTypeId(itemTypeId) == ITEM_LARGE_TYPE_DRUG then
    ShowNotifyTips("处于战斗中，不能购买药品")
    return
  end
  local data = data_Market[itemTypeId]
  local needCount = g_MissionMgr:getMissionShortageObjs(self.m_mid, itemTypeId, false)
  if needCount == nil then
    needCount = 1
  end
  if data and data.NeedAjustValue == 0 then
    CMarketBuy_NoChange.new(itemTypeId, priceNum, needCount)
  else
    CMarketBuy.new(itemTypeId, priceNum)
  end
end
function CMarketSilver:setSilverAndCoinNum()
  local box_silver = self:getNode("box_silver")
  box_silver:setVisible(true)
  box_silver:setTouchEnabled(false)
  local x, y = box_silver:getPosition()
  local z = box_silver:getZOrder()
  local size = box_silver:getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_SILVER))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:updateSilverNum()
  local box_coin = self:getNode("box_coin")
  box_coin:setVisible(true)
  box_coin:setTouchEnabled(false)
  local x, y = box_coin:getPosition()
  local z = box_coin:getZOrder()
  local size = box_coin:getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:updateCoinNum()
end
function CMarketSilver:updateSilverNum()
  local text_silver = self:getNode("text_silver")
  text_silver:setText(string.format("%d", g_LocalPlayer:getSilver()))
  AutoLimitObjSize(text_silver, 92)
end
function CMarketSilver:updateCoinNum()
  local text_coin = self:getNode("text_coin")
  text_coin:setText(string.format("%d", g_LocalPlayer:getCoin()))
  AutoLimitObjSize(text_coin, 92)
end
function CMarketSilver:setMarkItemInfoFromSvr(typeNumber, goods)
  print("CMarketSilver:收到市场分类【基本信息】", typeNumber)
  local sexraceLimit = 0
  local mainhero = g_LocalPlayer:getMainHero()
  if mainhero then
    local sex = mainhero:getProperty(PROPERTY_GENDER)
    local race = mainhero:getProperty(PROPERTY_RACE)
    sexraceLimit = sex * 10 + race
  end
  local function _goodsSortFunc(a, b)
    if a == nil or b == nil then
      return false
    end
    local id_a = a.itemid
    local id_b = b.itemid
    local data_a = data_Market[id_a]
    local data_b = data_Market[id_b]
    if data_a == nil and data_b == nil then
      return id_a < id_b
    elseif data_a ~= nil and data_b == nil then
      return true
    elseif data_a == nil and data_b ~= nil then
      return false
    else
      local isOwn_a = data_a.Limit ~= 0 and sexraceLimit == data_a.Limit
      local isOwn_b = data_b.Limit ~= 0 and sexraceLimit == data_b.Limit
      if isOwn_a and not isOwn_b then
        return true
      elseif not isOwn_a and isOwn_b then
        return false
      elseif data_a.GoodsID ~= data_b.GoodsID then
        return data_a.GoodsID < data_b.GoodsID
      else
        return id_a < id_b
      end
    end
  end
  table.sort(goods, _goodsSortFunc)
  self.m_MarketItemInfoOfSvr[typeNumber] = goods
  self:onSetItemInfo(typeNumber, goods)
  for _, data in pairs(goods) do
    SendMessage(MsgID_Market_PriceUpdate, data.itemid, data.price, data.markup)
  end
end
function CMarketSilver:updateMarkItemInfoFromSvr(typeNumber, goods)
  print("CMarketSilver:收到市场分类【更新信息】~~~~~~", typeNumber)
  local dataCache = self.m_MarketItemInfoOfSvr[typeNumber]
  if dataCache == nil then
    return
  end
  for _, data in pairs(goods) do
    for _, d in pairs(dataCache) do
      if data.itemid == d.itemid then
        d.price = data.price
        d.markup = data.markup
        print("CMarketSilver:更新缓存物品信息", typeNumber, data.itemid, data.price, data.markup)
        SendMessage(MsgID_Market_PriceUpdate, data.itemid, data.price, data.markup)
        break
      end
    end
  end
end
function CMarketSilver:SetItemList()
  local layer_itemlist = self:getNode("layer_itemlist")
  local parent = layer_itemlist:getParent()
  local x, y = layer_itemlist:getPosition()
  local z = layer_itemlist:getZOrder()
  layer_itemlist:setVisible(false)
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(88, 88),
    pageLines = 4,
    oneLineNum = 3,
    pageIconOffY = -15
  }
  self.m_PackageFrame = CPackageFrame.new(nil, function(itemObjId)
    self:ShowPackageDetail(itemObjId)
  end, nil, param, nil, nil, nil, nil, ExPackageGetCanNotUseFunc)
  self.m_PackageFrame:setPosition(ccp(x, y))
  parent:addChild(self.m_PackageFrame, z)
end
function CMarketSilver:ShowPackageDetail(itemObjId)
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local packageItemIns = g_LocalPlayer:GetOneItem(itemObjId)
  if packageItemIns == nil then
    return
  end
  local itemType = packageItemIns:getType()
  if itemType == ITEM_LARGE_TYPE_TASK then
    self.m_ItemDetail = CEquipDetail.new(itemObjId, {
      closeListener = handler(self, self.OnItemDetailClosed)
    })
  else
    local itemTypeId = packageItemIns:getTypeId()
    local itemNum = packageItemIns:getProperty(ITEM_PRO_NUM)
    if packageItemIns:getProperty(ITME_PRO_BUNDLE_FLAG) == 1 or data_Market[itemTypeId] == nil then
      self.m_ItemDetail = CEquipDetail.new(itemObjId, {
        leftBtn = {
          btnText = "出售",
          listener = handler(self, self.OnSellItem)
        },
        closeListener = handler(self, self.OnItemDetailClosed)
      })
    else
      self.m_ItemDetail = CEquipDetail.new(itemObjId, {
        leftBtn = {
          btnText = "出售1个",
          listener = function()
            self:OnSellItem_One(itemObjId)
          end
        },
        rightBtn = {
          btnText = "出售全部",
          listener = function()
            self:OnSellItem_All(itemObjId)
          end
        },
        closeListener = handler(self, self.OnItemDetailClosed)
      })
    end
  end
  if self.m_ItemDetail ~= nil then
    self:addSubView({
      subView = self.m_ItemDetail,
      zOrder = 9999
    })
    local x, y = self:getNode("Image_9_0_0"):getPosition()
    local iSize = self:getNode("Image_9_0_0"):getContentSize()
    local bSize = self.m_ItemDetail:getBoxSize()
    self.m_ItemDetail:setPosition(ccp(x - bSize.width, y - bSize.height / 2))
    self.m_ItemDetail:ShowCloseBtn()
  end
end
function CMarketSilver:ShowMarketDetail(itemTypeId)
  self.m_ItemDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.OnItemDetailClosed),
    itemType = itemTypeId
  })
  if self.m_ItemDetail ~= nil then
    self:addSubView({
      subView = self.m_ItemDetail,
      zOrder = 9999
    })
    local x, y = self:getNode("Image_9_0_0"):getPosition()
    local iSize = self:getNode("Image_9_0_0"):getContentSize()
    local bSize = self.m_ItemDetail:getBoxSize()
    self.m_ItemDetail:setPosition(ccp(x - 37, y - bSize.height / 2))
    self.m_ItemDetail:ShowCloseBtn()
  end
end
function CMarketSilver:OnSellItem(itemId)
  SellItemPopView(itemId, function()
    self:OnConfirmSell(itemId)
  end)
end
function CMarketSilver:OnConfirmSell(itemId, itemNum)
  netsend.netitem.requestSellItem(itemId, itemNum)
end
function CMarketSilver:OnSellItem_One(itemId)
  netsend.netitem.requestSellItem(itemId, 1)
end
function CMarketSilver:OnSellItem_All(itemId)
  netsend.netitem.requestSellItem(itemId, 0)
end
function CMarketSilver:OnItemDetailClosed(obj)
  if self.m_ItemDetail ~= nil and self.m_ItemDetail == obj then
    self.m_ItemDetail = nil
    if self.m_PackageFrame then
      self.m_PackageFrame:ClearSelectItem()
    end
  end
end
function CMarketSilver:CloseEquipDetail()
  if self.m_ItemDetail then
    self.m_ItemDetail:CloseSelf()
  end
end
function CMarketSilver:Btn_Closed(obj, objType)
  if g_Market ~= nil then
    g_Market:CloseSelf()
    netsend.netstall.colseView()
  end
end
function CMarketSilver:Btn_AddSilver(obj, objType)
  ShowRechargeView({resType = RESTYPE_SILVER})
end
function CMarketSilver:Btn_AddCoin(obj, objType)
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CMarketSilver:Btn_Tidy(obj, objType)
  local curTime = cc.net.SocketTCP.getTime()
  local temp = 6
  if self.m_LastZhengliTime ~= nil then
    temp = curTime - self.m_LastZhengliTime
  end
  local temp = math.floor(temp)
  if temp < 5 then
    local tips = string.format("你刚刚已经进行过整理，请隔%d秒再试", 5 - temp)
    ShowNotifyTips(tips)
    return
  else
    self.m_LastZhengliTime = curTime
    netsend.netitem.requestZhengliPackage()
  end
end
function CMarketSilver:Clear()
  self:CloseEquipDetail()
  netsend.netmarket.closeMarket()
end
