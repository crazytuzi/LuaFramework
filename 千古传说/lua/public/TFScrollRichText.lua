--[[--
	text scroll:
]]

TFScrollRichText = class('TFScrollRichText',function ( )
	local  scrollPanel = TFPanel:create()
	scrollPanel.Label  = TFRichText:create(CCSizeMake(2000,24))
	scrollPanel.speed  = 1
	scrollPanel.updateFunc = 0
	scrollPanel.scrollDirection = TFScrollRichText.SCROLLHORIZONTAL or 0   --Horizontal:0  Vertical:1
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


TFScrollRichText.SCROLLHORIZONTAL = 0
TFScrollRichText.SCROLLVERTICAL   = 1

function TFScrollRichText:stopScroll()
	TFDirector:removeEnterFrameEvent(self.updateFunc)
end

function TFScrollRichText:startScroll()
	TFDirector:removeEnterFrameEvent(self.updateFunc)
	self.updateFunc = TFScrollRichText:updatePosition()
	TFDirector:addEnterFrameEvent(self.updateFunc, self)
end

function TFScrollRichText:updatePosition( )
	return function(self)
		if not self or self.Label == nil then
			TFDirector:removeEnterFrameEvent(TFScrollRichText:updatePosition())
			return
		end
		local speed = self.speed * (60 / GameConfig.FPS)
		if self:isVisible() == false then return end
		if self.scrollDirection == self.SCROLLHORIZONTAL then --horizontal
			self.Label:setPosition(ccp(self.Label:getPosition().x + (-1)* speed,self.Label:getPosition().y))
			if(self.Label:getPosition().x + self.Label:getSize().width * 0.5  < 0) then
				self.Label:setPosition(ccp(self:getSize().width + self.Label:getSize().width * 0.5,self:getSize().height * 0.5))
				if self.changeTarget and self.changeFunc then
					TFFunction.call(self.changeFunc, self.changeTarget)
				end
			end
		else --vertical
			self.Label:setPosition(ccp(self.Label:getPosition().x,self.Label:getPosition().y + speed))
			if(self.Label:getPosition().y + self.Label:getSize().height * (-0.5) > self:getSize().height ) then
				self.Label:setPosition(ccp(self:getSize().width * 0.5 ,self.Label:getSize().height * 0.5 - self:getSize().height))
				if self.changeTarget and self.changeFunc then
					TFFunction.call(self.changeFunc, self.changeTarget)
				end
			end
		end
	end
end

function TFScrollRichText:create(sTxt)
	local  obj =  TFScrollRichText:new()
	if sTxt then
		obj:registerEvents()
		obj.Label:setText(sTxt)
		--obj.Label:setFontSize(24)
	end
	return obj
end

function TFScrollRichText:setScrollDirection( nDirectoin )
	self.scrollDirection = nDirectoin
	TFDirector:dispatchEventWith(self,"UPDATE_POS")
end

function TFScrollRichText:setSize(sizeObj)
	self:__localSetSize(sizeObj)
	TFDirector:dispatchEventWith(self,"UPDATE_POS")
end

function TFScrollRichText:setSpeed(nSpeed)
	self.speed = nSpeed
end

-- function TFScrollRichText:setFontSize(nSize)
-- 	self.Label:setFontSize(nSize)
-- 	TFDirector:dispatchEventWith(self,"UPDATE_POS")
-- end

function TFScrollRichText:setFontName(sName)
	self.Label:setFontName(sName)
end

function TFScrollRichText:setText(sTxt , reset)
	if reset == nil or reset == true then
		self.Label:setPosition(ccp(0,0))
	end
	self.Label:setText(sTxt)	
	TFDirector:dispatchEventWith(self,"UPDATE_POS")
end

--set the textRect in the panel
function TFScrollRichText:setTextVisibleSize(sizeObj)
	self.Label:setTextAreaSize(sizeObj)
end

-- function TFScrollRichText:setClipRect( ccRectObj)
-- 	self.clipRect = ccRectObj
-- 	self:setClippingRegion(ccRectObj)
-- end

-- function TFScrollRichText:getClipRect(  )
-- 	return self.clipRect
-- end

function TFScrollRichText:getLabel()
	return self.Label
end

function TFScrollRichText:setTextPos( posObj )
	self.Label:setPosition(posObj)
	TFDirector:addMEListener(self, "UPDATE_POS", self.onSizeOrPosChangeFunc)
end

function TFScrollRichText:onSizeOrPosChangeFunc(tEvent)
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

function TFScrollRichText:stop()
	self:removeEvents()
	self:stopScroll()	
end

function TFScrollRichText:start()
	self:registerEvents()
	self:startScroll()
end

function TFScrollRichText:registerEvents()
	TFDirector:addMEListener(self, "UPDATE_POS", self.onSizeOrPosChangeFunc)
end

function TFScrollRichText:removeEvents()
	TFDirector:removeMEListener(self, "UPDATE_POS", self.onSizeOrPosChangeFunc)
end

function TFScrollRichText:setChangeFunc( target,func )
	self.changeTarget = target
	self.changeFunc = func
end

return TFScrollRichText