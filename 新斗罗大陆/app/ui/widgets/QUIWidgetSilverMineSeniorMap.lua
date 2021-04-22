local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineSeniorMap = class("QUIWidgetSilverMineSeniorMap", QUIWidget)
 
function QUIWidgetSilverMineSeniorMap:ctor(options)
	local ccbFile = "ccb/Widget_SilverMineMap_Senior.ccbi"
 	local callbacks = {}
	QUIWidgetSilverMineSeniorMap.super.ctor(self, ccbFile, callbacks, options)

	self._index = 0
	self._caveWidth = 0

	-- local animation = nil
	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish1_1:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.1)
	-- animation:setSkeletonScaleY(0.1)
	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish1_2:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.1)
	-- animation:setSkeletonScaleY(0.1)
	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish1_3:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.1)
	-- animation:setSkeletonScaleY(0.1)

	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish2_1:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.1)
	-- animation:setSkeletonScaleY(0.1)
	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish2_2:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.1)
	-- animation:setSkeletonScaleY(0.1)
	-- animation = QSkeletonActor:create("moster_fish")
	-- self._ccbOwner.fish2_3:addChild(animation)
	-- animation:playAnimation("walk", true)
	-- animation:setSkeletonScaleX(0.1)
	-- animation:setSkeletonScaleY(0.1)

	-- self._animationDelayHandler = scheduler.performWithDelayGlobal(function()
	-- 	animation:setVisible(true)
	-- 	animation:playAnimation("animation", true)
	-- 	self._animationDelayHandler = nil
	-- end, 10.0)
end

function QUIWidgetSilverMineSeniorMap:onExit()
	-- if self._animationDelayHandler ~= nil then
	-- 	scheduler.unscheduleGlobal(self._animationDelayHandler)
	-- 	self._animationDelayHandler = nil
	-- end
end

function QUIWidgetSilverMineSeniorMap:getMaxWidth()
	local maxWidth = 0
	local index = 1
	while true do
		local node = self._ccbOwner["map"..index]
		if node then
			maxWidth = maxWidth + node:getContentSize().width * node:getScaleX()
			index = index + 1
		else
			break
		end
	end
	return maxWidth - 6
end

function QUIWidgetSilverMineSeniorMap:getOffsetWidth()
	local node = nil
	while true do
		node = self._ccbOwner["node_cave_"..self._index]
		if node then
			break
		else
			self._index = self._index - 1
			if self._index < 1 then break end
		end
	end

	local offsetX = 0
	local px = 0
	local w = 0

	if node then
		px = node:getPositionX()
		offsetX = self._ccbOwner.map1:getContentSize().width / 2
		w = self._caveWidth
	end
	return self:getMaxWidth() - (px + offsetX + w)
end

function QUIWidgetSilverMineSeniorMap:getCaveCount()
	local index = 1
	while true do
		local node = self._ccbOwner["node_cave_"..index]
		if node then
			index = index + 1
		else
			break
		end
	end
	return index - 1
end

function QUIWidgetSilverMineSeniorMap:myAddChild(widget, index)
	if not widget then return end
	self._index = index 
	self._caveWidth = widget:getWidth()

	local node = self._ccbOwner["node_cave_"..index]
	if node then
		node:addChild(widget)
	end
end
 
function QUIWidgetSilverMineSeniorMap:getCavePosByIndex(index)
	local node = self._ccbOwner["node_cave_"..index]
	if node then
		local cityPosX = self._ccbOwner.node_citys:getPositionX()
		return node:getPositionX()+cityPosX
	end
	return 0
end 

function QUIWidgetSilverMineSeniorMap:getNodeCitysPos()
	return self._ccbOwner.node_citys:getPositionX()
end

return QUIWidgetSilverMineSeniorMap
