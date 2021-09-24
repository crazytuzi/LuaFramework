function api_active_doorreward(request)
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

    -- 活动名称，门后有鬼
    local aname = 'doorGhost'
        
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


    local rc = mUseractive.info[aname].c+1


    local activeCfg = getConfig("active.doorGhost."..mUseractive.info[aname].cfg..".serverreward.ghostReward")
    


    local ghost = tonumber(mUseractive.info[aname].v)

    if ghost< tonumber(activeCfg[rc].nm) then
        response.ret=-1981
        return response
    end

    local  reward = activeCfg[rc].reward

    local ret = takeReward(uid,reward)
    if not ret then
        response.ret = -403
        return response
    end
   
    mUseractive.info[aname].c=rc
    if  uobjs.save() then        
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end