-- @Author: xurui
-- @Date:   2016-11-08 19:00:00
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-29 14:32:51
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActiveRankClient = class("QUIWidgetActiveRankClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetActiveRankClient:ctor(options)
	local ccbFile = "ccb/Widget_society_huoyuepaihang.ccbi"
	local callBack = {
		{ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetActiveRankClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:resetAll()
end

function QUIWidgetActiveRankClient:onEnter()
	self:initScrollView()
end

function QUIWidgetActiveRankClient:onExit()
end

function QUIWidgetActiveRankClient:resetAll()
	self._ccbOwner.tf_none:setVisible(false)
	self._ccbOwner.myRank:setVisible(false )
	self._ccbOwner.tf_none:setVisible(false)
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_level:setString("")
	self._ccbOwner.tf_vip:setVisible(false)
	self._ccbOwner.value1:setString("")
	self._ccbOwner.value2:setString("")
end

function QUIWidgetActiveRankClient:initScrollView()
	local sheetSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, sheetSize, {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)

	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._scrollViewMoveState))
	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._scrollViewMoveState))
end

function QUIWidgetActiveRankClient:setInfo()
	remote.union.unionActive:requestUnionActiveRank("CONSORTIA_ACTIVENESS_INFO", remote.user.userId, function(data)
			self:setClientInfo(data.rankings.top50)
			self:setMyRankInfo(data.rankings.myself)
		end)
end

function QUIWidgetActiveRankClient:setClientInfo(data)
	self._scrollView:clear()

	local itemContentSize, buffer = self._scrollView:setCacheNumber(5, "..widgets.QUIWidgetUnionActiveRankClientCell")

	local line = 0
	local lineDistance = 5
	local totalHeight = 0 
	local offsetX = 0
	for _, info in pairs(data) do
		local positionX = offsetX
		local positionY = line * (itemContentSize.height+lineDistance)
		self._scrollView:addItemBox(positionX, -positionY, {info = info})

		line = line + 1
	end
	totalHeight = line * (itemContentSize.height+lineDistance)
	self._scrollView:setRect(0, -totalHeight, 0, itemContentSize.width)
end

function QUIWidgetActiveRankClient:setMyRankInfo(info)
	info.name = info.name or remote.user.nickname
	info.level = info.level or remote.user.level
	info.rank = info.rank or 0

	if info.rank > 0 then
		self._ccbOwner.myRank:setVisible(true)
		self._ccbOwner.myRank:setString(info.rank )
		self._ccbOwner.tf_none:setVisible(false)
	else
		self._ccbOwner.myRank:setVisible(false )
		self._ccbOwner.tf_none:setVisible(true)
	end

	self._ccbOwner.tf_name:setString(info.name)
	self._ccbOwner.tf_level:setString(string.format("LV.%d",info.level))
	if info.vip then
		self._ccbOwner.tf_vip:setVisible(true)
		self._ccbOwner.tf_vip:setString("VIP "..info.vip)
	else
		self._ccbOwner.tf_vip:setVisible(false)
	end

	self._ccbOwner.value1:setString(info.consortiaDailyActiveness or 0)
	self._ccbOwner.value2:setString(info.consortiaWeekActiveness or 0)

	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = info.avatar
	if self._avatar == nil then
		self._avatar = QUIWidgetAvatar.new()
	    self._ccbOwner.node_head:addChild(self._avatar)
	end
	self._avatar:setInfo(avatar)
	self._avatar:setSilvesArenaPeak(info.championCount)

	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(info.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.node_badge:setVisible(true)
		self._ccbOwner.node_badge:addChild(CCSprite:create(config.alphaicon))
		self._ccbOwner.tf_name:setPositionX(-35)
	else
		self._ccbOwner.node_badge:setVisible(false)
		self._ccbOwner.tf_name:setPositionX(-65)
	end
end

function QUIWidgetActiveRankClient:_scrollViewMoveState(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self._isMoving = false
	end
end

return QUIWidgetActiveRankClient