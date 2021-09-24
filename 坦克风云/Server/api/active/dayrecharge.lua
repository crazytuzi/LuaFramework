-- 每日充值返利活动
-- 凌晨清数据
function api_active_dayrecharge(request)
    local response = {
        ret=-1,
        msg='error',
        data = {wheelFortune={}},
    }

    local uid = request.uid

     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，每日充值
    local aname = 'dayRecharge'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local lastTs = mUseractive.info[aname].t or 0

    if weeTs > lastTs then
        mUseractive.info[aname].c = 0
        mUseractive.info[aname].v = 0
    end

    local currentGetNum = (mUseractive.info[aname].c or 0) + 1
    local currentCost = activeCfg.cost[currentGetNum] or 0

    if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
        response.ret = -1981
        return response
    end
    
    local reward = activeCfg.serverreward.r[currentGetNum]
    local ret = takeReward(uid,reward)

    -- 统计
    mUseractive.setStats(aname,{reward=currentGetNum,weeTs=weeTs})

    -- 更新最后一次抽奖时间
    mUseractive.info[aname].t = weeTs
    mUseractive.info[aname].c = currentGetNum
        
    processEventsBeforeSave()

    if ret and uobjs.save() then        
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
