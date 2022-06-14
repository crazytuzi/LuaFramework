-- wangzhen create  04.21.2014 @beijing

eventManager = {}
 

eventManager.debug_ = false
eventManager.listeners_ = {}

 

--------------
function eventManager.addEventLister(eventName, listener,data)

      assert( eventName ~= nil,
        "eventManager:addEventLister() - invalid eventName")    
    
    local eventName = string.upper(eventName)
    if eventManager.listeners_[eventName] == nil then
        eventManager.listeners_[eventName] = {}
    end         
     
    local handle = table.nums(eventManager.listeners_[eventName])
    eventManager.listeners_[eventName][handle] = {listener,data}
    
    if eventManager.debug_ then    
        echoInfo("eventManager:addEventLister() - add listener [%s] %s for event %s", handle, tostring(listener), eventName)        
    end     
    return handle
end 

---{name = "logoshow",""}
function eventManager.dispatchEvent(event)
  
  assert(event.name ~= nil,
         "eventManager:dispatchEvent() - invalid eventKey"..(event.name))       
 
 	print("eventManager.dispatchEvent(event)  "..event.name);
 
    local eventName = string.upper(event.name)
    if eventManager.debug_ then
        echoInfo("eventManager:dispatchEvent() - dispatching event %s", eventName)
    end

    if eventManager.listeners_[eventName] == nil then 
    
        echoInfo("eventManager:dispatchEvent() - dispatching event %s no listener", eventName)
        return      
    end
    
    for handle, listener in pairs(eventManager.listeners_[eventName]) do
        if eventManager.debug_ then
            echoInfo("eventManager:dispatchEvent() - dispatching event %s to listener [%s] ", eventName, handle)
        end
        local ret
        if listener[2] then
            ret = listener[1](listener[2], event)
        else
            ret = listener[1](event)
        end
        if ret == false then
            if eventManager.debug_ then
                echoInfo("eventManager:dispatchEvent() - break dispatching for event %s", eventName)
            end             
        end
    end
   -- return eventManager 
end

function eventManager.removeEventListener(eventName, key)
    
    assert(eventName ~= nil,
        "eventManager:removeEventListener() - invalid eventKey"..eventName) 
    
    local eventName = string.upper(eventName)   
    
    if eventManager.listeners_[eventName] == nil then return end

    for handle, listener in pairs(eventManager.listeners_[eventName]) do
        if key == handle or (key == listener[1]) then
            eventManager.listeners_[eventName][handle] = nil
            if eventManager.debug_ then
                echoInfo("eventManager:removeEventListener() - remove listener [%s] for event %s", handle, eventName)
            end
            return handle
        end
    end
    --return eventManager
    
end

function eventManager.removeAllEventListenersForEvent(eventName)
    
    
    assert(eventName  ~= nil,
        "eventManager:removeAllEventListenersForEvent() - invalid eventKey"..eventName) 
    
    local eventName = string.upper(eventName)
    eventManager.listeners_[string.upper(eventName)] = nil
    if self.debug_ then
        echoInfo("eventManager:removeAllEventListenersForEvent() - remove all listeners for event %s", eventName)
    end
    return eventManager
end

function eventManager.removeAllEventListeners()
    eventManager.listeners_ = {}
    if eventManager.debug_ then
        echoInfo("eventManager:removeAllEventListeners() - remove all listeners")
    end
    return eventManager
end

function eventManager.setDebugEnabled(enabled)
    eventManager.debug_ = enabled
   return eventManager
end


function eventManager.dumpAllEventListeners()
    print("---- eventManager:dumpAllEventListeners() ----")
    for eventManager, listeners in pairs(self.listeners_) do
        printf("-- event: %s", eventManager)
        for handle, listener in pairs(listeners) do
            printf("---- handle: %s, %s", tostring(handle), tostring(listener))
        end
    end
    return eventManager
end	