local function api_dailytask_reward()
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
    }
    
    function self.getRules()
        return {
            -- required 表示参数是必需的,必需放在table的第1位
            -- _uid 表示取request.uid 而不是request.params.uid
            ["*"] = {
                _uid = { "required" }
            },
        }
    end
    
    function self.before(request)
    end

    -- 积分奖励
    function self.action_point(request)
        local response = self.response
        local tid = request.params.tid
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mDailytask = uobjs.getModel('dailytask')
        local taskConfig = getConfig('dailyTask2')

        -- 点数达不到要求
        if not taskConfig.finalTask[tid] or mDailytask.info.c < taskConfig.finalTask[tid].condition then
            response.ret = -1981
            return response
        end

        if not mDailytask.info.r1 then
            mDailytask.info.r1 = {}
        end

        -- 已经领取
        if table.contains(mDailytask.info.r1,tid) then
            response.ret = -1976
            return response
        end

        table.insert(mDailytask.info.r1,tid)

        if not takeReward(uid,taskConfig.finalTask[tid].award) then
            response.ret = -1989
            return response
        end

        processEventsBeforeSave()
        
        if uobjs.save() then
            processEventsAfterSave()
            response.data.dailytask = mDailytask.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 任务奖励
    function self.action_task(request)
        local response = self.response
        local tid = request.params.tid
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mDailytask = uobjs.getModel('dailytask')
        local mUserinfo = uobjs.getModel('userinfo')
        local taskConfig = getConfig('dailyTask2')

        -- 点数达不到要求
        if not taskConfig.task[tid] or not mDailytask.info.t[tid] or mDailytask.info.t[tid] < taskConfig.task[tid].condition then
            -- 科技和建筑可能全部满级了,直接发奖(后端这里没有做是否满级的检测)
            if tid ~= "s1002" and tid ~= "s1003" and tid ~= "s1005" and tid ~= "s1012" then
                response.ret = -1981
                return response
            end
        end

        if not mDailytask.info.r1 then
            mDailytask.info.r1 = {}
        end

        -- 已经领取
        if table.contains(mDailytask.info.r1,tid) then
            response.ret = -1976
            return response
        end

        table.insert(mDailytask.info.r1,tid)
        mDailytask.addActivePoint(taskConfig.task[tid].point)

        if taskConfig.task[tid].award2 and not takeReward(uid,taskConfig.task[tid].award2) then
            response.ret = -1989
            return response
        end

        local resourceAward = copyTable(taskConfig.task[tid].award1)
        for k,v in pairs(resourceAward) do
            if k == "userinfo_exp" then
                resourceAward[k] = math.floor(taskConfig.exp[mUserinfo.level] * v)
            else
                resourceAward[k] = math.floor(taskConfig.resource[mUserinfo.level] * v)
            end
        end

        if not takeReward(uid,resourceAward) then
            response.ret = -1989
            return response
        end

        -- 军团资金
        if taskConfig.task[tid].raising and mUserinfo.alliance>0  then
            local execRet,code = M_alliance.addacpoint{uid=uid,aid=mUserinfo.alliance,point=taskConfig.task[tid].raising,method=1,ts=getWeeTs()}
                response.data.rais = execRet and 1 or 0
        end
        --感恩节2017

        local thanksgiving = activity_setopt(uid,'thanksgiving',{act=9,num=1,w=1})  
        if type(thanksgiving)=='table' and next(thanksgiving) then
            local acaward = {}
            for k,v in pairs(thanksgiving) do
                acaward[k]= (acaward[k] or 0) + v
            end
            response.data.thank=acaward
        end

        -- 跨年福袋
        activity_setopt(uid,'luckybag',{act=1,n=1})   
        -- 合服大战
        activity_setopt(uid,'hfdz',{act='rr',num=1})

        processEventsBeforeSave()
        
        if uobjs.save() then
            processEventsAfterSave()
            response.data.dailytask = mDailytask.toArray(true)
            response.data.userinfo = mUserinfo.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    return self
end

return api_dailytask_reward
