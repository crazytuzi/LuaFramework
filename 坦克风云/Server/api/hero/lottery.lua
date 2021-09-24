--  各种连抽
function api_hero_lottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local lotteryType = request.params.method or 1

    if uid == nil or (lotteryType ~= 1 and lotteryType ~= 2) then
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
    local ActionLog=false
    local gemCost =0
    --免费
    local heroCfg = getConfig('heroCfg')
    local freeTicketLimit=heroCfg.freeTicketLimit
    local freeTicketTime =heroCfg.freeTicketTime
    local ts = getClientTs()
    --普通
    local pool = {}
    if lotteryType==1 then
        local weets  = getWeeTs()
        local lasttime = mHero.info.t or 0
        local count = mHero.info.c or 0
        local lastweets =getWeeTs(lasttime)
        --每天免费次数充值0
        if lastweets~=weets then
            count=0
        end

        if count> freeTicketLimit then
            response.ret=-11010
            return response
        end

        if lasttime>=weets then
            if lasttime+freeTicketTime > ts  then
                response.ret=-11011
                return response
            end
        end
        
        pool =heroCfg.freeTicket
        mHero.info.c=count+1
        mHero.info.t=ts
    else
        --高级 

        local pay = mHero.info.p or 0
        local pc  = mHero.info.pc or 0
        local pt  = mHero.info.pt or 0
        

        local free =request.params.free or 0
        --==1 免费的高级招募 or 花钱的
        if free ==1 then
            if pt+heroCfg.payTicketTime >ts then
                response.ret=-11011
                return response
            end
            pool=heroCfg.payTicket

            mHero.info.pt =ts
        else
            gemCost=heroCfg.payTicketCost
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end
            if pay ==0 then
                pool=heroCfg.payTicketPayFirst
            else
                pool=heroCfg.payTicket
            end    
            mHero.info.p =pay+1
            mHero.info.pc =pc+gemCost
            ActionLog=true
            
        end
        -- 加额外的奖励
        if getClientBH() == 2 then
            local ret = takeReward(uid,heroCfg.payTicketBouns)
            if not ret then
                response.ret = -403
                return response
            end
        end

    end


    --添加道具或者英雄
    local reward=getRewardByPool(pool)
    local ret= takeReward(uid,reward)
    local logparams = {r=reward}

    regActionLogs(uid,1,{action=43,item="",value=gemCost,params=reward})
   
    if not ret then
         response.ret = -403 
         return response
    end

    if setUserDailyActionNum(uid,'herolottery'..lotteryType) > 10 then
        response.ret = -1973
        return response
    end
    
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

    -- 和谐版判断
    if moduleIsEnabled('harmonyversion') ==1 and lotteryType==2 then
        local hReward,hClientReward = harVerGifts('funcs','hero',1)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        logparams.hr = hReward
        response.data.hReward = hClientReward
    end  

    --ptb:e(reward)
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()

        -- 系统功能抽奖记录
        setSysLotteryLog(uid,lotteryType,"hero.lottery",1,logparams) 
         
        response.data.hero =mHero.toArray(true)
        response.data.reward = formatReward(reward)
        response.data.fuck =reward
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
    
end
