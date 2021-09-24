-- 扫荡
-- 点击扫荡一次性把结果结算完,然后逐条反馈给用户.
-- 玩家家里没兵也一样扫荡
-- 
function api_echallenge_raid(request)
    local response = {
        ret=-1,
        msg='error',
        data = {echallengeraid={}},
    }

    if moduleIsEnabled('ec') == 0 then
        response.ret = -6004
        return response
    end

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","echallenge","accessory"})
    local mChallenge = uobjs.getModel("echallenge")
    local mUserinfo = uobjs.getModel('userinfo')
    local mAccessory = uobjs.getModel('accessory')
    local mHero      = uobjs.getModel('hero')


    -------------------- start vip新特权 增加捐献次数
    if moduleIsEnabled('vec') == 1 and mUserinfo.vip>0 then
            local vipRelatedCfg = getConfig('player.vipRelatedCfg')
            if type(vipRelatedCfg)=='table' then
                local vip =vipRelatedCfg.raidEliteChallenge[1]
                if mUserinfo.vip<vip then
                   response.ret = -6005
                   return response
                end
            end                   
    end
    --------------------- end

    local weeTs = getWeeTs()
    if (mChallenge.reset_at or 0) < weeTs then
        mChallenge.reset(weeTs)
    end

    -- 配置
    local challengeCfg = getConfig('eliteChallengeCfg')
    if mUserinfo.vip < challengeCfg.raidVipLv then
        response.ret = -6005
        return response
    end
    
    -- 每日首次扫荡（没有重置），需要扣能量
    if mChallenge.resetnum == 0 and mUserinfo.energy <= 0 then
        response.ret = -2001
        return response
    end

    -- table challenges
    local challenges = mChallenge.getAssaultable()

    -- 没有符合扫荡条件的关卡
    if #challenges <= 0 then
        response.ret = -6008
        return response
    end
        
    local report = {}
    local getRewardByPool = getRewardByPool
    local rRecord = {}  -- 奖品记录，（格式化好的数据，装备添加后会生成装备的唯一id）

    local randCnt = 0
    for _,v in ipairs(challenges) do
        if challengeCfg.challenge[v] then
            if not mAccessory.getAddAccessoryFlag(challengeCfg.challenge[v].aDropMaxNum,challengeCfg.challenge[v].fDropTypeMaxNum) then
                report[v] = -6009
                break
            end

            if mChallenge.resetnum == 0 and not mUserinfo.useEnergy(1) then
                break
            end

            report[v] = mChallenge.getRewardBySid(v)            
            local ret,rDetail = takeReward(uid,report[v])
            if not ret then
                report[v] = -6009
                break
            end
            
            for k,v in pairs(rDetail or {}) do
                for m,n in pairs(v) do                    
                    if type(n) == 'table' then
                        if not rRecord[m] then rRecord[m] = {} end
                        for rk,rv in pairs(n) do
                            if type(rv) == 'number' then
                                rRecord[m][rk] = (rRecord[m][rk] or 0) + rv
                            else
                                rRecord[m][rk] = rv
                            end
                        end
                    end                     
                end
            end

            mChallenge.kill(v)
            mHero.refreshFeat("t6",1,1)
            -- 中秋赏月活动埋点
            activity_setopt(uid, 'midautumn', {action='ab'})
            -- 国庆活动埋点
            activity_setopt(uid, 'nationalDay', {action='ab'})
            
            randCnt = randCnt + 1
        end
    end
    
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='ab', num=randCnt})
    -- 猎杀潜航
    activity_setopt(uid,'silentHunter',{action='ab',num=randCnt})
    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='ab',n=randCnt})
    --点亮铁塔
    activity_setopt(uid,'lighttower',{act='ab',num=randCnt}) 
    --岁末回馈
    activity_setopt(uid,'feedback',{act='ab',num=randCnt})
    -- 愚人节大作战-攻打X次补给线
    activity_setopt(uid,'foolday2018',{act='task',tp='ab',num=randCnt},true)

    -- 国庆七天乐
    activity_setopt(uid,'nationalday2018',{act='tk',type='ab',num=randCnt})   
    for k,v in pairs(report) do
        if type(report[k]) == 'table' then
            report[k] = formatReward(v)
            -- 啤酒节 数据添加到每一关中
            local beerreward = activity_setopt(uid,'beerfestival',{act='Rate2',num=1})
            if type(beerreward)=='table' and next(beerreward) then
                report[k].beer = beerreward
            end
            -- 感恩节2017 数据添加到每一关中
            local thanksgiving = activity_setopt(uid,'thanksgiving',{act=8,num=1,w=1})
            if type(thanksgiving)=='table' and next(thanksgiving) then
                report[k].thank = thanksgiving
            end
        end
    end

    processEventsBeforeSave()
    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s204',1)
    mDailyTask.changeTaskNum1('s1006')
    
    if uobjs.save() then    
        processEventsAfterSave()
        
        response.data.echallengeraid.report = report
        response.data.echallengeraid.reward = rRecord
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
