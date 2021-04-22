-- @Author: xurui
-- @Date:   2019-08-07 15:48:10
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-08 17:27:23
local QBaseSecretary = import(".QBaseSecretary")
local QArenaWorshipSecretary = class("QArenaWorshipSecretary", QBaseSecretary)

function QArenaWorshipSecretary:ctor(options)
	QArenaWorshipSecretary.super.ctor(self, options)
end

-- 竞技场膜拜
function QArenaWorshipSecretary:executeSecretary()
    local callback = function(data)
        if data.secretaryItemsLogResponse then
            local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
            local count = tonumber(countTbl[1])
            remote.user:addPropNumForKey("todayArenaWorshipCount", count)
            remote.activity:updateLocalDataByType(708, count)
        end
        if data.arenaWorshipResponse then
            remote.user:update({money = data.arenaWorshipResponse.money})
            app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_WORSHIP_EVENT, 1)
        end
        remote.secretary:updateSecretaryLog(data) 
        remote.secretary:nextTaskRunning()
    end

    local secretaryInfo = remote.secretary:getSecretaryInfo()
    local arenaInfo = secretaryInfo.arenaSecretary or {}
    local worshipCount = arenaInfo.worshipCount or 0
    if worshipCount < 10 then
        self:arenaWorshipSecretaryRequest(callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

-- 竞技场一键膜拜
function QArenaWorshipSecretary:arenaWorshipSecretaryRequest(success)
    local request = {api = "ARENA_WORSHIP_SECRETARY"}
    local fail = function(data)
        remote.secretary:executeInterruption()
    end    
    app:getClient():requestPackageHandler("ARENA_WORSHIP_SECRETARY", request, success, fail)
end

return QArenaWorshipSecretary
