local Scheduler = classGc(function ( self )
    self.m_lpScheduler = cc.Director:getInstance():getScheduler()
    self.m_handleList  = {}
end)

function Scheduler.enterFrame( self, listener, isPaused )
    --每帧回调
    local handle = self.m_lpScheduler:scheduleScriptFunc(listener, 0, isPaused or false)
    self.m_handleList[handle] = handle
    return handle
end

function Scheduler.schedule(self, listener, interval, isPaused)
    --间隔多少回调  
    --listener 函数   
    --interval 间隔   
    --isPaused 是否暂停???
    --返回一个 handle
    --local handle = self.m_lpScheduler:
    local handle = self.m_lpScheduler:scheduleScriptFunc(listener, interval, isPaused or false)
    self.m_handleList[handle] = handle
    return handle
end

function Scheduler.unschedule( self, handle )
    --解除回调
    if handle==nil then return end
    self.m_handleList[handle] = nil
    self.m_lpScheduler:unscheduleScriptEntry( handle )
end

function Scheduler.unAllschedule( self )
    --解除所有回调
    for _,handle in pairs(self.m_handleList) do
        self.m_lpScheduler:unscheduleScriptEntry( handle )
    end
    self.m_handleList={}
end

function Scheduler.performWithDelay(self, time, listener)
    --以time时间回调一次  仅此一次
    local handle = nil
    local function unscheduleEntry()
        self.m_handleList[handle] = nil
        if handle ~= nil then
            self.m_lpScheduler:unscheduleScriptEntry(handle)
            handle = nil
        end
        listener()
    end
    handle          = self.m_lpScheduler:scheduleScriptFunc(unscheduleEntry, time, false)
    unscheduleEntry = nil
    self.m_handleList[handle] = handle
    return handle
end

return Scheduler
