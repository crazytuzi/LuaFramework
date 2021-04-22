-- @Author: xurui
-- @Date:   2019-03-05 11:12:03
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-05-09 17:58:46
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAvatarWalk = class("QUIWidgetAvatarWalk", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")

function QUIWidgetAvatarWalk:ctor(options)
    QUIWidgetAvatarWalk.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._heroAvatar = {}
	self._avatarAnimation = {}
	self._targetPos = {}       --记录人物移动终点位置
	self._walkScheduler = {}

	self._speed = 100
end

function QUIWidgetAvatarWalk:onEnter()
end

function QUIWidgetAvatarWalk:onExit()
	for _, value in pairs(self._walkScheduler) do
		scheduler.unscheduleGlobal(value)
	end

	for _, value in pairs(self._heroAvatar) do
		value:removeFromParent()
	end
	self._heroAvatar = {}
end

--[[
heroList:{
	int actorId;
	int skinId;
	string userName;
}
]]
function QUIWidgetAvatarWalk:setInfo(heroList, heroRange)
	self._heroRange = heroRange

	for actorId, avatar in pairs(self._heroAvatar) do
		avatar:setVisible(false)
		self:removeAutoWalkAnimation(actorId, avatar)
	end

	local createAvatar = function(index, heroInfo)
		if self._heroAvatar[index] == nil then
			self._heroAvatar[index] = QUIWidgetHeroInformation.new({isAutoPlay = false})
			self._heroAvatar[index]:setAvatarByHeroInfo({skinId = heroInfo.skinId}, heroInfo.actorId, 0.5)
			self:addChild(self._heroAvatar[index])
			self._heroAvatar[index]:setTouchNodeStatus(false)
		end
		return self._heroAvatar[index]
	end

	for index, info in pairs(heroList) do
		local avatar = createAvatar(index, info)
		avatar:setVisible(true)
		avatar:setNamePositionOffset(-10, -180)
		avatar:setNameScale(0.7)
		avatar:setNameVisible(true, false)
		avatar:getNameTF():setString(info.userName or "")
		local startPos = math.random(0, self._heroRange.width)
		avatar:setPosition(ccp(startPos, -50))
		self:_setOP(info.officialPosition, avatar)
		self:setAutoWalkAnimation(index, info.actorId, avatar)
	end
end

function QUIWidgetAvatarWalk:_setOP(officialPosition, avatar)
	local path = QResPath("society_op")[officialPosition]
	if not path then 
		avatar:setSocietyOfficialPosition()
		return 
	end
	local sprite = CCSprite:create(path)
	avatar:setSocietyOfficialPosition(sprite)
	avatar:setSOPOffset(10, -100)
end

function QUIWidgetAvatarWalk:setAutoWalkAnimation(index, actorId, avatar)
	if avatar == nil or actorId == nil then return end
	if self._walkScheduler[index] then
		scheduler.unscheduleGlobal(self._walkScheduler[index])
		self._walkScheduler[index] = nil
	end
	self:removeAutoWalkAnimation(actorId, avatar)

	local startDirection = math.random(1, 2) -- 1:向左，2:向右
	local moveTime = math.random(3, 5) -- 移动时间
	local standTime = math.random(5, 10) -- 停留时间
	local moveOffsetX = self._speed * moveTime --移动距离
	local currentPosX = avatar:getPositionX()

	if startDirection == 1 then
		if currentPosX - moveOffsetX < 0 then
			moveOffsetX = -currentPosX
		else
			moveOffsetX = -moveOffsetX
		end
	elseif startDirection == 2 then
		if (currentPosX + moveOffsetX) > self._heroRange.width then
			moveOffsetX = self._heroRange.width - currentPosX
		end
	end

	--避免站在重叠位置
	moveOffsetX = self:checkEndPos(index, avatar, moveOffsetX)
	moveTime = math.abs(moveOffsetX) / self._speed

	--direction
	if moveOffsetX < 0 then
		avatar:getAvatar():setScaleX(-0.5)
	else
		avatar:getAvatar():setScaleX(0.5)
	end

	avatar:getAvatar():setAutoStand(true)
	avatar:avatarPlayAnimation(ANIMATION_EFFECT.WALK, false, function()
			if avatar and avatar.getAvatar then
				avatar:avatarPlayAnimation(ANIMATION_EFFECT.WALK)
			end
		end)
	local animationArray = CCArray:create()
	animationArray:addObject(CCMoveBy:create(moveTime, ccp(moveOffsetX, 0)))
	animationArray:addObject(CCCallFunc:create(function()
		if avatar and avatar.getAvatar and avatar:getAvatar() then
			avatar:getAvatar():stopDisplay()
		end
	end))
	self._avatarAnimation[index] = avatar:runAction(CCSequence:create(animationArray))

	self._walkScheduler[index] = scheduler.performWithDelayGlobal(function()
			self:setAutoWalkAnimation(index, actorId, avatar)
		end, standTime)
	
end

function QUIWidgetAvatarWalk:checkEndPos(index, avatar, offsetX)
	if q.isEmpty(self._targetPos) then
		self._targetPos = {}
	end

	local checkNum = 0
	local checkFunc
	checkFunc = function(offset)
		if checkNum > 4 then
			return offset
		end

		local endPos = avatar:getPositionX() + offset
		local gap = 100
		for i, value in ipairs(self._targetPos) do
			if i ~= index and endPos + gap > value and endPos - gap < value then
				if offset > 0 then
					offset =  offset - gap
				else
					offset =  offset + gap
				end
				checkNum = checkNum + 1
				offset = checkFunc(offset)
				break
			end
		end

		return offset
	end
	offsetX = checkFunc(offsetX)
	
	self._targetPos[index] = avatar:getPositionX() + offsetX

	return offsetX
end

function QUIWidgetAvatarWalk:removeAutoWalkAnimation(actorId, avatar)
	if avatar == nil or actorId == nil then return end

	if self._avatarAnimation[actorId] then
		avatar:stopAction(self._avatarAnimation[actorId])
		self._avatarAnimation[actorId] = nil
	end
end

function QUIWidgetAvatarWalk:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetAvatarWalk
 