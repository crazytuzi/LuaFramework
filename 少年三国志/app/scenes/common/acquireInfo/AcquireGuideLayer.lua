--AcquireGuideLayer.lua

require("app.scenes.common.acquireInfo.acquire_guide_info")
local AcquireGuideLayer = class("AcquireGuideLayer", UFCCSNormalLayer)


function AcquireGuideLayer.create( ... )
	return AcquireGuideLayer.new(...)
end

function AcquireGuideLayer:ctor( ... )
	self._layerHookerSuccess = false
	self._sceneHookerSuccess = false
	self._hitWidgetSuccess = false
	self._startHookerWidget = false

	self._touchBeginY = 0
	self._touchOffset = 0

	self._curStepId = 0
	self._param1 = 0 
	self._param2 = 0
	self._funId = 0

	self._hookerSceneName = nil
	self._hookerLayerName = nil
	self._hookerWidgetName = nil 
	self._intParam = 0
	self._hookerDelay = 0
	self._scaleValue = 100
	self._rectParam = CCRectMake(0, 0, 0, 0)
	self._curHookerRect = CCRectMake(0, 0, 0, 0)
	self._hookerWidgetRect = CCRectMake(0, 0, 0, 0)
	self._maxFilterSize = CCDirector:sharedDirector():getWinSize()

	self._fingerEffect = nil

	self._hookerScene = nil
	self._hookerLayer = nil

	self._showFilterPanel = false
	if self._showFilterPanel then 
		self._filterPanel = CCLayerColor:create(ccc4(255, 100, 100, 100), 100, 100)
		self:addChild(self._filterPanel)
	end

	self.super.ctor(self, ...)	
end

function AcquireGuideLayer:onLayerLoad( ... )
	--self:setBackColor(ccc4(0, 255, 0, 50))

	local EffectNode = require "app.common.effects.EffectNode"

    self._fingerEffect = EffectNode.new("effect_finger") 
    self._fingerEffect:setPosition(ccp(display.cx, display.cy))
    self:addChild(self._fingerEffect)
    self._fingerEffect:setVisible(false)

    UFCCSUIHooker.hookerScene(function (se, sceneName, flag, scene, ... )
		if flag == "enter" then
			self:_onSceneHooker(sceneName, scene)
		elseif flag == "exit" then
			self:_onSceneUnHooker(sceneName, scene)
		end
	end, self)

	self:registerTouchEvent(false, false, 3)

	uf_notifyLayer:getModelNode():addChild(self)
end

function AcquireGuideLayer:onLayerUnload( ... )
	self:finishGuide()
end


function AcquireGuideLayer:_onSceneHooker( sceneName, scene )
	if sceneName == self._hookerSceneName then
		self._sceneHookerSuccess = true
		self._hookerScene = scene
		self:_onHooker()
	end
end

function AcquireGuideLayer:_onSceneUnHooker( sceneName, scene )
	if sceneName == self._hookerSceneName  then
		self._sceneHookerSuccess = false
		if not self._hitWidgetSuccess then 
			self:_callback("cancel", true)
		end
	end
end

function AcquireGuideLayer:finishGuide( ... )
	--UFCCSUIHooker.dumpLayerHooker()
	__Log("unHookerWithTarget")
	UFCCSUIHooker.unHookerWithTarget(self)
	--UFCCSUIHooker.dumpLayerHooker()
	self:setVisible(false)
end

function AcquireGuideLayer:_callback( event, sceneExit )
	if self._stepCallback then 
		self._hitWidgetSuccess = true
		self._stepCallback(event, self._curStepId or 0)
		if event == "cancel" then 
			if not sceneExit then 
				self:_removeLayerHooker()
			else
				self._hookerLayer = nil
			end
			self._stepCallback = nil
		end
	end
end

function AcquireGuideLayer:filterWithStepId( stepId, funId, param1, param2, fun )
	self._curStepId = stepId
	self._stepCallback = fun
	self._funId = funId
	self._param1 = param1
	self._param2 = param2

	local guideInfo = acquire_guide_info.get(stepId)
	if not guideInfo then
		self:_callback("finish")
		return __LogError("invalid step_id:", step_id)
	end

