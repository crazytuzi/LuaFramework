--HerobuZhengLayer.lua


local HerobuZhengLayer = class ("HerobuZhengLayer", UFCCSModelLayer)

HerobuZhengLayer._SPRITE_OFFSET_Y = 0
function HerobuZhengLayer.create(  )
	return HerobuZhengLayer.new("ui_layout/knight_buzheng.json", Colors.modelColor)
end

function HerobuZhengLayer:ctor( ... )
	self._heroImgs = {}
	self._heroNames = {}
	self._editTeamId = 1

	self._closeCallback = nil
	
	self._touchedSprite = nil
	self._moveStartPt = ccp(0, 0)
	self._lastMovePtx = 0
	self._lastMovePty = 0
	self._moveStartIndex = 0

	self._heroBtns = {}
	self._formationArr = {}
	self._oldformationArr = {}

	self._selectedKnightBtn = nil
	self._curKnightBack = nil

	self.super.ctor(self, ...)

	self:showAtCenter(true)
end

function HerobuZhengLayer:onLayerLoad( ... )
	self:addCheckBoxGroupItem(1, "CheckBox_main")
	self:addCheckBoxGroupItem(1, "CheckBox_addition")

	self:setCheckStatus(1, "CheckBox_main")

	self._heroImgs[1] = self:getWidgetByName("Image_back_1")
	self._heroImgs[2] = self:getWidgetByName("Image_back_2")
	self._heroImgs[3] = self:getWidgetByName("Image_back_3")
	self._heroImgs[4] = self:getWidgetByName("Image_back_4")
	self._heroImgs[5] = self:getWidgetByName("Image_back_5")
	self._heroImgs[6] = self:getWidgetByName("Image_back_6")

	self._heroNames[1] = self:getLabelByName("Label_name_1")
	self._heroNames[2] = self:getLabelByName("Label_name_2")
	self._heroNames[3] = self:getLabelByName("Label_name_3")
	self._heroNames[4] = self:getLabelByName("Label_name_4")
	self._heroNames[5] = self:getLabelByName("Label_name_5")
	self._heroNames[6] = self:getLabelByName("Label_name_6")

	self:regisgerWidgetTouchEvent("Image_back_1", function ( widget, param )
		self:_onHeroTouched( widget, 1, param)
	end)
	self:regisgerWidgetTouchEvent("Image_back_2", function ( widget, param )
		self:_onHeroTouched( widget, 2, param)
	end)
	self:regisgerWidgetTouchEvent("Image_back_3", function ( widget, param )
		self:_onHeroTouched( widget, 3, param)
	end)
	self:regisgerWidgetTouchEvent("Image_back_4", function ( widget, param )
		self:_onHeroTouched( widget, 4, param)
	end)
	self:regisgerWidgetTouchEvent("Image_back_5", function ( widget, param )
		self:_onHeroTouched( widget, 5, param)
	end)
	self:regisgerWidgetTouchEvent("Image_back_6", function ( widget, param )
		self:_onHeroTouched( widget, 6, param)
	end)

	self:enableAudioEffectByName("Button_close", false)
	
	self:registerBtnClickEvent("Button_close", function ( widget )
		if self._closeCallback then
			self._closeCallback()
		end
		self:animationToClose()
		--self:close()
		local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	end)
	self:registerBtnClickEvent("Button_save", function ( widget )
		self:_onSaveClicked()
	end)

	for loopi = 1, 6 do 
    	label = self:getLabelByName("Label_name_"..loopi)
    	if label then
    		label:enableStrokeEx(Colors.strokeBrown, 1)
    	end
    end

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_FORMATION, self._onChangeFormation, self)
end

function HerobuZhengLayer:onLayerUnload(  )
	uf_eventManager:removeListenerWithTarget(self)
end

function HerobuZhengLayer:onLayerEnter( ... )
	self:closeAtReturn(true)

	self:_initKnightsWithTeam(1)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function HerobuZhengLayer:animationShow( func )
	self._closeCallback = func
end

function HerobuZhengLayer:onBackKeyEvent( ... )
    if self._closeCallback then
		self._closeCallback()
	end

	return false
end

function HerobuZhengLayer:_onChangeFormation( ret )
	if ret == NetMsg_ERROR.RET_OK then
		--G_MovingTip:showMovingTip(G_lang:get("LANG_SAVE_KNIGHT_SUCCESS"))
		--self:close()
	end
end

