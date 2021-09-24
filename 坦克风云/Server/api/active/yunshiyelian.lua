-- 陨石冶炼
function api_active_yunshiyelian(request)
    local response = {
        ret = -1,
        msg = 'error',
        data = {
        },
    }

    local uid = request.uid
    local action = request.params.action
    local aname = request.params.aname or 'yunshiyelian'
    local free  = request.params.free 
    local num   = tonumber(request.params.num) or 1
    local ts = getClientTs()
    local weeTs = getWeeTs()
    if uid == nil or action == nil then
        response.ret = -102
        return response
    end
    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero','alien'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAlien = uobjs.getModel('alien')
    local activStatus = mUseractive.getActiveStatus(aname)
    
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
        
    local lastTs = mUseractive.info[aname].t or 0
    local activeCfg = mUseractive.getActiveConfig(aname)
    if weeTs>lastTs then
        local task = {}
        -- 随机任务
        for _,value in pairs(activeCfg.changedTask) do
            local tmp={value.key, 0}
            table.insert(task,tmp)
        end 
        
        mUseractive.info[aname].tr = task
        mUseractive.info[aname].f = 0
        mUseractive.info[aname].t = weeTs
    end
    local redis = getRedis()
    local redisKey ="z-"..getZoneId()..aname..mUseractive.info[aname].st.."-uid-"..uid
    if action=="rand" then
        local rlog =json.decode(redis:get(redisKey))
        if rlog==nil then
            rlog={}
        end
        if free then
            if mUseractive.info[aname].f>0 then
                response.ret=-102
                return response
            end
            mUseractive.info[aname].f=1
            num=1
        else
            local gems=activeCfg.cost
            if num~=1 then
                num = 10
                gems = activeCfg.cost10
            end

            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            
            -- 陨石冶炼 金币日志
            regActionLogs(uid,1,{action=143,item="",value=gems,params={action=action,num=num}})
        end
        local report={}
        local rwds = {}
        for _=1,num do
            local pool=activeCfg.serverreward.randomPool
            
            local reward= copyTab( getRewardByPool(pool) )
            table.insert(report, formatReward(reward))
             -- 奖励发放
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            
            -- 任务埋点
            for k,v in pairs(reward) do
                rwds[k] = rwds[k] or 0
                rwds[k] = rwds[k] + v
            end
        end 
        
        -- 任务埋点
        local clientF = {}
        for k,v in pairs(rwds) do
            local rwditem = string.split(k, "_")
            if 'r1' == rwditem[2] then
                -- 陨石冶炼
                activity_setopt(uid, 'yunshiyelian', {action="rd", num=v})
            elseif 'r2' == rwditem[2] then
                -- 陨石冶炼
                activity_setopt(uid, 'yunshiyelian', {action="ry", num=v})
            end
            
            table.insert(clientF, formatReward({[k] = v}))
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','yunshiyelian',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
            table.insert(clientF, formatReward(hReward))
        end
    
        --记录一下位置
        table.insert(rlog, 1, {clientF, ts})
        
        -- 删除多余的最近抽奖信息
        local difNum = #rlog - 20
        if difNum > 0 then
            for _=1,difNum do
                table.remove(rlog)
            end
        end
        
        if uobjs.save() then
            response.ret = 0        
            response.msg = 'Success'
            response.data.report = report
            redis:set(redisKey,json.encode(rlog))
            redis:expireat(redisKey,mUseractive.info[aname].et)
            response.data[aname] = mUseractive.info[aname]
            response.data.alien = mAlien.toArray(true)
            response.data[aname].rlog = rlog
             if next(harCReward) then
                response.data[aname].hReward=harCReward
            end                    
        end
    elseif action=="getlog" then
        local rlog = json.decode(redis:get(redisKey))
        if rlog==nil then
                rlog = {}
        end
        response.ret = 0        
        response.msg = 'Success'
        response.data[aname] = {}
        response.data[aname].rlog = rlog
    elseif action=="task" then
        local tid= tonumber(request.params.method) or 1   
        
        -- 任务 不存在
        if mUseractive.info[aname].tr[tid] == nil then
            response.ret = -102
            return response
        end
        
        local taskCfg
        for _,v in pairs(activeCfg.changedTask) do
            if v.key == mUseractive.info[aname].tr[tid][1] then
                taskCfg = v
            end
        end

        -- 任务未完成
        local nnum = mUseractive.info[aname].tr[tid][2] or 0
        if taskCfg.needNum > nnum then
            response.ret = -1981
            return response
        end

        -- 获取奖励
        local reward = taskCfg.serverreward
        -- 发放奖励
        if not takeReward(uid, reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[aname].tr[tid][2] = -1
        response.data.reward = formatReward(reward)
        
        if uobjs.save() then
            response.ret = 0        
            response.msg = 'Success'            
            response.data.alien = mAlien.toArray(true)
            response.data[aname] = mUseractive.info[aname]
        end

    end

    return response
end
