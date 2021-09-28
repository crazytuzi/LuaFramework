ShopViewItem = class("ShopViewItem", CcsSubView)
function ShopViewItem:ctor(pageNum)
  ShopViewItem.super.ctor(self, "views/shop_item.json")
  self.m_PageNum = pageNum
  self.m_ItemId = nil
  self.m_ItemNum = nil
  self.m_IsSellOut = false
  self.m_PriceNum = 0
  self.m_PriceResType = RESTYPE_COIN
  self.m_SMSD_No = nil
  local size = self:getNode("bg"):getContentSize()
  self.m_IsTouchMoved = false
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
end
function ShopViewItem:setBuyInitNum(mid)
  self.m_mid = mid
end
function ShopViewItem:setItemId(itemId, itemNum)
  self.m_ItemNum = itemNum
  local tempNum = 0
  if self.m_PageNum == Shop_Smsd_Page or self.m_PageNum == Shop_Xiayi_Page then
    tempNum = itemNum
  end
  self.m_ItemId = itemId
  if self.m_ItemImg then
    self.m_ItemImg:removeFromParent()
    self.m_ItemImg = nil
  end
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  local icon = createClickItem({
    itemID = itemId,
    autoSize = nil,
    num = tempNum,
    LongPressTime = 0.3,
    clickListener = nil,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  pos:addChild(icon, 10)
  self.m_ItemImg = icon
  local name = data_getItemName(itemId)
  self:getNode("txt_name"):setText(name)
  if self.m_PageNum == Shop_Smsd_Page or self.m_PageNum == Shop_Xiayi_Page then
    self:setSellOut(tempNum == 0)
  end
  if g_MissionMgr:isObjShortage(itemId) then
    local bg = self:getNode("bg")
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    local x, y = bg:getPosition()
    local size = bg:getContentSize()
    img:setAnchorPoint(ccp(0, 1))
    img:setPosition(ccp(x - size.width / 2, y + size.height / 2))
    self:addNode(img, 100)
    self.m_NeedFlagImg = img
  end
end
function ShopViewItem:setSMSD_No(smsdid)
  self.m_SMSD_No = smsdid
end
function ShopViewItem:setXiaYiGoods_No(XiaYiId)
  self.m_XiaYiGoods_No = XiaYiId
end
function ShopViewItem:setSellOut(flag)
  if flag == true then
    if self.m_SellOutImg == nil then
      local tempImg = display.newSprite("views/pic/pic_sellout.png")
      local size = self:getContentSize()
      tempImg:setAnchorPoint(ccp(0.5, 0.5))
      tempImg:setPosition(ccp(size.width / 2, size.height / 2))
      self:addNode(tempImg, 99)
      self.m_SellOutImg = tempImg
    end
  elseif self.m_SellOutImg then
    self.m_SellOutImg:removeFromParent()
    self.m_SellOutImg = nil
  end
end
function ShopViewItem:setPriceType(prictType)
  if self.m_ResIcon then
    self.m_ResIcon:removeFromParent()
    self.m_ResIcon = nil
  end
  local x, y = self:getNode("resicon"):getPosition()
  local z = self:getNode("resicon"):getZOrder()
  local size = self:getNode("resicon"):getSize()
  self.m_PriceResType = prictType
  local tempImg = display.newSprite(data_getResPathByResID(self.m_PriceResType))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self.m_ResIcon = tempImg
  self:setPriceNum(self.m_PriceNum)
end
function ShopViewItem:setPriceNum(priceNum)
  if priceNum > 1000000 then
    self:getNode("text_price"):setText(string.format("%d万", math.floor(priceNum / 10000)))
  else
    self:getNode("text_price"):setText(tostring(priceNum))
  end
  self.m_PriceNum = priceNum
  local player = g_LocalPlayer
  local redFlag = false
  if self.m_PriceResType == RESTYPE_COIN then
    if player:getCoin() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_Honour then
    if player:getHonour() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_XIAYI and player:getXiaYiValue() < self.m_PriceNum then
    redFlag = true
  end
  if redFlag then
    self:getNode("text_price"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("text_price"):setColor(ccc3(255, 255, 255))
  end
end
function ShopViewItem:getItemId()
  return self.m_ItemId, self.m_PriceResType, self.m_PriceNum
end
function ShopViewItem:OnMessage(msgSID, ...)
  if msgSID == MsgID_MoneyUpdate then
    self:setPriceNum(self.m_PriceNum)
  elseif msgSID == MsgID_HonourUpdate then
    self:setPriceNum(self.m_PriceNum)
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum or msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem then
    local a1 = CCDelayTime:create(0.1)
    local a2 = CCCallFunc:create(function()
      if not g_MissionMgr:isObjShortage(self.m_ItemId) and self.m_NeedFlagImg then
        self.m_NeedFlagImg:removeFromParent()
        self.m_NeedFlagImg = nil
      end
    end)
    self:runAction(transition.sequence({a1, a2}))
  end
end
function ShopViewItem:OnBtn_Buy()
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
  end
  if JudgeIsInWar() and GetItemTypeByItemTypeId(self.m_ItemId) == ITEM_LARGE_TYPE_DRUG then
    ShowNotifyTips("处于战斗中，不能购买药品")
    return
  end
  local player = g_LocalPlayer
  if (self.m_PageNum == Shop_Smsd_Page or self.m_PageNum == Shop_Xiayi_Page) and self.m_ItemNum == 0 then
    ShowNotifyTips("该物品已售罄")
    return
  end
  if self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_PriceNum then
      ShowNotifyTips("元宝不足")
      return
    end
  elseif self.m_PriceResType == RESTYPE_Honour then
    if player:getHonour() < self.m_PriceNum then
      ShowNotifyTips("荣誉不足")
      return
    end
  elseif self.m_PriceResType == RESTYPE_XIAYI then
  end
  if self.m_PageNum ~= Shop_Smsd_Page and self.m_PageNum ~= Shop_Xiayi_Page then
    local m_initNum = g_MissionMgr:getMissionShortageObjs(self.m_mid, self.m_ItemId)
    if m_initNum ~= nil then
      self.m_ItemNum = m_initNum
    end
    CBuyNormalItemView.new(self.m_PageNum, self.m_ItemId, self.m_PriceResType, self.m_PriceNum, self.m_ItemNum)
  elseif self.m_PageNum == Shop_Xiayi_Page then
    CBuySecretItemView.new(self.m_PageNum, self.m_ItemId, self.m_PriceResType, self.m_PriceNum, self.m_ItemNum, self.m_SMSD_No, self.m_XiaYiGoods_No)
  else
    CBuySecretItemView.new(self.m_PageNum, self.m_ItemId, self.m_PriceResType, self.m_PriceNum, self.m_ItemNum, self.m_SMSD_No)
  end
end
function ShopViewItem:OnTouchEvent(event)
  local bg = self:getNode("bg")
  if event == TOUCH_EVENT_BEGAN then
    bg:setColor(ccc3(100, 100, 100))
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        bg:setColor(ccc3(255, 255, 255))
      end
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if bg == nil then
      return
    end
    if not self.m_IsTouchMoved then
      self:OnBtn_Buy()
      bg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function ShopViewItem:Clear()
end
ShopViewXianGouItem = class("ShopViewXianGouItem", CcsSubView)
function ShopViewXianGouItem:ctor(xgId)
  ShopViewXianGouItem.super.ctor(self, "views/shop_item.json")
  self.m_XGId = xgId
  local xgData = data_ShopXianGou[xgId] or {}
  local allXGData = g_LocalPlayer:GetXianGouShopList()
  self.m_PageNum = xgData.shopNum
  self.m_ItemId = xgData.itemid
  self.m_ItemNum = allXGData[self.m_XGId].num or 1
  local price = xgData.price
  if price == 0 or price == nil then
    self.m_PriceNum = xgData.gold
    self.m_PriceResType = RESTYPE_GOLD
  else
    self.m_PriceNum = xgData.price
    self.m_PriceResType = RESTYPE_COIN
  end
  local size = self:getNode("bg"):getContentSize()
  self.m_IsTouchMoved = false
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
  self:ListenMessage(MsgID_PlayerInfo)
  self:setItemId(self.m_ItemId, self.m_ItemNum)
  self:setXianGouData()
  self:setPriceType(self.m_PriceResType)
  self:setPriceNum(self.m_PriceNum)
  self:setXianGouTime()
  self.m_UpdateTimer = scheduler.scheduleGlobal(function()
    if self.setXianGouTime then
      self:setXianGouTime()
    end
  end, 1)
end
function ShopViewXianGouItem:setItemId(itemId, itemNum)
  self.m_ItemNum = itemNum
  local tempNum = 0
  if self.m_PageNum == Shop_Smsd_Page or self.m_PageNum == Shop_Xiayi_Page then
    tempNum = itemNum
  end
  self.m_ItemId = itemId
  if self.m_ItemImg then
    self.m_ItemImg:removeFromParent()
    self.m_ItemImg = nil
  end
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  local icon = createClickItem({
    itemID = itemId,
    autoSize = nil,
    num = tempNum,
    LongPressTime = 0.3,
    clickListener = nil,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  pos:addChild(icon, 10)
  self.m_ItemImg = icon
  local name = data_getItemName(itemId)
  self:getNode("txt_name"):setText(name)
end
function ShopViewXianGouItem:setXianGouData()
  local bg = self:getNode("bg")
  local img = display.newSprite("views/pic/pic_xiangou.png")
  local x, y = bg:getPosition()
  local size = bg:getContentSize()
  img:setAnchorPoint(ccp(0, 1))
  img:setPosition(ccp(x - size.width / 2, y + size.height / 2))
  self:addNode(img, 100)
end
function ShopViewXianGouItem:setPriceType(prictType)
  if self.m_ResIcon then
    self.m_ResIcon:removeFromParent()
    self.m_ResIcon = nil
  end
  local x, y = self:getNode("resicon"):getPosition()
  local z = self:getNode("resicon"):getZOrder()
  local size = self:getNode("resicon"):getSize()
  self.m_PriceResType = prictType
  local tempImg = display.newSprite(data_getResPathByResID(self.m_PriceResType))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self.m_ResIcon = tempImg
  self:setPriceNum(self.m_PriceNum)
end
function ShopViewXianGouItem:setPriceNum(priceNum)
  if priceNum > 1000000 then
    self:getNode("text_price"):setText(string.format("%d万", math.floor(priceNum / 10000)))
  else
    self:getNode("text_price"):setText(tostring(priceNum))
  end
  self.m_PriceNum = priceNum
  local player = g_LocalPlayer
  local redFlag = false
  if self.m_PriceResType == RESTYPE_COIN then
    if player:getCoin() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_Honour then
    if player:getHonour() < self.m_PriceNum then
      redFlag = true
    end
  elseif self.m_PriceResType == RESTYPE_XIAYI and player:getXiaYiValue() < self.m_PriceNum then
    redFlag = true
  end
  if redFlag then
    self:getNode("text_price"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("text_price"):setColor(ccc3(255, 255, 255))
  end
end
function ShopViewXianGouItem:setXianGouTime()
  local allXGData = g_LocalPlayer:GetXianGouShopList()
  local endTimePoint = 0
  endTimePoint = allXGData[self.m_XGId] and (allXGData[self.m_XGId].endTimePoint or 0)
  local restTime = endTimePoint - g_DataMgr:getServerTime()
  if restTime < 0 then
    restTime = 0
  end
  local d = math.floor(restTime / 3600 / 24)
  local h = math.floor(restTime / 3600 % 24)
  local m = math.floor(restTime % 3600 / 60)
  local s = math.floor(restTime % 60)
  local txt = "剩余时间:"
  if d > 0 then
    txt = string.format("%s%d天", txt, d)
  end
  if h > 0 then
    txt = string.format("%s%d小时", txt, h)
  end
  if m > 0 then
    txt = string.format("%s%d分", txt, m)
  end
  if d <= 0 and s > 0 then
    txt = string.format("%s%d秒", txt, s)
  end
  if self.m_XianGouTimeText == nil then
    self.m_XianGouTimeText = ui.newTTFLabel({
      text = txt,
      font = KANG_TTF_FONT,
      size = 18,
      color = ccc3(188, 125, 41)
    })
    self.m_XianGouTimeText:setAnchorPoint(ccp(0, 0))
    local x, y = self:getNode("txt_name"):getPosition()
    self.m_XianGouTimeText:setPosition(ccp(x, y - 60))
    self:addNode(self.m_XianGouTimeText)
  else
    self.m_XianGouTimeText:setString(txt)
  end
end
function ShopViewXianGouItem:OnMessage(msgSID, ...)
  if msgSID == MsgID_MoneyUpdate then
    self:setPriceNum(self.m_PriceNum)
  end
end
function ShopViewXianGouItem:OnBtn_Buy()
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
  end
  if JudgeIsInWar() and GetItemTypeByItemTypeId(self.m_ItemId) == ITEM_LARGE_TYPE_DRUG then
    ShowNotifyTips("处于战斗中，不能购买药品")
    return
  end
  local player = g_LocalPlayer
  if self.m_PriceResType == RESTYPE_GOLD then
    if player:getGold() < self.m_PriceNum then
      ShowNotifyTips("元宝不足")
      return
    end
  elseif self.m_PriceResType == RESTYPE_Honour and player:getHonour() < self.m_PriceNum then
    ShowNotifyTips("荣誉不足")
    return
  end
  CBuyXianGouItemView.new(self.m_XGId)
end
function ShopViewXianGouItem:OnTouchEvent(event)
  local bg = self:getNode("bg")
  if event == TOUCH_EVENT_BEGAN then
    bg:setColor(ccc3(100, 100, 100))
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        bg:setColor(ccc3(255, 255, 255))
      end
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if bg == nil then
      return
    end
    if not self.m_IsTouchMoved then
      self:OnBtn_Buy()
      bg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function ShopViewXianGouItem:Clear()
  if self.m_UpdateTimer then
    scheduler.unscheduleGlobal(self.m_UpdateTimer)
    self.m_UpdateTimer = nil
  end
end
