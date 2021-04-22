
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroHeadStar = class("QUIWidgetHeroHeadStar", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetHeroHeadStar:ctor(options)
	local ccbFile = "ccb/Widget_HeroHeadStar.ccbi"
	QUIWidgetHeroHeadStar.super.ctor(self,ccbFile,callBacks,options)

	self._startPosX = self._ccbOwner.nodeSmallStar:getPositionX()
end

function QUIWidgetHeroHeadStar:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star5, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star0, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_star, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.starNum, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetHeroHeadStar:onExit()
	QUIWidgetHeroHeadStar.super.onExit(self)
	if self.effect ~= nil then
		self.effect:disappear()
	end
end

function QUIWidgetHeroHeadStar:setEmptyStar()
	self._ccbOwner.nodeBigStar:setVisible(false)
	self._ccbOwner.nodeEmptyStar:setVisible(true)
	self._ccbOwner.nodeSmallStar:setVisible(false)

end

function QUIWidgetHeroHeadStar:setStar(star, isShowEffect)
	-- self._ccbOwner.nodeSmallStar:setVisible(star <= 5)
	self._ccbOwner.nodeBigStar:setVisible(false)
	self._ccbOwner.nodeEmptyStar:setVisible(false)
	self._ccbOwner.nodeSmallStar:setVisible(true)
	for i = 1, 5 do
		self._ccbOwner["star" .. i]:setVisible(false)
	end

	local function addByOne(n)
		return n >= 0 and n + 1 or n - 1
	end

	local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(star)
	if starNum == nil then return end


    if starNum ~= nil then
		local index = 3
		local ti = 0
		for i = 1, starNum do
			local displayFrame = QSpriteFrameByPath(iconPath)
			if displayFrame then
				self._ccbOwner["star" .. index]:setDisplayFrame(displayFrame)
			end
			
			self._ccbOwner["star" .. index]:setScale(1)
			self._ccbOwner["star" .. index]:setVisible(true)
			ti = -addByOne(ti)
			index = index + ti
		end
		local offsetX = math.fmod(starNum, 2) ~= 0 and 0 or 9
	    self._ccbOwner.nodeSmallStar:setPositionX(self._startPosX + offsetX)
	end
end

function QUIWidgetHeroHeadStar:setStarEffect(star, isShowEffect , callBack)
	-- self._ccbOwner.nodeSmallStar:setVisible(star <= 5)
	self._ccbOwner.nodeBigStar:setVisible(false)
	self._ccbOwner.nodeEmptyStar:setVisible(false)
	self._ccbOwner.nodeSmallStar:setVisible(true)
	for i = 1, 5 do
		self._ccbOwner["star" .. i]:setVisible(false)
	end

	local function addByOne(n)
		return n >= 0 and n + 1 or n - 1
	end
	local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(star)
	if starNum == nil then return end

    if starNum ~= nil then
		local index = 3
		local ti = 0
		for i = 1, starNum do
			local displayFrame = QSpriteFrameByPath(iconPath)
			if displayFrame then
				self._ccbOwner["star" .. index]:setDisplayFrame(displayFrame)
			end
			
			self._ccbOwner["star" .. index]:setScale(1)
			self._ccbOwner["star" .. index]:setVisible(true)
			ti = -addByOne(ti)
			index = index + ti
		end
		local offsetX = math.fmod(starNum, 2) ~= 0 and 0 or 9
	    self._ccbOwner.nodeSmallStar:setPositionX(self._startPosX + offsetX)
	    local effectNode = self._ccbOwner["star" .. starNum]
	    if effectNode then
	    	print("effectNodeeffectNodeeffectNodeeffectNodeeffectNode")
			effectNode:setScale(0)
    		local dur = q.flashFrameTransferDur(10)
    		local arr = CCArray:create()
    		arr:addObject(CCScaleTo:create(dur, 1.2))
    		arr:addObject(CCScaleTo:create(dur, 1))
    		if callBack then
    			arr:addObject(CCDelayTime:create(dur))
		    	arr:addObject(CCCallFunc:create(callBack))
    		end
		    effectNode:runAction(CCSequence:create(arr))
	    end
	end
end



function QUIWidgetHeroHeadStar:setScale(smallRatio, bigRatio)
	smallRatio = smallRatio or 1
	self._ccbOwner.nodeSmallStar:setScale(smallRatio)
	self._ccbOwner.nodeBigStar:setScale(bigRatio or smallRatio)
end

return QUIWidgetHeroHeadStar
