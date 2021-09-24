-- 配件进化活动每天可以购买超量水晶
-- 凌晨清数据
function api_active_accessoryevolution(request)
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

    -- 活动名称，配件进化
    local aname = 'accessoryEvolution'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mbag = uobjs.getModel('bag')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active.accessoryEvolution")
    local lastTs  = mUseractive.info[aname].t or 0
    local gemCost = tonumber(activeCfg.serverreward.gems)
    local maxcount= tonumber(activeCfg.serverreward.maxBuyTime)
    if weeTs > lastTs then
        mUseractive.info[aname].c = 0
        mUseractive.info[aname].v = 0
    end

    local currentGetNum = (mUseractive.info[aname].c or 0) + 1
    
    if (currentGetNum >maxcount) then 
        response.ret = -1987
        return response
    end
    if gemCost <= 0 then
        response.ret = -1981
        return response
    end

     if not mUserinfo.useGem(gemCost) then
        response.ret = -109
        return response
    end
    
    local reward = activeCfg.serverreward.reward
   
    local ret = takeReward(uid,reward)
    -- 统计
    mUseractive.setStats(aname,{reward=currentGetNum,weeTs=weeTs})
    --添加actionlog
    regActionLogs(uid,1,{action=5003,item="",value=gemCost,params={buyNum=currentGetNum,reward=reward}})

    -- 更新最后一次抽奖时间
    mUseractive.info[aname].t = weeTs
    mUseractive.info[aname].c = currentGetNum
        
    processEventsBeforeSave()

    if ret and uobjs.save() then        
        processEventsAfterSave()
        response.data.reward = formatReward(reward)
        response.data.gems   =mUserinfo.gems
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
