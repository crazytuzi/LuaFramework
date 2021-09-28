ccs_scrollview_ex(ListView)
function ListView:addTouchItemListenerListView(listener, eventListener)
  local isTouchItem = false
  self:addEventListenerListView(function(listObj, status)
    if status == LISTVIEW_ONSELECTEDITEM_START then
      isTouchItem = true
    elseif status == LISTVIEW_ONSELECTEDITEM_END and isTouchItem and listener then
      local idx = self:getCurSelectedIndex()
      local item = self:getItem(idx)
      listener(item, idx, self)
    end
    if eventListener then
      local idx = self:getCurSelectedIndex()
      local item = self:getItem(idx)
      eventListener(item, idx, self, status)
    end
  end)
  self:addEventListenerScrollView(function(listObj, status)
    if status == SCROLLVIEW_EVENT_SCROLLING and isTouchItem then
      isTouchItem = false
    end
  end)
end
function ListView:addTouchEventListenerScrollView(listener)
  self:addEventListenerScrollView(listener)
end
function ListView:addLoadMoreListenerScrollView(listener)
  self.__canLoadMore = true
  self:addEventListenerScrollView(function(listObj, status)
    if status == SCROLLVIEW_EVENT_SCROLLING or status == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
      local innerContainer = self:getInnerContainer()
      if innerContainer then
        local _, y = innerContainer:getPosition()
        if y > 0 and self.__canLoadMore ~= false then
          local curTime = cc.net.SocketTCP.getTime()
          if self.__lastLoadMoreTime == nil or curTime - self.__lastLoadMoreTime > 0.2 then
            self.__canLoadMore = false
            self.__lastLoadMoreTime = curTime
            if listener then
              listener()
            end
          end
        end
      end
    end
  end)
end
function ListView:addLoadMoreListenerScrollView_DragDown(listener)
  self.__canLoadMore = true
  self:addEventListenerScrollView(function(listObj, status)
    if status == SCROLLVIEW_EVENT_SCROLLING or status == SCROLLVIEW_EVENT_BOUNCE_TOP then
      local innerContainer = self:getInnerContainer()
      if innerContainer then
        local _, y = innerContainer:getPosition()
        local iSize = self:getInnerContainerSize()
        local bSize = self:getContentSize()
        if y + iSize.height < bSize.height and self.__canLoadMore ~= false then
          local curTime = cc.net.SocketTCP.getTime()
          if self.__lastLoadMoreTime == nil or curTime - self.__lastLoadMoreTime > 0.2 then
            self.__canLoadMore = false
            self.__lastLoadMoreTime = curTime
            if listener then
              listener()
            end
          end
        end
      end
    end
  end)
end
function ListView:addLoadMoreListenerScrollView_DragUpAndDown(uplistener, downlistener)
  self.__canLoadMore = true
  self:addEventListenerScrollView(function(listObj, status)
    if status == SCROLLVIEW_EVENT_SCROLLING or status == SCROLLVIEW_EVENT_BOUNCE_TOP then
      local innerContainer = self:getInnerContainer()
      if innerContainer then
        local _, y = innerContainer:getPosition()
        local iSize = self:getInnerContainerSize()
        local bSize = self:getContentSize()
        if y + iSize.height < bSize.height and self.__canLoadMore ~= false then
          local curTime = cc.net.SocketTCP.getTime()
          if self.__lastLoadMoreTime == nil or curTime - self.__lastLoadMoreTime > 0.2 then
            self.__canLoadMore = false
            self.__lastLoadMoreTime = curTime
            if uplistener then
              uplistener()
            end
            return
          end
        end
      end
    end
    if status == SCROLLVIEW_EVENT_SCROLLING or status == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
      local innerContainer = self:getInnerContainer()
      if innerContainer then
        local _, y = innerContainer:getPosition()
        if y > 0 and self.__canLoadMore ~= false then
          local curTime = cc.net.SocketTCP.getTime()
          if self.__lastLoadMoreTime == nil or curTime - self.__lastLoadMoreTime > 0.2 then
            self.__canLoadMore = false
            self.__lastLoadMoreTime = curTime
            if downlistener then
              downlistener()
            end
          end
        end
      end
    end
  end)
end
function ListView:setCanLoadMore(flag)
  self.__canLoadMore = flag
end
function ListView:getCount()
  return self:getItems():count()
end
function ListView:ListViewScrollToIndex_Vertical(index, scrollTime)
  if index == nil then
    return
  end
  scrollTime = scrollTime or 0.3
  self:refreshView()
  local cnt = self:getCount()
  if cnt == 0 then
    return
  end
  local h = self:getContentSize().height
  local ih = self:getInnerContainerSize().height
  if h < ih then
    local showNum = h / (ih / cnt)
    local percent = (index - 1) / (cnt - showNum) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self:scrollToPercentVertical(percent, scrollTime, false)
  end
end
function ListView:ListViewScrollToIndex_HORIZONTAL(index, scrollTime)
  do return end
  if index == nil then
    return
  end
  scrollTime = scrollTime or 0.3
  self:refreshView()
  local cnt = self:getCount()
  if cnt == 0 then
    return
  end
  local w = self:getContentSize().width
  local iw = self:getInnerContainerSize().width
  if w < iw then
    local x = (1 - (index + 0.5) / cnt) * iw - w / 2
    local percent = (1 - x / (iw - w)) * 100
    percent = math.max(percent, 0)
    percent = math.min(percent, 100)
    self:scrollToPercentHorizontal(percent, scrollTime, false)
  end
end
function ListView:removeItemIns(item)
  return self:removeItem(self:getIndex(item))
end
