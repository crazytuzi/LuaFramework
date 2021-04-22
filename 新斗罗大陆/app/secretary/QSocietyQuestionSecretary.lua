-- @Author: DELL
-- @Date:   2020-04-20 18:59:14
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-23 19:28:21
local QBaseSecretary = import(".QBaseSecretary")
local QSocietyQuestionSecretary = class("QSocietyQuestionSecretary", QBaseSecretary)

function QSocietyQuestionSecretary:ctor(options)
	QSocietyQuestionSecretary.super.ctor(self, options)
end

function QSocietyQuestionSecretary:convertSecretaryAwards( itemLog, logNum,info )
	QSocietyQuestionSecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local taskId = itemLog.taskType
    local dataProxy = remote.secretary:getSecretaryDataProxyById(itemLog.taskType)

    local secrataryConfig = remote.secretary:getSecretaryConfigById(taskId)

    local describe = nil
    -- 是否有多条日志
    if logNum and secrataryConfig.describe_split then
        local describeSplit = string.split(secrataryConfig.describe_split, ";")
        describe = describeSplit[logNum]
    end
    if not describe then
        describe = secrataryConfig.describe
    end

    local contents = string.split(describe, "#")
    local countTbl = string.split(itemLog.param, ";")
    local num = (logNum and logNum > 1 ) and logNum or 1
    local title2 = ""
    for i, v in pairs(contents) do
        local str = v
        if str == "name" then
            local idCount = tonumber(countTbl[num]) or 0
            if dataProxy then
        		str = dataProxy:getNameStr(taskId, idCount, logNum)
        	else
        		str = idCount
    		end
        end
        if str then
        	title2 = title2..str
        end
    end

    info.title2 = title2
end

function QSocietyQuestionSecretary:checkSecretaryIsNotActive()
    if remote.union:checkHaveUnion() == false then
        return true, "尚未加入宗门"
    end
    
	if app.unlock:checkLock("UNION_ANSWER") == false then
		local unlockLevel = app.unlock:getConfigByKey("UNION_ANSWER").sociaty_level
		return true, "宗门等级"..unlockLevel.."级开启"
	end

	local questionInfo = remote.question:getQuestion()
	if q.isEmpty(questionInfo) == false then
		if questionInfo.hasTakenFinalReward then
			return true,"今日答题已答完，请改日再来"
		end
	end	

	if not remote.question:checkTime() then
		return true, "答题时间已过"
	end	
	
    return false
end

function QSocietyQuestionSecretary:executeSecretary()

    local isNotQuestion,str = self:checkSecretaryIsNotActive()
    if not isNotQuestion then
        local callback = function(data)
    		local response = data.consortiaSolveQuestionResponse
    		local multipleCount = 1
    		if response and response.userQuestionInfo then
                remote.question:setQuestion(response.userQuestionInfo or {})
    			local correctCount = response.userQuestionInfo.correctCount or 0
    			multipleCount = response.multiple or 1
    			local awards = response.awardStr or ""
    			app.taskEvent:updateTaskEventProgress(app.taskEvent.UNION_QUESTION_EVENT, correctCount, false, true)
                remote.user:dispatchEvent({name = remote.user.EVENT_USER_PROP_CHANGE})
    		end
    		if multipleCount > 1 then
    			remote.secretary:updateSecretaryLog(data,2) 
    		else
            	remote.secretary:updateSecretaryLog(data,1) 
            end
            remote.secretary:nextTaskRunning()
        end

    	self:consortiaSolveQuestionRequest(callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

-- 竞技场一键膜拜
function QSocietyQuestionSecretary:consortiaSolveQuestionRequest(success)
    local request = {api = "CONSORTIA_SOLVE_QUESTION"}
    app:getClient():requestPackageHandler("CONSORTIA_SOLVE_QUESTION", request, success, fail)
end

return QSocietyQuestionSecretary
