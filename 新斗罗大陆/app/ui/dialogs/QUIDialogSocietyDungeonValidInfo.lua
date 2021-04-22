--
-- Kumo.Wang
-- 宗门副本有效伤害排行榜
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSocietyDungeonValidInfo = class("QUIDialogSocietyDungeonValidInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetSocietyDungeonValidInfo = import("..widgets.QUIWidgetSocietyDungeonValidInfo")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogSocietyDungeonValidInfo:ctor(options)
	local ccbFile = "ccb/Dialog_society_fuben_valid_info.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSocietyDungeonValidInfo.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._list = {}


	self:initScrollView()
end

function QUIDialogSocietyDungeonValidInfo:viewDidAppear()
	QUIDialogSocietyDungeonValidInfo.super.viewDidAppear(self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_INFO_UPDATE, self._updataInfo, self)

	self:_updataInfo()
end

function QUIDialogSocietyDungeonValidInfo:viewWillDisappear()
	QUIDialogSocietyDungeonValidInfo.super.viewWillDisappear(self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_INFO_UPDATE, self._updataInfo, self)
end

function QUIDialogSocietyDungeonValidInfo:_updataInfo()
	app:getClient():top50RankRequest("CONSORTIA_BOSS_VALID_DAMAGE_MEMBER_INFO", remote.user.userId, function (data)
		if self:safeCheck() then
			if data.rankings == nil then 
				return 
			end

			self._list = clone(data.rankings.top50) or {}

			table.sort(self._list, function (x, y)
				return x.rank < y.rank
			end)

			self:setInfo()
		end
	end, nil)
end

function QUIDialogSocietyDungeonValidInfo:initScrollView()
	local layerContentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, layerContentSize, {bufferMode = 2, senstiveDistance = 10})
	self._scrollView:setVerticalBounce(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._setScroViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._setScroViewMoveState))
end

function QUIDialogSocietyDungeonValidInfo:setInfo()
	self._scrollView:clear()

	local itemContentSize, buffer = self._scrollView:setCacheNumber(6, "widgets.QUIWidgetSocietyDungeonValidInfo")
	for _, v in pairs(buffer) do
		v:addEventListener(QUIWidgetSocietyDungeonValidInfo.EVENT_CLICK, handler(self, self._clickEvent))
	end

	local line = 0
	local lineDistance = 0
	local totalHeight = 0
	local offsetX = 0

	for i = 1, #self._list do
		local positionX = offsetX
		local positionY = (itemContentSize.height+lineDistance) * line

		self._scrollView:addItemBox(positionX, -positionY, {info = self._list[i]})
		line = line + 1
	end

	totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, itemContentSize.width)
end

function QUIDialogSocietyDungeonValidInfo:_clickEvent(event)
	if event.name == QUIWidgetSocietyDungeonValidInfo.EVENT_CLICK then
		if self._isMoving then return end
		QKumo(event.info)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyUnionHeadpromptNew", options = {info = event.info}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogSocietyDungeonValidInfo:_setScroViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

function QUIDialogSocietyDungeonValidInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSocietyDungeonValidInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSocietyDungeonValidInfo:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogSocietyDungeonValidInfo