
local QBaseModel = import("...models.QBaseModel")
local QQuestion = class("QQuestion", QBaseModel)
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QQuestion.EVENT_UPDATE = "EVENT_UPDATE"

function QQuestion:ctor(options)
	QQuestion.super.ctor(self)
end

function QQuestion:didappear()
	QQuestion.super.didappear(self)
end

function QQuestion:disappear()
	QQuestion.super.disappear(self)
end

function QQuestion:loginEnd()
	self:initQuestion(false)
end

function QQuestion:initQuestion(forceRefresh)
	if app.unlock:checkLock("UNION_ANSWER") then
		if self:checkTime() then
			if not self._question or forceRefresh then
				self:consortiaGetQuestionInfoRequest()
			end
		end
	else
		self:setQuestion()
	end
end

function QQuestion:getQuestion()
	return self._question
end

function QQuestion:setQuestion(question)
	self._question = question
	self:dispatchEvent({name = QQuestion.EVENT_UPDATE})
end

--检查答题时间
function QQuestion:checkTime()
	local time = q.serverTime()
	local date = q.date("*t", time)
	local hour = date.hour
	if hour >= 0 and hour < 24 then
		return true
	else
		return false
	end
end

--是否可以答题
function QQuestion:checkCanQuestion()
	if self:checkTime() == false then return false end
	if self._question == nil then return false end
	if self._question.answerCount >= #self._question.puzzleIdList then
		return false
	end
	return true
end

--------------------------proto part-------------------------------
--请求获取答题信息新
function QQuestion:consortiaGetQuestionInfoRequest(success, fail)
    local request = {api = "CONSORTIA_GET_QUESTION_INFO"}
    app:getClient():requestPackageHandler("CONSORTIA_GET_QUESTION_INFO", request, function (response)
        self:consortiaGetQuestionInfoResponse(response, success, nil, true)
    end, function (response)
        self:consortiaGetQuestionInfoResponse(response, nil, fail)
    end)
end

function QQuestion:consortiaGetQuestionInfoResponse(data, success, fail, succeeded)
	if data.consortiaGetQuestionInfoResponse ~= nil then
		self:setQuestion(data.consortiaGetQuestionInfoResponse.userQuestionInfo or {})
	end
    self:responseHandler(data,success,fail, succeeded)
end


--宗门答题新
function QQuestion:consortiaSolveQuestionRequest(subjectId, index, success, fail)
	local consortiaSolveQuestionRequest = {subjectId = subjectId, index = index}
    local request = {api = "CONSORTIA_SOLVE_QUESTION", consortiaSolveQuestionRequest = consortiaSolveQuestionRequest}
    app:getClient():requestPackageHandler("CONSORTIA_SOLVE_QUESTION", request, function (response)
        self:consortiaSolveQuestionResponse(response, success, nil, true)
    end, function (response)
        self:consortiaSolveQuestionResponse(response, nil, fail)
    end)
end

--宗门答题新接口
function QQuestion:consortiaSolveQuestionResponse(data, success, fail, succeeded)
	if data.consortiaSolveQuestionResponse ~= nil then
		self:setQuestion(data.consortiaSolveQuestionResponse.userQuestionInfo or {})
	end
    self:responseHandler(data,success,fail, succeeded)
end

function QQuestion:checkQuestionRedTip()
	if not app.unlock:checkLock("UNION_ANSWER") then
		return false
	end
	local maxCount = db:getConfiguration().everyday_answer_num.value
	local answerCount = maxCount
	if self._question then
		answerCount = self._question.answerCount
	end
	if maxCount and answerCount and maxCount > answerCount then
		return true
	end
	return false
end

function QQuestion:getFullCorrectCount()
	if self._question then
		return self._question.fullCorrectCount
	else
		return 0
	end
end

function QQuestion:getTotalCorrectCount()
	if self._question then
		return self._question.totalCorrectCount
	else
		return 0 
	end
end

return QQuestion