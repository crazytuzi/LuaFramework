--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QAllFightCapacityRank = class("QAllFightCapacityRank", QBaseRank)

function QAllFightCapacityRank:ctor(options)
	QAllFightCapacityRank.super.ctor(self, options)
end

function QAllFightCapacityRank:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankRequest("TOTAL", remote.user.userId, function (data)
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




return QAllFightCapacityRank
