-- @Author: liaoxianbo
-- @Date:   2019-05-31 12:04:05
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-27 15:40:44

local QBaseModel = import("..models.QBaseModel")
local QActivityVipGift = class("QActivityVipGift",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QActivity = import(".QActivity")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")


function QActivityVipGift:ctor( )
    QActivityVipGift.super.ctor(self)
    cc.GameObject.extend(self)
    self._dailyRecord = {}
    self._weekRecord = {}
end

function QActivityVipGift:loginEnd(success)
    self:loadActivity()
    self._showWeekVipGiftTips = true
    self._curentVipLevel = app.vipUtil:VIPLevel() --记录周礼包登陆后的VIP等级
    self:updateRecord(function()
        if success then
            success()
        end
    end)
end

function QActivityVipGift:hideWeekVipGiftTips()
    self._showWeekVipGiftTips = false
end
function QActivityVipGift:updateRecord(callback)
    self._curentVipLevel = app.vipUtil:VIPLevel()
    self:requestGetVipDailyGiftRecord(function(data)
        self:switchRecord(data.vipvGiftGetRecordResponse)
        if callback then
            callback()
        end
    end, function( ... )
        if callback then
            callback()
        end
    end)
end

function QActivityVipGift:switchRecord(response)
    if not response then return end
    if response.weekRecord then
         self._weekRecord = {}
        local weekRecord = response.weekRecord
        local record = string.split(weekRecord,";")
        for _,value in pairs(record) do
            if value and value ~= "" then
                local s, e = string.find(value, "%^")
                local id = string.sub(value, 1, s - 1)
                local count = string.sub(value, e + 1)
                table.insert(self._weekRecord,{id = id,count = count })
            end
        end
    end

    if response.dailyRecord then
        self._dailyRecord = {}
        local dailyRecord = response.dailyRecord
        local record = string.split(dailyRecord,";")
        for _,value in pairs(record) do
            if value and value ~= "" then
                local s, e = string.find(value, "%^")
                local id = string.sub(value, 1, s - 1)
                local count = string.sub(value, e + 1)
                table.insert(self._dailyRecord,{id = id,count = count })
            end
        end
    end
end

function QActivityVipGift:didappear()
    
end

function QActivityVipGift:disappear()

end

function QActivityVipGift:getDailyRecord( )
    return self._dailyRecord
end

function QActivityVipGift:getWeekRecord( )
    return self._weekRecord
end

function QActivityVipGift:checkDailyRedTips()
    if next(self._dailyRecord) == nil then
        return true
    else
        return false
    end
end
 
function QActivityVipGift:checkWeekRedTips()  
    local checkVip = app.vipUtil:VIPLevel()
    if self._curentVipLevel < checkVip then
        return true
    else
        local vipgiftList = db:getVipGiftWeekList()
        local weekList = {}
        for _,value in pairs(vipgiftList) do
            table.insert(weekList,value)
        end
        if #weekList == #self._weekRecord then
            for _,v in pairs(weekList) do 
                for _,r in pairs(self._weekRecord) do
                    if tonumber(v.id) == tonumber(r.id) then
                        local lastBuyTime = tonumber(v.exchange_number) - tonumber(r.count) 
                        if lastBuyTime > 0 then
                            return true
                        end
                    end
                end
            end
            return false
        end
        return app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("activity_"..QActivity.TYPE_VIP_GIFT_WEEK)
    end
end

function QActivityVipGift:loadActivity()
    local activities = {}
    if app.unlock:checkLock("UNLOCK_VIP_PACKAGE", false) then
        table.insert(activities,{type = QActivity.VIP_GIFT_DAILY, activityId = QActivity.TYPE_VIP_GIFT_DAILY, title = "每日福利",isLocal = true,subject = QActivity.THEME_ACTIVITY_NORMAL})
    end
    
    if app.unlock:checkLock("UNLOCK_VIP_PACKAGE_WEEK", false) then 
        table.insert(activities,{type = QActivity.VIP_GIFT_WEEK, activityId = QActivity.TYPE_VIP_GIFT_WEEK, title = "每周礼包",isLocal = true,subject = QActivity.THEME_ACTIVITY_NORMAL })
    end
    remote.activity:setData(activities)

end

-----------------request--------------------------
-- VIP礼包购买记录
function QActivityVipGift:requestGetVipDailyGiftRecord(success, fail)
    local request = {api = "VIP_GIFT_RECORD"}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if success then
                success(data)
            end
        end, fail)
end
--VIP每日福利领取
function QActivityVipGift:requestMyVipDailyGift(success, fail)
    local request = {api = "VIP_GIFT_DAILY_GAIN"}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if success then
                success(data)
            end
        end, fail)
end
-- VIP每周礼包购买
function QActivityVipGift:requestByMyVipWeekGift(index,success, fail)
    local request = {api = "VIP_GIFT_WEEK_BUY", vipGiftWeekBuyRequest = {index = index}}
    app:getClient():requestPackageHandler("VIP_GIFT_WEEK_BUY", request, function(data)
            if success then
                success(data)
            else
                print("购买失败---")
                printTable(data)
            end
        end, fail)

end
return QActivityVipGift