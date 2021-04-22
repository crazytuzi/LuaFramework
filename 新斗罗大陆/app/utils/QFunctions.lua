
require "lfs"
local socket = require "socket"
local http = require 'socket.http'
local utf8 = import("...lib.utf8")
local quickSort = import("...lib.quick_sort")
local emoji = import(".QEmoji")

local _assert = assert

QVERY_SMALL_NUMBER = 1e-6
function assert(cond, eval)
    if not cond then
        if type(eval) == "function" then
            return _assert(cond, eval())
        else
            return _assert(cond, eval)
        end
    else
        return cond, eval
    end
end

-- function print(fmt, ...)
--     -- print(string.format(tostring(fmt), ...))
-- end

-- find the item with maximium value in specified field
function table.max(list, field)
    local max = 0
    local r = nil
    for i, item in pairs(list) do
        if item[field] > max then
            r = item
            max = item[field]
        end
    end

    return r
end

-- find the item with maximium value in specified field
function table.max_fun(list, fun)
    local max = 0
    local r = nil
    for i, item in pairs(list) do
        if fun(item) > max then
            r = item
            max = fun(item)
        end
    end

    return r
end

-- find is value in specified field
function table.find(list, value)
    if list ~= nil and value ~= nil then
        for _, item in pairs(list) do
            if item == value then
                return true
            end
        end
    end
    return false
end

--通过index查找item值
function table.itemOfIndex(t, index)
    local i = 1
    for k, v in pairs(t) do
        if i == index then
            return v
        end
        i = i + 1
    end
    return nil
end

--[[--

合并表格中的值，此处当作数组处理

~~~ lua

local dest = {1,2}
local src  = {3,4}
table.mergeForArray(dest, src)
-- dest = {1,2,3,4}

~~~

@param table dest 目标表格
@param table src 来源表格

]]
function table.mergeForArray(dest, src, filter_func, get_func)
    if not filter_func then
        local dest_len = #dest
        local src_len = #src
        if not get_func then
            for i = 1, src_len do
                dest[dest_len + i] = src[i]
            end
        else
            for i = 1, src_len do
                dest[dest_len + i] = get_func(src[i])
            end
        end
    else
        local dest_len = #dest
        local src_len = #src
        local v = nil
        if not get_func then
            for i = 1, src_len do
                v = src[i]
                if filter_func(v) then
                    dest_len = dest_len + 1
                    dest[dest_len] = v
                end
            end
        else
            for i = 1, src_len do
                v = src[i]
                if filter_func(v) then
                    dest_len = dest_len + 1
                    dest[dest_len] = get_func(v)
                end
            end
        end
    end
end

--table转字符串
function table.join(t,sep)
    local str = ""
    local index = 0
    for k, v in pairs(t) do
        if type(v) == "number" or type(v) == "string" then
            if index > 0 then
                str = str..sep
            end
            str = str..v
            index = index + 1
        end
    end
    return str
end

--将table转换为sep1连接key和value，sep2连接数组格式的string
function table.formatString(t, sep1, sep2)
    local value = nil
    for k, v in pairs(t) do
      if value == nil then
        value = k..sep1..v 
      else
        value = value..sep2..k..sep1..v
      end
    end
    return value
end

function table.toJsonString(t)
    return json.encode(t)
    -- local tableLog = ""
    -- tableLog = tableLog .. "{" 
    -- for k, v in pairs(t) do
    --     if type(v) == "table" then
    --         if type(k) == "string" then k = "\"" .. k .. "\"" end
    --         tableLog = tableLog .. tostring(k) .. ":"
    --         tableLog = tableLog .. table.tostring(v) .. ","
    --     else
    --         if type(k) == "string" then k = "\"" .. k .. "\"" end
    --         if type(v) == "string" then v = "\"" .. v .. "\"" end
    --         v = string.gsub(tostring(v), "\n", "\\\\n")
    --         tableLog = tableLog ..tostring(k).. ":" .. tostring(v) .. ","
    --     end
    -- end
    -- tableLog = tableLog .. "}"
    
    -- return tableLog
end

-- Deprecated - Please use json.encode/decode ! -----------------------------------------------------------------------
--将table从内存转换成string型lua代码，用于序列化
-- str = table.tostring(t1)
-- local f = loadstring("return " .. str)
-- t2 = f()
-- assert(t1 == t2)
function table.tostring(t)
    local tableLog = ""
    tableLog = tableLog .. "{" 
    for k, v in pairs(t) do
        if type(v) == "table" then
            if type(k) == "string" then k = "\"" .. k .. "\"" end
            tableLog = tableLog .. "[" .. tostring(k) .. "]="
            tableLog = tableLog .. table.tostring(v) .. ","
        else
            if type(k) == "string" then k = "\"" .. k .. "\"" end
            if type(v) == "string" then v = "\"" .. v .. "\"" end
            v = string.gsub(tostring(v), "\n", "\\\\n")
            tableLog = tableLog .. "[" ..tostring(k) .. "]=" .. tostring(v) .. ","
        end
    end
    tableLog = tableLog .. "}"
    
    return tableLog
end

function table.extend( old, new ,isRecursive)
    -- body
    if type(old) ~= "table" or type(new) ~= "table" then
        return 
    end
    for k, v in pairs(new) do
        if isRecursive and type(v) == "table" and type(old[k]) == "table" then
            table.extend( old[k], v )
        else
            old[k] = v
        end
    end
    return old
end

