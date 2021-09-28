--SceneMonitor.lua


local SceneMonitor = class("SceneMonitor", function ( ... )
	return CCSNormalLayer:create()
end)

function SceneMonitor:ctor( ... )
	self._sceneStack = {}
	self._layerStack = {}
	self._layerSwallow = {}
	self._enterLabel = nil
	self._sceneLabel = nil
	self._sceneStackStr = ""

	self:_initMonitor()
end

function SceneMonitor:getSceneStackStr( ... )
	return self._sceneStackStr
end

function SceneMonitor:_initMonitor( ... )
	self:setVisible(false)
	self:setBackColor(ccc4(155, 0, 155, 50))
	if uf_notifyLayer then 
		uf_notifyLayer:getDebugNode():addChild(self)
	end

	if uf_sceneManager then
		uf_sceneManager:hookerSceneChange(function ( ... )
			self:_onSceneChange( ... )
		end)
	end

	UFCCSUIHooker.hookerScene(function (se, sceneName, flag, scene, ... )
		if flag == "enter" then
			self:_onSceneHooker(sceneName, scene)
		elseif flag == "exit" then
			self:_onSceneUnHooker(sceneName, scene)
		end
	end, self)

	UFCCSUIHooker.hookerLayer(function ( se, layerName, flag, layer, ... )
		if flag == "enter" then
			self:_onLayerHooker(layerName, layer)
		elseif flag == "exit" then 
			self:_onLayerUnHooker(layerName, layer)
		end
	end, self)
end

function SceneMonitor:unInitMonitor( ... )
	UFCCSUIHooker:unHookerWithTarget(self)
	self:removeFromParentAndCleanup()	
end

function SceneMonitor:_onSceneHooker( sceneName, scene )
	--print("_onSceneHooker:scene=["..sceneName.."]")
	if sceneName then 
		if not self._sceneStack[sceneName] then 
			self._sceneStack[sceneName] = 0
		end
		self._sceneStack[sceneName] = self._sceneStack[sceneName] + 1

		if self:isVisible() then 
			self:_refreshSceneStack()
		end
	end
end

function SceneMonitor:_onSceneUnHooker( sceneName, scene )
	if sceneName and self._sceneStack[sceneName] then 
		self._sceneStack[sceneName] = self._sceneStack[sceneName] - 1 
		if self._sceneStack[sceneName] <= 0 then 
			self._sceneStack[sceneName] = nil
		end

		if self:isVisible() then 
			self:_refreshSceneStack()
		end
	end
end

function SceneMonitor:_onLayerHooker( layerName, layer )
	--print("_onLayerHooker:layer=["..layerName.."]")
	if layerName then 
		if not self._layerStack[layerName] then 
			self._layerStack[layerName] = 0
		end
		self._layerStack[layerName] = self._layerStack[layerName] + 1

		if self:isVisible() then 
			self:_refreshSceneStack()
		end

		if layer:isTouchSwallow() then 
			if not self._layerSwallow[layerName] then 
				self._layerSwallow[layerName] = 1
			end
		end
	end
end

function SceneMonitor:_onLayerUnHooker( layerName, layer )
	--print("_onLayerUnHooker:layer=["..layerName.."]")
	if layerName and self._layerStack[layerName] then 
		self._layerStack[layerName] = self._layerStack[layerName] - 1 
		if self._layerStack[layerName] <= 0 then 
			self._layerStack[layerName] = nil
		end

		if self:isVisible() then 
			self:_refreshSceneStack()
		end
	end

	if layer:isTouchSwallow() then 
		if self._layerSwallow[layerName] then 
			self._layerSwallow[layerName] = nil
		end
	end
end

function SceneMonitor:_onSceneChange( sceneTable, count )	
	sceneTable = sceneTable or {}
	count = count or 0

	if self._sceneLabel == nil then 
		local size = CCDirector:sharedDirector():getWinSize()
		self._sceneLabel  = Label:create()
		self:addChild(self._sceneLabel)
		self._sceneLabel:setColor(ccc3(0, 255, 255))
		self._sceneLabel:setFontSize(20)
		self._sceneLabel:setTextAreaSize(CCSizeMake(size.width - 100, size.height/3))
		self._sceneLabel:setPosition(ccp(size.width/2, size.height*2/3))
	end

	local text = ""
	for key, value in pairs(sceneTable) do 
		text = text.." ["..(count + 1 - key)..":"..value.."] "
	end

	self._sceneLabel:setText(text)
end

function SceneMonitor:showMonitor( show )
	self:setVisible(show)

	if show then 
		self:_refreshSceneStack()
	end
end

function SceneMonitor:_refreshSceneStack( ... )
	if not self._enterLabel then
		local size = CCDirector:sharedDirector():getWinSize()
		self._enterLabel = Label:create()
		self:addChild(self._enterLabel)
		self._enterLabel:setColor(ccc3(0, 255, 255))
		self._enterLabel:setFontSize(20)
		self._enterLabel:setTextAreaSize(CCSizeMake(size.width - 100, size.height/3))
		self._enterLabel:setPosition(ccp(size.width/2, size.height/3))
		--self._enterLabel:setFixedWidth(true)
	end

	local text = ""
	for key, value in pairs(self._sceneStack) do 
		text = text.." ["..key..":"..value.."] "
	end
	text = text.."\n\n"
	for key, value in pairs(self._layerStack) do 
		text = text.." <"..key..":"..value.."> "
	end

	text = text.."\n\n"
	for key, value in pairs(self._layerSwallow) do 
		text = text.." <"..key..":"..(value or 0).."> "
	end

	self._enterLabel:setText(text)
	self._sceneStackStr = text
	--print("update text "..text)
end

function SceneMonitor:outputSceneStack( ... )
	-- body
end

return SceneMonitor
