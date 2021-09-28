--GuideFilterLayer.lua


local GuideFilterLayer = class("GuideFilterLayer", UFCCSNormalLayer)


function GuideFilterLayer.create( ... )
	return require("app.scenes.guide.GuideFilterLayer").new( "ui_layout/guide_FilterLayer.json", ...)
end

function GuideFilterLayer:ctor( ... )
	self._hookerSuccess = false
	self._filterTip = nil
	self.super.ctor(self, ...)

	self._curStepId = 0
	self._curStackSceneId = 0

	self._hookerSceneName = nil 
	self._lastHookerSceneName = nil

	self._hookerLayerName = nil 
	self._lastHookerLayerName = nil

	self._thirdHookerLayer = nil
	self._thirdHookerLayerName = nil

	self._hookerWidgetName = nil
	self._hookerEventName = nil

	self._tipPos = 0
	self._intParam = 0
	self._textId = 0
	self._zoomPercent = 100
	self._rectParam = CCRectZero

	self._maxFilterSize = CCDirector:sharedDirector():getWinSize()

	self._hookerDelay = 0
	self._hookerWidgetRect = CCRectMake(0, 0, 0, 0)
	self._hookerWidgetRect.size = self._maxFilterSize
	self._hookerLayer = nil
	self._lastHookerLayer = nil
	self._hookerScene = nil

	self._touchEnable = false
	self._needMask = true
	self._finishEventHooker = true

	self._finishHookerLayerName = ""
	self._sceneHookerSuccess = false
	self._layerHookerSuccess = false
	self._stepCallback = nil

	self._shouldWaitEffect = nil

	self._layersInCurScene = {}

	-- 用于显示当前引导步骤中可点击范围的半透明层标记及层对象
	self._showFilterPanel = false
	if self._showFilterPanel then 
		self._filterPanel = CCLayerColor:create(ccc4(255, 100, 100, 100), 100, 100)
		self:addChild(self._filterPanel)
	end
end

function GuideFilterLayer:onLayerLoad( ... )
	self:registerTouchEvent(false, true, 0)
	self:setClickSwallow(true)

	uf_notifyLayer:getGuideNode():addChild(self)

	--self:setBackColor(ccc4(0, 255, 0, 50))
	--self:setVisible(false)
	local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	if appstoreVersion or IS_HEXIE_VERSION  then 
		local img = self:getImageViewByName("Image_mm")
		if img then
			img:loadTexture("ui/system/yindao_zhushou_hexie.png")
		end
	end

	local EffectNode = require "app.common.effects.EffectNode"

    self._fingerEffect = EffectNode.new("effect_finger") 
    self._fingerEffect:setPosition(ccp(display.cx, display.cy))
    self:addChild(self._fingerEffect)
    self._fingerEffect:setVisible(false)

    self._filterTip = self:getWidgetByName("Panel_root")
    if self._filterTip then 
    	self._filterTip:setVisible(false)
    end
    self:showTextWithLabel("Label_tip_content", "")

    -- 注册对场景切换的监听
    UFCCSUIHooker.hookerScene(function (se, sceneName, flag, scene, ... )
		if flag == "enter" then
			self:_onSceneHooker(sceneName, scene)
		elseif flag == "exit" then
			self:_onSceneUnHooker(sceneName, scene)
		end
	end, self)
	-- 注册对界面显示的监听
	UFCCSUIHooker.hookerLayer(function (se, layerName, flag, layer, ...)
		if flag == "enter" then 
			self._layersInCurScene[layerName] = layer
		else
			self._layersInCurScene[layerName] = nil
		end
	end, self)
end

function GuideFilterLayer:finishGuide( ... )
	UFCCSUIHooker.unHookerWithTarget(self)
	self:recoveryDataAtFinishGuide()
	self._hookerScene = nil
	self:_removeLayerHooker()
end

