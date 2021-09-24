function api_user_growreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local level = tonumber(request.params.level)
   
    
    if moduleIsEnabled('gw')== 0 then
        response.ret = -9000
        return response
    end

    if mUserinfo.grow ~=1 then
        response.ret = -2011
        return response
    end

    if mUserinfo.level <level then
        response.ret = -301
        return response
    end

    if level <= mUserinfo.growrd then
        response.ret = -102
        return response
    end

    local rewards= getConfig('player.buygrowreward')
    
    if type(rewards[level])~='table' then
        response.ret = -1981
        return response
    end

    if not takeReward(uid,rewards[level]) then
        response.ret = -403
        return response
    end

    mUserinfo.growrd=level
    local mTask = uobjs.getModel('task')
    mTask.check()  
    regActionLogs(uid,6,{action=5002,item='growreward',value=rewards[level],params={}})
    if uobjs.save() then
        response.ret = 0   
        processEventsAfterSave()     
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    end
    
    return response

end