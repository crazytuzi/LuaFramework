
local QESkeletonViewer = class("QESkeletonViewer", function()
    return display.newScene("QESkeletonViewer")
end)

local QEBattleViewer = import(".QEBattleViewer")

QESkeletonViewer.ACTOR_MODE = 1
QESkeletonViewer.EFFECT_MODE = 2
QESkeletonViewer.EDIT_MODE = 3

QESkeletonViewer.EFFECT_EDIT_MODE = 1
QESkeletonViewer.EFFECT_PLAY_MODE = 2

QESkeletonViewer.EFFECT_FRAME_PLAY = 1
QESkeletonViewer.EFFECT_CONTINUE_PLAY = 2

-- effect attacher
function QESkeletonViewer:createEffectAttacher(skeleton, frontFile, backFile, actorHeight, effectID, zOrder)
	local _t = {}
	local strings = nil
	_t["dummy"] = {}
	_t["offset_x"] = {type = "number", range = nil, control = {0.1, 1}, value = 0}
	_t["offset_y"] = {type = "number", range = nil, control = {0.1, 1}, value = 0}
	_t["scale"] = {type = "number", range = nil, control = {0.01, 0.1}, value = 1}
	_t["rotation"] = {type = "number", range = nil, control = {0.1, 1}, value = 0}
	_t["play_speed"] = {type = "number", range = nil, control = {0.01, 0.1}, value = 1}
	_t["delay"] = {type = "number", range = nil, control = {0.01, 0.1}, value = 0}
	_t["is_hsi_enabled"] = {type = "boolean", range = nil, control = nil, value = false}
	_t["render_as_whole"] = {type = "boolean", range = nil, control = nil, value = false}
	_t["hue"] = {type = "number", range = {-180, 179, true}, control = {1, 10}, value = 0}
	_t["saturation"] = {type = "number", range = {-1, 1, false}, control = {0.01, 0.1}, value = 0}
	_t["intensity"] = {type = "number", range = {-1, 1, false}, control = {0.01, 0.1}, value = 0}
	_t["is_flip_with_actor"] = {type = "boolean", range = nil, control = nil, value = false}
	_t["id"] = {type = "string", range = nil, control = nil, value = effectID}
	local frontEffectFileName = frontFile
	if frontEffectFileName ~= nil and string.len(frontEffectFileName) > 0 then
		strings = string.split(frontEffectFileName, "/")
		if #strings <= 1 then
			strings = string.split(frontEffectFileName, "\\")
		end
		frontEffectFileName = strings[#strings]
	end
	_t["file"] = {type = "string", value = frontEffectFileName}
	local backEffectFileName = backFile
	if backEffectFileName ~= nil and string.len(backEffectFileName) > 0 then
		strings = string.split(backEffectFileName, "/")
		if #strings <= 1 then
			strings = string.split(backEffectFileName, "\\")
		end
		backEffectFileName = strings[#strings]
	end
	_t["file_back"] = {type = "string", value = backEffectFileName}
	local _currentTime = 0
	local _visible = true
	local function getType(key)
		local prop = _t[key]
		if prop then
			return prop.type
		end
	end
	local function setValue(key, value)
		if value ~= nil then
			local prop = _t[key]
			if prop then
				prop.value = value
			end
		end
	end
	local function getValue(key)
		local prop = _t[key]
		if prop then
			return prop.value
		end
	end
	local function getRange(key)
		local prop = _t[key]
		if prop then
			return prop.range
		end
	end
	local function getControl(key)
		local prop = _t[key]
		if prop then
			return prop.control
		end
	end
	local frontEffectNode, frontEffect
	local backEffectNode, backEffect
	local function _updateTime()
		local updateTime = _currentTime
		-- if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		-- 	return
		-- end
		-- if self._effectPlayMode ~= QESkeletonViewer.EFFECT_FRAME_PLAY then
		-- 	return 
		-- end
		local delay = _t["delay"].value
		if updateTime <= delay then
			if frontEffectNode ~= nil then
				frontEffectNode:setVisible(false)
			end
			if backEffectNode ~= nil then
				backEffectNode:setVisible(false)
			end
		else
			if frontEffectNode ~= nil then
				frontEffectNode:setVisible(true)
				frontEffect:playAnimation(EFFECT_ANIMATION, self._isLoopAnimation)
				local deltaTime = updateTime - delay
				local frames = math.floor(deltaTime * 30) -- equal to (deltaTime / ( 1.0 / 30))
				local time = frames / 30
				if time < 1 / 60 then
					time = 0;
				end
				frontEffect:updateAnimation(time)
			end
			if backEffectNode ~= nil then
				backEffectNode:setVisible(true)
				backEffect:playAnimation(EFFECT_ANIMATION, self._isLoopAnimation)
				local deltaTime = updateTime - delay
				local frames = math.floor(deltaTime * 30) -- equal to (deltaTime / ( 1.0 / 30))
				local time = frames / 30
				if time < 1 / 60 then
					time = 0;
				end
				backEffect:updateAnimation(time)
			end
		end
	end
	local function flush()
		local dummy = _t["dummy"].value
		local offset_x = _t["offset_x"].value
		local offset_y = _t["offset_y"].value
		local scale = _t["scale"].value
		local rotation = _t["rotation"].value
		local play_speed = _t["play_speed"].value
		local delay = _t["delay"].value
		local is_hsi_enabled = _t["is_hsi_enabled"].value
		local render_as_whole = _t["render_as_whole"].value
		local hue = _t["hue"].value
		local saturation = _t["saturation"].value
		local intensity = _t["intensity"].value
		local is_flip_with_actor = _t["is_flip_with_actor"].value
		if frontEffectNode then
			if frontEffectNode:getParent() == self._skeletonRoot then
				frontEffectNode:removeFromParent()
			else
				skeleton:detachNodeToBone(frontEffectNode)
			end
			frontEffectNode, frontEffect = nil, nil
		end
		if backEffectNode then
			if backEffectNode:getParent() == self._skeletonRoot then
				backEffectNode:removeFromParent()
			else
				skeleton:detachNodeToBone(backEffectNode)
			end
			backEffectNode, backEffect = nil, nil
		end
		local positionBottom = {x = 0, y = 0}
		local positionCenter = {x = 0, y = actorHeight * 0.5}
		local positionTop = {x = 0, y = actorHeight}
		-- front effect
		if not frontEffect and frontFile and string.len(frontFile) > 0 then
            local fileName
            if string.find(frontFile, "fca/", 1, true) then
                frontEffect = QFcaSkeletonView_cpp:createFcaSkeletonView(string.sub(frontFile, string.find(frontFile, "[^/]+$")), "effect", false)
                frontEffect.isFca = true
               	frontEffect:setScale(0.21/(self._message.actor_scale or 1.0))
                frontEffect:setScaleX(-frontEffect:getScaleX())
                function frontEffect:setColor2(...)
                end
            else
                local startIndex, endIndex = string.find(frontFile, ".json")
                fileName = string.sub(frontFile, 1, startIndex - 1)
                frontEffect = QSkeletonView:create(fileName)
            end
			frontEffectNode = CCNode:create()
			frontEffectNode:setZOrder(zOrder)
			frontEffectNode:addChild(frontEffect)
			if frontEffect.isFca then
				frontEffect:setPosition(offset_x * (0.21/(self._message.actor_scale or 1.0)), offset_y * (0.21/(self._message.actor_scale or 1.0)))
			else
				frontEffect:setPosition(offset_x, offset_y)
			end
			frontEffect:setSkeletonScaleX(scale)
			frontEffect:setSkeletonScaleY(scale)
			frontEffect:setRotation(rotation)
			frontEffect:setAnimationScale(play_speed)
			if dummy == nil or string.len(dummy) <= 0 or dummy == "No Dummy" then
				self._skeletonRoot:addChild(frontEffectNode)
			else
				if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
					if dummy == DUMMY.TOP then
						local x, y = frontEffect:getPosition()
						frontEffect:setPosition(x + positionTop.x, y + positionTop.y)
					elseif dummy == DUMMY.CENTER then
						local x, y = frontEffect:getPosition()
						frontEffect:setPosition(x + positionCenter.x, y + positionCenter.y)
					end
					skeleton:attachNodeToBone(nil, frontEffectNode, false, is_flip_with_actor)
				else
					skeleton:attachNodeToBone(dummy, frontEffectNode, false, is_flip_with_actor)
				end
			end
		end
		-- back effect
		if backFile and string.len(backFile) > 0 then
            local fileName
            if string.find(backFile, "fca/", 1, true) then
                backEffect= QFcaSkeletonView_cpp:createFcaSkeletonView(string.sub(backFile, string.find(backFile, "[^/]+$")), "effect", false)
                backEffect.isFca = true
               	backEffect:setScale(0.21/(self._message.actor_scale or 1.0))
                backEffect:setScaleX(-backEffect:getScaleX())
                function backEffect:setColor2(...)
                end
            else
                local startIndex, endIndex = string.find(backFile, ".json")
                fileName = string.sub(backFile, 1, startIndex - 1)
                backEffect= QSkeletonView:create(fileName)
            end
			backEffectNode = CCNode:create()
			backEffectNode:setZOrder(zOrder)
			backEffectNode:addChild(backEffect)
			if backEffect.isFca then
				backEffect:setPosition(offset_x * (0.21/(self._message.actor_scale or 1.0)), offset_y * (0.21/(self._message.actor_scale or 1.0)))
			else
				backEffect:setPosition(offset_x, offset_y)
			end
			backEffect:setSkeletonScaleX(scale)
			backEffect:setSkeletonScaleY(scale)
			backEffect:setRotation(rotation)
			backEffect:setAnimationScale(play_speed)
			if dummy == nil or string.len(dummy) <= 0 or dummy == "No Dummy" then
				self._skeletonRoot:addChild(backEffectNode)
			else
				if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
					if dummy == DUMMY.TOP then
						local x, y = backEffect:getPosition()
						backEffect:setPosition(x + positionTop.x, y + positionTop.y)
					elseif dummy == DUMMY.CENTER then
						local x, y = backEffect:getPosition()
						backEffect:setPosition(x + positionCenter.x, y + positionCenter.y)
					end
					skeleton:attachNodeToBone(nil, backEffectNode, true, is_flip_with_actor)
				else
					skeleton:attachNodeToBone(dummy, backEffectNode, true, is_flip_with_actor)
				end
			end
		end
		skeleton:updateAnimation(0)

		if is_hsi_enabled and hue and saturation and intensity then
			hue = math.floor((hue + 180) / 360 * 255)
			saturation = (saturation + 1) / 2 * 255
			intensity = (intensity + 1) / 2 * 255
			if render_as_whole and false then
				if frontEffect then
		            frontEffect:setScissorRects(
		                CCRect(0, 0, 0, 0),
		                CCRect(0, 0, 0, 0),
		                CCRect(0, 0, 0, 0),
		                CCRect(0, 0, 0, 0)
		            )
		            frontEffect:setScissorEnabled(true)
		            frontEffect:getRenderTextureSprite():setColor(ccc3(hue, saturation, intensity))
		            frontEffect:getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureHSI)
		        end
		        if backEffect then
		            backEffect:setScissorRects(
		                CCRect(0, 0, 0, 0),
		                CCRect(0, 0, 0, 0),
		                CCRect(0, 0, 0, 0),
		                CCRect(0, 0, 0, 0)
		            )
		            backEffect:setScissorEnabled(true)
		            backEffect:getRenderTextureSprite():setColor(ccc3(hue, saturation, intensity))
		            backEffect:getRenderTextureSprite():setShaderProgram(qShader.Q_ProgramPositionTextureHSI)
		        end
			else
				if frontEffect then
		            frontEffect:setScissorEnabled(false)
					setNodeShaderProgram(frontEffect, qShader.Q_ProgramPositionTextureColorHSI)
					frontEffect:setColor2(ccc4(hue, saturation, intensity, 0))
				end
				if backEffect then
		            backEffect:setScissorEnabled(false)
					setNodeShaderProgram(backEffect, qShader.Q_ProgramPositionTextureColorHSI)
					backEffect:setColor2(ccc4(hue, saturation, intensity, 0))
				end
			end
		else
			if frontEffect then
	            frontEffect:setScissorEnabled(false)
				setNodeShaderProgram(frontEffect, qShader.CC_ProgramPositionTextureColor)
				frontEffect:setColor2(ccc4(hue, saturation, intensity, 0))
			end
			if backEffect then
	            backEffect:setScissorEnabled(false)
				setNodeShaderProgram(backEffect, qShader.CC_ProgramPositionTextureColor)
				backEffect:setColor2(ccc4(hue, saturation, intensity, 0))
			end
		end

		_updateTime()
	end
	local function pause()
		if skeleton ~= nil then
			skeleton:pauseAnimation()
		end
		if frontEffect ~= nil then
			frontEffect:pauseAnimation()
		end
		if backEffect ~= nil then
			backEffect:pauseAnimation()
		end
	end
	local function updateTime(time)
		_currentTime = time
		_updateTime()
	end
	local function rewind()
		_currentTime = 0
		_updateTime()
		-- if frontEffectNode ~= nil then
		-- 	frontEffect:playAnimation(EFFECT_ANIMATION, false)
		-- 	frontEffect:updateAnimation(0)
		-- end
		-- if backEffectNode ~= nil then
		-- 	backEffect:playAnimation(EFFECT_ANIMATION, false)
		-- 	backEffect:updateAnimation(0)
		-- end
	end
	local function isVisible()
		return _visible
	end
	local function setVisible(value)
		_visible = value
		if frontEffect then
			frontEffect:setVisible(not not _visible)
		end
		if backEffect then
			backEffect:setVisible(not not _visible)
		end
	end
	return {getType = getType, setValue = setValue, getValue = getValue, getRange = getRange, getControl = getControl, updateTime = updateTime,
			pause = pause, flush = flush, rewind = rewind, isVisible = isVisible, setVisible = setVisible}
end

function QESkeletonViewer:createBooleanRangeMenu(key, menu, infomationNode, positionX, deltaX, positionY)
	local button = nil
	button = ui.newTTFLabelMenuItem( {
		listener = function()
				self._currentAttacher.setValue(key, not self._currentAttacher.getValue(key))
				self._currentAttacher.flush()
				self._currentAttacher.pause()
				button:setString(self._currentAttacher.getValue(key) and "YES" or "NO")
			end,
		text = self._currentAttacher.getValue() and "YES" or "NO",
		font = global.font_monaco,
		color = display.COLOR_WHITE,
		size = 20} )
	button:setAnchorPoint(ccp(0.0, 0.5))
	button:setPosition(positionX + deltaX * 1.5, positionY)
	menu:addChild(button)

	if self._booleanButtons == nil then
		self._booleanButtons = {}
	end
	self._booleanButtons[key] = button
end

function QESkeletonViewer:createNumberRangeMenu(key, menu, infomationNode, positionX, deltaX, positionY)
	local valueLabel = ui.newTTFLabel( {
		text = string.format("%.2f", self._currentAttacher.getValue(key)),
		font = global.font_monaco,
		color = display.COLOR_WHITE,
		size = 20 } )
	valueLabel:setAnchorPoint(ccp(0.0, 0.5))
	valueLabel:setPosition(positionX + deltaX + 40, positionY)
	infomationNode:addChild(valueLabel)
	local function updateValue(dValue)
		local range = self._currentAttacher.getRange(key)
		local value = self._currentAttacher.getValue(key) + dValue
		if range and range[1] and range[2] then
			if range[3] == true then
				value = math.wrap(value, range[1], range[2])
			else
				value = math.clamp(value, range[1], range[2])
			end
		end
		self._currentAttacher.setValue(key, value)
		self._currentAttacher.flush()
		self._currentAttacher.pause()
		valueLabel:setString(string.format("%0.2f", value))
	end
	local decreaseMoreButton = newTTFLabelMenuItem( {
			listener = function() updateValue(-self._currentAttacher.getControl(key)[2]) end,
			text = "<", 
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20} )
	decreaseMoreButton:setTouchEnabled(true)
	decreaseMoreButton:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	decreaseMoreButton:setAnchorPoint(ccp(0.0, 0.5))
	decreaseMoreButton:setPosition(positionX + deltaX, positionY)
	menu:addChild(decreaseMoreButton)
	local decreaseButton = newTTFLabelMenuItem( {
			listener = function() updateValue(-self._currentAttacher.getControl(key)[1]) end,
			text = "<", 
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20} )
	decreaseButton:setTouchEnabled(true)
	decreaseButton:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	decreaseButton:setAnchorPoint(ccp(0.0, 0.5))
	decreaseButton:setPosition(positionX + deltaX + 20, positionY)
	menu:addChild(decreaseButton)
	local increaseButton = newTTFLabelMenuItem( {
			listener = function() updateValue(self._currentAttacher.getControl(key)[1]) end,
			text = ">", 
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20} )
	increaseButton:setTouchEnabled(true)
	increaseButton:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	increaseButton:setAnchorPoint(ccp(0.0, 0.5))
	increaseButton:setPosition(positionX + deltaX + 100, positionY)
	menu:addChild(increaseButton)
	local increaseMoreButton = newTTFLabelMenuItem( {
			listener = function() updateValue(self._currentAttacher.getControl(key)[2]) end,
			text = ">", 
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20} )
	increaseMoreButton:setTouchEnabled(true)
	increaseMoreButton:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	increaseMoreButton:setAnchorPoint(ccp(0.0, 0.5))
	increaseMoreButton:setPosition(positionX + deltaX + 120, positionY)
	menu:addChild(increaseMoreButton)
	
	if self._numberLabels == nil then
		self._numberLabels = {}
	end
	self._numberLabels[key] = valueLabel
end

function QESkeletonViewer:syncCurrentAttacher()
	assert(self._currentAttacher, "")
	local attacher = self._currentAttacher
	for key, button in pairs(self._booleanButtons or {}) do
		button:setString(attacher.getValue(key) and "YES" or "NO")
	end
	for key, label in pairs(self._numberLabels or {}) do
		label:setString(string.format("%0.2f", attacher.getValue(key)))
	end
	attacher.flush()
	attacher.pause()
end

function QESkeletonViewer:ctor(options)
	-- background
	self:addChild(CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height))

	self._maps = {
		"not_exist.jpg",
		"arena.jpg",
		"booty_bay.jpg",
		"deadmine01.jpg",
		"deadmine02.jpg",
		"dwarf_cellar.jpg",
		"scarlet_monastery.jpg",
		"scarlet_monastery02.jpg",
		"scarlet_monastery03.jpg",
		"shadowfang_keep01.jpg",
		"shadowfang_keep02.jpg",
		"wailing_caverns01.jpg",
		"wailing_caverns02.jpg",
		"wailing_caverns03.jpg",
		"wailing_caverns04.jpg",
		"zulfarrk01.jpg",
		"zulfarrk02.jpg",
	}
	self._mapIndex = 1
	self._background = CCSprite:create("map/arena.jpg")
	self._background:setScale(UI_DESIGN_WIDTH / 1024)
	self._background:setPosition(display.cx, display.cy)
	self:addChild(self._background)
	self._background:setVisible(false)

	self._redOverlay = 255
	self._greenOverlay = 255
	self._yellowOverlay = 255
	self._opacityOverlay = 255

	-- coordinate axis
	self._axisNode = CCNode:create()
	self:addChild(self._axisNode)
	local horizontalLine = CCDrawNode:create()
	horizontalLine:drawLine({-display.cx, 0}, {display.cx, 0})
	self._axisNode:addChild(horizontalLine)
	local verticalLine = CCDrawNode:create()
	verticalLine:drawLine({0, -display.cy}, {0, display.height})
	self._axisNode:addChild(verticalLine)

	self._skeletonRoot = CCNode:create()
	self:addChild(self._skeletonRoot)
	self._skeletonRoot:setScale(UI_DESIGN_WIDTH / BATTLE_SCREEN_WIDTH)

	self._infomationNode = CCNode:create()
	self:addChild(self._infomationNode)
	self._infomationNode:setPosition(0, display.height)

	self._menu = CCMenu:create()
	self:addChild(self._menu)
	self._menu:setPosition(0, display.height)
