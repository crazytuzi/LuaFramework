-- @Author: liaoxianbo
-- @Date:   2020-06-04 14:28:00
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-09 18:08:00

local QBaseSecretary = import(".QBaseSecretary")
local QSotoTeamWorshipSecretary = class("QSotoTeamWorshipSecretary", QBaseSecretary)

function QSotoTeamWorshipSecretary:ctor(options)
	QSotoTeamWorshipSecretary.super.ctor(self, options)
end

function QSotoTeamWorshipSecretary:executeSecretary()
	local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
	if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
		remote.secretary:nextTaskRunning()
		return
	end
			
    remote.sotoTeam:sotoTeamWarInfoRequest(function()
	    local worships = remote.sotoTeam:getSotoTeamWorship()
	    local posIds = {}
	    for i, v in pairs(worships) do
	        local isFans = remote.sotoTeam:checkTodayWorshipByPos(v.pos)
	        if not isFans then
	            table.insert(posIds, v.pos) 
	        end
	    end

	    local callback = function(data)        
	        remote.secretary:updateSecretaryLog(data) 
	        remote.secretary:nextTaskRunning()
	    end
	    if #posIds > 0 then
	        self:sotoTeamWorshipSecretaryRequest(posIds, callback)
	    else
	        remote.secretary:nextTaskRunning()
	    end
	end, function()
        remote.secretary:nextTaskRunning()
	end)
end

-- 云顶一键膜拜
function QSotoTeamWorshipSecretary:sotoTeamWorshipSecretaryRequest(posIds, success)
    local sotoTeamWorshipRequest = {posIds = posIds, isSecretaryGet = true}
    local request = {api = "SOTO_TEAM_WORSHIP", sotoTeamWorshipRequest = sotoTeamWorshipRequest}
    app:getClient():requestPackageHandler("SOTO_TEAM_WORSHIP", request, success, fail)
end

return QSotoTeamWorshipSecretary