function api_active_newyear(request)
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

    local active = getConfig('active.newyear')
    local ts = getClientTs()

    if type(active) ~= 'table' or active.enable ~= 'Y' or ts < active.st or ts > active.et then
        response.ret = -401
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    if not mUserinfo.flags.active then
        mUserinfo.flags.active = {}
    end

    if mUserinfo.flags.active.newyear then
        response.ret = -402
        return response
    end

    if not takeReward(uid,active.reward) then
        response.ret = -403
        return response
    end

    mUserinfo.flags.active.newyear = ts
    
    local mTask = uobjs.getModel('task')
    mTask.check()  

    if uobjs.save() then
        response.ret = 0        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.msg = 'Success'
    end
    
    return response
end
