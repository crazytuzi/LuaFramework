--
-- Author: Kumo.Wang
-- 老玩家回归数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QUserComeBack = class("QUserComeBack", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")

QUserComeBack.NEW_DAY = "QUSERCOMEBACK_NEW_DAY"
QUserComeBack.UPDATE_USER_COMEBACK = "QUSERCOMEBACK_UPDATE_USER_COMEBACK"

QUserComeBack.TYPE_AWARD = "COMNBACK_TYPE_AWARD"
QUserComeBack.TYPE_EXCHANGE = "COMNBACK_TYPE_EXCHANGE"
QUserComeBack.TYPE_PAY = "COMNBACK_TYPE_PAY"
QUserComeBack.TYPE_FEATRUE = "COMNBACK_TYPE_FEATRUE"

function QUserComeBack:ctor()
    QUserComeBack.super.ctor(self)
end

function QUserComeBack:init()
    self._dispatchTBl = {}
    self._isOpen = false
    self._info = {}
    self._getUserComeBackDurationDays = 0 -- 召回功能的持续时间，单位：天
    self._getUserComeBackLoginDays = 0 -- 召回功能期间登陆天数，单位：天
end

function QUserComeBack:disappear()
    QUserComeBack.super.disappear(self)
    app:getAlarmClock():deleteAlarmClock("userComeBackEndTime")
    self:_removeEvent()
end

function QUserComeBack:loginEnd(success)
    if success then
        success()
    end
end

function QUserComeBack:_addEvent()
    self:_removeEvent()
    self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self._refreshTimeHandler))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_RECHARGED, self._updatePayInfo, self)
end

function QUserComeBack:_removeEvent()
    if self._userProxy ~= nil then
        self._userProxy:removeAllEventListeners()
        self._userProxy = nil
    end
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_RECHARGED, self._updatePayInfo, self)
end

--打开界面
function QUserComeBack:openDialog(callback)
    if self:getIsOpen() then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUserComeBack", options = {callback = callback}}) 
    else
        if callback then
            callback()
        else
            app.tip:floatTip("活动不存在或已结束")
        end
    end
end

--------------数据储存.KUMOFLAG.--------------

function QUserComeBack:getIsOpen()
    return self._isOpen
end

function QUserComeBack:getInfo()
    return self._info
end

--获取总的活动时间
function QUserComeBack:getUserComeBackDurationDays()
    if self._getUserComeBackDurationDays > 0 then return self._getUserComeBackDurationDays end
    if self._info and self._info.endAt and self._info.startAt then
        self._getUserComeBackDurationDays = math.ceil( (self._info.endAt - self._info.startAt) / (DAY * 1000) )
    else
        self._getUserComeBackDurationDays = 0
    end
    return self._getUserComeBackDurationDays
end

--获取兑换的次数
function QUserComeBack:getExchangeCountById(id)
    if self._info == nil or self._info.userComeBackBuyList == nil then
        return 0
    end
    for _,v in ipairs(self._info.userComeBackBuyList) do
        if v.goodId == id then
            return v.count
        end
    end
    return 0
end

--获取单日最大充值金额
function QUserComeBack:getDailyMaxRecharge()
    if self._info == nil or self._info.dailyMaxRecharge == nil then
        return 0
    end
    return self._info.dailyMaxRecharge
end

--获取单日累计充值金额
function QUserComeBack:getDailyTotalRecharge()
    if self._info == nil or self._info.dailyTotalRecharge == nil then
        return 0
    end
    return self._info.dailyTotalRecharge
end

--获取连续登陆天数
function QUserComeBack:getUserComeBackLoginDays()
    if self._getUserComeBackLoginDays > 0 then return self._getUserComeBackLoginDays end
    if self._info and self._info.startAt then
        self._getUserComeBackLoginDays = math.ceil( (q.serverTime() - self._info.startAt/1000) / DAY )
    else
        self._getUserComeBackLoginDays = 0
    end
    return self._getUserComeBackLoginDays
end

--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QUserComeBack:_createRedTips()
    remote.redTips:createTipsNode("QUIDialogUserComeBack_AwardButtonTips")
    remote.redTips:createTipsNode("QUIDialogUserComeBack_PayButtonTips")
end

function QUserComeBack:checkAllRedTips()
    local redTips = remote.redTips:getTipsStateByName("QUIDialogUserComeBack_AwardButtonTips")
    if redTips == false then
        redTips = remote.redTips:getTipsStateByName("QUIDialogUserComeBack_PayButtonTips")
    end

    return redTips
end

