
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTutorialHandTouch = class("QUIWidgetTutorialHandTouch", QUIWidget)
local QUIWidgetTutorialFreeDialogue = import("..widgets.QUIWidgetTutorialFreeDialogue")
local QUIWidgetMaskLayer = import("..widgets.common.QUIWidgetMaskLayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetTutorialHandTouch:ctor(options)
	if not options then options = {} end
	local ccbFile = "ccb/Widget_TutorialHandTouch.ccbi"
	local callbacks = {}
	QUIWidgetTutorialHandTouch.super.ctor(self, ccbFile, callbacks, options)

	self._fcaPlayingCount = 0
	self._ccbOwner.sp_stencil:setVisible(false)
	self._curIndex = 1
	self._fcaFocusList = {}
	while true do
		local fca = self._ccbOwner["fca_focus"..self._curIndex]
		if fca then
			self._fcaFocusList[self._curIndex] = tolua.cast(fca, "QFcaSkeletonView_cpp")
			self._fcaFocusList[self._curIndex]:stopAnimation()
			self._fcaFocusList[self._curIndex]:setVisible(false)
			self._curIndex = self._curIndex + 1
		else
			break
		end
	end
	self._ccbOwner.fca_focus:setVisible(false)
	self._curIndex = 1

	self._normalMaskPos = options.pos
	local moveStartPos = options.moveStartPos
	if self._normalMaskPos and moveStartPos then
		local offsetPos = ccp(self._normalMaskPos.x - moveStartPos.x, self._normalMaskPos.y - moveStartPos.y)
		self._atkHndStartPos = ccp(50 - offsetPos.x, -50 - offsetPos.y)
	end
	self._atkHndEndPos = ccp(50, -50)

	if self._normalMaskPos then
		q.floorPos(self._normalMaskPos)
	end
	if options.attack then
		self._atkHnd = CCBuilderReaderLoad("ccb/effects/jihuo_hand.ccbi", CCBProxy:create(), {})
		if self._atkHndStartPos then
			self._atkHnd:setPosition(self._atkHndStartPos)
		else
			self._atkHnd:setPosition(self._atkHndEndPos)
		end
		self:addChild(self._atkHnd)
		self._atkHnd:setVisible(false)
	end

	self._isPlaying = true
end

function QUIWidgetTutorialHandTouch:isPlaying()
	return self._isPlaying 
end

function QUIWidgetTutorialHandTouch:onEnter()
	self:_startShow()
end

function QUIWidgetTutorialHandTouch:_startShow()
	-- self:_addBlackCloth()
	self:_createFreeDialogue()
end

function QUIWidgetTutorialHandTouch:_showHand()
	if self._atkHnd then
		self._atkHnd:setVisible(true)
		if self._atkHndStartPos then
			self:_moveAtkHnd()
		else
			self._atkHnd:setPosition(self._atkHndEndPos)
			self:_addFreeDialogueMask()
			self._ccbOwner.fca_focus:setVisible(true)
		end
	else
		self:_addFreeDialogueMask()
		self._ccbOwner.fca_focus:setVisible(true)
	end
end

function QUIWidgetTutorialHandTouch:_moveAtkHnd()
	if self._atkHndActionHandler then return end

	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(0.3, self._atkHndEndPos))
	arr:addObject(CCCallFunc:create(function ()
		self._atkHndStartPos = nil
		self._atkHndActionHandler = nil
		self:_showHand()
	end))
	local ccsequence = CCSequence:create(arr)
	self._atkHndActionHandler = self._atkHnd:runAction(ccsequence)
end

function QUIWidgetTutorialHandTouch:onExit()
	if self._freeDialogueHandler and self._freeDialogue then
		self._freeDialogue:removeEventListener(self._freeDialogueHandler)
		self._freeDialogueHandler = nil
	end

	if self._freeDialogue then
		self._freeDialogue:removeFromParent()
		self._freeDialogue = nil
	end

	if self._atkHndActionHandler then
		self._atkHnd:stopAction(self._atkHndActionHandler)
		self._atkHndActionHandler = nil
	end

	if self._blackClothLayer then
		self._blackClothLayer:removeFromParent()
		self._blackClothLayer = nil
	end
