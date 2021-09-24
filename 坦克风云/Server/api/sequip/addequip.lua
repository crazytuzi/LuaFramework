-- 抽取装备
function api_sequip_addequip(request)
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

    if moduleIsEnabled('sequip') == 0 then
        response.ret = -11000
        return response
    end

    local weeTs = getWeeTs()
    local ts = getClientTs()
    local equipCfg = getConfig('superEquipCfg')

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "sequip", "useractive"})
    local mSequip = uobjs.getModel('sequip')
    local mUserinfo = uobjs.getModel('userinfo')

    local self = {}
    -- 稀土抽取
    function self.getbyr5(cnt)
        local free = false
        -- 第一次免费
        -- if cnt==1 and (not mSequip.info.fr5 or mSequip.info.fr5 < weeTs) then
        --      mSequip.info.fr5 = weeTs
        --      free = true
        -- end

        -- 消耗稀土
        if not mSequip.info.r5 or mSequip.info.r5[1] < weeTs then
           mSequip.info.r5 = {ts, 0}
        end

        local needres = 0 -- equipCfg.r5Cost *cnt
        local next_cnt = mSequip.info.r5[2] + 1

        -- 活动打折的价格配置
        local btype = cnt == 5 and 3 or 1
        local costCfg = activity_setopt(uid, 'superEquipOff', {btype = btype, ncnt = next_cnt, cnt=cnt}, nil, equipCfg.r5Cost)
        for i = next_cnt, (next_cnt + cnt - 1) do
            local idx = i
            if i > table.length(costCfg) then
                idx = table.length(costCfg)
            end

            --print(i, table.length(costCfg), idx, needres)
            needres = needres + costCfg[ idx ]
        end

       mSequip.info.r5[1] = ts
       mSequip.info.r5[2] = mSequip.info.r5[2] + cnt

       if not free and not mUserinfo.useResource({gold=needres}) then
            return false, -9101
       end

       -- 发奖
        local reward = self.rewardbypool(1, cnt)
        if not takeReward(uid, reward) then
            return false, -403
        end
        
        -- 全线突围活动埋点
        activity_setopt(uid, 'qxtw', {action=1,num=cnt})
        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='fb',num=cnt})

       return true, reward
    end

    -- 钻石抽取
    function self.getbygold(cnt)
        local poolType = 2 --钻石奖池

        --消耗钻石
        if not mSequip.info.gold then
           mSequip.info.gold = {0, 0}
        end

        if cnt==1 and not mSequip.info.gfirst then
            mSequip.info.gfirst = 1
            poolType = 3 --金币首抽奖池
        elseif cnt==1 and mSequip.info.gold[1] < weeTs then
            poolType = 1 --稀土奖池
        end

        -- 新的一天刷新
        if mSequip.info.gold[1] < weeTs then
           mSequip.info.gold = {weeTs, 0}
        end

        local gemCost, mostgemscnt = 0, 0
        local next_cnt = mSequip.info.gold[2] + 1

        -- 活动打折的价格配置
        local btype = cnt==5 and 4 or 2
        local costCfg = activity_setopt(uid, 'superEquipOff', {btype = btype, ncnt = next_cnt, cnt=cnt}, nil, equipCfg.goldCost)

        for i = next_cnt, (next_cnt + cnt - 1) do
            local idx = i
            if i > table.length(costCfg) then
                idx = table.length(costCfg)
                mostgemscnt = mostgemscnt + 1
            end

            -- print(i, idx,  table.length(costCfg))
            gemCost = gemCost + costCfg[ idx ]
        end

        mSequip.info.gold[1] = ts
        mSequip.info.gold[2] = mSequip.info.gold[2] + cnt

        if not mUserinfo.useGem( gemCost ) then
            return false, -9102
        end

        --发奖
        local reward = self.rewardbypool(poolType, cnt)
        if not takeReward(uid, reward) then
            return false, -403
        end

        if gemCost > 0 then
            regActionLogs(uid,1,{action=1001,item=mostgemscnt,value=gemCost,params=reward})
        end
        
        -- 全线突围活动埋点
        activity_setopt(uid, 'qxtw', {action=1,num=cnt})
        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='fb',num=cnt})

        return true, reward
    end

    -- 根据不同奖池发装备
    function self.rewardbypool(nType, cnt)
        local pool = nil
        if nType == 1 then
           pool = copyTab( equipCfg.r5Pool )
        elseif nType == 2 then
            pool = copyTab( equipCfg.goldPool )
        elseif nType == 3 then
            pool = copyTab( equipCfg.goldPoolFirst )
        end

        if not pool then
            return false
        end

        local ret = {}
        for i=1, cnt do
            local result = getRewardByPool(pool)
            for k, v in pairs( result) do
                ret[k] = (ret[k] or 0) + v
            end
        end

        return ret
    end

    -----------main
    local action = request.params.action
    local cnt = math.floor(request.params.count)
    local logparams = {r={},hr={}}
    local lotteryType = 0
    local ret, code = nil, nil
    if action == 'r5' then
        ret, code = self.getbyr5(cnt)
        logparams.r = code
        lotteryType = 1
    elseif action == 'gold' then
        ret, code = self.getbygold(cnt)
        logparams.r = code
        lotteryType = 2
        --和谐版
       if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('funcs','sequip',cnt)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data.hReward = hClientReward
            logparams.hr = hReward
        end         
    end

    if not ret then
        response.ret = code
        return response
    end
    
    -- 开年大吉
    activity_setopt(uid,'openyear',{action="fb", num=cnt})
    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='fb',n=cnt})
    -- 点亮铁塔
    activity_setopt(uid,'lighttower',{act='fb',num=cnt})
    -- 愚人节大作战-抽取超级装备X次（金币与水晶抽取都算）
    activity_setopt(uid,'foolday2018',{act='task',tp='fb',num=cnt})

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1016',request.params.count)

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()

        -- 系统功能抽奖记录
        setSysLotteryLog(uid,lotteryType,"sequip.addequip",cnt,logparams) 
       
        response.data.reward = formatReward(code)
        -- response.data.sequip = mSequip.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
