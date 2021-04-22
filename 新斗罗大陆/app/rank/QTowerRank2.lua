--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QTowerRank2 = class("QTowerRank2", QBaseRank)

function QTowerRank2:ctor(options)
	QTowerRank2.super.ctor(self, options)
end

function QTowerRank2:needsUpdate( ... )
	if q.isEmpty(self._list) then
		return true
	end

	-- roughly :)
	if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
		return true
	end
end

function QTowerRank2:update(success, fail)
	app:getClient():top50RankRequest("GLORY_COMPETITION_HISTORY_TOP_50", remote.user.userId, function (data)
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




return QTowerRank2
