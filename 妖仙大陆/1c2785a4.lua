



local _M = {}
_M.__index = _M

function _M.Sync()
  XmdsNetManage.Instance.ServerTimeSync:Sync()
end


function _M.GetCountDown(time_stamp)
  local last = time_stamp - _M.GetServerUnixTime() 
  last = last
  local rtn = ""
  local day = 24 * 60 * 60
  if last >= day then
    rtn = rtn .. tostring(math.floor(last / day)).."天"
    last = last % day
  end
  local hour = 60 * 60
  if last >= hour then
    rtn = rtn .. tostring(math.floor(last / hour)).."小时"
    last = last % hour
  end
  local min = 60
  if last >= min then
    rtn = rtn .. tostring(math.floor(last / min)).."分"
  end
  return rtn
end

function _M.GetCDStr(cd)
  local last = cd
  local rtn = ""
  local day = 24 * 60 * 60
  if last >= day then
    rtn = rtn .. tostring(math.floor(last / day)).."天"
    last = last % day
  end
  local hour = 60 * 60
  if last >= hour then
    rtn = rtn .. tostring(math.floor(last / hour)).."小时"
    last = last % hour
  end
  local min = 60
  if last >= min then
    rtn = rtn .. tostring(math.floor(last / min)).."分"
  end
  return rtn
end

function _M.GetTimeStr(cd)
  local last = math.floor(cd)
  local h = math.floor(last/3600)
  local m = math.floor(last/60)-h*60
  local s = last-m*60-3600*h
  local rtn = ""
  if h == 0 then
      h = ""
  elseif h < 10 then
      h = "0"..h..":"
  else
      h = h..":"
  end
  if m == 0 then
      m = "00"..":"
  elseif m < 10 then
      m = "0"..m..":"
  else
      m = m..":"
  end
  if s == 0 then
      s = "00"
  elseif s < 10 then
      s = "0"..s
  end
  rtn = h..m..s
  return rtn
end


function _M.GetCDTimeDesc(cd)
  local last = math.floor(cd)
  local h = math.floor(last/3600)
  local m = math.floor(last/60)-h*60
  local s = last-m*60-3600*h
  local rtn = ""
  if h == 0 then
      h = "0小时"
  elseif h < 10 then
      h = "0"..h.."小时"
  else
      h = h.."小时"
  end
  if m == 0 then
      m = "00".."分钟"
  elseif m < 10 then
      m = "0"..m.."分钟"
  else
      m = m.."分钟"
  end
  if s == 0 then
      s = "00秒"
  elseif s < 10 then
      s = "0"..s.."秒"
  else
      s = s.."秒"
  end
  rtn = h..m..s
  return rtn
end


function _M.FormatCD(cd, format)
  local date = {
      year = 1971, month = 0, day = 0, hour = 0, min = 0, sec = 0, isdst = false,
  }
  return os.date(format or "%M:%S", os.time(date) + cd)
end

function _M.GetCDStrCut(cd)
  local day = 24 * 60 * 60
  if cd >= day then
    return tostring(math.floor(cd / day)).."天"
  end
  local hour = 60 * 60
  if cd >= hour then
    return tostring(math.floor(cd / hour)).."小时"
  end
  local min = 60
  if cd >= min then
    return tostring(math.floor(cd / min)).."分"
  end
  if cd < 0 then cd = 0 end
  return tostring(math.floor(cd)) .. "秒"
end


function _M.GetCDStrCut2(cd)
  if cd < 0 then cd = 0 end

  local count = 0
  local str = ""
  local day = 24 * 60 * 60
  if cd >= day then
    count = count + 1
    str = tostring(math.floor(cd / day)).."天"
    cd = cd % day
  end
  local hour = 60 * 60
  if count == 1 or (count < 2 and cd >= hour) then
    count = count + 1
    str = str .. tostring(math.floor(cd / hour)).."小时"
    cd = cd % hour
  end
  local min = 60
  if count == 1 or (count < 2 and cd >= min) then
    count = count + 1
    str = str .. tostring(math.floor(cd / min)).."分"
    cd = cd % min
  end
  if count < 2 then
    str = str .. tostring(math.floor(cd)).."秒"
  end
  return str
end

function _M.GetCountDownCut(time_stamp)
  local cd = time_stamp - _M.GetServerUnixTime() 
  return _M.GetCDStrCut(cd)
end



function _M.GetServerUnixTime()
   return XmdsNetManage.Instance.ServerTimeSync:GetServerUnixTime() / 1000
end


function _M.GetCDTime(time_stamp)
  local time = math.floor(time_stamp - _M.GetServerUnixTime())
  if time < 0 then
    time = 0
  end
  return time
end


function _M.ConvertTimpstamp(sec, min, hour, day, month, year)
  
  local curDate = GameUtil.NormalizeTimpstamp(_M.GetServerUnixTime())
  local curyear = year == nil and curDate.Year or year
  local curmonth = month == nil and curDate.Month or month
  local curday = day == nil and curDate.Day or day
  local curhour = hour == nil and curDate.Hour or hour
  local curmin = min == nil and curDate.Minute or min
  local cursec = sec == nil and curDate.Second or sec
  curDate = System.DateTime.New(curyear, curmonth, curday, curhour, curmin, cursec)
  return curDate
end

function _M.GetTimeStamp(dateTime)
  
  local timestamp = math.floor((dateTime.UtcNow - System.DateTime.New(1970, 1, 1)).TotalSeconds)
  return timestamp
end

return _M
