function api_active_uservipreward(request)
    local response = {
        ret=-1,
        msg='error',
        data={},

    }

    local uid = request.uid
    if uid==nil then
        response.ret=-102    
        return response
    end

    --print(uid)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    --ptb:e(uobjs)
    local aname    ="userVip"
    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")

    local activStatus = mUseractive.getActiveStatus(aname)

    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active")

    local vip = (mUseractive.info[aname].c or 0) + 1

    if vip<=  mUseractive.info[aname].v  then
        response.ret = -1981
        return response
    end

    local rewards = activeCfg.userVip.serverreward.box
    if(type(rewards[vip])~='table')then
        response.msg='vip error'
        return response
    end 
    
    mUseractive.info.userVip.c = vip
    if uobjs.save() then
        local setinfo = {}
        setinfo.vip=vip
        mUseractive.setStats('userVip',setinfo)
        response.ret = 0        
        response.msg = 'Success'
        return response
    end

    return response
    
end