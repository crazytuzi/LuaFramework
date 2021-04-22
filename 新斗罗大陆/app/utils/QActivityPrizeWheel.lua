-- @Author: zhouxiaoshu
-- @Date:   2019-08-13 15:06:19
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-20 16:07:37
local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityPrizeWheel = class("QActivityPrizeWheel",QActivityRoundsBaseChild)

local MAX_COUNT = 8

function QActivityPrizeWheel:ctor( ... )
	-- body
	QActivityPrizeWheel.super.ctor(self,...)

	self._data = {}							-- 活动数据
	self._boxPrizeGotList = {}				-- 累计奖励记录
	self._helpPrizeGotList = {}				-- 助力奖励记录
	self._prizeWheelConfig = {}				-- 转盘配置
	self._prizeAwardConfig = {}				-- 累计配置
end

function QActivityPrizeWheel:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.PRIZA_WHEEL_UPDATE})
	end
end

function QActivityPrizeWheel:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.PRIZA_WHEEL_UPDATE})
end

function QActivityPrizeWheel:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.PRIZA_WHEEL_UPDATE})
end

function QActivityPrizeWheel:handleOnLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.PRIZA_WHEEL_UPDATE})
end

function QActivityPrizeWheel:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.PRIZA_WHEEL_UPDATE})
end

function QActivityPrizeWheel:checkRedTips( )
	-- 活动结束
	if not self.isOpen or not self.isActivityNotEnd then
		return false
	end

	-- 助力礼包
	if self:checkHelpBoxRedTips() then
		return true
	end

	-- 累计次数
	local function getIsGetAward(id)
		for i, v in pairs(self._data.boxPrizeGot or {}) do
			if tonumber(v) == id then
				return true
			end
		end
		return false
	end

	local drawCount = self._data.totalDrawCount or 0
	for i, v in pairs(self._prizeAwardConfig) do
		if drawCount >= v.number and not getIsGetAward(v.id) then
			return true
		end
	end

	-- 抽奖次数已满
	local count = #(self._data.wheelPrizeGot or {})
	if count >= MAX_COUNT then
		return false
	end

	-- 抽奖券足够
	local prizeWheelLottery = self._data.prizeWheelLottery or 0
	if prizeWheelLottery >= self:getCurConsumeTicket() then
		return true
	end

	return false
end

function QActivityPrizeWheel:checkHelpBoxRedTips()
    local curWheelGift = nil
    local curDays = self:getPrizeWheelDays()
    for i, v in pairs(self._wheelGiftConfig or {}) do
        if v.date == curDays then
            curWheelGift = v
            break
        end
    end
    if not curWheelGift then
        return false
    end

    local freeGet = false
    local feeGet = false
    local helpPrizeGot = self._data.helpPrizeGot or {}
    for i, v in pairs(helpPrizeGot) do
    	if v == 1 then
    		freeGet = true
    	elseif v == 2 then
    		feeGet = true
    	end
    end

    if not freeGet then
    	return true
    end
    if not feeGet and remote.user.todayRecharge >= curWheelGift.prize then
    	return true
    end
    return false
end

function QActivityPrizeWheel:initPrizeWheelConfig()
	if not self.rowNum then
		return
	end

	self._prizeWheelConfig = {}
	self._prizeAwardConfig = {}
	local wheelGiftConfig = db:getStaticByName("activity_prize_wheel_gift")
	local prizeWheelConfig = db:getStaticByName("activity_prize_wheel")
	local curPrizeWheelConfig = prizeWheelConfig[tostring(self.rowNum)] or {}
	self._wheelGiftConfig = wheelGiftConfig[tostring(self.rowNum)] or {}
	for i, v in pairs(curPrizeWheelConfig) do
		if v.type == 1 then
			table.insert(self._prizeWheelConfig, v)
		else
			table.insert(self._prizeAwardConfig, v)
		end
	end
	table.sort( self._prizeAwardConfig, function(a, b)
		return a.number < b.number
	end )
end

function QActivityPrizeWheel:updatePrizeWheelInfo(data, isDispatch)
	if not data.prizeWheelUserInfoResponse or not data.prizeWheelUserInfoResponse.userInfo then
		return
	end
	self._data = data.prizeWheelUserInfoResponse.userInfo
	if isDispatch then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.PRIZA_WHEEL_UPDATE})
	end
