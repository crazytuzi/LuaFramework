-- 累计消费活动
-- @params action  1.获取排行榜信息 2.领取档次奖励 3.领取排行榜奖励
-- @params tid 领取的档次奖励id
-- @params sid 玩家选择的多选奖励
function api_active_leijixiaofei(request)
    local response = {
        ret     = -1,
        msg     = 'error',
        data    = {},
    }

    local uid       = request.uid
    local action    = tonumber(request.params.action) or 0
    local aname     = 'leijixiaofei'

    if not uid or not action then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero','friends'})
    local mUseractive   = uobjs.getModel('useractive')
    local mUserinfo     = uobjs.getModel('userinfo')
    local mTroop        = uobjs.getModel('troops')
    local mHero        = uobjs.getModel('hero')
    
    local rewardTs = true
    if 0 ~= action and 2 ~= action then
        rewardTs = false
    end
    local activStatus   = mUseractive.getActiveStatus(aname, rewardTs)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts        = getClientTs()
    local weeTs     = getWeeTs()
    setRandSeed()

    -- 活动数据
    local actinfo   = mUseractive.info[aname]
    local actCfg    = mUseractive.getActiveConfig(aname)
    
    -- 检查活动是否初始化或者隔天刷新数据
    local function checkActive()
        local needInit = false
        -- 判断是否需要初始化
        if not actinfo or type(actinfo) ~= 'table' or 0 == actinfo.c then
            needInit = true
        end

        -- 初始化
        if needInit then
            actinfo.rn      = 0 -- 总消费值
            actinfo.rk      = 0 -- 排行榜奖励是否领取
            actinfo.r       = {} -- 普通档次奖励领取信息
            actinfo.c       = 1
        end

        -- 重新设定活动数据
        mUseractive.info[aname] = actinfo
        return true
    end
    
    -- 获取排行榜数据
    local function getRank(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        local ranklist = getActiveRanking(aname, actinfo.st)
        local list={}
        local selfRank = -1
        if type(ranklist) == 'table' and next(ranklist) then
            local i = 1
            for _,v in pairs(ranklist) do
                local mid = tonumber(v[1])
                if mid ~= uid then
                    local muobjs = getUserObjs(mid, true)
                    muobjs.load({"userinfo"})
                    local tmUserinfo = muobjs.getModel('userinfo')
                    table.insert(list, {mid, tmUserinfo.nickname, v[2], i})
                else
                    selfRank = i
                    table.insert(list, {uid, mUserinfo.nickname, v[2], i})
                end
                i = i+1
            end
        end
        
        response.data.rank = selfRank
        response.data.ranklist = list
        return true
    end
    
    -- 领取档次奖励
    local function reward(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        local tid = tonumber(request.params.tid) or 1
        local sid = tonumber(request.params.sid) or 1
        
        -- 参数不对
        if tid < 0 or tid > # actCfg.cost or sid < 0 then
            response.ret = -102
            return false
        end

        -- 是否已经领取
        if actinfo.r[tostring(tid)] and 1 <= actinfo.r[tostring(tid)] then
            response.ret = -102
            return false
        end
        
        local cost = actCfg.cost[tid]
        -- 不满足领取条件
        if not tonumber(cost) or tonumber(cost) > actinfo.rn then
            response.ret = -102
            return false
        end
        
        -- 选择的奖励存在
        local rewards = {}
        local chooseRwd = actCfg.serverReward.r1[tid][sid]
        local rwd = actCfg.serverReward.r2[tid]
        if not chooseRwd then
            response.ret = -102
            return false
        end
        
        for k,v in pairs(chooseRwd) do
            rewards[k] = rewards[k] or 0
            rewards[k] = rewards[k] + v
        end
        
        for k,v in pairs(rwd) do
            rewards[k] = rewards[k] or 0
            rewards[k] = rewards[k] + v
        end
        
        -- 发放奖励
        if not takeReward(uid, rewards) then
            response.ret = -403
            return response
        end
        
        actinfo.r[tostring(tid)] = sid
        response.data.reward = formatReward(rewards)
        -- response.data.userinfo = mUserinfo.toArray(true)
        
        return true
    end
    
    -- 领取排行榜奖励
    local function rankReward(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        -- local rank = tonumber(request.params.rank) or 0
        local myrank = -1
        local flag = actinfo.rk or 0
        
        -- 已经领取奖励
        if flag >= 1 then
            response.ret = -1976
            return false
        end
        
        -- 时间已过
        if ts < tonumber(mUseractive.getAcet(aname, true)) then
            response.ret =-1978
            return response
        end
        
        -- 获取排名
        local ranklist = getActiveRanking(aname, actinfo.st)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                if mid == uid then
                    myrank = k
                end
            end
        end
        -- if myrank ~= rank then
        --     response.ret = -102
        --     return response
        -- end
        
        local rankreward = {}
        local rankRwd = actCfg.rankReward
        for _,v in pairs(rankRwd) do
            if  myrank <= v.range[2] then
                rankreward = v.serverReward
                break
            end
        end
        -- 发放奖励
        if not takeReward(uid, rankreward) then
            response.ret = -403
            return response
        end
        
        actinfo.rk = 1
        response.data.reward = formatReward(rankreward)
        -- response.data.userinfo = mUserinfo.toArray(true)
        
        return true
    end
    
    -- 操作处理器
    local actionFunc = {
        ['0'] = checkActive, -- 检查活动是否初始化或者隔天刷新数据
        ['1'] = getRank, -- 获取排行榜数据
        ['2'] = reward, -- 领取档次奖励
        ['3'] = rankReward, -- 领取排行榜奖励
    }

    -- 根据action 调用不同的操作函数
    local flag = actionFunc[tostring(action)](true)

    processEventsBeforeSave()

    -- 数据返回
    if flag and uobjs.save() then
        response.data[aname] = mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
