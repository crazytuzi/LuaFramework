--KeypadHandler.lua

local KeypadHandler = class("KeypadHandler", function ( ... )
	return CCSNormalLayer:create()
end)


function KeypadHandler:ctor( ... )
	self._backKeyHandler = nil
	self._menuKeyHandler = nil

	self._enableKeypadEvent = true

	self._menuKeyHandlerList = {}
	self._backKeyHandlerList = {}

	local topLayer = TopLevelLayer:getInstance():getTopLevelNode()
	if topLayer then 
		topLayer:addChild(self, 10000)
	end

	self:setKeypadEnabled(true)
	self:registerScriptKeypadHandler(function ( menuType )
			if menuType == "backClicked" then
				self:_onBackKeyClicked()
			elseif menuType == "menuClicked" then
				self:_onMenuKeyClicked()
			end
		end)
end

function KeypadHandler:_onMenuKeyClicked( ... )
	local ret = false

	if self._enableKeypadEvent then 
		for loopi = #self._menuKeyHandlerList, 1, -1 do
			local value = self._menuKeyHandlerList[loopi]
			if type(value) == "table" and #value == 2 and not ret then 
				if value[2].isRunning and value[2]:isRunning() then 
					ret = ret or value[1](value[2])
				end
			end
    	end
    end

    if not ret and self._menuKeyHandler then 
    	self._menuKeyHandler()
    end
end

function KeypadHandler:_onBackKeyClicked( ... )
	local ret = false

	if self._enableKeypadEvent then 
		for loopi = #self._backKeyHandlerList, 1, -1 do  
			local value = self._backKeyHandlerList[loopi]
			if type(value) == "table" and #value == 2 and not ret then 
				if value[2].isRunning and value[2]:isRunning() then 
					ret = ret or value[1](value[2])
				end
			end
    	end
    end

    if not ret and self._backKeyHandler then 
    	self._backKeyHandler()
    end
end

function KeypadHandler:setDefaultMenuKeyHandler( func )
	self._menuKeyHandler = func
end

function KeypadHandler:setDefaultBackKeyHandler( func )
	self._backKeyHandler = func
end

function KeypadHandler:clearDefaultKeyHandler( ... )
	self._menuKeyHandler = nil 
	self._backKeyHandler = nil
end

function KeypadHandler:enableKeypadEvent( enable )
	self._enableKeypadEvent = enable or false
end

function KeypadHandler:registerBackKeyHandler( func, target )
	if not self._enableKeypadEvent then 
		return 
	end

	local _findHandler = function( fun, target )
		if fun == nil or target == nil then 
			assert(0, "invalid param")
			return false
		end

		for key, value in pairs(self._backKeyHandlerList) do  
			if type(value) == "table" and value[2] == target and value[1] == fun then 
				return true
			end
    	end

    	return false
	end

	if not func or not target then 
		assert(0, "have invalid param in registerBackKeyHandler")
		return 
	end

	table.insert(self._backKeyHandlerList, #self._backKeyHandlerList + 1, {func, target})
end

function KeypadHandler:registerMenuKeyHandler( func, target )
	if not self._enableKeypadEvent then 
		return 
	end
	local _findHandler = function( fun, target )
		if fun == nil or target == nil then 
			assert(0, "invalid param")
			return false
		end

		for key, value in pairs(self._menuKeyHandlerList) do  
			if type(value) == "table" and value[2] == target and value[1] == fun then 
				return true
			end
    	end

    	return false
	end

	if not func or not target then 
		assert(0, "have invalid param in registerMenuKeyHandler")
		return 
	end

	table.insert(self._menuKeyHandlerList, #self._menuKeyHandlerList + 1, {func, target})
end

function KeypadHandler:unregisterKeyHandler( target )
	for key, value in pairs(self._menuKeyHandlerList) do  
		if type(value) == "table" and value[2] == target then 
			table.remove(self._menuKeyHandlerList, key)
			--self._menuKeyHandlerList[key] = nil
		end
    end

    for key, value in pairs(self._backKeyHandlerList) do  
		if type(value) == "table" and value[2] == target then 
			table.remove(self._backKeyHandlerList, key)
			--self._backKeyHandlerList[key] = nil
		end
    end
end

return KeypadHandler