end

function QESkeletonViewer:cleanup()
	if self._frameUpdateId ~= nil then
		scheduler.unscheduleGlobal(self._frameUpdateId)
		self._frameUpdateId = nil
	end

	self._skeletonRoot:removeAllChildren()
	self._skeleton = nil
	self._frontEffect = nil
	self._backEffect = nil

	self._infomationNode:removeAllChildren();
	self._menu:removeAllChildren();
	self._currentAnimation = nil
end

function QESkeletonViewer:onReceiveData(message)
	if message == nil then
		return;
	end

	self._message = message

	if self._message.actor_scale then
		self._message.actor_scale = math.abs(self._message.actor_scale)
	end

	self:cleanup()

	if self._message.message == "display_actor" then
		self:onDisplayActor()
	elseif self._message.message == "display_effect" then
		self:onDisplayEffect()
	elseif self._message.message == "edit_effect" then
		self:onEditEffect()
	end
end

-- background
function QESkeletonViewer:_getCurrentBackgroundImage()
	return self._maps[self._mapIndex]
end

function QESkeletonViewer:_changeBackgroundImage()
	if self._mapIndex <= 0 then
		self._mapIndex = #self._maps
	end

	if self._mapIndex > #self._maps then
		self._mapIndex = 1
	end

	local imageFile = "map/" .. self._maps[self._mapIndex]
	local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(imageFile)
	if CCFileUtils:sharedFileUtils():isFileExist(fullPath) then
		self._background:setTexture(CCTextureCache:sharedTextureCache():addImage(imageFile))
		self._background:setVisible(true)
	else
		self._background:setVisible(false)
	end
