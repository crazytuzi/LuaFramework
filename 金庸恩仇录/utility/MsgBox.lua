local MsgBox = class("MsgBox", function (param)
	return require("utility.ShadeLayer").new()
end)
function MsgBox:ctor(param)
	local size = param.size or CCSizeMake(display.width * 0.9, display.height * 0.5)
	local baseNode = display.newNode()
	self:addChild(baseNode)
	baseNode:setContentSize(size)
	local content = param.content or ""
	local leftBtnName = param.leftBtnName or ""
	local midBtnName = param.midBtnName or ""
	local rightBtnName = param.rightBtnName or ""
	local leftBtnFunc = param.leftBtnFunc
	local midBtnFunc = param.midBtnFunc
	local rightBtnFunc = param.rightBtnFunc
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("public/window_msgBox", rootProxy, self._rootnode, baseNode, size)
	baseNode:setPosition(display.cx, display.cy)
	baseNode:addChild(rootnode, 1)
	local bgWidth = size.width
	local bgHeight = size.height
	self._rootnode.content:setString(content)
	local showClose = param.showClose or false
	
	if showClose then
		self._rootnode.backBtn:setVisible(true)
	end
	
	self._rootnode.backBtn:addHandleOfControlEvent(function (sender, eventName)
		if param.directclose == nil and leftBtnFunc ~= nil then
			leftBtnFunc()
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	if leftBtnName == "" and midBtnName == "" and rightBtnName == "" then
		midBtnName = common:getLanguageString("@queding")
	end
	if leftBtnName == "" then
		self._rootnode.leftBtn:setVisible(false)
	else
		self._rootnode.leftBtn:setVisible(true)
		resetctrbtnString(self._rootnode.leftBtn, leftBtnName)
		self._rootnode.leftBtn:addHandleOfControlEvent(function (sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if leftBtnFunc ~= nil then
				leftBtnFunc()
			end
			self:removeSelf()
		end,
		CCControlEventTouchUpInside)
	end
	
	if midBtnName == "" then
		self._rootnode.midBtn:setVisible(false)
	else
		self._rootnode.midBtn:setVisible(true)
		resetctrbtnString(self._rootnode.midBtn, midBtnName)
		self._rootnode.midBtn:addHandleOfControlEvent(function (sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			if midBtnFunc ~= nil then
				midBtnFunc()
			end
			self:removeSelf()
		end,
		CCControlEventTouchUpInside)
	end
	
	if rightBtnName == "" then
		self._rootnode.rightBtn:setVisible(false)
	else
		self._rootnode.rightBtn:setVisible(true)
		resetctrbtnString(self._rootnode.rightBtn, rightBtnName)
		self._rootnode.rightBtn:addHandleOfControlEvent(function (sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			rightBtnFunc()
			self:removeSelf()
		end,
		CCControlEventTouchUpInside)
	end
	baseNode:setScale(0.6)
	baseNode:runAction(CCScaleTo:create(0.1, 1))
end

return MsgBox