-- @Author: xurui
-- @Date:   2016-12-16 17:42:25
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-29 14:39:22
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderRank = class("QUIDialogPlunderRank", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetPlunderRankAwardsClient = import("..widgets.QUIWidgetPlunderRankAwardsClient")
local QUIWidgetPlunderRankClient = import("..widgets.QUIWidgetPlunderRankClient")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIDialogPlunderRank.PERSONAL_AWARD = "PERSONAL_AWARD"
QUIDialogPlunderRank.PERSONAL_RANK = "PERSONAL_RANK"
QUIDialogPlunderRank.UNION_AWARD = "UNION_AWARD"
QUIDialogPlunderRank.UNION_RANK = "UNION_RANK"

function QUIDialogPlunderRank:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_ranksingle.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerPersonalAwards", callback = handler(self, self._onTriggerPersonalAwards)},
		{ccbCallbackName = "onTriggerPersonalRank", callback = handler(self, self._onTriggerPersonalRank)},
		{ccbCallbackName = "onTriggerUnionAwards", callback = handler(self, self._onTriggerUnionAwards)},
		{ccbCallbackName = "onTriggerUnionRank", callback = handler(self, self._onTriggerUnionRank)},
	}
	QUIDialogPlunderRank.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._langBgH = 435
	self._shortBgH = 335
	self._tab = QUIDialogPlunderRank.UNION_RANK 
	self._awrdsItem = {}
	self._condition = 10001

	if options and options.tab then
		self._tab = options.tab or self._tab
	end

	self:initScrollView()
end

function QUIDialogPlunderRank:viewDidAppear()
	QUIDialogPlunderRank.super.viewDidAppear(self)

	self:selectTab()
end

function QUIDialogPlunderRank:viewWillDisappear()
	QUIDialogPlunderRank.super.viewWillDisappear(self)
end

function QUIDialogPlunderRank:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._langBgH - 2

	self._scrollViewLong = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollViewLong:setVerticalBounce(true)

	self._itemHeight = self._shortBgH - 2
	self._scrollViewShort = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollViewShort:setVerticalBounce(true)
end

function QUIDialogPlunderRank:selectTab()
	self:getOptions().tab = self._tab

	self._ccbOwner.node_no:setVisible(false)
	self:setButtonState()
	local isLongBg = true
	local titleFormat = ""

	if self._tab == QUIDialogPlunderRank.PERSONAL_AWARD then
		self._data = QStaticDatabase:sharedDatabase():getPlunderRankReward(1, remote.user.level)
		self._scrollViewLong:clear()

		self._condition = remote.plunder:getMyRank()
		titleFormat = "个人冰髓总量第%s名"
		self:filteAwards()

		self:setAwardsInfo(titleFormat)

	elseif self._tab == QUIDialogPlunderRank.PERSONAL_RANK then 
		isLongBg = false
		self._scrollViewShort:clear()

		self:getRankInfo("KUAFUMINE_PERSON_REALTIME_TOP_50", 1)

	elseif self._tab == QUIDialogPlunderRank.UNION_AWARD then 
		self._data = QStaticDatabase:sharedDatabase():getPlunderRankReward(2, remote.user.level)
		self._scrollViewLong:clear()

		self._condition = remote.plunder:getConsortiaRank()
		titleFormat = "宗门冰髓总量第%s名"
		self:filteAwards()

		self:setAwardsInfo(titleFormat)

	elseif self._tab == QUIDialogPlunderRank.UNION_RANK then 
		isLongBg = false
		self._scrollViewShort:clear()

		self:getRankInfo("KUAFUMINE_CONSORTIA_REALTIME_TOP_50", 2)
	end

	local bgW, bgH
	if isLongBg then
		bgW = self._ccbOwner.sheet_layout:getContentSize().width
		bgH = self._langBgH
	else
		bgW = self._ccbOwner.sheet_layout:getContentSize().width
		bgH = self._shortBgH
	end

	self._ccbOwner.s9s_bg:setPreferredSize(CCSize(bgW, bgH))
	self._scrollViewLong:setVisible(isLongBg)
	self._scrollViewShort:setVisible(not isLongBg)
	self._ccbOwner.node_client:setVisible(not isLongBg)
