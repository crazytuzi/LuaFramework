function api_user_dailyaward(request)
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

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')

    -- 每日Salary
    -- 声望按军衔等级读配置文件
    -- 5颗宝石固定    
    local weeTs = getWeeTs()

    if mUserinfo.flags.daily_award >= weeTs then
        return response
    end

    local cfg = getConfig('player.daily_honor')

    local rankLevel = arrayGet(mUserinfo,'rank',1)
    local honor = cfg[rankLevel]
    local res = {gems=5,honors=honor}

    if not mUserinfo.addResource(res) then
        response.ret = -1991
        return response
    end

    mUserinfo.flags.daily_award = weeTs
        
    local mTask = uobjs.getModel('task')
    mTask.check()  

    if uobjs.save() then
        response.ret = 0        
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    end
    
    return response
end
