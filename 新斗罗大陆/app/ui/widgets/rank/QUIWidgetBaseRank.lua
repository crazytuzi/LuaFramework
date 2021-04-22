local QUIWidget = import("..QUIWidget")
local QUIWidgetBaseRank = class("QUIWidgetBaseRank", QUIWidget)

QUIWidgetBaseRank.BIG_SIZE = CCSize(700, 122)
QUIWidgetBaseRank.NORMAL_SIZE = CCSize(700, 122)

function QUIWidgetBaseRank:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_Base.ccbi"
	QUIWidgetBaseRank.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetBaseRank:setInfo(info)
	
end

function QUIWidgetBaseRank:setStyle(style)
	if self._style ~= nil then
		self._style:removeFromParent()
		self._style = nil
	end
	self._style = style
	self._ccbOwner.node_content:addChild(self._style)
end

function QUIWidgetBaseRank:getStyle()
	return self._style
end

function QUIWidgetBaseRank:setRank(rank)
	self._ccbOwner.sp_first:setVisible(rank == 1)
	self._ccbOwner.sp_second:setVisible(rank == 2)
	self._ccbOwner.sp_third:setVisible(rank == 3)
	self._ccbOwner.tf_other:setVisible(rank > 3)
	if rank > 3 then
		self._ccbOwner.tf_other:setString(rank)
	end
end

function QUIWidgetBaseRank:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end
return QUIWidgetBaseRank