--[[--

将map table转为array table，舍弃key值

~~~ lua
local dest = {["2"] = 2, ["x"] = "x", ["table"] = {1, 2}}

return {2, "x", {1, 2}}
~~~

@param table dest 目标表格

]]
function table.mapToArray(dest)
    if dest == nil then return {} end

    local arrayTable = {}
    for _, value in pairs(dest) do
        if type(value) == "table" then
            arrayTable[#arrayTable+1] = table.mapToArray(value)
        else
            arrayTable[#arrayTable+1] = value
        end
    end

    return arrayTable
end

function printError( ... )
    print(string.format(...))
end

--打印table
function print_lua_table (lua_table, indent)
    indent = indent or 0
    local formatting
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print(formatting)
            print_lua_table(v, indent + 1)
            print(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting..szValue..",")
        end
    end
end

local _pesudo_id = 0
-- temporary uuid solution for demo
function uuid()
    _pesudo_id = _pesudo_id + 1
    return _pesudo_id
end

-- 获取当前的uuid
function get_pseudo_id()
    return _pesudo_id
end

-- os.time返回只能精确到秒，不符合要求，os.clock返回CPU消耗的时间，不符合要求。
function q.time()
    return socket.gettime() -- 以秒为单位，精确到毫秒
end

-- 未通信时记录本地time，通信时小于500ms误差的以服务器时间为准
function q.serverTime()
    if remote == nil or remote.serverTime == nil or remote.serverResTime == nil then
        return q.time()
    end
    local time = QUtility:getTime()
    -- printInfo("QUtility:getTime() " .. time)
    return remote.serverTime + time - remote.serverResTime
end

--转化时区后的os.date
function q.date(format, time)
    if time == nil then
        time = os.time()
    end
    time = time + UTC * HOUR
    if format ~= nil then
        if string.sub(format,1,1) ~= "!" then
            format = "!"..format
        end
    else
        format = "!%c"
    end
    return os.date(format, time)
end

--转化时区的time 取代os.time()
local _UTC_TIME
function q.OSTime(date)
    if _UTC_TIME == nil then
        local time = os.time()
        local date1 = os.date("*t", time)
        local date2 = os.date("!*t", time)
        _UTC_TIME = os.time(date2) - os.time(date1)
    end
    if date and tonumber(date.year) >= 2038 then
        date.year = "2037"
    end
    return os.time(date) -(_UTC_TIME + UTC * HOUR)
end

function q.getDateTimeByStandStr(str)
    if not str then 
        return q.serverTime()
    end
    local tbl = {}
    for k,v in string.gmatch(str, "(%d+)") do
        table.insert(tbl, k)
    end
    if #tbl >= 3 then
        local date = {year = tonumber(tbl[1] or 0), month = tonumber(tbl[2] or 0), day = tonumber(tbl[3] or 0), 
            hour = tonumber(tbl[4] or 0), min = tonumber(tbl[5] or 0) , sec = tonumber(tbl[6] or 0)}
        return q.OSTime(date)
    end
    return q.serverTime()
end

function q.getDateTimeByStr(str)
    if not str then 
        return {}
    end
    local tbl = {}
    for k,v in string.gmatch(str, "(%d+)") do
        table.insert(tbl, k)
    end
    local date = {year = tonumber(tbl[1] or 0), month = tonumber(tbl[2] or 0), day = tonumber(tbl[3] or 0), 
          hour = tonumber(tbl[4] or 0), min = tonumber(tbl[5] or 0) , sec = tonumber(tbl[6] or 0)}
    return date
end

function q.consumeTime(consumeTime)
    if consumeTime > 0 then
        local startTime = QUtility:getTime()
        while QUtility:getTime() - startTime < consumeTime do
        end
    end
end

function q.convertLargerNumber(num)
    num = tonumber(num)
    num = num or 0
    local unit = ""
    if num >= 10000000000 then
        num = math.floor(num/100000000)
        unit = "亿"
    elseif num >= 1000000 then
        num = math.floor(num/10000)
        unit = "万"
    end
    return num,unit
end

function q.countNodeMaxWidth(node)
    local point = node:getAnchorPoint()
    local pos = ccp(node:getPosition())
    local size = node:getContentSize()
    local scaleX = node:getScaleX()
    return pos.x + (1 - point.x) * size.width * scaleX
end

--自动排列node节点
function q.autoLayerNode(nodes, dircetion, gap)
    gap = gap or 0
    if dircetion == "x" then
        for index,node in ipairs(nodes) do
            if index > 1 then
                local perNode = nodes[index-1]
                local posX = 0
                if perNode:isVisible() then
                    posX = q.countNodeMaxWidth(perNode)
                else
                    posX = perNode:getPositionX()
                end
                if node:isVisible() then
                    local point = node:getAnchorPoint()
                    local size = node:getContentSize()
                    local scaleX = node:getScaleX()
                    posX = posX + point.x * size.width * scaleX + gap
                end
                node:setPositionX(posX)
            end
        end
    else
        for index,node in ipairs(nodes) do
            if index > 1 then
                local perNode = nodes[index-1]
                local size = perNode:getContentSize()
                if perNode:isVisible() == false then
                    size.height = 0
                end
                node:setPositionY(perNode:getPositionY() + size.height * perNode:getScaleY() + gap)
            end
        end
    end
end
--反向自动排列node节点
function q.turnAutoLayerNode(nodes, dircetion, gap)
    gap = gap or 0
    if dircetion == "x" then
        for index,node in ipairs(nodes) do
            if index > 1 then
                local perNode = nodes[index-1]
                local posX = 0
                if perNode:isVisible() then
                    posX = q.countNodeMaxWidth(perNode)
                else
                    posX = perNode:getPositionX()
                end
                if perNode:isVisible() then
                    local point = perNode:getAnchorPoint()
                    local size = perNode:getContentSize()
                    local scaleX = perNode:getScaleX()
                    posX = posX - point.x * size.width * scaleX - gap
                end
                node:setPositionX(posX)
            end
        end
    else
        for index,node in ipairs(nodes) do
            if index > 1 then
                local perNode = nodes[index-1]
                local size = perNode:getContentSize()
                if perNode:isVisible() == false then
                    size.height = 0
                end
                node:setPositionY(perNode:getPositionY() - size.height * perNode:getScaleY() - gap)
            end
        end
    end
end
--处理battleVerify
function q.battleVerifyHandler(battleVerify)
    if battleVerify then
        local buffer = crypto.decodeBase64(battleVerify)
        if buffer then
            buffer = crypto.decryptXXTEA(buffer, "WOW-BATTLE=VERIFY123")
            if buffer then
                local buffer = string.gsub(buffer, "battleKey:", "")
                buffer = string.gsub(buffer, ",sysTime:", "")
                local verify = crypto.encryptXXTEA(buffer, "WOW-BATTLE=VERIFY123")
                return crypto.encodeBase64(verify)
            end
        end
    end
end

-- 获取某时间当天剩余时间
function q.getLeftTimeOfDay(time, hour)
    time = time or q.serverTime()
    hour = hour or 0

    local dateTime = q.date("*t", time)
    dateTime.day = dateTime.day+1
    dateTime.hour = hour
    dateTime.min = 0
    dateTime.sec = 0

    return q.OSTime(dateTime) - time
end

-- 获取某个时间的天起始时间
function q.getFirstTimeOfDay(time, hour)
    time = time or q.serverTime()
    hour = hour or 0

    local dateTime = q.date("*t", time)
    if dateTime.hour < hour then
        dateTime.day = dateTime.day - 1
    end
    dateTime.hour = hour
    dateTime.min = 0
    dateTime.sec = 0

    return q.OSTime(dateTime)
end

-- 是否同一天  hour起始小时
function q.isSameDayTime(time, hour)
    if not time then
        return false
    end
    local startTime = q.getFirstTimeOfDay(time, hour)
    if 0 <= q.serverTime() - startTime and q.serverTime() - startTime <= DAY then
        return true
    end
    return false
end

-- 获取某个时间的周起始时间
function q.getFirstTimeOfWeek(time, hour)
    time = time or q.serverTime()
    hour = hour or 0

    local dateTime = q.date("*t", time)
    --date的第一天是周日0点，需要加一天到周一0点 -- 周日需要减一周
    if dateTime.wday == 1 then
        dateTime.day = dateTime.day - 7
    end    
    dateTime.day = dateTime.day - dateTime.wday + 2
    dateTime.hour = hour
    dateTime.min = 0
    dateTime.sec = 0

    return q.OSTime(dateTime)
end

-- 是否同一周 hour起始小时
function q.isSameWeekTime(time, hour)
    if not time then
        return false
    end
    local startTime = q.getFirstTimeOfWeek(time, hour)
    if 0 <= q.serverTime() - startTime and q.serverTime() - startTime <= WEEK then
        return true
    end
    return false
end

-- 獲取下個月第一個時間點
function q.getFirstTimeOfNextMonth()
    local curTime = q.serverTime()
    local curTimeTbl = q.date("*t", curTime)
    local nextMonthTimeTbl = {}
    if curTimeTbl.month == 12 then
        nextMonthTimeTbl.month = 1
        nextMonthTimeTbl.year = tonumber(curTimeTbl.year) + 1
    else
        nextMonthTimeTbl.month = tonumber(curTimeTbl.month) + 1
        nextMonthTimeTbl.year = tonumber(curTimeTbl.year)
    end
    nextMonthTimeTbl.sec = 0
    nextMonthTimeTbl.min = 0
    nextMonthTimeTbl.hour = 0
    nextMonthTimeTbl.day = 1

    local nextMonthTime = os.time(nextMonthTimeTbl)
    -- print("nextMonthTime = ", nextMonthTime)
    -- QKumo(q.date("*t", nextMonthTime))

    return nextMonthTime
end

-- 传入刷新时间点 计算刷新的时间毫秒数
function q.refreshTime(hour, min, sec)
    local currTime = q.date("*t", q.serverTime())
    local offsetTime = 0
    if tonumber(currTime.hour) < tonumber(hour) then
        offsetTime = 24*60*60
    end
    currTime.hour = hour or currTime.hour
    currTime.min = min or 0
    currTime.sec = sec or 0
    local freshTotalTime = q.OSTime(currTime) - offsetTime
    return freshTotalTime
end

-- 传入时间点 计算指定的时间毫秒数
function q.getTimeForHMS(hour, min, sec)
    local currTime = q.date("*t", q.serverTime())
    currTime.hour = hour or currTime.hour
    currTime.min = min or currTime.min
    currTime.sec = sec or currTime.sec
    local freshTotalTime = q.OSTime(currTime)
    return freshTotalTime
end

-- 传入时间点 计算指定的时间毫秒数
function q.getTimeForYMDHMS(year, month, day, hour, min, sec)
    local currTime = q.date("*t", q.serverTime())
    currTime.year = year or currTime.year
    currTime.month = month or currTime.month
    currTime.day = day or currTime.day
    currTime.hour = hour or currTime.hour
    currTime.min = min or currTime.min
    currTime.sec = sec or currTime.sec
    local freshTotalTime = q.OSTime(currTime)
    return freshTotalTime
end

-- 传入秒数计算时间格式为 小时：分钟：秒
-- hideHour： 如果小时为0，是否隐藏
function q.timeToHourMinuteSecond(time, hideHour)
    local hour = math.floor(time/(60*60))
    time = time % (60*60)
    local minute = math.floor(time/60)
    time = time%60
    local second = math.floor(time)
    local hourStr = string.format("%02d", hour)..":"
    if hideHour then
        hourStr = ""
    end

    return hourStr..string.format("%02d", minute)..":"..string.format("%02d", second)
end

function q.timeToHourMinuteSecondMs(time)
   local dateTime = q.date("*t", time/1000)

    return string.format("%02d", dateTime.hour)..":"..string.format("%02d", dateTime.min)..":"..string.format("%02d", dateTime.sec)

end

function q.timeToDayHourMinute(time)
    local day = math.floor(time/(DAY))
    time = time % (DAY)
    local hour = math.floor(time/HOUR)
    time = time%HOUR
    local minute = math.floor(time/MIN)
    time = time%MIN
    local second = math.floor(time)
    if day > 0 then
        return day.."天"..string.format("%02d", hour).."小时"..string.format("%02d", minute).."分"
    elseif hour > 0 then
        return string.format("%02d", hour).."小时"..string.format("%02d", minute).."分"..string.format("%02d", second).."秒"

    elseif minute > 0 then
        return string.format("%02d", minute).."分"..string.format("%02d", second).."秒"
    else
        return string.format("%02d", second).."秒"
    end
end

function q.timeToYearMonthDay(time)

    local dateTime = q.date("*t", time)
   
    return dateTime.year.."."..string.format("%02d", dateTime.month).."."..string.format("%02d", dateTime.day)
end

function q.timeToYearMonthDayHourMin(time)
    local dateTime = q.date("*t", time)
    return string.format("%d", dateTime.year).."年"..string.format("%d", dateTime.month).."月"..string.format("%02d", dateTime.day).."日"..string.format("%02d", dateTime.hour)..":"..string.format("%02d", dateTime.min)
end

function q.timeToMonthDayHourMin(time)
    local dateTime = q.date("*t", time)
    return string.format("%d", dateTime.month).."月"..string.format("%02d", dateTime.day).."日"..string.format("%02d", dateTime.hour)..":"..string.format("%02d", dateTime.min)
end

function q.timeToMonthDay(time)
    local dateTime = q.date("*t", time)
    return string.format("%d", dateTime.month).."月"..string.format("%02d", dateTime.day).."日"
end
--获取星期几
function q.timeWeekComm(y,m,d)
    if m == 1 or m == 2 then
        m = m + 12
        y = y - 1  
    end
    local m1,_ = math.modf(3 * (m + 1) / 5)
    local m2,_ = math.modf(y / 4)
    local m3,_ = math.modf(y / 100)
    local m4,_ = math.modf(y / 400)
 
    local iWeek = (d + 2 * m + m1 + y + m2 - m3  + m4 ) % 7
    local weekTab = {
        ["0"] = "星期一",
        ["1"] = "星期二",
        ["2"] = "星期三",
        ["3"] = "星期四",
        ["4"] = "星期五",
        ["5"] = "星期六",
        ["6"] = "星期日",
    }
    return weekTab[tostring(iWeek)] 
end

function q.setScreenScale(node, screenScale)
    local scale = 1.0
    local parent = node:getParent()
    while parent do
        scale = scale * parent:getScale()
        parent = parent:getParent()
    end
    node:setScale(screenScale / scale)
end

function q.newPercentBarClippingNode(node)
    local clippingNode = CCClippingNode:create()
    local stencil = CCLayerColor:create(ccc4(0,0,0,150),node:getContentSize().width,node:getContentSize().height)
    local scaleX = node:getScaleX()
    local scaleY = node:getScaleY()
    stencil:setScaleX(scaleX)
    stencil:setScaleY(scaleY)
    stencil:ignoreAnchorPointForPosition(false)
    stencil:setAnchorPoint(node:getAnchorPoint())
    clippingNode:setStencil(stencil)
    local parent = node:getParent()
    node:retain()
    node:removeFromParent()
    clippingNode:addChild(node)
    parent:addChild(clippingNode)
    clippingNode:setPosition(ccp(node:getPosition()))
    node:setPosition(ccp(0, 0))
    node:release()

    return clippingNode
end

function q.createHpBar(resFilePath)
    if resFilePath == nil then return end

    local sprite
    if type(resFilePath) == "string" then
        sprite = CCSprite:create(resFilePath)
    else
        sprite = resFilePath
    end
    local head = 0
    local tail = 0
    local width = sprite:getContentSize().width
    local percentScale = (width - head - tail) / width
    local headPercent = head / width
    setNodeShaderProgram(sprite, qShader.Q_ProgramPositionTextureColorBar)
    sprite:setOpacityModifyRGB(false)
    function sprite:update(percent)
        local realPercent = percent * percentScale + headPercent
        self:setColor(ccc3(255 * realPercent, 255, 255))
    end
    function sprite:setHeadPadding(headPadding)
        head = headPadding
        percentScale = (width - head - tail) / width
        headPercent = head / width
    end
    function sprite:setTailPadding(tailPadding)
        tail = tailPadding
        percentScale = (width - head - tail) / width
    end
    return sprite
end

function q.createHpBarRevers(resFilePath)
    if resFilePath == nil then return end

    local sprite
    if type(resFilePath) == "string" then
        sprite = CCSprite:create(resFilePath)
    else
        sprite = resFilePath
    end
    local head = 0
    local tail = 0
    local width = sprite:getContentSize().width
    local percentScale = (width - head - tail) / width
    local headPercent = head / width
    setNodeShaderProgram(sprite, qShader.Q_ProgramPositionTextureColorBarRevers)
    sprite:setOpacityModifyRGB(false)
    function sprite:update(percent)
        local realPercent = percent * percentScale + headPercent
        self:setColor(ccc3(255 * realPercent, 255, 255))
    end
    function sprite:setHeadPadding(headPadding)
        head = headPadding
        percentScale = (width - head - tail) / width
        headPercent = head / width
    end
    function sprite:setTailPadding(tailPadding)
        tail = tailPadding
        percentScale = (width - head - tail) / width
    end
    return sprite
end

-- by Kumo 给一张图片添加它的阴影
function q.addSpriteShadow(sp, spFrame)
    if not sp or not spFrame then return end

    sp:setDisplayFrame(spFrame)
    local shadowSp = CCSprite:createWithSpriteFrame(spFrame)
    shadowSp:setRotation(15)
    shadowSp:setScaleX(1)
    shadowSp:setScaleY(0.7)
    shadowSp:setOpacity(100)
    shadowSp:setColor(ccc3(0,0,0))
    shadowSp:setAnchorPoint(sp:getAnchorPoint())
    shadowSp:setPosition(ccp(sp:getPosition()))

    sp:getParent():addChild(shadowSp)
    shadowSp:setZOrder(-1)
end

-- 判断两个点是否足够近
function q.is2PointsClose(pt1, pt2)
    local x = pt1.x - pt2.x
    local y = pt1.y - pt2.y
    return x * x + y * y < EPSILON * EPSILON
end

function q.is2PointsCloseWithTolerance(pt1, pt2, tolerance)
    tolerance = tolerance or EPSILON
    local x = pt1.x - pt2.x
    local y = pt1.y - pt2.y
    return x * x + y * y < tolerance * tolerance
end

-- 计算两点距离
function q.distOf2Points(pt1, pt2)
    local dx = pt1.x - pt2.x
    local dy = pt1.y - pt2.y
    return math.sqrt(dx * dx + dy * dy)
end

-- 计算两点距离的平方，用来比较距离
function q.distOf2PointsSquare(pt1, pt2)
    local dx = pt1.x - pt2.x
    local dy = pt1.y - pt2.y
    return dx * dx + dy * dy
end

function q.distOf2PointsSquareWithYCoefficient(pt1, pt2, yCoefficient)
    local dx = pt1.x - pt2.x
    local dy = (pt1.y - pt2.y) * yCoefficient
    return dx * dx + dy * dy
end

function qccp(x, y)
    return {x = x, y = y}
end

-- 计算两点的夹角
function q.angleOf2Points(p1, p2)
    local p = {}
    p.x = p2.x - p1.x
    p.y = p2.y - p1.y
           
    local r = math.atan2(p.y,p.x)*180/math.pi

    return r
end

-- 取边界值
function q.getNumByBoundary(num, min, max)
    local tempNum = num
    if min and tempNum < min then
        tempNum = min
    end
    if max and tempNum > max then
        tempNum = max
    end
    return tempNum
end
--[[
/**
 *  计算距离添加换行符
 *  @param input 需要添加换行符的字符串
 *  @param skipSpace 是否忽略空格
 *  @return fullWidth 全角字符所占的宽度
 *  @return width 半角字符所占的宽度
 *  @return lineWidth 本行的宽度
 */
--]]
function q.autoWrap(input,fullWidth,width,lineWidth,skipSpace)
    local str = ""
    local num = ""
    if string.len(input) == 0 then return str end
    local i = 1
    local len = 0
    local c,b
    while true do 
        c = string.sub(input,i,i)
        b = string.byte(c)
        if b > 128 then
            str = str .. (string.sub(input,i,i+2))
            len = len + fullWidth
            i = i + 3
        else
            if b ~= 32 or skipSpace == false then
                str = str .. c
            end
            len = len + width
            i = i + 1
        end
        --检查数字中是否有换行符
        if (b >= 48 and b <= 57) or b == 46 then
            num = num..c
        elseif num ~= "" then
            num = ""
        end
        if i > #input then
            break
        end
        if b == 10 then
            len = 0
        elseif len >= lineWidth then
            if num ~= "" then
              str = q.replaceString(str, num, "\n")
              str = str..num 
              len = 0
            else
              str = str .. "\n"
              len = 0
            end
        end
     end
     return str
end

--替换源字符串中最后一个字符
function q.replaceString(s, pattern, reps)
  local i = string.len(s)
  local a = string.len(pattern)
  local str = ""
  local c = ""
  local isReplace = false
  while true do 
      if i < a then
        c = string.sub(s,1,i)
      else
        c = string.sub(s,i - a + 1, i)
      end
      if c == pattern and isReplace == false then
        str = reps..str
        i = i - a
        isReplace = true
      else
        str = c..str
        i = i - a
      end
      if i <= 0 then
        break
      end
  end
  return str
end

--[[
 /**
  *计算文字的长度
  * @param input 需要计算的文字
  * @param fullWidth 全角宽度
  * @param width 半角宽度
  */
--]]

function q.wordLen(input, fullWidth, width)
    local i = 1
    local len = 0
    if string.len(input) == 0 then return len end
    local c,b
    while true do 
        c = string.sub(input,i,i)
        b = string.byte(c)
        if b > 128 then
            len = len + fullWidth
            i = i + 3
        else
            len = len + width
            i = i + 1
        end
        if i > string.len(input) then
            break
        end
     end
     return len
end

--[[
 /**
  * 划分数字的千分制
  * @param num 需要转换的数字
  * @return str 返回的字符串
  */ 
]]
function q.micrometer(num)
    local str = ""
    local value = 0
    while true do
        value = num%1000
        num = math.floor(num/1000)
        if num > 0 then
            str = string.format("%.3d", value) .. str
            str =  "," .. str
        else
            str = string.format("%d", value) .. str
            break
        end
    end
    return str
end

--[[
    转换阿拉伯数字为中文数字
--]]
function q.numToWord(i)
    if i == 0 then
        return "零"
    elseif i == 1 then
        return "一"
    elseif i == 2 then
        return "二"
    elseif i == 3 then
        return "三"
    elseif i == 4 then
        return "四"
    elseif i == 5 then
        return "五"
    elseif i == 6 then
        return "六"
    elseif i == 7 then
        return "七"
    elseif i == 8 then
        return "八"
    elseif i == 9 then
        return "九"
    elseif i == 10 then
        return "十"
    elseif i == 100 then
        return "一百"
    elseif i == 1000 then
        return "一千"
    elseif i > 10 and i <20 then
        return "十"..q.numToWord(i%10)
    elseif i < 100 then
        if i%10 > 0 then
            return q.numToWord(math.floor(i/10)).."十"..q.numToWord(i%10)
        else
            return q.numToWord(math.floor(i/10)).."十"
        end
    elseif i < 1000 then
        if i%100 > 0 then
            if i%100 < 20 then
                return q.numToWord(math.floor(i/100)).."百"..q.numToWord(math.floor((i%100)/10))..q.numToWord(i%100)
            else
                return q.numToWord(math.floor(i/100)).."百"..q.numToWord(i%100)
            end
        else
            return q.numToWord(math.floor(i/100)).."百"
        end
    elseif i < 10000 then
        if i%1000 > 0 then
            if i%1000 < 100 then
                return q.numToWord(math.floor(i/1000)).."千"..q.numToWord(math.floor((i%1000)/100))..q.numToWord(i%1000)
            else
                return q.numToWord(math.floor(i/1000)).."千"..q.numToWord(i%1000)
            end
        else
            return q.numToWord(math.floor(i/1000)).."千"
        end
    elseif i < 100000000 then
        if i%10000 > 0 then
            if i%10000 < 1000 then
                return q.numToWord(math.floor(i/10000)).."万"..q.numToWord(math.floor((i%10000)/1000))..q.numToWord(i%10000)
            else
                return q.numToWord(math.floor(i/10000)).."万"..q.numToWord(i%10000)
            end
        else
            return q.numToWord(math.floor(i/10000)).."万"
        end
    else
        if i%100000000 > 0 then
            if i%100000000 < 10000000 then
                return q.numToWord(math.floor(i/100000000)).."亿"..q.numToWord(math.floor((i%100000000)/10000000))..q.numToWord(i%100000000)
            else
                return q.numToWord(math.floor(i/100000000)).."亿"..q.numToWord(i%100000000)
            end
        else
            return q.numToWord(math.floor(i/100000000)).."亿"
        end
    end
end

--[[
    颜色转成文字
]]
function q.colorToWord(name)
    if name == "white" then
        return "白"
    elseif name == "green" then
        return "绿"
    elseif name == "blue" then
        return "蓝"
    elseif name == "purple" then
        return "紫"
    elseif name == "orange" then
        return "橙"
    elseif name == "red" then
        return "红"
    elseif name == "yellow" then
        return "金"
    end
    return ""
end

--[[
    convert num address to ip address
]]
function q.convertNumToIP(num)
    local ip1 = math.floor(num/2^24)
    num = num%2^24
    local ip2 = math.floor(num/2^16)
    num = num%2^16
    local ip3 = math.floor(num/2^8)
    num = num%2^8
    local ip4 = math.floor(num)
    return string.format("%d.%d.%d.%d", ip1,ip2,ip3,ip4)
end

function q.convertColorToWord(color)
    if color == "white" then
        return "白色"
    elseif color == "green" then
        return "绿色"
    elseif color == "blue" then
        return "蓝色"
    elseif color == "purple" then
        return "紫色"
    elseif color == "orange" then
        return "橙色"
    elseif color == "red" then
        return "红色"
    elseif color == "yellow" then
        return "金色"
    end
    return ""
end

function q.convertStrToTable(str, splits, index)
    if index == nil then index = 1 end
    local tbl = {}
    if str ~= nil and #str > 0 then
        if splits ~= nil and #splits > 0 then
            local arr = string.split(str, splits[index])
            local isSplitChild = false
            if #splits > index then
                isSplitChild = true
            end
            for _,value in ipairs(arr) do
                if isSplitChild then
                    local childTbl = q.convertStrToTable(value, splits, index+1)

                    if #childTbl == 1 and type(childTbl[1]) ~= "table" then
                        table.insert(tbl, childTbl[1])
                    elseif #childTbl == 2 then
                        tbl[childTbl[1]] = childTbl[2]
                    else
                        table.insert(tbl,childTbl)
                    end
                else
                    table.insert(tbl, value)
                end
            end
        end
    end
    return tbl
end

--[[
    convert ip address to num address
]]
function q.convertIPToNum(address)
    local ip1,ip2,ip3,ip4 = string.match(address, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)")
    return ip1*2^24 + ip2*2^16 + ip3*2^8 + ip4
end

-- sort node based on their y position from large to small when reverse is false
function q.sortNodeZOrder(nodes, reverse)
    if nodes == nil or table.nums(nodes) == 0 then
        return {}
    end
    local parent = nodes[1]:getParent()
    for k, node in ipairs(nodes) do
        if node:getParent() ~= parent then
            return nodes
        end
    end

    table.sort(nodes, function(node1, node2)
        local tag1 = node1:getTag()
        local tag2 = node2:getTag()
        if tag1 ~= tag2 then
            -- CCMessageBox(tostring(tag1) .. " " .. tostring(tag2), "")
            return tag1 > tag2
        else
            local y1 = node1:getPositionY()
            local y2 = node2:getPositionY()

            if (y1 < y2) and (y2 - y1) > 1e-6 then
                return true
            end

            return false
        end
    end)

    if reverse == false then
        local reverseNodes = {}
        local count = table.nums(nodes)
        count = count + 1
        for i, node in ipairs(nodes) do
            reverseNodes[(count - i)] = node
        end
        return reverseNodes
    else
        return nodes
    end
end

-- get table. if not existent, create one.
function q.mt(t, ...)
    local ps = {...}
    local subt = t
    for _, p in ipairs(ps) do
        subt = t[p]
        if not subt then
            subt = {}
            t[p] = subt
        end
        t = subt
    end
    return subt
end

-- set node position to the screen position of another node
function q.setScreenPosition(src, dst, pos)
    local wp = dst:convertToWorldSpace(ccp(pos.x, pos.y))
    local lp = src:getParent():convertToNodeSpace(wp)
    src:setPosition(lp)
end

QBattle = {}

function QBattle.getTouchingActor(actorViews, x, y)
    if actorViews == nil then return nil end

    local touchedViews = {}
    for i, actorView in ipairs(actorViews) do
        if actorView.getModel and actorView:getModel():isDead() == false
            and actorView:getModel():isNeutral() ~= true
            and actorView:getModel():isExile() ~= true
            and actorView:isTouchMoveOnMe(x, y) == true then
            if table.nums(touchedViews) == 0 
                -- and actorView:isTouchMoveOnMeDeeply(x, y) == true 
                and (not app.scene._showActorView or app.scene._showActorView == actorView) then
                return actorView
            else
                table.insert(touchedViews, actorView)
            end
        end
    end

    local touchedCount = table.nums(touchedViews)
    local selectView = nil
    if touchedCount == 1 then
        selectView = touchedViews[1]
    elseif touchedCount > 1 then
        local touchWeight = 0
        local coefficient = 0.8
        for i, touchedView in ipairs(touchedViews) do
            if app.scene._showActorView then
                if touchedView == app.scene._showActorView then
                    selectView = touchedView
                end
            else
                local newTouchWeight = touchedView:getTouchWeight(x, y, coefficient)
                if newTouchWeight > touchWeight then
                    selectView = touchedView
                    touchWeight = newTouchWeight
                    coefficient = coefficient - 0.2
                    if coefficient < 0.2 then
                        coefficient = 0.2
                    end
                end
            end
        end
    end

    return selectView
end

function QBattle.getTouchingActorCore(actorViews, x, y)
    if actorViews == nil then return nil end

    for _, actorView in ipairs(actorViews) do
        if actorView.getModel and actorView:getModel():isDead() == false
            and actorView:getModel():isNeutral() ~= true
            and actorView:getModel():isExile() ~= true
            and actorView:isTouchMoveOnMeTouchRect(x, y) == true
            and (not app.scene._showActorView or app.scene._showActorView == actorView) then
            return actorView
        end
    end
end

function q.isEmpty(t)
    return t == nil or next(t) == nil
end

function math.xor(value1, value2)
    return (not not value1) == (not value2)
end

function math.sampler(value1, value2, percent)
    if type(percent) ~= "number" then
        return nil
    end

    if type(value1) == "number" and type(value2) == "number" then
        return value1 * (1 - percent) + value2 * percent 
    elseif type(value1) == "table" and type(value2) == "table" then
        local result = {}
        for k,v1 in pairs(value1) do
            if value2[k] ~= nil then
                local v2 = value2[k]
                if type(v1) == "number" and type(v2) == "number" then
                    result[k] = v1 * (1 - percent) + v2 * percent 
                end
            end
        end
        return result
    else
        return nil
    end
end

function math.sampler2(value1, value2, source_limit1, source_limit2, source_value)
    return math.sampler(value1, value2, (source_value - source_limit1) / (source_limit2 - source_limit1))
end

function math.clamp(value, limit1, limit2)
    if value > limit1 and value > limit2 then
        return limit1 > limit2 and limit1 or limit2
    elseif value < limit1 and value < limit2 then
        return limit1 < limit2 and limit1 or limit2
    else
        return value
    end
end

function math.wrap(value, limit1, limit2)
    local value = math.fmod(value - limit1, limit2 - limit1) + limit1
    if value < limit1 then
        value = value + limit2 - limit1
    end
    return value
end

-- q:format_dec(123, 10, 4) --> "00,0000,0123"
function q.format_dec_int(value, max_digits_number, comma_interval)
    value = math.floor(value)
    local digits_number = 0
    local str = ""
    while true do
        if comma_interval and digits_number ~= 0 and (digits_number - math.floor(digits_number / comma_interval) * comma_interval) == 0 then
            str = "," .. str
        end

        local tmp = math.floor(value / 10)
        str = tostring(value - tmp * 10) .. str
        value = tmp
        digits_number = digits_number + 1

        if max_digits_number then
            if digits_number >= max_digits_number then
                break
            end
        else
            if value <= 0 then
                break
            end
        end
    end

    return str, digits_number
end

-- C (n, k) = n! / (k! * (n-k)!)
-- return the index array
-- n, k is a number
-- n should large or equal than k
function math.combine(n, k)
    local t = {}

    if n == nil then
        return t
    end

    if k == nil then
        k = 1
    end

    if type(n) ~= "number" or type(k) ~= "number" then
        return t
    end

    if n < k then
        return t
    end

    if n == k then
        local m = {}
        for i = n, 1, -1 do
            table.insert(m, i)
        end
        table.insert(t, m)
        return t
    end

    if k == 1 then
        for i = n, 1, -1 do
            local m = {}
            table.insert(m, i)
            table.insert(t, m)
        end
        return t
    end

    for i = n, k, -1 do
        local _t = math.combine(i - 1, k - 1)
        for _, m in ipairs(_t) do
            table.insert(m, 1, i)
        end
        for _, m in ipairs(_t) do
            table.insert(t, m)
        end
    end

    return t

end

function scheduler.setTimeFunction(func)
    local sharedScheduler = CCDirector:sharedDirector():getScheduler()
    sharedScheduler:setUpdateTimeScriptHandle(func)
end

-- 用于战斗回放的uuid
local _replay_pseudo_id = 0
-- temporary uuid solution for demo
function replay_uuid()
    _replay_pseudo_id = _replay_pseudo_id + 1
    return _replay_pseudo_id
end

-- 设置用于战斗回放的uuid
function set_replay_pseudo_id(replay_pseudo_id)
    if replay_pseudo_id then
        _replay_pseudo_id = replay_pseudo_id
    end
end

local _story_uuid = 0
function story_uuid()
    _story_uuid = _story_uuid + 1
    return 10000 + _story_uuid 
end

function set_story_uuid(storyuuid)
    if storyuuid then
        _story_uuid = storyuuid
    end
end

-- 用于计算带参数的四则运算的函数
local function _initParseValue()
    local priority = {}
    priority["+"] = 0
    priority["-"] = 0
    priority["*"] = 1
    priority["/"] = 1
    local func = {}
    func["+"] = function(v1, v2) return v1 + v2 end
    func["-"] = function(v1, v2) return v1 - v2 end
    func["*"] = function(v1, v2) return v1 * v2 end
    func["/"] = function(v1, v2) return v1 / v2 end
    local ops = {}
    ops["+"] = true
    ops["-"] = true
    ops["*"] = true
    ops["/"] = true
    ops["("] = true
    ops[")"] = true
    local digits = {}
    digits["0"] = true
    digits["1"] = true
    digits["2"] = true
    digits["3"] = true
    digits["4"] = true
    digits["5"] = true
    digits["6"] = true
    digits["7"] = true
    digits["8"] = true
    digits["9"] = true
    digits[","] = true
    local function parseWord(format, cursor)
        local number_cursor = nil
        local var_cursor = nil
        while cursor <= string.len(format) do
            local c = string.sub(format, cursor, cursor)
            if c == " " then
                if number_cursor then
                    return tonumber(string.sub(format, number_cursor, cursor - 1)), cursor
                elseif var_cursor then
                    return string.sub(format, var_cursor, cursor - 1), cursor
                end
            elseif number_cursor then
                if not digits[c] then
                    return tonumber(string.sub(format, number_cursor, cursor - 1)), cursor
                end
            elseif var_cursor then
                if ops[c] then
                    return string.sub(format, var_cursor, cursor - 1), cursor
                end
            else
                if ops[c] then
                    return c, cursor + 1
                elseif digits[c] then
                    number_cursor = cursor
                else
                    var_cursor = cursor
                end
            end
            cursor = cursor + 1
        end

        if number_cursor then
            return tonumber(string.sub(format, number_cursor, cursor - 1)), cursor
        elseif var_cursor then
            return string.sub(format, var_cursor, cursor - 1), cursor
        end

        return nil, nil
    end
    local function evaluate(temp)
        while #temp > 1 do
            local index = #temp
            temp[index - 2] = func[temp[index - 1]](temp[index - 2], temp[index])
            temp[index - 1] = nil
            temp[index] = nil
        end
        return temp[1]
    end
    local calculate = nil
    calculate = function(list, from, to, var)
        local cursor = from
        local last_op = nil
        local temp = {}
        while true do
            if cursor > to then
                return evaluate(temp), cursor
            end
            local c = list[cursor]
            if c == "(" then
                local v = nil
                v, cursor = calculate(list, cursor + 1, to, var)
                table.insert(temp, v)
            elseif c == ")" then
                return evaluate(temp), cursor + 1
            elseif type(c) == "number" then
                table.insert(temp, c)
                cursor = cursor + 1
            elseif not ops[c] then
                table.insert(temp, var[c])
                cursor = cursor + 1
            else
                local op = c
                if last_op then
                    if priority[last_op] > priority[op] then
                        local v = evaluate(temp)
                        temp = {}
                        table.insert(temp, v)
                        table.insert(temp, op)
                        last_op = op
                        cursor = cursor + 1
                    else
                        table.insert(temp, op)
                        last_op = op
                        cursor = cursor + 1
                    end
                else
                    table.insert(temp, op)
                    last_op = op
                    cursor = cursor + 1
                end
            end
        end
    end
    local function parseValue(format, var)
        local symbol = nil
        local cursor = 1
        local list = {}
        while true do
            symbol, cursor = parseWord(format, cursor)
            if symbol == nil or cursor == nil then
                break
            end
            table.insert(list, symbol)
        end

        return calculate(list, 1, #list, var)
    end
    return parseValue
end

local _parseValue = _initParseValue()

function q.evaluateFormula(format, var)
    return _parseValue(format, var)
end

--[[
    path: a directory path
    fileSuffix: suffix of file type. for example "lua", "png"
    isIntoSubfolder: default is true
--]]
function filesInFolder(path, fileSuffix, isIntoSubfolder)
    local findFiles = {}
    if path == nil then
        return findFiles
    end

    if isIntoSubfolder == nil then
        isIntoSubfolder = true
    end

    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path .. "/" .. file
            local fname = file;
            if fileSuffix == nil or string.len(fileSuffix) == 0 then
                table.insert(findFiles, fname)
                -- printInfo("file file:" .. fname .. " in folder:" .. path)
            else
                if string.find(f, "%." .. fileSuffix) ~= nil then
                    table.insert(findFiles, fname)
                    -- printInfo("file file:" .. fname .. " in folder:" .. path)
                end
            end
            local attr = lfs.attributes(f)
            assert (type(attr) == "table")
            if attr.mode == "directory" and isIntoSubfolder then
                local fileNames = filesInFolder(f, fileSuffix, isIntoSubfolder)
                for _, fileName in ipairs(fileNames) do
                    table.insert(findFiles, fname .. "/" .. fileName)
                end
            end
        end
    end

    return findFiles
end


-- shrink object functions
local _rawget = rawget
local _rawset = rawset
local _next = next
local shrink_metas = {}
local function get_shrink_object_index(__colnames, __enum2string, __patterns, __chart)
    if __enum2string and __patterns then
        return function(t, key)
            local ret = _rawget(t, __colnames[key])
            if ret and __enum2string[key] then
                local __ret = __enum2string[key][ret]
                ret = __ret or ret
                return ret
            elseif ret and __patterns[key] then
                -- local values = {}
                -- while true do
                --     local value = _rawget(t, ret)
                --     if value then
                --         values[#values + 1] = value
                --         ret = ret - 1
                --     else
                --         break
                --     end
                -- end
                return string.format(__chart[tostring(_rawget(t,1))][-1][__colnames[key]], --[[unpack(values)]] 
                    _rawget(t, ret),_rawget(t, ret - 1),_rawget(t, ret - 2),_rawget(t, ret - 3)
                    ,_rawget(t, ret - 4),_rawget(t, ret - 5),_rawget(t, ret - 6)
                    ,_rawget(t, ret - 7),_rawget(t, ret - 8),_rawget(t, ret - 9)
                    ,_rawget(t, ret - 10))
            else
                return ret
            end
        end
    elseif __enum2string then
        return function(t, key)
            local ret = _rawget(t, __colnames[key])
            if ret and __enum2string[key] then
                local __ret = __enum2string[key][ret]
                ret = __ret or ret
                return ret
            else
                return ret
            end
        end
    else
        return function(t, key)
            return _rawget(t, __colnames[key])
        end
    end
end
local function get_shrink_object_pairs(__colnames, __colindices, __enum2string)
    local v, index
    if __enum2string then
        return function(t)
            return function(t, k)
                repeat
                    k, index = _next(__colnames, k)
                    v = _rawget(t, index) 
                until k == nil or v ~= nil
                if v and __enum2string[k] then
                    local __v = __enum2string[k][v]
                    v = __v or v
                    return k, v
                else
                    return k, v
                end
            end, t, nil
        end
    else
        return function(t)
            local len = #__colindices
            return function(t, k)
                local _index = __colnames[k]
                for index = (_index and (_index + 1) or 1), len do
                    v = _rawget(t, index)
                    if v then
                        return __colindices[index], v
                    end
                end
            end, t, nil
        end
    end
end
local function get_shrink_object_newindex(__colnames, __colindices, __string2enum)
    if __string2enum then
        return function(t, k, v)
            local index = __colnames[k]
            if not index then
                table.insert(__colindices, k)
                index = #__colindices
                __colnames[k] = index
            end
            if v and __string2enum[k] then
                local __v = __string2enum[k][v]
                v = __v or v
                _rawset(t, index, v)
            else
                _rawset(t, index, v)
            end
        end
    else
        return function(t, k, v)
            local index = __colnames[k]
            if not index then
                table.insert(__colindices, k)
                index = #__colindices
                __colnames[k] = index
            end
            _rawset(t, index, v)
        end
    end
end
local clonedObjects = nil
function q.enableShrinkObjectCache()
    clonedObjects = {}
end
function q.disableShrinkObjectCache()
    clonedObjects = nil
end
function q.cloneShrinkedObject(shrink_obj)
    if type(shrink_obj) ~= "table" then
        return shrink_obj
    end

    if clonedObjects then
        local obj = clonedObjects[shrink_obj]
        if obj then
            return obj
        end
    end

    if not getmetatable(shrink_obj) or not shrink_metas[getmetatable(shrink_obj)] then
        return clone(shrink_obj)
    end

    local mt = getmetatable(shrink_obj)
    setmetatable(shrink_obj, nil)
    local obj = {}
    local __colnames = shrink_metas[mt][1]
    local enum2string = shrink_metas[mt][3]
    if enum2string then
        for k, v in pairs(__colnames) do
            local v = shrink_obj[v]
            if v and enum2string[k] then
                v = enum2string[k][v] or v
                obj[k] = v
            else
                obj[k] = v
            end
        end
    else
        for k, v in pairs(__colnames) do
            obj[k] = shrink_obj[v]
        end
    end
    setmetatable(shrink_obj, mt)

    if clonedObjects then
        clonedObjects[shrink_obj] = obj
    end

    return obj
end
function q.shrinkObject(colnames_bykey, colnames_byindex, mt, obj, enum2string, string2enum)
    local raw_obj = obj
    local obj = {}

    for key, value in pairs(raw_obj) do
        local col_index = colnames_bykey[key]
        if col_index == nil then
            table.insert(colnames_byindex, key)
            col_index = #colnames_byindex
            colnames_bykey[key] = col_index
        end
        obj[col_index] = value
    end

    if not mt.__index then
        mt.__index = get_shrink_object_index(colnames_bykey, enum2string)
        mt.__newindex = get_shrink_object_newindex(colnames_bykey, colnames_byindex, enum2string)
        mt.__pairs = get_shrink_object_pairs(colnames_bykey, colnames_byindex, enum2string)
        shrink_metas[mt] = {colnames_bykey, colnames_byindex, enum2string, string2enum}
    end
    setmetatable(obj, mt)

    return obj
end
function q.getShrinkMetatable(colnames_bykey, colnames_byindex, enum2string, string2enum, patterns, charttable)
    local mt = {}
    mt.__index = get_shrink_object_index(colnames_bykey, enum2string, patterns, charttable)
    mt.__newindex = get_shrink_object_newindex(colnames_bykey, colnames_byindex, enum2string)
    mt.__pairs = get_shrink_object_pairs(colnames_bykey, colnames_byindex, enum2string)
    shrink_metas[mt] = {colnames_bykey, colnames_byindex, enum2string, string2enum}
    return mt
end

-- utility functions debug
local _debug_hook_disabled_ = false
local _debug_hook_main_ = nil
function q.disableDebugHook()
    if _debug_hook_disabled_ then
        return
    end
    _debug_hook_main_ = debug.gethook()
    debug.sethook()
    _debug_hook_disabled_ = true
end

function q.enableDebugHook()
    if not _debug_hook_disabled_ then
        return
    end
    debug.sethook(_debug_hook_main_, "lcr")
    _debug_hook_main_ = nil
    _debug_hook_disabled_ = false
end

--坐标向下取整
function q.floorPos(pos)
    if pos == nil then return end
    pos.x = math.floor(pos.x)
    pos.y = math.floor(pos.y)
end

-- max
function q.max(candidates, dist_func, compare_func)
    local candidate, distance
    for i, obj in ipairs(candidates) do
        local dist = dist_func(obj)
        if compare_func(distance, dist) then
            distance = dist
            candidate = obj
        end
    end
    return candidate, distance
end

-- id, level parsing
function q.parseIDAndLevel(id, default_level, skill, buff)
    default_level = default_level or 1
    local level = nil
    if string.find(id, ",") then
        local objs = string.split(id, ",")
        id = objs[1]
        level = tonumber(objs[2])
    elseif string.find(id, ";") then
        local objs = string.split(id, ";")
        id = objs[1]
        if objs[2] == "y" then
            if skill then
                level = skill:getSkillLevel()
            elseif buff then
                level = buff:getLevel()
            else
                level = default_level
            end
        else
            level = default_level
        end
    else
        level = default_level
    end

    return id, level
end

-- shuffle array
function q.shuffleArray(array, random_func)
    random_func = random_func or math.random
    local count = #array
    for i = 1, count - 1 do
        local switch_index = random_func(i, count)
        local tmp = array[switch_index]
        array[switch_index] = array[i]
        array[i] = tmp
    end
end

function q.getSkillMainDesc(skillDesc)
    if not skillDesc then
        return ""
    end
    if string.find(skillDesc, "。 ") then
        skillDesc = string.sub(skillDesc, 0, string.find(skillDesc, "。 ")-1).."..."
    end
    return skillDesc
end

function q.getSkillDescByLimitNum(skillDesc , num)
    if not skillDesc then
        return ""
    end
    local  result = ""
    local textLength = utf8.len(skillDesc)
    if textLength > num then
        result = utf8.sub(skillDesc, 1, num)
        result = result.."..."
    else
        return skillDesc
    end

    return result
end


function q.alignToScreenVerticalAbsolute(node, isUp, dist)
    if isUp then
        local p = node:getParent():convertToNodeSpace(ccp(0.0, display.height - dist))
        node:setPositionY(p.y)
    else
        local p = node:getParent():convertToNodeSpace(ccp(0.0, dist))
        node:setPositionY(p.y)
    end
end

local _posBeforeShake = nil

function q.shakeScreen(value, duration, repeat_count)
    value = value or 20
    duration = duration and (duration / 8) or 0.05
    repeat_count = repeat_count or 1

    local scene = CCDirector:sharedDirector():getRunningScene()
    if scene then
        if _posBeforeShake == nil then
            _posBeforeShake = {x = scene:getPositionX(), y = scene:getPositionY()}
        end
        scene:stopAllActions()
        scene:setPosition(_posBeforeShake.x, _posBeforeShake.y)
        local arr = CCArray:create()
        -- how shake looks like
        -- ______
        -- \    /|
        -- |\  / | 
        -- | \/  |
        -- | /\  |
        -- |/  \ |
        -- /____\|
        arr:addObject(CCMoveBy:create(duration / 2, ccp(-value / 2, value / 2)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(-value, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, 0)))
        arr:addObject(CCMoveBy:create(duration, ccp(-value, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(value, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration / 2, ccp(-value / 2, value / 2)))
        scene:runAction(CCRepeat:create(CCSequence:create(arr), repeat_count))
    end
end

function q.shakePortraitScreen(value, duration, repeat_count)
    value = value or 20
    duration = duration and (duration / 8) or 0.05
    repeat_count = repeat_count or 1

    local scene = CCDirector:sharedDirector():getRunningScene()
    if scene then
        if _posBeforeShake == nil then
            _posBeforeShake = {x = scene:getPositionX(), y = scene:getPositionY()}
        end
        scene:stopAllActions()
        scene:setPosition(_posBeforeShake.x, _posBeforeShake.y)
        local arr = CCArray:create()

        arr:addObject(CCMoveBy:create(duration / 2, ccp(0, value / 2)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, value)))
        arr:addObject(CCMoveBy:create(duration, ccp(0, -value)))
        arr:addObject(CCMoveBy:create(duration / 2, ccp(0, value / 2)))
        scene:runAction(CCRepeat:create(CCSequence:create(arr), repeat_count))
    end
end

function q.addSpriteButton( sp, callBack )
    local button = CCControlButton:create(" ", "font/FZZhunYuan-M02S.ttf", 28)
    local buttonWidth = sp:getContentSize().width
    local buttonHeight = sp:getContentSize().height
    button:setPreferredSize(CCSize(buttonWidth, buttonHeight))

    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchDown)
    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchDragInside)
    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchDragOutside)
    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchDragEnter)
    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchDragExit)
    button:addHandleOfControlEvent(callBack, CCControlEventTouchUpInside)
    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchUpOutside)
    -- button:addHandleOfControlEvent(callBack, CCControlEventTouchCancel)
    -- button:addHandleOfControlEvent(callBack, CCControlEventValueChanged)

    button:setBackgroundSpriteFrameForState(sp:getDisplayFrame(), CCControlStateNormal)
    button:setBackgroundSpriteFrameForState(sp:getDisplayFrame(), CCControlStateHighlighted)
    button:setBackgroundSpriteFrameForState(sp:getDisplayFrame(), CCControlStateDisabled)

    -- button:setTitleColorForState(ccc3(84, 56, 34), CCControlStateNormal)
    -- button:setTitleColorForState(ccc3(162, 58, 33), CCControlStateHighlighted)
    -- button:setTitleColorForState(ccc3(162, 58, 33), CCControlStateDisabled)

    button:setZoomOnTouchDown(false)
    button:setAnchorPoint(ccp(0.5, 0.5))

    return button