end

function QUIDialogPlunderRank:filteAwards()
	table.sort(self._data, function(a, b) return a.id < b.id end)

	for i = 1, #self._data do
		self._data[i].isDone = false
	end
	for i = 1, #self._data do
		if self._condition and self._condition >= self._data[i].rank_min and self._condition <= self._data[i].rank_max then
			self._data[i].isDone = true
			break
		end
	end
end

function QUIDialogPlunderRank:setAwardsInfo(titleFormat)
	local itemContentSize, buffer = self._scrollViewLong:setCacheNumber(4, "widgets.QUIWidgetPlunderRankAwardsClient")
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

		local str = self._data[i].rank_max
		if self._data[i].rank_max ~= self._data[i].rank_min then
			str = self._data[i].rank_min.."~"..self._data[i].rank_max
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

function QUIDialogPlunderRank:setRankInfo(awardsType)
	local itemContentSize, buffer = self._scrollViewShort:setCacheNumber(6, "widgets.QUIWidgetPlunderRankClient")
	for _, value in pairs(buffer) do
		table.insert(self._awrdsItem, value)
	end

	local rankData = self._data.top50
	if rankData == nil or next(rankData) == nil then
		self._ccbOwner.node_no:setVisible(true)
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

	self:setClientInfo(self._data.myself, awardsType)
end

function QUIDialogPlunderRank:setClientInfo(info, awardsType)
	if not info  then
		info = {}
		info.rank = 0
	end
	info.name = info.name or remote.user.nickname
	info.level = info.level or remote.user.level
	info.rank = info.rank or 0

	--self._ccbOwner.serverName:setVisible(false)

	if info.rank > 0 then
		self._ccbOwner.myRank:setVisible(true)
		self._ccbOwner.myRank:setString(info.rank )
		self._ccbOwner.tf_no_rank:setVisible(false)
	else
		self._ccbOwner.myRank:setVisible(false )
		self._ccbOwner.tf_no_rank:setVisible(true)
	end

	self._ccbOwner.tf_name:setString(info.name)
	self._ccbOwner.tf_level:setString(string.format("LV.%d",info.level))
	-- if info.vip then
	-- 	self._ccbOwner.tf_vip:setVisible(true)
	-- 	self._ccbOwner.tf_vip:setString("VIP "..info.vip)
	-- else
	-- 	self._ccbOwner.tf_vip:setVisible(false)
	-- end

	local score = info.today_socre or 0
	if awardsType == 2 then
		score = info.mineScore or 0
	end
	local num, str = q.convertLargerNumber(score)
	self._ccbOwner.tf_num:setString(num..(str or ""))

	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = info.avatar
	if info.avatar then
		self._avatar = QUIWidgetAvatar.new()
		self._avatar:setSilvesArenaPeak(info.championCount)
	elseif info.icon then
		self._avatar = QUnionAvatar.new()
		avatar = info.icon
	end
	if self._avatar then
		self._avatar:setInfo(avatar)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	end

	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.node_badge:setVisible(true)
		self._ccbOwner.node_badge:addChild(CCSprite:create(config.alphaicon))
	else
		self._ccbOwner.node_badge:setVisible(false)
	end

	local awards = self:getAwardsRank(info.rank, awardsType)
	local items = string.split(awards, ";")
	for i = 1, 4 do
		self._ccbOwner["item"..i]:removeAllChildren()
		if items[i] ~= nil and awards then
			items[i] = string.split(items[i], "^")
			self._ccbOwner["item"..i]:setVisible(true)
			self._ccbOwner["count"..i]:setVisible(true)

			local itemBox = QUIWidgetItemsBox.new()
			self._ccbOwner["item"..i]:addChild(itemBox)

			local itemType = ITEM_TYPE.ITEM
			if tonumber(items[i][1]) == nil then
				itemType = items[i][1]
			end
			itemBox:setGoodsInfo(tonumber(items[i][1]), itemType)
			self._ccbOwner["count"..i]:setString("x"..tonumber(items[i][2]))
		else
			self._ccbOwner["item"..i]:setVisible(false)
			self._ccbOwner["count"..i]:setVisible(false)
		end
	end
