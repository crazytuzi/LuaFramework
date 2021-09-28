local LocalNotificationMgr = class("LocalNotificationMgr")
function LocalNotificationMgr:ctor()
end
function LocalNotificationMgr:getTimeWithDelayTime(delayTime)
  return os.time() + delayTime
end
function LocalNotificationMgr:getTimeWithHourMinSec(hour, min, sec, canTomorrow)
  hour = hour or 0
  min = min or 0
  sec = sec or 0
  local curTime = os.time()
  local curYear = checkint(os.date("%Y", curTime))
  local curMon = checkint(os.date("%m", curTime))
  local curDay = checkint(os.date("%d", curTime))
  local timeParam = {
    year = curYear,
    month = curMon,
    day = curDay,
    hour = hour,
    min = min,
    sec = sec
  }
  local todayTime = os.time(timeParam)
  if curTime <= todayTime then
    return todayTime
  elseif canTomorrow == false then
    return nil
  else
    return todayTime + 86400
  end
end
function LocalNotificationMgr:test()
  print("\n\n\n当前时间:", os.time())
  print("1--->:", self:getTimeWithHourMinSec(15, 0, 0, true))
  print("1--->:", self:getTimeWithHourMinSec(19, 0, 0, true))
  print("2--->:", self:getTimeWithHourMinSec(10, 0, 0, false))
  print("2--->:", self:getTimeWithHourMinSec(10, 0, 59, true))
end
g_LocalNotifiMgr = LocalNotificationMgr.new()
