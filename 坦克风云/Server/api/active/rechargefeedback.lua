-- 充值反馈
function api_active_rechargefeedback(request)
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
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')

    -- 活动名称，
    local aname = 'rechargeFeedback'

    -- 状态检测
    local status = mUseractive.getActiveStatus(aname)
    if status ~= 1 then
        response.ret = status
        return response
    end
    if mUserinfo.buygems<=0 then
        response.ret = -9001
        return response
    end

    mUseractive.info[aname].get = mUseractive.info[aname].get or 0
    if 1 == tonumber(mUseractive.info[aname].get) then
        response.ret = -9002
        return response
    end

    local activeCfg = mUseractive.getActiveConfig(aname)
    local reward = copyTable( activeCfg.serverreward.r )

    if not takeReward(uid, reward) then        
        response.ret = -403 
        return false, response
    end
    mUseractive.info[aname].get = 1

    writeLog({parmas=request.params, info=mUseractive.info[aname]}, aname)
    
    if uobjs.save() then
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response
end
