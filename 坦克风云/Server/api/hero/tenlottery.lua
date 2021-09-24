function api_hero_tenlottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if moduleIsEnabled('hero') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero"})
    local mHero = uobjs.getModel('hero')
    local mBag  =  uobjs.getModel('bag')
    local mUserinfo = uobjs.getModel('userinfo')
    if mUserinfo.level <20 then
        response.ret=-11017
        return response
    end

    local heroCfg = getConfig('heroCfg')
    local tenpool= heroCfg.tenpool
    local tenheropool=heroCfg.tenheropool

    local gemCost =heroCfg.payTicketTenCost

    if not mUserinfo.useGem(gemCost) then
        response.ret = -109 
        return response
    end
    local function search(cfg,num,rand,reward,currN,report,heros)



        
        report = report or {}
        heros  = heros  or {}
        currN = (currN or 0) + 1
        local result,rewardKey =nil
        if currN==rand then
            result,rewardKey = getRewardByPool(cfg.tenheropool)
        else
            result,rewardKey = getRewardByPool(cfg.tenpool)
        end
        
        reward = reward or {}

       
        for k, v in pairs(result or {}) do
            local award = k:split('_')

            if award[1]=='hero' then
                table.insert(heros,{award[2],v})
            else
                reward[k] = (reward[k] or 0) + v 
            end  
            
        end

        table.insert(report,{formatReward(result)})

        if currN >= num then
            return reward,report,heros
        else
            return search(cfg,num,rand,reward,currN,report,heros)
        end        
    end

    local logparams = {r={},hr={}}
    setRandSeed()
    local randnum = rand(1,10)
    local reward,report,heros = search(heroCfg,10,randnum)
    if reward  and next(reward) then
        if not takeReward(uid,reward) then
            return response
        end
        logparams.r = reward
    end


    if next(heros) then
        for k,v in pairs(heros) do
            local flag =mHero.addHeroResource(v[1],v[2])
            if string.find(v[1],'h') then
                logparams.r['hero_'..v[1]] = (logparams.r['hero_'..v[1]] or 0) + 1-- 加将领 第二个值是品质不是数量
            else
                logparams.r['hero_'..v[1]] = (logparams.r['hero_'..v[1]] or 0) + v[2]
            end
            
            if not flag then
                return response
            end
        end
        
    end

    regActionLogs(uid,1,{action=43,item="",value=gemCost,params=reward})
    processEventsBeforeSave()
    regEventBeforeSave(uid,'e1')
    if getClientBH() == 2 then
        local ret = takeReward(uid,heroCfg.payTenTicketBouns)
        if not ret then
            response.ret = -403
            return response
        end
    end

    if setUserDailyActionNum(uid,'tenHerolottery') > 10 then
        response.ret = -1973
        return response
    end
    
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='jz',num=10})
      -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='jz',n=10})
     -- 点亮铁塔
    activity_setopt(uid,'lighttower',{act='jz',num=10}) 
    -- 愚人节大作战-招募x次将领
    activity_setopt(uid,'foolday2018',{act='task',tp='jz',num=10})
      -- 感恩节拼图
    activity_setopt(uid,'gejpt',{act='tk',type='jz',num=10})

    -- 每日任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1007',10)
    
    --和谐版
   if moduleIsEnabled('harmonyversion') ==1 then
        local hReward,hClientReward = harVerGifts('funcs','hero',10)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data.hReward = hClientReward
        logparams.hr = hReward
    end  

    -- 系统功能抽奖记录
    setSysLotteryLog(uid,3,"hero.lottery",10,logparams)    

    if uobjs.save() then        

        response.data.hero =mHero.toArray(true)
        response.data.hero.report = report
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response

end
