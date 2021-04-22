local QUIWidgetBaseRank = import(".QUIWidgetBaseRank")
local QUIWidgetWideRank = class("QUIWidgetWideRank", QUIWidgetBaseRank)

function QUIWidgetWideRank:ctor(options)
	QUIWidgetWideRank.super.ctor(self, options)
end

function QUIWidgetWideRank:setInfo(info)
	self:setRank(info.rank)
end

function QUIWidgetWideRank:setStyle(style)
	if self._style ~= nil then
		self._style:removeFromParent()
		self._style = nil
	end
	self._style = style
	self._ccbOwner.node_content:addChild(self._style)
end

function QUIWidgetWideRank:getStyle()
	return self._style
end

return QUIWidgetWideRank