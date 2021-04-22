-- @Author: xurui
-- @Date:   2019-02-20 17:04:22
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-26 17:30:22

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityNewServiceFund = class("QActivityNewServiceFund",QActivityRoundsBaseChild)
local QActivity = import(".QActivity")

QActivityNewServiceFund.NEW_SERVICE_FUND_7 = "1"      --7日新服基金
QActivityNewServiceFund.NEW_SERVICE_FUND_14 = "2"       --14日新服基金
QActivityNewServiceFund.MAX_NEW_SERVICE_FUND_14 = "3"       --最新14日新服基金

function QActivityNewServiceFund:ctor( ... )
    -- body
    QActivityNewServiceFund.super.ctor(self,...)

    self._newServiceFounInfo = {}
    self._userNewServiceFounInfo = {}
    self.luckyDrawId = 1

    self._receviedAwards = {}
    for i = 1, 7 do
        self._receviedAwards[i] = false
    end
end

function QActivityNewServiceFund:checkRedTips()
    if self:getActivityActiveState() == false then
        return false
    end

    local userInfo = self:getUserWeekFundInfo()
    if userInfo == nil or next(userInfo) == nil then
        return false 
    end 

    -- 未购买新服基金，常亮
    if userInfo.status == false then
        if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.NEW_SERVICE_FUND) then
            return true
        end
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

function QActivityNewServiceFund:checkActivityComplete()
    return self:checkRedTips()
end

--设置周基金信息
function QActivityNewServiceFund:setWeekFundInfo(data)
    self._newServiceFounInfo = {}

    local awardConfig = db:getStaticByName("activity_newfund")[tostring(self.luckyDrawId)]
    self._newServiceFounInfo.startAt = self.startAt
    self._newServiceFounInfo.endAt = self.endAt
    self._newServiceFounInfo.money = awardConfig[1].money_number
    self._newServiceFounInfo.rebate = awardConfig[1].rebate
    self._newServiceFounInfo.showAwardInfo = awardConfig[1].show_rewards
    self._newServiceFounInfo.weekFundAwardInfo = {}
    self._newServiceFounInfo.activityName = awardConfig[1].activty_name
    self._buyDayTime = awardConfig[1].buy_time - awardConfig[1].start_time + 1

    for i, value in ipairs(awardConfig) do
        local award = {}
        remote.items:analysisServerItem(value.rewards, award)
        self._newServiceFounInfo.weekFundAwardInfo[i] = {awardIndex = value.days, award = award}
    end
    
    if data.userNewWeekFundInfo then
        self._userNewServiceFounInfo = data.userNewWeekFundInfo
    end

    self:checkRedTips()
    self:handleEvent()
end

--获取周基金信息
function QActivityNewServiceFund:getWeekFundInfo()
    return self._newServiceFounInfo 
end

--获取周基金奖励信息
function QActivityNewServiceFund:getUserWeekFundInfo()
    return self._userNewServiceFounInfo 
end

function QActivityNewServiceFund:loadActivity()
    self.activityId = remote.activityRounds.NEWSERVICE_FUND_TYPE
    if self.isOpen and self:getActivityActiveState() then
        local activities = {}
        table.insert(activities, {type = QActivity.TYPE_NEW_SERVICE_FUND, activityId = self.activityId, title = self._newServiceFounInfo.activityName or "武魂基金", description = "", roundType = "NEW_WEEK_FUND",
        start_at = self.startAt * 1000, end_at = self.endAt * 1000, award_at = self.startAt * 1000, award_end_at = self.endAt * 1000, weight = 7.9, targets = {}, subject = 2})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

--获取登陆第几天
function QActivityNewServiceFund:getActivityDay()
    local time = q.getTimeForHMS(0,0,0)
    if time > self.startAt then
        return math.ceil((time-self.startAt)/DAY)+1
    end
    return 1
end

function QActivityNewServiceFund:getActivityAchieveDay()
    if (self.startAt or 0) <= 0 then
        return 0
    end

    local time = q.getTimeForHMS(0,0,0)
    local achieveTime = self.startAt
    if time > achieveTime then
        return math.ceil((time-achieveTime)/DAY)+1
    end

    return 1
end

function QActivityNewServiceFund:getActivityReceivedAwards()
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

function QActivityNewServiceFund:getActivityActiveState()
    if not self.isOpen then
        return false
    end

    local day = self:getActivityDay() or 0
    local userInfo = self:getUserWeekFundInfo() or {}
    if not userInfo.status and day > self:getActiveDayNum() then
        return false
    end

    return true
end

function QActivityNewServiceFund:checkWeekFoundIsBuyTime()
    if self.isOpen == false then return false end

    local day = self:getActivityDay() or 0
    local userInfo = self:getUserWeekFundInfo() or {}
    if not userInfo.status and day <= self:getActiveDayNum() then
        return true
    end

    return false