function GuideFilterLayer:_onSceneHooker( sceneName, scene )
	__Log("enter scene hooker:%s", sceneName)

	if sceneName == self._hookerSceneName then
		self._hookerScene = scene

		-- 当前是主线副本或剧情副本时，禁止滑动
		if (self._hookerSceneName == "DungeonGateScene" or self._hookerSceneName == "StoryDungeonGateScene" ) and self._hookerScene then
			self._hookerScene:setScrollEnable(false)
		end

		-- 如果当前引导步骤没有layer对象，则直接触发引导过滤
		if not self._hookerLayerName then 
			self._layerHookerSuccess = true
			self:_startFilter()
		end
	elseif sceneName == self._lastHookerSceneName then
	end
end

function GuideFilterLayer:_onSceneUnHooker( sceneName, scene )
	__Log("exit scene hooker:%s", sceneName)

	-- 退出当前引导场景并且未等待特效完成时，表明该引导步骤结束
	if sceneName == self._hookerSceneName and not self._shouldWaitEffect then
		self._hookerScene = nil 
		self:_removeLayerHooker()		
		if not self._hookerEventName then 
			self:_onHitHooker()
		end
	else
		self._hookerScene = nil
		__Log("unHookerScene:%s, current hooker scene:%s", sceneName, self._hookerSceneName)
	end
	self._layersInCurScene = {}
end

-- 开始初始化引导步骤stepId的数据配置
function GuideFilterLayer:filterWithStepId( stepId, fun )
	self._curStepId = stepId
	self._stepCallback = fun

	local guideInfo = newplay_guide_info.get(stepId)
	if not guideInfo then
		return __LogError("invalid step_id:", step_id)
	end

