function api_active_bindbaselevelreward(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
    }
    --end


    local uid = request.uid
    local uobjs = getUserObjs(uid)
    local level = tonumber(request.params.level) or 0
    local aname = 'bindbaseLeveling'

    if uid == nil  then
        response.ret = -102
        return response
    end
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel("userinfo")
    local mUseractive = uobjs.getModel("useractive")
    
    -- 开关未开启
    if not switchIsEnabled('bindActive') then
        response.ret = -102
        return response
    end
    
    -- 状态检测
    local status = mUseractive.getActiveStatus(aname)

    if status ~= 1 then
        response.ret = status
        return response
    end
    
    local activeCfg = getConfig("active")[aname]
    
    -- 没超过指定注册天数
    local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
    if regDays < activeCfg.bindTime[1] or regDays > activeCfg.bindTime[2] + activeCfg.rewardTime then
        response.ret = -102
        return response
    end 
    

    if(mUseractive.info[aname].c < level)then
        response.ret = -1984
        return response
    end

    if(type(mUseractive.info[aname].t) == 'table')then

        local flag=table.contains(mUseractive.info[aname].t, level)
        if(flag)then
            response.ret = -1976
            return response
        end

    end
    
    local rewards = activeCfg.serverreward.box

    
    if(type(rewards[level]) == 'table')then
        if(type(mUseractive.info[aname].t) ~= 'table')then
            mUseractive.info[aname].t = {}
        end
        table.insert(mUseractive.info[aname].t,level)
        if not takeReward(uid,rewards[level]) then        
            response.ret = -403 
            return response
        end

        if uobjs.save() then
            local setinfo = {}
            setinfo.uid = uid
            setinfo.level = level
            setinfo.vip = mUserinfo.vip
            mUseractive.setStats(aname,setinfo)
            response.ret = 0        
            response.msg = 'Success'
        return response
    end
    else
        response.ret=-1
        return response
    end

end
