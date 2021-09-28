local ScrollBase = require("universal.ScrollBase")
local ScrollView = class("ScrollView", ScrollBase)
function ScrollView:ctor(w, h, selListener, isHORIZONTAL, priority)
  self.m_Direction = isHORIZONTAL and ScrollBase.DIRECTION_HORIZONTAL or ScrollBase.DIRECTION_VERTICAL
  ScrollView.super.ctor(self, w, h, self.m_Direction, priority)
  self.m_ContView = CCLayerColor:create(ccc4(255, 0, 0, 0))
  self:setNodeEventEnabled(true)
  self.m_ContSize = {width = 0, height = 0}
  if isHORIZONTAL then
    self.m_ContSize.height = h
  else
    self.m_ContSize.width = w
  end
  self:setView(self.m_ContView, self.m_ContSize.width, self.m_ContSize.height)
  self.m_ItemObjs = {}
  self.m_ItemSize = {}
  self.m_SelListener = selListener
  self.m_DetectListenerStartPos = nil
  self.m_TouchDetectMaxMove = 10
  self.m_ExtendSize = {width = 0, height = 0}
  self.m_IsEnableDragFlush = false
  self.m_FlushListener = false
  self:setDragBeyondListener(function(beyondType)
    self:_DragToBeyond(beyondType)
  end)
  self.m_MoreTxt = nil
  self.m_LoadingSprite = nil
  self.m_LoadingPath = nil
  self.m_DragFlushListener = nil
end
function ScrollView:onCleanup()
  ScrollView.super.onCleanup(self)
  self.m_ContView = nil
  self.m_ItemObjs = nil
  self.m_ItemSize = nil
  self.m_SelListener = nil
  self.m_FlushListener = nil
  self.m_LoadingSprite = nil
  self.m_DragFlushListener = nil
end
function ScrollView:setViewSize(w, h)
  ScrollView.super.setViewSize(self, w + self.m_ExtendSize.width, h + self.m_ExtendSize.height)
  self:_resetMoreTxtPos()
end
function ScrollView:DetectTouchItem(event, x, y)
  if self.m_SelListener == nil then
    return
  end
  if event == "began" then
    self.m_DetectListenerStartPos = {x = x, y = y}
  elseif event == "ended" then
    if self.m_DetectListenerStartPos and self.m_SelListener then
      local dis = math.abs(self.m_DetectListenerStartPos.x - x) + math.abs(self.m_DetectListenerStartPos.y - y)
      if dis <= self.m_TouchDetectMaxMove then
        local pos = self.m_ContView:convertToNodeSpace(ccp(self.m_DetectListenerStartPos.x, self.m_DetectListenerStartPos.y))
        local tx = pos.x
        local ty = pos.y
        if self.m_Direction == ScrollView.DIRECTION_VERTICAL then
          for i, item in ipairs(self.m_ItemObjs) do
            local sizeInfo = self.m_ItemSize[i]
            if tx >= sizeInfo.x and tx <= sizeInfo.x + sizeInfo.size.width and ty <= sizeInfo.y and ty >= sizeInfo.y - sizeInfo.size.height then
              self.m_SelListener(item, i)
              break
            end
          end
        else
          for i, item in ipairs(self.m_ItemObjs) do
            local sizeInfo = self.m_ItemSize[i]
            if tx >= sizeInfo.x and tx <= sizeInfo.x + sizeInfo.size.width and ty >= sizeInfo.y and ty <= sizeInfo.y + sizeInfo.size.height then
              self.m_SelListener(item, i)
              break
            end
          end
        end
      end
    end
    self.m_DetectListenerStartPos = nil
  end
end
function ScrollView:onTouch(event, x, y)
  self:DetectTouchItem(event, x, y)
  return ScrollView.super.onTouch(self, event, x, y)
