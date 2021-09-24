_TimeCronVars = {
        startTime = 0,
        interval = 0,
        offsetTime = 0,
}

-- 启动时间,计划启动时间与启动时间的间隔,用户手动快进偏移时间
function setTimeCronVars(startTime,interval,offsetTime)
    _TimeCronVars.startTime = startTime
    _TimeCronVars.interval = interval
    _TimeCronVars.offsetTime = offsetTime
    writeLog({"——setTimeCronVars",startTime,interval,offsetTime},"gamecrond")
end

local osTime = os.time
function os.time()
        return _TimeCronVars.startTime + _TimeCronVars.interval + _TimeCronVars.offsetTime + (osTime() - _TimeCronVars.startTime )
end
