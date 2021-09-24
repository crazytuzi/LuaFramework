--
-- 大战前夕
-- User: luoning
-- Date: 14-9-1
-- Time: 下午7:11
--
function api_active_totalrecharge2(request)
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

    -- 活动名称 ，累计充值
    local aname = 'totalRecharge2'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    --activity_setopt(uid,'totalRecharge',{num=gold_num})
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active.totalRecharge2."..mUseractive.info[aname].cfg)
    local currentGetNum = (mUseractive.info[aname].c or 0) + 1
    local currentCost = activeCfg.cost[currentGetNum] or 0
    if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
        response.ret = -1981
        return response
    end

    local reward = activeCfg.serverreward.r[currentGetNum]

    if not takeReward(uid,reward) then
        response.ret = -403
        return response
    end


    mUseractive.info[aname].c = currentGetNum

    processEventsBeforeSave()

    if  uobjs.save() then
        processEventsAfterSave()
        -- 统计
        mUseractive.setStats(aname,{reward=currentGetNum})
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

