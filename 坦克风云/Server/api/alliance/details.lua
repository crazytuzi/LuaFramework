function api_alliance_details(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 申请的军团Id
    local aid = tonumber(request.params.aid) or 0

    local uid = request.uid 

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end

    local mAlliance = getAlliance(uid)

    -- 军团不存在
    if not mAlliance then
        response.ret = -8017
        return response
    end

    local allianceDetails = mAlliance.getDetails()

    response.data.alliance = allianceDetails
    response.ret = 0
    response.msg = 'Success'
    
    return response
end 