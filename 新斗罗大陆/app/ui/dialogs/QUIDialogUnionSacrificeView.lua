-- @Author: xurui
-- @Date:   2016-11-12 10:27:57
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-29 14:32:53
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionSacrificeView = class("QUIDialogUnionSacrificeView", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetUnionSacrificeViewCell = import("..widgets.QUIWidgetUnionSacrificeViewCell")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogUnionSacrificeView:ctor(options)
	local ccbFile = "ccb/Dialog_society_union_jisixinxi.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogUnionSacrificeView.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._consortiaFighters = options.consortiaFighters or {}

	self:initScrollView()
end

function QUIDialogUnionSacrificeView:viewDidAppear()
	QUIDialogUnionSacrificeView.super.viewDidAppear(self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_INFO_UPDATE, self._updataInfo, self)

	self:setInfo()
end

function QUIDialogUnionSacrificeView:viewWillDisappear()
	QUIDialogUnionSacrificeView.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_INFO_UPDATE, self._updataInfo, self)
end

function QUIDialogUnionSacrificeView:_updataInfo()
    remote.union:getUnionSacrificeInfoRequest(function(data)
            if self:safeCheck() and data.consortiaFighters then
				self._consortiaFighters = data.consortiaFighters or {}
                self:setInfo()
            end
        end)
end

function QUIDialogUnionSacrificeView:initScrollView()
	local layerContentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, layerContentSize, {bufferMode = 2, senstiveDistance = 10})
	self._scrollView:setVerticalBounce(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._setScroViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._setScroViewMoveState))
end

function QUIDialogUnionSacrificeView:setInfo()
	self._scrollView:clear()

	local itemContentSize, buffer = self._scrollView:setCacheNumber(6, "widgets.QUIWidgetUnionSacrificeViewCell")
	for _, v in pairs(buffer) do
		v:addEventListener(QUIWidgetUnionSacrificeViewCell.EVENT_CLICK, handler(self, self._clickEvent))
	end

	local line = 0
	local lineDistance = 0
	local totalHeight = 0
	local offsetX = 0

	for i = 1, #self._consortiaFighters do
		local positionX = offsetX
		local positionY = (itemContentSize.height+lineDistance) * line

		self._scrollView:addItemBox(positionX, -positionY, {info = self._consortiaFighters[i]})
		line = line + 1
	end

	totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, itemContentSize.width)
end

function QUIDialogUnionSacrificeView:_clickEvent(event)
	if event.name == QUIWidgetUnionSacrificeViewCell.EVENT_CLICK then
		if self._isMoving then return end

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyUnionHeadpromptNew", options = {info = event.info}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogUnionSacrificeView:_setScroViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

function QUIDialogUnionSacrificeView:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionSacrificeView:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogUnionSacrificeView:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogUnionSacrificeView