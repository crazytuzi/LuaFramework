local ScrollBase = class("ScrollBase", function(w, h)
  assert(type(w) == "number" and type(h) == "number", "@ScrollBase(). params may be error.")
  return display.newClippingRegionNode(CCRect(0, 0, w, h))
end)
ScrollBase.DIRECTION_VERTICAL = 1
ScrollBase.DIRECTION_HORIZONTAL = 2
ScrollBase.ScrollingSpaceTime = 0.1
ScrollBase.ScrollingSubSpeed = 2000
ScrollBase.ScrollingSpeedLimit = 2500
function ScrollBase:ctor(w, h, direction, priority)
  assert(direction == ScrollBase.DIRECTION_VERTICAL or direction == ScrollBase.DIRECTION_HORIZONTAL, "ScrollBase:ctor() - invalid direction")
  priority = priority or 0
  self._defaultAnimateTime = 0.4
  self._defaultAnimateEasing = "backOut"
  self._backBoundEnabled = true
  self._scrollingSubSpeed = nil
  self._scrollingSpeedLimit = nil
  self._scrollingSpeed = 0
  self._scrollingAhead = false
  self._localTimer = 0
  self._DragToBeyondListener = nil
  self._isDetectBeyondListener = false
  self.direction = direction
  self._clippingRect = CCRect(0, 0, w, h)
  self._ScrollSize = CCSize(w, h)
  self._layer = display.newLayer():addTo(self)
  self._viewRoot = display.newNode():addTo(self)
  self._viewWidth, self._viewHeight = 0, 0
  self._layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    return self:onTouch(event.name, event.x, event.y)
  end)
  self:setTouchEnabled(true)
  local function tick(dt)
    self:tick(dt)
  end
  self.m_Updatahandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
end
function ScrollBase:getView()
  return self._view
end
function ScrollBase:setView(sp, viewWidth, viewHeight)
  self:clearView()
  self._view = sp
  self._viewRoot:addChild(sp)
  if viewWidth and viewHeight then
    self._viewWidth = viewWidth
    self._viewHeight = viewHeight
    self._view:pos(0, 0)
    self:computeScrollMax()
    self:scrollToTop()
  else
    self:computeBoundingAndRePos()
  end
  return self
end
function ScrollBase:setViewSize(viewWidth, viewHeight)
  self._viewWidth = viewWidth or self._viewWidth
  self._viewHeight = viewHeight or self._viewHeight
  self:computeScrollMax()
end
function ScrollBase:getScrollSize()
  return self._ScrollSize
end
function ScrollBase:getViewLength()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    return self._viewWidth
  else
    return self._viewHeight
  end
end
function ScrollBase:clearView()
  if self._view then
    self._view:clear()
    self._view = nil
  end
  return self
end
function ScrollBase:getClippingRect()
  return self._clippingRect
end
function ScrollBase:setClippingRect(rect)
  self:setClippingRegion(rect)
  self._clippingRect = rect
  if not self._view then
    return self
  end
  self:computeScrollMax()
  self:scrollToTop()
  return self
end
function ScrollBase:setDragBeyondListener(listener)
  self._DragToBeyondListener = listener
end
function ScrollBase:setBackBoundEnabled(v)
  if v == nil then
    v = true
  end
  if v == 0 then
    v = false
  end
  if v then
    self._backBoundEnabled = true
  else
    self._backBoundEnabled = false
  end
  return self
end
function ScrollBase:setAlignUnitLength(v)
  v = v and toint(v)
  if v == 0 then
    v = nil
  end
  self._alignUnitLength = v
  return self
end
function ScrollBase:getCurrUnitIdx()
  if not self._alignUnitLength then
    return 1
  end
  local x, y = self._viewRoot:getPosition()
  local len = self._alignUnitLength
  local offset = 0
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    if x >= self._maxX then
      return 1
    end
    if x <= self._minX then
      return math.round((self._maxX - self._minX) / len) + 1
    end
    return math.round((self._maxX - x) / len) + 1
  else
    if y >= self._maxY then
      return 1
    end
    if y <= self._minY then
      return math.round((self._maxY - self._minY) / len) + 1
    end
    return math.round((y - self._minY) / len) + 1
  end
end
function ScrollBase:getScrollLoc()
  local x, y = self._viewRoot:getPosition()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    return self._maxX - x
  else
    return y - self._minY
  end
end
function ScrollBase:scrollToTop(animated, time, easing)
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    self:setContentOffset(self._maxX, animated, time, easing)
  else
    self:setContentOffset(self._minY, animated, time, easing)
  end
  return self
end
function ScrollBase:scrollToUnit(idx, animated, time, easing)
  assert(idx and idx > 0, "@ScrollBase:scrollToUnit(). 'idx' must be >0.")
  if self._alignUnitLength then
    local _newLoc = 0
    if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
      _newLoc = self._maxX - self._alignUnitLength * (idx - 1)
      if _newLoc < self._minX then
        _newLoc = self._minX
      end
      self:setContentOffset(_newLoc, animated, time, easing)
    else
      _newLoc = self._minY + self._alignUnitLength * (idx - 1)
      if _newLoc > self._maxY then
        _newLoc = self._maxY
      end
      self:setContentOffset(_newLoc, animated, time, easing)
    end
  end
  return self
