-- @Author: liaoxianbo
-- @Date:   2020-04-09 11:57:35
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-24 11:20:04
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerRankAwards = class("QUIDialogSoulTowerRankAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetWorldBossRankMyRank = import("..widgets.QUIWidgetWorldBossRankMyRank")

QUIDialogSoulTowerRankAwards.CURSERVER_AWARD = "CURSERVER_AWARD"
QUIDialogSoulTowerRankAwards.CURSERVER_RANK = "CURSERVER_RANK"
QUIDialogSoulTowerRankAwards.ALLSERVER_AWARD = "ALLSERVER_AWARD"
QUIDialogSoulTowerRankAwards.ALLSERVER_RANK = "ALLSERVER_RANK"
local TEST_Rank = 10
function QUIDialogSoulTowerRankAwards:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTower_RankAwards.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerCurserverAwards", callback = handler(self, self._onTriggerCurserverAwards)},
		{ccbCallbackName = "onTriggerCurserverRank", callback = handler(self, self._onTriggerCurserverRank)},
    }
    QUIDialogSoulTowerRankAwards.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._offsetX = 100     -- 长背景和短背景的差值
	self._tab = QUIDialogSoulTowerRankAwards.CURSERVER_AWARD 
	self._awrdsItem = {}
	self._condition = 10001

	if options and options.tab then
		self._tab = options.tab or self._tab
	end

	--点放大镜的时候拉本服数据缓存
	app:getClient():top50RankRequest("SOUL_TOWER_ENV_TOP_50", remote.user.userId, function (data)
		self._LocalData = clone(data.rankings)
		self._LocalMyInfo = data.rankings.myself
	end)
end

function QUIDialogSoulTowerRankAwards:viewDidAppear()
	QUIDialogSoulTowerRankAwards.super.viewDidAppear(self)
end

function QUIDialogSoulTowerRankAwards:viewAnimationInHandler()
	QUIDialogSoulTowerRankAwards.super.viewAnimationInHandler(self)
	self:initScrollView()
	if self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_RANK or self._tab == QUIDialogSoulTowerRankAwards.ALLSERVER_RANK then
	else
		self:selectTab()
	end
end

function QUIDialogSoulTowerRankAwards:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollViewLong = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollViewLong:setVerticalBounce(true)
	self._scrollViewLong:setGradient(true)
	self._scrollViewLong:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow_long, nil, nil)

	self._itemHeight = self._itemHeight - self._offsetX
	self._scrollViewShort = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollViewShort:setVerticalBounce(true)
	self._scrollViewShort:setGradient(true)
	self._scrollViewShort:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
end

function QUIDialogSoulTowerRankAwards:selectTab()
	self:getOptions().tab = self._tab

	self._ccbOwner.node_empty:setVisible(false)
	self:setButtonState()
	local isLongBg = true
	local titleFormat = ""

	if self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_AWARD then
		self._data = remote.soultower:getSoultowerRankAwards()
		self._scrollViewLong:clear()

		self._condition = self._LocalMyInfo and self._LocalMyInfo.rank or 0
		titleFormat = "本服个人通关第%s名奖励"
		self:filteAwards()

		self:setAwardsInfo(titleFormat,1)

	elseif self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_RANK then 
		isLongBg = false
		self._scrollViewShort:clear()
		if q.isEmpty(self._LocalData) then
			app:getClient():top50RankRequest("SOUL_TOWER_ENV_TOP_50", remote.user.userId, function (data)
				self._data = clone(data.rankings)
				self._LocalData = self._data
				self._LocalMyInfo = data.rankings.myself
				self:setRankInfo(1)
			end)
		else
			self._data = self._LocalData
			self:setRankInfo(1)
		end
	end

	self._scrollViewLong:setVisible(isLongBg)
	self._scrollViewShort:setVisible(not isLongBg)
	self._ccbOwner.long_bg:setVisible(isLongBg)
	self._ccbOwner.short_bg:setVisible(not isLongBg)
	self._ccbOwner.node_client:setVisible(not isLongBg)
end

