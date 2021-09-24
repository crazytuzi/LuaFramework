--退出游戏
function F_exitGame()
    if G_isIOS() == true then
        --制造错误让程序闪退
        local ccsp = CCSprite:create()
        sceneGame:addChild(ccsp)
        ccsp:release()
        ccsp:release()
    else
        deviceHelper:exitGameForAndroid()
    end
    do return end
end

--判断是否停留在游戏主基地（有些面板需要只在游戏主基地弹出）
function F_stayMainUI()
    if(newGuidMgr and newGuidMgr.isGuiding == true) or (otherGuideMgr and otherGuideMgr.isGuiding == true) or (buildingGuildMgr and buildingGuildMgr.isGuildSmallOpen == true)then
        return false
    end
    if mainUI:isVisible() == false then
        return false
    end
    if sceneController.curIndex == 0 and base.allShowedCommonDialog == 0 and SizeOfTable(G_SmallDialogDialogTb) == 0 then
        return true
    end
    return false
end

--获取月份的天数
function F_getMonthDays(year, month)
    local m = {[1] = 31, [3] = 31, [5] = 31, [7] = 31, [8] = 31, [10] = 31, [12] = 31}
    if m[month] then
        return m[month]
    elseif month == 2 then
        if (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0 then
            return 29
        else
            return 28
        end
    else
        return 30
    end
end

--获取指定时间为星期几
--return 1-6为周一到周六，0为周日
function F_getWeekDay(time)
    local dt = os.date("*t", time)
    local f_year, f_month, f_day = 2019, 12, 1 --2019-12-01这天为周日
    --获取当年已经过去的天数
    local passDays = 0 --不包含2019-12-01这一天
    if dt.year == f_year and dt.month == f_month then
        passDays = dt.day - f_day
    else
        passDays = 30
    end
    if dt.year - f_year > 1 then
        for y = f_year + 1, dt.year - 1 do
            if (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0 then
                passDays = passDays + 366
            else
                passDays = passDays + 365
            end
        end
    end
    if dt.year > f_year then
        for m = 1, dt.month do
            if m ~= dt.month then
                passDays = passDays + F_getMonthDays(dt.year, m)
            end
        end
        passDays = passDays + dt.day
    end
    return passDays % 7
end

function table.length(array)
    local len = 0
    if type(array) == 'table' then
        for _ in pairs(array) do
            len = len + 1
        end
    end
    
    return len
end

function table.keys(self)
    local keys = {}
    for k, _ in pairs(self) do
        table.insert(keys, k)
    end
    return keys
end

function table.values(self)
    local values = {}
    for _, v in pairs(self) do
        table.insert(values, v)
    end
    return values
end
