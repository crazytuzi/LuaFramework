--
-- Author: xurui
-- Date: 2016-06-24 10:09:44
--
local QBaseRank = import(".QBaseRank")
local QRealtimeAreaTowerRank2 = class("QRealtimeAreaTowerRank2", QBaseRank)

function QRealtimeAreaTowerRank2:ctor(options)
	QRealtimeAreaTowerRank2.super.ctor(self, options)
end

function QRealtimeAreaTowerRank2:needsUpdate( ... )
	return true
end

function QRealtimeAreaTowerRank2:update(success, fail)
	app:getClient():top50RankRequest("GLORY_COMPETITION_ENV_REALTIME_TOP_50", remote.user.userId, function (data)
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




return QRealtimeAreaTowerRank2