end
function ScrollView:appendItem(item, size, ex, ey)
  self:insertItem(item, #self.m_ItemObjs + 1, size, ex, ey)
end
function ScrollView:delItem(item)
  for i, tItem in ipairs(self.m_ItemObjs) do
    if tItem == item then
      return self:delIndex(i)
    end
  end
  return false
end
function ScrollView:delIndex(idx)
  print("ScrollView.delIndex:", idx)
  local item = self.m_ItemObjs[idx]
  if item == nil then
    print("delIndex, item == nil")
    return false
  end
  local size = self.m_ItemSize[idx].size
  item:setVisible(false)
  self.m_ContView:removeChild(item, true)
  table.remove(self.m_ItemObjs, idx)
  table.remove(self.m_ItemSize, idx)
  for i = idx, #self.m_ItemObjs do
    local sizeInfo = self.m_ItemSize[i]
    local cx, cy = self.m_ItemObjs[i]:getPosition()
    if self.m_Direction == ScrollBase.DIRECTION_HORIZONTAL then
      sizeInfo.x = sizeInfo.x - size.width
      cx = cx - size.width
    else
      sizeInfo.y = sizeInfo.y + size.height
      cy = cy + size.height
    end
    self.m_ItemObjs[i]:setPosition(cx, cy)
  end
  if self.m_Direction == ScrollBase.DIRECTION_HORIZONTAL then
    self.m_ContSize.width = self.m_ContSize.width - size.width
  else
    self.m_ContSize.height = self.m_ContSize.height - size.height
  end
  self.m_ContView:setContentSize(CCSize(self.m_ContSize.width, self.m_ContSize.height))
  self:setViewSize(self.m_ContSize.width, self.m_ContSize.height)
  return true
end
function ScrollView:DeletaAllItems()
  for i, item in ipairs(self.m_ItemObjs) do
    item:setVisible(false)
    self.m_ContView:removeChild(item, true)
  end
  self.m_ItemObjs = {}
  self.m_ItemSize = {}
  if self.m_Direction == ScrollBase.DIRECTION_HORIZONTAL then
    self.m_ContSize.width = 0
  else
    self.m_ContSize.height = 0
  end
  self.m_ContView:setContentSize(CCSize(self.m_ContSize.width, self.m_ContSize.height))
  self:setViewSize(self.m_ContSize.width, self.m_ContSize.height)
end
function ScrollView:insertItem(item, idx, size, ex, ey)
  if item.setAddedScroller then
    item:setAddedScroller(self)
  end
  local curLen = #self.m_ItemObjs
  if idx == nil or idx > curLen + 1 then
    idx = curLen + 1
  end
  if idx <= 0 then
    idx = 0
  end
  ex = ex or 0
  ey = ey or 0
  local size = size or item:getContentSize()
  local x = 0
  local y = 0
  local rx = 0
  local ry = 0
  local preSize = CCSizeMake(0, 0)
  print("curLen =", curLen)
  print("size =", size.width, size.height)
  if curLen >= idx - 1 and idx > 1 then
    x = self.m_ItemSize[idx - 1].x
    y = self.m_ItemSize[idx - 1].y
    preSize = self.m_ItemSize[idx - 1].size
  end
  if self.m_Direction == ScrollBase.DIRECTION_HORIZONTAL then
    x = x + preSize.width
    self.m_ContSize.width = self.m_ContSize.width + size.width
    if size.height > self.m_ContSize.height then
      self.m_ContSize.height = size.height
    end
    ry = y + ey
  else
    y = y - preSize.height
    self.m_ContSize.height = self.m_ContSize.height + size.height
    if size.width > self.m_ContSize.width then
      self.m_ContSize.width = size.width
    end
    ry = y - size.height + ey
  end
  self.m_ContView:addChild(item)
  rx = x + ex
  print("x, y = ", x, y, size.height)
  item:setPosition(rx, ry)
  for i = idx, #self.m_ItemObjs do
    local sizeInfo = self.m_ItemSize[i]
    local cx, cy = self.m_ItemObjs[i]:getPosition()
    if self.m_Direction == ScrollBase.DIRECTION_HORIZONTAL then
      sizeInfo.x = sizeInfo.x + size.width
      cx = cx + size.width
    else
      sizeInfo.y = sizeInfo.y - size.height
      cy = cy - size.height
    end
    self.m_ItemObjs[i]:setPosition(cx, cy)
  end
  print("self.m_ContSize.width, self.m_ContSize.height =", self.m_ContSize.width, self.m_ContSize.height)
  self.m_ContView:setContentSize(CCSize(self.m_ContSize.width, self.m_ContSize.height))
  self:setViewSize(self.m_ContSize.width, self.m_ContSize.height)
  table.insert(self.m_ItemObjs, idx, item)
  table.insert(self.m_ItemSize, idx, {
    x = x,
    y = y,
    size = size
  })
end
function ScrollView:getItemAmount()
  return #self.m_ItemObjs
end
function ScrollView:getItemAtIndex(index)
  return self.m_ItemObjs[index]
end
function ScrollView:setEnableDragFlush(isEnable, flushListener, loadingPath)
  print("setEnableDragFlush isEnable =", isEnable)
  self.m_DragFlushListener = flushListener
  self.m_LoadingPath = loadingPath or "uicommon/pic_loading.png"
  self.m_IsEnableDragFlush = isEnable
  self:_resetEnableDragStatus()
end
function ScrollView:_resetEnableDragStatus()
  if self.m_IsEnableDragFlush == false then
    self:setLoadingShow(false)
    self:setMoreTxtShow(false)
  else
    self:setLoadingShow(false)
    self:setMoreTxtShow(true)
  end
end
function ScrollView:setMoreLabelColor(c)
  self.m_MoreLabelColor = c
end
function ScrollView:resetDragFlush(isEnable)
  if isEnable ~= nil then
    self.m_IsEnableDragFlush = isEnable
  end
  self:_resetEnableDragStatus()
end
function ScrollView:_DragToBeyond()
  if self.m_IsEnableDragFlush == false then
    return
  end
  self:setLoadingShow(true)
  self:setMoreTxtShow(false)
  if self.m_DragFlushListener then
    self.m_DragFlushListener()
  end
end
function ScrollView:setMoreTxtShow(isShow)
  print("setMoreTxtShow isShow =", isShow)
  if isShow then
    if self.m_MoreTxt == nil then
      local txt = getTxtWithTxt("More...")
      self.m_MoreTxt = ui.newTTFLabel({
        text = txt,
        font = "CooperBlackStd",
        size = 32,
        color = self.m_MoreLabelColor or ccc3(161, 255, 252)
      })
      self.m_ContView:addChild(self.m_MoreTxt)
      local size = self.m_MoreTxt:getContentSize()
      self.m_ExtendSize.height = size.height * 1.5
      self:setViewSize(self.m_ContSize.width, self.m_ContSize.height)
    else
      self.m_MoreTxt:setVisible(true)
    end
  elseif self.m_MoreTxt then
    self.m_ContView:removeChild(self.m_MoreTxt, true)
    self.m_MoreTxt = nil
    self.m_ExtendSize = {width = 0, height = 0}
    self:setViewSize(self.m_ContSize.width, self.m_ContSize.height)
  else
    print("=========moreTxt = false ==========")
  end
end
function ScrollView:setLoadingShow(isShow)
  print("======setLoadingShow:", isShow)
  if isShow then
    if self.m_LoadingSprite == nil then
      self.m_LoadingSprite = display.newSprite(self.m_LoadingPath)
      self.m_ContView:addChild(self.m_LoadingSprite)
      self:setViewSize(self.m_ContSize.width, self.m_ContSize.height)
      local act1 = CCDelayTime:create(0.1)
      local act2 = CCRotateBy:create(0, 30)
      local act3 = transition.sequence({act1, act2})
      self.m_LoadingSprite:runAction(CCRepeatForever:create(act3))
    end
    self.m_LoadingSprite:setVisible(true)
  elseif self.m_LoadingSprite then
    self.m_LoadingSprite:setVisible(false)
  end
end
function ScrollView:_resetMoreTxtPos()
  print("================> _resetMoreTxtPos")
  print("----- ContentSize =", self.m_ContSize.width, self.m_ContSize.height)
  print([[


]])
  if self.m_MoreTxt then
    local size = self.m_MoreTxt:getContentSize()
    self.m_MoreTxt:setPosition(self.m_ContSize.width / 2, -(self.m_ContSize.height + size.height / 2))
  end
  if self.m_LoadingSprite then
    local size = self.m_LoadingSprite:getContentSize()
    self.m_LoadingSprite:setPosition(self.m_ContSize.width / 2, -(self.m_ContSize.height + size.height / 2))
  end
end
function ScrollView:setRelativeMorePic(obj)
  self.m_RelativeMorePic = obj
end
function ScrollView:tick(dt)
  self.super.tick(self, dt)
  if self.m_RelativeMorePic ~= nil and self.direction == ScrollBase.DIRECTION_VERTICAL then
    if not self:isVisible() then
      self.m_RelativeMorePic:setVisible(false)
    elseif self._viewHeight < self._clippingRect.size.height then
      self.m_RelativeMorePic:setVisible(false)
    else
      local x, y = self._viewRoot:getPosition()
      self.m_RelativeMorePic:setVisible(y < self._maxY)
    end
  end
end
return ScrollView
