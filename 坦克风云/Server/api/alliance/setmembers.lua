function api_alliance_setmembers(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    

    -- 成员签名，0-100字
    local notice = tostring(request.params.notice) or ''

    local uid = request.uid

    if uid == nil or aid == 0 or utfstrlen(notice) > 200 then
        response.ret = -102
        return response
    end
    
    local mAlliance = getAlliance(uid)

    if not mAlliance.isAllianceMember(uid) then
        response.ret = -8018
        return response
    end

    if not mAlliance.setMemNotice(notice) then
        return response
    end
    
    response.ret = 0
    response.msg = 'Success'
    
    return response
end	