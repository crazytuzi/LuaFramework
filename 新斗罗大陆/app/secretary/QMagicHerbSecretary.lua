-- @Author: xurui
-- @Date:   2019-08-07 15:20:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-08 15:14:17
local QBaseSecretary = import(".QBaseSecretary")
local QMagicHerbSecretary = class("QMagicHerbSecretary", QBaseSecretary)

function QMagicHerbSecretary:ctor(options)
	QMagicHerbSecretary.super.ctor(self, options)
end

-- 免费仙品宝箱
function QMagicHerbSecretary:executeSecretary()
    local callback = function(data)  
        remote.secretary:updateSecretaryLog(data) 

        remote.secretary:nextTaskRunning()
    end

    if not self:checkSecretaryIsComplete() then
        self:magicHerbSummonSecretaryRequest(false, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QMagicHerbSecretary:checkSecretaryIsComplete()
    local isFree = remote.user.magicHerbIsFree
    return not isFree
end

--请求仙品召唤
function QMagicHerbSecretary:magicHerbSummonSecretaryRequest(isTen, success, fail, succeeded)
    local magicHerbSummonRequest = {isTen = isTen, isSecretary = true}
    local request = { api = "MAGIC_HERB_SUMMON", magicHerbSummonRequest = magicHerbSummonRequest}
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("MAGIC_HERB_SUMMON", request, success,fail)
end

return QMagicHerbSecretary