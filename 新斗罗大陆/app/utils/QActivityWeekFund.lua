-- 
-- zxs
-- 周基金数据类
-- 
local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityWeekFund = class("QActivityWeekFund",QActivityRoundsBaseChild)
local QActivity = import(".QActivity")


function QActivityWeekFund:ctor( ... )
    QActivityWeekFund.super.ctor(self,...)

    self._weekFundInfo = {}
    self._userWeekFund = {}

    self._receviedAwards = {}
    for i = 1, 7 do
        self._receviedAwards[i] = false
    end
end


function QActivityWeekFund:setActivityInfo( data )
    QActivityWeekFund.super.setActivityInfo(self, data)
    self.buyEndAt = math.floor((data.buyEndAt or 0)/1000)
end

function QActivityWeekFund:checkRedTips()
    if self:getActivityActiveState() == false then
        return false
    end

    local userWeekFundInfo = self:getUserWeekFundInfo()
    if userWeekFundInfo == nil or next(userWeekFundInfo) == nil then
        return false 
    end 

    local isActiveMonthCard = remote.activity:checkMonthCardActive()
    -- 未激活双月卡每天红点一次
    if not isActiveMonthCard then
        if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.WEEK_FUND) then
            return true
        end
        if userWeekFundInfo.activateMoney and userWeekFundInfo.status == false then
            return true
        end
        return false
    end

    -- 已激活双月卡，未购买周基金，常亮
    if userWeekFundInfo.status == false then
        return true
    else
        -- 已激活周基金，可领取亮
        local reciviedAwards = self:getActivityReceivedAwards()
        local day = self:getActivityAchieveDay()
        for i = 1, 7 do
            if reciviedAwards[i] == false and i <= day then 
                return true
            end
        end
    end

    return false
end

function QActivityWeekFund:checkActivityComplete()
    return self:checkRedTips()
end

--设置周基金信息
function QActivityWeekFund:setWeekFundInfo(data)
    if data.weekFundInfo then
        self._weekFundInfo = data.weekFundInfo
    end
    if data.userWeekFundInfo then
        self._userWeekFund = data.userWeekFundInfo
    end

    self:checkRedTips()
    self:handleEvent()
end

--获取周基金信息
function QActivityWeekFund:getWeekFundInfo()
    return self._weekFundInfo 
end

--获取周基金奖励信息
function QActivityWeekFund:getUserWeekFundInfo()
    return self._userWeekFund 
end

function QActivityWeekFund:loadActivity()
    self.activityId = remote.activityRounds.WEEKFUND_TYPE
    if self.isOpen and self:getActivityActiveState() then
        local activities = {}
        table.insert(activities, {type = QActivity.TYPE_WEEKFUND, activityId = self.activityId, title = "周基金", description = "", roundType = "WEEK_FUND", weight = 7.9, targets = {}})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

--获取登陆第几天
function QActivityWeekFund:getActivityDay()
    local time = q.getTimeForHMS(0,0,0)
    if time > self.startAt then
        return math.ceil((time-self.startAt)/DAY)+1
    end
    return 1
end

function QActivityWeekFund:getActivityAchieveDay()
    local userInfo = self:getUserWeekFundInfo()
    if (userInfo.buyAt or 0) <= 0 then
        return 0
    end

    local time = q.getTimeForHMS(0,0,0)
    -- local achieveTime = userInfo.buyAt/1000

    -- modify by Kumo。优化：周基金的购买次数，不从原来的购买开始，而从活动开始时间开始。
    local info = self:getWeekFundInfo()
    local achieveTime = info.startAt/1000
    
    if time > achieveTime then
        return math.ceil((time-achieveTime)/DAY)+1
    end

    return 1
end

function QActivityWeekFund:getActivityReceivedAwards()
    local userInfo = self:getUserWeekFundInfo()
    if not userInfo then
        return self._receviedAwards
    end

    local awardTakenInfo = userInfo.awardTakenInfo or {}
    for i = 1, #awardTakenInfo do
        self._receviedAwards[awardTakenInfo[i]] = true
    end
    return self._receviedAwards
end

function QActivityWeekFund:getActivityActiveState()
    if not self.isOpen then
        return false
    end
    local isin14Day = remote.activity:checkActivityIsInDays(0, 14)
    if isin14Day then
        return false
    end   

    local day = self:getActivityDay() or 0
    local userInfo = self:getUserWeekFundInfo() or {}

    if not userInfo.status and self.buyEndAt < q.serverTime() then
        return false
    end

    return true
end

function QActivityWeekFund:checkWeekFoundIsBuyTime()
    if self.isOpen == false then return false end

    local isin14Day = remote.activity:checkActivityIsInDays(0, 14)
    if isin14Day then
        return false
    end 

    local userInfo = self:getUserWeekFundInfo() or {}
    if not userInfo.status and q.serverTime() <= self.buyEndAt then
        return true
    end

    return false
end

function QActivityWeekFund:getActivityInfoWhenLogin( success, fail )
    self:requestWeekFund(function()
            self:loadActivity()
            if success then
                success()
            end
        end, fail)
end

function QActivityWeekFund:activityShowEndCallBack(  )
    self:handleOffLine()
end

function QActivityWeekFund:activityEndCallBack(  )
    self:handleOffLine()
end

function QActivityWeekFund:handleOnLine( )
    if not self.isOpen then
        return
    end

    self:requestWeekFund(function()
            self:loadActivity()
        end, fail)
end

function QActivityWeekFund:handleOffLine( )
    -- body
    self._weekFundInfo = {}
    self._userWeekFund = {}
    self:checkRedTips()
    remote.activity:removeActivity(self.activityId , true)
    self.isOpen = false
    self:handleEvent()
end

function QActivityWeekFund:handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.WEEKFUND_UPDATE, isForce = true})
end

function QActivityWeekFund:getActiveDayNum()
    return 3
end

function QActivityWeekFund:getBuyEndAt()
    return self.buyEndAt
end


-----------------request--------------------------

function QActivityWeekFund:requestWeekFund(success, fail)
    local request = {api = "WEEK_FUND_GET_INFO"}
    app:getClient():requestPackageHandler("WEEK_FUND_GET_INFO", request, function (data)
        self:setWeekFundInfo(data)
        if success then
            success(data)
        end
    end, fail)
end

function QActivityWeekFund:requestWeekFundAward(awardIndex, success, fail)
    local request = {api = "WEEK_FUND_TAKE", weekFundGetAwardRequest = {awardIndex = awardIndex}}
    app:getClient():requestPackageHandler("WEEK_FUND_TAKE", request, function (data)
        self:setWeekFundInfo(data)
        if success then
            success(data)
        end
    end, fail)
end

return QActivityWeekFund