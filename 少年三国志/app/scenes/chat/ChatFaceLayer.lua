--ChatFaceLayer.lua

local ChatFaceLayer = class ("ChatFaceLayer", UFCCSModelLayer)



function ChatFaceLayer:ctor( ... )
	self._faceHandler = nil
	self._faceTarget = nil
	self._scrollView = nil

	self.super.ctor(self, ...)
end


function ChatFaceLayer:onLayerLoad( ... )
	--self:setClickClose(true)
	self:registerTouchEvent(false, true, 0)

	self._backView = self:getImageViewByName("ImageView_107")
	self:initFaceImages()
end

function ChatFaceLayer:onLayerEnter( ... )
	
end

function ChatFaceLayer:onTouchBegin( xpos, ypos )
	local curx, cury = self._backView:getPosition()
	local size = self._backView:getSize()
	local rect = CCRectMake(curx, cury, size.width, size.height)
	--__Log("rect:(%d, %d, %d, %d), pos(%d, %d)", rect.)
	if not G_WP8.CCRectContainXY(rect, xpos, ypos) then
	--if not rect:containsPoint(ccp(xpos, ypos)) then 
		self:close()
	end
end

function ChatFaceLayer:initPanelPos( xpos, ypos )
	local localPos = self._backView:convertToNodeSpace(ccp(xpos, ypos))
	local size = self._backView:getSize()
	local winSize = CCDirector:sharedDirector():getWinSize()

	self._backView:setPosition(ccp(localPos.x,  localPos.y))
end

function ChatFaceLayer.showFaceLayer( parent, posx, posy, func, target )
	if parent == nil then 
		return 
	end

	local chatPanel = require("app.scenes.chat.ChatFaceLayer").new("ui_layout/ChatPanel_FacePanel.json")
 	chatPanel._faceHandler = func
 	chatPanel._faceTarget = target

 	parent:addChild(chatPanel)

 	chatPanel:showAtCenter(false)
 	chatPanel._scrollView:jumpToTop()
 	chatPanel:setVisible(true)
	chatPanel:initPanelPos(posx, posy)
 end

 function ChatFaceLayer:onChoosenFace( fileName )
 	if self._faceHandler ~= nil and self._faceTarget ~= nil then
 		self._faceHandler(self._faceTarget, fileName)
 	elseif self._faceHandler ~= nil then
 		self._faceHandler(fileName)
 	end

 	self:close()
 end

function ChatFaceLayer:initFaceImages( ... )
	self._scrollView  = self:getScrollViewByName("ScrollView_face")
	if self._scrollView  == nil then
		return
	end

	self._scrollView:setBounceEnabled(true)
	local scrollSize = self._scrollView:getSize()

	local lineSpacing = 20
	local rowSpaceing = 10
	local startIndex = 1
	local endIndex = 54
	local maxCount = endIndex - startIndex + 1
	local maxLine = 5
	local maxRow = math.floor(maxCount/maxLine)
	if maxCount%maxLine ~= 0 then
		maxRow = maxRow + 1
	end

	local faceFormat = "ui/chat/face/%d.png"

	-- local startImgPath = string.format(faceFormat, startIndex)
	-- local startFace = ImageView:create()
	-- startFace:loadTexture(startImgPath, UI_TEX_TYPE_LOCAL)
	local xOffset = scrollSize.width/maxLine
	--local yOffset = startFace:getSize().height
	local yOffset = 75
	
	local innerSize = self._scrollView:getInnerContainerSize()
	if maxRow * yOffset > innerSize.height then 
		self._scrollView:setInnerContainerSize(CCSizeMake(innerSize.width, maxRow*yOffset))
		scrollSize.height = maxRow * yOffset
	end

	local startY = scrollSize.height - yOffset
	local startX = 0
	--local scale = 1.5

	for i = startIndex, endIndex, 1 do
		local imgPath = string.format(faceFormat, i)
		local btn = Button:create()
		btn:loadTextureNormal(imgPath, UI_TEX_TYPE_LOCAL)
		local btnSize = btn:getSize()

		local facePos = ccp(startX + ((i - 1)%maxLine + 0.5)*xOffset, startY - (math.floor((i - startIndex )/maxLine) - 0.5)*yOffset)

		--btn:setScale(scale)
		btn:setPosition(facePos)
		self._scrollView:addChild(btn)
		btn:setTag(i)
		btn:setTouchEnabled(true)
		local btnName = string.format("%d.png", i)
		btn:setName(btnName)
		self:registerBtnClickEvent(btnName, function ( widget )
			if widget == nil then
				return
			end

			local tag = widget:getTag()
			local faceName = string.format("%d.png", tag)
			self:onChoosenFace(faceName)
		end)

	end

	--local totalRect = self._scrollView :getCascadeBoundingBox(false)
	--self._scrollView :setInnerContainerSize(totalRect.size)
end

return ChatFaceLayer