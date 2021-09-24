--获取军团战的上阵队列
function api_alliance_getqueue(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local aid = tonumber(request.params.aid) or 0
    local uid = request.uid
    -- 成员id
    local memuid = tonumber(request.params.memuid)

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local date  = getWeeTs()
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local execRet,code = M_alliance.getqueue({uid=uid,aid=aid,date=date})

    if not execRet then
        response.ret = code
        return response
    end


    

    response.ret = 0
    response.msg = 'Success'
    response.data.queue=execRet.data.queue
    response.data.members=execRet.data.members
    return response
end