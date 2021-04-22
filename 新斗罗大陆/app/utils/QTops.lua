--
-- Author: Your Name
-- Date: 2014-07-07 16:14:44
--
local QBaseModel = import("..models.QBaseModel")
local QTops = class("QTops",QBaseModel)

QTops.REFRESH_TIME = 3600 --秒

function QTops:ctor(options)
	QTops.super.ctor(self)
	self._isGet = false -- 是否请求了排行数据
	self._ranks = {} --排行数据
	self._ranksTime = 0
	self._ranksFirstTime = 0
end

function QTops:getIsLast()
	return q.time() - self._ranksTime <= QTops.REFRESH_TIME
end

function QTops:getTopIsLast()
	return q.time() - self._ranksFirstTime <= QTops.REFRESH_TIME
end

function QTops:getTopData()
	return self._ranks ~= nil and self._ranks or {}
end

function QTops:setTopData(ranks)
	self._ranks = ranks
	self._ranksTime = q.time()
	self._ranksFirstTime = q.time()
end

function QTops:setFirstData(ranks)
	self._ranks = ranks
	self._ranksFirstTime = q.time()
end

function QTops:setMyRank(rank)
	self._myRank = rank
end

function QTops:getMyRank()
	return self._myRank
end

function QTops:getInfoForUser(sid)
	for _,value in pairs(self._ranks) do
		if value.sid == sid then
			return value
		end
	end
end

function QTops:getFirstIsLast()
	return q.time() - self._ranksFirstTime <= QTops.REFRESH_TIME
end

return QTops