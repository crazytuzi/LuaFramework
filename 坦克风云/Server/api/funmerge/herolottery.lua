--  各种连抽
function api_funmerge_herolottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('funmerge') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end
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

    --免费
    local heroCfg = getConfig('heroCfg')
    local freeTicketLimit=heroCfg.freeTicketLimit
    local freeTicketTime =heroCfg.freeTicketTime
    local ts = getClientTs()
    local reward = {}
    local report = {}
    local qreward = {}
    local tnum = 0
    --普通
    local pt  = mHero.info.pt or 0
    local weets  = getWeeTs()
    local lasttime = mHero.info.t or 0
    local count = mHero.info.c or 0
    local lastweets =getWeeTs(lasttime)
    --每天免费次数充值0
    if lastweets~=weets then
        count=0
    end
    if count >= freeTicketLimit and (pt+heroCfg.payTicketTime) >ts then
        response.ret=-11010
        return response
    end
    if setUserDailyActionNum(uid,'herolottery1') <= 10 then
        if count<= freeTicketLimit then
            local remain = freeTicketLimit-count
            if remain>0 then
                for i=1,remain do
                    local result = getRewardByPool(heroCfg.freeTicket)
                    for k,v in pairs(result) do
                        table.insert(qreward,{[k]=v})
                        reward[k]=(reward[k] or 0)+v
                    end
                    tnum = tnum + 1
                end
                mHero.info.c=count+remain
                mHero.info.t=ts
            end
        end
    end
    
    --高级 
    local flag = false
    if setUserDailyActionNum(uid,'herolottery2') <= 10 then
        if pt+heroCfg.payTicketTime <= ts then
            local result = getRewardByPool(heroCfg.payTicket)
            for k,v in pairs(result) do
                table.insert(qreward,{[k]=v})
                reward[k]=(reward[k] or 0)+v
            end
            tnum = tnum + 1 
            mHero.info.pt =ts
            flag = true
        end
    end
    -- 加额外的奖励
    if getClientBH() == 2 then
        local ret = takeReward(uid,heroCfg.payTicketBouns)
        if not ret then
            response.ret = -403
            return response
        end
    end

    local ret= takeReward(uid,reward)
    if not ret then
         response.ret = -403 
         return response
    end
    for k,v in pairs(qreward) do
        for k1,v1 in pairs(v) do
            table.insert(report, formatReward({[k1]=v1}))
        end
    end    
    if tnum >= 1 then
        for i=1,tnum do
            -- 春节攀升
            activity_setopt(uid, 'chunjiepansheng', {action='jz'})
            -- 悬赏任务
            activity_setopt(uid,'xuanshangtask',{t='',e='jz',n=1})
            -- 点亮铁塔
            activity_setopt(uid,'lighttower',{act='jz',num=1}) 
            -- 愚人节大作战-招募x次将领
            activity_setopt(uid,'foolday2018',{act='task',tp='jz',num=1})
            -- 感恩节拼图
            activity_setopt(uid,'gejpt',{act='tk',type='jz',num=1})
            -- 每日任务
            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum1('s1007')
        end
    end
    -- 和谐版判断
    if moduleIsEnabled('harmonyversion') ==1 and flag==true then
        local hReward,hClientReward = harVerGifts('funcs','hero',1)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data.hReward = hClientReward
    end       

    -- ptb:e(report)
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.data.reward = report
        response.data.fuck =reward
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
    
end
