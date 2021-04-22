-- @Author: xurui
-- @Date:   2016-10-25 14:32:01
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-07 16:22:45
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBossRank = class("QUIDialogWorldBossRank", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetWorldBossRankMyRank = import("..widgets.QUIWidgetWorldBossRankMyRank")

QUIDialogWorldBossRank.PERSONAL_AWARD = "PERSONAL_AWARD"
QUIDialogWorldBossRank.PERSONAL_RANK = "PERSONAL_RANK"
QUIDialogWorldBossRank.UNION_AWARD = "UNION_AWARD"
QUIDialogWorldBossRank.UNION_RANK = "UNION_RANK"

function QUIDialogWorldBossRank:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_paihang.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerPersonalAwards", callback = handler(self, self._onTriggerPersonalAwards)},
		{ccbCallbackName = "onTriggerPersonalRank", callback = handler(self, self._onTriggerPersonalRank)},
		{ccbCallbackName = "onTriggerUnionAwards", callback = handler(self, self._onTriggerUnionAwards)},
		{ccbCallbackName = "onTriggerUnionRank", callback = handler(self, self._onTriggerUnionRank)},
	}
	QUIDialogWorldBossRank.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = false

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._offsetX = 100     -- 长背景和短背景的差值
	self._tab = QUIDialogWorldBossRank.PERSONAL_AWARD 
	self._awrdsItem = {}
	self._condition = 10001

	if options and options.tab then
		self._tab = options.tab or self._tab
	end
end

function QUIDialogWorldBossRank:viewDidAppear()
	QUIDialogWorldBossRank.super.viewDidAppear(self)
end

function QUIDialogWorldBossRank:viewAnimationInHandler()
	QUIDialogWorldBossRank.super.viewAnimationInHandler(self)
	self:initScrollView()
	if self._tab == QUIDialogWorldBossRank.PERSONAL_RANK or self._tab == QUIDialogWorldBossRank.UNION_RANK then
		remote.worldBoss:requestWorldBossRank("WORLD_BOSS_CONSORTIA_HURT", remote.user.userId, function(data)
				remote.worldBoss:updateWorldBossParam({unionRank = data.consortiaRankings.myself.rank})
				self:selectTab()
			end)
	else
		self:selectTab()
	end
end

function QUIDialogWorldBossRank:initScrollView()
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

function QUIDialogWorldBossRank:selectTab()
	self:getOptions().tab = self._tab

	self._ccbOwner.empty:setVisible(false)
	self:setButtonState()
	local isLongBg = true
	local titleFormat = ""
	local worldBossInfo = remote.worldBoss:getWorldBossInfo()

	if self._tab == QUIDialogWorldBossRank.PERSONAL_AWARD then
		self._data = QStaticDatabase:sharedDatabase():getIntrusionRankAwardByLevel(2, remote.user.level)
		self._scrollViewLong:clear()

		self._condition = worldBossInfo.hurtRank or 0
		titleFormat = "个人荣誉第%s名奖励"
		self:filteAwards()

		self:setAwardsInfo(titleFormat)

	elseif self._tab == QUIDialogWorldBossRank.PERSONAL_RANK then 
		isLongBg = false
		self._scrollViewShort:clear()

		self._data = remote.worldBoss:getRankInfoByType("WORLD_BOSS_USER_HURT")
		if next(self._data) == nil or remote.worldBoss:checkWorldBossIsUnlock() == true then
			self:getRankInfo("WORLD_BOSS_USER_HURT", 2)
		else
			self:setRankInfo(2)
		end

	elseif self._tab == QUIDialogWorldBossRank.UNION_AWARD then 
		self._data = QStaticDatabase:sharedDatabase():getIntrusionRankAwardByLevel(3, remote.user.level)
		self._scrollViewLong:clear()

		self._condition = worldBossInfo.consortiaHurtRank or 0
		titleFormat = "宗门总荣誉第%s名奖励"
		self:filteAwards()

		self:setAwardsInfo(titleFormat)

	elseif self._tab == QUIDialogWorldBossRank.UNION_RANK then 
		isLongBg = false
		self._scrollViewShort:clear()

		self._data = remote.worldBoss:getRankInfoByType("WORLD_BOSS_CONSORTIA_HURT")
		if next(self._data) == nil or remote.worldBoss:checkWorldBossIsUnlock() == true then
			self:getRankInfo("WORLD_BOSS_CONSORTIA_HURT", 3)
		else
			self:setRankInfo(3)
		end

	end

	self._scrollViewLong:setVisible(isLongBg)
	self._scrollViewShort:setVisible(not isLongBg)
	self._ccbOwner.long_bg:setVisible(isLongBg)
	self._ccbOwner.short_bg:setVisible(not isLongBg)
	self._ccbOwner.node_client:setVisible(not isLongBg)

	-- local positionY = -193
	-- if isLongBg then positionY = -312 end
	-- self._ccbOwner.bottom_shadow:setPositionY(positionY)
