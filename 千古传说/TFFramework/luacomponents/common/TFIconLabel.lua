--[[--
	icon + label:
]]

TFIconLabel_IconLeft = 1
TFIconLabel_IconUp = 2
TFIconLabel_IconRight = 3
TFIconLabel_IconDown = 4

TFIconLabel = class('TFIconLabel',function ( )
	local  iconLabel = TFPanel:create()
	iconLabel.Label  = TFLabel:create()
	iconLabel.Icon   = TFImage:create()
	iconLabel.Gap 	 = 0
	iconLabel.selfSizeObj = CCSizeMake(0,0)
	iconLabel.IconVerAlign  = kCCVerticalTextAlignmentCenter
	iconLabel.LabelVerAlign = kCCVerticalTextAlignmentCenter
	iconLabel:addChild(iconLabel.Label)
	iconLabel:addChild(iconLabel.Icon)
	iconLabel:setAnchorPoint(ccp(0,0))
	iconLabel.isRunning = false

	iconLabel:addMEListener(TFWIDGET_ENTER, function(self)
		iconLabel:enter()
	end)
	iconLabel:addMEListener(TFWIDGET_EXIT, function(self)
		iconLabel:leave()
	end)
	iconLabel.__localSetSize = iconLabel.setSize
	iconLabel.__localSetSizePercent = iconLabel.setSizePercent
	iconLabel.__localSetAnchorPoint = iconLabel.setAnchorPoint
	iconLabel.ignore = true
	iconLabel.nIconDir = TFIconLabel_IconLeft
	return iconLabel
end)


function TFIconLabel:create(texture,szTxt)
	local  obj =  TFIconLabel:new()
	if szTxt then
		obj:setText(szTxt)
		obj:setFontSize(24)
	end
	if texture then
		obj:setIcon(texture)
	end
	return obj
end

function TFIconLabel:getEditorDescription()
	return "TFIconLabel"
end

function TFIconLabel:clone()
	print('clone TFIconLabel')
	local obj = TFIconLabel:create()
	obj.Icon = self.Icon:clone(false)
	obj.Label = self.Label:clone(false)

	obj:removeChild(obj.Label)
	obj:removeChild(obj.Icon)
	obj:addChild(obj.Label)
	obj:addChild(obj.Icon)
	obj.Gap 	 = self.Gap
	obj.selfSizeObj = self.selfSizeObj
	obj.IconVerAlign  = self.IconVerAlign
	obj.LabelVerAlign = self.LabelVerAlign
	obj:ignoreContentAdaptWithSize(self:isIgnoreContentAdaptWithSize())
	obj.nIconDir = self.nIconDir
	luaComponentsCopyProperties(obj, self)
	return obj
end

