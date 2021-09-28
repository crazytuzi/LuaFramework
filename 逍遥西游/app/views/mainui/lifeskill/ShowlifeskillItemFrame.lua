CShowLifeSkillItem = class("CShowLifeSkillItem", function()
  return Widget:create()
end)
function CShowLifeSkillItem:ctor(itemTypeId)
  local itemBg = display.newSprite("xiyou/item/itembg.png")
  self.m_ItemBg = itemBg
  itemBg:setAnchorPoint(ccp(0, 0))
  self:addNode(itemBg)
  self.m_bgSize = itemBg:getContentSize()
  self.m_ItemIcon = nil
  self.m_ItemNumLabel = nil
  self.m_ItemTopRightIcon = nil
  self.m_ItemCanNotUseIcon = nil
  self.m_itmeTypeId = itemTypeId
  self:SetIconImage()
  self:setTouchEnabled(false)
  self:setNodeEventEnabled(true)
end
function CShowLifeSkillItem:getBoxSize()
  return self.m_bgSize
end
function CShowLifeSkillItem:SetIconImage()
  local data_table = GetItemDataByItemTypeId(self.m_itmeTypeId)
  if self.m_ItemIcon then
    self:removeNode(self.m_ItemIcon)
    self.m_ItemIcon = nil
    self.m_ItemNumLabel = nil
    self.m_ItemTopRightIcon = nil
    self.m_ItemCanNotUseIcon = nil
  end
  local shapeId = data_table[self.m_itmeTypeId].itemShape
  local iconPath = data_getItemPathByShape(shapeId)
  local itemIcon = display.newSprite(iconPath)
  self.m_ItemIcon = itemIcon
  itemIcon:setAnchorPoint(ccp(0, 0))
  self:addNode(itemIcon)
  local iconSize = itemIcon:getContentSize()
  local x, y = (self.m_bgSize.width - iconSize.width) / 2, (self.m_bgSize.height - iconSize.height) / 2
  itemIcon:setPosition(x, y)
  local NeedLv = data_table[self.m_itmeTypeId].NeedLv or 0
  local numLabel = CCLabelTTF:create(string.format("Lv%s", NeedLv), ITEM_NUM_FONT, 22)
  local color = ccc3(255, 0, 0)
  numLabel:setColor(color)
  numLabel:setAnchorPoint(ccp(1, 0))
  numLabel:setPosition(ccp(self.m_bgSize.width - 6 - x, 5 - y))
  itemIcon:addChild(numLabel)
  AutoLimitObjSize(numLabel, 70)
  self.m_ItemNumLabel = numLabel
  if NeedLv == 0 then
    numLabel:setVisible(false)
  end
end
function CShowLifeSkillItem:setTouchState(flag)
  if flag then
    self.m_ItemBg:setColor(ccc3(200, 200, 200))
  else
    self.m_ItemBg:setColor(ccc3(255, 255, 255))
  end
end
function CShowLifeSkillItem:setFadeIn()
  local dt = 0.5
  self.m_ItemBg:setOpacity(0)
  self.m_ItemBg:runAction(CCFadeIn:create(dt))
  if self.m_ItemIcon ~= nil then
    self.m_ItemIcon:setOpacity(0)
    self.m_ItemIcon:runAction(CCFadeIn:create(dt))
  end
  if self.m_ItemNumLabel ~= nil then
    self.m_ItemNumLabel:setOpacity(0)
    self.m_ItemNumLabel:runAction(CCFadeIn:create(dt))
  end
  if self.m_ItemTopRightIcon ~= nil then
    self.m_ItemTopRightIcon:setOpacity(0)
    self.m_ItemTopRightIcon:runAction(CCFadeIn:create(dt))
  end
  if self.m_ItemCanNotUseIcon ~= nil then
    self.m_ItemCanNotUseIcon:setOpacity(0)
    self.m_ItemCanNotUseIcon:runAction(CCFadeIn:create(dt))
  end
  if self.m_ChoosedFrame ~= nil then
    self.m_ChoosedFrame:setOpacity(0)
    self.m_ChoosedFrame:runAction(CCFadeIn:create(dt))
  end
end
function CShowLifeSkillItem:setSelected(flag)
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
function CShowLifeSkillItem:onCleanup()
end
CShowLifeSkillItemFrame = class("CShowLifeSkillItemFrame", function()
  return Widget:create()
end)
function CShowLifeSkillItemFrame:ctor(listParam)
  if listParam == nil then
    listParam = {}
  end
  self.m_ListParam = listParam
  self.m_ClickListener = listParam.clickListener
  self.m_TotalItemPosList = listParam.itmeTypeIdTalbe or {}
  self.m_XYSpace = listParam.xySpace or ccp(5, 3)
  self.m_ItemSize = listParam.itemSize or CCSize(90, 85)
  self.m_PageLines = listParam.pageLines or 3
  self.m_OneLineNum = listParam.oneLineNum or 5
  self.m_PageItemNum = self.m_PageLines * self.m_OneLineNum
  self.m_MaxPageNum = listParam.maxPageNum
  self.m_PageIconOffY = listParam.pageIconOffY or -30
  local mWidth = self.m_OneLineNum * self.m_ItemSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local mHeight = self.m_PageLines * self.m_ItemSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(mWidth, mHeight))
  self:ShowPackagePage()
  self:setNodeEventEnabled(true)
  self:setAnchorPoint(ccp(0, 0))
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
  self.m_SelectedID = nil
