CcsUIView = class("CcsUIView", function()
  local cLayer = Layout:create()
  return cLayer
end)
function CcsUIView:ctor(uifilePath, addToUigroupZorder, param)
  param = param or {}
  local uizOrder = param.uizOrder or 0
  if uifilePath then
    CcsUIConfig.load(self, uifilePath)
  end
  addToUigroupZorder = addToUigroupZorder or 0
  if self.m_UINode ~= nil then
    local uiGroup = TouchGroup:create()
    uiGroup:scheduleUpdate()
    self:addNode(uiGroup, uizOrder)
    uiGroup:getRootWidget():addChild(self.m_UINode, addToUigroupZorder)
    self.m_UIGroup = uiGroup
  end
  self.m_IsTouchEnable = true
  self.m_ViewZOrder = param.viewZOrder or 0
  self.m_ViewTag = param.viewZTag or -1
  self.m_IsTouchEnable = true
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  WaitingViewExtend.extend(self)
end
function CcsUIView:setViewTouchEnabled(isEnable)
  self.m_IsTouchEnable = isEnable
end
function CcsUIView:AddTo(p, z, t)
  if z ~= nil then
    self.m_ViewZOrder = z
  end
  if t ~= nil then
    self.m_ViewTag = t
  end
  if p == nil then
    p = display.getRunningScene()
  end
  if p == nil then
    self:ShowAsScene()
  else
    self:addTo(p, self.m_ViewZOrder, self.m_ViewTag)
  end
  return self
end
function CcsUIView:addToTop(p, t)
  if p == nil then
    p = display.getRunningScene()
  end
  self.m_ViewZOrder = getMaxZ(p)
  if t ~= nil then
    self.m_ViewTag = t
  end
  self:addTo(p, self.m_ViewZOrder, self.m_ViewTag)
  return self
end
function CcsUIView:ShowAsScene(transitionType, time, more)
  transitionType = transitionType or "fade"
  if transitionType ~= "None" then
    time = time or 0.2
    more = more or display.COLOR_WHITE
  else
    transitionType = nil
  end
  local scene = CCScene:create()
  self:addTo(scene, self.m_ViewZOrder, self.m_ViewTag)
  display.replaceScene(scene, transitionType, time, more)
  if device.platform == "android" then
    local layer = display.newLayer()
    layer:addKeypadEventListener(function(event)
      if event == "back" and g_DeviceKeyMgr then
        g_DeviceKeyMgr:dispatchAndroidKey()
      end
    end)
    scene:addChild(layer)
    layer:setKeypadEnabled(true)
  end
  return scene
end
function CcsUIView:OnMessage(msgSID, ...)
  print("CcsUIView:OnMessage msgSID, ... = ", msgSID, ...)
end
function CcsUIView:onEnterTransitionFinish()
  if self.m_IsTouchEnable == false and self.m_UIGroup then
    self.m_UIGroup:setTouchEnabled(false)
  end
end
function CcsUIView:Clear()
  printLog("WARNING", "类:%s 没有处理Clear函数", self.__cname)
end
function CcsUIView:onCleanup()
  self.m_UIGroup = nil
  self:RemoveAllMessageListener()
  self:HideWaitingView()
  self:HideFullView()
  print("__cname = ", self.__cname)
  self:Clear()
end