function TFIconLabel:updatePosition( )
	local mSizeObj      = self:getSize()
	local mIconSizeObj 	= self.Icon:getSize()
	local mTextSizeObj 	= self.Label:getSize()
	local mIconPosObj 	= ccp(0,0)
	local mTextPosObj   = ccp(0,0)
	local nScaleX, nScaleY = self:getScaleX(), self:getScaleY()
	self:setScaleX(1.0)
	self:setScaleY(1.0)

	-- new iconlabe support left and right
	local newWidth, newHeight = 0, 0
	if not self:isIgnoreContentAdaptWithSize() then
		newWidth = mSizeObj.width
		newHeight = mSizeObj.height
	end
	local function setIconPos()
		if self.nIconDir == TFIconLabel_IconLeft then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = mIconSizeObj.width + mTextSizeObj.width + self.Gap, math.max(mIconSizeObj.height, mTextSizeObj.height)
			end
			mIconPosObj.x = mIconSizeObj.width * 0.5
			if self.IconVerAlign == kCCVerticalTextAlignmentCenter then
				mIconPosObj.y 	= newHeight * 0.5
			elseif self.IconVerAlign == kCCVerticalTextAlignmentTop then
				mIconPosObj.y 	= newHeight - mIconSizeObj.height * 0.5
			else
				mIconPosObj.y 	= mIconSizeObj.height * 0.5
			end
		elseif self.nIconDir == TFIconLabel_IconUp then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = math.max(mIconSizeObj.width, mTextSizeObj.width), mIconSizeObj.height + mTextSizeObj.height
			end
			mIconPosObj.x = newWidth * 0.5
			mIconPosObj.y = mTextSizeObj.height + mIconSizeObj.height * 0.5
		elseif self.nIconDir == TFIconLabel_IconRight then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = mIconSizeObj.width + mTextSizeObj.width + self.Gap, math.max(mIconSizeObj.height, mTextSizeObj.height)
			end
			mIconPosObj.x = mTextSizeObj.width + self.Gap + mIconSizeObj.width * 0.5
			if self.IconVerAlign == kCCVerticalTextAlignmentCenter then
				mIconPosObj.y 	= newHeight * 0.5
			elseif self.IconVerAlign == kCCVerticalTextAlignmentTop then
				mIconPosObj.y 	= newHeight - mIconSizeObj.height * 0.5
			else
				mIconPosObj.y 	= mIconSizeObj.height * 0.5
			end
		elseif self.nIconDir == TFIconLabel_IconDown then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = math.max(mIconSizeObj.width, mTextSizeObj.width), mIconSizeObj.height + mTextSizeObj.height
			end
			mIconPosObj.x = mTextSizeObj.width * 0.5
		end
	end
	local function setLabelPos()
		if self.nIconDir == TFIconLabel_IconLeft then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = mIconSizeObj.width + mTextSizeObj.width + self.Gap, math.max(mIconSizeObj.height, mTextSizeObj.height)
			end
			mTextPosObj.x = mIconSizeObj.width + self.Gap + mTextSizeObj.width * 0.5
			if self.LabelVerAlign == kCCVerticalTextAlignmentCenter then
				mTextPosObj.y 	= newHeight * 0.5
			elseif self.LabelVerAlign == kCCVerticalTextAlignmentTop then
				mTextPosObj.y 	= newHeight - mTextSizeObj.height * 0.5
			else
				mTextPosObj.y 	= mTextSizeObj.height * 0.5
			end
		elseif self.nIconDir == TFIconLabel_IconUp then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = math.max(mIconSizeObj.width, mTextSizeObj.width), mIconSizeObj.height + mTextSizeObj.height
			end
			mTextPosObj.x = mIconSizeObj.width * 0.5
		elseif self.nIconDir == TFIconLabel_IconRight then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = mIconSizeObj.width + mTextSizeObj.width + self.Gap, math.max(mIconSizeObj.height, mTextSizeObj.height)
			end
			mTextPosObj.x = mTextSizeObj.width * 0.5
			if self.LabelVerAlign == kCCVerticalTextAlignmentCenter then
				mTextPosObj.y 	= newHeight * 0.5
			elseif self.LabelVerAlign == kCCVerticalTextAlignmentTop then
				mTextPosObj.y 	= newHeight - mTextSizeObj.height * 0.5
			else
				mTextPosObj.y 	= mTextSizeObj.height * 0.5
			end
		elseif self.nIconDir == TFIconLabel_IconDown then
			if self:isIgnoreContentAdaptWithSize() then
				newWidth, newHeight = math.max(mIconSizeObj.width, mTextSizeObj.width), mIconSizeObj.height + mTextSizeObj.height
			end
			mTextPosObj.x = mIconSizeObj.width * 0.5
		end
	end

	setIconPos()
	setLabelPos()
	local point = self:getAnchorPoint()
	local offsetPoint = ccp(point.x * mSizeObj.width, point.y * mSizeObj.height)
	mIconPosObj = ccpSub(mIconPosObj, offsetPoint)
	mTextPosObj = ccpSub(mTextPosObj, offsetPoint)

	self.Icon:setPosition(mIconPosObj)
	self.Label:setPosition(mTextPosObj)


	if self:isIgnoreContentAdaptWithSize() then
		self:__localSetSize(CCSizeMake(newWidth, newHeight))
	end

	self:setScaleX(nScaleX)
	self:setScaleY(nScaleY)

end

function TFIconLabel:setIconDir(nDir)
	self.nIconDir = nDir
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:ignoreContentAdaptWithSize(bRet)
	self.ignore = bRet
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:isIgnoreContentAdaptWithSize(bRet)
	return self.ignore
end

function TFIconLabel:setAnchorPoint(point)
	self:__localSetAnchorPoint(point)
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:setSize(sizeObj)
	self.selfSizeObj = sizeObj
	self:__localSetSize(sizeObj)
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:setSizePercent(sizeObj)
	self.selfSizeObj = sizeObj
	self:__localSetSizePercent(sizeObj)
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:setGap(nVal)
	self.Gap = nVal
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:getGap(  )
	return self.Gap
end

function TFIconLabel:setIcon( sTexture )
	if sTexture then
		self.Icon:setTexture(sTexture)
		if self.isRunning then 
			TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
		end
	end
