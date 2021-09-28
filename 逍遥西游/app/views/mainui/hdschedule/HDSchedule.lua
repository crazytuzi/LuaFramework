CHDSchedule = class("CHDSchedule", CcsSubView)
function CHDSchedule:ctor()
  CHDSchedule.super.ctor(self, "views/schedule.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ScheduleList = self:getNode("list")
  self:InitScheduleData()
end
function CHDSchedule:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_ScheduleData then
    self:InitScheduleData()
  end
end
function CHDSchedule:InitScheduleData()
  self.m_ScheduleList:removeAllItems()
  local data = activity.hdschedule:getSchedule()
  local scheduleData = {}
  for k, v in pairs(data) do
    scheduleData[#scheduleData + 1] = {k, v}
  end
  local GetTimeCompareNumber = function(t)
    local tmp = string.split(t, ":")
    local n = 0
    for _, v in ipairs(tmp) do
      n = n * 100 + tonumber(v)
    end
    return n
  end
  local function _scheduleSortFunc(a, b)
    if a == nil or b == nil then
      return false
    end
    local t1 = GetTimeCompareNumber(a[1])
    local t2 = GetTimeCompareNumber(b[1])
    return t1 < t2
  end
  table.sort(scheduleData, _scheduleSortFunc)
  local dayInfo = os.date("*t")
  local wday = dayInfo.wday
  wday = wday - 1
  if wday <= 0 then
    wday = 7
  end
  for _, info in pairs(scheduleData) do
    local item = CHDScheduleItem.new(info, wday, self)
    self.m_ScheduleList:pushBackCustomItem(item.m_UINode)
  end
  for index = 1, 7 do
    if index == wday then
      self:getNode(string.format("title_%d", index)):setColor(ccc3(255, 245, 121))
    else
      self:getNode(string.format("title_%d", index)):setColor(ccc3(67, 240, 156))
    end
  end
end
function CHDSchedule:setVisible(v)
  self.m_UINode:setVisible(v)
  if not v then
    self:ClearHuoDongDetail()
  end
end
function CHDSchedule:ClickHuoDong(hdId, pos, size)
  self:ClearHuoDongDetail()
  self.m_ScheduleDetail = CHDScheduleDetail.new(hdId, pos, size, self)
end
function CHDSchedule:ClearHuoDongDetail(hdId, pos, size)
  if self.m_ScheduleDetail ~= nil then
    self.m_ScheduleDetail:removeFromParent()
    self.m_ScheduleDetail = nil
  end
end
function CHDSchedule:AutoClearHuoDongDetail()
  if self.m_ScheduleDetail then
    self.m_ScheduleDetail:AutoClear()
  end
end
function CHDSchedule:OnBtn_Close(btnObj, touchType)
  if g_HuodongView then
    g_HuodongView:CloseSelf()
  end
end
function CHDSchedule:Clear()
  self:ClearHuoDongDetail()
end
