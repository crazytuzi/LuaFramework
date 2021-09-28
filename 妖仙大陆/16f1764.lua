local _M = {}
_M.__index = _M

_M.TodayWeekIndex = 1

function _M.DailyActivityRequest(cb)
  Pomelo.DailyActivityHandler.dailyActivityRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.GetDegreeRewardRequest(c2s_id,cb)
  Pomelo.DailyActivityHandler.getDegreeRewardRequest(c2s_id,function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function GlobalHooks.DynamicPushs.dailyActivityPush(ex, json)
    if ex == nil then
        local param = json:ToData()
        if param then
          if param.s2c_dailyLs and #param.s2c_dailyLs > 0 then
            
            if param.s2c_dailyLs[1].id == 5 then
              EventManager.Fire("Event.Activity.dailyActivityPush", {})
            end
          end
        end
    end
end

function _M.InitNetWork()
    Pomelo.GameSocket.updateActivityPush(GlobalHooks.DynamicPushs.dailyActivityPush)
end
return _M
