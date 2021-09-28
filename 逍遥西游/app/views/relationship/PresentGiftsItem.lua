CPresentGiftItem = class("CPresentGiftItem", function()
  return Widget:create()
end)
function CPresentGiftItem:ctor(params)
  local params = params or {}
  self.m_itemTypeId = params.itemTypeId
  self.m_listnerhander = params.listener
  local itemBg = display.newSprite("xiyou/item/itembg.png")
  self.m_ItemBg = itemBg
  itemBg:setAnchorPoint(ccp(0, 0))
  self:addNode(itemBg)
  self.m_bgSize = itemBg:getContentSize()
  self.m_ItemIcon = nil
  self.m_ItemNumLabel = nil
  self:SetIconImage()
  self:setTouchEnabled(false)
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_ItemInfo)
  self.m_TouchNode = clickwidget.create(self.m_bgSize.width, self.m_bgSize.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
end
function CPresentGiftItem:callListener()
  if self.m_listnerhander then
    self.m_listnerhander(self)
  end
end
function CPresentGiftItem:OnTouchEvent(event)
  if event == TOUCH_EVENT_BEGAN then
    self.m_ItemBg:setColor(ccc3(200, 200, 200))
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        self.m_ItemBg:setColor(ccc3(255, 255, 255))
      end
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_ItemBg == nil then
      return
    end
    self:callListener()
    if not self.m_IsTouchMoved then
      self.m_ItemBg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function CPresentGiftItem:getBoxSize()
  return self.m_bgSize
end
function CPresentGiftItem:getGifgTypeId()
  return self.m_itemTypeId
end
function CPresentGiftItem:IsHasBuyTheGrid()
  return self.m_hasBuyTheGrid
end
function CPresentGiftItem:SetIconImage()
  local itemID = g_LocalPlayer:GetOneItemIdByType(self.m_itemTypeId)
  if self.m_ItemIcon then
    self:removeNode(self.m_ItemIcon)
    self.m_ItemIcon = nil
    self.m_ItemNumLabel = nil
  end
  if self.m_itemTypeId ~= nil then
    local data_table = GetItemDataByItemTypeId(self.m_itemTypeId)
    local itemShape = data_table[self.m_itemTypeId].itemShape
    local iconPath = data_getItemPathByShape(itemShape)
    local itemIcon = display.newSprite(iconPath)
    self.m_ItemIcon = itemIcon
    itemIcon:setAnchorPoint(ccp(0, 0))
    self:addNode(itemIcon)
    local iconSize = itemIcon:getContentSize()
    local x, y = (self.m_bgSize.width - iconSize.width) / 2, (self.m_bgSize.height - iconSize.height) / 2
    itemIcon:setPosition(x, y)
    local canMerge = true
    if canMerge then
      local num = g_LocalPlayer:GetItemNum(self.m_itemTypeId) or 0
      local numLabel = CCLabelTTF:create(string.format("%s", num), ITEM_NUM_FONT, 22)
      numLabel:setAnchorPoint(ccp(1, 0))
      numLabel:setPosition(ccp(self.m_bgSize.width - 6 - x, 5 - y))
      numLabel:setColor(ccc3(255, 255, 255))
      itemIcon:addChild(numLabel)
      AutoLimitObjSize(numLabel, 70)
      self.m_ItemNumLabel = numLabel
    end
  end
end
function CPresentGiftItem:setTouchState(flag)
  if flag then
    self.m_ItemBg:setColor(ccc3(200, 200, 200))
  else
    self.m_ItemBg:setColor(ccc3(255, 255, 255))
  end
end
function CPresentGiftItem:setSelected(flag)
  if flag == true then
    if self.m_ChoosedFrame == nil then
      self.m_ChoosedFrame = display.newSprite("xiyou/item/selecteditem.png")
      self:addNode(self.m_ChoosedFrame, 10)
      local size = self.m_ItemBg:getContentSize()
      self.m_ChoosedFrame:setPosition(ccp(size.width / 2, size.height / 2))
    end
  elseif self.m_ChoosedFrame ~= nil then
    self.m_ChoosedFrame:removeFromParent()
    self.m_ChoosedFrame = nil
  end
end
function CPresentGiftItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_ItemUpdate then
    local num = g_LocalPlayer:GetItemNum(self.m_itemTypeId) or 0
    self.m_ItemNumLabel:setString(tostring(num))
  end
end
function CPresentGiftItem:onCleanup()
  self:RemoveAllMessageListener()
end