function QUIDialogSoulTowerRankAwards:filteAwards()
	table.sort(self._data, function(a, b)
			if a.rank ~= b.rank then
				return a.rank < b.rank
			else
				return a.id < b.id
			end
		end)
	for i = 1, #self._data do
		self._data[i].isDone = false
	end
	for i = 1, #self._data do
		if self._condition and ( self._data[i-1] ~= nil and self._condition > self._data[i-1].rank and self._condition <= self._data[i].rank ) 
			or self._data[i].rank == self._condition then
			self._data[i].isDone = true
			break
		end
	end
end

-- awardsType 1:本服 2 全服
function QUIDialogSoulTowerRankAwards:setAwardsInfo(titleFormat,awardsType)
	local itemContentSize, buffer = self._scrollViewLong:setCacheNumber(10, "widgets.QUIWidgetSoulTowerRankAwardCell")
	for _, value in pairs(buffer) do
		table.insert(self._awrdsItem, value)
	end

	local row = 0
	local line = 0
	local lineDistance = 0
	local offsetY = 0
	for i = 1, #self._data do
		local positionX = 0
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY
		local str = self._data[i].rank

		if self._data[i].rank > 5 then
			str = (self._data[i-1].rank+1).."~"..self._data[i].rank
		end
		local titleString = string.format(titleFormat, str)
		local rankStr = self._condition == 0 and "无" or self._condition
		local rankString = string.format("我的排名：%s", rankStr)

		self._scrollViewLong:addItemBox(positionX, positionY, {awardInfo = self._data[i], awardsType = awardsType,isDone = self._data[i].isDone, titleString = titleString, rankString = rankString})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollViewLong:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogSoulTowerRankAwards:setRankInfo(awardsType)
	local itemContentSize, buffer = self._scrollViewShort:setCacheNumber(4, "widgets.QUIWidgetSoulTowerRankAwardClient")
	for _, value in pairs(buffer) do
		table.insert(self._awrdsItem, value)
	end

	local rankData = self._data.top50
	if rankData == nil or next(rankData) == nil then
		self._ccbOwner.node_empty:setVisible(true)
		if self._client ~= nil then
			self._client:removeFromParent()
			self._client = nil
		end
		return
	end
	table.sort( rankData, function(a, b)
			return a.rank < b.rank
		end )

	local row = 0
	local line = 0
	local lineDistance = 0
	local offsetY = 0
	for i = 1, #rankData do
		local positionX = 0
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY

		self._scrollViewShort:addItemBox(positionX, positionY, {info = rankData[i], awardsType = awardsType})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollViewShort:setRect(0, -totalHeight, 0, totalWidth)

	if self._client == nil then
		self._client = QUIWidgetWorldBossRankMyRank.new()
		self._ccbOwner.node_client:addChild(self._client)
	end
	self._client:setSoulTowerInfo(self._data.myself, awardsType)
end

function QUIDialogSoulTowerRankAwards:setButtonState()
	local curserverAward = self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_AWARD
	local curserverRank = self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_RANK

	self._ccbOwner.btn_curserver_award:setHighlighted(curserverAward)
	self._ccbOwner.btn_curserver_award:setEnabled(not curserverAward)

	self._ccbOwner.btn_curserver_rank:setHighlighted(curserverRank)
	self._ccbOwner.btn_curserver_rank:setEnabled(not curserverRank)

end

--------------------------- event click ----------------------------

function QUIDialogSoulTowerRankAwards:_onTriggerCurserverAwards()
	if self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_AWARD  then return end
	self._tab = QUIDialogSoulTowerRankAwards.CURSERVER_AWARD

	self:selectTab()
end

function QUIDialogSoulTowerRankAwards:_onTriggerCurserverRank()
	if self._tab == QUIDialogSoulTowerRankAwards.CURSERVER_RANK then return end
	self._tab = QUIDialogSoulTowerRankAwards.CURSERVER_RANK
	
	self:selectTab()
end

function QUIDialogSoulTowerRankAwards:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSoulTowerRankAwards:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
	self:playEffectOut()
end

function QUIDialogSoulTowerRankAwards:viewAnimationOutHandler()
	self:popSelf()
end

return QUIDialogSoulTowerRankAwards
