CHDScheduleItem = class("CHDScheduleItem", CcsSubView)
function CHDScheduleItem:ctor(info, wday, dlgObj)
  CHDScheduleItem.super.ctor(self, "views/scheduleitem.json")
  self.m_DlgObj = dlgObj
  local timeStr, data = unpack(info, 1, 2)
  self:getNode("time"):setText(timeStr)
  self.m_Width = 82
  self.m_HdIdList = {}
  self.m_BgHighLight = {}
  for index, k in pairs({
    "Mon",
    "Tues",
    "Wed",
    "Thur",
    "Fri",
    "Sat",
    "Sun"
  }) do
    local hdId = data[k]
    local txt = data_getHuodongOpenTypeScheduleName(hdId)
    local daystr = self:getNode(string.format("day%d", index))
    daystr:setText(txt)
    if string.len(txt) > 0 then
      self.m_HdIdList[index] = hdId
    end
    local bg = display.newSprite("views/hdschedule/hds_other.png")
    bg:setAnchorPoint(ccp(0, 0))
    bg:setPosition(ccp(index * self.m_Width, 0))
    self:addNode(bg, 0)
    bg:setVisible(false)
    bg._show = false
    local bgHighLight = display.newSprite("views/hdschedule/hds_today.png")
    bgHighLight:setAnchorPoint(ccp(0, 0))
    bgHighLight:setPosition(ccp(index * self.m_Width, 0))
    self:addNode(bgHighLight, 1)
    bgHighLight:setVisible(false)
    bgHighLight._show = false
    self.m_BgHighLight[index] = bgHighLight
    if wday == index then
      daystr:setColor(ccc3(224, 84, 45))
      bgHighLight:setVisible(true)
      bgHighLight._show = true
    else
      daystr:setColor(ccc3(96, 62, 2))
      bg:setVisible(true)
      bg._show = true
    end
  end
  local timebg = display.newSprite("views/hdschedule/hds_time.png")
  timebg:setAnchorPoint(ccp(0, 0))
  timebg:setPosition(ccp(0, 0))
  self:addNode(timebg, 1)
  self.m_UINode:setTouchEnabled(true)
  self.m_UINode:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      local touchPos = touchObj:getTouchStartPos()
      local p = self.m_UINode:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
      local day = math.floor(p.x / self.m_Width)
      local pos = self.m_UINode:convertToWorldSpace(ccp(0, 0))
      local size = self:getContentSize()
      if day >= 1 and day <= 7 then
        self:ClickDay(day, ccp(pos.x + day * self.m_Width, pos.y), CCSize(self.m_Width, size.height))
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      if self.m_DlgObj then
        self.m_DlgObj:AutoClearHuoDongDetail()
      end
      if self.m_TouchBg then
        self.m_TouchBg:setVisible(self.m_TouchBg._show)
        self.m_TouchBg = nil
      end
    end
  end)
end
function CHDScheduleItem:ClickDay(day, pos, size)
  if self.m_DlgObj then
    local hdId = self.m_HdIdList[day]
    if hdId ~= nil then
      self.m_DlgObj:ClickHuoDong(hdId, pos, size)
    end
  end
  self.m_TouchBg = self.m_BgHighLight[day]
  if self.m_TouchBg then
    self.m_TouchBg:setVisible(true)
  end
end
function CHDScheduleItem:Clear()
  self.m_DlgObj = nil
  self.m_TouchBg = nil
end