end

function QUIDialogPlunderRank:getAwardsRank(rank, awardsType)
	if rank == nil then return nil end
	local data = QStaticDatabase:sharedDatabase():getPlunderRankReward(awardsType, remote.user.level)
	table.sort( data, function(a, b) return a.id < b.id end )

	for i = 1, #data do
		if rank >= data[i].rank_min and rank <= data[i].rank_max then
			return data[i].reward
		end
	end
	return nil
end

function QUIDialogPlunderRank:setButtonState()
	local personalAward = self._tab == QUIDialogPlunderRank.PERSONAL_AWARD
	local personalRank = self._tab == QUIDialogPlunderRank.PERSONAL_RANK
	local unionAward = self._tab == QUIDialogPlunderRank.UNION_AWARD
	local unionRank = self._tab == QUIDialogPlunderRank.UNION_RANK

	self._ccbOwner.btn_personal_award:setHighlighted(personalAward)
	self._ccbOwner.btn_personal_award:setEnabled(not personalAward)
	self._ccbOwner.tf_personal_award:setColor(personalAward and COLORS.S or COLORS.T)

	self._ccbOwner.btn_personal_rank:setHighlighted(personalRank)
	self._ccbOwner.btn_personal_rank:setEnabled(not personalRank)
	self._ccbOwner.tf_personal_rank:setColor(personalRank and COLORS.S or COLORS.T)

	self._ccbOwner.btn_union_award:setHighlighted(unionAward)
	self._ccbOwner.btn_union_award:setEnabled(not unionAward)
	self._ccbOwner.tf_union_award:setColor(unionAward and COLORS.S or COLORS.T)

	self._ccbOwner.btn_union_rank:setHighlighted(unionRank)
	self._ccbOwner.btn_union_rank:setEnabled(not unionRank)
	self._ccbOwner.tf_union_rank:setColor(unionRank and COLORS.S or COLORS.T)
end

function QUIDialogPlunderRank:getRankInfo(kind, awardsType)
	remote.worldBoss:requestWorldBossRank(kind, remote.user.userId, function(data)
			if kind == "KUAFUMINE_PERSON_REALTIME_TOP_50" then
				self._data = data.rankings
			elseif kind == "KUAFUMINE_CONSORTIA_REALTIME_TOP_50"  then
				self._data = data.consortiaRankings
			end
			self:setRankInfo(awardsType)
		end)
end

--------------------------- event click ----------------------------

function QUIDialogPlunderRank:_onTriggerPersonalAwards()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderRank.PERSONAL_AWARD then return end
	self._tab = QUIDialogPlunderRank.PERSONAL_AWARD

	self:selectTab()
end

function QUIDialogPlunderRank:_onTriggerPersonalRank()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderRank.PERSONAL_RANK then return end
	self._tab = QUIDialogPlunderRank.PERSONAL_RANK
	
	self:selectTab()
end

function QUIDialogPlunderRank:_onTriggerUnionAwards()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderRank.UNION_AWARD then return end
	self._tab = QUIDialogPlunderRank.UNION_AWARD
	
	self:selectTab()
end

function QUIDialogPlunderRank:_onTriggerUnionRank()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderRank.UNION_RANK then return end
	self._tab = QUIDialogPlunderRank.UNION_RANK
	
	self:selectTab()
end

function QUIDialogPlunderRank:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPlunderRank:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPlunderRank:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogPlunderRank