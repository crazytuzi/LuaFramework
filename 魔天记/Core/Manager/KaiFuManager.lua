KaiFuManager = { };


KaiFuManager.kaifudate = 10000;

KaiFuManager.MESSAGE_KAIFUMANAGER_DATE_CHANGE = "MESSAGE_KAIFUMANAGER_DATE_CHANGE";

function KaiFuManager.SetKaiFunData(t)
    if (t) then
        KaiFuManager.kaifudate = t;      
        MessageManager.Dispatch(KaiFuManager, KaiFuManager.MESSAGE_KAIFUMANAGER_DATE_CHANGE);
        --MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
    end
end


-- 开放已经多少天
function KaiFuManager.GetKaiFuHasDate()
    return KaiFuManager.kaifudate;
end

-- 开服时间点
function KaiFuManager.GetKaiFuHasTime(add_day)

    local currTime = GetOffsetTime();

    if KaiFuManager.kaifudate ~= 10000 then
        currTime = currTime - Date.Day * KaiFuManager.kaifudate;
    end

    if add_day ~= nil then
        currTime = currTime + Date.Day * add_day;
    end

    local newTime = os.date("*t", currTime)

    return newTime;

end

-- delayed_day 延时多少天
function KaiFuManager.KaiFuIsOver(delayed_day)
  
   local listData = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SERVICE_LEVELING);
    local day = listData[1].days;

    local newTime = KaiFuManager.GetKaiFuHasTime(day+delayed_day);
    newTime.hour = 23;
    newTime.min = 59;
    newTime.sec = 59;
   --[[
   {year = 1998, month = 9, day = 16, yday = 259, wday = 4,hour = 23, min = 48, sec = 10, isdst = false}

   ]]
   local t = os.time( { year = tonumber(newTime.year), 
                        month = tonumber(newTime.month), 
                        day = tonumber(newTime.day), 
                        hour = tonumber(newTime.hour), 
                        min = tonumber(newTime.min),
                         sec = tonumber(newTime.sec) });

     local currTime = os.time();

     if currTime > t then
       return true;
     end

  return false;
end