end

function QESkeletonViewer:_nextBackgroundImage()
	self._mapIndex = self._mapIndex + 1
	self:_changeBackgroundImage()
	if self._currentBackgroundImageLabel ~= nil then
		self._currentBackgroundImageLabel:setString(self:_getCurrentBackgroundImage())
	end
end

function QESkeletonViewer:_previousBackgroundImage()
	self._mapIndex = self._mapIndex - 1
	self:_changeBackgroundImage()
	if self._currentBackgroundImageLabel ~= nil then
		self._currentBackgroundImageLabel:setString(self:_getCurrentBackgroundImage())
	end
end

-- actor display

function QESkeletonViewer:onDisplayBoneClicked()
	if self._isDisplayBone == true then
		self._boneCheckMenu:setString("No")
		self._skeleton:displayBones(false)
		self._isDisplayBone = false
	else
		self._boneCheckMenu:setString("Yes")
		self._skeleton:displayBones(true)
		self._isDisplayBone = true
	end
end

function QESkeletonViewer:onDisplayDummyClicked()
	if self._isDisplayDummy == true then
		self._dummyCheckMenu:setString("No")
		for _, label in ipairs(self._dummyLabels) do
			label:setVisible(false)
		end
		self._isDisplayDummy = false
	else
		self._dummyCheckMenu:setString("Yes")
		for _, label in ipairs(self._dummyLabels) do
			label:setVisible(true)
		end
		self._isDisplayDummy = true
	end
end

function QESkeletonViewer:onDisplayFreeDummyClicked()
	if self._isDisplayFreeDummy == true then
		self._freeDummyCheckMenu:setString("No")
		for _, label in ipairs(self._freeDummyLabels) do
			label:setVisible(false)
		end
		self._isDisplayFreeDummy = false
	else
		self._freeDummyCheckMenu:setString("Yes")
		for _, label in ipairs(self._freeDummyLabels) do
			label:setVisible(true)
		end
		self._isDisplayFreeDummy = true
	end
end

function QESkeletonViewer:onDisplayRectClicked()
	if self._isDisplayRect == true then
		self._rectCheckMenu:setString("No")
		self._boundingBox:setVisible(false)
		self._isDisplayRect = false
	else
		self._rectCheckMenu:setString("Yes")
		self._boundingBox:setVisible(true)
		self._isDisplayRect = true
	end
end

function QESkeletonViewer:onLoopClicked()
	if self._isLoopAnimation == true then
		self._loopCheckMenu:setString("No")
		self._isLoopAnimation = false
	else
		self._loopCheckMenu:setString("Yes")
		self._isLoopAnimation = true
	end

	if self._currentAnimation ~= nil then
		self._skeleton:resetActorWithAnimation(ANIMATION.STAND, false)
		self._skeleton:playAnimation(self._currentAnimation, self._isLoopAnimation)
	end
end

function QESkeletonViewer:onScaleIncreaseClicked()
	self._currentScale = self._currentScale + 0.1
	self._skeleton:setSkeletonScaleX(self._currentScale)
	self._skeleton:setSkeletonScaleY(self._currentScale)
	self._boundingBox:setScale(self._currentScale)
	self._scaleNumberLabel:setString(string.format("%.1f", self._currentScale))
end

function QESkeletonViewer:onScaleDecreaseClicked()
	self._currentScale = self._currentScale - 0.1
	self._skeleton:setSkeletonScaleX(self._currentScale)
	self._skeleton:setSkeletonScaleY(self._currentScale)
	self._boundingBox:setScale(self._currentScale)
	self._scaleNumberLabel:setString(string.format("%.1f", self._currentScale))
end

function QESkeletonViewer:onSpeedIncreaseClicked()
	self._currentSpeed = self._currentSpeed + 0.1
	self._skeleton:setAnimationScale(self._currentSpeed)
	self._speedNumberLabel:setString(string.format("%.1f", self._currentSpeed))
end

function QESkeletonViewer:onSpeedDecreaseClicked()
	self._currentSpeed = self._currentSpeed - 0.1
	if self._currentSpeed < 0 then
		self._currentSpeed = 0
	end
	self._skeleton:setAnimationScale(self._currentSpeed)
	self._speedNumberLabel:setString(string.format("%.1f", self._currentSpeed))
end

function QESkeletonViewer:onAnimationClicked(tag)
	local name = self._animationNames[tag]
	if name ~= nil and self._skeleton ~= nil then
		self._skeleton:resetActorWithAnimation(ANIMATION.STAND, false)
		self._skeleton:playAnimation(name, self._isLoopAnimation)
		self._currentAnimation = name
	end
end

function QESkeletonViewer:onHitMeClicked()
	if self._skeleton ~= nil and self._skeleton:isHitAnimationPlaying() == false then
		self._skeleton:playHitAnimation(ANIMATION.HIT)
	end
end

