function ccs_scrollview_ex(classObj)
  function classObj:setNodeEventEnabled(enabled, listener)
    local handle
    if enabled then
      listener = listener or function(event)
        local name = event.name
        if name == "enter" then
          self:onEnterEvent()
        elseif name == "exit" then
          self:onExitEvent()
        elseif name == "enterTransitionFinish" then
          self:onEnterTransitionFinishEvent()
        elseif name == "exitTransitionStart" then
          self:onExitTransitionStartEvent()
        elseif name == "cleanup" then
          self:ClearCCSEx()
          self:onCleanup()
        end
      end
      handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
    else
      self:removeNodeEventListener(handle)
    end
    return self
  end
  function classObj:ClearCCSEx()
    self.__eventListenerScrollView__ = {}
  end
  if classObj.__addEventListenerScrollView__ == nil then
    classObj.__addEventListenerScrollView__ = classObj.addEventListenerScrollView
  end
  function classObj:addEventListenerScrollView(listener)
    if self.__eventListenerScrollView__ == nil then
      self.__eventListenerScrollView__ = {}
      self:setNodeEventEnabled(true)
      classObj.__addEventListenerScrollView__(self, function(listObj, status)
        for i, v in ipairs(self.__eventListenerScrollView__) do
          v(listObj, status)
        end
      end)
    end
    self.__eventListenerScrollView__[#self.__eventListenerScrollView__ + 1] = listener
  end
  function classObj:sizeChangedForShowMoreTips()
    local innerSize = self:getInnerContainerSize()
    local tSize = self:getSize()
    local allChilds = self:getChildren()
    local h = 0
    for i = 0, allChilds:count() - 1 do
      local obj = tolua.cast(allChilds:objectAtIndex(i), "Widget")
      if obj then
        local s = obj:getSize()
        h = h + s.height
      end
    end
    if h > tSize.height then
      self.__needShowMoreTips__ = true
    else
      self.__needShowMoreTips__ = false
    end
    if self.__needShowMoreTips__ == true then
      if self.__moreTips == nil then
        self.__moreTips = display.newSprite("views/rolelist/pic_downarrow01.png")
        local mx, my = self:getPosition()
        self:getParent():addNode(self.__moreTips, getMaxZ(self:getParent()))
        local s = self.__moreTips:getContentSize()
        self.__moreTips:setPosition(ccp(mx + tSize.width / 2, my))
        self:addEventListenerScrollView(function(selfObj, status)
          if self.__needShowMoreTips__ == true then
            if status == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM or status == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
              self:showMoreTips_setTipsShow_(false)
            else
              self:showMoreTips_setTipsShow_(true)
            end
          end
        end)
      end
      local innerContainer = self:getInnerContainer()
      local x, y = innerContainer:getPosition()
      if y <= 0 then
        self:showMoreTips_setTipsShow_(true)
      end
    else
      self:showMoreTips_setTipsShow_(false)
    end
  end
  function classObj:sizeChangedForShowMoreTips_Horizontal()
    local innerSize = self:getInnerContainerSize()
    local tSize = self:getSize()
    local allChilds = self:getChildren()
    local w = 0
    for i = 0, allChilds:count() - 1 do
      local obj = tolua.cast(allChilds:objectAtIndex(i), "Widget")
      if obj then
        local s = obj:getSize()
        w = w + s.width
      end
    end
    if w > tSize.width then
      self.__needShowMoreTips__ = true
    else
      self.__needShowMoreTips__ = false
    end
    if self.__needShowMoreTips__ == true then
      if self.__moreTips == nil then
        self.__moreTips = display.newSprite("views/rolelist/pic_downarrow01.png")
        self.__moreTips:setRotation(270)
        local mx, my = self:getPosition()
        self:getParent():addNode(self.__moreTips, getMaxZ(self:getParent()))
        local s = self.__moreTips:getContentSize()
        self.__moreTips:setPosition(ccp(mx + tSize.width, my + tSize.height / 2))
        self:addEventListenerScrollView(function(selfObj, status)
          if self.__needShowMoreTips__ == true then
            if status == SCROLLVIEW_EVENT_SCROLL_TO_RIGHT or status == SCROLLVIEW_EVENT_BOUNCE_RIGHT then
              self:showMoreTips_setTipsShow_(false)
            else
              self:showMoreTips_setTipsShow_(true)
            end
          end
        end)
      end
      local innerContainer = self:getInnerContainer()
      local x, y = innerContainer:getPosition()
      if x + w > tSize.width then
        self:showMoreTips_setTipsShow_(true)
      else
        self:showMoreTips_setTipsShow_(false)
      end
    else
      self:showMoreTips_setTipsShow_(false)
    end
  end
  function classObj:showMoreTips_setTipsShow_(isShow)
    if self.__moreTips then
      self.__moreTips:setVisible(isShow)
    end
  end
end
ccs_scrollview_ex(ScrollView)
