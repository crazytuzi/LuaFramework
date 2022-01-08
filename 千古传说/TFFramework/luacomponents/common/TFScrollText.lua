--[[--
	text scroll:
]]

TFScrollText = class('TFScrollText',function (isUseRichTxt)
	local  scrollPanel = TFPanel:create()
	if isUseRichTxt then 
		scrollPanel.Label  = TFRichText:create()
	else
		scrollPanel.Label  = TFLabel:create()
		scrollPanel.Label:setFontSize(24)
	end
	scrollPanel.speed  = 1
	scrollPanel.updateFunc = 0
	scrollPanel.scrollDirection = TFScrollText.SCROLLHORIZONTAL or 0   --Horizontal:0  Vertical:1
	--scrollPanel.clipRect = CCRectMake(0,0,0,0) 
	scrollPanel:setAnchorPoint(ccp(0,0))
	scrollPanel:setClippingEnabled(true)
	scrollPanel:addChild(scrollPanel.Label)

	scrollPanel:addMEListener(TFWIDGET_ENTER,function()
		scrollPanel:start()
	end)
	
	scrollPanel:addMEListener(TFWIDGET_EXIT,function()
		scrollPanel:stop()
	end)

	scrollPanel.__localSetSize = scrollPanel.setSize
	return scrollPanel
end)


TFScrollText.SCROLLHORIZONTAL = 0
TFScrollText.SCROLLVERTICAL   = 1

function TFScrollText:stopScroll( )
	TFDirector:removeEnterFrameEvent(self.updateFunc)
end

function TFScrollText:startScroll( )
	TFDirector:removeEnterFrameEvent(self.updateFunc)
	self.updateFunc = TFScrollText:updatePosition()
	TFDirector:addEnterFrameEvent(self.updateFunc, self)
end

function TFScrollText:updatePosition( )
	return function(self)
		if not self or self.Label == nil then
			self:stop()
			return
		end

		if self.scrollDirection == self.SCROLLHORIZONTAL then --horizontal
			self.Label:setPosition(ccp(self.Label:getPosition().x + (-1)* self.speed,self.Label:getPosition().y))
			if(self.Label:getPosition().x + self.Label:getSize().width * 0.5  < 0) then
				self.Label:setPosition(ccp(self:getSize().width + self.Label:getSize().width * 0.5,self:getSize().height * 0.5))
			end
		else --vertical
			self.Label:setPosition(ccp(self.Label:getPosition().x,self.Label:getPosition().y + 1 * self.speed))
			if(self.Label:getPosition().y + self.Label:getSize().height * (-0.5) > self:getSize().height ) then
				self.Label:setPosition(ccp(self:getSize().width * 0.5 ,self.Label:getSize().height * 0.5 - self:getSize().height))
			end
		end
	end
end

function TFScrollText:create(sTxt, isUseRichTxt)
	local  obj =  TFScrollText:new(isUseRichTxt)
	if sTxt then
		obj:registerEvents()
		obj.Label:setText(sTxt)
	end
	return obj
end

function TFScrollText:setScrollDirection( nDirectoin )
	self.scrollDirection = nDirectoin
	TFDirector:dispatchEventWith(self,"UPDATE_POS")
end

function TFScrollText:setSize(sizeObj)
	self:__localSetSize(sizeObj)
	TFDirector:dispatchEventWith(self,"UPDATE_POS")
end

function TFScrollText:setSpeed(nSpeed)
	self.speed = nSpeed
end

function TFScrollText:setFontSize(nSize)
	if self.Label.setFontSize then
		self.Label:setFontSize(nSize)
		TFDirector:dispatchEventWith(self,"UPDATE_POS")
	end
end

function TFScrollText:setFontName(sName)
	if self.Label.setFontName then
		self.Label:setFontName(sName)
	end
end

function TFScrollText:setText(sTxt)
	self.Label:setText(sTxt)
	TFDirector:dispatchEventWith(self,"UPDATE_POS")
end

--set the textRect in the panel
function TFScrollText:setTextVisibleSize(sizeObj)
	if self.Label.setTextAreaSize then
		self.Label:setTextAreaSize(sizeObj)
	end
end

-- function TFScrollText:setClipRect( ccRectObj)
-- 	self.clipRect = ccRectObj
-- 	self:setClippingRegion(ccRectObj)
-- end

-- function TFScrollText:getClipRect(  )
-- 	return self.clipRect
-- end

function TFScrollText:getLabel()
	return self.Label
end

function TFScrollText:setTextPos( posObj )
	self.Label:setPosition(posObj)
	TFDirector:addMEListener(self, "UPDATE_POS", self.onSizeOrPosChangeFunc)
end

function TFScrollText:onSizeOrPosChangeFunc(tEvent)
	local mSizeObj     = self:getSize()
	local mTextSizeObj = self.Label:getSize()
	local mTextPosObj  = self.Label:getPosition()
	local mTextAnchor  = self.Label:getAnchorPoint()

	if self.scrollDirection == 0 then --Horizontal
		if mTextPosObj.x == 0 and mTextPosObj.y == 0 then
			mTextPosObj.x  = mSizeObj.width + mTextSizeObj.width * mTextAnchor.x  --horizontal right
			mTextPosObj.y  = mSizeObj.height * 0.5 + mTextSizeObj.height * (mTextAnchor.y - 0.5) --vertical center 
		end
	else --Vertical
		if mTextPosObj.x == 0 and mTextPosObj.y == 0 then
			mTextPosObj.x  = mSizeObj.width * 0.5 + mTextSizeObj.width * (mTextAnchor.x - 0.5) --horizontal center
			mTextPosObj.y  = mSizeObj.height * 0.5 + mTextSizeObj.height * (mTextAnchor.y - 0.5) --vertical center
		end
	end

	self.Label:setPosition(mTextPosObj)
end

function TFScrollText:stop()
	self:removeEvents()
	self:stopScroll()	
end

function TFScrollText:start()
	self:registerEvents()
	self:startScroll()
end

function TFScrollText:registerEvents()
	TFDirector:addMEListener(self, "UPDATE_POS", self.onSizeOrPosChangeFunc)
end

function TFScrollText:removeEvents()
	TFDirector:removeMEListener(self, "UPDATE_POS", self.onSizeOrPosChangeFunc)
end
return TFScrollText