dump(guideInfo)
	self._textId = guideInfo.text_id

	self._thirdHookerLayerName = self._lastHookerLayerName

	self._lastHookerLayerName = self._hookerLayerName
	self._lastHookerSceneName = self._hookerSceneName

	self._finishHookerLayerName = ""
	self._hookerSceneName = #guideInfo.scene_name > 0 and guideInfo.scene_name or nil 
	self._hookerLayerName = #guideInfo.layer_name > 0 and guideInfo.layer_name or nil
	self._hookerWidgetName = #guideInfo.click_widget > 0 and guideInfo.click_widget or nil
	self._touchEnable = guideInfo.click_enable
	self._intParam = guideInfo.click_param1
	self._hookerDelay = guideInfo.hooker_delay
	self._zoomPercent = guideInfo.zoom_percent
	self._needMask = (guideInfo.need_mask ~= 0)
	self._tipPos = guideInfo.position

    self:showTextWithLabel("Label_tip_content", guideInfo.comment)
    if self._filterTip then
    	self._filterTip:setVisible(guideInfo.comment and #guideInfo.comment > 0)
    	self._filterTip:setPosition(ccp(0, -500))
    end

	if self._hookerEventName and self._hookerEventName ~= "" then 
		--self:callAfterFrameCount(1, function ( ... )
			uf_eventManager:removeListenerWithTarget(self)
		--end)
		
		self._hookerEventName = nil
	end
	if guideInfo.protocal_id == "" then 
		self._hookerEventName = nil
		self._finishEventHooker = true
	else
		self._hookerEventName = guideInfo.protocal_id
		self._finishEventHooker = false
	end

	self._shouldWaitEffect = (guideInfo.wait_effect > 0)

	local size = CCDirector:sharedDirector():getWinSize()
	self._rectParam = CCRectMake(guideInfo.x, (guideInfo.y + size.height)%size.height, guideInfo.width, guideInfo.height)

	self._layerHookerSuccess = false

	self:_startFilter()
end

function GuideFilterLayer:_startFilter( ... )
	if self._hookerLayerName and self._hookerLayerName ~= "DungeonStoryTalkLayer" then
		if self._hookerSceneName == self._lastHookerSceneName and self._hookerScene then 
			self:_removeLayerHooker()
			__Log("use old hookder scene:%s", self._lastHookerSceneName or "")
			__Log("hookerLayerName:%s, lastLayerName:%s, thirdLayerName:%s", 
				self._hookerLayerName or "", self._lastHookerLayerName or "", self._thirdHookerLayerName or "")
			self._hookerLayer = self._hookerScene:getUILayerComponent(self._hookerLayerName)
			if not self._hookerLayer and self._hookerLayerName == self._lastHookerLayerName then 
				self._hookerLayer = self._lastHookerLayer
			end

			if not self._hookerLayer and self._thirdHookerLayerName == self._hookerLayerName then 
				self._hookerLayer = self._thirdHookerLayer
			end

			if not self._hookerLayer then 
				self._hookerLayer = self._layersInCurScene[self._hookerLayerName]
			end			
		else
			self:_removeLayerHooker()

			self._hookerLayer = self._layersInCurScene[self._hookerLayerName]
		end

		if self._hookerLayer then
			self._layerHookerSuccess = true
			self:_onHooker()
		else
			__Log("hookerlayer is nill")
		end

		-- 如果还未成功收到监听layer的显示事件，则注册对该界面的显示监听
		if not self._hookerLayer then 
			__Log("register layer with name:[%s], _finishHookerLayerName:%s", self._hookerLayerName or "", self._finishHookerLayerName or "")
			UFCCSUIHooker.hookerLayerWithName(self._hookerLayerName, function (se, layerName, flag, layer, ...)
				if layerName ~= self._hookerLayerName then
					return 
				end
				if self._finishHookerLayerName == layerName then 
					return 
				end

				-- 收到监听layer的显示事件，则触发引导指示
				if flag == "enter" then
					__Log("-------[enter layer hooker: [%s]---------", layerName or "")
					self._layerHookerSuccess = true
					self._finishHookerLayerName = layerName
					self:_removeLayerHooker()
					self._hookerLayer = layer
					self:_onHooker()
				-- 收到监听layer的退出事件，则移除该引导
				elseif flag == "exit" then
					__Log("-------[exit layer hooker: [%s]----------", layerName or "")
					self._layerHookerSuccess = false
					self._finishHookerLayerName = nil
					self:_removeLayerHooker()
				end
			end, self)
		end
	elseif not self._hookerLayerName then 
		self:_removeLayerHooker()
		self:_onHooker()		
	end
end

function GuideFilterLayer:resetFilterScene( scene )
	self._hookerScene = scene 
	if not scene or not self._hookerLayerName then 
		return 
	end

	local layer = self._hookerScene:getUILayerComponent(self._hookerLayerName)
	if layer then 
		self._layerHookerSuccess = true
		self._finishHookerLayerName = self._hookerLayerName
		self:_removeLayerHooker()
		self._hookerLayer = layer
		self:_onHooker()
	end
end

function GuideFilterLayer:prepareDataForStep( stepId )
	local guideInfo = newplay_guide_info.get(stepId)
	if not guideInfo then 
		__LogError("stepinfo is invalid! stepId=%d", stepId or 0)
	end

	-- 如果当前引导需要界面返回数据，或界面需要引导提供条件数据时，则通过
	-- __prepareDataForGuide__ 函数返回或传递，优先调用layer，否则调用scene。
	if guideInfo.prepare_data > 0 then
		self:callAfterDelayTime(0.1, nil, function ( ... )
			local prepareData = nil
			if self._hookerLayer and self._hookerLayer.__prepareDataForGuide__ then 
				prepareData = self._hookerLayer:__prepareDataForGuide__(guideInfo.click_param1)
			elseif self._hookerScene and self._hookerScene.__prepareDataForGuide__ then 
				prepareData = self._hookerScene:__prepareDataForGuide__(guideInfo.click_param1)
			end

			__Log("prepareData:stepid:%d", stepId)
			if prepareData then 
				dump(prepareData)
			end
			if prepareData and prepareData.origin and prepareData.size then 
				self._rectParam = prepareData
			end
			-- if guideInfo.click_widget == "" and guideInfo.width == 0 and prepareData then 
			-- 	self._rectParam = prepareData
			-- end
		end)

		-- if stepId == 49 then
		-- 	self:callAfterFrameCount(15, function (  )
		-- 		if guideInfo and self._hookerLayer and self._hookerLayer.newGuideShopping then
		-- 			self._hookerLayer:newGuideShopping(guideInfo.click_param1)
		-- 		end
		-- 	end)
		-- elseif stepId == 604 then 
		-- 	if guideInfo and self._hookerLayer and self._hookerLayer._moveToCell then 
		-- 		self._hookerLayer:_moveToCell(guideInfo.click_param1)
		-- 	end 
		-- end
	end

	-- 当需要被监听的控件是列表或翻页控件时，则需要禁止滑动功能
	if self._hookerLayer and guideInfo.click_widget then
		self:callAfterFrameCount(1, function ( ... )
			if self._hookerLayer then 
				local list = self._hookerLayer:getListViewByName(guideInfo.click_widget)
				if list then 
					__Log("disable list scroll:%s", guideInfo.click_widget or "")
					list:setScrollEnabled(false)
				else
					local page = self._hookerLayer:getNewPageViewByName(guideInfo.click_widget)
					if page then 
					__Log("disable newPageView scroll:%s", guideInfo.click_widget or "")
						page:setScrollEnabled(false)
					else
						page = self._hookerLayer:getPageViewByName(guideInfo.click_widget)
						if page then 
					__Log("disable pageView scroll:%s", guideInfo.click_widget or "")
							page:setScrollEnabled(false)
						end
					end
					--__Log("can't find list [%s] in cur layer", guideInfo.click_widget)
				end
			end
		end)		
	end

	-- 添加当前引导需要监听的协议
	if self._hookerEventName ~= "" then 
		__Log("prepareData: register event hooker:event=%s", self._hookerEventName or "")
		uf_eventManager:addEventListener(self._hookerEventName, handler(self, self._onReceiveHookerEvent), self)
	end
end

function GuideFilterLayer:recoveryDataAtFinishGuide(  )
	if (self._hookerSceneName == "DungeonGateScene" or self._hookerSceneName == "StoryDungeonGateScene" ) and self._hookerScene then
		self._hookerScene:setScrollEnable(true)
	end
	self:setVisible(false)
end

function GuideFilterLayer:_onHooker(  )
	if not self._layerHookerSuccess then
		return 
	end

	if self._hookerLayer and self._hookerLayer.closeAtReturn then 
		self._hookerLayer:closeAtReturn(false)
	end

	if self._shouldWaitEffect then 
		__Log("set effect callback at step:[%d]", self._curStepId)
		self._hookerLayer.__EFFECT_FINISH_CALLBACK__ = function ( ... )
			self:_onWaitEffectFinished( ... )
		end
	else
		-- if self._hookerLayer then 
		-- 	self._hookerLayer.__EFFECT_FINISH_CALLBACK__ = nil
		-- end
	end

	self:prepareDataForStep(self._curStepId)
	if self._hookerLayer and self._hookerWidgetName then
		self._hookerLayer:registerHooker(function ( name, intParam1, stringParam2 )
			if self._hookerWidgetName and self._hookerWidgetName == name then
				self:_onWidgetHookerEvent(intParam1, stringParam2)
			elseif "CCLayer" == name then
				--self:_onLayerHookerEvent(intParam1, stringParam2)
			end
		end)
	end

	local showFinger = function (  )
		if self._textId > 0 and self._hookerLayerName ~= "DungeonStoryTalkLayer" then 
			__Log("DungeonStoryTalkLayer:textId:%d", self._textId or 0)
			uf_notifyLayer:getGuideNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create(
					{storyId = self._textId, func = function ( ... )
			end }))
			self._textId = 0
		end

		local hookerRect = CCRectZero
		if self._rectParam.size.width ~= 0 and self._rectParam.size.height ~= 0 then
			hookerRect = self._rectParam
		elseif self._hookerWidgetName and self._hookerLayer then
			hookerRect = self._hookerLayer:getScreenRectWithWidget(self._hookerWidgetName)
			__Log("register widget:%s", self._hookerWidgetName or "")
			if self._zoomPercent < 100 then
				hookerRect = CCRectMake(hookerRect.origin.x + hookerRect.size.width * (100 - self._zoomPercent)/200,
				hookerRect.origin.y + hookerRect.size.height * (100 - self._zoomPercent)/200,
				hookerRect.size.width*self._zoomPercent/100, 
				hookerRect.size.height*self._zoomPercent/100 )
			end
		else
			__Log("use null rect")
		end	

		if not self._needMask then 
			hookerRect = CCRectMake(0, 0, self._maxFilterSize.width, self._maxFilterSize.height)
		end

		self:_resetHookerRect(hookerRect)
	end

