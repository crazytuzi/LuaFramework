
require("app.cfg.wheel_prize_info")
require("app.cfg.shop_price_info")

local FuCommon = require("app.scenes.dafuweng.FuCommon")

local TrigramsData = class("TrigramsData")

function TrigramsData:ctor()
	
	self:_initData()

end

function TrigramsData:_initData()

	self.score = 0
	self.got_reward = false
	self.rankList = {}
	self.jyRankList = {}
	self.myRank = -1
	self.jyRankScore = 10000
	self.awardRank = 0
	self.startTime = 0
	self.endTime = 0
	self.presentTime = 0
	self.playCount = 0

	self._rankUpdated = false  --排名是否变化
	self.myOldRank = 0

	self._awardList = {}    --8个道具列表
	self._openList = {}    --8个位置开启状态列表  0代表未开启
	self._levelList = {}   --8个位置对应的等级（品质）列表

	self:_initJyRankInfo()
	self:_initPriceData()

end


function TrigramsData:_initJyRankInfo()
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.event_type == FuCommon.TRIGRAMS_PRIZE_TYPE and info.type == 2 then
			self.jyRankScore = info.score
		end
		if info.event_type == FuCommon.TRIGRAMS_PRIZE_TYPE and info.lower_rank > self.awardRank then
			self.awardRank = info.lower_rank
		end
	end
end

-- @desc 是否重新需要拉数据
function TrigramsData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end


---------------------接收协议返回数据

function TrigramsData:updateTrigram(data)
	self._awardList = {}
	self._openList = {}
	self._levelList = {}

	self._awardList = rawget(data, "awards") and data.awards or {}
	self._levelList = rawget(data, "award_level") and data.award_level or {}
	self._openList = rawget(data, "open") and data.open or {}
end

function TrigramsData:updateInfo(data)

	if type(data) ~= "table" then return end

	self._date = G_ServerTime:getDate()

	self.score = data.score
	self.got_reward = data.got_reward
	self.startTime = data.start
	self.endTime = data["end"]
	self.presentTime = data.present
	self.playCount = data.count

	if rawget(data, "info") then
		self:updateTrigram(data.info)
	end

end


function TrigramsData:updatePlayOne(data)

	if type(data) ~= "table" then return end

	--将对应位置置成开启状态
	if rawget(data, "pos") and rawget(data, "open_id") then
		self._openList[data.pos] = data.open_id
	end

	--dump(self._openList)
	self._rankUpdated = true
	self.myOldRank = self.myRank

	self.playCount = self.playCount + 1   --已抽取次数加1

	if rawget(data, "score") then
		self.score = data.score
	end

end


function TrigramsData:updatePlayAll(data)

	if type(data) ~= "table" then return end

	--默认都打开
	for i=1, #self._openList do
		self._openList[i] = i
	end

	self._rankUpdated = true
	self.myOldRank = self.myRank

	self.playCount = self.playCount + FuCommon.ITEM_MAX_NUM   --已抽取次数加8

	if rawget(data, "score") then
		self.score = data.score
	end

end


function TrigramsData:updateRankList(data)

	if type(data) ~= "table" then return end

	self._rankUpdated = false

	self.rankList = data.ranking or {}

	self:initRank()
	self.myOldRank = self.myRank
end


function TrigramsData:updateReward(data)

	self.got_reward = true

end


---------------------


function TrigramsData:hasFinalAward()
	return self:getState()==FuCommon.STATE_AWARD and self.myRank<=100 and self.myRank>0 and not self.got_reward
end

function TrigramsData:getTimeLeft()
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

function TrigramsData:isClose()
	return self:getState() == FuCommon.STATE_CLOSE
end

function TrigramsData:getState()
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