function QUserComeBack:checkRedTips()
    local isRedTip = false
    if self:getIsOpen() then
        local configs = self:getDataByType(QUserComeBack.TYPE_AWARD)
        local loginDay = self:getUserComeBackLoginDays()
        for _,v in ipairs(configs) do
            if loginDay >= v.day and self:checkLoginRewardInfoById(v.id) == false then
                isRedTip = true
                break
            end
        end
    end
    remote.redTips:setTipsStateByName("QUIDialogUserComeBack_AwardButtonTips", isRedTip)

    isRedTip = false
    if self:getIsOpen() then
        local configs = self:getDataByType(QUserComeBack.TYPE_PAY)
        local dailyMaxRecharge = self:getDailyMaxRecharge()
        local dailyTotalRecharge = self:getDailyTotalRecharge()
        for _,v in ipairs(configs) do
            local isGet = self:checkRechargeRewardInfoById(v.id)
            local isCanGet = false
            if v.chongzhi_leixing == 1 then
                isCanGet = dailyMaxRecharge >= v.chongzhi_jine
            else
                isCanGet = dailyTotalRecharge >= v.chongzhi_jine
            end
            if isCanGet and isGet == false then
                isRedTip = true
                break
            end
        end
    end
    
    remote.redTips:setTipsStateByName("QUIDialogUserComeBack_PayButtonTips", isRedTip)
end

function QUserComeBack:getDataByType(type)
    if type == QUserComeBack.TYPE_AWARD then
        return self:_getHeroComeBackAwardsBylevel(self._info.initTeamLevel)
    elseif type == QUserComeBack.TYPE_EXCHANGE then
        return self:_getHeroComeBackExchangeByLevel(self._info.initTeamLevel)
    elseif type == QUserComeBack.TYPE_PAY then
        return self:_getHeroComeBackPay()
    elseif type == QUserComeBack.TYPE_FEATRUE then
        return self:_getHeroComeBackFeature()
    end
    return {}
end

function QUserComeBack:_getHeroComeBackAwardsBylevel(level)
    local config = QStaticDatabase:sharedDatabase():getStaticByName("hero_comeback")
    local tbl = {}
    if level  == nil then return tbl end
    for _,v in pairs(config) do
        if v.min_level <= level and level <= v.max_level then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function QUserComeBack:_getHeroComeBackExchangeByLevel(level)
    local config = QStaticDatabase:sharedDatabase():getStaticByName("hero_comeback_duihuan")
    local tbl = {}
    if level  == nil then return tbl end
    for _,v in pairs(config) do
        if v.exchange_show <= level then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function QUserComeBack:_getHeroComeBackPay()
    local config = QStaticDatabase:sharedDatabase():getStaticByName("hero_comeback_chongzhi")
    local tbl = {}
    for _,v in pairs(config) do
        table.insert(tbl, v)
    end
    return tbl
end

function QUserComeBack:_getHeroComeBackFeature()
    local config = QStaticDatabase:sharedDatabase():getStaticByName("hero_comeback_wanfa")
    local tbl = {}
    for _,v in pairs(config) do
        if app.unlock:checkLock(v.unlock) then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function QUserComeBack:updateTime()
    local timeStr = "--:--:--"
    local dayInt = 0 
    local isOvertime = true
    if not self._endTimeForSec then
        self._endTimeForSec = self._info.endAt/1000
    end

    if q.serverTime() >= self._endTimeForSec then
        timeStr = "00:00:00"
    else
        local sec = self._endTimeForSec - q.serverTime()
        -- if sec >= 30*60 then
        --     color = ccc3(255, 216, 44)
        -- else
        --     color = ccc3(255, 63, 0)
        -- end
        local d, h, m, s = self:_formatSecTime( sec )
        dayInt = d
        timeStr = string.format("%02d:%02d:%02d", h, m, s)
        -- timeStr = string.format("%02d:%02d", h, m)
        isOvertime = false
    end

    return isOvertime, dayInt, timeStr
end

--检查是否领取过奖励
function QUserComeBack:checkLoginRewardInfoById(id)
    if self._info == nil or self._info.loginRewardInfo == nil then
        return false
    end
    for _,v in ipairs(self._info.loginRewardInfo) do
        if v == id then
            return true
        end
    end
    return false
end

--检查是否领取过充值奖励
function QUserComeBack:checkRechargeRewardInfoById(id)
    if self._info == nil or self._info.rechargeRewardInfo == nil then
        return false
    end
    for _,v in ipairs(self._info.rechargeRewardInfo) do
        if v == id then
            return true
        end
    end
    return false
end


--检查是否领取过充值奖励
function QUserComeBack:checkComeBackStated()
    local isOpen = self:getIsOpen()
    if isOpen == false then
        return false
    end
    
    if self._info and (self._info.endAt/1000) <= q.serverTime() then
        return false
    end

    return true
end

--------------数据处理.KUMOFLAG.--------------

function QUserComeBack:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )

    if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

function QUserComeBack:pushHandler( data )
    -- QPrintTable(data)
end

function QUserComeBack:setInfo(info)
    self._info = info
    local nowTimeForMsec = q.serverTime() * 1000
    local endOffsetTime = self._info.endAt - nowTimeForMsec
    self._isOpen = false
    if endOffsetTime > 0 and nowTimeForMsec > self._info.startAt then
        self._isOpen = true
        app:getAlarmClock():deleteAlarmClock("userComeBackEndTime")
        app:getAlarmClock():createNewAlarmClock("userComeBackEndTime", self._info.endAt/1000, function ()
                self:setInfo(self._info)
            end)
    end
    self:_createRedTips()
    self:checkRedTips()
    if self._isOpen then
        self:_addEvent()
        self:_analysisConfig()
    else
        self:_removeEvent()
    end
    self:dispatchEvent({name = QUserComeBack.UPDATE_USER_COMEBACK})