function QESkeletonViewer:onRedDecreaseClicked()
	self._redOverlay = self._redOverlay - 1
	if self._redOverlay < 0 then
		self._redOverlay = 0
	end
	self._redOverlay = math.floor(self._redOverlay)
	self._redNumberLabel:setString(string.format("%d", self._redOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onRedIncreaseClicked()
	self._redOverlay = self._redOverlay + 1
	if self._redOverlay > 255 then
		self._redOverlay = 255
	end
	self._redOverlay = math.floor(self._redOverlay)
	self._redNumberLabel:setString(string.format("%d", self._redOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onRedDecreaseMoreClicked()
	self._redOverlay = self._redOverlay - 10
	if self._redOverlay < 0 then
		self._redOverlay = 0
	end
	self._redOverlay = math.floor(self._redOverlay)
	self._redNumberLabel:setString(string.format("%d", self._redOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onRedIncreaseMoreClicked()
	self._redOverlay = self._redOverlay + 10
	if self._redOverlay > 255 then
		self._redOverlay = 255
	end
	self._redOverlay = math.floor(self._redOverlay)
	self._redNumberLabel:setString(string.format("%d", self._redOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onGreenDecreaseClicked()
	self._greenOverlay = self._greenOverlay - 1
	if self._greenOverlay < 0 then
		self._greenOverlay = 0
	end
	self._greenOverlay = math.floor(self._greenOverlay)
	self._greenNumberLabel:setString(string.format("%d", self._greenOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onGreenIncreaseClicked()
	self._greenOverlay = self._greenOverlay + 1
	if self._greenOverlay > 255 then
		self._greenOverlay = 255
	end
	self._greenOverlay = math.floor(self._greenOverlay)
	self._greenNumberLabel:setString(string.format("%d", self._greenOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onGreenDecreaseMoreClicked()
	self._greenOverlay = self._greenOverlay - 10
	if self._greenOverlay < 0 then
		self._greenOverlay = 0
	end
	self._greenOverlay = math.floor(self._greenOverlay)
	self._greenNumberLabel:setString(string.format("%d", self._greenOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onGreenIncreaseMoreClicked()
	self._greenOverlay = self._greenOverlay + 10
	if self._greenOverlay > 255 then
		self._greenOverlay = 255
	end
	self._greenOverlay = math.floor(self._greenOverlay)
	self._greenNumberLabel:setString(string.format("%d", self._greenOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onBlueDecreaseClicked()
	self._blueOverlay = self._blueOverlay - 1
	if self._blueOverlay < 0 then
		self._blueOverlay = 0
	end
	self._blueOverlay = math.floor(self._blueOverlay)
	self._blueNumberLabel:setString(string.format("%d", self._blueOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onBlueIncreaseClicked()
	self._blueOverlay = self._blueOverlay + 1
	if self._blueOverlay > 255 then
		self._blueOverlay = 255
	end
	self._blueOverlay = math.floor(self._blueOverlay)
	self._blueNumberLabel:setString(string.format("%d", self._blueOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onBlueDecreaseMoreClicked()
	self._blueOverlay = self._blueOverlay - 10
	if self._blueOverlay < 0 then
		self._blueOverlay = 0
	end
	self._blueOverlay = math.floor(self._blueOverlay)
	self._blueNumberLabel:setString(string.format("%d", self._blueOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onBlueIncreaseMoreClicked()
	self._blueOverlay = self._blueOverlay + 10
	if self._blueOverlay > 255 then
		self._blueOverlay = 255
	end
	self._blueOverlay = math.floor(self._blueOverlay)
	self._blueNumberLabel:setString(string.format("%d", self._blueOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onOpacityDecreaseClicked()
	self._opacityOverlay = self._opacityOverlay - 1
	if self._opacityOverlay < 0 then
		self._opacityOverlay = 0
	end
	self._opacityOverlay = math.floor(self._opacityOverlay)
	self._opacityNumberLabel:setString(string.format("%d", self._opacityOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onOpacityIncreaseClicked()
	self._opacityOverlay = self._opacityOverlay + 1
	if self._opacityOverlay > 255 then
		self._opacityOverlay = 255
	end
	self._opacityOverlay = math.floor(self._opacityOverlay)
	self._opacityNumberLabel:setString(string.format("%d", self._opacityOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onOpacityDecreaseMoreClicked()
	self._opacityOverlay = self._opacityOverlay - 10
	if self._opacityOverlay < 0 then
		self._opacityOverlay = 0
	end
	self._opacityOverlay = math.floor(self._opacityOverlay)
	self._opacityNumberLabel:setString(string.format("%d", self._opacityOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:onOpacityIncreaseMoreClicked()
	self._opacityOverlay = self._opacityOverlay + 10
	if self._opacityOverlay > 255 then
		self._opacityOverlay = 255
	end
	self._opacityOverlay = math.floor(self._opacityOverlay)
	self._opacityNumberLabel:setString(string.format("%d", self._opacityOverlay))
	self:resetSkeletonColor()
end

function QESkeletonViewer:resetSkeletonColor()
	self._skeleton:setColor(ccc3(self._redOverlay, self._greenOverlay, self._blueOverlay))
end

function QESkeletonViewer:onDisplayActor()
	self._axisNode:setPosition(display.cx, display.cy * 0.5)
	self._skeletonRoot:setPosition(display.cx, display.cy * 0.5)

	local filePath = self._message.file_path
	if filePath ~= nil and string.len(filePath) > 0 then
		-- create skeleton
		local startIndex, endIndex = string.find(filePath, ".json")
		local fileName = string.sub(filePath, 1, startIndex - 1)
		self._skeleton = QSkeletonActor:create(fileName)
		self._skeletonRoot:addChild(self._skeleton)
		self._skeleton:playAnimation(ANIMATION.STAND, true)
		self._currentAnimation = ANIMATION.STAND

		-- change weapon
		if self._message.weapon_file ~= nil and string.len(self._message.weapon_file) > 0 then
			local parentBone = self._skeleton:getParentBoneName(DUMMY.WEAPON)
        	self._skeleton:replaceSlotWithFile(self._message.weapon_file, parentBone, ROOT_BONE, EFFECT_ANIMATION)
		end

		-- attach dummy lable
		self._dummyLabels = {}
		self._freeDummyLabels = {}
		for dummyKey, dummyName in pairs(DUMMY) do
			if dummyName == DUMMY.TOP or dummyName == DUMMY.CENTER or dummyName == DUMMY.BOTTOM then
				if self._message.actor_height >= 0 then
					local node = CCNode:create()
					local label = ui.newTTFLabel( {
						text = dummyName,
						font = global.font_monaco,
						color = display.COLOR_GREEN,
						size = 20 } )
					node:addChild(label)
					self._skeleton:attachNodeToBone(nil, node)
					label:setVisible(false)
					table.insert(self._freeDummyLabels, label)
					if dummyName == DUMMY.TOP then
						label:setPosition(0, self._message.actor_height)
					elseif dummyName == DUMMY.CENTER then
						label:setPosition(0, self._message.actor_height * 0.5)
					end
				end
			else
				if self._skeleton:isBoneExist(dummyName) == true then
					local label = ui.newTTFLabel( {
						text = dummyName,
						font = global.font_monaco,
						size = 20 } )
					self._skeleton:attachNodeToBone(dummyName, label)
					label:setVisible(false)
					table.insert(self._dummyLabels, label)
				end
			end
		end

		-- bounding box
		self._boundingBox = CCNode:create()
		self._skeleton:addChild(self._boundingBox)
		self._boundingBox:setScale(self._message.actor_scale)
		self._boundingBox:setVisible(false)
		if self._message.actor_width > 0 and self._message.actor_height > 0 then
			local displayRect = true
			local displayCoreRect = true

			if displayRect == true then
				local width = self._message.actor_width
				local height = self._message.actor_height
				local scale = self._message.actor_scale
				local rect = CCRectMake(-width * 0.5, 0, width, height)
		        rect.origin.x = rect.origin.x
		        rect.size.width = rect.size.width
		        rect.size.height = rect.size.height
		        local vertices = {}
		        table.insert(vertices, {rect.origin.x, rect.origin.y})
		        table.insert(vertices, {rect.origin.x, rect.origin.y + rect.size.height})
		        table.insert(vertices, {rect.origin.x + rect.size.width, rect.origin.y + rect.size.height})
		        table.insert(vertices, {rect.origin.x + rect.size.width, rect.origin.y})
		        local param = {
		            fillColor = ccc4f(0.0, 0.0, 0.0, 0.0),
		            borderWidth = 1,
		            borderColor = ccc4f(1.0, 0.0, 0.0, 1.0)
		        }
		        local drawNode = CCDrawNode:create()
		        drawNode:clear()
		        drawNode:drawPolygon(vertices, param) -- red color
		        self._boundingBox:addChild(drawNode)
			end
			
			if displayCoreRect == true then
				local width = self._message.actor_width
				local height = self._message.actor_height
				local scale = self._message.actor_scale * 0.8
				local rect = CCRectMake(-width * 0.5, 0, width, height)
		        rect.origin.x = rect.origin.x * scale
		        rect.size.width = rect.size.width * scale
		        rect.size.height = rect.size.height * scale
		        local vertices = {}
		        table.insert(vertices, {rect.origin.x, rect.origin.y})
		        table.insert(vertices, {rect.origin.x, rect.origin.y + rect.size.height})
		        table.insert(vertices, {rect.origin.x + rect.size.width, rect.origin.y + rect.size.height})
		        table.insert(vertices, {rect.origin.x + rect.size.width, rect.origin.y})
		        local param = {
		            fillColor = ccc4f(0.0, 0.0, 0.0, 0.0),
		            borderWidth = 1,
		            borderColor = ccc4f(1.0, 1.0, 0.0, 1.0)
		        }
		        local drawNode = CCDrawNode:create()
		        drawNode:clear()
		        drawNode:drawPolygon(vertices, param) -- yellow color
		        self._boundingBox:addChild(drawNode)
			end
		end

		-- button and lable at left top
		local positionX = 10 
		local positionY = -20
		local deltaX = 200

		self._nameLabel = ui.newTTFLabel( {
			text = self._message.actor_name or "unknow name",
			font = global.font_monaco,
			color = display.COLOR_ORANGE,
			size = 25 } )
		self._nameLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._nameLabel)
		self._nameLabel:setPosition(positionX, positionY)
		positionY = positionY - 25

		self._boneLabel = ui.newTTFLabel( {
			text = "bone",
			font = global.font_monaco,
			size = 25 } )
		self._boneLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._boneLabel)
		self._boneLabel:setPosition(positionX, positionY)

		self._boneCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onDisplayBoneClicked),
			text = "No",
			font = global.font_monaco,
			size = 25 } )
		self._boneCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._boneCheckMenu)
		self._boneCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayBone = false
		positionY = positionY - 25

		self._dummyLabel = ui.newTTFLabel( {
			text = "dummy",
			font = global.font_monaco,
			size = 25 } )
		self._dummyLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._dummyLabel)
		self._dummyLabel:setPosition(positionX, positionY)

		self._dummyCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onDisplayDummyClicked),
			text = "No",
			font = global.font_monaco,
			size = 25 } )
		self._dummyCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._dummyCheckMenu)
		self._dummyCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayDummy = false
		positionY = positionY - 25

		self._freeDummyLabel = ui.newTTFLabel( {
			text = "free dummy",
			font = global.font_monaco,
			size = 25 } )
		self._freeDummyLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._freeDummyLabel)
		self._freeDummyLabel:setPosition(positionX, positionY)

		self._freeDummyCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onDisplayFreeDummyClicked),
			text = "No",
			font = global.font_monaco,
			size = 25 } )
		self._freeDummyCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._freeDummyCheckMenu)
		self._freeDummyCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayFreeDummy = false
		positionY = positionY - 25

		self._rectLabel = ui.newTTFLabel( {
			text = "bounding box",
			font = global.font_monaco,
			size = 25 } )
		self._rectLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._rectLabel)
		self._rectLabel:setPosition(positionX, positionY)

		self._rectCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onDisplayRectClicked),
			text = "No",
			font = global.font_monaco,
			size = 25 } )
		self._rectCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._rectCheckMenu)
		self._rectCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayRect = false
		positionY = positionY - 25

		self._loopLabel = ui.newTTFLabel( {
			text = "loop",
			font = global.font_monaco,
			size = 25 } )
		self._loopLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._loopLabel)
		self._loopLabel:setPosition(positionX, positionY)

		self._loopCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onLoopClicked),
			text = "Yes",
			font = global.font_monaco,
			size = 25 } )
		self._loopCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._loopCheckMenu)
		self._loopCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isLoopAnimation = true
		positionY = positionY - 25

		self._scaleLabel = ui.newTTFLabel( {
			text = "scale",
			font = global.font_monaco,
			size = 25 } )
		self._scaleLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._scaleLabel)
		self._scaleLabel:setPosition(positionX, positionY)

		self._scaleDecreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onScaleDecreaseClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._scaleDecreaseMenu:setTouchEnabled(true)
		self._scaleDecreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._scaleDecreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._scaleDecreaseMenu)
		self._scaleDecreaseMenu:setPosition(positionX + deltaX, positionY)

		self._currentScale = self._message.actor_scale
		self._skeleton:setSkeletonScaleX(self._currentScale)
		self._skeleton:setSkeletonScaleY(self._currentScale)
		self._scaleNumberLabel = ui.newTTFLabel( {
			text = string.format("%.1f", self._currentScale),
			font = global.font_monaco,
			size = 25 } )
		self._scaleNumberLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._scaleNumberLabel)
		self._scaleNumberLabel:setPosition(positionX + deltaX + 30, positionY)

		self._scaleIncreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onScaleIncreaseClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._scaleIncreaseMenu:setTouchEnabled(true)
		self._scaleIncreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._scaleIncreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._scaleIncreaseMenu)
		self._scaleIncreaseMenu:setPosition(positionX + deltaX + 80, positionY)
		positionY = positionY - 25

		self._speedLabel = ui.newTTFLabel( {
			text = "speed",
			font = global.font_monaco,
			size = 25 } )
		self._speedLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._speedLabel)
		self._speedLabel:setPosition(positionX, positionY)

		self._speedDecreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onSpeedDecreaseClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._speedDecreaseMenu:setTouchEnabled(true)
		self._speedDecreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._speedDecreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._speedDecreaseMenu)
		self._speedDecreaseMenu:setPosition(positionX + deltaX, positionY)

		self._currentSpeed = 1.0
		self._speedNumberLabel = ui.newTTFLabel( {
			text = string.format("%.1f", self._currentSpeed),
			font = global.font_monaco,
			size = 25 } )
		self._speedNumberLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._speedNumberLabel)
		self._speedNumberLabel:setPosition(positionX + deltaX + 30, positionY)

		self._speedIncreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onSpeedIncreaseClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._speedIncreaseMenu:setTouchEnabled(true)
		self._speedIncreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._speedIncreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._speedIncreaseMenu)
		self._speedIncreaseMenu:setPosition(positionX + deltaX + 80, positionY)
		positionY = positionY - 40

		self._animationLabel = ui.newTTFLabel( {
			text = "animations:",
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 25 } )
		self._animationLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._animationLabel)
		self._animationLabel:setPosition(positionX, positionY)

		self._hitMeMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onHitMeClicked),
			text = "Hit Me",
			font = global.font_monaco,
			size = 25 } )
		self._hitMeMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._hitMeMenu)
		self._hitMeMenu:setPosition(positionX + deltaX, positionY)

		positionY = positionY - 25

		local animationNames = self._skeleton:getAllAnimationName()
		local animationCount = animationNames:count()
		self._animationNames = {}
		for i = 1, animationCount do
			local animationName = tolua.cast(animationNames:objectAtIndex(i - 1), "CCString")
			local animationText = animationName:getCString()
			local menuItem = ui.newTTFLabelMenuItem( {
				listener = handler(self, QESkeletonViewer.onAnimationClicked),
				text = animationText,
				font = global.font_monaco,
				size = 25,
				color = display.COLOR_GREEN,
				tag = i } )
			menuItem:setAnchorPoint(ccp(0.0, 0.5))
			self._menu:addChild(menuItem)
			menuItem:setPosition(positionX, positionY)
			table.insert(self._animationNames, animationText)
			positionY = positionY - 25
		end

		-- background image
		positionX = display.width - 400
		positionY = -display.height + 20
		self._backgroundImageLabel = ui.newTTFLabel( {
			text = "map: ",
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		self._backgroundImageLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._backgroundImageLabel)
		self._backgroundImageLabel:setPosition(positionX, positionY)

		self._previousBackgroundImageMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer._previousBackgroundImage),
			text = "<",
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		-- self._previousBackgroundImageMenu:setTouchEnabled(true)
		-- self._previousBackgroundImageMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._previousBackgroundImageMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._previousBackgroundImageMenu)
		self._previousBackgroundImageMenu:setPosition(positionX + deltaX * 0.3, positionY)

		self._currentBackgroundImageLabel = ui.newTTFLabel( {
			text = self:_getCurrentBackgroundImage(),
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		self._currentBackgroundImageLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentBackgroundImageLabel)
		self._currentBackgroundImageLabel:setPosition(positionX + deltaX * 0.3 + 20, positionY)

		self._nextBackgroundImageMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer._nextBackgroundImage),
			text = ">",
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		-- self._nextBackgroundImageMenu:setTouchEnabled(true)
		-- self._nextBackgroundImageMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._nextBackgroundImageMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._nextBackgroundImageMenu)
		self._nextBackgroundImageMenu:setPosition(positionX + 1.8 * deltaX, positionY)

		positionX = 800 
		positionY = -20
		deltaX = 150

		self._redOverlay = 255
		self._greenOverlay = 255
		self._blueOverlay = 255
		self._opacityOverlay = 255

		self._redLabel = ui.newTTFLabel( {
			text = "Red",
			font = global.font_monaco,
			size = 25 } )
		self._redLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._redLabel)
		self._redLabel:setPosition(positionX, positionY)

		self._redDecreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onRedDecreaseMoreClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._redDecreaseMoreMenu:setTouchEnabled(true)
		self._redDecreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._redDecreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._redDecreaseMoreMenu)
		self._redDecreaseMoreMenu:setPosition(positionX + deltaX - 30, positionY)

		self._redDecreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onRedDecreaseClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._redDecreaseMenu:setTouchEnabled(true)
		self._redDecreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._redDecreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._redDecreaseMenu)
		self._redDecreaseMenu:setPosition(positionX + deltaX, positionY)

		self._redNumberLabel = ui.newTTFLabel( {
			text = string.format("%d", self._redOverlay),
			font = global.font_monaco,
			size = 25 } )
		self._redNumberLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._redNumberLabel)
		self._redNumberLabel:setPosition(positionX + deltaX + 30, positionY)

		self._redIncreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onRedIncreaseClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._redIncreaseMenu:setTouchEnabled(true)
		self._redIncreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._redIncreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._redIncreaseMenu)
		self._redIncreaseMenu:setPosition(positionX + deltaX + 80, positionY)

		self._redIncreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onRedIncreaseMoreClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._redIncreaseMoreMenu:setTouchEnabled(true)
		self._redIncreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._redIncreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._redIncreaseMoreMenu)
		self._redIncreaseMoreMenu:setPosition(positionX + deltaX + 80 + 30, positionY)

		positionY = positionY - 40

		self._greenLabel = ui.newTTFLabel( {
			text = "Green",
			font = global.font_monaco,
			size = 25 } )
		self._greenLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._greenLabel)
		self._greenLabel:setPosition(positionX, positionY)

		self._greenDecreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onGreenDecreaseMoreClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._greenDecreaseMoreMenu:setTouchEnabled(true)
		self._greenDecreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._greenDecreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._greenDecreaseMoreMenu)
		self._greenDecreaseMoreMenu:setPosition(positionX + deltaX - 30, positionY)

		self._greenDecreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onGreenDecreaseClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._greenDecreaseMenu:setTouchEnabled(true)
		self._greenDecreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._greenDecreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._greenDecreaseMenu)
		self._greenDecreaseMenu:setPosition(positionX + deltaX, positionY)

		self._greenNumberLabel = ui.newTTFLabel( {
			text = string.format("%d", self._greenOverlay),
			font = global.font_monaco,
			size = 25 } )
		self._greenNumberLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._greenNumberLabel)
		self._greenNumberLabel:setPosition(positionX + deltaX + 30, positionY)

		self._greenIncreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onGreenIncreaseClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._greenIncreaseMenu:setTouchEnabled(true)
		self._greenIncreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._greenIncreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._greenIncreaseMenu)
		self._greenIncreaseMenu:setPosition(positionX + deltaX + 80, positionY)

		self._greenIncreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onGreenIncreaseMoreClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._greenIncreaseMoreMenu:setTouchEnabled(true)
		self._greenIncreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._greenIncreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._greenIncreaseMoreMenu)
		self._greenIncreaseMoreMenu:setPosition(positionX + deltaX + 80 + 30, positionY)

		positionY = positionY - 40

		self._blueLabel = ui.newTTFLabel( {
			text = "Blue",
			font = global.font_monaco,
			size = 25 } )
		self._blueLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._blueLabel)
		self._blueLabel:setPosition(positionX, positionY)

		self._blueDecreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onBlueDecreaseMoreClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._blueDecreaseMoreMenu:setTouchEnabled(true)
		self._blueDecreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._blueDecreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._blueDecreaseMoreMenu)
		self._blueDecreaseMoreMenu:setPosition(positionX + deltaX - 30, positionY)

		self._blueDecreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onBlueDecreaseClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._blueDecreaseMenu:setTouchEnabled(true)
		self._blueDecreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._blueDecreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._blueDecreaseMenu)
		self._blueDecreaseMenu:setPosition(positionX + deltaX, positionY)

		self._blueNumberLabel = ui.newTTFLabel( {
			text = string.format("%d", self._blueOverlay),
			font = global.font_monaco,
			size = 25 } )
		self._blueNumberLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._blueNumberLabel)
		self._blueNumberLabel:setPosition(positionX + deltaX + 30, positionY)

		self._blueIncreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onBlueIncreaseClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._blueIncreaseMenu:setTouchEnabled(true)
		self._blueIncreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._blueIncreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._blueIncreaseMenu)
		self._blueIncreaseMenu:setPosition(positionX + deltaX + 80, positionY)

		self._blueIncreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onBlueIncreaseMoreClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._blueIncreaseMoreMenu:setTouchEnabled(true)
		self._blueIncreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._blueIncreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._blueIncreaseMoreMenu)
		self._blueIncreaseMoreMenu:setPosition(positionX + deltaX + 80 + 30, positionY)

		positionY = positionY - 40

		self._opacityLabel = ui.newTTFLabel( {
			text = "Opacity",
			font = global.font_monaco,
			size = 25 } )
		self._opacityLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._opacityLabel)
		self._opacityLabel:setPosition(positionX, positionY)

		self._opacityDecreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onOpacityDecreaseMoreClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._opacityDecreaseMoreMenu:setTouchEnabled(true)
		self._opacityDecreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._opacityDecreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._opacityDecreaseMoreMenu)
		self._opacityDecreaseMoreMenu:setPosition(positionX + deltaX - 30, positionY)

		self._opacityDecreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onOpacityDecreaseClicked),
			text = "<",
			font = global.font_monaco,
			size = 25 } )
		self._opacityDecreaseMenu:setTouchEnabled(true)
		self._opacityDecreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._opacityDecreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._opacityDecreaseMenu)
		self._opacityDecreaseMenu:setPosition(positionX + deltaX, positionY)

		self._opacityNumberLabel = ui.newTTFLabel( {
			text = string.format("%d", self._opacityOverlay),
			font = global.font_monaco,
			size = 25 } )
		self._opacityNumberLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._opacityNumberLabel)
		self._opacityNumberLabel:setPosition(positionX + deltaX + 30, positionY)

		self._opacityIncreaseMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onOpacityIncreaseClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._opacityIncreaseMenu:setTouchEnabled(true)
		self._opacityIncreaseMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._opacityIncreaseMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._opacityIncreaseMenu)
		self._opacityIncreaseMenu:setPosition(positionX + deltaX + 80, positionY)

		self._opacityIncreaseMoreMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onOpacityIncreaseMoreClicked),
			text = ">",
			font = global.font_monaco,
			size = 25 } )
		self._opacityIncreaseMoreMenu:setTouchEnabled(true)
		self._opacityIncreaseMoreMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._opacityIncreaseMoreMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._opacityIncreaseMoreMenu)
		self._opacityIncreaseMoreMenu:setPosition(positionX + deltaX + 80 + 30, positionY)

		positionY = positionY - 40
	end

	self._currentMode = QESkeletonViewer.ACTOR_MODE
