--获取积分流向log

function api_userwar_getpointlog(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end

    local cobjs = getCacheObjs(uid,1,'getpoint')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops"})
    local mHero     = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')

    response.data.pointlog=mUserwar.pointlog
    response.data.point=mUserwar.point
    response.ret = 0
    response.msg = 'Success'
    return response
end