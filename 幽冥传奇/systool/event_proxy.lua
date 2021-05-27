
EventProxy = EventProxy or BaseClass()

function EventProxy:__init(dispatcher, obj)
    self.dispatcher = dispatcher
    self.handles = {}

    self.remove_all_listen_h = nil
    if obj and obj.AddEventListener then
        self.remove_all_listen_h = obj:AddEventListener(GameObjEvent.REMOVE_ALL_LISTEN, function()
            obj:RemoveEventListener(self.remove_all_listen_h)
            self:DeleteMe()
        end)
    end
end

function EventProxy:__delete()
    self:RemoveAllEventListeners()
    self.handles = {}
    self.dispatcher = nil
    self.remove_all_listen_h = nil
end

function EventProxy:AddEventListener(event_name, listener)
    local handle = self.dispatcher:AddEventListener(event_name, listener)
    self.handles[handle] = handle
    return handle
end

function EventProxy:RemoveEventListener(handle)
    self.dispatcher:RemoveEventListener(handle)
    self.handles[handle] = nil
end

function EventProxy:RemoveAllEventListeners()
    for _, handle in pairs(self.handles) do
        self.dispatcher:RemoveEventListener(handle)
    end
    self.handles = {}
end