end

function QUIWidgetTutorialHandTouch:_createFreeDialogue()
	local id = self:getOptions().id
	local x, y, model, words, sound

	if id then
		local config = QStaticDatabase.sharedDatabase():getGuidenceWordById(id)
		if config and config.type == 2 then
			x, y, model, words = self:_analysisConfig( config.dialogue )
			sound = config.sound
		end
	else
		x = self:getOptions().x 
		y = self:getOptions().y
		model = self:getOptions().model
		words = self:getOptions().word             --# 代表回车
		sound = self:getOptions().sound
	end

	local parentNode = app.tutorialNode
	if self:getOptions().parentNode then
		parentNode = self:getOptions().parentNode
	end
	if x and y and model and words then
		self._freeDialogue = QUIWidgetTutorialFreeDialogue.new({model = model, words = words})
		self._freeDialogueHandler = self._freeDialogue:addEventListener(QUIWidgetTutorialFreeDialogue.ANIMATION_END, function()
				if self._freeDialogueHandler then
					self._freeDialogue:removeEventListener(self._freeDialogueHandler)
					self._freeDialogueHandler = nil
				end
				self:_showHand()
			end)
		self._freeDialogue:setPosition(display.width*x/100, display.height*y/100)
		parentNode:addChild(self._freeDialogue, 1)
	else
		self:_showHand()
	end

	if sound then
		local sounds = string.split(sound or "", ";") or {}
	    if sounds[1] and not self._isPlaySound then
	    	self._isPlaySound = true
	    	if app.sound.tutorialSoundHandle then
	    		app.sound:stopSound(app.sound.tutorialSoundHandle)
	    	end
	    	app.sound:playSound(sounds[1])
	    end
	end
end

function QUIWidgetTutorialHandTouch:getStencil()
	return self._ccbOwner.sp_stencil 
end

function QUIWidgetTutorialHandTouch:_fcaHandler(eventType)
	if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
		self._fcaPlayingCount = self._fcaPlayingCount - 1
		if self._maskLayer and self._fcaPlayingCount <= 0 then
			self._fcaPlayingCount = 0
			self._maskLayer:removeFromParent()
			self._maskLayer = nil
			self._focusMaskPos = nil
		end
	elseif eventType == SP_ANIMATION_START then
		self._fcaPlayingCount = self._fcaPlayingCount + 1
		self:_addMask()
	end
end

function QUIWidgetTutorialHandTouch:_addFreeDialogueMask()
	self._isPlaying = false
	if self._blackClothLayer then
		self._blackClothLayer:removeFromParent()
		self._blackClothLayer = nil
	end
	if not self._normalMaskPos then return end

	if self._freeLayer then
		self._freeLayer:removeFromParent()
		self._freeLayer = nil
	end
	self._freeLayer = QUIWidgetMaskLayer.new()
    self._freeLayer:setPic("ui/cricle_kuang_alpha1.png", self._normalMaskPos.x, self._normalMaskPos.y)
    self._freeLayer:setColor(ccc3(0,0,0))
    self._freeLayer:setOpacity(150)
    self._freeLayer:setPosition(ccp(-self._normalMaskPos.x, -self._normalMaskPos.y))
	self._ccbOwner.node_mask:addChild(self._freeLayer)
end

function QUIWidgetTutorialHandTouch:_addMask()
	if self._maskLayer then
		self._maskLayer:removeFromParent()
		self._maskLayer = nil
	end

	local npos = self:convertToNodeSpace(self._focusMaskPos)
	self._maskLayer = QUIWidgetMaskLayer.new()
    self._maskLayer:setPic("ui/cricle_kuang_alpha1.png", self._focusMaskPos.x, self._focusMaskPos.y)
    self._maskLayer:setColor(ccc3(0,0,0))
    self._maskLayer:setOpacity(150)
    self._maskLayer:setPosition(ccp(-self._focusMaskPos.x, -self._focusMaskPos.y))
	self._ccbOwner.node_mask:addChild(self._maskLayer)
end

