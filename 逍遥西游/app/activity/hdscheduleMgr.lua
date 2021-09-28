local hdschedule = class("hdscheduleMgr")
function hdschedule:ctor()
  self.m_Schedule = {}
end
function hdschedule:setSchedule(data)
  if data ~= nil then
    self.m_Schedule = data
    SendMessage(MsgID_Activity_ScheduleData, data)
  end
end
function hdschedule:getSchedule()
  return self.m_Schedule
end
return hdschedule
