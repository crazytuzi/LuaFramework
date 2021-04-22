local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceWelfareMap = class("QUIWidgetInstanceWelfareMap", QUIWidget)

function QUIWidgetInstanceWelfareMap:ctor(options)
	local ccbFile = "ccb/Widget_InstanceMap_Welfare.ccbi"
	local callbacks = {}
	QUIWidgetInstanceWelfareMap.super.ctor(self, ccbFile, callbacks, options)
end

function QUIWidgetInstanceWelfareMap:getMaxWidth()
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

function QUIWidgetInstanceWelfareMap:getMapNode()
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

return QUIWidgetInstanceWelfareMap