end

-- effect display

function QESkeletonViewer:onDisplayEffect()
	self._axisNode:setPosition(display.cx, display.cy)
	self._skeletonRoot:setPosition(display.cx, display.cy)

	local frontFile = self._message.front_file
	if frontFile ~= nil and string.len(frontFile) > 0 then
		-- create skeleton
		local startIndex, endIndex = string.find(frontFile, ".json")
		local fileName = string.sub(frontFile, 1, startIndex - 1)
		self._frontEffect = QSkeletonView:create(fileName)
		self._skeletonRoot:addChild(self._frontEffect)
		self._frontEffect:playAnimation(EFFECT_ANIMATION, true)
	end

	local backFile = self._message.back_file
	if backFile ~= nil and string.len(backFile) > 0 then
		-- create skeleton
		local startIndex, endIndex = string.find(backFile, ".json")
		local fileName = string.sub(backFile, 1, startIndex - 1)
		self._backEffect = QSkeletonView:create(fileName)
		self._skeletonRoot:addChild(self._backEffect)
		self._backEffect:playAnimation(EFFECT_ANIMATION, true)
	end

	-- button and lable at left top
	local positionX = 10 
	local positionY = -20
	local deltaX = 180

	self._nameLabel = ui.newTTFLabel( {
		text = "Effect",
		font = global.font_monaco,
		color = display.COLOR_ORANGE,
		size = 25 } )
	self._nameLabel:setAnchorPoint(ccp(0.0, 0.5))
	self._infomationNode:addChild(self._nameLabel)
	self._nameLabel:setPosition(positionX, positionY)
	positionY = positionY - 25

	self._currentMode = QESkeletonViewer.Effect_MODE