end

function writeToFile(name, content)
    if content == nil or name == nil then
        return
    end
    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    local wfile = io.open(fileutil:getWritablePath() .. fileName, "w")
    assert(wfile)
    wfile:write(content)
    wfile:close() 
end

function writeToBinaryFile(name, content)
    if content == nil or name == nil then
        return
    end
    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    local wfile = io.open(fileutil:getWritablePath() .. fileName, "wb")
    assert(wfile)
    wfile:write(content)
    wfile:close() 
end

function appendToFile(name, content)
    if content == nil or name == nil then
        return
    end
    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    if fileutil:isFileExist(fileutil:getWritablePath() .. fileName) == false then
        writeToFile(name, content)
    else
        local wfile = io.open(fileutil:getWritablePath() .. fileName, "ab+")
        --assert(wfile)
        if wfile then
            wfile:seek("end")
            wfile:write(content)
            wfile:close()
        end
    end
end

function readFromFile(name)
    if name == nil then
        return
    end
    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    local rfile=io.open(fileutil:getWritablePath() .. fileName, "r") 
    assert(rfile) 
    local content = rfile:read("*a")
    rfile:close() 
    return content
end

function readFromBinaryFile(name)
    if name == nil then
        return
    end
    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    local rfile=io.open(fileutil:getWritablePath() .. fileName, "rb") 
    --assert(rfile)
    if rfile then
        local content = rfile:read("*a")
        rfile:close() 
        return content
    end
