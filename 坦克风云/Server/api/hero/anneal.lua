-- 将领试炼
function api_hero_anneal(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('heroAnneal') == 0 then
        response.ret = -11000
        return response
    end
    
    local weeTs = getWeeTs()
    local ts = getClientTs()
    local cfg = getConfig("heroAnnealCfg")

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "hero"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')

    local self = {}
    -- 刷新任务
    function self.refreshTask()
        if type(mHero.anneal.s) ~= 'table' then
            mHero.anneal.s = { ts=0, fcnt=0, gemcnt=0 }
        end

        -- 有任务了（任务没完成，还没过期 ,今天任务已经完成）
        if type(mHero.anneal.t) == 'table' and ((mHero.anneal.t.expireTs > ts and mHero.anneal.t.stat ~= 2) 
            or mHero.anneal.t.ts >= weeTs) then
            return false, -10019
        end

        if mHero.anneal.s.ts < weeTs then
            mHero.anneal.s.ts = weeTs
            mHero.anneal.s.fcnt = 0
            mHero.anneal.s.gemcnt = 0
        else
            if not self.consumefly() and not self.consumeGems() then
                return false, -10018
            end
        end

        mHero.anneal.t = nil --清空任务数据
        return true, mHero.refreshAnnealList()
    end

    -- 接受任务
    function self.accepetTask(tid)
        if type(mHero.anneal.t) ~= 'table' then
            mHero.anneal.t = {ts=0, stat=0}
        end

        -- 今天已经有任务了
        if mHero.anneal.t.ts >= weeTs then
            return false, -10017
        end
        -- 任务id不正确
        if type(mHero.anneal.l) ~= 'table' or not mHero.anneal.l[tid] then
            return false, -10012
        end

        -- 刷新任务坐标点
        local mAnneal = loadModel("model.heroanneal", {uid=uid,tid=tid})
        local ret = mAnneal.refreshAnneal()
        if type(ret) ~= 'table'  then
            return false
        end

        -- 任务详情
        mHero.anneal.t.ts = weeTs --接受时间
        mHero.anneal.t.stat = 1 -- 状态 - 0 未刷新；1 已经刷新；2 已经完成；
        mHero.anneal.t.task = mHero.anneal.l[tid] -- 任务
        mHero.anneal.t.x = ret[1] -- 任务坐标x
        mHero.anneal.t.y = ret[2] -- 任务坐标y
        mHero.anneal.t.expireTs = ret[3] -- 任务过期时间
        mHero.anneal.t.hp = ret[4] -- 当前血量
        mHero.anneal.t.maxHp = ret[5] -- 最大血量
        mHero.anneal.t.lv = ret[6] -- 任务等级
        mHero.anneal.t.r = {0,0,0} --领奖信息

        mHero.anneal.l = nil --清空列表
        return true
    end

    -- 任务完成将领
    function self.getTaskReward(nType)
        -- 已领
        if type(mHero.anneal.t.r) ~= 'table' then
            mHero.anneal.r = {0,0,0}
        end

        if mHero.anneal.t and mHero.anneal.t.stat ~= 2 then
            return false, -10015
        end

        if mHero.anneal.t.r[nType] and mHero.anneal.t.r[nType] == 1 then
            return false, -10014
        end

        local rewardpool = nil
        local quality = string.split(mHero.anneal.t.task, "_")
        local useGems = cfg.boxCost[nType]
        if nType == 1 then
            rewardpool = cfg.box[nType][tonumber(quality[2])]
        else
            rewardpool = cfg.box[nType]
            -- 消耗钻石
            if not mUserinfo.useGem(useGems) then
                return false, -109
            end
            
        end

        local tmpreward = getRewardByPool(rewardpool)
        local heroCfg = getConfig('heroCfg')
        local sid = nil
        for k, v in pairs(heroCfg.soulToHero) do
            if v == quality[1] then
                sid = k
                break
            end
        end
        if not sid then --没找到对应的英魂
            return false, -10016
        end
        local reward = {}
        for k, v in pairs(tmpreward) do
            if k == "hero" then --组装对应的英魂
                reward["hero_" .. sid] = v
            else
                reward[k] = v
            end
        end

        if not next(reward) then
            print('error reward empty !')
            return false, -403
        end

        if not takeReward(uid, reward) then
            return false, -403
        end

        -- 日志
        if useGems > 0 then
            regActionLogs(uid,1,{action=142,item=nType,value=useGems,params={reward=reward}})
        end
        mHero.anneal.t.r[nType] = 1

        return true, reward
    end

    function self.consumefly()
        local fCost = nil
        -- 优先消耗友善值
        if #cfg.friendlyCost <= mHero.anneal.s.fcnt then
            fCost = cfg.friendlyCost[#cfg.friendlyCost] 
        else
            fCost = cfg.friendlyCost[mHero.anneal.s.fcnt+1]
        end

        mHero.anneal.fly = tonumber(mHero.anneal.fly) or 0
        if mHero.anneal.fly < fCost then
            return false
        end

        mHero.anneal.fly = mHero.anneal.fly - fCost
        mHero.anneal.s.fcnt = mHero.anneal.s.fcnt + 1
        return true
    end

    function self.consumeGems()
        local gemCost = nil
        if #cfg.goldCost <= mHero.anneal.s.gemcnt then
            gemCost = cfg.goldCost[#cfg.goldCost]
        else
            gemCost = cfg.goldCost[mHero.anneal.s.gemcnt + 1]
        end

        if not mUserinfo.useGem( gemCost ) then
            return false
        end

        mHero.anneal.s.gemcnt = mHero.anneal.s.gemcnt + 1
        regActionLogs(uid,1,{action=142,item='refreshTask',value=gemCost,params={gemcnt=mHero.anneal.s.gemcnt}})
        return true
    end

    -----------main-----------------------
    local action = request.params.action or 0
    local nType = request.params.type or 0 
    local ret, code = nil, nil

    if action == 0 then
        ret, code = self.refreshTask(nType)
    elseif action == 1 then
        ret, code = self.accepetTask(nType)
    elseif action == 2 then
        ret, code = self.getTaskReward(nType)
        --日常任务
        local mDailyTask = uobjs.getModel('dailytask')
        mDailyTask.changeTaskNum1('s1018')
    elseif action == 3 then -- 任务初始化数据
        response.ret = 0        
        response.msg = 'Success'
        response.data.hero = {anneal = mHero.anneal}        
        response.data.annealog = mHero.getAnnealLog()
        return response
    elseif action == 4 then -- 指定玩家的任务信息
        local tarUid = tonumber(nType)
        if tarUid then
            local taruobjs = getUserObjs(tarUid)
            local tarHero = taruobjs.getModel("hero")
            response.ret = 0        
            response.msg = 'Success'
            response.data.anneal = tarHero.anneal.t or {}
            return response            
        end
    end

    if not ret then
        response.ret = code or -1
        return response
    end

    if uobjs.save() then 
        if action == 2 then
            response.data.reward = formatReward(code)
        end
        response.data.hero = {anneal = mHero.anneal}
        response.ret = 0        
        response.msg = 'Success'
    end

    return response

end