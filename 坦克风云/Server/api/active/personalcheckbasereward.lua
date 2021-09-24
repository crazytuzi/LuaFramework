function api_active_personalcheckbasereward(request)

    local response = {
        ret=-1,
        data={},
        msg="error",
    }

    local aname = 'personalCheckPoint'
    local uid =request.uid
    if uid==nil then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})


    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")
    -- ptb:e(mUseractive.info.personalCheckPoint)
    local activeCfg = getConfig("active")
    -- local cfg = mUseractive.info.personalCheckPoint.cfg and 2
    local cfg = mUseractive.info.personalCheckPoint.cfg
    local reward = activeCfg.personalCheckPoint[cfg].serverreward.allCanGet
    local num = reward[1].star
    local basereward = reward[1].r
    if reward == nil then
        response.ret = -102 
        return response
    end
    if mUseractive.info.personalCheckPoint.re == nil then
        mUseractive.info.personalCheckPoint.re = 0 --未领取
    end
    if mUseractive.info.personalCheckPoint.re == 1 then
        response.ret = -1976 
        return response
    end
    if type(reward)=='table' then

        if mUseractive.info.personalCheckPoint.t < num then
            response.ret = -102 
            return response
        end
        if not takeReward(uid,basereward) then        
            response.ret = -403 
            return response
        end
        regActionLogs(uid,6,{action=5007,item='personalCheckPoint',value=basereward.userinfo_gems,params={}})
        mUseractive.info.personalCheckPoint.re = 1 
        local setinfo={}
        setinfo.uid=uid
        if uobjs.save() then
            mUseractive.setStats('personalCheckPoint',setinfo)
            response.data[aname] =mUseractive.info[aname]
            response.data[aname].reward = formatReward(basereward)
            response.ret = 0        
            response.msg = 'Success'
            return response
        end
       
    end

    return response
end