function TrigramsData:initRank()

	self.jyRankList = {}
	self.myRank = 0
	local num = #self.rankList

	for i = 1, num do

		if self._rankUpdated then
			if self.score >= self.rankList[num+1-i].sp1 then
				self.myRank = num+1-i
			end
		else
			if tostring(self.rankList[num+1-i].id) == tostring(G_Me.userData.id) and 
				tostring(self.rankList[num+1-i].sid) == tostring(G_PlatformProxy:getLoginServer().id) then				
				self.myRank = num+1-i
			end
		end

		if self.rankList[i].sp1 >= self.jyRankScore then
			table.insert(self.jyRankList,#self.jyRankList+1,self.rankList[i])
		end
	end
end

function TrigramsData:getMyRank()
	-- if self.myRank == -1 then
	-- 	self:initRank()
	-- end
	self:initRank()
	return self.myRank
end



function TrigramsData:getAward(_rank,_type)
	for i = 1 , wheel_prize_info.getLength() do 
		local info = wheel_prize_info.indexOf(i)
		if info.type == _type and info.event_type == FuCommon.TRIGRAMS_PRIZE_TYPE and _rank <= info.lower_rank and _rank >= info.upper_rank then
			return info
		end
	end
	return nil
end


function TrigramsData:getAwardList()
	return self._awardList
end

function TrigramsData:getLevelList()
	return self._levelList
end

function TrigramsData:getAwardInfo(pos)
	
	if type(pos) ~= "number" or pos < 1 or pos > FuCommon.ITEM_MAX_NUM then return nil end

	--如果所有位置都没打开则取默认顺序的award
	if not self:isAniPosOpen() then
		return self._awardList[pos]
	end

	local openAwardIndex = self._openList[pos]
	--先判断pos是否打开过
	if openAwardIndex > 0 and #self._awardList >= openAwardIndex then
		return self._awardList[openAwardIndex]
	end

	return nil
end

function TrigramsData:isPosOpen(pos)
	
	if type(pos) ~= "number" or pos < 1 or pos > FuCommon.ITEM_MAX_NUM then return false end
	
	if #self._openList >= pos then
		return self._openList[pos] > 0
	end

	return false
end


function TrigramsData:isAniPosOpen()
	for i=1, FuCommon.ITEM_MAX_NUM do
		if self:isPosOpen(i) then
			return true
		end
	end

	return false
end

function TrigramsData:isAllPosOpen()
	for i=1, FuCommon.ITEM_MAX_NUM do
		if not self:isPosOpen(i) then
			return false
		end
	end

	return true
end

function TrigramsData:getAwardLevel(pos)
	
	if type(pos) ~= "number" or pos < 1 or pos > FuCommon.ITEM_MAX_NUM then 
			return FuCommon.TRIGRAMS_REWARD_LEVEL_3 
		end
	
	--如果所有位置都没打开则取默认顺序的award
	if not self:isAniPosOpen() then
		return self._levelList[pos]
	end

	local openAwardIndex = self._openList[pos]
	--先判断pos是否打开过
	if openAwardIndex > 0 and #self._levelList >= openAwardIndex then
		return self._levelList[openAwardIndex]
	end

	return FuCommon.TRIGRAMS_REWARD_LEVEL_3
end


function TrigramsData:getRankList(_type)

	_type = _type or FuCommon.RANK_TYPE_PT

	if _type == FuCommon.RANK_TYPE_PT then
		return self.rankList
	else
		return self.jyRankList
	end
end

function TrigramsData:getScore100(_type)
	local list = self:getRankList(_type)
	if #list < 100 then
		return 0 
	else
		return list[100].sp1
	end
end

function TrigramsData:_initPriceData()
	self._costList = {}
	self._costFreeTimes = 0

	local find = false

	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == FuCommon.TRIGRAMS_ID_IN_SHOP_PRIZE_INFO then
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

	--dump(self._costList)

end

function TrigramsData:getPrice(times)

	local price = 0
	local playTimes = self.playCount
	local getOnePrice = function ( times )
		local list = self._costList
		for i = 1, #list do
			local nextCostInfo = list[i + 1]
			if not nextCostInfo or nextCostInfo.start_times > times then
				return list[i].cost
			end
		end
		return 0
	end

	for i = 1 , times do 
		price = price + getOnePrice(playTimes+i)
		
		--单次抽取价格*(4/3)
		if times == 1 then
			price  = math.floor(price * 4 / 3)
		end
	end

	return price
end

function TrigramsData:getRefreshPrice()

	--打开过任意位置
	if self:isAniPosOpen() then
		return 0
	else
		return FuCommon.REFRESH_COST_GOLD
	end

end

--判断能否刷新 TODO
function TrigramsData:canRefresh()
	return true
end

function TrigramsData:getFreeLeft(_type)
	return self._costFreeTimes - self.playCount
end

return TrigramsData
