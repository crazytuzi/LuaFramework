--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QStormArenaSeasonRank = class("QStormArenaSeasonRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QStormArenaSeasonRank:ctor(options)
	QStormArenaSeasonRank.super.ctor(self, options)
end

function QStormArenaSeasonRank:needsUpdate( ... )
	-- return true
	-- if q.isEmpty(self._list) then
	-- 	return true
	-- end

	-- -- roughly :)
	-- if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
	-- 	return true
	-- end
	return true
end

function QStormArenaSeasonRank:update(success, fail)
	app:getClient():top50RankRequest("STORM_SEASON_SCORE_TOP_50", remote.user.userId, function (data)
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

function QStormArenaSeasonRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QStormArenaSeasonRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)

		style:setTFByIndex(3, "赛季积分：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.seasonScore)
		style:setTFByIndex(6, info.game_area_name)
		style:setTFByIndex(7, "")
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

function QStormArenaSeasonRank:getSelfItem()
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

	style:setTFByIndex(3, "赛季积分：")
	style:setTFByIndex(4, (myInfo.seasonScore or "0"))
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end




return QStormArenaSeasonRank
