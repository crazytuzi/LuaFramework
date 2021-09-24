-- 战争雕像数据
function api_statue_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 战争雕像系统没有开启
    if not switchIsEnabled('statue') then
        response.ret = -27000
        return response
    end

    local uid = tonumber(request.uid)
    if uid == nil then
        response.ret = -102
        return response
    end

    local ts = getClientTs()
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","statue"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mStatue = uobjs.getModel('statue')

    response.data.statue = mStatue.toArray(true)

    response.ret = 0        
    response.msg = 'Success' 
    return response
end