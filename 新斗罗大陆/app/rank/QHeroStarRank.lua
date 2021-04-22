--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QHeroStarRank = class("QHeroStarRank", QBaseRank)

function QHeroStarRank:ctor(options)
	QHeroStarRank.super.ctor(self, options)
end

function QHeroStarRank:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankRequest("HERO_STAR", remote.user.userId, function (data)
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




return QHeroStarRank
