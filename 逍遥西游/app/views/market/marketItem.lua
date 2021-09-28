CMarketItem = class("CMarketItem", CcsSubView)
function CMarketItem:ctor(itemTypeId, price, markup, marketViewObj)
  CMarketItem.super.ctor(self, "views/marketitem.json")
  self.m_ItemTypeId = itemTypeId
  self.m_PriceResType = RESTYPE_SILVER
  self:setBaseInfo()
  self:setPriceNum(price)
  self:setMarkUp(markup)
  local size = self:getNode("bg"):getContentSize()
  self.m_IsTouchMoved = false
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
  self.m_MarketViewObj = marketViewObj
  self:ListenMessage(MsgID_Market)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_Mission)
end
function CMarketItem:OnMessage(msgSID, ...)
  if msgSID == MsgID_Market_PriceUpdate then
    local arg = {
      ...
    }
    if arg[1] == self.m_ItemTypeId then
      self:setPriceNum(arg[2])
      self:setMarkUp(arg[3])
    end
  elseif msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    local arg = {
      ...
    }
    local itemType = arg[3]
    if self.m_ItemTypeId == itemType then
      self:flushNeededSign()
    end
  elseif msgSID == MsgID_Mission_NpcStatusChanged then
    self:flushNeededSign()
  end
end
function CMarketItem:flushNeededSign()
  if self._needFlagImg == nil then
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    img:setAnchorPoint(ccp(0, 1))
    local size = self:getContentSize()
    img:setPosition(ccp(0, size.height))
    self:addNode(img)
    self._needFlagImg = img
    local zOrder = 10
    if self.pic_raceown ~= nil and self.pic_raceown.getZOrder ~= nil then
      zOrder = self.pic_raceown:getZOrder()
    end
    img:getParent():reorderChild(self._needFlagImg, zOrder)
    self._needFlagImg:setVisible(false)
  end
  local isNeedFlag = g_MissionMgr:isObjShortage(self.m_ItemTypeId)
  self._needFlagImg:setVisible(isNeedFlag)
end
function CMarketItem:getItemTypeId()
  return self.m_ItemTypeId
end
function CMarketItem:setBaseInfo()
  local pos = self:getNode("itempos")
  pos:setVisible(false)
  local parent = pos:getParent()
  local x, y = pos:getPosition()
  local zOrder = pos:getZOrder()
  local icon = createClickItem({
    itemID = self.m_ItemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = function()
      if self.m_MarketViewObj then
        self.m_MarketViewObj:ShowMarketDetail(self.m_ItemTypeId)
      end
    end,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  parent:addChild(icon, zOrder)
  icon:setPosition(ccp(x, y))
  self.m_ItemImg = icon
  local name = data_getItemName(self.m_ItemTypeId)
  self:getNode("txt_name"):setText(name)
  local resicon = self:getNode("resicon")
  local x, y = resicon:getPosition()
  local z = resicon:getZOrder()
  local size = resicon:getSize()
  local tempImg = display.newSprite(data_getResPathByResID(self.m_PriceResType))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self.pic_raceown = self:getNode("pic_raceown")
  local data = data_Market[self.m_ItemTypeId]
  if data ~= nil then
    if data.Limit ~= 0 then
      local mainhero = g_LocalPlayer:getMainHero()
      if mainhero then
        local sex = mainhero:getProperty(PROPERTY_GENDER)
        local race = mainhero:getProperty(PROPERTY_RACE)
        if sex == math.floor(data.Limit / 10) and race == data.Limit % 10 then
          self.pic_raceown:setVisible(true)
        else
          self.pic_raceown:setVisible(false)
        end
      else
        self.pic_raceown:setVisible(false)
      end
    else
      self.pic_raceown:setVisible(false)
    end
  else
    self.pic_raceown:setVisible(false)
  end
  local isNeedFlag = g_MissionMgr:isObjShortage(self.m_ItemTypeId)
  if isNeedFlag then
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    img:setAnchorPoint(ccp(0, 1))
    local size = self:getContentSize()
    img:setPosition(ccp(0, size.height))
    self:addNode(img)
    self._needFlagImg = img
    local zOrder = 10
    if self.pic_raceown ~= nil and self.pic_raceown.getZOrder ~= nil then
      zOrder = self.pic_raceown:getZOrder()
    end
    img:getParent():reorderChild(self._needFlagImg, zOrder)
  end
end
function CMarketItem:setPriceNum(priceNum)
  self.m_PriceNum = priceNum
  local text_price = self:getNode("text_price")
  text_price:setText(tostring(self.m_PriceNum))
  AutoLimitObjSize(self:getNode("text_price"), 65)
end
function CMarketItem:setMarkUp(markup)
  local text_change = self:getNode("text_change")
  if markup >= 0.01 then
    if markup >= 100000 then
      text_change:setText("涨停")
    else
      text_change:setText(string.format("+%s%%", Value2Str(markup, 2)))
    end
    text_change:setColor(VIEW_DEF_WARNING_COLOR)
  elseif markup <= -0.01 then
    if markup <= -100000 then
      text_change:setText("跌停")
    else
      text_change:setText(string.format("%s%%", Value2Str(markup, 2)))
    end
    text_change:setColor(VIEW_DEF_PGREEN_COLOR)
  else
    text_change:setText("-- --")
    text_change:setColor(ccc3(255, 255, 255))
  end
end
function CMarketItem:OnBtn_Buy()
  self.m_MarketViewObj:OnBuyMarketItem(self.m_ItemTypeId, self.m_PriceNum)
end
function CMarketItem:OnTouchEvent(event)
  local bg = self:getNode("bg")
  if event == TOUCH_EVENT_BEGAN then
    bg:setColor(ccc3(200, 200, 200))
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
function CMarketItem:Clear()
  self.m_MarketViewObj = nil
end
