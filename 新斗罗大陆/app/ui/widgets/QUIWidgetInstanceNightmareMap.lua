local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceNightmareMap = class("QUIWidgetInstanceNightmareMap", QUIWidget)

function QUIWidgetInstanceNightmareMap:ctor(options)
	local ccbFile = "ccb/Widget_InstanceMap_EM.ccbi"
	local callbacks = {}
	QUIWidgetInstanceNightmareMap.super.ctor(self, ccbFile, callbacks, options)

	local animation = nil
	animation = QSkeletonActor:create("tujiu_03_yasuo")
	self._ccbOwner.vulture:addChild(animation)
	animation:playAnimation("feixin", true)

	animation = QSkeletonActor:create("tujiu_03_yasuo")
	self._ccbOwner.vulture2:addChild(animation)
	animation:playAnimation("feixin", true)

	animation = QSkeletonActor:create("moster_fish")
	self._ccbOwner.fish:addChild(animation)
	animation:playAnimation("walk", true)
	animation:setSkeletonScaleX(0.4)
	animation:setSkeletonScaleY(0.4)

	animation = QSkeletonActor:create("blc")
	self._ccbOwner.boat1:addChild(animation)
	animation:playAnimation("animation", true)
	animation:setSkeletonScaleX(0.9)
	animation:setSkeletonScaleY(0.9)
	animation:setAnimationScale(0.333)

	animation = QSkeletonActor:create("lmc")
	self._ccbOwner.boat2:addChild(animation)
	animation:setSkeletonScaleX(0.9)
	animation:setSkeletonScaleY(0.9)
	animation:setAnimationScale(0.333)
	animation:setVisible(false)
	self._animationDelayHandler = scheduler.performWithDelayGlobal(function()
		animation:setVisible(true)
		animation:playAnimation("animation", true)
		self._animationDelayHandler = nil
	end, 10.0)
end

function QUIWidgetInstanceNightmareMap:addBuild(buildWidget)
	self._ccbOwner.node_build:addChild(buildWidget)
end

function QUIWidgetInstanceNightmareMap:onExit()
	QUIWidgetInstanceNightmareMap.super.onExit(self)
	if self._animationDelayHandler ~= nil then
		scheduler.unscheduleGlobal(self._animationDelayHandler)
		self._animationDelayHandler = nil
	end
end

function QUIWidgetInstanceNightmareMap:getMaxWidth()
	local maxWidth = 0
	for i=1,4 do
		maxWidth = maxWidth + self._ccbOwner["map"..i]:getContentSize().width * self._ccbOwner["map"..i]:getScaleX()
	end
	return maxWidth
end

function QUIWidgetInstanceNightmareMap:getMapNode()
	local mapNode = {}
	for i=1,4 do
		mapNode[i] = self._ccbOwner["map"..i]
	end
	return mapNode
end

return QUIWidgetInstanceNightmareMap