function QUIWidgetTutorialHandTouch:_addBlackCloth()
	if self._blackClothLayer then
		self._blackClothLayer:removeFromParent()
		self._blackClothLayer = nil
	end

	self._blackClothLayer = QUIWidgetMaskLayer.new()
	self._blackClothLayer:setPic(nil, 0, 0)
    self._blackClothLayer:setColor(ccc3(0,0,0))
    self._blackClothLayer:setOpacity(150)
    self._blackClothLayer:setPosition(ccp(0, 0))
	-- self:getParent():addChild(self._blackClothLayer)

	local parentNode = app.tutorialNode
	if self:getOptions().parentNode then
		parentNode = self:getOptions().parentNode
	end
	parentNode:addChild(self._blackClothLayer)
end


function QUIWidgetTutorialHandTouch:showFocus( pos )
	if self._isPlaying then return end
	self._focusMaskPos = pos or self._normalMaskPos
	if self._focusMaskPos then
		q.floorPos(self._focusMaskPos)
	end
	if self._fcaFocusList and self._fcaFocusList[self._curIndex] then
		self._fcaFocusList[self._curIndex]:stopAnimation()
	    self._fcaFocusList[self._curIndex]:setVisible(true)
	    self._fcaFocusList[self._curIndex]:connectAnimationEventSignal(handler(self, self._fcaHandler))
	    self._fcaFocusList[self._curIndex]:playAnimation(string.split(self._fcaFocusList[self._curIndex]:getAvailableAnimationNames(), ";")[1], false)
	    self._curIndex = self._curIndex + 1
		if self._curIndex > #self._fcaFocusList then
			self._curIndex = 1
		end
	end
end


function QUIWidgetTutorialHandTouch:showFocusAndDisappear( Size_width, Size_height,pos )
	if self._isPlaying then return end
	self._focusMaskPos = pos or self._normalMaskPos
	if self._focusMaskPos then
		q.floorPos(self._focusMaskPos)
	end

	local _curIndex =""
	while true do
		local fca = self._ccbOwner["fca_focus".._curIndex]
		if fca then
			self._fcaFocusList[self._curIndex] = tolua.cast(fca, "QFcaSkeletonView_cpp")
			self._fcaFocusList[self._curIndex]:stopAnimation()
			self._fcaFocusList[self._curIndex]:setVisible(false)
			if _curIndex == "" then
				_curIndex = 1
			else
				_curIndex = _curIndex + 1

			end
		else
			break
		end
	end
	if self._maskLayer then
		self._maskLayer:removeFromParent()
		self._maskLayer = nil
	end

	local npos = self:convertToNodeSpace(self._focusMaskPos)
	self._maskLayer = QUIWidgetMaskLayer.new()
    self._maskLayer:setPicSize(Size_width, Size_height, self._focusMaskPos.x, self._focusMaskPos.y)
    self._maskLayer:setColor(ccc3(0,0,0))
    self._maskLayer:setOpacity(100)
    self._maskLayer:setPosition(ccp(-self._focusMaskPos.x, -self._focusMaskPos.y))
	self._ccbOwner.node_mask:addChild(self._maskLayer)


end


-- 跳过动画阶段
function QUIWidgetTutorialHandTouch:onClick()
	if self._isPlaying then
		if self._freeDialogue then
			if self._atkHndActionHandler then
				self._atkHnd:stopAction(self._atkHndActionHandler)
				self._atkHndActionHandler = nil
			end
			if self._freeDialogueHandler then
				self._freeDialogue:removeEventListener(self._freeDialogueHandler)
				self._freeDialogueHandler = nil
			end
			self._atkHndStartPos = nil
			self:_showHand()
		end
	end
end

function QUIWidgetTutorialHandTouch:_analysisConfig( dialogue )
	local x = -999
	local y = -999
	local model = QUIWidgetTutorialFreeDialogue.RIGHT
	local words = ""

	if dialogue then
		local tbl = string.split(dialogue, "^")
		x = tonumber(tbl[1])
		y = tonumber(tbl[2])
		model = tbl[3]
		words = tbl[4]
	end

	return x, y, model, words
end

return QUIWidgetTutorialHandTouch