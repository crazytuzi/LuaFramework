
require("app.cfg.richman_info")
require("app.cfg.richman_event_info")
require("app.cfg.richman_prize_info")
require("app.cfg.richman_shop_info")
require("app.cfg.wheel_prize_info")
require("app.cfg.shop_price_info")

local FuCommon = require("app.scenes.dafuweng.FuCommon")


local RichData = class("RichData")

function RichData:ctor()
	self.step = 0
	self.score = 0
	self.got_reward = false
	self.round_award = {}
	self.shop_item = {}
	-- self.shop_item_count = {}
	self.rankList = {}
	self.jyRankList = {}
	self.myRank = -1
	self.jyRankScore = 10000
	self.awardRank = 0
	self.startTime = 0
	self.endTime = 0
	self.presentTime = 0
	self._buyId = 0
	self._rankOld = false
	self.bought_times = 0
	self:initJy()
	self:initPriceData()
end

function RichData:initJy()
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.event_type == FuCommon.RICH_PRIZE_TYPE and info.type == 2 then
			self.jyRankScore = info.score
		end
		if info.event_type == FuCommon.RICH_PRIZE_TYPE and info.lower_rank > self.awardRank then
			self.awardRank = info.lower_rank
		end
	end
end

function RichData:updateInfo(data)
	self._date = G_ServerTime:getDate()
	self.step = data.step
	self.score = data.score
	self.got_reward = data.got_reward
	self.round_award = data.round_award or {}
	self.shop_item = {}
	-- self.shop_item = data.shop_item or {}
	if data.shop_item then
		for k , v in pairs(data.shop_item) do 
			table.insert(self.shop_item,#self.shop_item+1,{id=v,count=data.shop_item_count[k]})
		end
		table.sort(self.shop_item,function ( a,b )
			local disa = richman_shop_info.get(a.id).discount
			local disb = richman_shop_info.get(b.id).discount
			disa = disa > 0 and disa or 100
			disb = disb > 0 and disb or 100
			if disa ~= disb then
				return disa < disb
			end
			return a.id < b.id
		end)
	end
	-- self.shop_item_count = data.shop_item_count or {}
	self.startTime = data.start
	self.endTime = data["end"]
	self.presentTime = data.present
	self.bought_times = rawget(data,"bought_times") or 0
end

-- @desc 是否重新需要拉数据
function RichData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function RichData:setList(ranks)
	self._rankOld = false
	self.rankList = ranks
	self:initRank()
end

function RichData:getShopList()
	return self.shop_item
end

function RichData:hasShopLeft()
	for k , v in pairs(self.shop_item) do 
		if v.count > 0 then
			return true
		end
	end
	return false
end

function RichData:gotRoundReward(id)
	for k , v in pairs(self.round_award) do 
		if v == id then
			return true
		end
	end
	return false
end

function RichData:refreshReward(_type,_id)
	if _type == 0 then
		self.got_reward = true
	else
		table.insert(self.round_award,#self.round_award+1,_id)
	end
end

function RichData:buySuccess(_id,_count)
	-- self.shop_item_count = self.shop_item_count - 1
	-- for i = 1 , #self.shop_item do 
	-- 	if self.shop_item[i].id == self._buyId then
	-- 		table.remove(self.shop_item,i)
	-- 		self._buyId = 0
	-- 		return
	-- 	end
	-- end
	-- self._buyId = 0
	
	if _id > 0 then
		for i = 1 , #self.shop_item do 
			if self.shop_item[i].id == _id then
				self.shop_item[i].count = self.shop_item[i].count - _count
			end
 		end
		self.score = self.score + richman_shop_info.get(_id).score * _count
	end
end

function RichData:leftBuyTimes(id)
	for i = 1 , #self.shop_item do 
		if self.shop_item[i].id == id then
			return self.shop_item[i].count 
		end
	end
	return 0
end

function RichData:getStep()
	return self.step
end

function RichData:hasFinalAward()
	return (self:getState()==FuCommon.STATE_AWARD and self.myRank<=100 and self.myRank>0 and not self.got_reward)
end

function RichData:getLoop()
	return math.max(math.floor((self.step-1)/35),0) 
end

function RichData:hasAward()
	if self:getState() == FuCommon.STATE_CLOSE then
		return false
	end
	for i = 1 , richman_prize_info.getLength() do 
		local info = richman_prize_info.get(i)
		if info.turn <= self:getLoop() and not self:gotRoundReward(info.id) then
			return true
		end
	end
	return false
end

function RichData:getCurQuanNum()
	return G_Me.bagData:getPropCount(54)
end

function RichData:getCurTouziNum()
	return G_Me.bagData:getPropCount(87)
end

function RichData:getTimeLeft()
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
function RichData:getState()
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

function RichData:initRank()
	self.jyRankList = {}
	self.myRank = 0
	local num = #self.rankList
	for i = 1,#self.rankList do 
		if self._rankOld then
			if self.score >= self.rankList[num+1-i].score then
				self.myRank = num+1-i
			end
		else
			if self.rankList[num+1-i].name == G_Me.userData.name then
				self.myRank = num+1-i
			end
		end
		if self.rankList[i].score >= self.jyRankScore then
			table.insert(self.jyRankList,#self.jyRankList+1,self.rankList[i])
		end
	end
	-- print("initRank "..self.myRank)
end

function RichData:getMyRank()
	-- if self.myRank == -1 then
	-- 	self:initRank()
	-- end
	self:initRank()
	return self.myRank
end

function RichData:play(data,oldDice)
	local dice = data.dice
	for k , v in pairs(dice) do 
		self.step = self.step + v
		self.score = self.score + v
	end
	local reroll = data.reroll
	for k , v in pairs(reroll) do 
		self.step = self.step + v
	end
	-- self.shop_item = data.goods
	self.shop_item = {}
	if data.goods then
		for k , v in pairs(data.goods) do 
			table.insert(self.shop_item,#self.shop_item+1,{id=v,count=data.count[k]})
		end
		table.sort(self.shop_item,function ( a,b )
			local disa = richman_shop_info.get(a.id).discount
			local disb = richman_shop_info.get(b.id).discount
			disa = disa > 0 and disa or 100
			disb = disb > 0 and disb or 100
			if disa ~= disb then
				return disa < disb
			end
			return a.id < b.id
		end)
	end
	-- self.shop_item_count = data.count
	if oldDice and oldDice == 0 then
		self.bought_times = self.bought_times + #dice
	end
	self._rankOld = true
end

function RichData:getAward(_rank,_type)
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.type == _type and info.event_type == FuCommon.RICH_PRIZE_TYPE and _rank <= info.lower_rank and _rank >= info.upper_rank then
			return info
		end
	end
	return nil
end

function RichData:getRankList(_type)
	if _type == FuCommon.RANK_TYPE_PT then
		return self.rankList
	else
		return self.jyRankList
	end
end

function RichData:getScore100(_type)
	local list = self:getRankList(_type)
	if #list < 100 then
		return 0 
	else
		return list[100].score
	end
end

function RichData:initPriceData()
	self._costList = {}
	self._costFreeTimes = 0
	local find = false
	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == 21 then
			if info.price == 0 then
				find = true
			else
				if find then
					self._costFreeTimes = info.num - 1
				end
				find = false
			end
			table.insert(self._costList,#self._costList+1,{start_times = info.num, cost = info.price})
		end
	end
end

function RichData:getPrice(times)
	local price = 0
	local getOnePrice = function ( times )
		for i = 1, #self._costList do
			local nextCostInfo = self._costList[i + 1]
			if not nextCostInfo or nextCostInfo.start_times > times then
				return self._costList[i].cost
			end
		end
	end

	for i = 1 , times do 
		price = price + getOnePrice(self.bought_times+i)
	end
	return price
end

function RichData:getFreeLeft()
	return self._costFreeTimes - self.bought_times
end

return RichData