function HerobuZhengLayer:_initKnightsWithTeam( teamId )
	local index = 1
	local formationIndex = 0
	local knightId = 0
	self._editTeamId = teamId or 1
	require("app.cfg.knight_info")
	local Colors = require("app.setting.Colors")

	while index <= 6 do 
		formationIndex, knightId = G_Me.formationData:getFormationIndexAndKnighId(teamId, index)

		if formationIndex ~= 0 and knightId ~= 0 then
			if self._heroImgs and self._heroImgs[index] then
				self._heroImgs[index]:removeAllNodes()

				local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId) 		
				local knightInfo = knight_info.get(baseId)
    			local resId = knightInfo and knightInfo.res_id or 0

    			if knightId == G_Me.formationData:getMainKnightId() then 
					resId = G_Me.dressData:getDressedPic()
				end

				heroSprite =  CCSprite:create(G_Path.getKnightIcon(resId))
    			self._heroImgs[index]:addNode(heroSprite, 0, 1000)
    			heroSprite:setPosition(ccp(0, HerobuZhengLayer._SPRITE_OFFSET_Y))
    			self._formationArr[index] = formationIndex
    			
    			local colorImgPath = G_Path.getAddtionKnightColorImage(knightInfo and knightInfo.quality or 1)
    			local colorSprite = CCSprite:createWithSpriteFrameName(colorImgPath)
    			local pt = heroSprite:getAnchorPointInPoints()
    			colorSprite:setPosition(pt)
    			heroSprite:addChild(colorSprite)

    			if self._heroNames and self._heroNames[index] then
    				local heroName = knightInfo and knightInfo.name or ""
    				self._heroNames[index]:setColor(Colors.getColor(knightInfo.quality) or ccc3(255, 255, 255))
    				self._heroNames[index]:setText(heroName ~= nil and heroName or "")    				
    			end
    		end    		
    	else 
    		if self._heroImgs and self._heroImgs[index] then
    			self._formationArr[index] = 0
    			self._heroImgs[index]:removeAllNodes()
    		end
    		if self._heroNames and self._heroNames[index] then
    			self._heroNames[index]:setText("")
    		end
    	end    

    	index = index + 1	
	end

	self._oldformationArr = self._formationArr
end

function HerobuZhengLayer.showBuZhengLayer( func )
	if not G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").PET) then
		local buzhengLayer = HerobuZhengLayer.create()
		uf_sceneManager:getCurScene():addChild(buzhengLayer)
		buzhengLayer:animationShow(func)
		return buzhengLayer
	else
		local buzhengPetLayer = require("app.scenes.hero.HerobuZhengPetLayer").create()
		uf_sceneManager:getCurScene():addChild(buzhengPetLayer)
		buzhengPetLayer:animationShow(func)
		return buzhengPetLayer
	end
end


function HerobuZhengLayer:_onHeroTouched( widget, index, param )
	if param == TOUCH_EVENT_BEGAN  then
		self._touchedSprite = widget:getNodeByTag(1000)
		self._moveStartPt = widget:getTouchStartPos()
		self._lastMovePtx = self._moveStartPt.x
		self._lastMovePty = self._moveStartPt.y
		self._moveStartIndex = index

		if self._touchedSprite == nil then
			return 
		end

		local spritePt = self:convertToNodeSpace(ccp(self._moveStartPt.x, self._moveStartPt.y))
		self._touchedSprite:retain()
		self._heroImgs[self._moveStartIndex]:removeNode(self._touchedSprite)
		--self._touchedSprite:removeFromParentAndCleanup(true)
		self:addChild(self._touchedSprite, 0, 1000)
		self._touchedSprite:setPosition(spritePt.x, spritePt.y)
		self._touchedSprite:release()

		local label = self._heroNames[self._moveStartIndex]
		if label then 
			local nameCopy = nil
			if device.platform == "wp8" or device.platform =="winrt" then
				nameCopy = cc.XXLabel:createWithTTF(label:getStringValue(), label:getFontName(), label:getFontSize())
				nameCopy:enableOutline(cc.c4b(Colors.strokeBrown.r, Colors.strokeBrown.g, Colors.strokeBrown.b, 255), 1)
			else
				nameCopy = CCLabelTTF:create(label:getStringValue(), label:getFontName(), label:getFontSize())
				nameCopy:createStroke(Colors.strokeBrown, 1)
			end
			label:setVisible(false)
			local size = self._touchedSprite:getContentSize()
			if nameCopy then 
				nameCopy:setColor(label:getColor())			
				self._touchedSprite:addChild(nameCopy, 1001, 1001)
				local labelSize = nameCopy:getContentSize()
				nameCopy:setPosition(ccp(size.width/2, - size.height/2 + 5))
			end
		end
	elseif param == TOUCH_EVENT_MOVED then
		if self._touchedSprite ~= nil then
			local curMovePt = widget:getTouchMovePos()
			local oldX, oldY = self._touchedSprite:getPosition()
			local newX = oldX + curMovePt.x - self._lastMovePtx
			local newY = oldY + curMovePt.y - self._lastMovePty
			self._touchedSprite:setPosition(newX, newY)

			self._lastMovePtx = curMovePt.x
			self._lastMovePty = curMovePt.y
		end
	elseif param == TOUCH_EVENT_ENDED  then
		local endPos = widget:getTouchEndPos()
		local ptx, pty = widget:convertToWorldSpaceXY(endPos.x, endPos.y)
		self:_onMoveSpriteFinish(ptx, pty)
	elseif param == TOUCH_EVENT_CANCELED  then
		--local ptx, pty = widget:convertToWorldSpace(ccp(self._lastMovePtx, self._lastMovePty))
		self:_onMoveSpriteFinish(self._lastMovePtx, self._lastMovePty)
	end