end

function QUIDialogWorldBossRank:filteAwards()
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

function QUIDialogWorldBossRank:setAwardsInfo(titleFormat)
	local itemContentSize, buffer = self._scrollViewLong:setCacheNumber(4, "widgets.QUIWidgetWorldBossRankAwardClient")
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
		if self._data[i].rank > 3 then
			str = (self._data[i-1].rank+1).."~"..self._data[i].rank
		end
		local titleString = string.format(titleFormat, str)
		local rankStr = self._condition == 0 and "无" or self._condition
		local rankString = string.format("我的排名：%s", rankStr)

		self._scrollViewLong:addItemBox(positionX, positionY, {awardInfo = self._data[i], isDone = self._data[i].isDone, titleString = titleString, rankString = rankString})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollViewLong:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogWorldBossRank:setRankInfo(awardsType)
	local itemContentSize, buffer = self._scrollViewShort:setCacheNumber(4, "widgets.QUIWidgetWorldBossRankClient")
	for _, value in pairs(buffer) do
		table.insert(self._awrdsItem, value)
	end

	local rankData = self._data.top50
	if rankData == nil or next(rankData) == nil then
		self._ccbOwner.empty:setVisible(true)
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
	self._client:setInfo(self._data.myself, awardsType)
end

function QUIDialogWorldBossRank:setButtonState()
	local personalAward = self._tab == QUIDialogWorldBossRank.PERSONAL_AWARD
	local personalRank = self._tab == QUIDialogWorldBossRank.PERSONAL_RANK
	local unionAward = self._tab == QUIDialogWorldBossRank.UNION_AWARD
	local unionRank = self._tab == QUIDialogWorldBossRank.UNION_RANK

	self._ccbOwner.btn_personal_award:setHighlighted(personalAward)
	self._ccbOwner.btn_personal_award:setEnabled(not personalAward)

	self._ccbOwner.btn_personal_rank:setHighlighted(personalRank)
	self._ccbOwner.btn_personal_rank:setEnabled(not personalRank)

	self._ccbOwner.btn_union_award:setHighlighted(unionAward)
	self._ccbOwner.btn_union_award:setEnabled(not unionAward)

	self._ccbOwner.btn_union_rank:setHighlighted(unionRank)
	self._ccbOwner.btn_union_rank:setEnabled(not unionRank)
end

function QUIDialogWorldBossRank:getRankInfo(kind, awardsType)
	remote.worldBoss:requestWorldBossRank(kind, remote.user.userId, function(data)
			if kind == "WORLD_BOSS_USER_HURT" then
				self._data = data.rankings
			elseif kind == "WORLD_BOSS_CONSORTIA_HURT"  then
				self._data = data.consortiaRankings
			end
			self:setRankInfo(awardsType)
		end)
end

--------------------------- event click ----------------------------

function QUIDialogWorldBossRank:_onTriggerPersonalAwards()
	if self._tab == QUIDialogWorldBossRank.PERSONAL_AWARD then return end
	self._tab = QUIDialogWorldBossRank.PERSONAL_AWARD

	self:selectTab()
end

function QUIDialogWorldBossRank:_onTriggerPersonalRank()
	if self._tab == QUIDialogWorldBossRank.PERSONAL_RANK then return end
	self._tab = QUIDialogWorldBossRank.PERSONAL_RANK
	
	self:selectTab()
end

function QUIDialogWorldBossRank:_onTriggerUnionAwards()
	if self._tab == QUIDialogWorldBossRank.UNION_AWARD then return end
	self._tab = QUIDialogWorldBossRank.UNION_AWARD
	
	self:selectTab()
end

function QUIDialogWorldBossRank:_onTriggerUnionRank()
	if self._tab == QUIDialogWorldBossRank.UNION_RANK then return end
	self._tab = QUIDialogWorldBossRank.UNION_RANK
	
	self:selectTab()
end

function QUIDialogWorldBossRank:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogWorldBossRank:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
	self:playEffectOut()
end

function QUIDialogWorldBossRank:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogWorldBossRank