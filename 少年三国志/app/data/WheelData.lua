
require("app.cfg.game_time_info")
require("app.cfg.wheel_info")
require("app.cfg.wheel_prize_info")
require("app.cfg.shop_price_info")

local FuCommon = require("app.scenes.dafuweng.FuCommon")

local WheelData = class("WheelData")

function WheelData:ctor()
	self.score = 0
	self.score_total = 0
	self.pool = 0
	self.pool2 = 0
	self.got_reward = false
	self.rankList = {}
	self.jyRankList = {}
	self.myRank = -1
	self.jyRankScore = 10000
	self.awardRank = 0
	self.startTime = 0
	self.endTime = 0
	self.presentTime = 0
	self.bought_times1 = 0
	self.bought_times2 = 0
	self:initJy()
	self:initPriceData()
end

function WheelData:initJy()
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.event_type == FuCommon.WHEEL_PRIZE_TYPE and info.type == 2 then
			self.jyRankScore = info.score
		end
		if info.event_type == FuCommon.WHEEL_PRIZE_TYPE and info.lower_rank > self.awardRank then
			self.awardRank = info.lower_rank
		end
	end
end

function WheelData:updateInfo(data)
	self._date = G_ServerTime:getDate()
	self.score = data.score
	self.score_total = data.score_total
	self.pool = data.pool
	self.pool2 = data.pool2
	-- self.date = data.date
	self.got_reward = data.got_reward
	self.startTime = data.start
	self.endTime = data["end"]
	self.presentTime = data.present
	self.bought_times1 = rawget(data,"bought_times1") or 0
	self.bought_times2 = rawget(data,"bought_times2") or 0
end

-- @desc 是否重新需要拉数据
function WheelData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function WheelData:setList(ranks)
	self.rankList = ranks
	self:initRank()
end

function WheelData:getCurQuanNum()
	return G_Me.bagData:getPropCount(54)
end

function WheelData:hasFinalAward()
	return self:getState()==FuCommon.STATE_AWARD and self.myRank<=100 and self.myRank>0 and not self.got_reward
end

function WheelData:getTimeLeft()
	local time = G_ServerTime:getTime()
	local state = self:getState()
	if state == FuCommon.STATE_OPEN then
		return self.endTime - time
	elseif state == FuCommon.STATE_AWARD then
		return self.presentTime - time
	elseif state == FuCommon.STATE_CLOSE then
		return self.startTime - time
	end
	return -1
end

--1转盘2商店3关闭
function WheelData:getState()
	local time = G_ServerTime:getTime()
	if time <= self.startTime then
		return FuCommon.STATE_CLOSE
	elseif time <= self.endTime then
		return FuCommon.STATE_OPEN
	elseif time <= self.presentTime then
		return FuCommon.STATE_AWARD
	else
		return FuCommon.STATE_CLOSE
	end
end

function WheelData:initRank()
	self.jyRankList = {}
	self.myRank = 0
	for i = 1,#self.rankList do 
		if self.rankList[i].name == G_Me.userData.name then
			self.myRank = i
		end
		if self.rankList[i].score >= self.jyRankScore then
			table.insert(self.jyRankList,#self.jyRankList+1,self.rankList[i])
		end
	end
end

function WheelData:getMyRank()
	if self.myRank == -1 then
		self:initRank()
	end
	return self.myRank
end

function WheelData:play(data)
	local info = wheel_info.get(data.id)
	local times = #data.reward_id
	self.score = self.score + info.score*times
	self.score_total = self.score_total + info.score*times
	self.myRank = data.rank
	self.pool = data.pool
	self.pool2 = data.pool2
	if data.id == 1 then
		self.bought_times1 = self.bought_times1 + times
	else
		self.bought_times2 = self.bought_times2 + times
	end
end

function WheelData:getAward(_rank,_type)
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.type == _type and info.event_type == FuCommon.WHEEL_PRIZE_TYPE and _rank <= info.lower_rank and _rank >= info.upper_rank then
			return info
		end
	end
	return nil
end

function WheelData:getRankList(_type)
	if _type == FuCommon.RANK_TYPE_PT then
		return self.rankList
	else
		return self.jyRankList
	end
end

function WheelData:getScore100(_type)
	local list = self:getRankList(_type)
	if #list < 100 then
		return 0 
	else
		return list[100].score
	end
end

function WheelData:initPriceData()
	self._costList1 = {}
	self._costList2 = {}
	self._costFreeTimes1 = 0
	self._costFreeTimes2 = 0
	local buyType1 = wheel_info.get(1).cost_type
	local buyType2 = wheel_info.get(2).cost_type
	local buyT1 = wheel_info.get(1).cost
	local buyT2 = wheel_info.get(2).cost
	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == buyType1 then
			if info.price == 0 then
				find = true
			else
				if find then
					self._costFreeTimes1 = info.num - 1
				end
				find = false
			end
			table.insert(self._costList1,#self._costList1+1,{start_times = info.num, cost = info.price*buyT1})
		end
	end
	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == buyType2 then
			if info.price == 0 then
				find = true
			else
				if find then
					self._costFreeTimes2 = info.num - 1
				end
				find = false
			end
			table.insert(self._costList2,#self._costList2+1,{start_times = info.num, cost = info.price*buyT2})
		end
	end
end

function WheelData:getPrice(times,_type)
	local price = 0
	local boughtTimes = _type == 1 and self.bought_times1 or self.bought_times2
	local getOnePrice = function ( times )
		local list = _type == 1 and self._costList1 or self._costList2
		for i = 1, #list do
			local nextCostInfo = list[i + 1]
			if not nextCostInfo or nextCostInfo.start_times > times then
				return list[i].cost
			end
		end
	end

	for i = 1 , times do 
		price = price + getOnePrice(boughtTimes+i)
	end
	return price
end


function WheelData:getFreeLeft(_type)
	if _type == 1 then
		return self._costFreeTimes1 - self.bought_times1
	else
		return self._costFreeTimes2 - self.bought_times2
	end
end

return WheelData
