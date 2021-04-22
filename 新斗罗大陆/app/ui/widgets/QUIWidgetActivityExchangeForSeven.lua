-- @Author: xurui
-- @Date:   2018-06-06 16:16:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-07 19:56:27
local QUIWidgetActivityExchange = import("..widgets.QUIWidgetActivityExchange")
local QUIWidgetActivityExchangeForSeven = class("QUIWidgetActivityExchangeForSeven", QUIWidgetActivityExchange)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetActivityExchangeForSeven:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity_exchange.ccbi"
	if options == nil then
		options = {}
	end
	options.ccbFile = ccbFile

    QUIWidgetActivityExchangeForSeven.super.ctor(self, options)
    -- self._ccbOwner.node_right:setPositionX(-195)
    -- self._ccbOwner.node_bg:setScaleX(0.78)
end

function QUIWidgetActivityExchangeForSeven:setPreviewStated(stated)
	if stated then
		self._ccbOwner.btnName:setString("明日开启")
	end
	self._ccbOwner.btnExchange:setEnabled(not stated)
	self._ccbOwner.timesLabel:setVisible(not stated)
end

return QUIWidgetActivityExchangeForSeven

