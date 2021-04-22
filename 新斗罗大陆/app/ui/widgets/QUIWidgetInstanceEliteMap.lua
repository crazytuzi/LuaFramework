local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceEliteMap = class("QUIWidgetInstanceEliteMap", QUIWidget)

function QUIWidgetInstanceEliteMap:ctor(options)
	local ccbFile = "ccb/Widget_InstanceMap_Elite.ccbi"
	local callbacks = {}
	QUIWidgetInstanceEliteMap.super.ctor(self, ccbFile, callbacks, options)
end

function QUIWidgetInstanceEliteMap:getMaxWidth()
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
	return maxWidth
end

function QUIWidgetInstanceEliteMap:getMapNode()
	local mapNode = {}
	local index = 1
	while true do
		local node = self._ccbOwner["map"..index]
		if node then
			mapNode[index] = node
			index = index + 1
		else
			break
		end
	end
	return mapNode
end

-- function QUIWidgetInstanceEliteMap:getMaxWidth()
-- 	local maxWidth = 0
-- 	for i=1,4 do
-- 		maxWidth = maxWidth + self._ccbOwner["map"..i]:getContentSize().width * self._ccbOwner["map"..i]:getScaleX()
-- 	end
-- 	return maxWidth
-- end

-- function QUIWidgetInstanceEliteMap:getMapNode()
-- 	local mapNode = {}
-- 	for i=1,4 do
-- 		mapNode[i] = self._ccbOwner["map"..i]
-- 	end
-- 	return mapNode
-- end

return QUIWidgetInstanceEliteMap