local Lplus = require("Lplus")
local AbsoluteTimer = Lplus.Class(ModuleBase, "AbsoluteTimer")
local def = AbsoluteTimer.define
local instance
def.field("table").listeners = nil
def.field("number").zoneSeconds = 0
def.field("number").timerId = 1
local get_timezone_offset = function()
  local ts = os.time()
  local basets = os.time({
    year = 2016,
    month = 11,
    day = 1,
    hour = 11,
    isdst = false
  })
  ts = math.max(ts, basets)
  local utcdate = os.date("!*t", ts)
  local localdate = os.date("*t", ts)
  return os.difftime(os.time(localdate), os.time(utcdate))
end
def.static().Init = function()
  if instance == nil then
    instance = AbsoluteTimer()
    instance.zoneSeconds = -get_timezone_offset()
    instance.listeners = {}
    _G.AbsoluteTimer = instance
    GameUtil.AddGlobalTimer(1, false, AbsoluteTimer.Update)
  end
end
def.static("number", "number", "function", "table", "number", "=>", "number").AddListener = function(tick, loops, func, context, delay)
  if func == nil then
    return -1
  end
  instance.timerId = instance.timerId + 1
  local id = instance.timerId
  local listener = {f = func}
  instance.listeners[id] = listener
  local timeStamp = GameUtil.GetTickCount()
  listener.tick = tick
  listener.timeStamp = timeStamp
  listener.loops = loops
  listener.context = context
  listener.delay = delay
  listener.occurTime = delay + tick
  return id
end
def.static("number", "number", "number", "number", "number", "number", "number", "function", "table", "=>", "number").AddServerTimeEvent = function(year, month, day, hour, min, loop_cycle, loop_times, func, context)
  if loop_cycle <= 0 then
    error("Invalid param: loop_cycle")
    return -1
  end
  local server_time = AbsoluteTimer.GetServerTimeByDate(year, month, day, hour, min, 0)
  if server_time <= 0 then
    return
  end
  local diff = server_time - _G.GetServerTime()
  if diff < 0 then
    warn("Event start time is out of date")
    return -1
  end
  local tick = loop_cycle
  if tick <= 0 then
    tick = diff
  end
  return AbsoluteTimer.AddListener(tick, loop_times, func, context, diff - tick)
end
def.static("number", "number", "number", "number", "number", "number", "=>", "number").GetServerTimeByDate = function(year, month, day, hour, min, sec)
  local cur_zone_time = os.time({
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = min,
    sec = sec,
    isdst = false
  })
  if cur_zone_time == nil then
    error("Invalid date")
    return -1
  end
  local server_time = cur_zone_time - instance.zoneSeconds - _G.GetServerZoneOffset()
  return server_time
end
def.static("number").RemoveListener = function(key)
  instance.listeners[key] = nil
end
def.static("number", "=>", "table").GetServerTimeTable = function(serverTime)
  if serverTime <= 0 then
    serverTime = _G.GetServerTime()
  end
  local localtime = serverTime + instance.zoneSeconds + _G.GetServerZoneOffset()
  local t = os.date("*t", localtime)
  if t.isdst then
    if 0 < t.hour then
      t.hour = t.hour - 1
    else
      t = os.date("*t", localtime - 3600)
      if not t.isdst then
        t.hour = t.hour + 1
      end
    end
  end
  return t
end
def.static("string", "number", "=>", "string").GetFormatedServerDate = function(formatStr, serverTime)
  if serverTime <= 0 then
    serverTime = _G.GetServerTime()
  end
  local localtime = serverTime + instance.zoneSeconds + _G.GetServerZoneOffset()
  local t = os.date("*t", localtime)
  if t.isdst then
    localtime = localtime - 3600
  end
  return os.date(formatStr, localtime)
end
def.static().Update = function()
  local curTime = GameUtil.GetTickCount()
  for k, v in pairs(instance.listeners) do
    if (curTime - v.timeStamp) / 1000 >= v.occurTime then
      _G.SafeCall(v.f, v.context)
      if v.loops > 0 then
        v.loops = v.loops - 1
      elseif v.loops == 0 then
        instance.listeners[k] = nil
      end
      v.occurTime = v.occurTime + v.tick
    end
  end
end
return AbsoluteTimer.Commit()
