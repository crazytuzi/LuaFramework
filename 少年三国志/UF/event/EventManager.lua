--EventManager.lua



local EventManager = class ("EventManager", function (  )
	return display.newNode()
end)

function EventManager:ctor( ... )
	uf_notifyLayer:addNode(self)

	self._isDispatching = false
	self._observerList = {}
	self._asyncEvent = {}
	self._eventPair = {}
	self._removeEventCache = {}
	self._addEventCache = {}

	local updateHandler = function ( ... )
		if table.getn(self._asyncEvent) < 1 then 
			return nil
		end

		table.foreach(self._asyncEvent, function(i, v)
			self:_doDispatchEvent(v.id, v.ex, v.args)
		end) 

		self._asyncEvent = {}
	end

	self:scheduleUpdate(updateHandler, 0)
end

function EventManager:addEventListener( event, fun, target)
	if event == nil or fun == nil then
		return false
	end

	if target == nil then
		__LogError("target can't be nil when register event listener!")
		return false
	end
	
	if self:_findEventListener(event, fun, target) then
		return true
	end

	return self:_addListener(event, fun, target)
end

function EventManager:removeListenerWithTarget( target )
	if target == nil then 
		return false
	end

	local eventArr = self._eventPair[target]
	if eventArr == nil then 
		return true
	end

	for key, value in pairs(eventArr) do  
		if value ~= nil then 
			self:removeListenerWithEvent(target, value)
		end
    end
    self._eventPair[target] = nil

    return true
end

function EventManager:_findEventListener( event, fun, target )
	if event == nil or fun == nil or target == nil then 
		assert(0, "invalid param")
		return true
	end

	local obj = self._observerList[event]
	if obj == nil or type(obj) ~= "table" then 
		return false
	end

	for key, value in pairs(obj) do  
		if type(value) == "table" and value[1] == target and value[2] == fun then 
			return true
		end
    end

    return false
end

function EventManager:_addListener( event, fun, target )
	if event == nil or fun == nil then 
		assert(0, "invalid param")
		return true
	end

	local obj = self._observerList[event]
	local len = 1
	if obj == nil or type(obj) ~= "table" then 
		--__Log("type of obj is %s", type(obj))
		self._observerList[event] = {}
		len = 1
	else
		len = table.getn(obj) + 1
	end
	
	table.insert(self._observerList[event], len, {target, fun})
	--__Log("[EventManager:addObserver] register event = %d, len=%d size=%d ",
	-- event, len, table.getn(self._observerList[event]))

	-- add event id into event pair
	if target ~= nil then 
		local len = 1
		if self._eventPair[target] == nil or
		   type(self._eventPair[target]) ~= "table" then
			self._eventPair[target] = {}
		else
			len = table.getn(self._eventPair[target]) + 1
		end

	--__Log("[EventManager:addObserver] add event pair = %d, len=%d ", event, len)
		table.insert(self._eventPair[target], len, event)
	end
	
	return true
end

function EventManager:_removeListener( target )
	if target == nil then 
		return false
	end

	local eventArr = self._eventPair[target]
	if eventArr == nil then 
		return true
	end

	for key, value in pairs(eventArr) do  
		if value ~= nil then 
			self:removeListenerWithEvent(target, value)
		end
    end
    self._eventPair[target] = nil

    return true
end

function EventManager:removeListenerWithEvent( target, event )
	if target == nil or event == nil then 
		return false
	end

	local eventObserver = self._observerList[event]
	if eventObserver == nil then 
		return true
	end

	if self._isDispatching then 
		return self:_addRemoveEventCache(target, event)
	end

	for key, value in pairs(eventObserver) do  
		if type(value) == "table" and value[1] == target then 
			table.remove(self._observerList[event], key)
			return true
		end
    end

    return false
end

function EventManager:_addRemoveEventCache( target, event )
	table.insert(self._removeEventCache, #self._removeEventCache + 1, {target, event})
end

function EventManager:_doRemoveEventCache( ... )
	for key, value in pairs(self._removeEventCache) do 
		self:removeListenerWithEvent(value[1], value[2])
	end

	self._removeEventCache = {}
end

function EventManager:dispatchEvent( event, except, async, ... )
	if event == nil then 
		return nil
	end

	if async == false then
		local args = {...}
		self:_doDispatchEvent(event, except, args)
	else
		self:_addAsyncEvent(event, except, ...)
	end
end

function EventManager:_doDispatchEvent( event, except, args )
	local eventObserver = self._observerList[event]
	if eventObserver == nil then 
		return false
	end

	self._isDispatching = true
	for key, value in pairs(eventObserver) do  
		if value ~= nil and type(value) == "table" and table.getn(value) >= 2 then 
			if value[1] ~= nil and value[2] ~= nil then 
				value[2](value[1], unpack(args))
			elseif value[2] ~= nil then
				value[2](unpack(args))
			end
		end
    end
    self._isDispatching = false

    self:_doRemoveEventCache()
end

function EventManager:_addAsyncEvent( event, except, ... )
	local count = table.getn(self._asyncEvent)
	local eventInfo = { id = event,
						ex = except,
						args = {...}}
	--__Log("[EventManager] addAsyncEvent: event = %d", event)
	table.insert(self._asyncEvent, count + 1, eventInfo)

end

return EventManager