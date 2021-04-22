local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderNormalMap = class("QUIWidgetPlunderNormalMap", QUIWidget)

function QUIWidgetPlunderNormalMap:ctor(options)
	local ccbFile = "ccb/Widget_plunderMap_normal.ccbi"
	local callbacks = {}
	QUIWidgetPlunderNormalMap.super.ctor(self, ccbFile, callbacks, options)

	self._index = 0
	self._caveWidth = 0

	-- warm up snow particles
	local snow_1 = self._ccbOwner.node_snow
	local warmup_count = 19
	while warmup_count > 0 do
		snow_1:update(0.125)
		warmup_count = warmup_count - 1
	end
end

function QUIWidgetPlunderNormalMap:getMaxWidth()
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
	return maxWidth - 3
end

function QUIWidgetPlunderNormalMap:getOffsetWidth()
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

function QUIWidgetPlunderNormalMap:getCaveCount()
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

function QUIWidgetPlunderNormalMap:myAddChild(widget, index)
	if not widget then return end
	self._index = index 
	self._caveWidth = widget:getWidth()

	local node = self._ccbOwner["node_cave_"..index]
	if node then
		node:addChild(widget)
	end
 end
 
return QUIWidgetPlunderNormalMap

