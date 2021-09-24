-- 实名认证
function api_user_auth(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local uid = tonumber(request.uid) or 0
    local age = tonumber(request.params.age) or 0
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
   
    if moduleIsEnabled("auth") == 0 then
        response.ret = -114
        return response
    end

    if mUserinfo.flags.auth == 1 and mUserinfo.flags.age>0 then
        response.ret = 0
        return response
    end   

    mUserinfo.flags.auth = 1
    mUserinfo.flags.age = age
    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end