end

-- edit effect

function QESkeletonViewer:editEffectPauseAllAnimations()
	if self._skeleton ~= nil then
		self._skeleton:pauseAnimation()
	end
	self._currentAttacher.pause()
end

function QESkeletonViewer:onEditEffectAnimationClicked(tag)
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_EDIT_MODE then
		return
	end

	local name = self._animationNames[tag]
	if name ~= nil and self._skeleton ~= nil then
		self._skeleton:resetActorWithAnimation(ANIMATION.STAND, false)
		self._skeleton:playAnimation(name, false)
		self._currentAnimation = name
		self._currentAnimationFrameCount = self._skeleton:getAnimationFrameCount(self._currentAnimation)
		self._currentAnimationLabel:setString(self._currentAnimation)
		self._frameCountLabel:setString("Frame Count: " .. tostring(self._currentAnimationFrameCount))
	end
end

function QESkeletonViewer:onEditEffectDisplayActorClicked()
	if self._isDisplayActor == true then
		self._displayActorCheckMenu:setString("No")
		self._skeleton:setVisible(false)
		self._isDisplayActor = false
	else
		self._displayActorCheckMenu:setString("Yes")
		self._skeleton:setVisible(true)
		self._isDisplayActor = true
	end
end

function QESkeletonViewer:onEditEffectFlipActorClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_EDIT_MODE then
		return
	end

	if self._isFlipActor == true then
		self._flipActorCheckMenu:setString("No")
		local scale = self._message.actor_scale or 1.0
		self._skeleton:setSkeletonScaleX(scale)
		self._isFlipActor = false
	else
		self._flipActorCheckMenu:setString("Yes")
		local scale = self._message.actor_scale or 1.0
		scale = -scale
		self._skeleton:setSkeletonScaleX(scale)
		self._isFlipActor = true
	end
end

function QESkeletonViewer:onEditEffectFlipSkeletonClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_EDIT_MODE then
		return
	end

	self._skeleton:flipSkeletonActor()
end

function QESkeletonViewer:onEditEffectDisplayDummyClicked()
	if self._isDisplayDummy == true then
		self._displayDummyCheckMenu:setString("No")
		for _, label in ipairs(self._dummyLabels) do
			label:setVisible(false)
		end
		self._isDisplayDummy = false
	else
		self._displayDummyCheckMenu:setString("Yes")
		for _, label in ipairs(self._dummyLabels) do
			label:setVisible(true)
		end
		self._skeleton:updateAnimation(0)
		self._isDisplayDummy = true
	end
end

function QESkeletonViewer:onEditEffectDisplayFreeDummyClicked()
	if self._isDisplayFreeDummy == true then
		self._displayFreeDummyCheckMenu:setString("No")
		for _, label in ipairs(self._freeDummyLabels) do
			label:setVisible(false)
		end
		self._isDisplayFreeDummy = false
	else
		self._displayFreeDummyCheckMenu:setString("Yes")
		for _, label in ipairs(self._freeDummyLabels) do
			label:setVisible(true)
		end
		self._isDisplayFreeDummy = true
	end
end

function QESkeletonViewer:onEditEffectModeClicked()
	if self._effectEditMode == QESkeletonViewer.EFFECT_EDIT_MODE then
		if self._message.relode_effect then
			for i,attacher in pairs(self._attachers) do
				attacher.flush()
			end
		end
		self._modeCheckMenu:setString("Play Mode")
		if self._effectPlayMode == QESkeletonViewer.EFFECT_FRAME_PLAY then
			self:onEditEffectUpdateFrameModeFrame(0)
		elseif self._effectPlayMode == QESkeletonViewer.EFFECT_CONTINUE_PLAY then
			self._isStoped = true
		end
		self._effectEditMode = QESkeletonViewer.EFFECT_PLAY_MODE
	else
		self._modeCheckMenu:setString("Edit Mode")
		self._skeleton:playAnimation(self._currentAnimation, false)
		self._skeleton:updateAnimation(0)
		self._currentAttacher.rewind()
		self._effectEditMode = QESkeletonViewer.EFFECT_EDIT_MODE
	end
end

function QESkeletonViewer:onEditEffectPlayModeClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode == QESkeletonViewer.EFFECT_FRAME_PLAY then
		self._effectPlayMode = QESkeletonViewer.EFFECT_CONTINUE_PLAY
		self._playModeCheckMenu:setString("Continue Play")
		self._isStoped = true
	else
		self._effectPlayMode = QESkeletonViewer.EFFECT_FRAME_PLAY
		self._playModeCheckMenu:setString("Frame Play")
		self:onEditEffectUpdateFrameModeFrame(0)
	end
end

function QESkeletonViewer:onEditEffectLoopAnimationClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._isLoopAnimation == true then
		self._isLoopAnimation = false
		self._loopAnimationCheckMenu:setString("No")
	else
		self._isLoopAnimation = true
		self._loopAnimationCheckMenu:setString("Yes")
	end
	self._isStoped = true
end

function QESkeletonViewer:onEditEffectPreviousFrameClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_FRAME_PLAY then
		return
	end
	
	if self._currentFrame == 0 then
		return
	end

	self:onEditEffectUpdateFrameModeFrame(self._currentFrame - 0.5)
end

function QESkeletonViewer:onEditEffectNextFrameClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_FRAME_PLAY then
		return
	end

	-- if self._currentFrame == self._currentAnimationFrameCount then
	-- 	return
	-- end
	
	self:onEditEffectUpdateFrameModeFrame(self._currentFrame + 0.5)
end

function QESkeletonViewer:onEditEffectUpdateFrameModeFrame(frame)
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_FRAME_PLAY then
		return 
	end

	self._currentFrame = frame
	self._currentFrameLabel:setString(tostring(self._currentFrame))

	local updateTime = self._currentFrame / 30

	self._skeleton:playAnimation(self._currentAnimation, false)
	self._skeleton:updateAnimation(updateTime)

	for _, attacher in ipairs(self._attachers) do
		attacher.updateTime(self._currentFrame / 30)
		attacher.pause()
	end
end

function QESkeletonViewer:onEditEffectPlayClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_CONTINUE_PLAY then
		return
	end

	self._isStoped = false
	self._currentTime = 0
	self._skeleton:playAnimation(self._currentAnimation, self._isLoopAnimation)
	self._skeleton:updateAnimation(0.0)
	self._currentAttacher.updateTime(0)

	if self._frameUpdateId == nil and self._stepMenu == nil then
		self._frameUpdateId = scheduler.scheduleUpdateGlobal(handler(self, QESkeletonViewer.onEditEffectFrame))
	end
end

function QESkeletonViewer:onEditEffectStopClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_CONTINUE_PLAY then
		return
	end

	self._isStoped = true
end

function QESkeletonViewer:onEditEffectStepClicked()
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_CONTINUE_PLAY then
		return
	end

	self:onEditEffectFrame(1/60)
end

function QESkeletonViewer:onEditEffectFrame(dt)
	if self._effectEditMode ~= QESkeletonViewer.EFFECT_PLAY_MODE then
		return
	end

	if self._effectPlayMode ~= QESkeletonViewer.EFFECT_CONTINUE_PLAY or self._isStoped == true then
		return
	end

	local lastTime = self._currentTime
	self._currentTime = self._currentTime + dt

	self._skeleton:updateAnimation(dt)
	for _, attacher in ipairs(self._attachers) do
		attacher.updateTime(self._currentTime)
		attacher.pause()
	end
end

