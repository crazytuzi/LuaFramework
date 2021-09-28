local clickwidget = {}
function clickwidget.create(w, h, anchorPointX, anchorPointY, handle)
  local tempClickWidget = Widget:create()
  tempClickWidget:ignoreContentAdaptWithSize(false)
  tempClickWidget:setSize(CCSize(w, h))
  tempClickWidget:setTouchEnabled(true)
  tempClickWidget:setAnchorPoint(ccp(anchorPointX, anchorPointY))
  if handle ~= nil then
    tempClickWidget:addTouchEventListener(handle)
  end
  return tempClickWidget
end
MOVE_JUDGE_DEL_LONGPRESS = 100
function clickwidget.createOneClickWidget(w, h, anchorPointX, anchorPointY, clickListener, clickDel)
  local tempClickWidget = Widget:create()
  tempClickWidget:ignoreContentAdaptWithSize(false)
  tempClickWidget:setSize(CCSize(w, h))
  tempClickWidget:setTouchEnabled(true)
  tempClickWidget:setAnchorPoint(ccp(anchorPointX, anchorPointY))
  clickwidget.extendLongPressAndClickFunc(tempClickWidget, 0, clickListener, nil, nil, clickDel)
  return tempClickWidget
end
function clickwidget.extendClickFunc(obj, clickListener, clickDel, clickSoundType)
  clickwidget.extendLongPressAndClickFunc(obj, 0, clickListener, nil, nil, clickDel, clickSoundType)
end
function clickwidget.extendLongPressAndClickFunc(obj, LongPressTime, clickListener, LongPressListener, LongPressEndListner, clickDel, clickSoundType)
  local LongPressHandler
  obj:setNodeEventEnabled(true)
  function obj:longPressSchedule()
    if LongPressHandler ~= nil then
      scheduler.unscheduleGlobal(LongPressHandler)
    end
    local startPos = obj:getTouchStartPos()
    local movePos = obj:getTouchMovePos()
    if obj.m_HasMoveDel > MOVE_JUDGE_DEL_LONGPRESS then
      return
    end
    if LongPressListener then
      LongPressListener(obj, t)
      obj.m_HasLongPressFlag = true
    end
  end
  function obj:showClickEffect()
    if obj.m_ObjOldPos == nil then
      local x, y = obj:getPosition()
      obj.m_ObjOldPos = ccp(x, y)
      obj.m_ObjOldScale = obj:getScale()
      obj.m_ObjSize = obj:getContentSize()
    end
    local clickScale = 1.1 * obj.m_ObjOldScale
    obj:setScale(clickScale)
    obj:setPosition(ccp(obj.m_ObjOldPos.x + obj.m_ObjSize.width * (obj.m_ObjOldScale - clickScale) / 2, obj.m_ObjOldPos.y + obj.m_ObjSize.height * (obj.m_ObjOldScale - clickScale) / 2))
  end
  function obj:showOldEffect()
    if obj.m_ObjOldPos ~= nil then
      obj:setScale(obj.m_ObjOldScale)
      obj:setPosition(ccp(obj.m_ObjOldPos.x, obj.m_ObjOldPos.y))
    end
  end
  obj:setTouchEnabled(true)
  obj.m_HasLongPressFlag = false
  obj.m_HasMoveDel = 0
  obj.m_HasMoveFlag = false
  clickDel = clickDel or 10
  obj:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      obj.m_HasMoveFlag = false
      obj:showClickEffect()
      obj.m_HasMoveDel = 0
      if LongPressHandler ~= nil then
        scheduler.unscheduleGlobal(LongPressHandler)
      end
      if LongPressTime > 0 then
        LongPressHandler = scheduler.scheduleGlobal(handler(obj, obj.longPressSchedule), LongPressTime)
      end
    elseif t == TOUCH_EVENT_MOVED then
      local startPos = obj:getTouchStartPos()
      local movePos = obj:getTouchMovePos()
      obj.m_HasMoveDel = obj.m_HasMoveDel + math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y)
      if clickDel and (math.abs(startPos.x - movePos.x) > clickDel or math.abs(startPos.y - movePos.y) > clickDel) then
        obj.m_HasMoveFlag = true
        obj:showOldEffect()
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      obj:showOldEffect()
      if obj.m_HasLongPressFlag == false then
        local endPos = obj:getTouchEndPos()
        local ap = obj:getAnchorPoint()
        local size = obj:getContentSize()
        local leftDown = obj:convertToWorldSpace(ccp(-size.width * ap.x, -size.height * ap.y))
        local rightTop = obj:convertToWorldSpace(ccp(size.width * (1 - ap.x), size.height * (1 - ap.y)))
        local insideFlag = endPos.x >= leftDown.x and endPos.x <= rightTop.x and endPos.y >= leftDown.y and endPos.y <= rightTop.y
        local isClickFlag = false
        if insideFlag then
          if clickDel then
            if obj.m_HasMoveFlag == false then
              isClickFlag = true
            end
          else
            isClickFlag = true
          end
          if isClickFlag then
            if clickSoundType ~= nil and clickSoundType ~= 0 then
              soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", clickSoundType))
            end
            if clickListener then
              clickListener(touchObj, t)
            end
          end
        end
      elseif LongPressEndListner then
        LongPressEndListner(touchObj, t)
      end
      if LongPressHandler ~= nil then
        scheduler.unscheduleGlobal(LongPressHandler)
      end
      obj.m_HasLongPressFlag = false
    end
  end)
  function obj:onCleanup()
    if LongPressEndListner then
      LongPressEndListner(obj, t)
    end
  end
end
return clickwidget
