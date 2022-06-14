--wz
scheduler = {}

local instance = GameClient.Scheduler:Instance()

function scheduler.scheduleUpdateGlobal(listener)    
    local handler = instance:scheduleScriptFunc(listener, 0, false)
		--print("scheduler.scheduleUpdateGlobal  handler  "..handler);
		return handler;
end

function scheduler.scheduleGlobal(listener, interval)
    return instance:scheduleScriptFunc(listener, interval, false)
end

function scheduler.unscheduleGlobal(handle)
    --print("scheduler.unscheduleGlobal  handler  "..handle);
    instance:unscheduleScriptEntry(handle)
end

function scheduler.performWithDelayGlobal(listener, time, params)
    local handle
    handle = instance:scheduleScriptFunc(function()
        scheduler.unscheduleGlobal(handle)
        listener(params)
    end, time, false)
end