end

function fileExists(name)
    if not name then return end

    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    if fileutil:isFileExist(fileutil:getWritablePath() .. fileName) then
        return true
    else
        return false
    end
end

function directoryExists(name)
    if not name then return end

    local fileutil = CCFileUtils:sharedFileUtils()
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    if fileutil.isDirectoryExist and fileutil:isDirectoryExist(fileutil:getWritablePath() .. fileName) then
        return true
    else
        return false
    end
end

function createFileDir(fileName)
    local _dirName = nil
    for w in string.gmatch(fileName, "(.-)/") do
        if _dirName == nil then
            _dirName = w
        else
            _dirName = _dirName.."/"..w
        end
        if createSubDirectory(_dirName) == false then
            return false
        end
    end
    return true
end

function createSubDirectory(name)
    local fileName
    if device.platform == "windows" then
        fileName = string.gsub(name, "|", "_")
    else
        fileName = name
    end
    if QUtility.createSubDirectory and QUtility:createSubDirectory(fileName) then
        return true
    else
        return false
    end
end

function listFolderWithFilter(dir, filter, except)
    if QUtility.listFolderWithFilter then
        local fileutil = CCFileUtils:sharedFileUtils()
        local folderPath = fileutil:getWritablePath() .. dir
        local fileList = QUtility:listFolderWithFilter(folderPath, filter, except)

        return fileList
    else
        return ""
    end
