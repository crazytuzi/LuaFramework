function api_alliance_skillupgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    local sid = tonumber(request.params.sid) or 0
    local uid = request.uid 

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end
    
    local mAlliance = getAlliance(uid)

    -- 管理员权限
    local admin = mAlliance.getAdminAuthority()
    if not admin then
        response.ret = -8008
        return response
    end

    mAlliance.joinCondition = {
        joinNeedLv = joinNeedLv,
        joinNeedFc = joinNeedFc,
    }
    mAlliance.foreignNotice = foreignNotice
    mAlliance.internalNotice = internalNotice
    mAlliance.joinType = joinType

    if not mAlliance.updateSettings() then
        return response
    end
    
    response.ret = 0
    response.msg = 'Success'
    
    return response
end	