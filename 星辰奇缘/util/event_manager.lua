-- 事件系统

EventLib = EventLib or BaseClass()
function EventLib:__init(EventName)
    self.handlers = {}
    self.args = nil
    self.EventName = EventName or "<Unknown Event>"
end

function EventLib:AddListener(handler)
    self:Add(handler)
end
function EventLib:Add(handler)
     if EventCountManager.Instance ~= nil then
        EventCountManager.Instance:AddCount(1)
    end
    assert(type(handler) == "function", "非法事件")
    table.insert(self.handlers, handler)
end

function EventLib:RemoveListener(handler)
    self:Remove(handler)
end
function EventLib:Remove(handler)
    -- assert(type(handler) == "function", "非法事件")
    if not handler then
        EventCountManager.Instance:ReleseCount(#self.handlers)
        self.handlers = {}
    else
        for k, v in pairs(self.handlers) do
            if v == handler then
                self.handlers[k] = nil
                EventCountManager.Instance:ReleseCount(1)
                return k
            end
        end
    end
end

function EventLib:RemoveAll()
    self:Remove()
end

-- 应该只有一个主线程，就不考虑多线程问题了
function EventLib:Fire(...)
    self.args = {...}
    local funcList = {}
    for k, v in pairs(self.handlers) do
        table.insert(funcList, v)
    end
    for _, func in ipairs(funcList) do
        if EventCountManager.Instance.onTick == false then
            EventCountManager.Instance.onTick = true
            EventCountManager.Instance:FireCount(1)
            EventCountManager.Instance.nowTime = BaseUtils.BASE_TIME
        end

        if BaseUtils.BASE_TIME - EventCountManager.Instance.nowTime < 2 and EventCountManager.Instance.onTick == true then
            EventCountManager.Instance:FireCount(1)
        else
            EventCountManager.Instance.onTick = false
            EventCountManager.Instance.nowTime = 0
            EventCountManager.Instance.nowTimeEvent = 0
        end

        -- func(...)
        local call = function() func(unpack(self.args)) end
        local status, err = xpcall(call, function(errinfo)
            Log.Error("EventLib:Fire出错了[" .. self.EventName .. "]:" .. tostring(errinfo)); Log.Error(debug.traceback())
        end)
    end
    funcList = nil
    self.args = nil
end

function EventLib:Destroy()
    self:RemoveAll()
    for k, v in pairs(self) do
        self[k] = nil
    end
end

function EventLib:__delete()
    self:Destroy()
end

-- UnityEvent.RemoveListener在某些情况下不起作用
-- 所以增加了该方式，handler为lua function
EventMgr = EventMgr or BaseClass()
function EventMgr:__init()
    EventMgr.Instance = self
    self.events = {}
end

function EventMgr:AddListener(event, handler)
    if not event or type(event) ~= "string" then
        Log.Error("事件名要为字符串")
    end

    if not handler or type(handler) ~= "function" then
        Log.Error("handler为是一个函数,事件名:"..event)
    end

    if not self.events[event] then
        self.events[event] = EventLib.New(event)
    end
    self.events[event]:Add(handler)
end

function EventMgr:RemoveListener(event, handler)
    if self.events[event] then
        self.events[event]:Remove(handler)
    end
end
function EventMgr:RemoveAllListener(event)
    if self.events[event] then
        self.events[event]:RemoveAll()
    end
end

function EventMgr:Fire(event, ...)
    if self.events[event] then
        local args = {...}
        local call = function() self.events[event]:Fire(unpack(args)) end
        local status, err = xpcall(call, function(errinfo)
            Log.Error("EventMgr:Fire出错了[" .. event .. "]:" .. tostring(errinfo)); Log.Error(debug.traceback())
        end)
        if not status then
            Log.Error("EventMgr:Fire出错了" .. tostring(err))
        end
    end
end
