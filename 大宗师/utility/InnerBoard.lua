local InnerBoard = class("InnerBoard", function (param)	
		
	return  display.newNode()
end)

function InnerBoard:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_zhenrong.plist", "ui/ui_zhenrong.png")
	
	local scaleBgImg= param.bgImg or "#zhenrong_bottom_bg.png"
	local scaleBgSize = param.bgSize

	local bgCornorImg = param.cornorImg or "#zhenrong_frame_corner.png"
	local bgCornorScale = param.cornorScale or 1 

	local cornerOffset = param.cornorOffset or 0.45

	local withCorner = param.withCorner 

	self.scaleBg  = display.newScale9Sprite(scaleBgImg, x, y, scaleBgSize)
	self:addChild(self.scaleBg)

	local zhengfuX = {1,-1,1,-1}
	local zhengfuY = {-1,-1,1,1}

	if withCorner~=1 then
		for index = 1,4 do 	
			
			local cornorSprite = display.newSprite(bgCornorImg, x, y)
			cornorSprite:setScale(bgCornorScale)

			local pos = {0 ,0}

			if index % 2 == 0 then
				cornorSprite:setFlipX(true)
				pos[1] = 1
			else
				pos[1] = 0 
			end

			if index > 2 then 
				cornorSprite:setFlipY(true)
				pos[2] = 0
			else
				pos[2] = 1
			end

			cornorSprite:setPosition(pos[1] * scaleBgSize.width + zhengfuX[index] * cornorSprite:getContentSize().width*cornerOffset , pos[2]*scaleBgSize.height + zhengfuY[index] * cornorSprite:getContentSize().height*cornerOffset )
			self.scaleBg:addChild(cornorSprite)


		end
	end

end

function InnerBoard:setAnchorPoint(p)
	self.scaleBg:setAnchorPoint(p)
end

function InnerBoard:getContentSize()

	return self.scaleBg:getContentSize()
end

return InnerBoard