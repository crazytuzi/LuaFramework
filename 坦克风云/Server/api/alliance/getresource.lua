-- 获取军团是资源

function api_alliance_getresource(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    if mUserinfo.alliance <=0 then
        response.ret = -8023
        return response
    end
    local weeTs=getWeeTs()
    local execRet, code = M_alliance.getResource{uid=uid,aid=mUserinfo.alliance,weet=weeTs}
    
    if not execRet then
        response.ret = code
        return response
    end
    response.ret = 0
    response.data.ainfo = execRet.data.info
    response.msg = 'Success'
    
    return response

    
end