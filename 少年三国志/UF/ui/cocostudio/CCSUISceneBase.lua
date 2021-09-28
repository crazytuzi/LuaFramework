--CCSUISceneBase.lua

local CCSUISceneBase = class ("CCSUISceneBase", function ( jsonFile, fun, ... )
	if type(fun) == "function" then
		return CCSUIScene:create(jsonFile, fun)
	elseif type(jsonFile) == "string" then
		return CCSUIScene:create(jsonFile)
	else
		return CCSUIScene:create()
	end
end)


function CCSUISceneBase:ctor( jsonFile, fun, ... )
    self._backKeypadFlag = 0
    self._menuKeypadFlag = 0

	self:registerNodeEvent()

	self:_onSceneLoad(jsonFile, fun, ...);
	if type(fun) == "function" then
		self:addAsyncLoadHandler(function ( isComplete, progress )
			self:_resourceLoadProgress( isComplete, progress )
		end)
	end
end


function CCSUISceneBase:registerKeypadEvent( backKey, menuKey )
    local backFlag = backKey and 1 or 0
    local menuFlag = menuKey and 1 or 0

    if backFlag ~= self._backKeypadFlag then 
        self._backKeypadFlag = backFlag
        if self._backKeypadFlag == 1 and self:isRunning() then 
            self:_doRegisterBackKeyHandler()
        end
    end

    if menuFlag ~= self._menuKeypadFlag then 
        self._menuKeypadFlag = menuFlag
        if self._menuKeypadFlag == 1 and self:isRunning() then 
            self:_doRegisterMenuKeyHandler()
        end
    end
end

function CCSUISceneBase:_doRegisterBackKeyHandler( ... )
    uf_keypadHandler:registerBackKeyHandler(function ( ... )
        return self:_onBackKeyHandler()
    end, self)
end

function CCSUISceneBase:_doRegisterMenuKeyHandler( ... )
    uf_keypadHandler:registerMenuKeyHandler(function ( ... )
        return self:_onMenuKeyHandler()
    end, self)
end

function CCSUISceneBase:unregisterKeypadEvent( ... )
    uf_keypadHandler:unregisterKeyHandler(self)
end

function CCSUISceneBase:_onBackKeyHandler( ... )
    return self:onBackKeyEvent()
end

function CCSUISceneBase:onBackKeyEvent( ... )
    -- body
end

function CCSUISceneBase:_onMenuKeyHandler( ... )
    return self:onMenuKeyEvent()
end

function CCSUISceneBase:onMenuKeyEvent( ... )
    -- body
end

function CCSUISceneBase:registerNodeEvent()
    local handler = function(event, sub_event, ...)
        if event == "enter" then
            self:_onSceneEnter()
        elseif event == "exit" then
            self:_onSceneExit()
        elseif event == "cleanup" then
            self:_onSceneUnload()
        elseif event == "component_ui" then
        	if sub_event == "enter" then
        		self:_onUIComponentEnter(...)
        	elseif sub_event == "exit" then
        		self:_onUIComponentExit(...)
        	end
        end
    end
    self:registerScriptHandler(handler)
end

function CCSUISceneBase:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCSUISceneBase:_onSceneLoad( ... )
	if self.onSceneLoad ~= nil then
		self:onSceneLoad(...)
	end
end

function CCSUISceneBase:_onSceneExit( )
    UFCCSUIHooker.hitSceneHooker(self.class.__cname, "exit", self)
    if self._backKeypadFlag == 1 or self._menuKeypadFlag == 1 then 
        self:unregisterKeypadEvent()
    end
	if self.onSceneExit ~= nil then
		self:onSceneExit()
	end
end

function CCSUISceneBase:_onSceneEnter( )
    UFCCSUIHooker.hitSceneHooker(self.class.__cname, "enter", self)
    if self._backKeypadFlag == 1 then 
        self:_doRegisterBackKeyHandler()
    end

    if self._menuKeypadFlag == 1 then 
        self:_doRegisterMenuKeyHandler()
    end
	if self.onSceneEnter ~= nil then
		self:onSceneEnter()
	end
end

function CCSUISceneBase:_onSceneUnload( )
	if self.onSceneUnload ~= nil then
		self:onSceneUnload()
	end
end

function CCSUISceneBase:_onUIComponentEnter( comName, layer )
	--__Log("_onUIComponentEnter: comName:%s", comName)
    UFCCSUIHooker.hitLayerHooker(comName, "enter", layer)
	self:onUIComponentEnter(comName, layer)
end

function CCSUISceneBase:onUIComponentEnter( comName, layer )
	-- body
end

function CCSUISceneBase:_onUIComponentExit( comName, layer )
	--__Log("_onUIComponentExit: comName:%s", comName)
    UFCCSUIHooker.hitLayerHooker(comName, "exit", layer)
	self:onUIComponentExit(comName, layer)
end

function CCSUISceneBase:onUIComponentExit( comName, layer )
	-- body
end

function CCSUISceneBase:_resourceLoadProgress( isComplete, progress )
	if self.onResourceLoadProgress ~= nil then
		self:onResourceLoadProgress( isComplete, progress ) 
	end

	if isComplete == true then
		if self.onResourcesLoadComplete ~= nil then
			self:onResourcesLoadComplete()
		end
	end
end

function CCSUISceneBase:onResourceLoadProgress( isComplete, progress )
	
end

function CCSUISceneBase:onSceneSwitch( args, callback )
	return false
end

function CCSUISceneBase:getLayerByName( layerName )
	for key, value in pairs(self._ccbiFile) do
		if key == layerName then
			return value
		end
	end

	return nil
end

function CCSUISceneBase:showLayerByName(layerName, show )
	local layer = self:getLayerByName(layerName)
 	if layer == nil then 
 		return false
 	end

 	if show then
 		layer:setVisible(true)
	else 
		layer:setVisible(false)
	end
end

function CCSUISceneBase:removeLayerByName( layerName )
	local layer = self:getLayerByName(layerName)
 	if layer == nil then 
 		return false
 	end

	layer:close()
	self:removeLayerObj(layerName)
 	return true
end

function CCSUISceneBase:removeNode( node )
	if node == nil then 
		return false
	end

	if node.getLayerName ~= nil then
		self:removeLayerByName(node:getLayerName())
	else
		self:removeChild(node, true)
	end

	return true
end

return CCSUISceneBase