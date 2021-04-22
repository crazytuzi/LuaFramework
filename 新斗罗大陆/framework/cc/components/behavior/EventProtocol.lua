
local Component = import("..Component")
local EventProtocol = class("EventProtocol", Component)

function EventProtocol:ctor()
    EventProtocol.super.ctor(self, "EventProtocol")
    self.listeners_ = {}
    self.nextListenerHandleIndex_ = 0
    self.listenersIndex_ = {}
end

function EventProtocol:addEventListener(eventName, listener, tag)
    eventName = string.upper(eventName)
    if self.listeners_[eventName] == nil then
        self.listeners_[eventName] = {}
    end

    self.nextListenerHandleIndex_ = self.nextListenerHandleIndex_ + 1
    local handle = tostring(self.nextListenerHandleIndex_)
    tag = tag or ""
    self.listeners_[eventName][#self.listeners_[eventName] + 1] = {listener, tag, handle}

    return handle
end

function EventProtocol:dispatchEvent(event)
    event.name = string.upper(tostring(event.name))
    local eventName = event.name

    if self.listeners_[eventName] == nil then return end
        event.target = self.target_
        event.stop_ = false
        event.stop = function(self)
        self.stop_ = true
    end

    local listeners = {}
    for _, listener in ipairs(self.listeners_[eventName]) do
        listeners[#listeners + 1] = listener
    end
    for index, listener in ipairs(listeners) do
        listener[1](event)
        if event.stop_ then
            break
        end
    end

    return self.target_
end

function EventProtocol:removeEventListener(handleToRemove, key1, key2)
    if key2 then
        return self.target_
    elseif key1 then
        handleToRemove = key1
    end

    for eventName, listenersForEvent in pairs(self.listeners_) do
        for index, listener in ipairs(listenersForEvent) do
            if listener[3] == handleToRemove then
                table.remove(listenersForEvent, index)
                return self.target_
            end
        end
    end

    return self.target_
end

function EventProtocol:removeEventListenersByTag(tagToRemove)
    for eventName, listenersForEvent in pairs(self.listeners_) do
        while true do
            local findOne = false
            for index, listener in ipairs(listenersForEvent) do
                if listener[2] == tagToRemove then
                    table.remove(listenersForEvent, index)
                    break
                end
            end
            if not findOne then
                break
            end
        end
    end

    return self.target_
end

function EventProtocol:removeEventListenersByEvent(eventName)
    self.listeners_[string.upper(eventName)] = nil
    return self.target_
end

function EventProtocol:removeAllEventListenersForEvent(eventName)
    return self:removeEventListenersByEvent(eventName)
end

function EventProtocol:removeAllEventListeners()
    self.listeners_ = {}
    return self.target_
end

function EventProtocol:hasEventListener(eventName)
    event.name = string.upper(tostring(eventName))
    local t = self.listeners_[eventName]
    for _, __ in ipairs(t) do
        return true
    end
    return false
end

function EventProtocol:dumpAllEventListeners()
    
end

function EventProtocol:exportMethods()
    self:exportMethods_({
        "addEventListener",
        "dispatchEvent",
        "removeEventListener",
        "removeEventListenersByTag",
        "removeEventListenersByEvent",
        "removeAllEventListenersForEvent",
        "removeAllEventListeners",
        "hasEventListener",
        "dumpAllEventListeners",
    })
    return self.target_
end

function EventProtocol:onBind_()
end

function EventProtocol:onUnbind_()
end

return EventProtocol
