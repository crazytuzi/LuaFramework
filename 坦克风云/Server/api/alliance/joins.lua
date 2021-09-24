function api_alliance_joins(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 军团Id
    local aid = tonumber(request.params.aid) or 0

    local uid = request.uid 

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end

    local mAlliance = getAlliance(uid)

    -- 军团未找着
    if not mAlliance then
        response.ret = -8012
        return response
    end

    -- 管理员权限
    local admin = mAlliance.getAdminAuthority()
    if not admin then
        response.ret = -8008
        return response
    end

    local joinList = mAlliance.getjoinList()
        
    response.data.alliance = {joinlist = joinList}
    response.ret = 0
    response.msg = 'Success'

    return response
end 