end

function QActivityNewServiceFund:getActivityInfoWhenLogin( success, fail )
    self:requestWeekFund(function(data)
            self:createAlarmClock()
            if success then
                success()
            end
        end, fail)
end

function QActivityNewServiceFund:getActiveDayNum()
    return self._buyDayTime or 0
end

function QActivityNewServiceFund:activityShowEndCallBack(  )
    self:handleOffLine()
end

function QActivityNewServiceFund:activityEndCallBack(  )
    self:handleOffLine()
end

function QActivityNewServiceFund:handleOnLine( )
    if not self.isOpen then
        return
    end

    self:requestWeekFund(function(data)
            self:createAlarmClock()
        end, fail)
end

function QActivityNewServiceFund:handleOffLine( )
    -- body
    self._newServiceFounInfo = {}
    self._userNewServiceFounInfo = {}
    self:checkRedTips()
    remote.activity:removeActivity(self.activityId , true)
    self.isOpen = false
    self:handleEvent()
end

function QActivityNewServiceFund:handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.NEW_SERVICE_FUND_UPDATE, isForce = true})
end

function QActivityNewServiceFund:setActivityInfo( data )
    -- body
    if not data or not data.rowNum  then
        return 
    end

    self._activityData = data
    self.rowNum = self._activityData.rowNum
    self.luckyDrawId = self._activityData.luckyDrawId or "1"
    self.startAt = math.floor(self._activityData.startAt/1000)
    self.endAt = math.floor(self._activityData.endAt/1000)
    self.showEndAt = math.floor(self._activityData.showEndAt/1000)

    local curTime = q.serverTime()
    if self.showEndAt < curTime or self.startAt > curTime then
        self.isOpen = false
        self.isActivityNotEnd = false
    elseif self.endAt > curTime then
        self.isOpen = true
        self.isActivityNotEnd = true
    else
        self.isOpen = true
        self.isActivityNotEnd = false
    end
end

function QActivityNewServiceFund:createAlarmClock()
    local timeEndStr = string.format("%sEnd", "NEW_WEEK_FUND" or "")
    local timeShowEndStr = string.format("%sShowEnd", "NEW_WEEK_FUND" or "")
    app:getAlarmClock():deleteAlarmClock(timeEndStr)
    app:getAlarmClock():deleteAlarmClock(timeShowEndStr)

    self.rowNum = self._activityData.rowNum
    self.luckyDrawId = self._activityData.luckyDrawId or "1"
    self.startAt = math.floor(self._activityData.startAt/1000)
    self.endAt = math.floor(self._activityData.endAt/1000)
    self.showEndAt = math.floor(self._activityData.showEndAt/1000)


    local userInfo = self:getUserWeekFundInfo()
    if userInfo.status == false then
        self.endAt = self.startAt + (self:getActiveDayNum() * DAY)
        self.showEndAt = self.endAt
    end
    if self.endAt > self.showEndAt then
        self.showEndAt = self.endAt
    end

    local curTime = q.serverTime()
    if self.showEndAt < curTime or self.startAt > curTime then
    elseif self.endAt > curTime then
        if self.endAt == self.showEndAt then
            app:getAlarmClock():createNewAlarmClock(timeShowEndStr, self.endAt, function (  )
                -- body
                self.isActivityNotEnd = false
                self.isOpen = false
                self:activityShowEndCallBack()
            end)
        else
            app:getAlarmClock():createNewAlarmClock(timeEndStr, self.endAt, function (  )
                -- body
                self.isActivityNotEnd = false
                self:activityEndCallBack()
            end)

            app:getAlarmClock():createNewAlarmClock(timeShowEndStr, self.showEndAt, function (  )
            -- body
                self.isOpen = false
                self:activityShowEndCallBack()
            end)
        end 
    else
        app:getAlarmClock():createNewAlarmClock(timeShowEndStr, self.showEndAt, function (  )
            -- body
            self.isOpen = false
            self:activityShowEndCallBack()
        end)
    end

    self:loadActivity()
end

-----------------request--------------------------

function QActivityNewServiceFund:requestWeekFund(success, fail)
    local request = {api = "NEW_WEEK_FUND_GET_INFO"}
    app:getClient():requestPackageHandler("NEW_WEEK_FUND_GET_INFO", request, function (data)
        self:setWeekFundInfo(data)
        if success then
            success(data)
        end
    end, fail)
end

function QActivityNewServiceFund:requestWeekFundAward(awardIndex, success, fail)
    local request = {api = "NEW_WEEK_FUND_TAKE", newWeekFundGetAwardRequest = {awardIndex = awardIndex}}
    app:getClient():requestPackageHandler("NEW_WEEK_FUND_TAKE", request, function (data)
        self:setWeekFundInfo(data)
        if success then
            success(data)
        end
    end, fail)
end

return QActivityNewServiceFund