end
function ScrollBase:scrollToLen(len, animated, time, easing)
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    self:setContentOffset(math.max(self._maxX - len, self._minX), animated, time, easing)
  else
    self:setContentOffset(math.min(self._minY + len, self._maxY), animated, time, easing)
  end
end
function ScrollBase:isTouchEnabled()
  return self._layer:isTouchEnabled()
end
function ScrollBase:setTouchEnabled(enabled)
  self._layer:setTouchEnabled(enabled)
end
function ScrollBase:setTouchEnded(func)
  self._funcTouchEnded = func
end
function ScrollBase:setScrollingSubSpeed(subSpeed)
  self._scrollingSubSpeed = subSpeed
end
function ScrollBase:setScrollingSpeedLimit(speedLimit)
  self._scrollingSpeedLimit = speedLimit
end
function ScrollBase:onTouchBegan(x, y)
  if not self._clippingRect:containsPoint(self:convertToNodeSpace(ccp(x, y))) then
    return false
  end
  local _posx, _posy = self._viewRoot:getPosition()
  self._stat = {
    startViewX = _posx,
    startViewY = _posy,
    startTouchX = x,
    startTouchY = y,
    lastTouchX = x,
    lastTouchY = y,
    speedX = 0,
    speedY = 0,
    lastTime = self._localTimer
  }
  self:stopScrollAhead()
  self._isDetectBeyondListener = true
  return true
end
function ScrollBase:onTouchMoved(x, y)
  local _newLoc = 0
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    _newLoc = x - self._stat.startTouchX + self._stat.startViewX
    if _newLoc > self._maxX then
      _newLoc = self._maxX + math.floor((_newLoc - self._maxX) / 3)
    elseif _newLoc < self._minX then
      _newLoc = self._minX - math.floor((self._minX - _newLoc) / 3)
    end
    self:setContentOffset(_newLoc)
  else
    _newLoc = y - self._stat.startTouchY + self._stat.startViewY
    if _newLoc > self._maxY then
      _newLoc = self._maxY + math.floor((_newLoc - self._maxY) / 3)
    elseif _newLoc < self._minY then
      _newLoc = self._minY - math.floor((self._minY - _newLoc) / 3)
    end
    self:setContentOffset(_newLoc)
  end
  local dTime = math.max(self._localTimer - self._stat.lastTime, 0.01)
  self._stat.lastTime = self._localTimer
  self._stat.speedX = (x - self._stat.lastTouchX) / dTime
  self._stat.speedY = (y - self._stat.lastTouchY) / dTime
  self._stat.lastTouchX = x
  self._stat.lastTouchY = y
end
function ScrollBase:onTouchEnded(x, y)
  self._initAtTheBottom = self:isViewAtTheBottom()
  if self._stat == nil then
    self:touchEndedBackBound()
    self:touchEndedByUnit()
  else
    local deltaTime = self._localTimer - self._stat.lastTime
    if deltaTime > ScrollBase.ScrollingSpaceTime then
      self:touchEndedBackBound()
      self:touchEndedByUnit()
    else
      self:scrollAhead(self._stat.speedX, self._stat.speedY)
    end
  end
  if self._funcTouchEnded then
    self._funcTouchEnded()
  end
  self._stat = nil
end
function ScrollBase:onTouch(event, x, y)
  if tolua.isnull(self._view) then
    return
  end
  if event == "began" then
    return self:onTouchBegan(x, y)
  elseif event == "moved" then
    self:onTouchMoved(x, y)
  else
    if event == "ended" then
      self:onTouchEnded(x, y)
    else
    end
  end
end
function ScrollBase:isBeyondView()
  local beyond = false
  local x, y = self._viewRoot:getPosition()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    if x > self._maxX then
      return x - self._maxX, 3
    elseif x < self._minX then
      return self._minX - x, 1
    end
  elseif y > self._maxY then
    return y - self._maxY, 0
  elseif y < self._minY then
    return self._minY - y, 2
  end
  return 0, -1
end
function ScrollBase:isViewAtTheBottom()
  local x, y = self._viewRoot:getPosition()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    return x >= self._maxX
  else
    return y >= self._maxY
  end
end
function ScrollBase:scrollAhead(speedX, speedY)
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    self._scrollingSpeed = speedX
  else
    self._scrollingSpeed = speedY
  end
  local speedLimit = self._scrollingSpeedLimit or ScrollBase.ScrollingSpeedLimit
  if self._scrollingSpeed > 0 then
    self._scrollingSpeed = math.min(self._scrollingSpeed, speedLimit)
  else
    self._scrollingSpeed = math.max(self._scrollingSpeed, -speedLimit)
  end
  self._scrollingAhead = true
