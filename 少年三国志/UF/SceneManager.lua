--SceneManager.lua


local SceneManager = class ("SceneManager")

function SceneManager:ctor( ... )
	self._handler = {}
end

function SceneManager:start( startScene )
	self:replaceScene(startScene)
end

function SceneManager:pushScene( scene, transitionType, time, more)
	if scene ~= nil then 
		if transitionType then
            scene = display.wrapSceneWithTransition(scene, transitionType, time, more)
        end
        CCDirector:sharedDirector():pushScene(scene)
	self:_notifySceneChange()
	else 
		__LogError("wrong |scene| param in function SceneManager:pushScene")
	end
end

function SceneManager:replaceScene(scene, transitionType, time, more )
	if scene ~= nil then 
		display.replaceScene(scene, transitionType, time, more)
		self:_notifySceneChange()
	else 
		__LogError("wrong |scene| param in function SceneManager:replaceScene")
	end
end

function SceneManager:popToRootAndReplaceScene( scene )
	if scene ~= nil then 
		CCDirector:sharedDirector():popToRootAndReplaceScene(scene)
	self:_notifySceneChange()
	end
end

function SceneManager:popScene( )
	CCDirector:sharedDirector():popScene()
	self:_notifySceneChange()
end

function SceneManager:popSceneWithName( scene, ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
        self:popScene()
    elseif scene then
        self:replaceScene(require(scene).new(...))
    end
end

function SceneManager:popToRootScene( )
	CCDirector:sharedDirector():popToRootScene()
	self:_notifySceneChange()
end

function SceneManager:popToSceneStackLevel( level )
	if type(level) ~= "number" then 
		__LogError("Error in popToSceneStackLevel, wrong level!")
		return 
	end

	CCDirector:sharedDirector():popToSceneStackLevel(level)
	self:_notifySceneChange()
end

function SceneManager:getCurScene(  )
	return CCDirector:sharedDirector():getRunningScene()
end

function SceneManager:_notifySceneChange( ... )
	if not uf_funcCallHelper then 
		return 
	end

	--uf_funcCallHelper:callAfterFrameCount(1, function ( ... )
		self:_doNotifySceneChange()		
	--end)
end

function SceneManager:_doNotifySceneChange( ... )
	if #self._handler < 1 then 
		return 
	end

	local sceneCount = CCDirector:sharedDirector():getSceneCount()
	local sceneStack = {}
	if sceneCount > 0 then 
		local loopi = 0
		while loopi < sceneCount do 
			local scene = CCDirector:sharedDirector():getSceneByIndex(loopi)
			loopi = loopi + 1
	 		if scene and scene.class then
	 			table.insert(sceneStack, #sceneStack + 1, scene.class.__cname)
	 		else
	 			table.insert(sceneStack, #sceneStack + 1, "CCScene")
			end			
		end
	end

	for key, value in pairs(self._handler) do 
		value(sceneStack, sceneCount)
	end
end

function SceneManager:hookerSceneChange( func )
	if not func then 
		return 
	end

	for key, value in pairs(self._handler) do 
		if value == func then 
			return 
		end
	end

	table.insert(self._handler, #self._handler + 1, func)
end

function SceneManager:unhookerSceneChange( func )
	if not func then 
		return 
	end

	for key, value in pairs(self._handler) do 
		if value == func then 
			table.remove(self._handler, key)
			return 
		end
	end
end

return SceneManager