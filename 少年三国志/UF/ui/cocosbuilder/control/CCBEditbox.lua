--CCBEditbox.lua


local CCBEditbox = class( "CCBEditbox", function ()
	return display.newNode()
end)

function CCBEditbox:ctor(  )
	self._acquireFocusHandler = nil
	self._loseFocusHandler = nil
	self._textChangedHandler = nil
	self._returnKeyHandler = nil
	self._editbox = nil
end

function CCBEditbox:createWithScale9Sprite( scale9Sprite, label )
	if type(scale9Sprite) ~= SCALE9SPRITE then
		scale9Sprite = tolua.cast(scale9Sprite, SCALE9SPRITE)
	end

	if scale9Sprite == nil then
		return nil
	end

	local nodeParent = scale9Sprite:getParent()
	local rect = CCRectMake(0, 0, scale9Sprite:getContentSize().width,
          scale9Sprite:getContentSize().height),
          CCRectMake(0, 0, scale9Sprite:getContentSize().width,
          scale9Sprite:getContentSize().height)
    local posX = scale9Sprite:getPositionX()
    local posY = scale9Sprite:getPositionY()

    scale9Sprite:removeFromParentAndCleanup(true)

    self._editbox = CCEditBox:create(rect.size.width, 
          rect.size.height, scale9Sprite)

    self._editbox:setFontName("Arial")
    self:addChild(self._editbox)
    self._editbox:setPosition(posX, posY)
    nodeParent:addChild(self)

    if label ~= nil then
      label = tolua.cast(label, "CCLabelTTF")
    end

    if label ~= nil then 
        self._editbox:setPlaceHolder(label:getString())
        self._editbox:setFontSize(label:getFontSize())
        self._editbox:setFontColor(label:getColor())
        self._editbox:setInputFlag(kCCBEditboxInputFlagInitialCapsAllCharacters)
        self._editbox:setInputMode(kCCBEditboxInputModeAny)
        self._editbox:setReturnType(kKeyboardReturnTypeDone)
        self._editbox:setPlaceHolderFontColor(label:getColor())
    end

    self._editbox:registerScriptCCBEditboxHandler(function ()
          if eventType == "began" then
          	self:_onAcquireFocus()
          elseif eventType == "ended" then
          	self:_onLoseFocus()
          elseif eventType == "changed" then
          	self:_onTextChanged()
          elseif eventType == "return" then
          	self:_onReturnClicked()
          end

        end)

    return self._editbox
end

function CCBEditbox:CCBEditbox(  )
  return self._editbox
end

function CCBEditbox:_onAcquireFocus( )
	if self._acquireFocusHandler ~= nil then
		self._acquireFocusHandler()
	end
end

function CCBEditbox:_onLoseFocus( )
	if self._loseFocusHandler ~= nil then
		self._loseFocusHandler()
	end
end

function CCBEditbox:_onTextChanged( )
	if self._textChangedHandler ~= nil then
		self._textChangedHandler()
	end
end

function CCBEditbox:_onReturnClicked( )
	if self._returnKeyHandler ~= nil then
		self._returnKeyHandler()
	end
end

function CCBEditbox:setOnAcquireFocusHandler( fun )
	self._acquireFocusHandler = fun
end

function CCBEditbox:setOnLoseFocusHandler( fun )
	self._loseFocusHandler = fun
end

function CCBEditbox:setOnTextChangedHandler( fun )
	self._textChangedHandler = fun
end

function CCBEditbox:setOnReturnKeyHandler( fun )
	self._returnKeyHandler = fun
end

return CCBEditbox