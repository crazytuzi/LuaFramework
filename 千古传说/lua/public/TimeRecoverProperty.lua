
--[[
    倒计时

    --By: haidong.gan
    --2013/12/02
]]



--获得某时间距离当前时间的间隔描述（秒）
function getTimeString(time)
    local timeStr = "";
    if (time < 0) then
        timeStr = "错误时间：" .. time;

    elseif (time < 60) then
        timeStr = "刚刚";
    elseif (time < 3600) then
        --分钟
        timeStr = math.floor(time/ 60) .. "分钟前";
    elseif (time < 24 * 3600) then
        --小时
        timeStr = math.floor(time/ 3600) .. "小时前";
    else
        --天
        timeStr = math.floor(time/ (3600 * 24)) .. "天前";
    end
    return timeStr;
end


--[[
--用法举例
    1、在生命值、体力回复等地方使用
       说明：总回复时间需要1000秒，现在已经过了200秒，每20秒回复一点。
       方法：最大值：1000/20=500，当前值：200/20=100.
    TimeRecoverProperty:create(1000,200,20);


    2、简单用法：倒计时120秒钟
    TimeRecoverProperty:create(120,0,1);

]]
local function getTimeStrForNum(num)
    if num < 10 then
        return "0" .. tostring(num);
    end
    return tostring(num);
end

local TimeRecoverProperty = class("TimeRecoverProperty");


--[[--
    倒计时
    @param maxRecoverTime: 倒计时最大时间
    @param curRecoverTime: 倒计时开始时间
    @param timeToValuePercent: 每多少秒，计数一次
]]  
function TimeRecoverProperty:create(maxRecoverTime, curRecoverTime, timeToValuePercent)
    local timeRecoverProperty = TimeRecoverProperty:new(maxRecoverTime, curRecoverTime, timeToValuePercent);
    return timeRecoverProperty;
end

function TimeRecoverProperty:ctor(maxRecoverTime, curRecoverTime, timeToValuePercent)
    self.maxRecoverTime = maxRecoverTime;
    self.curRecoverTime = curRecoverTime;
    self.timeToValuePercent = timeToValuePercent;

    if self.timeToValuePercent == nil or self.timeToValuePercent == 0 then
        self.timeToValuePercent = 1;
    end

    self.createTime = os.time();
end

--[[--
    倒计时结束时得到的最大值
]]  
function TimeRecoverProperty:getMaxValue()
    return  math.floor(self.maxRecoverTime / self.timeToValuePercent);
end

--[[--
    倒计时当前对应的值
]]  
function TimeRecoverProperty:getCurValue()

    if (self.curRecoverTime > self.maxRecoverTime) then
        return  math.floor(self.curRecoverTime / self.timeToValuePercent);
    elseif (self.curRecoverTime + self:getSubTime() > self.maxRecoverTime) then
        return self:getMaxValue();
    else
        return math.floor((self.curRecoverTime + self:getSubTime()) / self.timeToValuePercent);
    end
end

--距离最大值剩余时间（秒）
function TimeRecoverProperty:getRemainRecoverTime()
    local remainTime = self.maxRecoverTime - self:getSubTime() - self.curRecoverTime;
    if remainTime > 0 then
        return remainTime;
        else
        return 0;
    end
end

--距离倒计时剩余时间（28号字体字符串）
function TimeRecoverProperty:getRemainRecoverTimeFntString()
    local second = self:getRemainRecoverTime();
    local hour =  math.floor(second / 3600);
    local minute =  math.floor((second % 3600) / 60);
    second = math.floor(second % 60);

    return getTimeStrForNum(hour) .."h".. getTimeStrForNum(minute) .."h".. getTimeStrForNum(second);
end

--距离倒计时剩余时间（字符串）
function TimeRecoverProperty:getRemainRecoverTimeString()
    local second = self:getRemainRecoverTime();
    local hour =  math.floor(second / 3600);
    local minute =  math.floor((second % 3600) / 60);
    second = math.floor(second % 60);
    
    return getTimeStrForNum(hour) ..":".. getTimeStrForNum(minute) ..":".. getTimeStrForNum(second);
end

--距离下一个计数点剩余时间（秒）
function TimeRecoverProperty:getOneRecoverTime()
    local remainTime = self:getRemainRecoverTime() % self.timeToValuePercent;
    if remainTime > 0 then
        return remainTime;
        else
        return 0;
    end
end
--距离下一个计数点剩余时间（28号字体字符串）
function TimeRecoverProperty:getOneRecoverTimeFntString()
    local second = self:getOneRecoverTime();
    local hour =  math.floor(second / 3600);
    local minute =  math.floor((second % 3600) / 60);
    second = math.floor(second % 60);
    
    return getTimeStrForNum(hour) .."h".. getTimeStrForNum(minute) .."h".. getTimeStrForNum(second)
end

--距离下一个计数点剩余时间（字符串）
function TimeRecoverProperty:getOneRecoverTimeString()
    local second = self:getOneRecoverTime();
    local hour =  math.floor(second / 3600);
    local minute =  math.floor((second % 3600) / 60);
    second =  math.floor(second % 60);

    if hour == 0 then
        return getTimeStrForNum(minute) ..":".. getTimeStrForNum(second)
    else
        return getTimeStrForNum(hour) ..":".. getTimeStrForNum(minute) ..":".. getTimeStrForNum(second)
    end
end
--距离下一个计数点剩余时间（字符串）
function TimeRecoverProperty:getOneRecoverTimeStringOutHour()
    local second = self:getOneRecoverTime();
    local minute =  math.floor(second  / 60);
    second =  math.floor(second % 60);
    
    return getTimeStrForNum(minute) ..":".. getTimeStrForNum(second)
end

--数据从保存至今，过去了多少时间（秒）
function TimeRecoverProperty:getSubTime()
    return os.time() - self.createTime ;
end 

return TimeRecoverProperty;