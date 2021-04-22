-- @Author: xurui
-- @Date:   2019-08-07 15:18:55
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-08 15:06:19
local QBaseSecretary = import(".QBaseSecretary")
local QBuyMoneySecretary = class("QBuyMoneySecretary", QBaseSecretary)

function QBuyMoneySecretary:ctor(options)
	QBuyMoneySecretary.super.ctor(self, options)
end

function QBuyMoneySecretary:executeSecretary()
    local callback = function(data)   
        if data.secretaryItemsLogResponse then    
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1])
            remote.user:addPropNumForKey("addupBuyMoneyCount", count)
            remote.activity:updateLocalDataByType(504, count)
            remote.user:update({todayMoneyBuyLastTime = q.serverTime()})
        end
        remote.secretary:updateSecretaryLog(data) 
        remote.secretary:nextTaskRunning()
    end

    if not self:checkSecretaryIsComplete() then
        self:buyMoneySecretaryRequest(1, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QBuyMoneySecretary:checkSecretaryIsComplete()
    local buyCount = remote.user.todayMoneyBuyCount or 0
    local count = 0
    while true do
        buyCount = buyCount + 1
        local config = db:getTokenConsume(ITEM_TYPE.MONEY, buyCount)
        if config ~= nil and config.money_num > 0 then
            break
        end
        count = count + 1
    end
    return count <= 0
end

function QBuyMoneySecretary:buyMoneySecretaryRequest(count, success, fail, status)
    local buyMoneyRequest = {count = count, isSecretary = true}
    local request = {api = "BUY_MONEY", buyMoneyRequest = buyMoneyRequest}
    fail = function(data)
        remote.secretary:executeInterruption()
    end
    
    app:getClient():requestPackageHandler("BUY_MONEY", request, success, fail, true, true)
end

return QBuyMoneySecretary