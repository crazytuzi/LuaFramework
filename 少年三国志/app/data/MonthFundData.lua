--月基金数据 
require("app.cfg.month_fund_info")

local MonthFundData = class("MonthFundData")


function MonthFundData:ctor()

	self:initBaseInfo()

end

function MonthFundData:initBaseInfo()
	
	self._buy_start_time = 0
	self._buy_end_time = 0
	self._reward_start_time = 0
	self._reward_end_time = 0
	self._activate = false  --是否激活双月卡
	self._buy_month_fund = {false,false}  --是否购买月基金
	self._can_get_reward = false  --是否有奖励可领取
	self._dataReady = false
	self._buy_open = {false,false} --是否开放月基金

	self._award_day = 0  --当前可领第几天奖
	self._get_award_days = {{},{}}  --已领取的天数

end

--TODO 检测时间合法性
function MonthFundData:_checkTimeValid()
	
	local serverTime = G_ServerTime:getTime()

	if self._buy_start_time == 0 or self._buy_end_time == 0 or
		self._reward_start_time == 0 or self._reward_end_time == 0 then
		return false
	end

	if self._buy_start_time > self._buy_end_time or self._reward_start_time > self._reward_end_time 
		or self._buy_end_time > self._reward_start_time then 	
		return false
	end

	--领奖结束或者未开启购买不显示
	if serverTime >= self._reward_end_time or serverTime < self._buy_start_time then
		return false
	end

	--购买结束并且为购买也不显示
	if self:checkInAwardStage() and not self:hasBought(1) and not self:hasBought(2) then 
		return false
	end


	return true
end

function MonthFundData:updateBaseInfo(data)
	self:initBaseInfo()

	self._buy_start_time = rawget(data, "mfd_time") and data.mfd_time.recharge_start_time or 0
	self._buy_end_time = rawget(data, "mfd_time") and data.mfd_time.recharge_end_time or 0
	self._reward_start_time = rawget(data, "mfd_time") and data.mfd_time.reward_start_time or 0
	self._reward_end_time = rawget(data, "mfd_time") and data.mfd_time.reward_end_time or 0

	self._activate = rawget(data, "activate") and data.activate or false
	self._buy_month_fund[1] = rawget(data, "buy_small") and data.buy_small or false
	self._buy_month_fund[2] = rawget(data, "buy_big") and data.buy_big or false
	self._can_get_reward = rawget(data, "flag") and data.flag or false

	if rawget(data, "fund_kind") then
		self._buy_open[1] = data.fund_kind > 1
		self._buy_open[2] = data.fund_kind%2 > 0
	end
	
	if not self:_checkTimeValid() then
		self:initBaseInfo()
        --G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_FUND_ERROR_CONFIG"))
		return
	end

	self._dataReady = true

end


function MonthFundData:updateAwardInfo(monthFund)
	
	self._award_day = rawget(monthFund, "day") and monthFund.day or 0

    if rawget(monthFund, "award_days_small") and monthFund.award_days_small ~= nil then
        for i,v in ipairs(monthFund.award_days_small) do
            self._get_award_days[1][v] = v
        end
    end
    if rawget(monthFund, "award_days_big") and monthFund.award_days_big ~= nil then
        for i,v in ipairs(monthFund.award_days_big) do
            self._get_award_days[2][v] = v
        end
    end

end

function MonthFundData:updateAward(monthFund)

	--服务器重发领奖信息
	self:updateAwardInfo(monthFund)

end

------------------------

--判断是否处于购买阶段
function MonthFundData:checkInBuyStage( )
	
	local now = G_ServerTime:getTime()

	return now > self._buy_start_time and now < self._buy_end_time

end


--判断是否处于领奖阶段
function MonthFundData:checkInAwardStage( )
	
	local now = G_ServerTime:getTime()

	return  now > self._reward_start_time and now < self._reward_end_time

end


function MonthFundData:getBuyStartTime()
	return self._buy_start_time
end

function MonthFundData:getBuyEndTime()
	return self._buy_end_time
end

function MonthFundData:getRewardStartTime()
	return self._reward_start_time
end

function MonthFundData:getRewardEndTime()
	return self._reward_end_time
end


function MonthFundData:getStartBuyCountDown()
	local t1 = self._buy_start_time
	local t2 = G_ServerTime:getTime()
	return (t1 > t2) and (t1 - t2) or 0
end

function MonthFundData:getEndBuyCountDown()
	local t1 = self._buy_end_time
	local t2 = G_ServerTime:getTime()
	return (t1 > t2) and (t1 - t2) or 0
end

function MonthFundData:getStartAwardCountDown()
	local t1 = self._reward_start_time
	local t2 = G_ServerTime:getTime()
	return (t1 > t2) and (t1 - t2) or 0
end

function MonthFundData:getEndAwardCountDown()
	local t1 = self._reward_end_time
	local t2 = G_ServerTime:getTime()
	return (t1 > t2) and (t1 - t2) or 0
end


function MonthFundData:dataReady()
	return self._dataReady
end

function MonthFundData:openBuy()
	
	local now = G_ServerTime:getTime()
	return now > self._buy_start_time and now < self._buy_end_time

end

function MonthFundData:hasBought(type)
	return self._buy_month_fund[type] 
end

function MonthFundData:hasOpen(type)
	return self._buy_open[type] 
end

function MonthFundData:isActivate()
	return self._activate
end


--某天奖励是否能领取
function MonthFundData:canGetAward(day,_type)

	if self._award_day == 0 or day == 0 or type(day) ~= "number" then
		return false
	end

	--未激活或者未购买
	if not self:hasBought(_type) then
		return false
	end

	local now = G_ServerTime:getTime()

	--过期了
	if now <= self._reward_start_time or now >= self._reward_end_time then
		return false
	end

	--不在已领奖天数列表
	if day <= self._award_day and not self._get_award_days[_type][day] then
		return true
	else 
		return false
	end
	
end

function MonthFundData:hasGetAward(day,_type)

	if type(day) ~= "number" then
		return false
	end
	_type = _type or 1
	return self._get_award_days[_type][day] ~= nil 

end

--是否有未领取的奖励
function MonthFundData:canGetAnyAward(_type)
	
	for i = 1, month_fund_info.getLength() do
		if self:canGetAward(i,_type) then
			return true
		end
	end

	return false
end

--红点提示条件：可购买或者可领取奖励
function MonthFundData:needTips( ... )
	
	if self._can_get_reward then
		return true
	end

	if self:canGetAnyAward(1) or self:canGetAnyAward(2) then
		return true
	end

	if not ( self:hasBought(1) and self:hasBought(2) ) and self:openBuy() then
		return true
	else
		return false
	end	
end



return MonthFundData
