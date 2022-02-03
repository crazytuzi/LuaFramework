--[[
    @自定义事件类型
]]

--用于唯一标识obj的table
_inner_event_connection_obj = _inner_event_connection_obj or {}

CustomEvent = CustomEvent or BaseClass()

function CustomEvent:__init(event_id)
    self.event_id = event_id
    self.bind_id_count = 0
    self.event_func_list = {}
end

function CustomEvent:Fire(arg_table)
    for _, func in pairs(self.event_func_list) do
        func(unpack(arg_table))
    end
end

function CustomEvent:UnBind(obj)
    --仅当obj符合类型时才作对应操作
    if getmetatable(obj) == _inner_event_connection_obj and obj.event_id == self.event_id then
        self.event_func_list[obj.bind_id] = nil
    end
end

function CustomEvent:Bind(event_func)
    self.bind_id_count = self.bind_id_count + 1
    local obj = {}
    setmetatable(obj, _inner_event_connection_obj)
    obj.event_id = self.event_id
    obj.bind_id = self.bind_id_count
    self.event_func_list[obj.bind_id] = event_func
    return obj
end

--利用ID分离对EventSystem的直接引用
_inner_event_system_list = _inner_event_system_list or {}
_inner_event_system_id_count = _inner_event_system_id_count or 0

EventSystem = EventSystem or BaseClass()
--事件系统(非单健)
function EventSystem:__init()
    _inner_event_system_id_count = _inner_event_system_id_count + 1
    self.system_id = _inner_event_system_id_count
    _inner_event_system_list[self.system_id] = self

    --需要激发的事件(延后调用方式)
    self.need_fire_events = List.New()

    --事件列表
    self.event_list = {}

    self.delay_handle_list = {}

    self.delay_id_count = 0

    self.is_deleted = false
end

--调用已经处于派发队列中的Event
function EventSystem:Update()
    --依次执行所有需要触发的事件
    while not List.Empty(self.need_fire_events) do
        local fire_info = List.PopFront(self.need_fire_events)
        fire_info.event:Fire(fire_info.arg_list)
    end
end

function EventSystem:Bind(event_id, event_func)
    if event_id == nil then
        print(debug.traceback())
        error("Try to bind to a nil event_id")
        return
    end
    if self.is_deleted then return end
    if self.event_list[event_id] == nil then
        self:CreateEvent(event_id)
    end
    local tmp_event = self.event_list[event_id]    
    return tmp_event:Bind(event_func)
end

function EventSystem:UnBind(event_handle)
    if event_handle == nil or event_handle.event_id == nil then
        error("Try to unbind a nil event_id")
        return
    end

    if self.is_deleted then return end

    local tmp_event = self.event_list[event_handle.event_id]
    if tmp_event ~= nil then
        tmp_event:UnBind(event_handle)
    end
end

--立即触发
function EventSystem:Fire(event_id, ...)
    if event_id == nil then
        error("Try to call EventSystem:Fire() with a nil event_id")
        return
    end

    if self.is_deleted then return end
    
    local tmp_event = self.event_list[event_id] 
    if tmp_event ~= nil then
        tmp_event:Fire({...})
    end
end

--下一帧触发
function EventSystem:FireNextFrame(event_id, ...)
    if event_id == nil then
        error("Try to call EventSystem:FireNextFrame() with a nil event_id")
        return
    end

    if self.is_deleted then return end

    local tmp_event = self.event_list[event_id] 
    if tmp_event ~= nil then
        local fire_info = {}
        fire_info.event = tmp_event
        fire_info.arg_list = {...}
        List.PushBack(self.need_fire_events, fire_info)
    end
end

function EventSystem:CreateEvent(event_id)
    self.event_list[event_id] = CustomEvent.New(event_id)
end

function EventSystem:__delete()
    if not self.is_deleted then
        _inner_event_system_list[self.system_id] = nil
        self.is_deleted = true
    end
end


--用于唯一标识obj的table
EventDispatcher = EventDispatcher or BaseClass()
function EventDispatcher:__init()
    self.eventSys=EventSystem.New()
end

function EventDispatcher:Bind(type_str, listener_func)
    return self.eventSys:Bind(type_str,listener_func);
end
function EventDispatcher:UnBind(obj)
    self.eventSys:UnBind(obj);
end
function EventDispatcher:Fire(type_str, ...)
    self.eventSys:Fire(type_str, ...)
end