end

--老玩家领奖
function QUserComeBack:userComeBackTakeLoginRewardRequest(loginDay, success, fail)
    local userComeBackTakeLoginRewardRequest = { loginDay = loginDay}
    local request = { api = "USER_COME_BACK_TAKE_LOGIN_REWARD", userComeBackTakeLoginRewardRequest = userComeBackTakeLoginRewardRequest }
    app:getClient():requestPackageHandler("USER_COME_BACK_TAKE_LOGIN_REWARD", request, function (response)
        self:_updateDayAwardsData(loginDay)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--老玩家兑换奖励
function QUserComeBack:userComeBackBuyRewardRequest(goodId, count, success, fail)
    local userComeBackBuyRewardRequest = { goodId = goodId, count = count}
    local request = { api = "USER_COME_BACK_BUY_REWARD", userComeBackBuyRewardRequest = userComeBackBuyRewardRequest }
    app:getClient():requestPackageHandler("USER_COME_BACK_BUY_REWARD", request, function (response)
        self:_updateExchangeAwardsData(goodId, count)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--老玩家领取充值奖励
function QUserComeBack:userComeBackTakeRechargeRewardRequest(rewardId, success, fail)
    local userComeBackTakeRechargeRewardRequest = { rewardId = rewardId}
    local request = { api = "USER_COME_BACK_TAKE_RECHAREG_REWARD", userComeBackTakeRechargeRewardRequest = userComeBackTakeRechargeRewardRequest }
    app:getClient():requestPackageHandler("USER_COME_BACK_TAKE_RECHAREG_REWARD", request, function (response)
        self:_updateBuyAwardsData(rewardId)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QUserComeBack:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, name in pairs(self._dispatchTBl) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = 0
        end
    end
    self._dispatchTBl = {}
end

function QUserComeBack:_analysisConfig()
    
end

function QUserComeBack:_refreshTimeHandler(event)
    if event.time == nil or event.time == 0 then
        local info = self:getInfo()
        if info ~= nil then
            info.dailyMaxRecharge = 0
            info.dailyTotalRecharge = 0
            -- info.rechargeRewardInfo = nil
            info.userComeBackBuyList = nil
            self._getUserComeBackLoginDays = 0
            self:setInfo(info)
        end
        -- self:dispatchEvent( { name = QUserComeBack.NEW_DAY } )
    end

    -- if event.time == nil or event.time == 5 then
    --     self:dispatchEvent( { name = QUserComeBack.NEW_DAY } )
    -- end
end

--更新充值信息
function QUserComeBack:_updatePayInfo(event)
    local payNum = event.amount
    if self:getIsOpen() then
        local info = self:getInfo()
        if info ~= nil then
            info.dailyMaxRecharge = math.max(info.dailyMaxRecharge or 0, payNum)
            info.dailyTotalRecharge = (info.dailyTotalRecharge or 0) + payNum
            self:setInfo(info)
        end
    end
end

--更新每日奖励领取
function QUserComeBack:_updateDayAwardsData(day)
    local info = self:getInfo()
    if info ~= nil then
        if info.loginRewardInfo == nil then
            info.loginRewardInfo = {}
        end
        table.insert(info.loginRewardInfo, day)
        self:setInfo(info)
    end
end

--更新充值领奖
function QUserComeBack:_updateBuyAwardsData(rewardId)
    local info = self:getInfo()
    if info ~= nil then
        if info.rechargeRewardInfo == nil then
            info.rechargeRewardInfo = {}
        end
        table.insert(info.rechargeRewardInfo, rewardId)
        self:setInfo(info)
    end
end

--更新兑换领奖
function QUserComeBack:_updateExchangeAwardsData(goodId, count)
    local info = self:getInfo()
    if info ~= nil then
        local isFind = false
        if info.userComeBackBuyList ~= nil then
            for _,v in ipairs(info.userComeBackBuyList) do
                if v.goodId == goodId then
                    v.count = v.count + count
                    isFind = true
                    break
                end
            end     
        end
        if isFind == false then
            if info.userComeBackBuyList == nil then
                info.userComeBackBuyList = {}
            end
            table.insert(info.userComeBackBuyList, {goodId = goodId, count = count})
        end
        self:setInfo(info)
    end
end

-- 将秒为单位的数字转换成 00：00：00格式
function QUserComeBack:_formatSecTime( sec )
    local d = math.floor(sec/DAY)
    local h = math.floor((sec/HOUR)%24)
    local m = math.floor((sec/MIN)%60)
    local s = math.floor(sec%60)

    return d, h, m, s
end

return QUserComeBack
