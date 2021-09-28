--UIHelper.lua


function UIHelper.addEditboxToNode( scale9Sprite, label)
	if type(scale9Sprite) ~= "CCScale9Sprite" then
		scale9Sprite = tolua.cast(scale9Sprite, "CCScale9Sprite")
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

    local editbox = CCEditBox:create(rect.size.width, 
          rect.size.height, scale9Sprite)

    nodeParent:addChild(editbox)
    editbox:setPosition(posX, posY)
    editbox:setFontName("Arial")

    if label ~= nil then
      label = tolua.cast(label, "CCLabelTTF")
    end

    if label ~= nil then 
        editbox:setPlaceHolder(label:getString())
        editbox:setFontSize(label:getFontSize())
        editbox:setFontColor(label:getColor())
        editbox:setInputFlag(kEditBoxInputFlagInitialCapsAllCharacters)
        editbox:setInputMode(kEditBoxInputModeAny)
        editbox:setReturnType(kKeyboardReturnTypeDone)
        editbox:setPlaceHolderFontColor(label:getColor())
    end

    return editbox
end