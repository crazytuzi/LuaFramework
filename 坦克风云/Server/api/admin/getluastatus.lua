function api_admin_getluastatus(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local zoneId = getZoneId()
    local baseId = 1000000
    local uid = zoneId 
    
    if userLogin(uid) <= 0 then
        -- response.ret = -104
        -- return response
    end

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel("userinfo")
    mUserinfo.nickname = "statusTest" .. tostring(zoneId)

    if mUserinfo.uid == uid and uobjs.save() then
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end