__Log("self._hookerDelay:%d", self._hookerDelay)
	-- 如果需要延迟，则延迟后再显示手指
	if self._hookerDelay > 0 then 
		self._hookerWidgetRect = CCRectMake(0, 0, 0, 0)
		self:callAfterDelayTime(self._hookerDelay/1000, nil, function ( ... )
			showFinger()
		end)
	else
		showFinger()
	end	
end

function GuideFilterLayer:_resetHookerRect( rect )
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
		local fingerPos = ccp(self._hookerWidgetRect.origin.x + self._hookerWidgetRect.size.width/2,
			self._hookerWidgetRect.origin.y + self._hookerWidgetRect.size.height/2)
		self._fingerEffect:setPosition(fingerPos)
		self._fingerEffect:play()
		if self._hookerWidgetRect.origin.y < 10 then 
			self._fingerEffect:setRotation(210)
		else
			self._fingerEffect:setRotation(0)
		end

		if self._filterTip then 
			local tipSize = self._filterTip:getSize()

			if self._tipPos == 0 then
    			self._filterTip:setPosition(ccp( (self._maxFilterSize.width - tipSize.width)/2, fingerPos.y + 100))
    		else 
    			self._filterTip:setPosition(ccp( (self._maxFilterSize.width - tipSize.width)/2, fingerPos.y - 100 - tipSize.height))
    		end
    	end
    else
		if self._filterTip then
    		self._filterTip:setVisible(true)
    	end
	end
	self._fingerEffect:setVisible(showFingerFlag)

	if self._showFilterPanel then 
		self._filterPanel:setPosition(self._hookerWidgetRect.origin)
		self._filterPanel:setContentSize(self._hookerWidgetRect.size)
	end