end
function ScrollBase:onScrollingAhead(dt)
  if self._scrollingSpeed == 0 then
    self:scrollAheadOver()
    return
  end
  local subSpeed
  local beyond, beyondType = self:isBeyondView()
  if beyond > 0 then
    local temp
    local speedLimit = self._scrollingSpeedLimit or ScrollBase.ScrollingSpeedLimit
    if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
      temp = beyond ^ 1.5 / self._clippingRect.size.width * speedLimit
    else
      temp = beyond ^ 1.5 / self._clippingRect.size.height * speedLimit
    end
    local scrollSubSpeed = self._scrollingSubSpeed or ScrollBase.ScrollingSubSpeed
    subSpeed = (scrollSubSpeed + temp) * dt
  else
    local scrollSubSpeed = self._scrollingSubSpeed or ScrollBase.ScrollingSubSpeed
    subSpeed = scrollSubSpeed * dt
  end
  if self._scrollingSpeed > 0 then
    self._scrollingSpeed = self._scrollingSpeed - subSpeed
    if self._scrollingSpeed < 0 then
      self._scrollingSpeed = 0
    end
  else
    self._scrollingSpeed = self._scrollingSpeed + subSpeed
    if self._scrollingSpeed > 0 then
      self._scrollingSpeed = 0
    end
  end
  local x, y = self._viewRoot:getPosition()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    x = x + self._scrollingSpeed * dt
  else
    y = y + self._scrollingSpeed * dt
  end
  self._viewRoot:setPosition(x, y)
end
function ScrollBase:scrollAheadOver()
  self._scrollingAhead = false
  self._scrollingSpeed = 0
  self:touchEndedBackBound(true)
  self:touchEndedByUnit()
end
function ScrollBase:stopScrollAhead()
  self._scrollingAhead = false
  self._scrollingSpeed = 0
end
function ScrollBase:computeBoundingAndRePos()
  local _viewBounding = self._viewRoot:boundingRect()
  self._viewWidth = _viewBounding.size.width
  self._viewHeight = _viewBounding.size.height
  self._view:pos(-_viewBounding.origin.x, -_viewBounding.origin.y - self._viewHeight)
  self:computeScrollMax()
  self:scrollToTop()
end
function ScrollBase:computeScrollMax()
  if not self._view then
    return
  end
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    self._maxX = 0
    self._minX = math.min(0, -self._viewWidth + self._clippingRect.size.width)
  else
    self._maxY = math.max(self._viewHeight, self._clippingRect.size.height)
    self._minY = self._clippingRect.size.height
  end
end
function ScrollBase:setContentOffset(offset, animated, time, easing)
  local x, y = self._viewRoot:getPosition()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    x = offset
  else
    y = offset
  end
  if animated then
    transition.stopTarget(self._viewRoot)
    transition.moveTo(self._viewRoot, {
      x = x,
      y = y,
      time = time or self._defaultAnimateTime,
      easing = easing or self._defaultAnimateEasing
    })
  else
    self._viewRoot:setPosition(ccp(x, y))
  end
end
function ScrollBase:touchEndedBackBound(overByScrolling)
  local x, y = self._viewRoot:getPosition()
  local callListener = false
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    if x > self._maxX then
      callListener = x - self._maxX > self._clippingRect.size.width / 6
      x = self._maxX
    elseif x < self._minX then
      callListener = self._minX - x > self._clippingRect.size.width / 6
      x = self._minX
    else
      self._isDetectBeyondListener = false
      return
    end
    self:setContentOffset(x, true)
  else
    if y > self._maxY then
      callListener = y - self._maxY > self._clippingRect.size.height / 6
      y = self._maxY
    elseif y < self._minY then
      callListener = self._minY - y > self._clippingRect.size.height / 6
      y = self._minY
    else
      self._isDetectBeyondListener = false
      return
    end
    self:setContentOffset(y, true)
  end
  if overByScrolling and not self._initAtTheBottom then
    callListener = false
  end
  if callListener and self._isDetectBeyondListener and self._DragToBeyondListener then
    self._isDetectBeyondListener = false
    if self._DragToBeyondListener then
      self._DragToBeyondListener()
    end
  end
  self._isDetectBeyondListener = false
end
function ScrollBase:touchEndedByUnit()
  if not self._alignUnitLength then
    return
  end
  local len = self._alignUnitLength
  local x, y = self._viewRoot:getPosition()
  if self.direction == ScrollBase.DIRECTION_HORIZONTAL then
    if x >= self._maxX or x <= self._minX then
      return
    end
    x = (math.floor(x / len) + math.round(x % len / len)) * len
    self:setContentOffset(x, true)
  else
    if y >= self._maxY or y <= self._minY then
      return
    end
    local offset = y - self._minY
    offset = (math.floor(offset / len) + math.round(offset % len / len)) * len
    y = self._minY + offset
    self:setContentOffset(y, true)
  end
end
function ScrollBase:onCleanup()
  CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_Updatahandle)
  self._DragToBeyondListener = nil
end
function ScrollBase:tick(dt)
  self._localTimer = self._localTimer + dt
  if self._scrollingAhead then
    self:onScrollingAhead(dt)
  end
end
return ScrollBase
