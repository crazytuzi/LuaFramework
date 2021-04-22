-- @Author: xurui
-- @Date:   2019-08-07 15:20:00
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-31 12:08:33
local QBaseSecretary = import(".QBaseSecretary")
local QMountBoxSecretary = class("QMountBoxSecretary", QBaseSecretary)

function QMountBoxSecretary:ctor(options)
	QMountBoxSecretary.super.ctor(self, options)
end

-- 免费暗器宝箱
function QMountBoxSecretary:executeSecretary()
    local callback = function(data)  
        remote.secretary:updateSecretaryLog(data)
        remote.mount:responseHandler(data)

        remote.secretary:nextTaskRunning()
    end

    local isFree = remote.user.mountIsFree
    if isFree then
        self:mountSummonSecretaryRequest(isFree, false, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QMountBoxSecretary:checkSecretaryIsComplete()
    local isFree = remote.user.mountIsFree
    return not isFree
end

--请求暗器召唤
function QMountBoxSecretary:mountSummonSecretaryRequest(isFree, isTen, success, fail, succeeded)
    local zuoqiSummonRequest = {isFree = isFree, isTen = isTen, isSecretary = true}
    local request = {api = "ZUOQI_SUMMON", zuoqiSummonRequest = zuoqiSummonRequest}
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("ZUOQI_SUMMON", request, success,fail)
end

return QMountBoxSecretary