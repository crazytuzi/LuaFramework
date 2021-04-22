-- @Author: xurui
-- @Date:   2017-01-04 17:52:40
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-16 18:46:09

local QBaseRank = import(".QBaseRank")
local QMaritimeAllAreaRank = class("QMaritimeAllAreaRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QMaritimeAllAreaRank:ctor(options)
	QMaritimeAllAreaRank.super.ctor(self, options)
end

function QMaritimeAllAreaRank:needsUpdate( ... )
	return true
end

function QMaritimeAllAreaRank:update(success, fail)
	app:getClient():top50RankRequest("MARITIME_REALTIME_TOP_50", remote.user.userId, function (data)
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

function QMaritimeAllAreaRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QMaritimeAllAreaRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:setTFByIndex(3, "今日收益：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.artifactScore or 0)
		style:setTFByIndex(6, info.game_area_name or "")
		style:setSpByIndex(1, false)
		style:setTFByIndex(7, "")
		style:autoLayout()
	end
end

function QMaritimeAllAreaRank:getSelfItem()
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

	style:setTFByIndex(3, "今日收益：")
	style:setTFByIndex(4, (myInfo.artifactScore or "0"))
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QMaritimeAllAreaRank