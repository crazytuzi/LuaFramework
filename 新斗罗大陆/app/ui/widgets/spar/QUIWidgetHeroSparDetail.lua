-- @Author: xurui
-- @Date:   2017-04-06 11:51:33
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-22 16:15:38
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparDetail = class("QUIWidgetHeroSparDetail", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetHeroSparDetailClient = import("...widgets.spar.QUIWidgetHeroSparDetailClient")
local QScrollView = import("....views.QScrollView")
local QQuickWay = import("....utils.QQuickWay")
local QUIWidgetHeroSparDetailSuitClient = import(".QUIWidgetHeroSparDetailSuitClient")

function QUIWidgetHeroSparDetail:ctor(options)
	local ccbFile = "ccb/Widget_spar_info.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
		{ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
	}
	QUIWidgetHeroSparDetail.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetHeroSparDetail:onEnter()
end

function QUIWidgetHeroSparDetail:onExit()
end

function QUIWidgetHeroSparDetail:setScrollView()
	local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()

	if self._scrollView == nil then
		self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {sensitiveDistance = 10})
		self._scrollView:setVerticalBounce(true)

	    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
	    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
	end
end


function QUIWidgetHeroSparDetail:setInfo(actorId, sparId, index)
	self:setScrollView()

	self._actorId = actorId
	self._sparId = sparId
	self._sparInfo = remote.spar:getSparsBySparId(sparId)
	self._index = index

	if self._detailInfo == nil then
		self._detailInfo = QUIWidgetHeroSparDetailClient.new()
		self._scrollView:addItemBox(self._detailInfo)
	end
	self._detailInfo:setDetailInfo(self._actorId, self._sparId)
	local contentSize = self._detailInfo:getContentSize()
	self._detailInfo:setPosition(ccp(-20, 0))
	self._scrollView:setRect(0, -contentSize.height-20, 0, contentSize.width/2)
	
	self._scrollView:runToTop()

	local siutClient = self._detailInfo:getSuitClient()
	for _, value in pairs(siutClient) do
		value:addEventListener(QUIWidgetHeroSparDetailSuitClient.EVENT_CLICK_BOX, handler(self, self._onEvent))
		value:addEventListener(QUIWidgetHeroSparDetailSuitClient.EVENT_SKILL, handler(self, self._onEvent))
	end

	self:_checkRedTips()
end

function QUIWidgetHeroSparDetail:_onScrollViewMoving()
	self._isMoving = true
end

function QUIWidgetHeroSparDetail:_onScrollViewBegan()
	self._isMoving = false
end

function QUIWidgetHeroSparDetail:_onEvent(event)
	if self._isMoving then return end

	if event.name == QUIWidgetHeroSparDetailSuitClient.EVENT_CLICK_BOX then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemId, nil, nil, false)
	elseif event.name == QUIWidgetHeroSparDetailSuitClient.EVENT_SKILL then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparGradeSkillDetail",
	    	options = {suitInfo = event.suitInfo, minGrade = event.minGrade}})
	end
end

function QUIWidgetHeroSparDetail:_checkRedTips()
	local changeTip = remote.spar:checkSparIsBetter(self._sparId, self._index)
	self._ccbOwner.change_tip:setVisible(changeTip)
end

function QUIWidgetHeroSparDetail:_onTriggerWear(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_wear) == false then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparFastBag", 
        options = {actorId = self._actorId, pos = self._index, isChangeSparId = self._sparId}})
end

function QUIWidgetHeroSparDetail:_onTriggerUnwear(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_unwear) == false then return end
	remote.spar:requestSparEquipment(self._sparInfo.sparId, self._actorId, false, self._sparInfo.itemId, function()
		end)
end

return QUIWidgetHeroSparDetail