dump(guideInfo)
 	local lastScene = self._hookerSceneName
	self._hitWidgetSuccess = false
	self._hookerSceneName = #guideInfo.scene_name > 0 and guideInfo.scene_name or nil 
	self._hookerLayerName = #guideInfo.layer_name > 0 and guideInfo.layer_name or nil
	self._hookerWidgetName = #guideInfo.click_widget > 0 and guideInfo.click_widget or nil
	self._intParam = guideInfo.click_param1
	self._hookerDelay = guideInfo.hooker_delay
	self._scaleValue = guideInfo.scale_value

	local size = CCDirector:sharedDirector():getWinSize()
	self._rectParam = CCRectMake(guideInfo.x, (guideInfo.y + size.height)%size.height, guideInfo.width, guideInfo.height)

	self._layerHookerSuccess = false
	self._sceneHookerSuccess = lastScene == self._hookerSceneName
	self._startHookerWidget = false

	self:_startFilter()
end

function AcquireGuideLayer:_startFilter( ... )
	if not self._hookerLayer and self._hookerLayerName then 
		__Log("------hookerLayerWithName: layerName:%s-------", self._hookerLayerName)
		UFCCSUIHooker.hookerLayerWithName(self._hookerLayerName, function (se, layerName, flag, layer, ...)
			if layerName ~= self._hookerLayerName then
				return 
			end

			if flag == "enter" then
				__Log("-------[ acquire: enter layer hooker: [%s]---------", layerName)
				if not self._layerHookerSuccess then
					self._layerHookerSuccess = true
					self._hookerLayer = layer

					self:_onHooker()
				end
			elseif flag == "exit" then
				__Log("-------[acquire: exit layer hooker: [%s]----------", layerName)
				--self._layerHookerSuccess = false
				--self._hookerLayer = nil
			end
		end, self)
		--UFCCSUIHooker.dumpLayerHooker()
	end
end

function AcquireGuideLayer:showFinger( ... )
	if not self._hookerLayer then 
		return 
	end

	self._startHookerWidget = true
		local prepareRect = self:_prepareDataForGuide()

		local hookerRect = CCRectZero
		if prepareRect then 
			hookerRect = prepareRect 
			__Log("prepareRect:(%d, %d, %d, %d)", 
				prepareRect.origin.x, prepareRect.origin.y, prepareRect.size.width, prepareRect.size.height)
		else
			if self._rectParam.size.width ~= 0 and self._rectParam.size.height ~= 0 then
				hookerRect = self._rectParam
			elseif self._hookerWidgetName then
				local hookerWidget = self._hookerWidgetName
				__Log("self._intParam:%d, hookerWidget:%s", self._intParam, self._hookerWidgetName)
				if self._intParam > 0 then
					local startPos, endPos = string.find(hookerWidget, '%%d')
					__Log("startPos:%d", startPos or -1)
					if startPos and startPos > 0 then
						hookerWidget = string.format(hookerWidget, self._intParam == 1 and self._param1 or self._param2)
					end
				end
				if self._hookerLayer then
					hookerRect = self._hookerLayer:getScreenRectWithWidget(hookerWidget)
					self._hookerWidgetName = hookerWidget
				end
				__Log("register widget:%s", hookerWidget)
			else
				__Log("use null rect")
			end	
		end
		if (self._scaleValue < 100) and hookerRect then
			hookerRect = CCRectMake(hookerRect.origin.x + hookerRect.size.width * (100 - self._scaleValue)/200,
			hookerRect.origin.y + hookerRect.size.height * (100 - self._scaleValue)/200,
			hookerRect.size.width*self._scaleValue/100, 
			hookerRect.size.height*self._scaleValue/100 )
		end

		self:_resetHookerRect(hookerRect)
end

function AcquireGuideLayer:_onHooker(  )
	if not self._layerHookerSuccess or not self._sceneHookerSuccess then
		return 
	end

	if self._hookerLayer and self._hookerWidgetName then
		self._hookerLayer:registerHooker(function ( name, intParam1, stringParam2 )
			if not self._startHookerWidget then 
				return 
			end
			if "CCLayer" == name then
				self:_onLayerHookerEvent(intParam1, stringParam2)
			elseif self._hookerWidgetName then
				self:_onWidgetHookerEvent(name, intParam1, stringParam2)
			end
		end)
	end

	if self._hookerDelay > 0 then 
		self._hookerWidgetRect = CCRectMake(0, 0, 0, 0)
		self:callAfterDelayTime(self._hookerDelay/1200, nil, function ( ... )
			self:showFinger()
		end)
	else
		self:showFinger()
	end	
