-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/7/25
-- Time: 16:50
-- 文件功能：用于时间定时的作用

GlobalTimeTicket = GlobalTimeTicket or {}

-- 获取单例
-- New和不New只是一层一层调用__init和__delete，对于单例没有影响
function GlobalTimeTicket:getInstance()
    if not self.is_init then 
        self.scheduler = cc.Director:getInstance():getScheduler()
        self.schedulers = {}
        self.is_init = true
        self.is_stop = nil
    end
    return self
end

-- 定时回调 通用版
-- call_back : function     回调函数    必填
-- interval  : int          时间间隔    默认1 秒
-- limit_time: int          限制次数    默认0 无限
-- with_name : any          定时器标识  默认自增id
-- 返回用于删除的标识
-- simple    : local id = GlobalTimeTicket:getInstance():add(fun) ; GlobalTimeTicket:getInstance():remove(id)
--           : GlobalTimeTicket:getInstance():add(fun, 0.1, 1)              -- 次数达到自动删除
--           : GlobalTimeTicket:getInstance():add(fun, 0.1, 3, "name")      
function GlobalTimeTicket:add(call_back, interval, limit_time, with_name)
    if self.is_stop then return end
    with_name = with_name or autoId()
    if nil == call_back or self.schedulers == nil or nil ~= self.schedulers[with_name] then return end    -- 已经有定义了，不能重复

    limit_time = limit_time or 0
    interval = interval or 1
    local schedul_hander = self.scheduler:scheduleScriptFunc(function(dt)
        if self.is_stop then return end
        if call_back ~= nil then
            if limit_time == 1 then 
                self:remove(with_name)
            elseif limit_time > 1 then 
                limit_time = limit_time - 1
            end
            call_back(dt)
        end
    end, interval, false)
    self.schedulers[with_name] = schedul_hander
    return with_name
end

-- 删除一个定时器
function GlobalTimeTicket:remove(with_name)
    if with_name == nil then return end
    local schedul_hander = self.schedulers[with_name] 
    if schedul_hander ~= nil then
        self.scheduler:unscheduleScriptEntry(schedul_hander)
        self.schedulers[with_name] = nil 
    end
end

-- 清除所有定时器
function GlobalTimeTicket:removeAll()
    for _, v in pairs(self.schedulers) do 
        self.scheduler:unscheduleScriptEntry(v)
    end
    self.schedulers = {}
end

function GlobalTimeTicket:hasTicket(with_name)
    local schedul_hander = self.schedulers[with_name] 
    if schedul_hander ~= nil then
        return true
    end
    return false
end

function GlobalTimeTicket:getSchedulers()
    return self.schedulers
end

-- 停止定时器
function GlobalTimeTicket:stop()
    self.is_stop = true
    self:removeAll()
    self.is_init = false
end

