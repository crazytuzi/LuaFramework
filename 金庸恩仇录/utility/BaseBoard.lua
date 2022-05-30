local BaseBoard = class("BaseBoard", function (titleSprite, boardSize, hasMask)
	display.addSpriteFramesWithFile("ui/ui_float_window.plist", "ui/ui_float_window.png")
	return display.newNode()
end)
function BaseBoard:ctor(titleSprite, boardSize, hasMask)
	local hasMaskLayer = hasMask or false
	if hasMaskLayer then
		local colorLayer = display.newColorLayer(ccc4(0, 0, 0, 256))
		colorLayer:setContentSize(CCSize(display.width + 100, display.height + 100))
		colorLayer:setOpacity(128)
		colorLayer:setPosition(-display.width / 2 - 50, -display.height / 2 - 50)
		self:addChild(colorLayer)
		colorLayer:setTouchEnabled(true)
	end
	local winSize = boardSize or CCSize(display.width * 0.93, display.height * 0.65)
	local scaleBg = display.newScale9Sprite("#f_win_bg.png", x, y, winSize)
	self.bg = scaleBg
	self:add(scaleBg)
	self:setTouchEnabled(true)
	local upFrameBg = display.newScale9Sprite("#f_win_top_frame.png", scaleBg:getContentSize().width * 0.5, scaleBg:getContentSize().height * 0.99, CCSize(display.width, 45))
	scaleBg:addChild(upFrameBg)
	if titleSprite ~= nil then
		local titleBg = display.newSprite("#f_win_title_bg.png", self:getContentSize().width / 2, self:getContentSize().height + 5)
		scaleBg:addChild(titleBg)
		if tolua.type(titleSprite) == "CCSprite" then
			titleSprite:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height * 0.4)
			titleBg:addChild(titleSprite)
		elseif tolua.type(titleSprite) == "string" then
			local titleLabel = ui.newTTFLabelWithOutline({
			text = titleSprite,
			x = titleBg:getContentSize().width / 2,
			y = titleBg:getContentSize().height * 0.4,
			align = ui.TEXT_ALIGN_CENTER,
			font = FONTS_NAME.font_haibao,
			color = FONT_COLOR.TITLE_COLOR,
			outlineColor = FONT_COLOR.TITLE_OUTLINECOLOR,
			size = 30
			})
			titleBg:addChild(titleLabel)
		end
	end
	local oranmentLeft = display.newSprite("#f_win_ornament.png", 15, 10)
	oranmentLeft:setAnchorPoint(CCPoint(0.5, 1))
	upFrameBg:addChild(oranmentLeft)
	local sequenceLeft = transition.sequence({
	CCRotateTo:create(1.5, -3),
	CCRotateTo:create(1.1, 0)
	})
	local repeatActLeft = CCRepeatForever:create(sequenceLeft)
	oranmentLeft:runAction(repeatActLeft)
	local oranmentRight = display.newSprite("#f_win_ornament.png", upFrameBg:getContentSize().width - 13, 10)
	oranmentRight:setAnchorPoint(CCPoint(0.5, 1))
	upFrameBg:addChild(oranmentRight)
	local sequenceRight = transition.sequence({
	CCRotateTo:create(1.6, -3),
	CCRotateTo:create(1.1, 0)
	})
	local repeatActRight = CCRepeatForever:create(sequenceRight)
	oranmentRight:runAction(repeatActRight)
end

function BaseBoard:getContentSize()
	return self.bg:getContentSize()
end

return BaseBoard