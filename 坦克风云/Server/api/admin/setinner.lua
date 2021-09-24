--
-- 设置内部账号标识
-- chenyunhe
--
function api_admin_setinner(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    if uid < 1 then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    mUserinfo.flags.inner = 1

 
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end