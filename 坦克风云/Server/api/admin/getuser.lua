function api_admin_getuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname) 
    local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
    local data_name = request.params.data_name

    if uid < 1 or data_name == nil then
        response.ret = -102
        return response
    end

    if userLogin(uid) <= 0 then
        response.ret = -104
        return response
    end
    
    local uobjs = getUserObjs(uid,true)
    local model = uobjs.getModel(data_name)

    if model then
        response.data[data_name] = model.toArray()
        if data_name == 'userinfo' then
            local mBuildings = uobjs.getModel('buildings')
            response.data.buildings = mBuildings.toArray(true)
        end

        response.ret = 0
        response.msg = 'Success'
    end

    return response
end