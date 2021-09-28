--CCBBaseScene.lua

local CCBBaseScene = class("CCBBaseScene", function()
    return CCSceneExtend.extend(UIScene:create())
end)

function CCBBaseScene:ctor( ... )
	self._ccbiFile = {}
	self:registerNodeEvent()
	--__Log("CCBBaseScene:onCtor")
end

function CCBBaseScene:loadLayer(ccbfile, isModel)
	if ccbfile == nil then
		return nil
	end

	local ccbLoader = nil
	if isModel then
		ccbLoader = UFModelLayer.new(ccbfile, ccc4(50, 50, 50, 150))
	else
		ccbLoader = UFNormalLayer.new(ccbfile)
	end	

	if ccbLoader == nil then
		return nil
	end

	self.addLayer(self, ccbLoader)
	return ccbLoader
end

function CCBBaseScene:addLayer(ccbFile)
	if ccbFile == nil then 
		assert(0, "invalid parameter!")
		return nil
	end

	self:addToScene(ccbFile, ccbFile:getZOrder(), ccbFile:getTag() )
	if ccbFile.getLayerName ~= nil then 
		local layerName = ccbFile:getLayerName()

		self:addLayerObj(layerName, ccbFile)
		ccbFile:setParentScene(self)
		self:_onSceneLoad(ccbFile:ccbFileName(), ccbFile)
	end
end

function CCBBaseScene:addLayerObj( layerName, obj )
	if layerName ~= nil then
		self._ccbiFile[layerName] = obj
	else
		__Log("addLayerObj: name is nil")
		table.insert(self._ccbiFile, obj)
	end

end

function CCBBaseScene:removeLayerObj( layerName )
	self._ccbiFile[layerName] = nil
end

function CCBBaseScene:registerNodeEvent()
    local handler = function(event)
        if event == "enter" then
            self:_onSceneEnter()
        elseif event == "exit" then
            self:_onSceneExit()
        elseif event == "cleanup" then
            self:_onSceneUnload()
        end
    end
    self:registerScriptHandler(handler)
end

function CCBBaseScene:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCBBaseScene:_onSceneLoad( ccbFile, ccbLoader)
	--if ccbLoader ~= nil then
	--	ccbLoader:_onLayerLoad()
	--end

	if self.onSceneLoad ~= nil then
		self:onSceneLoad(ccbFile, ccbLoader)
	end
end

function CCBBaseScene:_onSceneExit( )
	if self.onSceneExit ~= nil then
		self:onSceneExit()
	end
end

function CCBBaseScene:_onSceneEnter( )
	if self.onEnterScene ~= nil then
		self:onEnterScene()
	end
end

function CCBBaseScene:_onSceneUnload( )
	if self.onSceneUnload ~= nil then
		self:onSceneUnload()
	end
end

function CCBBaseScene:registerMenuHandler(ccbFile, menuName, fun, target )
	if ccbFile == nil or fun == nil then
		return false
	end
	
	return ccbFile:registerMenuHandler(menuName, fun, target)
end

function CCBBaseScene:registerAnimationCallback( ccbFile, selector, fun, target )
	if ccbFile == nil or fun == nil then
		return false
	end
	
	return ccbFile:registerAnimationCallback(selector, fun, target)
end

function CCBBaseScene:sendLayerEvent( layerName, event, sender, ... )
 	local layer = self:getLayerByName(layerName)
 	if layer == nil then 
 		return false
 	end

 	if layer.onLayerEvent ~= nil then 
        return layer.onLayerEvent(layer, event, sender, ...)
    end

    return false
end


function CCBBaseScene:onSceneSwitch( args, callback )
	return false
end

function CCBBaseScene:onSceneEvent( event, sender, ... )
    
end

function CCBBaseScene:getLayerByName( layerName )
	for key, value in pairs(self._ccbiFile) do
		if key == layerName then
			return value
		end
	end

	return nil
end

function CCBBaseScene:showLayerByName(layerName, show )
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

function CCBBaseScene:removeLayerByName( layerName )
	local layer = self:getLayerByName(layerName)
 	if layer == nil then 
 		return false
 	end

	layer:close()
	self:removeLayerObj(layerName)
 	return true
end

function CCBBaseScene:removeNode( node )
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

return CCBBaseScene