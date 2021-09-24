-- 绑定类 每日充值返利活动
-- 凌晨清数据
function api_active_binddayrecharge(request)
    local response = {
        ret=-1,
        msg='error',
        data = {bindDayRecharge={}},
    }

    local uid = request.uid
    local rwdday = tonumber(request.params.day) or 1

     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，每日充值
    local aname = 'bindDayRecharge'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    
    -- 开关未开启
    if not switchIsEnabled('bindActive') then
        response.ret = -102
        return response
    end

    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    local activeCfg = getConfig("active."..aname)
    -- 没超过指定注册天数
    local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
    if regDays < activeCfg.bindTime[1] or regDays > activeCfg.bindTime[2] + activeCfg.rewardTime then
        response.ret = -102
        return response
    end 

    local weeTs = getWeeTs()
    local lastTs = mUseractive.info[aname].t or 0

    if weeTs > lastTs then
        mUseractive.info[aname].c = 0
        mUseractive.info[aname].v = 0
        mUseractive.info[aname].rs = {}
    end

    local currentCost = activeCfg.reward[regDays].cost[rwdday]

    if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
        response.ret = -1981
        return response
    end
    
    if mUseractive.info[aname].rs[tostring(rwdday)] then
        response.ret = -401
        return response
    end
    
    local reward = activeCfg.reward[regDays].serverreward.r[rwdday]
    local ret = takeReward(uid,reward)

    -- 更新最后一次抽奖时间
    mUseractive.info[aname].t = weeTs
    mUseractive.info[aname].c = 1
    mUseractive.info[aname].rs[tostring(rwdday)] = 1
        
    processEventsBeforeSave()

    if ret and uobjs.save() then        
        processEventsAfterSave()
        
        response.data[aname] = mUseractive.info[aname]

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
