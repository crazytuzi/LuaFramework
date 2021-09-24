function api_active_rechargerebate(request)
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
    local aname = 'rechargeRebate'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    local currentCost = tonumber(mUseractive.info.rechargeRebate.c)
    if currentCost <= 0  then
        response.ret = -1981
        return response
    end
    
    local reward = {userinfo_gems=currentCost}
    local ret = takeReward(uid,reward)

    
    mUseractive.info[aname].c = -1
        
    processEventsBeforeSave()

    if ret and uobjs.save() then        
        processEventsAfterSave()
        -- 统计
        mUseractive.setStats(aname,{reward=currentCost})
        response.ret = 0
        response.msg = 'Success'
        response.data.gld=currentCost
    end
    
    return response
end