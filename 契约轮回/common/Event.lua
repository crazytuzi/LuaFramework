--[[
Auth:Chiuan
like Unity Brocast Event System in lua.
]]

Event = class("Event")

local Event = Event
Event.ID = 0

function Event:ctor()
    self.event_count = 0
    self.events = {}
    self.events_map = {}

    self.lock_state_list = {}
    self.lock_add_list = {}
    self.lock_del_list = {}
end

function Event:dctor()
    self:RemoveAll()

    self.event_count = 0
    self.events = {}
    self.events_map = {}

    self.lock_state_list = nil
    self.lock_add_list = nil
    self.lock_del_list = nil
end

function Event:AddListener(event, handler)
    -- if BagEvent.LoadItemByBagId == event then
    -- 	print('--LaoY Event.lua,line 19-- data=',data)
    -- end
    if not event then
        error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.event_name is "..event)
    end
    if not handler or type(handler) ~= "function" then
        error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
    end

    if not self.events[event] then
        self.events[event] = {}
    end

    self.event_count = self.event_count + 1
    Event.ID = Event.ID + 1
    if self.lock_state_list[event] then
        self.lock_add_list[event] = self.lock_add_list[event] or {}
        self.lock_add_list[event][#self.lock_add_list[event] + 1] = { id = Event.ID, event = event, handler = handler }
        return Event.ID
    end
    self.events[event][Event.ID] = handler
    self.events_map[Event.ID] = event
    return Event.ID
end

function Event:Brocast(event, ...)
    if not self.events[event] then
        -- error("brocast " .. event .. " has no event.")
    else
        if not self.time_brocast_list or not self.time_brocast_list[event] then
            -- local event_list = clone(self.events[event])
            local event_list = self.events[event]

            self.lock_state_list[event] = true
            for event_id, func in pairs(event_list) do
                if not self.lock_del_list[event] or not self.lock_del_list[event][event_id] then
                    func(...)
                end
            end
            self.lock_state_list[event] = false
            self:CheckLockList(event)
        else
            local param = { ... }
            local function callback()
                -- local event_list = clone(self.events[event])
                self.lock_state_list[event] = true
                local event_list = self.events[event]
                for event_id, func in pairs(event_list) do
                    if not self.lock_del_list[event] or not self.lock_del_list[event][event_id] then
                        func(unpack(param))
                    end
                end
                self.lock_state_list[event] = false
                self:CheckLockList(event)
            end
            EventManager:GetInstance():TimeBrocast(event, callback)
        end
    end
end

function Event:CheckLockList(event)
    if not table.isempty(self.lock_add_list[event]) then
        local len = #self.lock_add_list[event]
        for i = 1, len do
            local tab = self.lock_add_list[event][i]
            self.events[tab.event][tab.id] = tab.handler
            self.events_map[tab.id] = tab.event
        end

        self.lock_add_list[event] = nil
        -- for k,v in pairs(self.lock_add_list[event]) do
        -- 	self.lock_add_list[event][k] = nil
        -- end
    end

    if not table.isempty(self.lock_del_list[event]) then
        -- local len = #self.lock_del_list[event]
        -- for i=1,len do
        -- 	local event_id = self.lock_del_list[event][i]
        -- 	self:RemoveListener(event_id)
        -- 	self.events_map[event_id] = nil
        -- end
        for event_id, v in pairs(self.lock_del_list[event]) do
            self:RemoveListener(event_id)
        end
        self.lock_del_list[event] = nil
        -- for k,v in pairs(self.lock_del_list[event]) do
        -- 	self.lock_del_list[event][k] = nil
        -- end
    end
end

function Event:RemoveListener(event_id)
    local event = self.events_map[event_id]
    if self.lock_state_list[event] then
        self.lock_del_list[event] = self.lock_del_list[event] or {}
        -- self.lock_del_list[event][#self.lock_del_list[event]+1] = event_id
        self.lock_del_list[event][event_id] = true
        return
    end
    if self.events[event] and self.events[event][event_id] then
        self.events[event][event_id] = nil
        self.event_count = self.event_count - 1
    end
    self.events_map[event_id] = nil
end

function Event:RemoveTabListener(tab)
    for k, v in pairs(tab) do
        self:RemoveListener(v);
    end
end

function Event:AddTimeBrocast(event, time)
    self.time_brocast_list = self.time_brocast_list or {}
    self.time_brocast_list[event] = time
    EventManager:GetInstance():SetEventIntervalTime(event, time)
end

function Event:RemoveAll()
    self.event_count = 0
    self.events = {}
    self.events_map = {}
end