local CommonButton = class("CommonButton", function ()
	local layer = cc.Layer:create()
	layer:setTouchEnabled(true)
	return layer
end)

CommonButton.TYPE_NORMAL = 1
CommonButton.TYPE_BUBBLE = 2
CommonButton.TYPE_DARKER = 3

function CommonButton:setColor(c)
	local child = self:getChildByTag(1)
	child:setColor(c)
end

function CommonButton:onClick()
	if self.listener then
		self.listener()
	end
end

function CommonButton:setFont(child)
	self.sprite:addChild(child)
end

function CommonButton:onButtonDown()
	if self.btnType == CommonButton.TYPE_NORMAL then
		self:normal1(-20, 0.11, function ()
		end)
	end
end

function CommonButton:onButtonUp(taped)
	if self.btnType == CommonButton.TYPE_NORMAL then
		self:normal2(10, 0.1, function ()
			self.actioning = false
		end)
	end
	if taped then
		self:onClick()
	end
end

function CommonButton:setListener(listener)
	self.listener = listener
end

function CommonButton:getContentSize()
	return self.sprite:getContentSize()
end

function CommonButton:setScale(x)
	self.sprite:setScale(x)
end

function CommonButton:ctor(params)
	local img = params.img
	self.listener = params.listener
	self.btnType = params.btnType or CommonButton.TYPE_NORMAL
	self.font = params.font
	local t = type(img)
	if t == "userdata" then
		t = tolua.type(img)
	end
	if t == "cc.Sprite" then
		self.sprite = img
	else
		self.sprite = display.newSprite(img)
	end
	self:ignoreAnchorPointForPosition(false) 
	self:setContentSize(self.sprite:getContentSize())
	function self.getContentSize(_)
		return self.sprite:getContentSize()
	end
	
	self:align(display.CENTER)
	self.sprite:align(display.CENTER)
	self.sprite:setPosition(self.sprite:getContentSize().width / 2, self.sprite:getContentSize().height / 2)
	self:addChild(self.sprite, 1, 1)
	if self.font ~= nil then
		self.font:align(display.CENTER, self.sprite:getContentSize().width / 2, self.sprite:getContentSize().height / 2)		
		self.sprite:addChild(self.font)
	end
	local boundBox = self.sprite:boundingBox()
	local function onTouchEvent(event)
		if event.name == "began" then		
			if cc.rectContainsPoint(boundBox, self.sprite:convertToNodeSpace(cc.p(event.x, event.y))) then
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				self:onButtonDown()
				return true
			else
				return false
			end
		elseif event.name == "ended" then
			local taped = cc.rectContainsPoint(boundBox, self.sprite:convertToNodeSpace(cc.p(event.x, event.y)))
			self:onButtonUp(taped)
		end
	end
	
	self.actioning = false
	
	self:registerScriptTouchHandler(function(event, x, y)
		return onTouchEvent({name = event, x = x, y = y})
	end)
	
end

function CommonButton:normal1(offset, time, onComplete)
	local x, y = self.sprite:getPosition()
	local size = self.sprite:getContentSize()
	local scaleX = self.sprite:getScaleX() * (size.width + offset) / size.width
	local scaleY = self.sprite:getScaleY() * (size.height + offset) / size.height
	self.sprite:runAction(transition.sequence({
	CCScaleTo:create(time, scaleX, scaleY),
	CCCallFunc:create(function (...)
		self.sprite:setOpacity(200)
	end),
	CCCallFunc:create(onComplete)
	}))
end

function CommonButton:normal2(offset, time, onComplete)
	local x, y = self.sprite:getPosition()
	local size = self.sprite:getContentSize()
	local scaleX = 1
	local scaleY = 1
	self.sprite:runAction(transition.sequence({
	CCScaleTo:create(time, 1.08, 1.08),
	CCCallFunc:create(function (...)
		self.sprite:setOpacity(255)
	end),
	CCScaleTo:create(time / 2, scaleX, scaleY),
	CCCallFunc:create(onComplete)
	}))
end


function CommonButton:setDisplaySprite(img)
	local newSprite
	local t = type(img)
	if t == "userdata" then
		t = tolua.type(img)
	end
	if t == "cc.Sprite" then
		newSprite = img
	else
		newSprite = display.newSprite(img)
	end
	self.sprite:setDisplayFrame(newSprite:getDisplayFrame())
	self:setContentSize(self.sprite:getContentSize())
	self.sprite:setPosition(self.sprite:getContentSize().width / 2, self.sprite:getContentSize().height / 2)
end

function CommonButton:setAlign(align)
	self:align(align)
end

return CommonButton