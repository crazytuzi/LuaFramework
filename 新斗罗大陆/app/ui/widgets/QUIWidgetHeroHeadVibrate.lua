
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroHeadVibrate = class("QUIWidgetHeroHeadVibrate", QUIWidget)

function QUIWidgetHeroHeadVibrate:ctor(options)
	local starNum, iconPath, plist = remote.herosUtil:getStarIconByStarNum(options.star)
	if options.iconPath ~= nil then
		iconPath = options.iconPath
	end
	self._starScale = 1
	if options.scale ~= nil then
		self._starScale = options.scale
	end
	local ccbNum = starNum
	if options.isEquipment then
		ccbNum = starNum.."_"..starNum
	end

	local ccbFile = "effects/HeroHeadStar" .. ccbNum .. ".ccbi"
	QUIWidgetHeroHeadVibrate.super.ctor(self,ccbFile,callBacks,options)

	for i = 1, starNum do
		self._ccbOwner["star" .. i]:setVisible(false)
	end

	local function addByOne(n)
		return n >= 0 and n + 1 or n - 1
	end

    if starNum ~= nil then
		for i = 1, starNum do
			local displayFrame = QSpriteFrameByPath(iconPath)
			if displayFrame then
				self._ccbOwner["star" .. i]:setDisplayFrame(displayFrame)
			end
			
			self._ccbOwner["star" .. i]:setVisible(true)
		end
	end
	
	self._ccbOwner.node_head:addChild(options.head)
	self._ccbOwner.node_hero_star:setVisible(false)
	self._ccbOwner.node_hero_star:setScale(self._starScale)

	self._starNum = starNum or 0
end

function QUIWidgetHeroHeadVibrate:setStarPosition(x, y)
	local posX, posY = self._ccbOwner.node_hero_star:getPosition()
	self._ccbOwner.node_hero_star:setPosition(ccp(posX+x, posY+y))
end

function QUIWidgetHeroHeadVibrate:playStarAnimation(endFunc)
	self._ccbOwner.node_hero_star:setVisible(true)
	local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:runAnimationsForSequenceNamed("Default Timeline")
		if endFunc then
		    animationManager:connectScriptHandler(function(animationName)
		                animationManager:stopAnimation()
		                endFunc()
		            end)
		end


    end

    -- local star = self:getOptions().star > 5 and 1 or self:getOptions().star
	for i=1, self._starNum, 1 do
		local timeHandler = scheduler.performWithDelayGlobal(function ()
			app.sound:playSound("common_star")
		end, 0.3*(i-1)+0.2)
	end
end

return QUIWidgetHeroHeadVibrate
