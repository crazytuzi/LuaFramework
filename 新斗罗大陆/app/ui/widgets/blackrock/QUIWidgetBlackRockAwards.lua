local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockAwards = class("QUIWidgetBlackRockAwards", QUIWidget)

function QUIWidgetBlackRockAwards:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_sanxing.ccbi"
	QUIWidgetBlackRockAwards.super.ctor(self, ccbFile, callBacks, options)

	-- self._ccbOwner.tf_level:setVisible(false)
	-- self._ccbOwner.tf_name:setVisible(false)
	-- self._ccbOwner.tf_force:setVisible(false)
	-- self._ccbOwner.tf_server:setVisible(false)
	-- self._ccbOwner.tf_team:setVisible(false)
end

function QUIWidgetBlackRockAwards:setInfo(info)
	self._info = info
	-- self._ccbOwner.tf_name:setString(self._info)
	-- self._ccbOwner.tf_name:setVisible(true)
end

function QUIWidgetBlackRockAwards:getContentSize()
	return self._ccbOwner.done_banner:getContentSize()
end

return QUIWidgetBlackRockAwards