end

function HerobuZhengLayer:_onMoveSpriteFinish( ptx, pty )
	if self._touchedSprite == nil then
		return 
	end

	local hitPassIndex = 0
	local hitPassWidget = nil
	for i, value in pairs(self._heroImgs) do
		if value:hitTest(ccp(ptx, pty)) and hitPassIndex == 0 then
			hitPassIndex = i 
			hitPassWidget = value
		end
	end

	local label = self._heroNames[self._moveStartIndex]
	if label then 
		label:setVisible(true)
	end

	if hitPassIndex == self._moveStartIndex or hitPassWidget == nil then
		self._touchedSprite:retain()
		self:removeChild(self._touchedSprite)
		--self._touchedSprite:removeFromParentAndCleanup(true)
		self._heroImgs[self._moveStartIndex]:addNode(self._touchedSprite, 0, 1000)
		self._touchedSprite:release()
		self._touchedSprite:setPosition(ccp(0, HerobuZhengLayer._SPRITE_OFFSET_Y))
		
		self._touchedSprite:removeChildByTag(1001)
		self._touchedSprite = nil
		return 
	end

	local knight1Name = ""
	local knight2Name = ""
	local knight1Clr = ccc3(255, 255, 255)
	local knight2Clr = ccc3(255, 255, 255)
	if self._heroNames[self._moveStartIndex] then
		knight1Name = self._heroNames[self._moveStartIndex]:getStringValue()
		local clr = self._heroNames[self._moveStartIndex]:getColor()
		knight1Clr = ccc3(clr.r, clr.g, clr.b)
	end

	if self._heroNames[hitPassIndex] then
		knight2Name = self._heroNames[hitPassIndex]:getStringValue()
		local clr = self._heroNames[hitPassIndex]:getColor()
		knight2Clr = ccc3(clr.r, clr.g, clr.b)
	end

	local hitWidgetFormationIndex = self._formationArr[hitPassIndex]
	self._formationArr[hitPassIndex] = self._formationArr[self._moveStartIndex]
	self._formationArr[self._moveStartIndex] = hitWidgetFormationIndex

	local moveStartWidget = self._heroImgs[self._moveStartIndex]
	local hitWidgetSprite = hitPassWidget:getNodeByTag(1000)

	self._touchedSprite:retain()
	self._touchedSprite:removeFromParentAndCleanup(true)

	if hitWidgetSprite ~= nil then
		hitWidgetSprite:retain()
		hitPassWidget:removeNodeByTag(1000)
		moveStartWidget:addNode(hitWidgetSprite, 0, 1000)
		hitWidgetSprite:release()
		hitWidgetSprite:setPosition(ccp(0, HerobuZhengLayer._SPRITE_OFFSET_Y))
	end
	
	self._touchedSprite:setPosition(ccp(0, HerobuZhengLayer._SPRITE_OFFSET_Y))
	hitPassWidget:addNode(self._touchedSprite, 0, 1000)
	self._touchedSprite:release()

	if self._heroNames[hitPassIndex] then
		self._heroNames[hitPassIndex]:setColor(knight1Clr)
		self._heroNames[hitPassIndex]:setText(knight1Name)
	end

	if self._heroNames[self._moveStartIndex] then
		self._heroNames[self._moveStartIndex]:setColor(knight2Clr)
		self._heroNames[self._moveStartIndex]:setText(knight2Name)
	end

	self._touchedSprite:removeChildByTag(1001)
	self._touchedSprite = nil
	self._moveStartIndex = 0

	self:_onSaveClicked()
end

function HerobuZhengLayer:_onSaveClicked(  )
	G_HandlersManager.cardHandler:changeFormation(self._editTeamId, self._formationArr)
end


return HerobuZhengLayer
