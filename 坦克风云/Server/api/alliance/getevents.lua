function api_alliance_getevents(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local page = tonumber(request.params.page) or 0    
    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end
    
    local execRet, code = M_alliance.getEvents{uid=uid,page=page}
    
    if not execRet then
        response.ret = code
        return response
    end
    
    response.data = execRet
    response.ret = 0
    response.msg = 'Success'
    
    return response
end	