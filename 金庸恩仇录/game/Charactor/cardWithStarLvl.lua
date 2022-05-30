local cardWithStarLvl = class("cardWithStarLvl", function()
	local  layer = display.newNode()
    return layer
end)

function cardWithStarLvl:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
	local image = param.image
	local starNum = param.starNum
	self.cardBg = display.newSprite("#heroinfo_cardbg.png", x, y)
	self:addChild(self.cardBg)
	local bgWidth = self.cardBg:getContentSize().width 
	local bgHeight =  self.cardBg:getContentSize().height

	self.heroImage = display.newSprite(image)
	self.heroImage:setScale(0.85)
	self.heroImage:setPosition(bgWidth/2,bgHeight*0.6)
	self.cardBg:addChild(self.heroImage)


	local function setStars(num)
		for i=1,starNum do
			local stars = display.newSprite("#f_win_star.png")
			stars:setPosition(bgWidth*0.2  + 0.8*(i-1)*stars:getContentSize().width, bgHeight*0.09) 
			stars:setScale(0.8)
			self.cardBg:addChild(stars)
		end
	end
	setStars(starNum)
end

-- function cardWithStarLvl:setStars(num)
-- end

function cardWithStarLvl:getContentSize()
	return self.cardBg:getContentSize()
end

return cardWithStarLvl