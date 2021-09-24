--获取军团战的战报
function api_alliance_getbattlelog(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid   = request.uid
    local warid= tonumber(request.params.warid) or 0
    local aid   = tonumber(request.params.aid) or 0
    local method= tonumber(request.params.type) or 1
    local mins = tonumber(request.params.minTs) or 0
    local maxs = tonumber(request.params.maxTs) or 0
    local date  = getWeeTs()

    if uid == nil or  aid == 0  then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local execRet, code = M_alliance.getbattlelog{uid=uid,aid=aid,warid=warid,method=method,min=mins,max=maxs}
    
    if not execRet then
        response.ret = code
        return response
    end

    response.ret = 0
    response.data.ulog = execRet.data.ulog
    response.data.alog = execRet.data.alog
    response.data.unum = execRet.data.unum
    response.data.mydie = execRet.data.mydie
    response.data.mykill = execRet.data.mykill
    response.data.rednum = execRet.data.rednum
    response.data.bluenum = execRet.data.bluenum
    response.msg = 'Success'
    
    return response
end