end

function zipFile(dir, source, removeIfSucceed)
    if QUtility.zipFile then
        removeIfSucceed = removeIfSucceed or false
        local fileutil = CCFileUtils:sharedFileUtils()
        local folderPath = fileutil:getWritablePath() .. dir
        return QUtility:zipFile(folderPath .. "/" .. source, removeIfSucceed)
    else
        return false
    end
end

function rename(dir, source, dest)
    if QUtility.rename then
        local fileutil = CCFileUtils:sharedFileUtils()
        local folderPath = fileutil:getWritablePath() .. dir
        QUtility:rename(folderPath .. "/" .. source, folderPath .. "/" .. dest)
    end
end

function isChineseStr(str)
    if str == nil then return false end
    local l = string.len(str)
    for i=1,l do
        local asc2=string.byte(string.sub(str,i,i))
        if asc2>127 then
            return true
        end
    end
    return false
end

function QPrintTable( ... )
    local info = debug.getinfo(2, "Sl")
    local lineNumber = info and info.currentline or -1
    local source = info and info.source or ""
    local i1 = string.find(source, "/[^/]*$")
    local i2 = string.find(source, ".[^.]*$")
    info = debug.getinfo(2, "n")
    local callerName = info and info.name or ""
    print("Ln." .. lineNumber .. " " .. string.sub(source, i1+1, i2-1) .. ":" .. callerName)
    printTableWithColor(PRINT_FRONT_COLOR_BLUE, PRINT_BACK_COLOR_YELLOW, ... )
