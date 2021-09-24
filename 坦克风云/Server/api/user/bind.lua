function api_user_bind(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local uid = request.uid or 0
    if uid == 0 then
        response.ret = -104
        response.msg = 'uid invalid'
        return response
    end

    -- local username = request.params.username or ''
    
    -- if string.len(username) < 3 or string.len(username) > 40 then
    --     response.ret = -102
    --     response.msg = 'username invalid'
    --     return response
    -- end

    -- if userGetUid(username) ~= 0 then
    --     response.ret = -103
    --     response.msg = 'username already exists'
    --     return response
    -- end
        
    -- local password = request.params.password or ''

    -- if string.len(password) < 3 or string.len(password) > 40 then
    --     response.ret = -104
    --     response.msg = 'password invalid'
    --     return response
    -- end
    
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')

    -- 已经绑定过了
    if tonumber(mUserinfo.guest) ~= 0 then
        response.ret = -104
        response.msg = 'Repeat bind'
        return response
    end

    -- mUserinfo.password = password
    -- mUserinfo.username = username
    mUserinfo.guest = 1
    mUserinfo.flags.bindAward = 1

    local award = {gems=20}
    mUserinfo.addResource(award)

    if uobjs.save() then
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0
        response.msg = "success"
    else
        response.ret = -106
        response.msg = "bind failed"        
    end
    
    return response
end
