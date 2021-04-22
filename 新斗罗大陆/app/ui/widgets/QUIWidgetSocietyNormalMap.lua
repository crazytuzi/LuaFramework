local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyNormalMap = class("QUIWidgetSocietyNormalMap", QUIWidget)

function QUIWidgetSocietyNormalMap:ctor(options)
	local ccbFile = "ccb/Widget_SocietyMap_Normal.ccbi"
	local callbacks = {}
	QUIWidgetSocietyNormalMap.super.ctor(self, ccbFile, callbacks, options)
end

function QUIWidgetSocietyNormalMap:getMaxWidth()
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

function QUIWidgetSocietyNormalMap:getMapNode()
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

return QUIWidgetSocietyNormalMap