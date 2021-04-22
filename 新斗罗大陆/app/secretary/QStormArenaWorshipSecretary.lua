-- @Author: xurui
-- @Date:   2019-08-07 15:48:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-12 17:56:49
local QBaseSecretary = import(".QBaseSecretary")
local QStormArenaWorshipSecretary = class("QStormArenaWorshipSecretary", QBaseSecretary)

function QStormArenaWorshipSecretary:ctor(options)
	QStormArenaWorshipSecretary.super.ctor(self, options)
end

function QStormArenaWorshipSecretary:executeSecretary()
    remote.stormArena:requestStormArenaInfo(false, function()
	    local worships = remote.stormArena:getStormArenaWorship()
	    local posIds = {}
	    for i, v in pairs(worships) do
	        local isFans = remote.stormArena:stormArenaTodayWorshipByPos(v.pos)
	        if not isFans then
	            local posId = {}
	            posId.userId = v.userId
	            posId.pos = v.pos - 1
	            table.insert(posIds, posId) 
	        end
	    end

	    local callback = function(data)
	        app.taskEvent:updateTaskEventProgress(app.taskEvent.STORM_ARENA_WORSHIP_EVENT, #posIds, false, true)
	        
	        remote.secretary:updateSecretaryLog(data) 
	        remote.secretary:nextTaskRunning()
	    end
	    
	    if #posIds > 0 then
	        self:stormArenaWorshipSecretaryRequest(posIds, callback)
	    else
	        remote.secretary:nextTaskRunning()
	    end
	end, function()
        remote.secretary:nextTaskRunning()
	end)
end

-- 索坨斗魂场一键膜拜
function QStormArenaWorshipSecretary:stormArenaWorshipSecretaryRequest(posIds, success)
    local stormWorshipRequest = {userId = 0, pos = 0, posIds = posIds, isSecretaryGet = true}
    local request = {api = "STORM_WORSHIP", stormWorshipRequest = stormWorshipRequest}
    local fail = function(data)
        remote.secretary:executeInterruption()
    end
    app:getClient():requestPackageHandler("STORM_WORSHIP", request, success, fail)
end

return QStormArenaWorshipSecretary
