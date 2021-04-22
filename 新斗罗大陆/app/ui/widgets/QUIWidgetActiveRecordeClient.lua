-- @Author: xurui
-- @Date:   2016-11-10 11:27:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-29 14:32:50
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActiveRecordeClient = class("QUIWidgetActiveRecordeClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 

function QUIWidgetActiveRecordeClient:ctor(options)
	local ccbFile = "ccb/Widget_society_choujiangjilu.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetActiveRecordeClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActiveRecordeClient:onEnter()
	self:initScrollView()
end

function QUIWidgetActiveRecordeClient:onExit()
end

function QUIWidgetActiveRecordeClient:setInfo()
	remote.union.unionActive:requestUnionActiveChestRecorde(function(data)
			if data.consortiaGetDrawLogResponse.drawLogs then
				self:setClientInfo(data.consortiaGetDrawLogResponse.drawLogs)
			end
		end)
end

function QUIWidgetActiveRecordeClient:initScrollView()
	local sheetSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._scrollViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._scrollViewMoveState))
end

function QUIWidgetActiveRecordeClient:setClientInfo(logInfo)
	self._scrollView:clear()

	local tasks = {}
	
	local itemContentSize, buffer = self._scrollView:setCacheNumber(10, "..widgets.QUIWidgetActiveRecordeClientCell")

	local line = 0
	local lineDistance = 10
	local totalHeight = 0 
	local offsetX = 5
	for _, log in pairs(logInfo) do
		local positionX = offsetX
		local positionY = line * (itemContentSize.height+lineDistance)
		self._scrollView:addItemBox(positionX, -positionY, {log = log})

		line = line + 1
	end
	totalHeight = line * itemContentSize.height
	self._scrollView:setRect(0, -totalHeight, 0, itemContentSize.width)
end

function QUIWidgetActiveRecordeClient:_scrollViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

return QUIWidgetActiveRecordeClient