end
function CShowLifeSkillItemFrame:getTotalPageNum()
  return self.m_TotalPageNum
end
function CShowLifeSkillItemFrame:getFrameSize()
  local w = self.m_OneLineNum * self.m_ItemSize.width + (self.m_OneLineNum - 1) * self.m_XYSpace.x
  local h = self.m_PageLines * self.m_ItemSize.height + (self.m_PageLines - 1) * self.m_XYSpace.y
  return CCSize(w, h)
end
function CShowLifeSkillItemFrame:ShowPackagePage(showAction)
  self.m_TotalItemObj = {}
  local idIndex = 1
  local pageItemIdList = {}
  local iWidth = self.m_ItemSize.width
  local iHeight = self.m_ItemSize.height
  local spacex = self.m_XYSpace.x
  local spacey = self.m_XYSpace.y
  for line = 1, self.m_PageLines do
    for i = 1, self.m_OneLineNum do
      local index = (line - 1) * self.m_OneLineNum + i
      local itemTypeId = self.m_TotalItemPosList[index]
      if itemTypeId ~= nil then
        local itemObj = CShowLifeSkillItem.new(itemTypeId)
        itemObj.itemTypeId = itemTypeId
        itemObj:setSelected(self.m_SelectedID ~= nil and tempTypeId == self.m_SelectedID)
        self:addChild(itemObj)
        local ox, oy = (iWidth + spacex) * (i - 1) + 5, (iHeight + spacey) * (self.m_PageLines - line) - 5
        itemObj.m_OriPosXY = ccp(ox, oy)
        itemObj:setPosition(itemObj.m_OriPosXY)
        self.m_TotalItemObj[#self.m_TotalItemObj + 1] = itemObj
        idIndex = idIndex + 1
        if showAction == true then
          itemObj:setFadeIn()
        end
      end
    end
  end
end
function CShowLifeSkillItemFrame:ClickPackageItem(itemID)
  if itemID == nil then
    return
  end
  if self.m_ClickListener then
    self.m_ClickListener(itemID, self)
  end
end
function CShowLifeSkillItemFrame:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    self:ResetToOriPosXY()
    local startPos = touchObj:getTouchStartPos()
    self.m_TouchBeganItem = self:checkTouchBeganPos(startPos)
    self.m_HasTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    local startPos = touchObj:getTouchStartPos()
    local movePos = touchObj:getTouchMovePos()
    if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
      self.m_HasTouchMoved = true
    end
    if self.m_HasTouchMoved and self.m_TouchBeganItem then
      self.m_TouchBeganItem:setTouchState(false)
      self.m_TouchBeganItem = nil
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      if self.m_TouchBeganItem ~= nil then
        self.m_TouchBeganItem:setTouchState(false)
        self.m_TouchBeganItem = nil
      end
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
    else
      self:ClickAtPos()
    end
  end
end
function CShowLifeSkillItemFrame:checkTouchBeganPos(pos)
  local touchPos = self:convertToNodeSpace(ccp(pos.x, pos.y))
  for _, itemObj in pairs(self.m_TotalItemObj) do
    local x, y = itemObj:getPosition()
    if x <= touchPos.x and touchPos.x <= x + self.m_ItemSize.width and y <= touchPos.y and touchPos.y <= y + self.m_ItemSize.height then
      itemObj:setTouchState(true)
      return itemObj
    end
  end
  return nil
end
function CShowLifeSkillItemFrame:getTouchBeganItem()
  return self.m_TouchBeganItem
end
function CShowLifeSkillItemFrame:ClickAtPos(startPos)
  if self.m_TouchBeganItem == nil then
    return
  end
  self:ClickPackageItem(self.m_TouchBeganItem.itemTypeId)
  self.m_SelectedID = self.m_TouchBeganItem.itemTypeId
  for _, item in pairs(self.m_TotalItemObj) do
    item:setSelected(false)
  end
  if self.m_SelectedID ~= nil then
    self.m_TouchBeganItem:setSelected(true)
  end
  self.m_TouchBeganItem:setTouchState(false)
  self.m_TouchBeganItem = nil
end
function CShowLifeSkillItemFrame:ClearSelectItem()
  self.m_SelectedID = nil
  for _, item in pairs(self.m_TotalItemObj) do
    item:setSelected(false)
  end
end
function CShowLifeSkillItemFrame:ResetToOriPosXY()
  for _, itemObj in pairs(self.m_TotalItemObj) do
    itemObj:stopAllActions()
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:setPosition(oriPosXY)
  end
end
function CShowLifeSkillItemFrame:BackToOriPosXY()
  for _, itemObj in pairs(self.m_TotalItemObj) do
    local oriPosXY = itemObj.m_OriPosXY
    itemObj:stopAllActions()
    itemObj:runAction(CCMoveTo:create(0.3, oriPosXY))
  end
end
function CShowLifeSkillItemFrame:onCleanup()
  self.m_ClickListener = nil
end