end

function QReplaceEmoji(source, replace)
    if source == nil or string.len(source) == 0 then 
        return source 
    end

    if replace == nil then 
        replace = "?" 
    end

    for _, c in ipairs(emoji) do
        source = string.gsub(source, c, replace)
    end
    
    return source
end


local function recalculateAtIndex(calculation_array, index)
    local last_final_value = 0
    if index > 1 then
        last_final_value = calculation_array[index - 1].final_value
    end
    local obj = calculation_array[index]
    local value
    if obj.operator == "+" then
        value = last_final_value + obj.value
    elseif obj.operator == "*" then
        value = last_final_value * obj.value
    elseif obj.operator == "&" then
        value = obj.value
    else
        assert(false , string.format("Wrong operator %s", tostring(obj.operator)))
    end
    obj.validate2:set(value)
    obj.final_value = value
end

function createActorNumberProperty()
    local return_obj = {}
    local calculation_array = {}
    local stub_table = {}
    local finalValueSetter = nil
    function return_obj:setFinalValueSetter(setter)
        finalValueSetter = setter
    end
    function return_obj:getFinalValue()
        local len = #calculation_array
        if len == 0 then
            return 0
        else
            return calculation_array[len].final_value
        end
    end
    function return_obj:getCount()
        return #calculation_array
    end
    function return_obj:insertValue(stub, operator, value)
        if stub_table[stub] then
            return
        end

        local obj = {operator = operator, value = value, stub = stub, validate = q.createValidation(value), validate2 = q.createValidation()}
        table.insert(calculation_array, obj)
        recalculateAtIndex(calculation_array, #calculation_array)
        stub_table[stub] = #calculation_array
        if finalValueSetter then
            finalValueSetter(self:getFinalValue())
        end
    end
    function return_obj:getValue(stub)
        local index = stub_table[stub]
        if index then
            return calculation_array[index].value
        end
    end
    function return_obj:modifyValue(stub, operator, value)
        local index = stub_table[stub]
        if index then
            local obj = calculation_array[index]
            obj.operator = operator
            obj.validate:set(value)
            obj.value = value
            recalculateAtIndex(calculation_array, index)
            for index2 = index + 1, #calculation_array do
                recalculateAtIndex(calculation_array, index2)
            end
            if finalValueSetter then
                finalValueSetter(self:getFinalValue())
            end
        end
    end
    function return_obj:removeValue(stub)
        local found_index = nil
        for index, obj in ipairs(calculation_array) do
            if obj.stub == stub then
                found_index = index
                stub_table[stub] = nil
                break
            end
        end
        local len = #calculation_array
        if found_index then
            for index = found_index, len do
                if index < len then
                    calculation_array[index] = calculation_array[index + 1]
                    stub_table[calculation_array[index].stub] = index
                    recalculateAtIndex(calculation_array, index)
                else
                    calculation_array[index] = nil
                end
            end
            if finalValueSetter then
                finalValueSetter(self:getFinalValue())
            end
        end
    end
    function return_obj:clear()
        calculation_array = {}
        stub_table = {}
    end
    function return_obj:validate()
        for _, obj in ipairs(calculation_array) do
            obj.validate:validate(obj.value)
            obj.validate2:validate(obj.final_value)
        end 
    end
    function return_obj:getCalculationArray()
        return calculation_array
    end
    return return_obj
end

function QRectMake(x, y, width, height)
    return {origin = {x = x, y = y}, size = {width = width, height = height}}
end

function QCleanNode( node )
    -- body
    local parentNode = tolua.cast(node, "CCNode")
    if parentNode then
        local children = parentNode:getChildren()
        if children then
            for index = 0, children:count()-1, 1 do
                local tempNode = children:objectAtIndex(index)
                QCleanNode(tempNode)
            end
        end
        parentNode:stopAllActions();
        parentNode:unscheduleUpdate();
    end
end

if CCSprite and CCSprite.setDisplayFrame then
    local _setDisplayFrame = CCSprite.setDisplayFrame
    function CCSprite:setDisplayFrame(frame)
        if frame == nil then
            return
        end
        _setDisplayFrame(self, frame)
    end
end

if CCLabelTTF and CCLabelTTF.disableOutline == nil then
    function CCLabelTTF:disableOutline( ... )
    end
end

if CCLabelTTF and CCLabelTTF.setString then
    local _setString = CCLabelTTF.setString
    function CCLabelTTF:setString(str)
        if str == nil then
            return
        end
        _setString(self, str)
    end
end

function TFSetDisableOutline(tf, b)
    if tf and tf.disableOutline then
        tf:disableOutline(b)
    end
end

-- 矩阵相关函数
-- 矩阵初始化
function __QAffineTransformMake(a, b, c, d, tx, ty)
    local t_dic = {}
    t_dic.a, t_dic.b, t_dic.c, t_dic.d, t_dic.tx, t_dic.ty = a, b, c, d, tx, ty
    return t_dic
end

-- 单位矩阵
function QAffineTransformMakeIdentity()
    return __QAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
end

-- 平移矩阵
function QAffineTransformTranslate(t, tx, ty)
    return __QAffineTransformMake(t.a, t.b, t.c, t.d,
        t.tx + t.a * tx + t.c * ty, t.ty + t.b * tx + t.d * ty)
end

-- 旋转矩阵
function QAffineTransformRotate(t, anAngle)
    local fSin = math.sin(anAngle)
    local fCos = math.cos(anAngle)
    return __QAffineTransformMake(t.a * fCos + t.c * fSin,
                                    t.b * fCos + t.d * fSin,
                                    t.c * fCos - t.a * fSin,
                                    t.d * fCos - t.b * fSin,
                                    t.tx,
                                    t.ty)
end

-- 矩阵*矩阵
function QAffineTransformConcat(t1, t2)
    return __QAffineTransformMake(    t1.a * t2.a + t1.b * t2.c, t1.a * t2.b + t1.b * t2.d, --a,b
                                    t1.c * t2.a + t1.d * t2.c, t1.c * t2.b + t1.d * t2.d, --c,d
                                    t1.tx * t2.a + t1.ty * t2.c + t2.tx,                  --tx
                                    t1.tx * t2.b + t1.ty * t2.d + t2.ty);                  --ty
end

-- 点*矩阵
function QPointApplyAffineTransform(point, t)
    local x = t.a * point.x + t.c * point.y + t.tx
    local y = t.b * point.x + t.d * point.y + t.ty
    return qccp(x, y)
end

-- 获取绕point点旋转的旋转矩阵
function QGetRotateMatrix(point, anAngle)
    local unitMatrix = QAffineTransformMakeIdentity() -- 单位矩阵
    local matrix1 = QAffineTransformTranslate(unitMatrix, -point.x, -point.y)
    local matrix2 = QAffineTransformRotate(unitMatrix, anAngle)
    local matrix3 = QAffineTransformTranslate(unitMatrix, point.x, point.y)
    local matrix = QAffineTransformConcat(matrix1, matrix2)
    matrix = QAffineTransformConcat(matrix, matrix3)
    return matrix
end

-- 获取旋转anAngle角度后的矩形
--[[--
@param anAngle CCRect 未旋转矩形
@param anAngle value 旋转角度
--]]--
function QGetRotateRect(rect, anAngle)
    local cx = rect.origin.x + rect.size.width * 0.5
    local cy = rect.origin.y + rect.size.height * 0.5
    local centerPoint = qccp(cx, cy)

    local matrix = QGetRotateMatrix(centerPoint, anAngle)
    local lb = qccp(rect.origin.x, rect.origin.y)
    local lt = qccp(rect.origin.x, rect.size.height+rect.origin.y)
    local rt = qccp(rect.size.width+rect.origin.x, rect.size.height+rect.origin.y)
    local rb = qccp(rect.size.width+rect.origin.x, rect.origin.y)
    lb = QPointApplyAffineTransform(lb, matrix)
    lt = QPointApplyAffineTransform(lt, matrix)
    rt = QPointApplyAffineTransform(rt, matrix)
    rb = QPointApplyAffineTransform(rb, matrix)

    return lb, lt, rt, rb
end

-- 判断旋转后的矩形是否包围point,理论上同样适应未旋转的矩形
--[[--
@param rect CCRect 未旋转的矩形
@param point qccp 需要判断的点
@param anAngle value 旋转角度
--]]--
function QRotateRectContainPoint(rect, anAngle, point)
    local cx = rect.origin.x + rect.size.width * 0.5
    local cy = rect.origin.y + rect.size.height * 0.5
    local centerPoint = qccp(cx, cy)

    local matrix = QGetRotateMatrix(centerPoint, anAngle)
    local rotatePoint = QPointApplyAffineTransform(point, matrix)
    
    local bRet = false
    if rotatePoint.x >= rect.origin.x and
        rotatePoint.x <= rect.origin.x + rect.size.width and
        rotatePoint.y >= rect.origin.y and
        rotatePoint.y <= rect.origin.y + rect.size.height then
        bRet = true
    end

    return bRet;
end

--[[
    主要用于属性数值。
    num：源数据
    isPercent：是否百分比显示。
    decimalCount：小数保留位数
    --isAccurate: 是否需要精确显示（用于整数）
]]
function q.getFilteredNumberToString(num, isPercent, decimalCount, isAccurate)
    local filteredNumToString = ""
    local decimalCount = tonumber(decimalCount)
    if isPercent then
        num = math.floor(num*10000+0.5)/10000
        filteredNumToString = string.format("%."..decimalCount.."f", (num * 100)).."%"
    -- elseif isAccurate and num > floorValue   then
    --     filteredNumToString = string.format("%.1f", num)
    else
        filteredNumToString = tostring(num)
    end

    return filteredNumToString
end

--[[
    设置品质
    @param nodeOwner 品质ccb节点
    @param aptitudeStr 当前品质字符 ss, s,  a+, a,  b,  c
    @param aptitudeNum 当前品质数字 22, 20, 18, 15, 12, 10
]]
function q.setAptitudeShow(nodeOwner, aptitudeStr, aptitudeNum)
    if nodeOwner == nil then return end
    local aptitudeInfo = nil
    for _, value in ipairs(HERO_SABC) do
        local node = nodeOwner["pingzhi_"..value.lower]
        if node then
            node:setVisible(false)
        end
        if aptitudeStr and aptitudeStr == value.lower then
            aptitudeInfo = value
        elseif aptitudeNum and aptitudeNum == value.aptitude then
            aptitudeInfo = value
        end
    end
    
    -- 未找到品质
    if not aptitudeInfo then return end
    if nodeOwner["pingzhi_"..aptitudeInfo.lower] then
        nodeOwner["pingzhi_"..aptitudeInfo.lower]:setVisible(true)
    end
end

--[[
    阿拉伯數字轉羅馬數字 支持1～20
    int：阿拉伯數字
]]
function q.getRomanNumberalsByInt(int)
    local num = tonumber(int)
    if num == 1 then
        return "I"
    elseif num == 2 then
        return "II"
    elseif num == 3 then
        return "III"
    elseif num == 4 then
        return "IV"
    elseif num == 5 then
        return "V"
    elseif num == 6 then
        return "VI"
    elseif num == 7 then
        return "VII"
    elseif num == 8 then
        return "VIII"
    elseif num == 9 then
        return "IX"
    elseif num == 10 then
        return "X"
    elseif num == 11 then
        return "XI"
    elseif num == 12 then
        return "XII"
    elseif num == 13 then
        return "XIII"
    elseif num == 14 then
        return "XIV"
    elseif num == 15 then
        return "XV"
    elseif num == 16 then
        return "XVI"
    elseif num == 17 then
        return "XVII"
    elseif num == 18 then
        return "XVIII"
    elseif num == 19 then
        return "XIX"
    elseif num == 20 then
        return "XX"
    end
    return int
end


--[[
    转换颜色值
    @param color 需要转换的颜色值
    @param isLight 是否亮色
]]
function q.convertColorLightOrGray(color, isLight)
    local colorX = color.r*256*256+color.g*256+color.b
    local convertColor = nil
    for _,v in ipairs(COLOR_CONTRAST) do
        if v.colorLight == colorX and isLight == false then
            convertColor = v.colorDark
            break
        elseif v.colorDark == colorX and isLight == true then
            convertColor = v.colorLight
            break
        end
    end
    if nil ~= convertColor then
        local b = convertColor%256
        local g = (convertColor - color.b)%(256*256)/256
        local r = (convertColor - color.b - color.g)/(256*256)
        return ccc3(r,g,b)
    end
    return color
end

--[[
    截屏
    @param node 需要截屏的父节点
    @param imageName ,图片的保存名称
    @param isSprite , 返回CCSprite,不保存图片
]]
function q.screenShot(node, imageName, isSprite)
    if node == nil then return end

    --the layer is just for excute autorender
    local layer = CCLayer:create()
    node:addChild(layer)

    local render = CCRenderTexture:create(display.width, display.height)
    render:begin()
    node:visit()
    render:endToLua()

    layer:removeFromParent()

    local sprite
    if isSprite then
        sprite = CCSprite:createWithSpriteFrame(render:getSprite():getDisplayFrame())
        sprite:flipY(true)
    else
        render:saveToFile(imageName, kFmtJpg)
        render:onExit()
    end

    return sprite
end


--[[
    将颜色值解析为ccc
    用位运算实现
    支持rgb : #ff0102 返回的是ccc3(255,1,2)
             #f12 = #ff1122 返回的是ccc3(255,17,34)
    rgba : #ff010203 返回 ccc4(255,1,2,3)
           #f123 = #ff112233 返回 ccc4(255,17,34,51)
]]
function q.parseColor(str)
    if string.sub(str,1,1) ~= '#' then return nil end
    local len = string.len(str)
    if len == 7 then
        local r = tonumber(string.sub(str, 2, 3), 16)
        local g = tonumber(string.sub(str, 4, 5), 16)
        local b = tonumber(string.sub(str, 6, 7), 16)
        return ccc3(r,g,b)
    elseif len == 4 then
        local r = tonumber(string.sub(str, 2, 2), 16) * 17
        local g = tonumber(string.sub(str, 3, 3), 16) * 17
        local b = tonumber(string.sub(str, 4, 4), 16) * 17
        return ccc3(r,g,b)
    elseif len == 9 then
        local r = tonumber(string.sub(str, 2, 3), 16)
        local g = tonumber(string.sub(str, 4, 5), 16)
        local b = tonumber(string.sub(str, 6, 7), 16)
        local a = tonumber(string.sub(str, 8, 9), 16)
        return ccc4(r,g,b,a)
    elseif len == 5 then
        local r = tonumber(string.sub(str, 2, 2), 16) * 17
        local g = tonumber(string.sub(str, 3, 3), 16) * 17
        local b = tonumber(string.sub(str, 4, 4), 16) * 17
        local a = tonumber(string.sub(str, 5, 5), 16) * 17
        return ccc4(r,g,b,a)
    end
    return nil
end

function q.cutSprite(nodeMask, sp, spParent, isInverted)
    --切圖
    if not nodeMask or not sp or not spParent then return end

    local isInverted = isInverted or false
    local size = nodeMask:getContentSize()
    local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
    local ccclippingNode = CCClippingNode:create()
    lyImageMask:setPositionX(nodeMask:getPositionX())
    lyImageMask:setPositionY(nodeMask:getPositionY())
    lyImageMask:ignoreAnchorPointForPosition(nodeMask:isIgnoreAnchorPointForPosition())
    lyImageMask:setAnchorPoint(nodeMask:getAnchorPoint())
    ccclippingNode:setStencil(lyImageMask)
    ccclippingNode:setInverted(isInverted)
    sp:retain()
    sp:removeFromParent()
    ccclippingNode:addChild(sp)
    spParent:addChild(ccclippingNode)
    sp:release()
end



--[==[
跟踪一个table的某个键,当键被查询的时候会调用getCallBack,当键被重新赋值的时候会调用setCallBack
这个函数会将这个键从table中移除 所以如果有用到遍历的时候 需要注意 注意 注意！
getCallback参数 table,key,value: 被查询的表,被查询的key,查询到的值
setCallback参数 table,key,value,valueBefore: 被修改的表，被修改的键，被修改的值，修改前的值
--]==]
function QDebugFlowwTable(table, key, getCallback, setCallback)
    local __metatable = getmetatable(table)
    local newmetatable = clone(__metatable)
    local realValue = table[key]
    rawset(table,key,nil)
    newmetatable.__index = function(t,k)
                            if k == key then
                                if getCallback then
                                    getCallback(t,k,realValue)
                                end
                                return realValue
                            end
                            if __metatable.__index then
                                if type(__metatable.__index) == "table" then
                                    return __metatable.__index[k]
                                elseif type(__metatable.__index) == "function" then
                                    return __metatable.__index(t,k)
                                end
                            end
                            return rawget(t,k)
                        end
    newmetatable.__newindex = function(t,k,v)
                            if k == key then
                                if setCallback then
                                    setCallback(t,k,v,realValue)
                                end
                                realValue = v
                                return
                            end
                            if __metatable.__newindex then
                                if type(__metatable.__newindex) == "table" then
                                    __metatable.__newindex[k] = v
                                elseif type(__metatable.__newindex) == "function" then
                                    __metatable.__newindex(t,k,v)
                                end
                            end
                            rawset(t,k,v)
                        end
    setmetatable(table,newmetatable)
end

local _ui_newEditBox = ui.newEditBox
function ui.newEditBox(...)
    local editBox = _ui_newEditBox(...)
    editBox.setText = function(editBox, str)
        getmetatable(editBox).setText(editBox, str)

        if device.platform == "android" or device.platform == "ios" then
            local array = CCArray:create()
            array:addObject(CCDelayTime:create(0))
            array:addObject(CCCallFunc:create(function()
                    getmetatable(editBox).setText(editBox, str)
                end))
            editBox:runAction(CCSequence:create(array))
        end
    end

    if editBox then
        editBox:setReturnType(kKeyboardReturnTypeDone)
    end
    return editBox
end

--[[
    统一设置tab类型按钮
]]
function ui.tabButton(tab, name, fontSize, ap)
    if not tab then return end
    if not name then return end
    local size = fontSize or 22
    local ttflable = CCLabelTTF:create(name, global.font_default, size)
    tab:setTitleLabelForState(ttflable, CCControlStateNormal)
    local ttflable = CCLabelTTF:create(name, global.font_default, size+2)
    tab:setTitleLabelForState(ttflable, CCControlStateHighlighted)
    if ap then
        tab:setLabelAnchorPoint(ap)
    else
        tab:setLabelAnchorPoint(ccp(0.7, 0.5))
    end
    tab:setTitleColorForState(ccc3(235, 174, 114), CCControlStateNormal)
    tab:setTitleColorForState(ccc3(255, 249, 245), CCControlStateHighlighted)
    tab:setTitleColorForState(ccc3(255, 249, 245), CCControlStateDisabled)

    tab:setTitleForState(CCString:create(name), CCControlStateNormal)
    tab:setTitleForState(CCString:create(name), CCControlStateHighlighted)
    tab:setTitleForState(CCString:create(name), CCControlStateDisabled)
end

--[[
    统一管理tab类型按钮
]]

function ui.tabManager(tabArr)
    local tm = {}
    tm.selected = function(self, tab)
        for i,v in ipairs(tabArr) do
            local b = v == tab
            v:setEnabled(not b)
            v:setHighlighted(b)
        end
    end
    return tm
end

function RunActionDelayTime(node, callback, time)
    if node then
        node:stopAllActions()

        local array = CCArray:create()
        array:addObject(CCDelayTime:create(time))
        array:addObject(CCCallFunc:create(function()
                if callback then
                    callback()
                end
            end))
        node:runAction(CCSequence:create(array))
    end
end

-- 字符串里删掉ID
function q.deleteIdFromString(str, id, split)
    if str == nil then
        return nil
    end
    local index = string.find(str, id)
    if not index then
        return str
    end

    local newStr = ""
    split = split or ";"
    -- 是第一个
    if index == 1 then
        local notSingle = string.find(str, split)
        if notSingle then
            newStr = string.gsub(str, id.."[^"..split.."]*"..split, "")
        else
            newStr = nil
        end
    else
        newStr = string.gsub(str, "%"..split..id.."[^"..split.."]*", "")
    end
    return newStr
end

function httpGet(url, timeout)
    if timeout == nil then timeout = 1 end
    local t = {}
    local r, c, h = http.request {
        create=function()
          local req_sock = socket.tcp()
          req_sock:settimeout(timeout, 't')
          return req_sock
          end,
        url = url,
        sink = ltn12.sink.table(t)}
    return table.concat(t)
end

function httpPost(url,param,timeout)
    local respbody = {}
    if timeout == nil then timeout = 1 end
    local result, respcode, respheaders, respstatus = http.request {
        create=function ()
            local t = socket.tcp()
            t:settimeout(timeout, "t")
            return t
        end,
        method = "POST",
        url = url,
        source = ltn12.source.string(param),
        headers = {
            ["content-type"] = "application/x-www-form-urlencoded",
            ["content-length"] = tostring(#param),
            ["Accept-Encoding"] = "gzip",
        },
        sink = ltn12.sink.table(respbody),
        protocol = "tlsv1", -- 协议
    }
    return respbody
end

function httpGetNonsync(url, lisenter, timeout)
    print("httpGetNonsync",url)
    if timeout == nil then timeout = 1 end
    local httpRequest = nil
    local responseFunc = function (data)
        if lisenter then
            lisenter(data)
        end
        httpRequest:release()
    end
    httpRequest = network.createHTTPRequest(responseFunc, url, "GET")
    httpRequest:setTimeout(timeout)
    httpRequest:retain()
    httpRequest:start()
end

function QKumo( tbl, str )
    local info = debug.getinfo(2, "Sl")
    local lineNumber = info and info.currentline or -1
    local source = info and info.source or ""
    local i1 = string.find(source, "/[^/]*$")
    local i2 = string.find(source, ".[^.]*$")
    info = debug.getinfo(2, "n")
    local callerName = info and info.name or ""
    print("Ln." .. lineNumber .. " " .. string.sub(source, i1+1, i2-1) .. ":" .. callerName)
    local prefix = "[Kumo"..(str and ("_"..str) or "").."]"
    printTableWithColor(PRINT_FRONT_COLOR_BLACK, PRINT_BACK_COLOR_RED, tbl, prefix)
end

function SafeAssert( bool, str )
    if DEBUG > 0 then
        assert(bool, str)
    end
end


function CalculateUIBgSize(bgNode, imageWidth)
    if bgNode == nil then return 1 end

    local scale = 1
    local width = imageWidth
    if width == nil then
        width = bgNode:getContentSize().width
    end
    if width < display.width and display.width >= UI_VIEW_MIN_WIDTH then
        scale = display.width / width
        bgNode:setScale(scale)
    end

    return scale
end

function AdaptationUIBgSize(bgNode)
    if bgNode == nil then return 1 end

    local scale = 1
    local width = bgNode:getContentSize().width
    -- local height = bgNode:getContentSize().height
    -- scale = math.max(display.width / width,display.height / height) 
    scale = display.width / width
    bgNode:setScale(scale)
    return scale
end

function CalculateBattleUIPosition(bgNode, isRight)
    if bgNode == nil then return end

    local gapWidth = display.width - display.ui_width
    if isRight then
        gapWidth = - gapWidth
    end
    bgNode:setPositionX(bgNode:getPositionX() + gapWidth/2)
end

function q.PropPercentHanderFun(value)
    if value ~= nil then
        value = value * 100
        local _,pos1 = string.find(value,"[(0-9)]*.")
        local pos2 = string.len(tostring(value))
        pos1 = pos1 or 0
        pos2 = pos2 or 1
        local f = pos2-pos1
        if f < 1 then
            f = 1
        elseif f > 1 then
            f = 2
        end
        return string.format("%0."..f.."f%%", value)
    end

    return value
end

--截取中英混合的UTF8字符串，endIndex可缺省
function q.SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = q.SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = q.SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, q.SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, q.SubStringGetTrueIndex(str, startIndex), q.SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function q.SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = q.SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function q.SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = q.SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function q.SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

-- 添加砸星星动画效果 By Kumo
function q.addHitTheStarsEffect(node, initScale, initOpacity, callback)
    if not node then 
        if callback then
            callback()
        end
        return 
    end

    local actionInArray = CCArray:create()
    actionInArray:addObject(CCFadeTo:create(0.03, 120))
    actionInArray:addObject(CCFadeTo:create(0.13, 255))

    local actionScaleArray = CCArray:create()
    actionScaleArray:addObject(CCDelayTime:create(0.03))
    actionScaleArray:addObject(CCScaleTo:create(0.13, 0.95))
    actionScaleArray:addObject(CCScaleTo:create(0.16, 1))

    local actionAnimationArray = CCArray:create()
    actionAnimationArray:addObject(CCSequence:create(actionInArray))
    actionAnimationArray:addObject(CCSequence:create(actionScaleArray))

    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(0.5))
    actionArray:addObject(CCSpawn:create(actionAnimationArray))
    actionArray:addObject(CCCallFunc:create(function() 
        if callback then
            callback()
        end
    end))
    node:setScale(initScale or 7)
    node:setOpacity(initOpacity or 0)
    node:setVisible(true)
    node:runAction(CCSequence:create(actionArray))
end

--动态属性创建
function q.createPropTextNode( name,value,isGreen,fontSize,grap)
    local tfNode = CCNode:create()
    local offersetX = grap or 5
    local tfName = CCLabelTTF:create(name, global.font_default, fontSize)
    tfName:setAnchorPoint(ccp(0, 0.5))
    tfName:setColor(COLORS.j)
    tfName:setPositionX(0)
    tfNode:addChild(tfName)
    local tfValue = CCLabelTTF:create("+"..value, global.font_default, fontSize)
    tfValue:setAnchorPoint(ccp(0, 0.5))
    tfValue:setColor(isGreen and COLORS.l or COLORS.j)
    tfValue:setPositionX(tfName:getContentSize().width + offersetX)
    tfNode:addChild(tfValue)
    return tfNode
end