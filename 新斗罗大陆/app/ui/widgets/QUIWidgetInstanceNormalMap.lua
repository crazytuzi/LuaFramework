local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceNormalMap = class("QUIWidgetInstanceNormalMap", QUIWidget)

function QUIWidgetInstanceNormalMap:ctor(options)
	local ccbFile = "ccb/Widget_InstanceMap_Normal.ccbi"
	local callbacks = {}
	QUIWidgetInstanceNormalMap.super.ctor(self, ccbFile, callbacks, options)
end

function QUIWidgetInstanceNormalMap:getMaxWidth()
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

function QUIWidgetInstanceNormalMap:getMapNode()
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

return QUIWidgetInstanceNormalMap