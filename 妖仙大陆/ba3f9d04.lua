

local _M = {}
_M.__index = _M

local AllSign = nil
local luxurymsg = nil

function _M.GetAttendanceInfoRequest(cb)
  Pomelo.AttendanceHandler.getAttendanceInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      AllSign = msg.s2c_attendance
      luxurymsg = msg.s2c_luxury
      cb()
    end
  end)
end

function _M.GetDailyRewardRequest(cb)
  Pomelo.AttendanceHandler.getDailyRewardRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllSign = msg.s2c_attendance
      cb()
    end
  end)
end

function _M.GetCumulativeRewardRequest(id,cb) 
  Pomelo.AttendanceHandler.getCumulativeRewardRequest(id,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllSign = msg.s2c_attendance
      cb()
    end
  end)
end

function _M.GetLuxuryRewardRequest(cb)
  Pomelo.AttendanceHandler.getLuxuryRewardRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      luxurymsg = msg.s2c_luxury
      cb()
    end
  end)
end

function _M.GetLeftVipRewardRequest(id,cb)
  Pomelo.AttendanceHandler.getLeftVipRewardRequest(id,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllSign = msg.s2c_attendance
      cb()
    end
  end)
end

function _M.GetAllSignMsg()
	return AllSign
end

function _M.Getluxurymsg()
  return luxurymsg
end

function GlobalHooks.DynamicPushs.richSignPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    luxurymsg = msg.s2c_luxury
  end
end

function _M.InitNetWork()
  Pomelo.AttendanceHandler.luxuryRewardPush(GlobalHooks.DynamicPushs.richSignPush)
end

function _M.initial()
  print("Sign initial") 
end

return _M