function QESkeletonViewer:onEditEffect()
	self._axisNode:setPosition(display.cx, display.cy * 0.5)
	self._skeletonRoot:setPosition(display.cx, display.cy * 0.5)

	local actorFile = self._message.actor_file
	if actorFile ~= nil and string.len(actorFile) > 0 then
		-- create skeleton
		local startIndex, endIndex = string.find(actorFile, ".json")
		local fileName = string.sub(actorFile, 1, startIndex - 1)
		self._skeleton = QSkeletonActor:create(fileName)
		self._skeletonRoot:addChild(self._skeleton)
		self._skeleton:playAnimation(ANIMATION.STAND, false)
		self._skeleton:setSkeletonScaleX(self._message.actor_scale or 1.0)
		self._skeleton:setSkeletonScaleY(self._message.actor_scale or 1.0)
		self._currentAnimation = ANIMATION.STAND

		-- attach dummy lable
		self._dummyLabels = {}
		self._freeDummyLabels = {}
		self._dummyNames = {}
		self._freeDummyNames = {}
		for dummyKey, dummyName in pairs(DUMMY) do
			if dummyName == DUMMY.TOP or dummyName == DUMMY.CENTER or dummyName == DUMMY.BOTTOM then
				if self._message.actor_height >= 0 then
					local node = CCNode:create()
					local label = ui.newTTFLabel( {
						text = dummyName,
						font = global.font_monaco,
						color = display.COLOR_GREEN,
						size = 20 } )
					node:addChild(label)
					self._skeleton:attachNodeToBone(nil, node)
					label:setVisible(false)
					table.insert(self._freeDummyLabels, label)
					table.insert(self._freeDummyNames, dummyName)
					if dummyName == DUMMY.TOP then
						label:setPosition(0, self._message.actor_height)
					elseif dummyName == DUMMY.CENTER then
						label:setPosition(0, self._message.actor_height * 0.5)
					end
				end
			else
				if self._skeleton:isBoneExist(dummyName) == true then
					local label = ui.newTTFLabel( {
						text = dummyName,
						font = global.font_monaco,
						size = 20 } )
					self._skeleton:attachNodeToBone(dummyName, label)
					label:setVisible(false)
					table.insert(self._dummyLabels, label)
					table.insert(self._dummyNames, dummyName)
				end
			end
		end

		local attachers = {}
		self._attachers = attachers

		local index = 1

		for i = 1, 4 do
			local effectObject = self._message["effect"..i]
			if effectObject then
				attachers[index] = self:createEffectAttacher(self._skeleton, effectObject.front_file, effectObject.back_file, self._message.actor_height, effectObject.id, i)
				local attacher = attachers[index]
				attacher.setValue("is_file_with_actor", effectObject.is_file_with_actor)
				attacher.setValue("is_lay_on_the_ground", effectObject.is_lay_on_the_ground)
				attacher.setValue("is_hsi_enabled", effectObject.is_hsi_enabled)
				attacher.setValue("render_as_whole", effectObject.render_as_whole)
				attacher.setValue("offset_x", effectObject.offset_x)
				attacher.setValue("offset_y", effectObject.offset_y)
				attacher.setValue("scale", effectObject.scale)
				attacher.setValue("rotation", effectObject.rotation)
				attacher.setValue("play_speed", effectObject.play_speed)
				attacher.setValue("dummy", effectObject.dummy)
				attacher.setValue("id", effectObject.id)
				attacher.flush()
				index = index + 1
			end
		end

		self._currentAttacher = attachers[1]

		-- editor button and infomation

		-- 1. file information
		local positionX = 10 
		local positionY = -15
		local deltaX = 180

		local strings = string.split(self._message.actor_file, "/")
		if #strings <= 1 then
			strings = string.split(self._message.actor_file, "\\")
		end
		local actorFileName = strings[#strings]
		self._acotrFileLabel = ui.newTTFLabel( {
			text = "Actor:        " .. actorFileName,
			font = global.font_monaco,
			color = display.COLOR_ORANGE,
			size = 20 } )
		self._acotrFileLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._acotrFileLabel)
		self._acotrFileLabel:setPosition(positionX, positionY)
		positionY = positionY - 20

		local frontEffectFileName = "nil"
		if self._message.front_file ~= nil and string.len(self._message.front_file) > 0 then
			strings = string.split(self._message.front_file, "/")
			if #strings <= 1 then
				strings = string.split(self._message.front_file, "\\")
			end
			frontEffectFileName = strings[#strings]
		end
		self._frontEffectFileLabel = ui.newTTFLabel( {
			text = "Front Effect: " .. frontEffectFileName,
			font = global.font_monaco,
			color = display.COLOR_ORANGE,
			size = 20 } )
		self._frontEffectFileLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._frontEffectFileLabel)
		self._frontEffectFileLabel:setPosition(positionX, positionY)
		positionY = positionY - 20

		local backEffectFileName = "nil"
		if self._message.back_file ~= nil and string.len(self._message.back_file) > 0 then
			strings = string.split(self._message.back_file, "/")
			if #strings <= 1 then
				strings = string.split(self._message.back_file, "\\")
			end
			backEffectFileName = strings[#strings]
		end
		self._backEffectFileLabel = ui.newTTFLabel( {
			text = "Back Effect:  " .. backEffectFileName,
			font = global.font_monaco,
			color = display.COLOR_ORANGE,
			size = 20 } )
		self._backEffectFileLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._backEffectFileLabel)
		self._backEffectFileLabel:setPosition(positionX, positionY)
		positionY = positionY - 30

		-- 2. actor animation and actor display switch
		self._displayActorLabel = ui.newTTFLabel( {
			text = "Actor",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._displayActorLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._displayActorLabel)
		self._displayActorLabel:setPosition(positionX, positionY)

		self._displayActorCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectDisplayActorClicked),
			text = "Yes",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._displayActorCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._displayActorCheckMenu)
		self._displayActorCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayActor = true
		positionY = positionY - 20

		self._flipActorLabel = ui.newTTFLabel( {
			text = "Flip Actor",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._flipActorLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._flipActorLabel)
		self._flipActorLabel:setPosition(positionX, positionY)

		self._flipActorCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectFlipActorClicked),
			text = "No",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._flipActorCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._flipActorCheckMenu)
		self._flipActorCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isFlipActor = false
		positionY = positionY - 20

		self._flipSkeletonLabel = ui.newTTFLabel( {
			text = "Flip Skeleton",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._flipSkeletonLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._flipSkeletonLabel)
		self._flipSkeletonLabel:setPosition(positionX, positionY)

		self._flipSkeletonCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectFlipSkeletonClicked),
			text = "flip",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._flipSkeletonCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._flipSkeletonCheckMenu)
		self._flipSkeletonCheckMenu:setPosition(positionX + deltaX, positionY)
		positionY = positionY - 20

		self._currentAnimationTitleLabel = ui.newTTFLabel( {
			text = "Current Animation:",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._currentAnimationTitleLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentAnimationTitleLabel)
		self._currentAnimationTitleLabel:setPosition(positionX, positionY)

		self._currentAnimationLabel = ui.newTTFLabel( {
			text = self._currentAnimation,
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._currentAnimationLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentAnimationLabel)
		self._currentAnimationLabel:setPosition(positionX + deltaX * 1.2, positionY)
		positionY = positionY - 20

		self._actorAnimationLabel = ui.newTTFLabel( {
			text = "Actor Animation:",
			font = global.font_monaco,
			color = display.COLOR_GREEN,
			size = 20 } )
		self._actorAnimationLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._actorAnimationLabel)
		self._actorAnimationLabel:setPosition(positionX, positionY)
		positionY = positionY - 20

		local animationNames = self._skeleton:getAllAnimationName()
		local animationCount = animationNames:count()
		self._animationNames = {}
		for i = 1, animationCount do
			local animationName = tolua.cast(animationNames:objectAtIndex(i - 1), "CCString")
			local animationText = animationName:getCString()
			local menuItem = ui.newTTFLabelMenuItem( {
				listener = handler(self, QESkeletonViewer.onEditEffectAnimationClicked),
				text = animationText,
				font = global.font_monaco,
				size = 20,
				color = display.COLOR_GREEN,
				tag = i } )
			menuItem:setAnchorPoint(ccp(0.0, 0.5))
			self._menu:addChild(menuItem)
			if i % 2 ~= 0 then
				menuItem:setPosition(positionX, positionY)
			else
				menuItem:setPosition(positionX + deltaX, positionY)
				positionY = positionY - 20
			end
			table.insert(self._animationNames, animationText)
		end
		if animationCount % 2 ~= 0 then
			positionY = positionY - 30
		else
			positionY = positionY - 10
		end

		-- 3. effect dummy
		self._displayDummyLabel = ui.newTTFLabel( {
			text = "Dummy",
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 20 } )
		self._displayDummyLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._displayDummyLabel)
		self._displayDummyLabel:setPosition(positionX, positionY)

		self._displayDummyCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectDisplayDummyClicked),
			text = "No",
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 20 } )
		self._displayDummyCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._displayDummyCheckMenu)
		self._displayDummyCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayDummy = false
		positionY = positionY - 20

		self._displayFreeDummyLabel = ui.newTTFLabel( {
			text = "Free Dummy",
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 20 } )
		self._displayFreeDummyLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._displayFreeDummyLabel)
		self._displayFreeDummyLabel:setPosition(positionX, positionY)

		self._displayFreeDummyCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectDisplayFreeDummyClicked),
			text = "No",
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 20 } )
		self._displayFreeDummyCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._displayFreeDummyCheckMenu)
		self._displayFreeDummyCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isDisplayFreeDummy = false
		positionY = positionY - 20

		self._currentDummyTitleLabel = ui.newTTFLabel( {
			text = "Current Dummy:",
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 20 } )
		self._currentDummyTitleLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentDummyTitleLabel)
		self._currentDummyTitleLabel:setPosition(positionX, positionY)

		self._currentDummy = self._message.dummy or "No Dummy"
		self._currentDummyLabel = ui.newTTFLabel( {
			text = self._currentDummy,
			font = global.font_monaco,
			color = display.COLOR_BLUE,
			size = 20 } )
		self._currentDummyLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentDummyLabel)
		self._currentDummyLabel:setPosition(positionX + deltaX, positionY)
		positionY = positionY - 20

		for i, dummyName in ipairs(self._dummyNames) do
			local menuItem = ui.newTTFLabelMenuItem( {
				listener = function()
						self._currentAttacher.setValue("dummy", dummyName)
						self._currentAttacher.flush()
						self._currentAttacher.pause()
						self._currentDummyLabel:setString(dummyName)
					end,
				text = dummyName,
				font = global.font_monaco,
				size = 20,
				color = display.COLOR_BLUE,
				tag = i } )
			menuItem:setAnchorPoint(ccp(0.0, 0.5))
			self._menu:addChild(menuItem)
			menuItem:setPosition(positionX, positionY)
			positionY = positionY - 20
		end
		if #self._dummyNames % 2 ~= 0 then
			positionY = positionY - 20
		end

		for i, dummyName in ipairs(self._freeDummyNames) do
			local menuItem = ui.newTTFLabelMenuItem( {
				listener = function()
						self._currentAttacher.setValue("dummy", dummyName)
						self._currentAttacher.flush()
						self._currentAttacher.pause()
						self._currentDummyLabel:setString(dummyName)
					end,
				text = dummyName,
				font = global.font_monaco,
				size = 20,
				color = display.COLOR_BLUE,
				tag = i } )
			menuItem:setAnchorPoint(ccp(0.0, 0.5))
			self._menu:addChild(menuItem)
			menuItem:setPosition(positionX, positionY)
			positionY = positionY - 20
		end

		local noDummyMenuItem = ui.newTTFLabelMenuItem( {
			listener = function()
						self._currentAttacher.setValue("dummy", "No Dummy")
						self._currentAttacher.flush()
						self._currentAttacher.pause()
						self._currentDummyLabel:setString("No Dummy")
					end,
			text = "No Dummy",
			font = global.font_monaco,
			size = 20,
			color = display.COLOR_BLUE,
			tag = i } )
		noDummyMenuItem:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(noDummyMenuItem)
		noDummyMenuItem:setPosition(positionX, positionY)
		positionY = positionY - 20

		-- 4. effect attribute
		positionX = display.width - 300 
		positionY = -15
		deltaX = 150

		self._offsetXLabel = ui.newTTFLabel( {
			text = "Offset X:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._offsetXLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._offsetXLabel)
		self._offsetXLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("offset_x", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		self._offsetYLabel = ui.newTTFLabel( {
			text = "Offset Y:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._offsetYLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._offsetYLabel)
		self._offsetYLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("offset_y", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		self._scaleLabel = ui.newTTFLabel( {
			text = "Scale:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._scaleLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._scaleLabel)
		self._scaleLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("scale", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		self._rotationLabel = ui.newTTFLabel( {
			text = "Rotation:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._rotationLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._rotationLabel)
		self._rotationLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("rotation", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		self._playSpeedLabel = ui.newTTFLabel( {
			text = "Play Speed:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._playSpeedLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._playSpeedLabel)
		self._playSpeedLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("play_speed", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		self._delayLabel = ui.newTTFLabel( {
			text = "Delay:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._delayLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._delayLabel)
		self._delayLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("delay", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		-- HSI enabling
		self._HSIEnabledLabel = ui.newTTFLabel( {
			text = "HSI ENABLED:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._HSIEnabledLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._HSIEnabledLabel)
		self._HSIEnabledLabel:setPosition(positionX, positionY)

		self:createBooleanRangeMenu("is_hsi_enabled", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		-- Render as whole
		self._renderAsWholeLabel = ui.newTTFLabel( {
			text = "RENDER AS WHOLE:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._renderAsWholeLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._renderAsWholeLabel)
		self._renderAsWholeLabel:setPosition(positionX, positionY)

		self:createBooleanRangeMenu("render_as_whole", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		-- HUE
		self._hueLabel = ui.newTTFLabel( {
			text = "Hue:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._hueLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._hueLabel)
		self._hueLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("hue", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		-- Saturation
		self._saturationLabel = ui.newTTFLabel( {
			text = "Sat:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._saturationLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._saturationLabel)
		self._saturationLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("saturation", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		-- Intensity
		self._intensityLabel = ui.newTTFLabel( {
			text = "Int:",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._intensityLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._intensityLabel)
		self._intensityLabel:setPosition(positionX, positionY)

		self:createNumberRangeMenu("intensity", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 20

		self._flipWithActorLabel = ui.newTTFLabel( {
			text = "Is Flip With Actor",
			font = global.font_monaco,
			color = display.COLOR_WHITE,
			size = 20 } )
		self._flipWithActorLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._flipWithActorLabel)
		self._flipWithActorLabel:setPosition(positionX, positionY)

		self:createBooleanRangeMenu("is_flip_with_actor", self._menu, self._infomationNode, positionX, deltaX, positionY)
		positionY = positionY - 30

		self._effectEditMode = QESkeletonViewer.EFFECT_EDIT_MODE
		self._modeCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectModeClicked),
			text = "Edit Mode",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._modeCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._modeCheckMenu)
		self._modeCheckMenu:setPosition(positionX, positionY)
		positionY = positionY - 20

		self._effectPlayMode = QESkeletonViewer.EFFECT_FRAME_PLAY
		self._playModeCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectPlayModeClicked),
			text = "Frame Play",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._playModeCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._playModeCheckMenu)
		self._playModeCheckMenu:setPosition(positionX, positionY)
		positionY = positionY - 20

		self._currentAnimationFrameCount = self._skeleton:getAnimationFrameCount(self._currentAnimation)
		self._frameCountLabel = ui.newTTFLabel( {
			text = "Frame Count: " .. tostring(self._currentAnimationFrameCount),
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._frameCountLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._frameCountLabel)
		self._frameCountLabel:setPosition(positionX, positionY)
		positionY = positionY - 20

		self._frameLabel = ui.newTTFLabel( {
			text = "Frame:",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._frameLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._frameLabel)
		self._frameLabel:setPosition(positionX, positionY)

		self._previousFrameMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectPreviousFrameClicked),
			text = "<",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._previousFrameMenu:setTouchEnabled(true)
		self._previousFrameMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._previousFrameMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._previousFrameMenu)
		self._previousFrameMenu:setPosition(positionX + deltaX * 0.5, positionY)

		self._currentFrame = 0
		self._currentFrameLabel = ui.newTTFLabel( {
			text = tostring(self._currentFrame),
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._currentFrameLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentFrameLabel)
		self._currentFrameLabel:setPosition(positionX + deltaX * 0.7, positionY)

		self._nextFrameMenu = newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectNextFrameClicked),
			text = ">",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._nextFrameMenu:setTouchEnabled(true)
		self._nextFrameMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._nextFrameMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._nextFrameMenu)
		self._nextFrameMenu:setPosition(positionX + deltaX, positionY)
		positionY = positionY - 20

		self._loopAnimationLabel = ui.newTTFLabel( {
			text = "Loop",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._loopAnimationLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._loopAnimationLabel)
		self._loopAnimationLabel:setPosition(positionX, positionY)

		self._loopAnimationCheckMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectLoopAnimationClicked),
			text = "No",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._loopAnimationCheckMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._loopAnimationCheckMenu)
		self._loopAnimationCheckMenu:setPosition(positionX + deltaX, positionY)
		self._isLoopAnimation = false
		positionY = positionY - 20

		self._isStoped = true
		self._playMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectPlayClicked),
			text = "Play",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._playMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._playMenu)
		self._playMenu:setPosition(positionX, positionY)

		self._stopMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer.onEditEffectStopClicked),
			text = "Stop",
			font = global.font_monaco,
			color = display.COLOR_YELLOW,
			size = 20 } )
		self._stopMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._stopMenu)
		self._stopMenu:setPosition(positionX + deltaX * 0.5, positionY)

		-- self._stepMenu = ui.newTTFLabelMenuItem( {
		-- 	listener = handler(self, QESkeletonViewer.onEditEffectStepClicked),
		-- 	text = "Step",
		-- 	font = global.font_monaco,
		-- 	color = display.COLOR_YELLOW,
		-- 	size = 20 } )
		-- self._stepMenu:setAnchorPoint(ccp(0.0, 0.5))
		-- self._menu:addChild(self._stepMenu)
		-- self._stepMenu:setPosition(positionX + deltaX, positionY)

		positionY = positionY - 30

		local editBtns = {}
		local visibleBtns = {}
		for index = 1, 4, 1 do
			local attacher = self._attachers[index]
			if attacher then
				local id = attacher.getValue("id")
				local nameLabel = ui.newTTFLabel( {
					text = "[" .. (id or ("effect "..tostring(index))) .. "]",
					font = global.font_monaco,
					color = display.COLOR_YELLOW,
					size = 20 } )
				nameLabel:setAnchorPoint(ccp(0.0, 0.5))
				self._infomationNode:addChild(nameLabel)
				nameLabel:setPosition(positionX, positionY)
				positionY = positionY - 24
				local editBtn
				editBtn = ui.newTTFLabelMenuItem( {
					listener = function()
						if attacher ~= self._currentAttacher then
							self._currentAttacher = attacher
							self:syncCurrentAttacher()
							for i = 1, #editBtns do
								editBtns[i]:setString((index == i and "Edit[On]" or "Edit[Off]"))
							end
							visibleBtns[index]:setString("View[On]")
							self._frontEffectFileLabel:setString("Front Effect: "..tostring(attacher.getValue("file")))
							self._backEffectFileLabel:setString("Back Effect: "..tostring(attacher.getValue("file_back")))
						end
					end,
					text = (index == 1 and "Edit[On]" or "Edit[Off]"),
					font = global.font_monaco,
					color = display.COLOR_YELLOW,
					size = 20 } )
				editBtn:setAnchorPoint(ccp(0.0, 0.5))
				self._menu:addChild(editBtn)
				editBtn:setPosition(positionX, positionY)
				editBtns[index] = editBtn
				local visibleBtn
				visibleBtn = ui.newTTFLabelMenuItem( {
					listener = function() 
						local visible = not attacher.isVisible()
						attacher.setVisible(visible)
						visibleBtn:setString(visible and "View[On]" or "View[Off]")
					end,
					text = "View[On]",
					font = global.font_monaco,
					color = display.COLOR_YELLOW,
					size = 20 } )
				visibleBtn:setAnchorPoint(ccp(0.0, 0.5))
				self._menu:addChild(visibleBtn)
				visibleBtn:setPosition(positionX + 120, positionY)
				visibleBtns[index] = visibleBtn
				positionY = positionY - 24
			end
		end

		positionX = display.width - 400
		positionY = -display.height + 20
		self._backgroundImageLabel = ui.newTTFLabel( {
			text = "map: ",
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		self._backgroundImageLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._backgroundImageLabel)
		self._backgroundImageLabel:setPosition(positionX, positionY)

		self._previousBackgroundImageMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer._previousBackgroundImage),
			text = "<",
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		-- self._previousBackgroundImageMenu:setTouchEnabled(true)
		-- self._previousBackgroundImageMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._previousBackgroundImageMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._previousBackgroundImageMenu)
		self._previousBackgroundImageMenu:setPosition(positionX + deltaX * 0.4, positionY)

		self._currentBackgroundImageLabel = ui.newTTFLabel( {
			text = self:_getCurrentBackgroundImage(),
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		self._currentBackgroundImageLabel:setAnchorPoint(ccp(0.0, 0.5))
		self._infomationNode:addChild(self._currentBackgroundImageLabel)
		self._currentBackgroundImageLabel:setPosition(positionX + deltaX * 0.4 + 20, positionY)

		self._nextBackgroundImageMenu = ui.newTTFLabelMenuItem( {
			listener = handler(self, QESkeletonViewer._nextBackgroundImage),
			text = ">",
			font = global.font_monaco,
			color = display.COLOR_MAGENTA,
			size = 20 } )
		-- self._nextBackgroundImageMenu:setTouchEnabled(true)
		-- self._nextBackgroundImageMenu:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._nextBackgroundImageMenu:setAnchorPoint(ccp(0.0, 0.5))
		self._menu:addChild(self._nextBackgroundImageMenu)
		self._nextBackgroundImageMenu:setPosition(positionX + 2.5 * deltaX, positionY)

		positionX = 800 
		positionY = -20

		if self._currentAttacher then
			self._frontEffectFileLabel:setString("Front Effect: "..tostring(self._currentAttacher.getValue("file")))
			self._backEffectFileLabel:setString("Back Effect: "..tostring(self._currentAttacher.getValue("file_back")))
		end
		self:syncCurrentAttacher()
	end

	self._currentMode = QESkeletonViewer.EDIT_MODE
end

return QESkeletonViewer
