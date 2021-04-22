-- @Author: xurui
-- @Date:   2019-08-07 15:14:11
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-08 15:02:00
local QBaseSecretary = import(".QBaseSecretary")
local QLuckDrawSecretary = class("QLuckDrawSecretary", QBaseSecretary)

function QLuckDrawSecretary:ctor(options)
	QLuckDrawSecretary.super.ctor(self, options)
end

-- 普通酒馆抽奖
function QLuckDrawSecretary:executeSecretary()
    local callback = function(data)
        -- 每日任务
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1])
            remote.user:addPropNumForKey("addupLuckydrawCount",count)
            remote.user:addPropNumForKey("todayLuckyDrawAnyCount",count)  
            remote.user:addPropNumForKey("todayLuckyDrawFreeCount",count)  
            remote.activity:updateLocalDataByType(507,count)
        end
        remote.secretary:updateSecretaryLog(data)
        remote.secretary:nextTaskRunning()
    end

    if not self:checkSecretaryIsComplete() then
        self:luckyDrawSecretaryRequest(1, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QLuckDrawSecretary:checkSecretaryIsComplete()
    -- 普通抽奖
    local silverCount = db:getConfiguration().LUCKY_DRAW_COUNT.value or 0 -- 白银宝箱的次数
    local freeCount = remote.user.todayLuckyDrawFreeCount or 0
    if freeCount < silverCount then
        return false
    else
        return true
    end
end

-- 抽将
function QLuckDrawSecretary:luckyDrawSecretaryRequest(count, success, fail, status)
    local luckyDrawRequest = {isAdvance = false, count = count, isHalf = false, isSecretary = true}
    local request = {api = "LUCKY_DRAW", luckyDrawRequest = luckyDrawRequest}
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("LUCKY_DRAW", request, success, fail)
end

return QLuckDrawSecretary