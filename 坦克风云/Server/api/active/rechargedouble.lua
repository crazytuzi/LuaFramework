-- 前线军需活动
function api_active_rechargedouble(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local cost = request.params.cost
    local action = tonumber(request.params.action) or 1 -- 1是获取信息，2是领取

     if uid == nil or (cost == nil and action ~= 1 ) then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')

    -- 活动名称，
    local aname = 'rechargeDouble'

    -- 状态检测
    local status = mUseractive.getActiveStatus(aname)
    if status ~= 1 then
        response.ret = status
        return response
    end

    if action == 1 then
        response.data.useractive = {}
        response.data.useractive[aname] = mUseractive.info[aname]
        response.ret = 0        
        response.msg = 'Success'

        return response
    end

    local addGems = arrayGet(mUseractive.info[aname].d,cost,0)

    if addGems <= 0 or addGems > 10000 then
        response.ret = -1981
        return response
    end

    if not mUserinfo.addResource({gems=addGems}) then
        response.ret = -1991
        return response
    end

    mUseractive.info[aname].d[cost] = -mUseractive.info[aname].d[cost]

    local log = {parmas=request.params,gems=addGems}
    writeLog(log,aname)
    
    if uobjs.save() then
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response
end
