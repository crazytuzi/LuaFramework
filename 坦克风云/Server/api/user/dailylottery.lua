function api_user_dailylottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local lotteryType = request.params.type or 1

    if uid == nil or (lotteryType ~= 1 and lotteryType ~= 2) then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')

    setRandSeed()

    local awards = {}
    local ConsumeType ,iGems,buyPropNums,usePropNums = nil,0,0,0

    local logparams = {r={},hr={}}

    if lotteryType == 1 then
        awards,ConsumeType,iGems,buyPropNums,usePropNums  = mUserinfo.ordinaryLuckyGoods()
    elseif lotteryType == 2 then
        if mUserinfo.getLevel() < 10 then
            response.ret = -301
            return response
        end

        awards,ConsumeType,iGems,buyPropNums ,usePropNums = mUserinfo.advancedLuckyGoods()
    end
    logparams.r = awards
    
    local mTask = uobjs.getModel('task')
    mTask.check()

    local mDailyTask = uobjs.getModel('dailytask')
    -- 购买道具
    if iGems > 0 then   
        mDailyTask.changeNewTaskNum('s405',1) --商城购买道具任务触发
        regActionLogs(uid,1,{action=27,item="p47",value=iGems,params={useNum=buyPropNums}})
    end

    if usePropNums>1 then
        mDailyTask.changeNewTaskNum('s404',1) --新的日常任务检测， 抽奖任务触发
    end

    if setUserDailyActionNum(uid,'userlottery'..lotteryType) > 10 then
        response.isLuckyWhat = lotteryType
        response.ret = -1973
        return response
    end

    -- 和谐版判断 
    if moduleIsEnabled('harmonyversion') ==1 then
        --普通
        local harnum=1
        if lotteryType == 2 then
            harnum=3--高级
        end        
        local hReward,hClientReward = harVerGifts('funcs','daily',harnum)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data.hReward = hClientReward

        logparams.hr = hReward
    end    

    processEventsBeforeSave()
    if uobjs.save() then    
        processEventsAfterSave()   
        -- 系统功能抽奖记录
        setSysLotteryLog(uid,lotteryType,"user.dailylottery",1,logparams,true,false)      
        
        for k,v in pairs(awards) do
            if type(v) == 'table' and next(v) then
                if k == 'o' then
                    local mTroops  = uobjs.getModel('troops')
                    response.data.troops = mTroops.toArray(true)
                end
            end
        end
        
        local mBag  = uobjs.getModel('bag')
        response.data.bag = mBag.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.awards = awards
        response.data.ConsumeType = ConsumeType
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end
    
    return response
end