end

function AcquireGuideLayer:_prepareDataForGuide( ... )
	if self._intParam <= 0 then 
		return nil
	end

	local param = self._intParam == 1 and self._param1 or self._param2
	if self._hookerLayer and self._hookerLayer.__prepareDataForAcquireGuide__ then 
			return self._hookerLayer:__prepareDataForAcquireGuide__(self._funId, param)
	elseif self._hookerScene and self._hookerScene.__prepareDataForAcquireGuide__ then 
			return self._hookerScene:__prepareDataForAcquireGuide__(self._funId, param)
	end

	return nil
end

function AcquireGuideLayer:_resetHookerRect( rect )
	self._hookerWidgetRect = rect or CCRectMake(0, 0, 0, 0)
__Log("_resetHookerRect:(%d, %d, %d, %d)", 
	self._hookerWidgetRect.origin.x, self._hookerWidgetRect.origin.y,
	self._hookerWidgetRect.size.width, self._hookerWidgetRect.size.height)

	local showFingerFlag = true
	if (self._hookerWidgetRect.size.width == self._maxFilterSize.width and
	 	self._hookerWidgetRect.size.height == self._maxFilterSize.height) or 
	 		(self._hookerWidgetRect.size.width == 0 or 
	 		self._hookerWidgetRect.size.height == 0) then 
	 	showFingerFlag = false 
	end
	if showFingerFlag then 
		self._fingerEffect:setPosition(ccp(self._hookerWidgetRect.origin.x + self._hookerWidgetRect.size.width/2,
			self._hookerWidgetRect.origin.y + self._hookerWidgetRect.size.height/2))
			self._fingerEffect:play()
	end
	self._fingerEffect:setVisible(showFingerFlag)

	if self._showFilterPanel then 
		self._filterPanel:setPosition(self._hookerWidgetRect.origin)
		self._filterPanel:setContentSize(self._hookerWidgetRect.size)
	end
end

function AcquireGuideLayer:_resetHookerRectWithValue( x, y, width, height )
	self:_resetHookerRect(CCRectMake(x or 0, y or 0, width or 0, height or 0))
end

function AcquireGuideLayer:onTouchBegin( xpos, ypos )
	self._touchBeginY = ypos

    return true
end

function AcquireGuideLayer:onTouchMove( xpos, ypos )
	self:_checkMoveDistrict(ypos - self._touchBeginY)
end

function AcquireGuideLayer:onTouchEnd( xpos, ypos )
	self._touchOffset = ypos - self._touchBeginY
end

function AcquireGuideLayer:_checkMoveDistrict( offset )
	local maxDist = self._hookerWidgetRect.size.height
	if maxDist <= 0 then 
		maxDist = 100
	end
	if math.abs(self._touchOffset + offset) >= maxDist then 
		self._fingerEffect:setVisible(false)
		self:_callback("cancel")	
	end
end

function AcquireGuideLayer:_onWidgetHookerEvent( name, intParam1, stringParam2 )
	if not self._hookerWidgetName then
		return 
	end

	if stringParam2 == "CCSListViewEx" and intParam1 ~= 2 then 
		return 
	end

	if name == self._hookerWidgetName then 
		self:_onHitHooker()
	else
		__Log("hooker other widget:%s", name)
		self:_callback("cancel")
	end
end

function AcquireGuideLayer:_onLayerHookerEvent( intParam1, stringParam2 )
	if self._hookerWidgetName then
		return 
	end
end

function AcquireGuideLayer:_removeLayerHooker(  )
	if self._hookerLayer then
		self._hookerLayer:removeHooker()
		self._hookerLayer = nil
	end
end

function AcquireGuideLayer:_onHitHooker(  )
	if self._curStepId == 0  then
		return 
	end

	self._curStepId = 0

	--self:setVisible(false)
	self:_stopCurrentFilter()

	self:_callback("finish")
end

function AcquireGuideLayer:_stopCurrentFilter( ... )
	if self._hookerLayerName then
		UFCCSUIHooker.unHookerWithLayerName(self._hookerLayerName)
	end

	self:_removeLayerHooker()

	self:_resetHookerRect(CCRectMake(0, 0, 0, 0))

	if self._fingerEffect then
		self._fingerEffect:setVisible(false)
		self._fingerEffect:stop()
	end
end

return AcquireGuideLayer
