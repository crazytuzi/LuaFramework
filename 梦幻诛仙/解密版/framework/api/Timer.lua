local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
PRINT_DEPRECATED("module api.Timer is deprecated, please use cc.utils.Timer")
local Timer = {}
function Timer.new()
  local timer = {}
  require(cc.PACKAGE_NAME .. ".api.EventProtocol").extend(timer)
  local handle
  local countdowns = {}
  local timecount = 0
  local function onTimer(dt)
    timecount = timecount + dt
    for eventName, cd in pairs(countdowns) do
      cd.countdown = cd.countdown - dt
      cd.nextstep = cd.nextstep - dt
      if cd.countdown <= 0 then
        print(string.format("[finish] %s", eventName))
        timer:dispatchEvent({name = eventName, countdown = 0})
        timer:removeCountdown(eventName)
      elseif cd.nextstep <= 0 then
        print(string.format("[step] %s", eventName))
        cd.nextstep = cd.nextstep + cd.interval
        timer:dispatchEvent({
          name = eventName,
          countdown = cd.countdown
        })
      end
    end
  end
  function timer:addCountdown(eventName, countdown, interval)
    eventName = tostring(eventName)
    assert(not countdowns[eventName], "eventName '" .. eventName .. "' exists")
    assert(type(countdown) == "number" and countdown >= 30, "invalid countdown")
    if type(interval) ~= "number" then
      interval = 30
    else
      interval = math.floor(interval)
      if interval < 2 then
        interval = 2
      elseif interval > 120 then
        interval = 120
      end
    end
    countdowns[eventName] = {
      countdown = countdown,
      interval = interval,
      nextstep = interval
    }
  end
  function timer:removeCountdown(eventName)
    eventName = tostring(eventName)
    countdowns[eventName] = nil
    self:removeAllEventListenersForEvent(eventName)
  end
  function timer:start()
    if not handle then
      handle = scheduler.scheduleGlobal(onTimer, 1, false)
    end
  end
  function timer:stop()
    if handle then
      scheduler.unscheduleGlobal(handle)
      handle = nil
    end
  end
  return timer
end
return Timer
