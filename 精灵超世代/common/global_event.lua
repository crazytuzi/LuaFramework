--[[
    @自定义事件派发机制
]]
GlobalEvent = GlobalEvent or BaseClass()

-- 获取单例
-- New和不New只是一层一层调用__init和__delete，对于单例没有影响
function GlobalEvent:getInstance()
    if not self.is_init then 
        --事件列表
        self.event_list = {}
        self.is_deleted = false
        self.is_init = true 
    end
    return self
end

function GlobalEvent:Bind(event_id, event_func)
    if event_id == nil then
        print(debug.traceback())
        error("Try to bind to a nil event_id")
        return
    end
    if self.is_deleted then
        return
    end
    if self.event_list[event_id] == nil then
        self:CreateEvent(event_id)
    end
    local tmp_event = self.event_list[event_id]
    return tmp_event:Bind(event_func)
end

function GlobalEvent:CreateEvent(event_id) 
    self.event_list[event_id] = CustomEvent.New(event_id)
end

function GlobalEvent:UnBind(event_handle)
    if event_handle == nil or event_handle.event_id == nil then
        error("Try to unbind a nil event_id")
        return
    end
    if self.is_deleted then
        return
    end
    local tmp_event = self.event_list[event_handle.event_id]
    if tmp_event ~= nil then
        tmp_event:UnBind(event_handle)
    end
end

function GlobalEvent:UnBindAll()
    for k,event_handle in pairs(self.event_list) do
        local tmp_event = self.event_list[event_handle.event_id] 
        if tmp_event ~= nil then
            tmp_event:UnBind(event_handle)
        end
        event_handle = nil
    end
end

function GlobalEvent:UnBindMacro(event_handle)
    if event_handle then
        self:UnBind(event_handle)
		event_handle = nil
    end
end

--立即触发
function GlobalEvent:Fire(event_id, ...)
    if event_id == nil then
        print(debug.traceback())
        error("Try to call Event:Fire() with a nil event_id")
        return
    end
    if self.is_deleted then
        return
    end
    local tmp_event = self.event_list[event_id]
    if tmp_event ~= nil then
        tmp_event:Fire({...})
    end
end

function GlobalEvent:__delete()
    if not self.is_deleted then
        self.is_deleted = true
    end

    self.is_init = false
end