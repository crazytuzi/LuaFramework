-- @Author: xurui
-- @Date:   2019-08-07 15:18:30
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-08 15:03:56
local QBaseSecretary = import(".QBaseSecretary")
local QLuckAdvanceDrawSecretary = class("QLuckAdvanceDrawSecretary", QBaseSecretary)

function QLuckAdvanceDrawSecretary:ctor(options)
	QLuckAdvanceDrawSecretary.super.ctor(self, options)
end

function QLuckAdvanceDrawSecretary:executeSecretary()
    local callback = function(data)
        -- 每日任务
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1])
            remote.user:addPropNumForKey("addupLuckydrawAdvanceCount")
            remote.user:addPropNumForKey("todayLuckyDrawAnyCount")  
            remote.user:addPropNumForKey("todayAdvancedDrawCount")  
            remote.activity:updateLocalDataByType(508,count)
        end
        remote.secretary:updateSecretaryLog(data)
        remote.secretary:nextTaskRunning()
    end

    if not self:checkSecretaryIsComplete() then
        self:luckyDrawAdvanceSecretaryRequest(1, false, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QLuckAdvanceDrawSecretary:checkSecretaryIsComplete()
    -- 高级抽奖
    local advanceLastTime = (remote.user.luckyDrawAdvanceRefreshedAt or 0)/1000
    local lastRefreshTime = q.date("*t", q.serverTime())
    if lastRefreshTime.hour < 5 then
        advanceLastTime = advanceLastTime + DAY
    end
    lastRefreshTime.hour = 5
    lastRefreshTime.min = 0
    lastRefreshTime.sec = 0
    lastRefreshTime = q.OSTime(lastRefreshTime)
    if advanceLastTime <= lastRefreshTime then
        return false
    else
        return true
    end
end

-- 抽将
function QLuckAdvanceDrawSecretary:luckyDrawAdvanceSecretaryRequest(count, isHalf, success, fail, status)
    local luckyDrawRequest = {isAdvance = true, count = count, isHalf = false, isSecretary = true}
    local request = {api = "LUCKY_DRAW", luckyDrawRequest = luckyDrawRequest}
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("LUCKY_DRAW", request, success, fail)
end

return QLuckAdvanceDrawSecretary
