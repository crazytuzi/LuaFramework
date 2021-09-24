function api_user_pwdupdate(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local uid = request.uid or 0 
    if uid == 0 then
        response.ret = -102
        response.msg = 'uid invalid'
        return response
    end
    
    local oldPwd = request.params.oldpassword
    local newPwd = request.params.newpassword    

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')

    if tostring(mUserinfo.password) ~= tostring(oldPwd) then
        response.ret = -131
        response.msg = 'Passwords do not match'
        return response
    end

    mUserinfo.password = newPwd

    if uobjs.save() then
        response.ret = 0
        response.msg = "success"
    else
        response.ret = -106
        response.msg = "password update failed"        
    end
    
    return response
end
