-- @Author: xurui
-- @Date:   2016-11-24 10:29:48
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-16 18:44:20
local QBaseRank = import(".QBaseRank")
local QBlackRockRank = class("QBlackRockRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QBlackRockRank:ctor(options)
	QBlackRockRank.super.ctor(self, options)
end

function QBlackRockRank:needsUpdate( ... )
	return true
end

function QBlackRockRank:update(success, fail)
	app:getClient():top50RankRequest("BLACK_ROCK_REALTIME_TOP_50", remote.user.userId, function (data)
	if data.rankings == nil or data.rankings.top50 == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.rankings.top50)
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	self._myInfo = data.rankings.myself

	self.super:update(success)
end, fail)
end

function QBlackRockRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QBlackRockRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:setTFByIndex(3, "组队积分：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.today_socre or 0)
		style:setTFByIndex(6, info.game_area_name or "")
		style:setTFByIndex(7, "")
		style:autoLayout()
	end
end

function QBlackRockRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "组队积分：")
	style:setTFByIndex(4, (myInfo.today_socre or "0"))
	style:autoLayout()
	style:setHideStart(true)
	return item
end

return QBlackRockRank