end

function GuideFilterLayer:_resetHookerRectWithValue( x, y, width, height )
	self:_resetHookerRect(CCRectMake(x or 0, y or 0, width or 0, height or 0))
end

function GuideFilterLayer:onTouchBegin( xpos, ypos )
	-- __Log("hookerRect:(%d, %d, %d, %d), needMask:%d, xpos:%d, ypos:%d, contains:%d",
	-- 	self._hookerWidgetRect.origin.x, self._hookerWidgetRect.origin.y,
	-- 	self._hookerWidgetRect.size.width, self._hookerWidgetRect.size.height,
	-- 	self._needMask and 1 or 0, xpos, ypos, self._hookerWidgetRect:containsPoint(ccp(xpos, ypos)) and 1 or 0)
	--if self._hookerWidgetRect:containsPoint(ccp(xpos, ypos)) then
	if  G_WP8.CCRectContainXY(self._hookerWidgetRect, xpos, ypos) then
		if not self._needMask then 
			--self:_doHitHooker()
		end
		return false
	end

    return true
end

function GuideFilterLayer:onTouchCancel( xpos, ypos )
	self:onTouchEnd(xpos, ypos)
end

function GuideFilterLayer:onTouchEnd( xpos, ypos )
end

function GuideFilterLayer:_onWidgetHookerEvent( intParam1, stringParam2 )
	if not self._hookerWidgetName then
		return 
	end

	if stringParam2 == "CCSListViewEx" and intParam1 ~= 2 then 
		return 
	end

	__Log("widget hooker event: widgetName=%s", self._hookerWidgetName or "")
	self:_doHitHooker()
