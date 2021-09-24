-- 刷新vip
function api_user_refvip(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    local vip =mUserinfo.updateVipLevel()
    mUserinfo.vip=vip
    
    if  uobjs.save() then
        response.ret = 0
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    end

    return response
   
end