end

function QActivityPrizeWheel:addPrizeWheelMoney(number)
	self._data.prizeWheelLottery = (self._data.prizeWheelLottery or 0) + number
end

function QActivityPrizeWheel:getPrizeWheelInfo()
	return self._data
end

function QActivityPrizeWheel:getPrizeWheelDays()
	local passTime = q.serverTime() - self.startAt
	local days = math.ceil(passTime/DAY)
	return days
end

function QActivityPrizeWheel:getCurConsumeTicket()
	local costType = self:getCurCostType()
	local count = #(self._data.wheelPrizeGot or {})
	local config = db:getTokenConsume(costType, count+1)
	return config.money_num or 0
end


function QActivityPrizeWheel:getCurCostType()
	local costType = "activity_prize_wheel"
	local positionId = self._data.positionId or 1
	for i, v in pairs(self._prizeWheelConfig) do
		if v.id == positionId then
			return v.cost_array
		end
	end
	return costType
end

function QActivityPrizeWheel:getCurDialogHelpType()
	local helpType = "help_prize_wheel"
	local positionId = self._data.positionId or 1
	for i, v in pairs(self._prizeWheelConfig) do
		if v.id == positionId then
			return v.help
		end
	end
	return helpType
end


function QActivityPrizeWheel:getCurDropCostNum()
	local helpType = 0
	local positionId = self._data.positionId or 1
	for i, v in pairs(self._prizeWheelConfig) do
		if v.id == positionId then
			return db:getConfigurationValue(v.drop)
		end
	end
	return helpType
end

function QActivityPrizeWheel:getDrawReward()
	local positionId = self._data.positionId or 0
	for i, v in pairs(self._prizeWheelConfig) do
		if v.id == positionId then
			local awards = remote.items:analysisServerItem(v.reward)
			return positionId, awards
		end
	end
	return positionId
end

function QActivityPrizeWheel:getActivityInfoWhenLogin( success, fail )
    self:requestPrizeWheelInfo(success, fail)
end

-- 活动信息
function QActivityPrizeWheel:requestPrizeWheelInfo(success, fail)
    local request = {api = "PRIZE_WHEEL_GET_INFO", prizeWheelGetInfoRequest = {activityId = self.activityId}}
    app:getClient():requestPackageHandler("PRIZE_WHEEL_GET_INFO", request, function (data)
        self:initPrizeWheelConfig()
        self:updatePrizeWheelInfo(data, true)
        if success then
            success(data)
        end
    end, fail)
end

-- 开始转
function QActivityPrizeWheel:requestPrizeWheelDraw(success, fail)
    local request = {api = "PRIZE_WHEEL_DRAW", prizeWheelDrawRequest = {activityId = self.activityId}}
    app:getClient():requestPackageHandler("PRIZE_WHEEL_DRAW", request, function (data)
        self:updatePrizeWheelInfo(data, false)
        if success then
            success(data)
        end
    end, fail)
end

--getType == 1 助力奖励
function QActivityPrizeWheel:requestPrizeWheelGetPrizeHelp(prizeId, success, fail)
    local request = {api = "PRIZE_WHEEL_GET_PRIZE", prizeWheelGetPrizeRequest = {activityId = self.activityId, prizeId = prizeId, getType = 1}}
    app:getClient():requestPackageHandler("PRIZE_WHEEL_GET_PRIZE", request, function (data)
        self:updatePrizeWheelInfo(data, true)
        if success then
            success(data)
        end
    end, fail)
end

--getType == 2 累计转盘奖励
function QActivityPrizeWheel:requestPrizeWheelGetPrizeTotal(prizeId, success, fail)
    local request = {api = "PRIZE_WHEEL_GET_PRIZE", prizeWheelGetPrizeRequest = {activityId = self.activityId, prizeId = prizeId, getType = 2}}
    app:getClient():requestPackageHandler("PRIZE_WHEEL_GET_PRIZE", request, function (data)
        self:updatePrizeWheelInfo(data, true)
        if success then
            success(data)
        end
    end, fail)
end

return QActivityPrizeWheel