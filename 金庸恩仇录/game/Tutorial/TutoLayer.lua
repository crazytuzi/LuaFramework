require("game.Biwu.BiwuFuc")

local TutoLayer = class("TutoLayer", function(data)
	isTutoExist = true
	return display.newNode()
end)

function TutoLayer:onEnter()
	RegNotice(self, function(_, info)
		self._info = info
		self.callBackFunc()
	end,
	NoticeKey.REMOVE_TUTOLAYER)
	
	ResMgr.delayFunc(0.3, function()
		ResMgr.removeTutoMask()
	end,
	self)
end

function TutoLayer:onExit()
	UnRegNotice(self, NoticeKey.REMOVE_TUTOLAYER)
	if self.tutoindex  == TUTO_INDEX then
		isTutoExist = false
	end
end

function TutoLayer:onCleanup()
	if self.tutoindex  == TUTO_INDEX then
		isTutoExist = false
	end
end

function TutoLayer:ctor(param)
	self.tutoindex = TUTO_INDEX
	self._canTouch = false
	TutoMgr.lockTable()
	self.rootNode = {}
	local tuData = param.tuData
	local isMask = param.isMask
	self.unlockFunc = param.unlockFunc
	self:setNodeEventEnabled(true)
	local btn = param.btn
	local callBack = param.func
	local btnScale
	local btnScaleX = btn:getScaleX()
	local btnScaleY = btn:getScaleY()
	if btnScaleX < btnScaleY then
		btnScale = btnScaleX
	else
		btnScale = btnScaleY
	end
	local sizeX = param.sizeX
	local sizeY = param.sizeY
	local btnSize = btn:getContentSize()
	if sizeX ~= nil and sizeY ~= nil then
		btnSize = cc.size(sizeX, sizeY)
	else
		btnSize = cc.size(btnSize.width, btnSize.height)
	end
	self.touchType = param.isTouch
	local delay = param.delay / 1000 or 0
	local btnCenterPos = cc.p(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	local btnPos = btn:convertToWorldSpace(btnCenterPos)
	local clippingNode = CCClippingNode:create()
	clippingNode:setContentSize(btnSize)
	local stencil = display.newRect(cc.rect(0, 0, btnSize.width, btnSize.height))
	stencil:setPosition(cc.p(btnPos.x-btnSize.width/2,btnPos.y-btnSize.height/2))
	stencil:setScale(btnScale)
	clippingNode:setStencil(stencil)
	clippingNode:setInverted(true)
	self:addChild(clippingNode)
	
	function self.callBackFunc()
		dump("[______________________TutoLayer_callBackFunc_null_________________]")
	end
	
	display.addSpriteFramesWithFile("ui/ui_tutorial.plist", "ui/ui_tutorial.png")
	local lColor
	if tuData.isDark == 0 then
		lColor = cc.c4b(0, 0, 0, 0)
	else
		lColor = cc.c4b(0, 0, 0, tuData.opacity)
	end
	local pLayer = display.newColorLayer(lColor)
	clippingNode:addChild(pLayer)
	pLayer = tolua.cast(pLayer,"cc.Layer")
	pLayer:setTouchEnabled(true)
	pLayer:setTouchSwallowEnabled(true)
	
	pLayer:registerScriptTouchHandler(function (event, x, y)
		if self._canTouch == false then
			return true
		end
		if "began" == event then
			local loKongRect = cc.rect(btnPos.x - btnSize.width / 2, btnPos.y - btnSize.height / 2, btnSize.width, btnSize.height)
			if cc.rectContainsPoint(loKongRect, cc.p(x, y)) then
				if self.touchType == 1 then
					self.callBackFunc()
				end
				return false
			else
				dump("click TutoLayer btn")
				return true
			end
		end
	end)
	
	local getAppearAct = function(times)
		local delayTime = times[1] / 1000
		local appTime = times[2] / 1000
		local delayAct = CCDelayTime:create(delayTime)
		local appearAct = CCFadeTo:create(appTime, 255)
		local seq = transition.sequence({delayAct, appearAct})
		return seq
	end
	self.baseNode = display.newNode()
	self:addChild(self.baseNode)
	local arrow = LoadUI("mainmenu/navigtion.ccbi", self.rootNode)
	arrowHeight = arrow:getContentSize().height / 2
	self.arrowNode = display.newNode()
	self.arrowNode:addChild(arrow)
	self.baseNode:addChild(self.arrowNode)
	local arrowDir = param.arrowDir
	local arrowPos, movePos
	if arrowDir == 1 then
		arrowPos = cc.p(btnPos.x, btnPos.y)
		movePos = cc.p(btnPos.x - 50, btnPos.y + 20)
	elseif arrowDir == 2 then
		arrowPos = cc.p(btnPos.x, btnPos.y)
		movePos = cc.p(btnPos.x, btnPos.y - 50)
		arrow:setScaleY(-1)
	elseif arrowDir == 3 then
		arrowPos = cc.p(btnPos.x, btnPos.y)
		movePos = cc.p(btnPos.x - 20, btnPos.y)
		arrow:setRotation(-90)
	elseif arrowDir == 4 then
		arrowPos = cc.p(btnPos.x, btnPos.y)
		movePos = cc.p(btnPos.x + 20, btnPos.y)
		arrow:setRotation(90)
	else
		arrowPos = cc.p(btnPos.x, btnPos.y)
		movePos = cc.p(btnPos.x, btnPos.y)
	end
	self.arrowNode:setPosition(arrowPos)
	arrow:setOpacity(0)
	local arrowTimes = tuData.arrow_appear_time
	local delayTime = arrowTimes[1] / 1000
	local appTime = arrowTimes[2] / 1000
	self:initPos()
	self.posId = param.girlPos or 1
	local flip = false
	local flipSign = -1
	local chatBoxAnchor = 0
	local chatCornerAnchor = 1
	local ttfOffsetX = 25
	if self.posId % 2 == 0 then
		flip = true
		flipSign = 1
		chatBoxAnchor = 1
		chatCornerAnchor = 0
		ttfOffsetX = 15
	end
	if self.posId ~= 0 then
		self.grilNode = display.newNode()
		self.baseNode:addChild(self.grilNode)
		local girlTable = {}
		self.girl = display.newSprite("#tuto_girl.png")
		self.girl:setPosition(self.pos[self.posId])
		girlTable[#girlTable + 1] = self.girl
		self.girl:setFlipX(flip)
		self.grilNode:addChild(self.girl)
		local girlWidth = self.girl:getContentSize().width
		local girlHeight = self.girl:getContentSize().height
		local girlPosX = self.girl:getPositionX()
		local girlPosY = self.girl:getPositionY()
		local corner_offsetX = 7
		local chatBox_offsetX = 100
		local chatBox_offsetY = 70
		local tutoStr = param.intro or common:getLanguageString("@xinshouydxmm")
		local tutoStrLen = #tostring(tutoStr) / 3
		local colHigh = 24
		local chatOffsetY = 40
		local chatWidth = 250
		self.chatBox = display.newScale9Sprite("#tuto_msgbox.png")
		self.chatBox:setAnchorPoint(cc.p(chatBoxAnchor, 0.5))
		self.chatBox:setPosition(girlPosX - chatBox_offsetX * flipSign, girlPosY + chatBox_offsetY)
		self.grilNode:addChild(self.chatBox)
		girlTable[#girlTable + 1] = self.chatBox
		self.chatChorner = display.newSprite("#tuto_msgfrom.png")
		self.chatChorner:setAnchorPoint(cc.p(chatCornerAnchor, 0.5))
		self.chatChorner:setFlipX(not flip)
		self.chatChorner:setPosition(self.chatBox:getPositionX() - corner_offsetX * flipSign, self.chatBox:getPositionY())
		self.grilNode:addChild(self.chatChorner)
		girlTable[#girlTable + 1] = self.chatChorner
		local ttfAlian = ui.TEXT_ALIGN_LEFT
		if tutoStrLen < 12 then
			ttfAlian = ui.TEXT_ALIGN_CENTER
		end
		
		self.tutoTTF = ui.newTTFLabel({
		text = tutoStr,
		align = ttfAlian,
		size = 24,
		dimensions = cc.size(chatWidth - 40, 0),
		font = FONTS_NAME.font_fzcy,
		color = cc.c3b(73, 35, 18),
		})
		girlTable[#girlTable + 1] = self.tutoTTF
		self.chatBox:setContentSize(cc.size(chatWidth, self.tutoTTF:getContentSize().height + 30 + chatOffsetY))
		self.tutoTTF:setAnchorPoint(ccp(chatBoxAnchor, 0.5))
		self.tutoTTF:setPosition(self.chatBox:getPositionX() - ttfOffsetX * flipSign, self.chatBox:getPositionY())
		self.grilNode:addChild(self.tutoTTF)
		for k, v in pairs(girlTable) do
			local girlFadeAct = getAppearAct(tuData.girl_appear_time)
			v:setOpacity(0)
			v:runAction(girlFadeAct)
		end
		--[[
		local skipBtn = display.newSprite("#tuto_jump_btn.png")
		addTouchListener(skipBtn, function(sender, eventType)
			if eventType == EventType.began then
				skipBtn:setScale(0.9)
			elseif eventType == EventType.ended then
				skipBtn:setScale(1)
				TutoMgr.setServerNum({setNum = 999999})
				if callBack ~= nil then
					callBack()
				end
				ResMgr.delayFunc(0.01, function()
					self:removeSelf()
				end,
				self)
			elseif eventType == EventType.cancel then
				skipBtn:setScale(1)
			end
		end)
		skipBtn:setAnchorPoint(cc.p(1, 1))
		skipBtn:setPosition(cc.p(display.width - 10, display.height - 10))
		if GAME_TUTO_SKIP and game.isCanSkipGame then
			self:addChild(skipBtn)
		end
		]]
	end
	local isShowGirl = param.isShowGirl
	if isShowGirl == 0 then
		self.tutoTTF:setVisible(false)
		self.chatChorner:setVisible(false)
		self.chatBox:setVisible(false)
		self.girl:setVisible(false)
	elseif isShowGirl == 2 then
		self.girl:setVisible(false)
		self.chatChorner:setVisible(false)
	end
	
	self.baseNode:setVisible(false)
	clippingNode:setVisible(false)
	
	local function appearFunc()
		if self.unlockFunc ~= nil then
			self.unlockFunc()
		end
		self.baseNode:setVisible(true)
		clippingNode:setVisible(true)
		self._canTouch = true
		function self.callBackFunc()
			isTutoExist = false
			if self._info ~= nil then
				dump("[______________________TutoLayer_callBackFunc_________________]" ..self._info)
			else
				dump("[______________________TutoLayer_callBackFunc_________________]")
			end
			
			dump(param.tuData)
			if isMask == 1 then
				ResMgr.createTutoMask(self:getParent())
			end
			self:setTag(99999)
			TutoMgr.unlockTable()
			if callBack ~= nil then
				callBack()
			end
			ResMgr.delayFunc(0.01, function()
				self:removeSelf()
			end,
			self)
		end
	end
	
	--ÑÓÊ±³öÏÖ
	ResMgr.delayFunc(delay, appearFunc, self)
end

function TutoLayer:initPos()
	local displayWidth = display.width
	local displayHeight = display.height
	local leftPosX = 0.2 * displayWidth
	local rightPosX = 0.8 * displayWidth
	local bottomPosY = 0.25 * displayHeight
	local middlePosY = 0.4375 * displayHeight
	local topPosY = 0.7 * displayHeight
	self.pos = {
	cc.p(leftPosX, middlePosY),
	cc.p(rightPosX, middlePosY),
	cc.p(leftPosX, bottomPosY),
	cc.p(rightPosX, bottomPosY),
	cc.p(leftPosX, topPosY),
	cc.p(rightPosX, topPosY)
	}
end

return TutoLayer