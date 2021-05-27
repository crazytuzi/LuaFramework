EventProtocol = EventProtocol or BaseClass(Component)

function EventProtocol:__init()
    self.event_list = {}
end

function EventProtocol:__delete()
end

function EventProtocol:AddEventListener(event_name, listener)
    if event_name == nil then
        ErrorLog("Try to bind to a nil event_name")
        return
    end

    if self.event_list[event_name] == nil then
        self.event_list[event_name] = Event.New(event_name)
    end
    return self.event_list[event_name]:Bind(listener)
end

function EventProtocol:DispatchEvent(event_name, ...)
    local start_time = os.time()
    if self.event_list[event_name] == nil then return end

    for _, func in pairs(self.event_list[event_name].event_func_list) do
        func(...)
        if os.time() - start_time >= 2 then
            print("EventProtocol------------>事件派发卡顿", event_name, "  time: ", os.time() - start_time) 
        end
    end
end

function EventProtocol:RemoveEventListener(event_handle)
    if event_handle == nil or event_handle.event_id == nil then
        ErrorLog("Try to remove a nil event_handle")
        return
    end

    local tmp_event = self.event_list[event_handle.event_id]
    if tmp_event ~= nil then
        tmp_event:UnBind(event_handle)
    end
end

function EventProtocol:RemoveAllEventlist()
    self.event_list = {}
end

function EventProtocol:ExportMethods()
    self:ExportMethods_({
        "AddEventListener",
        "DispatchEvent",
        "RemoveEventListener",
        "RemoveAllEventlist",
    })
end