end

function TFIconLabel:setText( sTxt )
	if sTxt then
		self.Label:setText(sTxt)
		if self.isRunning then 
			TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
		end
	end
end

function TFIconLabel:getText()
	return self.Label:getText()
end

function TFIconLabel:setTextVAlign( verticalAlign )
	self.LabelVerAlign = verticalAlign
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:setTextVerticalAlignment(verticalAlign)
	self:setTextVAlign( verticalAlign )
end

function TFIconLabel:setIconVAlign( verticalAlign )
	self.IconVerAlign = verticalAlign
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:getTextVAlign( )
	return self.LabelVerAlign
end

function TFIconLabel:getIconVAlign( )
	return self.IconVerAlign
end

function TFIconLabel:setFontSize( nSize )
	self.Label:setFontSize(nSize)
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:setFontName( sName )
	self.Label:setFontName(sName)
	if self.isRunning then 
		TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
	end
end

function TFIconLabel:setTextColor( color )
	self.Label:setFontColor(color)
	if me.platform == me.platforms[me.PLATFORM_WIN32] then
		self.Label:setColor(color)
	end
end

function TFIconLabel:getTextColor()
	local color = self.Label:getFontColor()
	if me.platform == me.platforms[me.PLATFORM_WIN32] then
		color = self.Label:getColor()
	end
	return color
end

function TFIconLabel:setFontColor(color)
	self:setTextColor(color)
end

function TFIconLabel:getFontColor()
	return self:getTextColor()
end

function TFIconLabel:setTouchScaleChangeAble( bAbled )
	self.Label:setTouchScaleChangeEnabled(bAbled)
end

function TFIconLabel:isTouchScaleChangeEnabled()
	return self.Label:isTouchScaleChangeEnabled()
end

function TFIconLabel:enableShadow(shadowColor, shadowOffset, shadowOpacity, shadowBlur)
	-- print("enable Shadow", shadowColor, shadowOffset, shadowOpacity, shadowBlur)
	if shadowBlur == nil then shadowBlur = 1 end
	return self.Label:enableShadow(shadowColor, shadowOffset, shadowOpacity, shadowBlur)
end

function TFIconLabel:disableShadow()
	self.Label:disableShadow()
end

function TFIconLabel:enableStroke(strokeColor, strokeSize, mustUpdateTexture)
	if mustUpdateTexture == nil then mustUpdateTexture = true end
	return self.Label:enableStroke(strokeColor, strokeSize, mustUpdateTexture)
end

function TFIconLabel:disableStroke()
	self.Label:disableStroke()
end

function TFIconLabel:getIcon()
	return self.Icon
end

function TFIconLabel:getLabel()
	return self.Label
end

function TFIconLabel:onSizeChangeFunc(tEvent)
	if self.selfSizeObj.width == 0 then
		local mIconSize  = self.Icon:getSize()
		local mLabelSize = self.Label:getSize()
		local mSize = CCSizeMake(mIconSize.width + mLabelSize.width + self.Gap, math.max(mIconSize.height, mLabelSize.height))
		if mSize.height < mLabelSize.height then
			mSize.height = mLabelSize.height
		end
		if mSize.height ~= 0 and mSize.width ~= 0 then
			self:setSize(mSize)
		end
	end
	self:updatePosition()
	self:updatePosition()
end

function TFIconLabel:registerEvents()
	TFDirector:addMEListener(self, "SIZE_CHANGE", self.onSizeChangeFunc)
end

function TFIconLabel:removeEvents()
	TFDirector:removeMEListener(self, "SIZE_CHANGE", self.onSizeChangeFunc)
end

function TFIconLabel:enter()
	self.isRunning = true
	self:registerEvents()
	TFDirector:dispatchEventWith(self,"SIZE_CHANGE")
end

function TFIconLabel:leave()
	self.isRunning = false
	self:removeEvents()
end

local function new(val, parent)
	local obj
	obj = TFIconLabel:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

function TFIconLabel:initControl(val, parent)
	-- Old Editor
	if val['szIconTexture'] == '' or (not val['szIconTexture'] and not val.tIconLabelProperty) then 
		return TFLabel:initControl(val, parent)
	end
	-- New Editor
	if val.tIconLabelProperty and (val.tIconLabelProperty['szIcon'] == "" or not val.tIconLabelProperty['szIcon']) then
		return TFLabel:initControl(val, parent)
	end
	local obj = new(val,parent)
	obj:initMEIconLabel(val, parent)
	return true, obj
end

return TFIconLabel