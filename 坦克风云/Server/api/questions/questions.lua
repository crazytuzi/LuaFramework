--
-- desc:问卷调查
-- user:chenyunhe
--
local function api_questions_questions(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

    function self.action_get(request)
        local response = self.response
        local qid = tonumber(request.params.qid)
        local uid = request.uid

        if not uid or not qid or qid<=0 then
            response.ret = -102
            return response
        end

        -- 等级判断
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')

        require "model.questions"
        local mQuestion = model_questions()

        local info = {}
        info = mQuestion.getByid(qid)

        if next(info) then
            if mUserinfo.level< tonumber(info.level) then
                response.ret = -102
                return response
            end

            info.content = json.decode(info.content)
            info.gift = formatReward(json.decode(info.gift))
        end

        response.data.info = info or {}
        response.ret = 0
        response.msg = 'Success'
      
        return response
    end 

    -- 未填写的问卷列表(只包含标题)
    function self.action_list(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')

        -- 等级判断 跟客户端都通过 给注释了
        -- local quesLevel = getConfig('player.quesLevel') or 0
        -- if quesLevel>mUserinfo.level then
        --     response.ret = -301
        --     return response
        -- end

        require "model.questions"
        local mQuestion = model_questions()
 
        response.data.list = mQuestion.list(uid) or {}
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 提交
    function self.action_sub(request)
        local response = self.response
        local uid = request.uid
        local qid = tonumber(request.params.qid)
        local ans = request.params.ans 
        if not uid or not qid or type(ans)~='table' or not next(ans) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')

        require "model.questions"
        local mQuestion = model_questions()

        if mQuestion.check(uid,qid) then
            response.ret = -29010
            return response
        end

        local cfg = mQuestion.getByid(qid)
        if type(cfg)~='table' then
            response.ret = -102
            return response
        end

        if mUserinfo.level<tonumber(cfg.level) then
            response.ret = -102
            return response
        end

        local params = {}
        params.uid=uid
        params.qid = qid
        params.answers = json.encode(ans)
        if mQuestion.sub(uid,qid,params) then         
            local gift =json.decode(cfg.gift)
            if type(gift)=='table' and next(gift) then
                if not takeReward(uid,gift) then
                    writeLog('reward:uid='..uid..'qid='..qid,'questions_error')
                end
                uobjs.save()
                response.data.reward = formatReward(gift)
            end

            -- 更新问题表  用来统计的
            mQuestion.statistics(qid,ans,uid)

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end
        response.ret = 0
        response.msg = 'Success'
        
        return response
    end

    return self  
end

return api_questions_questions