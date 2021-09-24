--
-- desc:问卷调查
-- user:chenyunhe
--
local function api_admin_questions(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

    function self.action_set(request)
        local response = self.response
        local ts = getClientTs()
        local questions = request.params

        if type(questions) ~= 'table' or not questions.qid or tonumber(questions.time)<=0 then
            response.ret = -102
            return response
        end

        local URL = require "lib.url"
        questions.title = URL:url_unescape(questions.title)
        questions.content = json.decode(URL:url_unescape(questions.content))

        questions.st = tonumber(questions.st)
        questions.time = tonumber(questions.time)
        questions.qid = tonumber(questions.qid)
        questions.et = questions.st + questions.time
     
        if type(questions.gift)~='table' or not next(questions.gift) then 
            questions.gift = {}
        end
        if type(questions.content)~='table' or not next(questions.content) then
            response.ret = -102 
            return response
        end

        require "model.questions"
        local mQuestion = model_questions()
        local ret = false
        local getCfg = mQuestion.getByid(questions.qid)

        if type(getCfg)=='table' and next(getCfg) then
            ret = mQuestion.set(questions.qid,questions)
        else
            ret = mQuestion.create(questions)
        end

        if ret then    
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -1
            response.msg = 'Fail'
        end

        return response
    end 

    function self.action_statistics(request)
        local response = self.response
        local qid = request.params.qid

        if not qid then
            response.ret = -102
            return response
        end
        require "model.questions"
        local mQuestion = model_questions()
        local getCfg = mQuestion.getByid(qid)

        if type(getCfg)~='table' or not next(getCfg) then
           response.ret = -120
           return response
        end

        local s = mQuestion.getstatistics(qid)
        response.data.statistics = s
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    return self  
end

return api_admin_questions