--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QStormArenaUnionRank = class("QStormArenaUnionRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")

function QStormArenaUnionRank:ctor(options)
	QStormArenaUnionRank.super.ctor(self, options)
end

function QStormArenaUnionRank:needsUpdate( ... )
	if q.isEmpty(self._list) then
		return true
	end

	-- roughly :)
	if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
		return true
	end
end

function QStormArenaUnionRank:update(success, fail)
	app:getClient():top50RankRequest("STORM_CONSORTIA_INCOME", remote.user.userId, function (data)
	if data.consortiaRankings == nil or data.consortiaRankings.top50 == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.consortiaRankings.top50)
	for k, v in ipairs(self._list) do
		v.avatar = v.icon
	end
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	self._myInfo = data.consortiaRankings.myself

	self.super:update(success)
end, fail)
end

function QStormArenaUnionRank:getRefreshHour()
	local refreshTime =  24
	return refreshTime
end

function QStormArenaUnionRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QStormArenaUnionRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setUnionAvatar(info.icon, info.consortiaWarFloor)
		style:setVIP(nil)
		style:setTFByIndex(3, "风暴积分：")
		style:setTFByIndex(4, info.storm_income)
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

return QStormArenaUnionRank
