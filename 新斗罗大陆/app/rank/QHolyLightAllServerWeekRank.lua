-- @Author: xurui
-- @Date:   2017-09-17 17:08:34
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-16 18:45:25

local QBaseRank = import(".QBaseRank")
local QHolyLightAllServerWeekRank = class("QHolyLightAllServerWeekRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleEmblic = import("..ui.widgets.rank.QUIWidgetRankStyleEmblic")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QHolyLightAllServerWeekRank:ctor(options)
	QHolyLightAllServerWeekRank.super.ctor(self, options)
end

function QHolyLightAllServerWeekRank:needsUpdate( ... )
	return true
end

function QHolyLightAllServerWeekRank:update(success, fail)
	app:getClient():top50RankRequest("HOLY_RIGHT_REALTIME_TOP_50", remote.user.userId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
		self._list = clone(data.rankings.top50)
		for k, v in ipairs(self._list) do
			v.holyLightScore = v.holyLightScore..string.format("（第%d关）", v.holyLightWaveId)
		end
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self._myInfo = data.rankings.myself
		if self._myInfo.holyLightWaveId ~= nil then
			self._myInfo.holyLightScore = self._myInfo.holyLightScore..string.format("（第%d关）", self._myInfo.holyLightWaveId)
		end

		self.super:update(success)
	end, fail)
end

function QHolyLightAllServerWeekRank:getRefreshHour()
	-- local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local refreshTime =  24
	return refreshTime
end

function QHolyLightAllServerWeekRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleEmblic.new()
	item:setStyle(style)
	return item
end

function QHolyLightAllServerWeekRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.icon)
		style:setVIP(nil)
		style:setTFByIndex(3, "试炼积分：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.holyLightScore)
		style:setTFByIndex(6, info.game_area_name)
		style:setTFByIndex(7, "  战力：")
		local num,unit = q.convertLargerNumber(info.force or 0)
		style:setTFByIndex(8, num..(unit or ""))
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

function QHolyLightAllServerWeekRank:getSelfItem()
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

	style:setTFByIndex(3, "试炼积分：")
	style:setTFByIndex(4, (myInfo.holyLightScore or "0"))
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QHolyLightAllServerWeekRank