end

function GuideFilterLayer:_onReceiveHookerEvent( data )
	__Log("_onReceiveHookerEvent:curEvent=%s", self._hookerEventName or "")
	if not self._finishEventHooker and self._hookerEventName then
		self._finishEventHooker = true 
		self:_doHitHooker()
	end
end

function GuideFilterLayer:_doHitHooker( ... )
	__Log("_doHitHooker: eventName:%s, finish:%d, waitEffect=%d",
	 self._hookerEventName or "", self._finishEventHooker and 1 or 0, self._shouldWaitEffect and 1 or 0)
	
	if self._hookerEventName then 
		if self._finishEventHooker then 
			if self._shouldWaitEffect then 
				if self._stepCallback then
					self._stepCallback(1, self._finishEventHooker)
				end
				self:_removeLayerHooker()
				self:_stopCurrentFilter()
			else
				self:_onHitHooker()
			end
		else
			if self._shouldWaitEffect then 
				if self._stepCallback then
					self._stepCallback(1, self._finishEventHooker)
				end
			end
			self:_stopCurrentFilter()
		end
	else
		if self._shouldWaitEffect then 
			if self._stepCallback then
				self._stepCallback(1, self._finishEventHooker)
			end
			self:_removeLayerHooker()
			self:_stopCurrentFilter()
		else
			self:_onHitHooker()
		end
	end

	

	-- if self._hookerEventName and self._finishEventHooker then 
	-- 	self:_onHitHooker()
	-- elseif self._hookerEventName then 
	-- 	self:_stopCurrentFilter()
	-- elseif not self._shouldWaitEffect then 
	-- 	self:_onHitHooker()
	-- else
	-- end
end

function GuideFilterLayer:_onWaitEffectFinished( pauseGuide, ... )
	__Log("_onWaitEffectFinished: curStep:%d, pauseGuide:%d", self._curStepId, pauseGuide and 1 or 0)
	if pauseGuide then 
		self:_stopCurrentFilter()
	else
		self._shouldWaitEffect = false
		--self:_onHitHooker()
		self:_doHitHooker()
	end
end

function GuideFilterLayer:_onLayerHookerEvent( intParam1, stringParam2 )
	if self._hookerWidgetName then
		return 
	end

	--self:_onHitHooker()
end

function GuideFilterLayer:_removeLayerHooker(  )
	if self._hookerLayer then
		self._thirdHookerLayer = self._lastHookerLayer
		self._lastHookerLayer = self._hookerLayer
		__Log("-----remove hooker-----")
		--self._hookerLayer:removeHooker()
		self._hookerLayer = nil
	end
end

function GuideFilterLayer:_onHitHooker(  )
	if self._curStepId == 0  then
		return 
	end

	self._curStepId = 0

	--self:setVisible(false)
	self:_stopCurrentFilter()

	if self._stepCallback then
		self._stepCallback(0)
	end
end

function GuideFilterLayer:_stopCurrentFilter( ... )
	if self._hookerLayerName then
		--UFCCSUIHooker.unHookerWithLayerName(self._hookerLayerName)
	end

	self:_resetHookerRect(CCRectMake(0, 0, 0, 0))

	if self._fingerEffect then
		self._fingerEffect:setVisible(false)
		self._fingerEffect:stop()
	end
	if self._filterTip then
    	self._filterTip:setVisible(false)
    end
end

return GuideFilterLayer
