-- @Author: xurui
-- @Date:   2019-08-07 15:19:18
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-08 15:09:18
local QBaseSecretary = import(".QBaseSecretary")
local QEnchantBoxSecretary = class("QEnchantBoxSecretary", QBaseSecretary)

function QEnchantBoxSecretary:ctor(options)
	QEnchantBoxSecretary.super.ctor(self, options)
end

-- 免费觉醒宝箱
function QEnchantBoxSecretary:executeSecretary()
    local callback = function(data)  
        remote.secretary:updateSecretaryLog(data) 

        remote.secretary:nextTaskRunning()
    end

    if not self:checkSecretaryIsComplete() then
        self:luckyDrawEnchantSecretaryRequest(false, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QEnchantBoxSecretary:checkSecretaryIsComplete()
    local isFree = remote.user.enchantIsFree
    return not isFree
end

function QEnchantBoxSecretary:luckyDrawEnchantSecretaryRequest(is10Times, success, fail, status)
    local luckyDrawEnchantRequest = {is10Times = is10Times, isSecretary = true}
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    local request = {api = "LUCKY_DRAW_ENCHANT", luckyDrawEnchantRequest = luckyDrawEnchantRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_ENCHANT", request, success, fail)
end

return QEnchantBoxSecretary