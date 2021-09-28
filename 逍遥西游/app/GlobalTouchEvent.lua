GlobalTouchEvent = class("GlobalTouchEvent", function()
  return display.newNode()
end)
function GlobalTouchEvent:ctor()
  self:setTouchEnabled(true)
  self:setTouchCaptureEnabled(true)
  self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.Touch))
  self:setContentSize(CCSize(display.width, display.height))
  self.m_ListenerIndex = 0
  self.m_CanTouchNum = 0
  self.m_TouchListener = {}
end
function GlobalTouchEvent:Start()
  local scene = CCScene:create()
  scene:retain()
  scene:addChild(self)
  scene:onEnterLua()
  scene:onEnterTransitionDidFinishLua()
end
function GlobalTouchEvent:Clear()
  self.m_TouchListener = {}
end
function GlobalTouchEvent:Touch(event)
  local name, x, y, prevX, prevY = event.name, event.x, event.y, event.prevX, event.prevY
  for k, v in pairs(self.m_TouchListener) do
    v(name, x, y, prevX, prevY)
  end
  return true
end
function GlobalTouchEvent:registerGlobalTouchEvent(obj, listener)
  if obj.__globalTouchEvent_listener_key ~= nil then
    return
  end
  self.m_ListenerIndex = self.m_ListenerIndex + 1
  obj.__globalTouchEvent_listener_key = self.m_ListenerIndex
  self.m_TouchListener[self.m_ListenerIndex] = listener
end
function GlobalTouchEvent:unRegisterGlobalTouchEvent(obj)
  if obj.__globalTouchEvent_listener_key ~= nil then
    self.m_TouchListener[obj.__globalTouchEvent_listener_key] = nil
    obj.__globalTouchEvent_listener_key = nil
  end
end
function GlobalTouchEvent:setCanTouch(flag)
  if flag then
    self.m_CanTouchNum = math.max(0, self.m_CanTouchNum - 1)
  else
    self.m_CanTouchNum = self.m_CanTouchNum + 1
  end
  if self.m_CanTouchNum > 0 then
    self:setTouchEnabled(false)
  else
    self:setTouchEnabled(true)
  end
end
g_TouchEvent = GlobalTouchEvent.new()
g_TouchEvent:Start()
gamereset.registerResetFunc(function()
  if g_TouchEvent then
    g_TouchEvent:Clear()
  end
end)
