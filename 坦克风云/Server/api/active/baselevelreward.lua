function api_active_baselevelreward(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
}
--end


    local uid = request.uid
    local uobjs = getUserObjs(uid)
    local level = tonumber(request.params.level) or 0

    if uid == nil  then
        response.ret = -102
        return response
    end
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel("userinfo")
    local mUseractive = uobjs.getModel("useractive")
    
    -- 状态检测
    local status = mUseractive.getActiveStatus('baseLeveling')

    if status ~= 1 then
        response.ret = status
        return response
    end
    

    if(mUseractive.info.baseLeveling.c<level)then
        response.ret=-1984
        return response
    end

    if(type(mUseractive.info.baseLeveling.t)=='table')then

        local flag=table.contains(mUseractive.info.baseLeveling.t, level)
        if(flag)then
            response.ret=-1976
            return response
        end

    end
    

    local activeCfg = getConfig("active")
    local rewards = activeCfg.baseLeveling.serverreward.box

    
    if(type(rewards[level])=='table')then
        if(type(mUseractive.info.baseLeveling.t)~='table')then
            mUseractive.info.baseLeveling.t={}
        end
        table.insert(mUseractive.info.baseLeveling.t,level)
        if not takeReward(uid,rewards[level]) then        
            response.ret = -403 
            return response
        end

        if uobjs.save() then
            local setinfo = {}
            setinfo.uid=uid
            setinfo.level=level
            setinfo.vip=mUserinfo.vip
            mUseractive.setStats('baseLeveling',setinfo)
            response.ret = 0        
            response.msg = 'Success'
        return response
    end
    else
        response.ret=-1
        return response
    end

end


